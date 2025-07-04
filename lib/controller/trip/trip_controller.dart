import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';
import 'package:splitrip/data/constants.dart';
import 'package:splitrip/data/token.dart';
import 'package:splitrip/model/trip/participant_model.dart';
import 'package:splitrip/model/trip/trip_model.dart';
import 'package:splitrip/model/friend/friend_model.dart';
import '../emoji_controller.dart';

class TripController extends GetxController {
  RxBool isFriendPageLoading = false.obs;
  RxBool isAuthenticated = false.obs;
  RxBool isMantainTripLoading = true.obs;
  RxBool isAddparticipantLoading = false.obs;
  final RxString callFrom = "".obs;
  final EmojiController emojiController = Get.put(EmojiController());
  final TextEditingController tripNameController = TextEditingController();
  final TextEditingController newParticipantNameController = TextEditingController();
  final TextEditingController newParticipantMembersController = TextEditingController();
  final RxString selectedCurrency = "INR".obs;
  final RxList<ParticipantModel> participantModelList = RxList();
  final RxList<FriendModel> selectedfriendModelList = RxList();
  final RxString validationMsgForSelectFriend = "".obs;
  final RxBool isVisibleAddFriendForm = false.obs;
  Trip? tripModel;
  final RxList<Trip> tripModelList = RxList();
  final formKey = GlobalKey<FormState>();
  final addParticipantFormKey = GlobalKey<FormState>();
  RxBool isTripScreenLoading = false.obs;
  @override
  void onClose() {
    tripNameController.dispose();
    newParticipantNameController.dispose();
    newParticipantMembersController.dispose();
    super.onClose();
  }

