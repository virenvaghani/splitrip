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
import '../../model/currency/currency_model.dart';
import '../../model/friend/linkuser_model.dart';
import '../emoji_controller/emoji_controller.dart';
import '../splash_screen/splash_screen_controller.dart';

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
  final selectedCurrencyId = 0.obs;
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
  RxBool isParticipantLinked = false.obs;

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
        return availableParticipants.map((e) => e['participant_reference_id'].toString()).toList();
      } else {
        print("Failed to fetch valid participants: ${response.statusCode} - ${response.body}");
        return [];
      }
    } catch (e) {
      print("Exception fetching valid participants: $e");
      return [];
    }
  }

  double? _parseToDouble(dynamic value) {
    if (value == null) return null;
    if (value is num) return value.toDouble();
    if (value is String) return double.tryParse(value);
    return null;
  }

  Future<void> initStateMethodForMaintain({
    required Map<String, dynamic> argumentData,
  }) async {
    isMantainTripLoading.value = true;

    // Check if user is logged in
    final userIdString = await AuthStatusStorage.getUserId();
    if (userIdString == null || userIdString.isEmpty) {
      isMantainTripLoading.value = false;
      showSnackBar(Get.context!, Get.theme, "Please log in to continue");
      return;
    }
    final parsedUserId = int.tryParse(userIdString);
    if (parsedUserId == null) {
      isMantainTripLoading.value = false;
      showSnackBar(Get.context!, Get.theme, "Invalid user ID");
      return;
    }

    callFrom.value = argumentData["Call From"]?.toString() ?? "";
    int? tripId = int.tryParse(argumentData["trip_id"]?.toString() ?? "0");

    final data = await fetchOrSaveTripData(tripId: tripId);

    if (data != null) {
      final isEdit = data["trip"] != null;

      // Map selected participants with linked status
      final List<ParticipantModel> selectedList = (data["selected_participants"] as List).map((e) {
        final participantReferenceId = e["participant_reference_id"];
        // Determine if participant is linked
        final isParticipantLinked = Kconstant.friendModelList.any((friend) {
          if (friend.participant.referenceId != participantReferenceId) {
            return false;
          }
          final participatedTrips = friend.participant.participatedTrips;
          if (participatedTrips == null || participatedTrips.isEmpty) {
            return false;
          }
          return participatedTrips.any((trip) {
            if (trip.id.toString() != tripId.toString()) {
              return false;
            }
            final linkedUsers = trip.linkedUsers;
            if (linkedUsers == null || linkedUsers.isEmpty) {
              return false;
            }
            return linkedUsers.any((user) {
              return user.id.toString() == parsedUserId.toString();
            });
          });
        });

        return ParticipantModel(
          referenceId: e["participant_reference_id"],
          name: "${e["participant_name"]}",
          member: _parseToDouble(e["member"]),
          customMemberCount: _parseToDouble(e["custom_member_count"]),
          linkedUsers: [],
          isLinked: isParticipantLinked, // Add isLinked to ParticipantModel
        );
      }).toList();

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

      // Ensure currencies are loaded
      if (Kconstant.currencyModelList.isEmpty) {
        final SplashScreenController splashScreenController = Get.find<SplashScreenController>();
        await splashScreenController.getAllCurrency();
      }

      if (isEdit) {
        final trip = data["trip"];
        if (trip["is_deleted"] == true || trip["is_archive"] == true) {
          isMantainTripLoading.value = false;
          showSnackBar(Get.context!, Get.theme, "Trip is deleted or archived");
          return;
        }

        tripNameController.text = trip["trip_name"] ?? "";
        // Set currency ID from database, using ID directly
        final defaultCurrencyId = int.tryParse(trip["default_currency"]?.toString() ?? "15") ?? 15;
        final selectedCurrency = Kconstant.currencyModelList.firstWhere(
              (currency) => currency.id == defaultCurrencyId,
          orElse: () => CurrencyModel(
            id: 15,
            code: 'INR',
            name: 'Indian Rupee',
            symbol: '₹',
          ),
        );
        selectedCurrencyId.value = selectedCurrency.id;
        emojiController.selectedEmoji.value =
            emojiController.getEmojiDataByString(trip["trip_emoji"]) ?? emojiController.getDefaultEmoji();
      } else {
        tripNameController.clear();
        selectedCurrencyId.value = 15; // Default to INR
        emojiController.selectedEmoji.value = emojiController.getRandomEmoji();

        print("🔍 Parsed User ID: $parsedUserId");

        if (parsedUserId != null) {
          final friendController = Get.find<FriendController>();
          final List<FriendModel> matchingFriends = friendController.friendsList.where((friend) {
            return friend.participant.participatedTrips?.any((trip) {
              return trip.linkedUsers?.any((user) => user.id.toString() == parsedUserId.toString()) ?? false;
            }) ?? false;
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
              selectedList.add(ParticipantModel(
                referenceId: match.participant.referenceId,
                name: match.participant.name,
                member: match.participant.member ?? 1.0,
                customMemberCount: match.participant.customMemberCount,
                linkedUsers: [],
                isLinked: true, // Mark as linked for matching friends
              ));
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

      // Find the selected currency using selectedCurrencyId
      final selectedCurrency = Kconstant.currencyModelList.firstWhere(
            (currency) => currency.id == selectedCurrencyId.value,
        orElse: () => CurrencyModel(
          id: 15,
          code: 'INR',
          name: 'Indian Rupee',
          symbol: '₹',
        ),
      );

      if (participantMaps.isEmpty ||
          tripNameController.text.trim().isEmpty ||
          selectedCurrencyId.value == 0 ||
          emojiController.selectedEmoji.value?.char == null) {
        showSnackBar(Get.context!, Get.theme, "Please provide valid trip details and participants");
        isMantainTripLoading.value = false;
        return;
      }

      final tripData = {
        'trip_name': tripNameController.text.trim(),
        'default_currency': selectedCurrency.id, // Send currency ID to backend
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
    required Map<String, dynamic> argumentData,
  }) async {
    if (participantReferenceId == null || participantReferenceId.isEmpty) {
      showSnackBar(context, theme, "Invalid participant ID");
      return;
    }

    final userIdString = await AuthStatusStorage.getUserId();
    final parsedUserId = int.tryParse(userIdString ?? "");
    print("🔍 Parsed User ID: $parsedUserId");

    if (parsedUserId == null) {
      if (context.mounted) {
        showSnackBar(context, theme, "User not authenticated");
        return;
      }
    }
    callFrom.value = argumentData["Call From"]?.toString() ?? "";
    int? tripId = int.tryParse(argumentData["trip_id"]?.toString() ?? "0");


    isParticipantLinked.value = Kconstant.friendModelList.any((friend) {
      print('Checking friend: ${friend.participant.referenceId}');
      if (friend.participant.referenceId != participantReferenceId) {
        return false;
      }

      final participatedTrips = friend.participant.participatedTrips;
      if (participatedTrips == null || participatedTrips.isEmpty) {
        print('No participated trips for friend: ${friend.participant.referenceId}');
        return false;
      }

      return participatedTrips.any((trip) {
        print('Checking trip: ${trip.id} against tripId: $tripId');
        if (trip.id.toString() != tripId.toString()) {
          return false;
        }

        final linkedUsers = trip.linkedUsers;
        if (linkedUsers == null || linkedUsers.isEmpty) {
          print('No linked users for trip: ${trip.id}');
          return false;
        }

        return linkedUsers.any((user) {
          print('Checking user: ${user.id} against parsedUserId: $parsedUserId');
          return user.id.toString() == parsedUserId.toString();
        });
      });
    });

    if (isParticipantLinked.value) {

      if (context.mounted) {
        showSnackBar(context, theme, "Cannot remove a linked participant");
        return;
      }
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

      if (context.mounted) {
        showSnackBar(context, theme, "Participant removed successfully");
        return;
      }
    } else {
      if (context.mounted) {
        showSnackBar(context, theme, "Participant not found");
        return;
      }
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

  // Helper to get currency name from ID
  String getCurrencyName(int id) {
    return Kconstant.currencyModelList.firstWhere(
          (currency) => currency.id == id,
      orElse: () => CurrencyModel(id: 15, code: 'INR', name: 'Indian Rupee', symbol: '₹'),
    ).name;
  }}