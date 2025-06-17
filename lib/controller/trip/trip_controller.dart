import 'dart:convert';
import 'package:emoji_selector/src/emoji_data.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:splitrip/api/api.dart';
import 'package:splitrip/model/trip/participant_model.dart';
import 'package:splitrip/model/trip/trip_model.dart';
import '../../data/token.dart';
import '../../model/friend/friend_model.dart';
import '../emoji_controller.dart';
import 'package:http/http.dart' as http;

class TripController extends GetxController {
  // Maintain trip screen parameters
  final RxString callFrom = "".obs;
  final EmojiController emojiController = Get.put(EmojiController());
  final TextEditingController tripNameController = TextEditingController();
  final TextEditingController tripMemberController = TextEditingController();
  final TextEditingController friendNameController = TextEditingController();
  final RxString selectedCurrency = "".obs;
  final RxString selectedParticipant = "".obs;
  final RxList<ParticipantModel> participantModelList = RxList();
  final RxList<FriendModel> friendModelList = RxList();
  final RxString validationMsgForSelectFriend = "".obs;
  final RxBool isVisibleAddFriendForm = false.obs;

  // Trip screen
  final RxList<Trip> tripModelList = RxList();

  final formKey = GlobalKey<FormState>();
  final addParticipantFormKey = GlobalKey<FormState>();

  final TextEditingController newParticipantNameController =
      TextEditingController();
  final TextEditingController newParticipantMembersController =
      TextEditingController();

  @override
  void onClose() {
    // Dispose of TextEditingControllers to prevent memory leaks
    tripNameController.dispose();
    tripMemberController.dispose();
    friendNameController.dispose();
    newParticipantNameController.dispose();
    newParticipantMembersController.dispose();
    super.onClose();
  }

  void initStateMethodForMaintain({
    required Map<String, dynamic> argumentData,
  }) async {
    callFrom.value = argumentData["Call From"] ?? "";
    int? tripId = argumentData["trip_id"]; // could be null
    selectedCurrency.value = "INR";

    final response = await ApiService.fetchTripInitData(tripId: tripId);

    if (response != null) {
      // === Existing Trip ===
      if (response["trip"] != null) {
        final trip = response["trip"];
        tripNameController.text = trip["trip_name"] ?? "";
        selectedCurrency.value = trip["trip_currency"] ?? "INR";

        // Set emoji using getEmojiDataByString
        emojiController.selectedEmoji.value =
            emojiController.getEmojiDataByString(trip["trip_emoji"]) ??
            emojiController.getEmojiDataByString(
              '🧳',
            ); // Fallback to luggage emoji
      } else {
        // === New Trip ===
        tripNameController.clear();
        selectedCurrency.value = "INR";
        emojiController.selectedEmoji.value = emojiController
            .getEmojiDataByString('🧳'); // Default to luggage emoji
      }

      // Selected participants for this trip
      participantModelList.clear();
      for (var p in response["selected_participants"]) {
        participantModelList.add(ParticipantModel.fromJson(p));
      }

      // Available (reusable) participants to choose from
      friendModelList.clear();
      for (var p in response["available_participants"]) {
        friendModelList.add(FriendModel.fromJson(p));
      }

      print(
        "InitState loaded for ${tripId != null ? "editing" : "creating"} trip",
      );
    } else {
      showSnackBar(
        Get.context!,
        Theme.of(Get.context!),
        "Failed to load trip data",
      );
    }
  }

  void showSnackBar(BuildContext context, ThemeData theme, String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        behavior: SnackBarBehavior.floating,
        backgroundColor: theme.snackBarTheme.actionTextColor,
        content: Text(message),
      ),
    );
  }

  Future<void> loadTripInitData({int? tripId}) async {
    final data = await ApiService.fetchTripInitData(tripId: tripId);

    if (data != null) {
      // If editing a trip, populate fields
      if (data["trip"] != null) {
        final trip = Trip.fromJson(data["trip"]);
        tripNameController.text = trip.tripName ?? '';
        selectedCurrency.value = trip.tripCurrency ?? 'INR';
        selectedParticipant.value = 'Select Participant';

        // Convert tripEmoji string to EmojiData
        emojiController.selectedEmoji.value =
            emojiController.getEmojiDataByString(trip.tripEmoji) ??
            emojiController.getEmojiDataByString(
              '🧳',
            ); // Fallback to luggage emoji

        // Map selected participants
        participantModelList.value =
            (data["selected_participants"] as List)
                .map((e) => ParticipantModel.fromJson(e))
                .toList();
      } else {
        // === New Trip ===
        tripNameController.clear();
        selectedCurrency.value = 'INR';
        selectedParticipant.value = 'Select Participant';
        emojiController.selectedEmoji.value = emojiController
            .getEmojiDataByString('🧳'); // Default to luggage emoji
      }

      // Load available participants for selection
      friendModelList.value =
          (data["available_participants"] as List)
              .map((e) => FriendModel.fromJson(e))
              .toList();
    } else {
      showSnackBar(Get.context!, Get.theme, "Failed to load trip data");
    }
  }
}