  // Helper to get current user's participant ID
  Future<String?> getCurrentUserParticipantId() async {

    final token = await TokenStorage.getToken();

    if (token == Null) {
      print("Invalid or missing token");
      showSnackBar(Get.context!, Get.theme, "Please log in again");
      return null;
    }

    final Uri url = Uri.parse('${ApiConstants.baseUrl}/trip/maintain/');
    final headers = {
      'Content-Type': 'application/json',
      'Authorization': 'Token $token',
    };

    try {
      final response = await http.get(url, headers: headers);
      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        final availableParticipants = data["available_participants"] as List;
        // Assuming the current user is identified by a field like 'is_current_user' or 'user'
        final currentUserParticipant = availableParticipants.firstWhere(
              (participant) => participant['user'] != null, // Adjust based on API response
          orElse: () => null,
        );
        return currentUserParticipant?['reference_id'] as String?;
      } else {
        print("Failed to fetch participants: ${response.statusCode} - ${response.body}");
        return null;
      }
    } catch (e) {
      print("Exception fetching participants: $e");
      return null;
    }
  }

  Future<List<String>> fetchValidParticipantIds() async {

    final token = await TokenStorage.getToken();

    if (token == Null) {
      print("Invalid or missing token");
      return [];
    }

    final Uri url = Uri.parse('${ApiConstants.baseUrl}/participants/');
    try {
      final response = await http.get(
        url,
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Token $token',
        },
      );

      if (response.statusCode == 200) {
        final List<dynamic> participants = jsonDecode(response.body);
        return participants
            .map((p) => p['reference_id'] as String?)
            .where((id) => id != null && id.isNotEmpty)
            .cast<String>()
            .toList();
      } else {
        print("Failed to fetch valid participants: ${response.statusCode} - ${response.body}");
        return [];
      }
    } catch (e) {
      print("Exception fetching valid participants: $e");
      return [];
    }
  }

  Future<void> initStateMethodForMaintain({
    required Map<String, dynamic> argumentData,
  }) async {
    isMantainTripLoading.value = true;

    callFrom.value = argumentData["Call From"]?.toString() ?? "";
    int? tripId = int.tryParse(argumentData["trip_id"]?.toString() ?? "0");

    final data = await fetchOrSaveTripData(tripId: tripId);

    if (data != null) {
      final isEdit = data["trip"] != null;

      if (isEdit) {
        final trip = data["trip"];
        tripNameController.text = trip["trip_name"] ?? "";
        selectedCurrency.value = trip["trip_currency"] ?? "INR";
        emojiController.selectedEmoji.value =
            emojiController.getEmojiDataByString(trip["trip_emoji"]) ??
                emojiController.getRandomEmoji();
      } else {
        tripNameController.clear();
        selectedCurrency.value = "INR";
        emojiController.selectedEmoji.value = emojiController.getRandomEmoji();
      }

      participantModelList.value = (data["selected_participants"] as List)
          .map((e) => ParticipantModel.fromJson(e))
          .toList();

      selectedfriendModelList.value = (data["available_participants"] as List)
          .map((e) => FriendModel.fromJson(e))
          .toList();
    } else {
      showSnackBar(Get.context!, Get.theme, "Failed to load trip data");
    }

    isMantainTripLoading.value = false;
  }

  Future<Map<String, dynamic>?> fetchOrSaveTripData({
    required int? tripId,
    Map<String, dynamic>? tripData,
  }) async {

    final token = await TokenStorage.getToken();

    if (token == Null) {
      print("Invalid or missing token");
      showSnackBar(Get.context!, Get.theme, "Please log in again");
      return null;
    }

    final bool isSaving = tripData != null;
    final bool isCreate = tripId == null;

    final Uri url = Uri.parse(
      isCreate
          ? '${ApiConstants.baseUrl}/trip/maintain/'
          : '${ApiConstants.baseUrl}/trip/maintain/$tripId/',
    );

    try {
      http.Response response;
      final headers = {
        'Content-Type': 'application/json',
        'Authorization': 'Token $token',
      };
      print("Headers: $headers");

      if (isSaving) {
        // Fetch current user's participant ID
        final currentUserParticipantId = await getCurrentUserParticipantId();
        if (currentUserParticipantId == null) {
          showSnackBar(Get.context!, Get.theme, "Failed to identify current user as participant");
          return null;
        }

        // Ensure participants field exists and add current user's participant ID
        tripData!['participants'] = tripData['participants'] ?? [];
        if (!tripData['participants'].contains(currentUserParticipantId)) {
          tripData['participants'].add(currentUserParticipantId);
        }

        final String body = jsonEncode(tripData);
        print("Sending POST/PUT to $url with body: $body");

        response = isCreate
            ? await http.post(url, headers: headers, body: body)
            : await http.put(url, headers: headers, body: body);
      } else {
        response = await http.get(url, headers: headers);
      }

      if (response.statusCode == 200 || response.statusCode == 201) {
        print("Trip ${isSaving ? (isCreate ? 'created' : 'updated') : 'fetched'} successfully");
        return jsonDecode(response.body);
      } else {
        print("Failed to ${isSaving ? (isCreate ? 'create' : 'update') : 'fetch'} trip: ${response.statusCode} - ${response.body}");
        showSnackBar(Get.context!, Get.theme, "Server error: ${response.statusCode}- ${response.body}");
        return null;
      }
    } catch (e) {
      print("Exception during trip ${isSaving ? 'save' : 'fetch'}: $e");
      showSnackBar(Get.context!, Get.theme, "Network error occurred");
      return null;
    }
  }

  // Updated saveTrip method
  Future<void> saveTrip({
    required Map<String, dynamic> argumentData,
  }) async {
    if (formKey.currentState?.validate() ?? false) {
      isMantainTripLoading.value = true;

      final participantRefIds = participantModelList
          .where((p) => p.referenceId != null && p.referenceId!.isNotEmpty)
          .map((p) => p.referenceId!)
          .toList();

      // Validate inputs
      if (emojiController.selectedEmoji.value?.char == null ||
          tripNameController.text.trim().isEmpty ||
          selectedCurrency.value.isEmpty ||
          participantRefIds.isEmpty) {
        showSnackBar(Get.context!, Get.theme, "Please provide valid trip details and participants");
        isMantainTripLoading.value = false;
        return;
      }

      // Fetch current user's participant ID and ensure it's included
      final currentUserParticipantId = await getCurrentUserParticipantId();
      if (currentUserParticipantId == null) {
        showSnackBar(Get.context!, Get.theme, "Failed to identify current user as participant");
        isMantainTripLoading.value = false;
        return;
      }

      if (!participantRefIds.contains(currentUserParticipantId)) {
        participantRefIds.add(currentUserParticipantId);
      }

      // Validate participant IDs against server
      final validServerIds = await fetchValidParticipantIds();
      final validParticipantIds = participantRefIds.where((id) => validServerIds.contains(id)).toList();

      if (validParticipantIds.isEmpty) {
        print("No valid participants selected. Participant refIds: $participantRefIds");
        print("Valid server participant IDs: $validServerIds");
        showSnackBar(Get.context!, Get.theme, "No valid participants selected or participants not found on server");
        isMantainTripLoading.value = false;
        return;
      }

      // Prepare trip data
      final tripData = {
        'trip_name': tripNameController.text.trim(),
        'trip_currency': selectedCurrency.value,
        'trip_emoji': emojiController.selectedEmoji.value?.char ?? '🧳',
        'participants': validParticipantIds,
      };

      // Save or update trip
      final tripId = int.tryParse(argumentData['trip_id']?.toString() ?? '');
      final response = await fetchOrSaveTripData(tripId: tripId, tripData: tripData);

      if (response != null) {
        showSnackBar(Get.context!, Get.theme, tripId != null ? "Trip updated successfully" : "Trip created successfully");
        Get.back(result: response);
        tripModelList.refresh();
      } else {
        showSnackBar(Get.context!, Get.theme, "Failed to ${tripId != null ? 'update' : 'create'} trip");
      }

      isMantainTripLoading.value = false;
    } else {
      showSnackBar(Get.context!, Get.theme, "Please fill in all required fields");
    }
  }

  Future<void> addParticipantMethod({
    required BuildContext context,
    required ThemeData theme,
  }) async {
    validationMsgForSelectFriend.value = "";

    final selectedFriends = selectedfriendModelList.where((friend) => friend.isSelected).toList();

    if (selectedFriends.isEmpty) {
      validationMsgForSelectFriend.value = "Please select at least one friend";
      showSnackBar(context, theme, "Please select at least one friend");
      return;
    }

    bool participantAdded = false;

    for (var friend in selectedFriends) {
      if (friend.participant.referenceId == null || friend.participant.referenceId!.isEmpty) {
        print("Invalid participant data for ${friend.participant.name}: referenceId is null or empty");
        showSnackBar(context, theme, "Invalid participant data for ${friend.participant.name}");
        continue;
      }

      final alreadyExists = participantModelList.any(
            (p) => p.referenceId == friend.participant.referenceId,
      );

      if (!alreadyExists) {
        final participant = ParticipantModel(
          id: friend.participant.id,
          name: friend.participant.name,
          member: friend.participant.member,
          referenceId: friend.participant.referenceId,
          user: friend.participant.user,
        );
        participantModelList.add(participant);
        participantAdded = true;
        print("Added participant: ${participant.name} (referenceId: ${participant.referenceId})");
      }
    }

    if (!participantAdded && selectedFriends.isNotEmpty) {
      showSnackBar(context, theme, "Selected friends are already added");
    }

    participantModelList.refresh();
    for (var friend in selectedfriendModelList) {
      friend.isSelected = false;
    }
    selectedfriendModelList.refresh();

    if (participantAdded) {
      showSnackBar(context, theme, "Participants added successfully");
      Get.back();
    }
  }

  Future<void> addNewParticipant({
    required BuildContext context,
    required ThemeData theme,
    required Map<String, dynamic> participantData,
  }) async {
    if (participantData['name'] == null || participantData['name'].toString().trim().isEmpty) {
      showSnackBar(context, theme, "Participant name is required");
      isAddparticipantLoading.value = false;
      isFriendPageLoading.value = false;
      return;
    }
    if (participantData['member'] == null || participantData['member'] <= 0) {
      showSnackBar(context, theme, "Valid number of members is required");
      isAddparticipantLoading.value = false;
      isFriendPageLoading.value = false;
      return;
    }

    isAddparticipantLoading.value = true;
    isFriendPageLoading.value = true;


    final token = TokenStorage.getToken();

    if (token == Null) {
      print("Invalid or missing token");
      showSnackBar(context, theme, "Please log in again");
      isAddparticipantLoading.value = false;
      isFriendPageLoading.value = false;
      return;
    }

    final Uri url = Uri.parse('${ApiConstants.baseUrl}/participants/create/');

    try {
      final headers = {
        'Content-Type': 'application/json',
        'Authorization': 'Token $token',
      };
      final body = jsonEncode({
        'name': participantData['name'],
        'member': participantData['member'],
      });

      print("Sending POST to $url with body: $body");

      final response = await http.post(url, headers: headers, body: body);

      if (response.statusCode == 201) {
        final responseData = jsonDecode(response.body);
        final participant = ParticipantModel(
          id: responseData['id'],
          name: responseData['name'],
          member: responseData['member'],
          referenceId: responseData['reference_id'],
          user: responseData['user'],
        );
        selectedfriendModelList.add(FriendModel(participant: participant, isSelected: true));
        selectedfriendModelList.refresh();
        showSnackBar(context, theme, "Participant added successfully");
      } else {
        print("Failed to add participant: ${response.statusCode} - ${response.body}");
        showSnackBar(context, theme, "Failed to add participant: ${response.statusCode}");
      }
    } catch (e) {
      print("Exception during participant creation: $e");
      showSnackBar(context, theme, "Error adding participant");
    }

    isAddparticipantLoading.value = false;
    isFriendPageLoading.value = false;
  }

  void removeFromParticipantList({
    required BuildContext context,
    required ThemeData theme,
    required String? participantReferenceId,
  }) {
    if (participantReferenceId == null || participantReferenceId.isEmpty) {
      showSnackBar(context, theme, "Invalid participant ID");
      return;
    }

    final index = participantModelList.indexWhere((p) => p.referenceId == participantReferenceId);
    if (index != -1) {
      participantModelList.removeAt(index);
      participantModelList.refresh();
      showSnackBar(context, theme, "Participant removed successfully");
    } else {
      showSnackBar(context, theme, "Participant not found");
    }
  }

  void showSnackBar(BuildContext context, ThemeData? theme, String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        behavior: SnackBarBehavior.floating,
        backgroundColor: theme?.snackBarTheme.backgroundColor ?? Colors.grey[800],
        content: Text(
          message,
          style: TextStyle(color: theme?.snackBarTheme.contentTextStyle?.color ?? Colors.white),
        ),
      ),
    );
  }

  Future<void> iniStateMethodForTripScreen({
    required BuildContext context,
  }) async {
    isTripScreenLoading.value = true;
    try {

      final token = await TokenStorage.getToken();

      if (token == Null) {
        Get.snackbar("Error", "Authentication token is missing.");
        return;
      }

      final response = await http.get(
        Uri.parse('${ApiConstants.baseUrl}/trips/'),
        headers: {
          'Authorization': 'Token $token',
          'Content-Type': 'application/json',
        },
      );

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        final tripsData = data['trips'] as List;
        tripModelList.value = tripsData.map((json) => Trip.fromJson(json)).toList();
      } else {
        Get.snackbar("Error", "Failed to fetch trips: ${response.statusCode}");
      }
    } catch (e) {
      Get.snackbar("Error", "Something went wrong: $e");
    } finally {
      isTripScreenLoading.value = false;
    }
  }

  Future<void> addToArchive(Trip trip) async {
    try {
      final token = await TokenStorage.getToken();
      if (token == null) {
        throw Exception('Authentication token not found');
      }

      final response = await http.put(
        Uri.parse('${ApiConstants.baseUrl}/trips/${trip.id}/archive/'),
        headers: {
          'Authorization': 'Token $token',
          'Content-Type': 'application/json',
        },
      );

      if (response.statusCode == 200 || response.statusCode == 201) {
        tripModelList.refresh();
      } else {
        throw Exception('Failed to archive trip: ${response.statusCode}');
      }
    } catch (e) {
      throw Exception('Error archiving trip: $e');
    }
  }
}