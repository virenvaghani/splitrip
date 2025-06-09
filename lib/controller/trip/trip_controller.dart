import 'package:flutter/Material.dart';
import 'package:flutter/foundation.dart';
import 'package:get/get.dart';
import 'package:splitrip/model/trip/participant_model.dart';
import 'package:splitrip/model/trip/trip_model.dart';

import '../../model/friend/friend_model.dart';
import '../../views/trip/maintain_trip_screen_.dart';
import '../emoji_controller.dart';

class TripController extends GetxController {
  //Maintain trip screen parameter
  final RxString callFrom = "".obs;
  final EmojiController emojiController = Get.put(EmojiController());
  final TextEditingController tripNameController = TextEditingController();
  final TextEditingController tripMemberController = TextEditingController();
  final TextEditingController friendNameController = TextEditingController();
  RxString selectedCurrency = "".obs;
  RxString selectedParticipant = "".obs;
  RxList<ParticipantModel> participantModelList = RxList();
  RxList<FriendModel> friendModelList = RxList();
  RxString validationMsgForSelectFriend = "".obs;
  RxBool isVisibleAddFriendForm = false.obs;

  // tripscreen
  RxList<TripModel> tripModelList = RxList();

  final formKey = GlobalKey<FormState>();
  final addParticipantFormKey = GlobalKey<FormState>();

  final TextEditingController newParticipantNameController =
      TextEditingController();
  final TextEditingController newParticipantMembersController =
      TextEditingController();

  // Reactive variables to track field states
  final RxBool isNameValid = false.obs;
  final RxBool isMembersValid = false.obs;

  void initStateMethodForMaintain({required argumentData}) {
    callFrom.value = argumentData["Call From"];
    if (callFrom.value == "Add") {
      validationMsgForSelectFriend.value = "";
      isVisibleAddFriendForm.value = false;
      tripNameController.clear();
      tripMemberController.clear();
      selectedCurrency.value = "INR";
      selectedParticipant.value = "Select Participant";
      participantModelList.clear();
      participantModelList.add(
        ParticipantModel(name: "Viren", memberCount: 2, isCurrentUser: true),
      );
      friendModelList.clear();
      friendModelList.add(
        FriendModel(name: "Viren", memberCount: 2, isSelected: false),
      );
      friendModelList.add(
        FriendModel(name: "Jaydip", memberCount: 2, isSelected: false),
      );
      friendModelList.add(
        FriendModel( name: "Arjun", memberCount: 2, isSelected: false),
      );
      friendModelList.add(
        FriendModel(name: "Jignesh", memberCount: 2, isSelected: false),
      );
      friendModelList.add(
        FriendModel(name: "Ayush", memberCount: 2, isSelected: false),
      );
      if (kDebugMode) {
        print("participant count ${participantModelList.length}");
      }
    }
  }

  void addParticipantMethod({
    required BuildContext context,
    required ThemeData theme,
  }) {
    if (friendModelList.where((p0) => p0.isSelected == true).toList().isEmpty) {
      validationMsgForSelectFriend.value = "Please select at least one friend";
    } else {
      friendModelList.where((p0) => p0.isSelected == true).toList().forEach((
        element,
      ) {
        ParticipantModel participantModel = ParticipantModel(
          id: element.id,
          name: element.name,
          memberCount: element.memberCount,
        );
        participantModelList.add(participantModel);
      });
      participantModelList.refresh();
      if (kDebugMode) {
        print("participant count ${participantModelList.length}");
      }
      Get.back();
    }
  }

  void addTripMethod({
    required BuildContext context,
    required ThemeData theme,
  }) {
    if (tripNameController.text.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          behavior: SnackBarBehavior.floating,
          backgroundColor: theme.snackBarTheme.actionTextColor,
          content: Text("Please Enter Name"),
        ),
      );
    } else if (selectedCurrency.value.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          behavior: SnackBarBehavior.floating,
          backgroundColor: theme.snackBarTheme.actionTextColor,
          content: Text("Please Select Currency"),
        ),
      );
    } else if (participantModelList.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          behavior: SnackBarBehavior.floating,
          backgroundColor: theme.snackBarTheme.actionTextColor,
          content: Text("Select Participant"),
        ),
      );
    } else {
      TripModel tripModel = TripModel(
        id: tripModelList.length,
        tripName: tripNameController.text,
        currency: selectedCurrency.value,
        tripEmoji: emojiController.selectedEmoji.value?.char,
        participantModelList: participantModelList,
      );
      tripModelList.add(tripModel);
      tripModelList.refresh();
      Get.back();
    }

    if (kDebugMode) {
      print("trip count ${tripModelList.length}");
    }
  }


  void removeFromParticipantList({
    required BuildContext context,
    required ThemeData theme,
    int? participant_id,
  }) {


    participantModelList.removeWhere((p) => p.id == participant_id);

    final friend = friendModelList.firstWhere(
          (f) => f.id == participant_id,
      orElse: () => FriendModel(id: participant_id, isSelected: false),
    );
  }

  void iniStateMethodForList() {}
}
