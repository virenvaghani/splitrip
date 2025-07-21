import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:http/http.dart' as http;
import 'package:splitrip/controller/friend/friend_controller.dart';
import 'package:splitrip/data/authenticate_value.dart';
import 'package:splitrip/data/constants.dart';
import 'package:splitrip/data/token.dart';
import 'package:splitrip/model/friend/participant_model.dart';
import 'package:splitrip/model/trip/trip_model.dart';
import 'package:splitrip/model/friend/friend_model.dart';
import '../../model/friend/linkuser_model.dart';
import 'emoji_controller.dart';

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
  final RxString selectedCurrencyCode = "INR".obs; // Store currency code
  final RxList<Map<String, dynamic>> availableCurrencies = RxList(); // Store currency data

  final RxString validationMsgForSelectFriend = "".obs;
  final RxBool isVisibleAddFriendForm = false.obs;
  Trip? tripModel;
  final RxList<Trip> tripModelList = RxList();
  final formKey = GlobalKey<FormState>();
  final addParticipantFormKey = GlobalKey<FormState>();
  RxBool isTripScreenLoading = false.obs;

  final RxList<FriendModel> availableParticipantModel = RxList();
  final RxList<ParticipantModel> selectedParticipantModel = RxList();
  final RxList<Trip> archivedTripList = RxList();
  final isTokenLoading = true.obs;

  final searchText = ''.obs;
  final authToken = RxnString();

  @override
  void onClose() {
    tripNameController.dispose();
    newParticipantNameController.dispose();
    newParticipantMembersController.dispose();
    super.onClose();
  }

  Future<List<String>> fetchValidParticipantIds() async {
    final token = await TokenStorage.getToken();

    if (token == null) {
      print("Invalid or missing token");
      return [];
    }

    final Uri url = Uri.parse('${ApiConstants.baseUrl}/trip/maintain/');
    try {
      final response = await http.get(url, headers: {
        'Content-Type': 'application/json',
        'Authorization': 'Token $token',
      });

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        final availableParticipants = data["available_participants"] as List;
        // Store currencies
        availableCurrencies.value = List<Map<String, dynamic>>.from(data["currency"]);
        return availableParticipants
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

      // Map selected participants
      final List<ParticipantModel> selectedList = (data["selected_participants"] as List)
          .map((e) => ParticipantModel(
        referenceId: e["participant_reference_id"],
        name: e["participant_name"],
        member: e["member"],
        customMemberCount: e["custom_member_count"],
        linkedUsers: [],
      ))
          .toList();

      // Map available participants
      final List<FriendModel> availableList = (data["available_participants"] as List)
          .map((e) => FriendModel.fromJson({
        ...e,
        "participant": e,
        "isSelected": false,
      }))
          .where((friend) => !selectedList.any(
            (selected) => selected.referenceId == friend.participant.referenceId,
      ))
          .toList();

      // Store currencies
      availableCurrencies.value = List<Map<String, dynamic>>.from(data["currency"]);

      if (isEdit) {
        final trip = data["trip"];
        if (trip["is_deleted"] == true || trip["is_archive"] == true) {
          isMantainTripLoading.value = false;
          showSnackBar(Get.context!, Get.theme, "Trip is deleted or archived");
          return;
        }

        tripNameController.text = trip["trip_name"] ?? "";
        // Set currency code from database, default to INR if null
        selectedCurrencyCode.value = trip["trip_currency"]?.toString() ?? "INR";
        emojiController.selectedEmoji.value =
            emojiController.getEmojiDataByString(trip["trip_emoji"]) ?? emojiController.getDefaultEmoji();
      } else {
        tripNameController.clear();
        selectedCurrencyCode.value = "INR";
        emojiController.selectedEmoji.value = emojiController.getRandomEmoji();

        final userIdString = await AuthStatusStorage.getUserId();
        final parsedUserId = int.tryParse(userIdString ?? "");
        print("🔍 Parsed User ID: $parsedUserId");

        if (parsedUserId != null) {
          final friendController = Get.find<FriendController>();

          final List<FriendModel> matchingFriends = friendController.friendsList.where((friend) {
            return friend.participant.participatedTrips!.any((trip) {
              return trip.linkedUsers!.any((user) => user.id.toString() == parsedUserId.toString());
            });
          }).toList();


          print("✅ Matching Friends For Create Only:");
          for (var f in matchingFriends) {
            print("Friend Ref ID: ${f.participant.referenceId}");
          }

          for (var match in matchingFriends) {
            final existsInAvailable = availableList.any(
                    (f) => f.participant.referenceId == match.participant.referenceId);
            final alreadySelected = selectedList.any(
                    (p) => p.referenceId == match.participant.referenceId);

            if (existsInAvailable && !alreadySelected) {
              selectedList.add(match.participant);
              availableList.removeWhere(
                      (f) => f.participant.referenceId == match.participant.referenceId);
              print("➡️ Moved ${match.participant.referenceId} to selected.");
            }
          }
        }
      }

      availableParticipantModel.value = availableList;
      selectedParticipantModel.value = selectedList;
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

    if (token == null) {
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

      if (isSaving) {
        final String body = jsonEncode(tripData);
        print("Sending ${isCreate ? 'POST' : 'PUT'} to $url with body: $body");

        response = isCreate
            ? await http.post(url, headers: headers, body: body)
            : await http.put(url, headers: headers, body: body);
      } else {
        response = await http.get(url, headers: headers);
      }

      if (response.statusCode == 200 || response.statusCode == 201) {
        print("Trip ${isSaving ? (isCreate ? 'created' : 'updated') : 'fetched'} successfully");
        final data = jsonDecode(response.body);
        return data;
      } else {
        showSnackBar(Get.context!, Get.theme, "Server error: ${response.statusCode} - ${response.body}");
        return null;
      }
    } catch (e) {
      print("Exception during trip ${isSaving ? 'save' : 'fetch'}: $e");
      showSnackBar(Get.context!, Get.theme, "Network error occurred");
      return null;
    }
  }

  Future<void> saveTrip({required Map<String, dynamic> argumentData}) async {
    if (formKey.currentState?.validate() ?? false) {
      isMantainTripLoading.value = true;

      final participantMaps = selectedParticipantModel.map((p) => {
        "participant_reference_id": p.referenceId,
        "custom_member_count": p.customMemberCount ?? p.member ?? 1,
      }).toList();

      if (participantMaps.isEmpty ||
          tripNameController.text.trim().isEmpty ||
          selectedCurrencyCode.value.isEmpty ||
          emojiController.selectedEmoji.value?.char == null) {
        showSnackBar(Get.context!, Get.theme, "Please provide valid trip details and participants");
        isMantainTripLoading.value = false;
        return;
      }

      final tripData = {
        'trip_name': tripNameController.text.trim(),
        'trip_currency': selectedCurrencyCode.value, // Use currency code
        'trip_emoji': emojiController.selectedEmoji.value?.char ?? '🧳',
        'participants': participantMaps,
      };

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
    final selectedFriends = availableParticipantModel.where((friend) => friend.isSelected).toList();

    if (selectedFriends.isEmpty) {
      validationMsgForSelectFriend.value = "Please select at least one friend";
      showSnackBar(context, theme, "Please select at least one friend");
      return;
    }

    for (var friend in selectedFriends) {
      final participant = friend.participant;

      final alreadyExists = selectedParticipantModel.any(
              (p) => p.referenceId == participant.referenceId);

      if (!alreadyExists) {
        selectedParticipantModel.add(participant);
      }

      availableParticipantModel.remove(friend);
    }

    selectedParticipantModel.refresh();
    availableParticipantModel.refresh();

    showSnackBar(context, theme, "Participants added successfully");
    Get.back();
  }

  Future<void> addNewParticipant({
    required Map<String, dynamic> participantData, required BuildContext context, required ThemeData theme,
  }) async {
    if (participantData['name'] == null || participantData['name'].toString().trim().isEmpty) {
      showSnackBar(Get.context!, Get.theme, "Participant name is required");
      isAddparticipantLoading.value = false;
      isFriendPageLoading.value = false;
      return;
    }
    if (participantData['member'] == null || int.tryParse(participantData['member'].toString())! <= 0) {
      showSnackBar(Get.context!, Get.theme, "Valid number of members is required");
      isAddparticipantLoading.value = false;
      isFriendPageLoading.value = false;
      return;
    }

    isAddparticipantLoading.value = true;
    isFriendPageLoading.value = true;

    final token = await TokenStorage.getToken();

    if (token == null) {
      print("Invalid or missing token");
      showSnackBar(Get.context!, Get.theme, "Please log in again");
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
        'member': int.tryParse(participantData['member'].toString()) ?? 1,
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
          linkedUsers: responseData['linked_users']?.map((u) => LinkedUserModel.fromJson(u)).toList() ?? [],
        );
        availableParticipantModel.add(FriendModel(participant: participant));
        availableParticipantModel.refresh();
        showSnackBar(Get.context!, Get.theme, "Participant added successfully");
      } else {
        print("Failed to add participant: ${response.statusCode} - ${response.body}");
        showSnackBar(Get.context!, Get.theme, "Failed to add participant: ${response.statusCode}");
      }
    } catch (e) {
      print("Exception during participant creation: $e");
      showSnackBar(Get.context!, Get.theme, "Error adding participant");
    }

    isAddparticipantLoading.value = false;
    isFriendPageLoading.value = false;
  }

  Future<void> removeFromParticipantList({
    required BuildContext context,
    required ThemeData theme,
    required String? participantReferenceId,
  }) async {
    if (participantReferenceId == null || participantReferenceId.isEmpty) {
      showSnackBar(context, theme, "Invalid participant ID");
      return;
    }

    final userIdString = await AuthStatusStorage.getUserId();
    final parsedUserId = int.tryParse(userIdString ?? "");
    print("🔍 Parsed User ID: $parsedUserId");

    if (parsedUserId == null) {
      showSnackBar(context, theme, "User not authenticated");
      return;
    }

    final friendController = Get.find<FriendController>();

    final isParticipantLinked = friendController.friendsList.any((friend) {
      return friend.participant.referenceId == participantReferenceId &&
          friend.participant.participatedTrips!.any((trip) {
            return trip.linkedUsers!.any((user) {
              return user.id.toString() == parsedUserId.toString();
            },);
          });
    });

    if (isParticipantLinked) {
      showSnackBar(context, theme, "Cannot remove a linked participant");
      return;
    }

    final index = selectedParticipantModel.indexWhere(
            (p) => p.referenceId == participantReferenceId);

    if (index != -1) {
      final removedParticipant = selectedParticipantModel.removeAt(index);

      availableParticipantModel.add(
        FriendModel(
          participant: removedParticipant,
          isSelected: false,
        ),
      );

      selectedParticipantModel.refresh();
      availableParticipantModel.refresh();

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
          style: TextStyle(
            color: theme?.snackBarTheme.contentTextStyle?.color ?? Colors.white,
          ),
        ),
      ),
    );
  }

  // Helper to get currency name from code
  String getCurrencyName(String code) {
    return availableCurrencies.firstWhere(
          (c) => c["code"] == code,
      orElse: () => {"name": "Indian Rupee"},
    )["name"];
  }
}