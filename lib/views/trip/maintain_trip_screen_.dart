import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';
import 'package:dropdown_button2/dropdown_button2.dart';
import 'package:splitrip/controller/trip/trip_controller.dart';
import 'package:splitrip/model/friend/friend_model.dart';
import 'package:splitrip/model/trip/trip_model.dart';
import 'package:splitrip/widgets/myappbar.dart';
import '../../../widgets/emoji_selector.dart';
import '../../controller/theme_controller.dart';
import '../../controller/trip/trip_controller.dart';
import '../../widgets/my_textfield.dart';



class MaintainTripScreen extends StatelessWidget {
  MaintainTripScreen({super.key});

  final TripController tripController = Get.put(TripController());
  final argumentData = Get.arguments;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return GetX<TripController>(
      initState: (state) {
        tripController.initStateMethodForMaintain(argumentData: argumentData);
      },
      builder: (_) {
        return Scaffold(
          appBar: CustomAppBar(title: "New Trip"),
          body: bodyWidget(context: context, theme: theme),
          bottomNavigationBar: bottomNavigationBarWidget(
            context: context,
            theme: theme,
          ),
        );
      },
    );
  }

  Widget bodyWidget({required BuildContext context, required ThemeData theme}) {
    return GestureDetector(
      behavior: HitTestBehavior.opaque,
      onPanDown: (_) {
        FocusScope.of(context).requestFocus(FocusNode());
      },
      child: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 15, vertical: 15),
          child: Form(
            key: tripController.formKey,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Text(tripController.isMembersValid.value.toString()),
                emojiSelectAndTitleWidget(context: context, theme: theme),
                const SizedBox(height: 15.0),
                currencyWidget(context: context, theme: theme),
                const SizedBox(height: 15),
                selectParticipantWidget(context: context, theme: theme),
                const SizedBox(height: 15),
                participantTable(context: context, theme: theme),
                const SizedBox(height: 8),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget bottomNavigationBarWidget({
    required BuildContext context,
    required ThemeData theme,
  }) {
    return BottomAppBar(
      child: Container(
        width:
            double.infinity, // Ensures the Container matches the button's width
        decoration: BoxDecoration(
          gradient: LinearGradient(
            colors: [theme.colorScheme.primary, theme.colorScheme.secondary],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
          borderRadius: BorderRadius.circular(12),
          boxShadow: [
            BoxShadow(
              color: theme.colorScheme.primary.withOpacity(0.3),
              blurRadius: 8,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        padding: EdgeInsets.symmetric(vertical: 16), // Adjust padding as needed
        child: ElevatedButton(
          style: ElevatedButton.styleFrom(
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12),
            ),
            backgroundColor:
                Colors
                    .transparent, // Set to transparent to allow gradient background
            shadowColor: Colors.transparent,
            splashFactory: NoSplash.splashFactory,
            elevation: 0,
          ),
          onPressed: () {
            tripController.addTripMethod(context: context, theme: theme);
          },
          child: Center(
            child: Text(
              'Create Trip',
              style: theme.textTheme.labelLarge?.copyWith(
                color: theme.colorScheme.onPrimary,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget emojiSelectAndTitleWidget({
    required BuildContext context,
    required ThemeData theme,
  }) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.end,
      children: [
        GestureDetector(
          onTap: () {
            selectEmojiBottomsheetMethod(context: context);
          },
          child: Padding(
            padding: const EdgeInsets.only(bottom: 2.0),
            child: Stack(
              children: [
                CircleAvatar(
                  backgroundColor: theme.cardTheme.color,
                  radius: 25,
                  child: Text(
                    tripController.emojiController.selectedEmoji.value?.char ??
                        '😊',
                    style: const TextStyle(fontSize: 24),
                    semanticsLabel: 'Select trip emoji',
                  ),
                ),
                Positioned(
                  bottom: 0.0,
                  right: 0.0,
                  child: CircleAvatar(
                    radius: 8.0,
                    backgroundColor: darkTextColor,
                    child: Icon(
                      Icons.edit_outlined,
                      color: theme.primaryColor,
                      size: 10.0,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),

        Expanded(
          child: Padding(
            padding: const EdgeInsets.only(left: 10.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Padding(
                  padding: const EdgeInsets.only(left: 5.0),
                  child: Text('Title', style: theme.textTheme.titleMedium),
                ),
                CustomTextField(
                  hintText: 'Enter trip name',
                  controller: tripController.tripNameController,
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }

  Widget currencyWidget({
    required BuildContext context,
    required ThemeData theme,
  }) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.end,
      children: [
        Padding(
          padding: const EdgeInsets.only(bottom: 2.0),
          child: CircleAvatar(
            backgroundColor: theme.cardTheme.color,
            radius: 25,
            child: Icon(Icons.currency_rupee, color: theme.primaryColor),
          ),
        ),
        Expanded(
          child: Padding(
            padding: const EdgeInsets.only(left: 10.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Padding(
                  padding: const EdgeInsets.only(left: 5.0),
                  child: Text('Currency', style: theme.textTheme.titleMedium),
                ),
                DropdownButtonFormField2<String>(
                  iconStyleData: const IconStyleData(
                    icon: Padding(
                      padding: EdgeInsets.only(right: 10.0),
                      child: Icon(Icons.keyboard_arrow_down),
                    ),
                  ),
                  decoration: InputDecoration(
                    border: OutlineInputBorder(
                      borderSide: BorderSide(width: 2.0),
                      borderRadius: BorderRadius.circular(12.0),
                    ),
                    contentPadding: const EdgeInsets.symmetric(vertical: 15),
                  ),
                  hint: Text(
                    'Select currency',
                    style: theme.textTheme.bodyLarge?.copyWith(
                      color: theme.colorScheme.onSurface.withOpacity(0.6),
                    ),
                  ),
                  items:
                      ['INR', 'USD', 'EUR', 'GBP', 'JPY']
                          .map(
                            (currency) => DropdownMenuItem(
                              value: currency,
                              child: Text(
                                currency,
                                style: theme.textTheme.bodyLarge,
                              ),
                            ),
                          )
                          .toList(),
                  value: tripController.selectedCurrency.value,
                  onChanged: (value) {
                    tripController.selectedCurrency.value = value!;
                  },
                  validator: (value) {
                    if (value == null) {
                      return 'Please select a currency';
                    }
                    return null;
                  },
                  dropdownStyleData: DropdownStyleData(
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(12),
                      color: theme.cardTheme.color,
                    ),
                    elevation: 1,
                  ),
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }

  Widget selectParticipantWidget({
    required BuildContext context,
    required ThemeData theme,
  }) {
    return GestureDetector(
      onTap: () {
        selectParticipantsBottomSheetMethod(context: context, theme: theme);
      },
      child: Container(
        alignment: Alignment.center,
        decoration: BoxDecoration(
          gradient: LinearGradient(
            colors: [
              theme.colorScheme.primary.withValues(alpha: 0.1),
              theme.colorScheme.secondary.withValues(alpha: 0.1),
            ],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
          boxShadow: [
            BoxShadow(
              color: theme.colorScheme.onSurface.withValues(alpha: 0.05),
              blurRadius: 8,
              offset: const Offset(0, 4),
            ),
          ],
          borderRadius: BorderRadius.circular(30),
        ),
        child: Padding(
          padding: const EdgeInsets.all(10.0),
          child: Text("Add Participant", style: theme.textTheme.titleMedium),
        ),
      ),
    );
  }

  Future selectParticipantsBottomSheetMethod({
    required ThemeData theme,
    required BuildContext context,
  }) {
    var theme = Theme.of(context);

    if (tripController.participantModelList.isNotEmpty &&
        tripController.friendModelList.isNotEmpty) {
      // 1. Extract participant names (using a Set for fast lookups)
      final participantNames =
          tripController.participantModelList.map((p) => p.name).toSet();

      // 2. Remove friends whose names are in participants
      tripController.friendModelList.removeWhere(
        (friend) => participantNames.contains(friend.name),
      );

      // 3. For the remaining friends, reset selection
      for (var friend in tripController.friendModelList) {
        friend.isSelected = false;
      }

      // 4. Refresh the UI
      tripController.friendModelList.refresh();
    }

    tripController.validationMsgForSelectFriend.value = "";
    tripController.isVisibleAddFriendForm.value = false;

    return showModalBottomSheet(
      context: context,
      enableDrag: true, // Allow dragging to close
      isDismissible: true, // Allow tapping outside to dismiss
      isScrollControlled: true, // Allow the sheet to control its height
      useSafeArea: true, // Ensure content is placed within safe areas

      builder: (context) {
        return GetX<TripController>(
          builder: (_) {
            return Padding(
              padding: EdgeInsets.only(
                left: 20.0,
                right: 20.0,
                bottom: MediaQuery.of(context).viewInsets.bottom,
                top: 0.0,
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisSize: MainAxisSize.min,
                children: [
                  Padding(
                    padding: const EdgeInsets.only(top: 15.0, bottom: 10.0),
                    child: Align(
                      alignment: Alignment.center,
                      child: Container(
                        width: 50,
                        height: 5,
                        alignment: Alignment.center,
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(100),
                          color: darkTextColor,
                        ),
                      ),
                    ),
                  ),
                  Padding(
                    padding: const EdgeInsets.only(bottom: 5.0),
                    child: Row(
                      crossAxisAlignment: CrossAxisAlignment.center,
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Expanded(
                          child: Padding(
                            padding: const EdgeInsets.only(left: 2.0),
                            child: Text(
                              "Select Participants",
                              // maxLines: 1,
                              //overflow: TextOverflow.ellipsis,
                              style: theme.textTheme.titleMedium!.copyWith(
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ),
                        ),
                        IconButton(
                          iconSize: 24,
                          splashRadius: 20.0,
                          constraints: const BoxConstraints(),
                          onPressed: () {
                            Get.back();
                          },
                          icon: const Icon(Icons.close),
                        ),
                      ],
                    ),
                  ),
                  Flexible(
                    fit: FlexFit.loose,
                    child: NotificationListener<
                      OverscrollIndicatorNotification
                    >(
                      onNotification: (
                        OverscrollIndicatorNotification overscroll,
                      ) {
                        overscroll.disallowIndicator();
                        return true;
                      },
                      child: Padding(
                        padding: const EdgeInsets.only(bottom: 20.0),
                        child: SingleChildScrollView(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Wrap(
                                crossAxisAlignment: WrapCrossAlignment.start,
                                alignment: WrapAlignment.start,

                                runSpacing: 10.0,
                                spacing: 10.0,
                                children: [
                                  ...List.generate(tripController.friendModelList.length, (
                                    index,
                                  ) {
                                    FriendModel friendModel =
                                        tripController.friendModelList[index];
                                    return ChoiceChip(
                                      materialTapTargetSize:
                                          MaterialTapTargetSize.shrinkWrap,
                                      disabledColor: Colors.transparent,
                                      selectedShadowColor: Colors.transparent,
                                      shadowColor: Colors.transparent,
                                      color: WidgetStatePropertyAll(
                                        friendModel.isSelected!
                                            ? theme.primaryColor
                                            : darkTextColor,
                                      ),
                                      padding: EdgeInsets.zero,
                                      backgroundColor: theme.colorScheme.shadow,
                                      shape: RoundedRectangleBorder(
                                        borderRadius: BorderRadius.circular(
                                          12.5,
                                        ),
                                        side: BorderSide(color: darkTextColor),
                                      ),
                                      elevation: 0.0,
                                      pressElevation: 3.0,
                                      selectedColor:
                                          friendModel.isSelected!
                                              ? theme.primaryColor
                                              : darkTextColor,
                                      surfaceTintColor: Colors.transparent,
                                      checkmarkColor: darkTextColor,
                                      avatar:
                                          friendModel.isSelected == true
                                              ? Icon(
                                                Icons.check_circle_outline,
                                                color: lightBackground,
                                              )
                                              : null,
                                      labelPadding: EdgeInsets.only(
                                        left:
                                            friendModel.isSelected == true
                                                ? 0.0
                                                : 10.0,
                                        right: 10.0,

                                        top: 2.0,
                                        bottom: 2.0,
                                      ),
                                      labelStyle: theme.textTheme.titleMedium!
                                          .copyWith(
                                            color:
                                                friendModel.isSelected!
                                                    ? lightBackground
                                                    : theme.primaryColorDark,
                                            fontWeight:
                                                friendModel.isSelected!
                                                    ? FontWeight.bold
                                                    : FontWeight.normal,
                                          ),
                                      showCheckmark: false,
                                      selected: friendModel.isSelected!,
                                      label: Padding(
                                        padding: EdgeInsets.only(
                                          left:
                                              friendModel.isSelected == true
                                                  ? 0.0
                                                  : 5.0,
                                          right: 5.0,

                                          top: 2.0,
                                          bottom: 2.0,
                                        ),
                                        child: Column(
                                          mainAxisAlignment:
                                              MainAxisAlignment.start,
                                          crossAxisAlignment:
                                              CrossAxisAlignment.start,
                                          mainAxisSize: MainAxisSize.min,
                                          children: [
                                            Text(friendModel.name.toString()),
                                            Row(
                                              mainAxisSize: MainAxisSize.min,
                                              crossAxisAlignment:
                                                  CrossAxisAlignment.center,
                                              children: [
                                                Text(
                                                  "Member :",
                                                  style: theme
                                                      .textTheme
                                                      .labelSmall!
                                                      .copyWith(
                                                        color:
                                                            friendModel
                                                                    .isSelected!
                                                                ? lightBackground
                                                                : theme
                                                                    .primaryColorDark,
                                                        fontWeight:
                                                            friendModel
                                                                    .isSelected!
                                                                ? FontWeight
                                                                    .bold
                                                                : FontWeight
                                                                    .normal,
                                                      ),
                                                ),
                                                Text(
                                                  friendModel.memberCount
                                                      .toString(),
                                                  style: theme
                                                      .textTheme
                                                      .labelSmall!
                                                      .copyWith(
                                                        color:
                                                            friendModel
                                                                    .isSelected!
                                                                ? lightBackground
                                                                : theme
                                                                    .primaryColorDark,
                                                        fontWeight:
                                                            friendModel
                                                                    .isSelected!
                                                                ? FontWeight
                                                                    .bold
                                                                : FontWeight
                                                                    .normal,
                                                      ),
                                                ),
                                              ],
                                            ),
                                          ],
                                        ),
                                      ),
                                      onSelected: (value) {
                                        friendModel.isSelected =
                                            !friendModel.isSelected!;
                                        tripController.friendModelList
                                            .refresh();
                                      },
                                    );
                                  }),
                                  GestureDetector(
                                    onTap: () {
                                      tripController
                                          .isVisibleAddFriendForm
                                          .value = true;
                                    },
                                    child: Chip(
                                      materialTapTargetSize:
                                          MaterialTapTargetSize.shrinkWrap,

                                      shadowColor: Colors.transparent,
                                      color: WidgetStatePropertyAll(
                                        theme.primaryColor,
                                      ),
                                      padding: EdgeInsets.zero,
                                      backgroundColor: theme.primaryColor,
                                      shape: RoundedRectangleBorder(
                                        borderRadius: BorderRadius.circular(
                                          12.5,
                                        ),
                                        side: BorderSide(
                                          color: theme.primaryColor,
                                        ),
                                      ),
                                      elevation: 0.0,

                                      surfaceTintColor: Colors.transparent,

                                      avatar: Icon(
                                        Icons.add_circle_outline,
                                        color: lightBackground,
                                      ),
                                      labelPadding: EdgeInsets.only(
                                        right: 10.0,

                                        top: 2.0,
                                        bottom: 2.0,
                                      ),
                                      labelStyle: theme.textTheme.titleMedium!
                                          .copyWith(
                                            color: lightBackground,
                                            fontWeight: FontWeight.normal,
                                          ),

                                      label: Padding(
                                        padding: EdgeInsets.only(
                                          right: 5.0,
                                          top: 2.0,
                                          bottom: 2.0,
                                        ),
                                        child: Column(
                                          mainAxisAlignment:
                                              MainAxisAlignment.start,
                                          crossAxisAlignment:
                                              CrossAxisAlignment.start,
                                          mainAxisSize: MainAxisSize.min,
                                          children: [
                                            Text("Add Friend"),
                                            Text(
                                              "click here",
                                              style: theme.textTheme.labelSmall!
                                                  .copyWith(
                                                    color: lightBackground,
                                                    fontWeight:
                                                        FontWeight.normal,
                                                  ),
                                            ),
                                          ],
                                        ),
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                              if (tripController
                                  .isVisibleAddFriendForm
                                  .value) ...[
                                Padding(
                                  padding: const EdgeInsets.only(top: 10.0),
                                  child: Divider(color: theme.disabledColor),
                                ),
                                Row(
                                  children: [
                                    Expanded(
                                      child: Padding(
                                        padding: const EdgeInsets.all(8.0),
                                        child: Container(
                                          child: CustomTextField(
                                            controller:
                                                tripController
                                                    .friendNameController,
                                            hintText: "Name",
                                          ),
                                        ),
                                      ),
                                    ),
                                    Expanded(
                                      child: Padding(
                                        padding: const EdgeInsets.all(8.0),
                                        child: Container(
                                          child: CustomTextField(
                                            controller:
                                                tripController
                                                    .tripMemberController,
                                            hintText: "member",
                                          ),
                                        ),
                                      ),
                                    ),
                                    TextButton(
                                      onPressed: () {
                                        tripController.friendModelList.add(
                                          FriendModel(
                                            name:
                                                tripController
                                                    .friendNameController
                                                    .text,
                                            memberCount: int.tryParse(
                                              tripController
                                                  .tripMemberController
                                                  .text,
                                            ),
                                            isSelected: false,
                                          ),
                                        );
                                        tripController.tripMemberController
                                            .clear();
                                        tripController.friendNameController
                                            .clear();
                                      },
                                      child: Text(
                                        "Add",
                                        style: TextStyle(
                                          color: theme.primaryColor,
                                        ),
                                      ),
                                    ),
                                  ],
                                ),
                              ],
                            ],
                          ),
                        ),
                      ),
                    ),
                  ),
                  if (tripController
                      .validationMsgForSelectFriend
                      .value
                      .isNotEmpty)
                    Text(
                      "* ${tripController.validationMsgForSelectFriend.value}",
                      style: theme.textTheme.titleMedium!.copyWith(
                        color: theme.colorScheme.error,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  Padding(
                    padding: const EdgeInsets.symmetric(vertical: 15.0),
                    child: Container(
                      width:
                          double
                              .infinity, // Ensures the Container matches the button's width
                      decoration: BoxDecoration(
                        gradient: LinearGradient(
                          colors: [
                            theme.colorScheme.primary,
                            theme.colorScheme.secondary,
                          ],
                          begin: Alignment.topLeft,
                          end: Alignment.bottomRight,
                        ),
                        borderRadius: BorderRadius.circular(12),
                        boxShadow: [
                          BoxShadow(
                            color: theme.colorScheme.primary.withOpacity(0.3),
                            blurRadius: 8,
                            offset: const Offset(0, 4),
                          ),
                        ],
                      ),
                      /*padding: EdgeInsets.symmetric(
                        vertical: 16,
                      ),*/
                      // Adjust padding as needed
                      child: ElevatedButton(
                        style: ElevatedButton.styleFrom(
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                          backgroundColor:
                              Colors
                                  .transparent, // Set to transparent to allow gradient background
                          shadowColor: Colors.transparent,
                          splashFactory: NoSplash.splashFactory,
                          elevation: 0,
                        ),
                        onPressed: () {
                          tripController.addParticipantMethod(
                            context: context,
                            theme: theme,
                          );
                        },
                        child: Center(
                          child: Text(
                            'Add Paricipant',
                            style: theme.textTheme.labelLarge?.copyWith(
                              color: theme.colorScheme.onPrimary,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            );
          },
        );
      },
    );
  }

  Future selectEmojiBottomsheetMethod({required BuildContext context}) {
    return showModalBottomSheet(
      context: context,
      isDismissible: true,
      isScrollControlled: true,
      enableDrag: true,
      useSafeArea: true,
      builder: (context1) {
        return EmojiSelectorBottomSheet();
      },
    );
  }

  participantTable({required BuildContext context, required ThemeData theme}) {
    return Column(
      children: [
        Container(
          decoration: BoxDecoration(
            gradient: LinearGradient(
              colors: [
                theme.colorScheme.primary.withValues(alpha: 0.1),
                theme.colorScheme.secondary.withValues(alpha: 0.1),
              ],
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ),
            borderRadius: const BorderRadius.only(
              topRight: Radius.circular(15.0),
              topLeft: Radius.circular(15.0),
            ),
            boxShadow: [
              BoxShadow(
                color: theme.colorScheme.onSurface.withValues(alpha: 0.05),
                blurRadius: 8,
                offset: const Offset(0, 4),
              ),
            ],
          ),
          child: Table(
            border: null,
            defaultVerticalAlignment: TableCellVerticalAlignment.middle,
            columnWidths: const {
              0: FractionColumnWidth(0.50),
              1: FractionColumnWidth(0.20),
              2: FractionColumnWidth(0.15),
              3: FractionColumnWidth(0.15),
            },
            children: [
              TableRow(
                children: [
                  Padding(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 10.0,
                      vertical: 10.0,
                    ),
                    child: Text(
                      "Name",
                      maxLines: 1,
                      style: theme.textTheme.titleSmall!.copyWith(
                        fontWeight: FontWeight.bold,
                        color: theme.colorScheme.onSurface,
                      ),
                    ),
                  ),
                  Padding(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 10.0,
                      vertical: 12.0,
                    ),
                    child: Text(
                      "Member",
                      maxLines: 1,
                      style: theme.textTheme.titleSmall!.copyWith(
                        fontWeight: FontWeight.bold,
                        color: theme.colorScheme.onSurface,
                      ),
                    ),
                  ),
                  Padding(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 10.0,
                      vertical: 12.0,
                    ),
                    child: Icon(Icons.edit_outlined, size: 20),
                  ),
                  Padding(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 10.0,
                      vertical: 12.0,
                    ),
                    child: Icon(Icons.delete_outline, size: 20),
                  ),
                ],
              ),
            ],
          ),
        ),
        Column(
          children: List.generate(tripController.participantModelList.length, (
            index,
          ) {
            return Container(
              decoration: BoxDecoration(
                color: theme.scaffoldBackgroundColor,
                borderRadius:
                    tripController.participantModelList.length - 1 == index
                        ? BorderRadius.only(
                          bottomLeft: Radius.circular(15.0),
                          bottomRight: Radius.circular(15.0),
                        )
                        : null,
                boxShadow: [
                  BoxShadow(
                    color: theme.colorScheme.onSurface.withValues(alpha: 0.05),
                    blurRadius: 8,
                    offset: const Offset(0, 4),
                  ),
                ],
              ),
              child: Table(
                border: null,
                // border: TableBorder(
                //   verticalInside: BorderSide(
                //     color: theme.hintColor,
                //     width: 1.0,
                //   ),
                // ),
                defaultVerticalAlignment: TableCellVerticalAlignment.middle,
                columnWidths: const {
                  0: FractionColumnWidth(0.50),
                  1: FractionColumnWidth(0.20),
                  2: FractionColumnWidth(0.15),
                  3: FractionColumnWidth(0.15),
                },
                children: [
                  TableRow(
                    children: [
                      Padding(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 10.0,
                          vertical: 10.0,
                        ),
                        child: Text(
                          "${tripController.participantModelList.elementAt(index).name}",
                          maxLines: 1,
                          style: theme.textTheme.titleSmall!.copyWith(
                            fontWeight: FontWeight.bold,
                            color: theme.colorScheme.onSurface,
                          ),
                        ),
                      ),
                      Padding(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 10.0,
                          vertical: 12.0,
                        ),
                        child: Center(
                          child: Text(
                            "${tripController.participantModelList.elementAt(index).memberCount}",
                            maxLines: 1,
                            style: theme.textTheme.titleSmall!.copyWith(
                              fontWeight: FontWeight.bold,
                              color: theme.colorScheme.onSurface,
                            ),
                          ),
                        ),
                      ),
                      Padding(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 10.0,
                          vertical: 12.0,
                        ),
                        child: Icon(
                          Icons.edit_outlined,
                          size: 20,
                          color: Colors.green,
                        ),
                      ),
                      Padding(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 10.0,
                          vertical: 12.0,
                        ),
                        child: GestureDetector(
                          child: Icon(
                            Icons.delete_outlined,
                            color: Colors.red.shade600,
                          ),
                          onTap: () {
                            if (index >= 0 && index < tripController.participantModelList.length) {
                              tripController.removeFromParticipantList(
                                context: context,
                                theme: theme,
                                participant_id: tripController.participantModelList.elementAt(index).id,
                              );
                            }
                          },
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            );
          }),
        ),
      ],
    );
  }
}
