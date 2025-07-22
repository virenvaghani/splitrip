import 'dart:convert';
import 'package:flutter/Material.dart';
import 'package:http/http.dart' as http;
import 'package:get/get.dart';
import 'package:splitrip/controller/trip/trip_controller.dart';

import '../../data/constants.dart';
import '../../data/token.dart';
import '../../model/friend/friend_model.dart';
import '../../model/friend/participant_model.dart';

class TripParticipantSelectorController extends GetxController {
  final int tripId;
  TripParticipantSelectorController(this.tripId);

  TripController tripController = Get.find<TripController>();

  final authToken = RxnString();

  var isLoading = true.obs;
  var participants = <FriendModel>[].obs;
  RxBool isTokenLoading = false.obs;
  @override
  void onInit() {
    super.onInit();
    loadParticipants();
  }

  Future<void> fetchAndSetToken() async {
    print('[TripScreenController] Fetching token...');
    isTokenLoading.value = true;

    try {
      final token = await TokenStorage.getToken();
      authToken.value = token;
      isTokenLoading.value = false;

      if (token != null && token.isNotEmpty) {
        print('[TripScreenController] Token found, fetching friends...');
        await loadParticipants();
      } else {
        print('[FriendController] No token, clearing friends list...');
              }
    } catch (e) {
      authToken.value = null;
      isTokenLoading.value = false;
      print('[FriendController] Error fetching token: $e');
    }
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
        Uri.parse('${ApiConstants.baseUrl}/participants/selection_list/$tripId/'),
        headers: {
          'Authorization': 'Token $token',
          'Content-Type': 'application/json',
        },
      );

      if (response.statusCode == 200) {
        final List<dynamic> data = jsonDecode(response.body);
        participants.value = data.map((json) {
          final participant = ParticipantModel.fromJson(json);
          return FriendModel(participant: participant);
        }).toList();
      } else {
        Get.snackbar('Error', 'Failed to fetch participants');
      }
    } catch (e) {
      Get.snackbar('Error', 'Error fetching participants');
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
        Uri.parse('${ApiConstants.baseUrl}/api/trips/$tripId/link-participant/'),
        headers: {
          'Authorization': 'Token $token',
          'Content-Type': 'application/json',
        },
        body: jsonEncode({'reference_id': referenceId}),
      );

      if (response.statusCode == 200) {
        Get.snackbar('Success', 'Participant linked successfully');
        Get.offAndToNamed(PageConstant.tripDetailScreen, arguments: {
          'tripId': tripId.toString(),
        });
      } else {
        final errorData = jsonDecode(response.body);
        print('error : failed to link  participant: ${errorData["message"]} , ${response.statusCode}');
        Get.snackbar('Error', 'Failed to link participant: ${errorData['message'] ?? response.statusCode}');

      }
    } catch (e) {
      Get.snackbar('Error', 'Error linking participant: $e');
    } finally {
      isLoading.value = false;
    }
  }


}
