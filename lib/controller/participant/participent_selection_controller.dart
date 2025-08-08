import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:http/http.dart' as http;
import 'package:mobile_scanner/mobile_scanner.dart';
import '../../controller/trip/trip_controller.dart';
import '../../data/constants.dart';
import '../../data/token.dart';
import '../../model/friend/friend_model.dart';
import '../../views/trip/scan_trip/generate_qr_screen.dart';


class TripParticipantSelectorController extends GetxController {
  TripController tripController = Get.find<TripController>();
  final MobileScannerController scannerController = MobileScannerController();

  final authToken = RxnString();
  var isLoading = true.obs;
  RxList<FriendModel> participants = RxList();
  RxBool isTokenLoading = false.obs;
  var scannedData = RxnString();
  var isTorchOn = false.obs;
  int? tripId;
  var referenceId = RxnString();

  @override
  void onInit() {
    super.onInit();
    final args = Get.arguments;
    if (args != null && args['tripId'] != null) {
      updateTripId(args['tripId']);
    }
  }

  @override
  void onClose() {
    scannerController.dispose();
    super.onClose();
  }

  /// Call this after QR scan or when arguments are passed
  void updateTripId(int id) {
    if (tripId != id) {
      tripId = id;
      fetchAndSetToken();
    }
  }

  Future<void> fetchAndSetToken() async {
    if (tripId == null) {
      print('[TripParticipantSelectorController] Trip ID not set yet, skipping token fetch.');
      return;
    }

    _setTokenLoading(true);
    try {
      final token = await TokenStorage.getToken();
      authToken.value = token;
      _setTokenLoading(false);

      if (_hasValidToken(token)) {
        print('[TripParticipantSelectorController] Token found, fetching participants...');
        await loadParticipants();
      } else {
        print('[TripParticipantSelectorController] No token, waiting for QR scan...');
      }
    } catch (e) {
      _handleTokenError(e);
    }
  }

  void _setTokenLoading(bool isLoading) {
    isTokenLoading.value = isLoading;
  }

  bool _hasValidToken(String? token) {
    return token != null && token.isNotEmpty;
  }

  void _handleTokenError(dynamic error) {
    authToken.value = null;
    _setTokenLoading(false);
    print('[TripParticipantSelectorController] Error fetching token: $error');
    Get.snackbar('Error', 'Failed to fetch token: $error');
  }

  Future<void> loadParticipants() async {
    try {
      isLoading.value = true;
      final token = await TokenStorage.getToken();
      if (token == null) {
        Get.snackbar('Error', 'Authentication token not found');
        return;
      }

      final response = await http.get(
        Uri.parse('${ApiConstants.baseUrl}/participants/selection_list/${tripId}/'),
        headers: {
          'Authorization': 'Token $token',
          'Content-Type': 'application/json',
        },
      );

      if (response.statusCode == 200) {
        print('innnnnnnnnnnnnnnnnnnnnnnnnnnnnnnnnnnnnnnnnnn');
        final List<dynamic> data = jsonDecode(response.body);
        print('1');
        List<FriendModel>  ParticipantModelList = data.map((json) =>FriendModel.fromJson(json)).toList();
        participants.addAll(ParticipantModelList);
        print('2');
        print('[TripParticipantSelectorController] Participants loaded: ${participants.length}');
      } else {
        print('nooooooooooooooooooooooooooooooooooooooooooooooooo');
        final errorData = jsonDecode(response.body);
        print('[TripParticipantSelectorController] Failed to load participants: ${errorData["message"]} , ${response.statusCode}');
        Get.snackbar('Error', 'Failed to load participants: ${errorData['message'] ?? response.statusCode}');
      }
    } catch (e) {
      print('[TripParticipantSelectorController] Error loading participants: $e');
      Get.snackbar('Error', 'Error loading participants: $e');
    } finally {
      isLoading.value = false;
    }
  }

  Future<void> linkuserWithParticipant({
    required BuildContext context,
    ThemeData? theme,
    String? referenceId,
  }) async {
    try {
      isLoading.value = true;
      final token = await TokenStorage.getToken();
      if (token == null) {
        Get.snackbar('Error', 'Authentication token not found');
        return;
      }
      if (referenceId == null) {
        Get.snackbar('Error', 'Reference ID is required');
        return;
      }

      final response = await http.post(
        Uri.parse('${ApiConstants.baseUrl}/api/trips/${tripId}/link-participant/'),
        headers: {
          'Authorization': 'Token $token',
          'Content-Type': 'application/json',
        },
        body: jsonEncode({'reference_id': referenceId}),
      );

      if (response.statusCode == 200) {
        Get.snackbar('Success', 'Participant linked successfully');
        await loadParticipants();
        Get.offAndToNamed(PageConstant.tripDetailScreen, arguments: {
          'tripId': tripId.toString(),
        });
      } else {
        final errorData = jsonDecode(response.body);
        print('[TripParticipantSelectorController] Failed to link participant: ${errorData["message"]} , ${response.statusCode}');
        Get.snackbar('Error', 'Failed to link participant: ${errorData['message'] ?? response.statusCode}');
      }
    } catch (e) {
      Get.snackbar('Error', 'Error linking participant: $e');
    } finally {
      isLoading.value = false;
    }
  }

  void handleQRScan(BarcodeCapture capture, BuildContext context, ThemeData theme) {
    final List<Barcode> barcodes = capture.barcodes;
    for (final barcode in barcodes) {
      final scannedValue = barcode.rawValue;
      if (scannedValue != null) {
        scannedData.value = scannedValue;
        debugPrint('QR Code found: $scannedValue');

        final parts = scannedValue.split(':');
        if (parts.length == 2) {
          final scannedTripId = int.tryParse(parts[0]);
          final refId = parts[1];
          if (scannedTripId != null) {
            scannerController.stop();
            updateTripId(scannedTripId);
            referenceId.value = refId;
            linkuserWithParticipant(context: context, theme: theme, referenceId: refId);
          }
        }
      }
    }
  }

  void toggleTorch() {
    if (!kIsWeb) {
      scannerController.toggleTorch();
      isTorchOn.value = !isTorchOn.value;
    } else {
      debugPrint('Torch unavailable on web platform');
    }
  }

  Future<void> generateAndShowQR(BuildContext context) async {
    try {
      Get.to(() => GenerateQRPage( tripId: tripId!));
    } catch (e) {
      Get.snackbar('Error', 'Failed to generate QR code: $e');
    }
  }


}
