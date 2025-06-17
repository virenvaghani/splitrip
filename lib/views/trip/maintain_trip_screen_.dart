import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';
import 'package:dropdown_button2/dropdown_button2.dart';
import 'package:splitrip/controller/trip/trip_controller.dart';
import 'package:splitrip/model/friend/friend_model.dart';
import 'package:splitrip/widgets/myappbar.dart';
import '../../../widgets/emoji_selector.dart';
import '../../data/trip_constant.dart';
import '../../theme/theme_colors.dart';
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
          appBar: CustomAppBar(title: AppStrings.newTripTitle),
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
          padding: AppPaddings.defaultPadding,
          child: Form(
            key: tripController.formKey,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                emojiSelectAndTitleWidget(context: context, theme: theme),
                AppSpacers.medium,
                currencyWidget(context: context, theme: theme),
                AppSpacers.medium,
                selectParticipantWidget(context: context, theme: theme),
                AppSpacers.small,
                participantTable(context: context, theme: theme),
                AppSpacers.small,
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
        width: double.infinity,
        decoration: BoxDecoration(
          gradient: LinearGradient(
            colors: [theme.colorScheme.primary, theme.colorScheme.secondary],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
          borderRadius: AppBorders.defaultRadius,
          boxShadow: [AppShadows.defaultShadow(theme)],
        ),
        padding: AppPaddings.buttonPadding,
        child: ElevatedButton(
          style: AppStyles.elevatedButtonStyle(theme),
          onPressed: () {
            tripController.loadTripInitData();
          },
          child: Center(
            child: Text(
              AppStrings.createTrip,
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
            padding: AppPaddings.smallBottom,
            child: Stack(
              children: [
                Container(
                  height: 50,
                  width: 50,
                  decoration: AppStyles.kBoxDecoration,
                  child: Center(
                    child: Text(
                      tripController
                              .emojiController
                              .selectedEmoji
                              .value
                              ?.char ??
                          AppStrings.defaultEmoji,
                      style: AppStyles.emojiStyle,
                      semanticsLabel: AppStrings.selectEmojiLabel,
                    ),
                  ),
                ),
                Positioned(
                  bottom: 0.0,
                  right: 0.0,
                  child: CircleAvatar(
                    radius: AppSizes.smallAvatarRadius,
                    backgroundColor: AppColors.darkText,
                    child: Icon(
                      Icons.edit_outlined,
                      color: theme.primaryColor,
                      size: AppSizes.smallIcon,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
        Expanded(
          child: Padding(
            padding: const EdgeInsets.only(left: AppSpacers.smallSpacing),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Padding(
                  padding: const EdgeInsets.only(
                    left: 5.0,
                  ), // No matching constant, keeping as is
                  child: Text(
                    AppStrings.titleLabel,
                    style: theme.textTheme.titleMedium,
                  ),
                ),
                CustomTextField(
                  hintText: AppStrings.enterTripName,
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
          padding: AppPaddings.smallBottom,
          child: Container(
            height: 50,
            width: 50,
            decoration: AppStyles.kBoxDecoration,
            child: Icon(Icons.currency_rupee, color: theme.primaryColor),
          ),
        ),
        Expanded(
          child: Padding(
            padding: const EdgeInsets.only(left: AppSpacers.smallSpacing),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Padding(
                  padding: const EdgeInsets.only(
                    left: 5.0,
                  ), // No matching constant, keeping as is
                  child: Text(
                    AppStrings.currencyLabel,
                    style: theme.textTheme.titleMedium,
                  ),
                ),
                DropdownButtonFormField2<String>(
                  iconStyleData: AppStyles.dropdownIconStyle,
                  decoration: AppStyles.dropdownDecoration(theme),
                  hint: Text(
                    AppStrings.selectCurrency,
                    style: AppStyles.hintStyle(theme),
                  ),
                  items:
                      AppConstants.currencies
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
                      return AppStrings.currencyValidation;
                    }
                    return null;
                  },
                  dropdownStyleData: DropdownStyleData(
                    decoration: BoxDecoration(
                      borderRadius: AppBorders.defaultRadius,
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
          boxShadow: [AppShadows.defaultShadow(theme)],
          borderRadius: AppBorders.largeRadius,
        ),
        child: Padding(
          padding: const EdgeInsets.all(AppSpacers.smallSpacing),
          child: Text(
            AppStrings.addParticipant,
            style: theme.textTheme.titleMedium,
          ),
        ),
      ),
    );
  }

  Future selectParticipantsBottomSheetMethod({
    required ThemeData theme,
    required BuildContext context,
  }) {
    var theme = Theme.of(context);
    tripController.validationMsgForSelectFriend.value = "";
    tripController.isVisibleAddFriendForm.value = false;

    return showModalBottomSheet(
      context: context,
      enableDrag: true,
      isDismissible: true,
      isScrollControlled: true,
      useSafeArea: true,
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
                    padding: const EdgeInsets.only(
                      top: 15.0,
                      bottom: 5.0,
                    ), // No matching constant, keeping as is
                    child: Align(
                      alignment: Alignment.center,
                      child: Container(
                        width: AppSizes.handleWidth,
                        height: AppSizes.handleHeight,
                        alignment: Alignment.center,
                        decoration: BoxDecoration(
                          borderRadius: AppBorders.handleRadius,
                          color: AppColors.darkText,
                        ),
                      ),
                    ),
                  ),
                  Padding(
                    padding: const EdgeInsets.only(
                      bottom: 5.0,
                    ), // No matching constant, keeping as is
                    child: Row(
                      crossAxisAlignment: CrossAxisAlignment.center,
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Expanded(
                          child: Padding(
                            padding: const EdgeInsets.only(
                              left: 2.0,
                            ), // No matching constant, keeping as is
                            child: Text(
                              AppStrings.selectParticipants,
                              style: theme.textTheme.titleMedium!.copyWith(
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ),
                        ),
                        IconButton(
                          iconSize: 24, // No matching constant, keeping as is
                          splashRadius: AppSizes.splashRadius,
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
                        padding: const EdgeInsets.only(
                          bottom: 20.0,
                        ), // No matching constant, keeping as is
                        child: SingleChildScrollView(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Wrap(
                                crossAxisAlignment: WrapCrossAlignment.start,
                                alignment: WrapAlignment.start,
                                runSpacing: AppSpacers.smallSpacing,
                                spacing: AppSpacers.smallSpacing,
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
                                        friendModel.isSelected
                                            ? AppColors.primary
                                            : AppColors.darkText,
                                      ),
                                      padding: EdgeInsets.zero,
                                      backgroundColor: theme.colorScheme.shadow,
                                      shape: RoundedRectangleBorder(
                                        borderRadius: AppBorders.chipRadius,
                                        side: BorderSide(
                                          color: AppColors.darkText,
                                        ),
                                      ),
                                      elevation: 0.0,
                                      pressElevation: 3.0,
                                      selectedColor:
                                          friendModel.isSelected
                                              ? theme.primaryColor
                                              : AppColors.darkText,
                                      surfaceTintColor: Colors.transparent,
                                      checkmarkColor: AppColors.darkText,
                                      avatar:
                                          friendModel.isSelected
                                              ? Icon(
                                                Icons.check_circle_outline,
                                                color:
                                                    AppColors.lightBackground,
                                              )
                                              : null,
                                      labelPadding: EdgeInsets.only(
                                        left:
                                            friendModel.isSelected
                                                ? 0.0
                                                : 10.0, // Conditional, no direct constant
                                        right:
                                            10.0, // No matching constant, keeping as is
                                        top:
                                            2.0, // No matching constant, keeping as is
                                        bottom:
                                            2.0, // No matching constant, keeping as is
                                      ),
                                      labelStyle: theme.textTheme.titleMedium!
                                          .copyWith(
                                            color:
                                                friendModel.isSelected
                                                    ? AppColors.lightBackground
                                                    : theme.primaryColorDark,
                                            fontWeight:
                                                friendModel.isSelected
                                                    ? FontWeight.bold
                                                    : FontWeight.normal,
                                          ),
                                      showCheckmark: false,
                                      selected: friendModel.isSelected,
                                      label: Padding(
                                        padding: EdgeInsets.only(
                                          left:
                                              friendModel.isSelected
                                                  ? 0.0
                                                  : 5.0, // Conditional, no direct constant
                                          right:
                                              5.0, // No matching constant, keeping as is
                                          top:
                                              2.0, // No matching constant, keeping as is
                                          bottom:
                                              2.0, // No matching constant, keeping as is
                                        ),
                                        child: Column(
                                          mainAxisAlignment:
                                              MainAxisAlignment.start,
                                          crossAxisAlignment:
                                              CrossAxisAlignment.start,
                                          mainAxisSize: MainAxisSize.min,
                                          children: [
                                            Text(friendModel.participant.name),
                                            Row(
                                              mainAxisSize: MainAxisSize.min,
                                              crossAxisAlignment:
                                                  CrossAxisAlignment.center,
                                              children: [
                                                Text(
                                                  "Member:",
                                                  style:
                                                      AppStyles.chipLabelStyle(
                                                        theme,
                                                        friendModel.isSelected,
                                                      ),
                                                ),
                                                Text(
                                                  friendModel.participant.member
                                                      .toString(),
                                                  style:
                                                      AppStyles.chipLabelStyle(
                                                        theme,
                                                        friendModel.isSelected,
                                                      ),
                                                ),
                                              ],
                                            ),
                                          ],
                                        ),
                                      ),
                                      onSelected: (value) {
                                        friendModel.isSelected =
                                            !friendModel.isSelected;
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
                                        borderRadius: AppBorders.chipRadius,
                                        side: BorderSide(
                                          color: theme.primaryColor,
                                        ),
                                      ),
                                      elevation: 0.0,
                                      surfaceTintColor: Colors.transparent,
                                      avatar: Icon(
                                        Icons.add_circle_outline,
                                        color: AppColors.lightBackground,
                                      ),
                                      labelPadding: EdgeInsets.only(
                                        right:
                                            10.0, // No matching constant, keeping as is
                                        top:
                                            2.0, // No matching constant, keeping as is
                                        bottom:
                                            2.0, // No matching constant, keeping as is
                                      ),
                                      labelStyle: theme.textTheme.titleMedium!
                                          .copyWith(
                                            color: AppColors.lightBackground,
                                            fontWeight: FontWeight.normal,
                                          ),
                                      label: Padding(
                                        padding: EdgeInsets.only(
                                          right:
                                              5.0, // No matching constant, keeping as is
                                          top:
                                              2.0, // No matching constant, keeping as is
                                          bottom:
                                              2.0, // No matching constant, keeping as is
                                        ),
                                        child: Column(
                                          mainAxisAlignment:
                                              MainAxisAlignment.start,
                                          crossAxisAlignment:
                                              CrossAxisAlignment.start,
                                          mainAxisSize: MainAxisSize.min,
                                          children: [
                                            Text(AppStrings.addFriend),
                                            Text(
                                              AppStrings.clickHere,
                                              style: theme.textTheme.labelSmall!
                                                  .copyWith(
                                                    color:
                                                        AppColors
                                                            .lightBackground,
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
                                  padding: const EdgeInsets.only(
                                    top: 10.0,
                                  ), // No matching constant, keeping as is
                                  child: Divider(color: theme.disabledColor),
                                ),
                                Row(
                                  children: [
                                    Expanded(
                                      child: Padding(
                                        padding: AppPaddings.smallPadding,
                                        child: Container(
                                          child: CustomTextField(
                                            controller:
                                                tripController
                                                    .friendNameController,
                                            hintText: AppStrings.nameLabel,
                                          ),
                                        ),
                                      ),
                                    ),
                                    Expanded(
                                      child: Padding(
                                        padding: AppPaddings.smallPadding,
                                        child: Container(
                                          child: CustomTextField(
                                            controller:
                                                tripController
                                                    .tripMemberController,
                                            hintText: AppStrings.memberLabel,
                                          ),
                                        ),
                                      ),
                                    ),
                                    TextButton(
                                      onPressed: () {
                                        // tripController.friendModelList.add(
                                        //   // FriendModel(
                                        //   //   id: 0, // Placeholder if not yet saved to backend
                                        //   //   referenceId: '', // Will be filled after backend response if needed
                                        //   //   name: tripController.friendNameController.text,
                                        //   //   member: int.tryParse(
                                        //   //     tripController.tripMemberController.text,
                                        //   //   ) ??
                                        //   //       1,
                                        //   //   isSelected: false,
                                        //   // ),
                                        // //);
                                        // //tripController.tripMemberController.clear();
                                        // //tripController.friendNameController.clear();
                                      },
                                      child: Text(
                                        AppStrings.addLabel,
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
                    padding: const EdgeInsets.symmetric(
                      vertical: 15.0,
                    ), // No matching constant, keeping as is
                    child: Container(
                      width: double.infinity,
                      decoration: BoxDecoration(
                        gradient: LinearGradient(
                          colors: [
                            theme.colorScheme.primary,
                            theme.colorScheme.secondary,
                          ],
                          begin: Alignment.topLeft,
                          end: Alignment.bottomRight,
                        ),
                        borderRadius: AppBorders.defaultRadius,
                        boxShadow: [AppShadows.defaultShadow(theme)],
                      ),
                      child: ElevatedButton(
                        style: AppStyles.elevatedButtonStyle(theme),
                        onPressed: () {
                          // tripController.addParticipantMethod(
                          //   context: context,
                          //   theme: theme,
                          // );
                        },
                        child: Center(
                          child: Text(
                            AppStrings.addParticipant,
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

  Widget participantTable({
    required BuildContext context,
    required ThemeData theme,
  }) {
    final selectedFriends = tripController.participantModelList;
    return selectedFriends.isNotEmpty
        ? Column(
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
                borderRadius: AppBorders.tableTopRadius,
                boxShadow: [AppShadows.defaultShadow(theme)],
              ),
              child: Table(
                border: null,
                defaultVerticalAlignment: TableCellVerticalAlignment.middle,
                columnWidths: AppConstants.tableColumnWidths,
                children: [
                  TableRow(
                    children: [
                      Padding(
                        padding: AppPaddings.tableCellPadding,
                        child: Text(
                          AppStrings.nameLabel,
                          maxLines: 1,
                          style: theme.textTheme.titleSmall!.copyWith(
                            fontWeight: FontWeight.bold,
                            color: theme.colorScheme.onSurface,
                          ),
                        ),
                      ),
                      Padding(
                        padding: AppPaddings.tableCellPadding,
                        child: Text(
                          AppStrings.memberLabel,
                          maxLines: 1,
                          style: theme.textTheme.titleSmall!.copyWith(
                            fontWeight: FontWeight.bold,
                            color: theme.colorScheme.onSurface,
                          ),
                        ),
                      ),
                      Padding(
                        padding: AppPaddings.tableCellPadding,
                        child: Icon(
                          Icons.edit_outlined,
                          size: AppSizes.mediumIcon,
                        ),
                      ),
                      Padding(
                        padding: AppPaddings.tableCellPadding,
                        child: Icon(
                          Icons.delete_outline,
                          size: AppSizes.mediumIcon,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
            Column(
              children: List.generate(selectedFriends.length, (index) {
                return Container(
                  decoration: BoxDecoration(
                    color: theme.scaffoldBackgroundColor,
                    borderRadius:
                        tripController.participantModelList.length - 1 == index
                            ? AppBorders.tableBottomRadius
                            : null,
                    boxShadow: [AppShadows.defaultShadow(theme)],
                  ),
                  child: Table(
                    border: null,
                    defaultVerticalAlignment: TableCellVerticalAlignment.middle,
                    columnWidths: AppConstants.tableColumnWidths,
                    children: [
                      TableRow(
                        children: [
                          Padding(
                            padding: AppPaddings.tableCellPadding,
                            child: Text(
                              selectedFriends[index].name,
                              maxLines: 1,
                              style: theme.textTheme.titleSmall!.copyWith(
                                fontWeight: FontWeight.bold,
                                color: theme.colorScheme.onSurface,
                              ),
                            ),
                          ),
                          Padding(
                            padding: AppPaddings.tableCellPadding,
                            child: Center(
                              child: Text(
                                "${selectedFriends[index].member}",
                                maxLines: 1,
                                style: theme.textTheme.titleSmall!.copyWith(
                                  fontWeight: FontWeight.bold,
                                  color: theme.colorScheme.onSurface,
                                ),
                              ),
                            ),
                          ),
                          Padding(
                            padding: AppPaddings.tableCellPadding,
                            child: Icon(
                              Icons.edit_outlined,
                              size: AppSizes.mediumIcon,
                              color: Colors.green,
                            ),
                          ),
                          Padding(
                            padding: AppPaddings.tableCellPadding,
                            child: GestureDetector(
                              child: Icon(
                                Icons.delete_outlined,
                                color: Colors.red.shade600,
                                size: AppSizes.mediumIcon,
                              ),
                              onTap: () {
                                // if (index >= 0 &&
                                //     index < selectedFriends.length) {
                                //   tripController.removeFromParticipantList(
                                //     context: context,
                                //     theme: theme,
                                //     participantId: selectedFriends[index].id,
                                //   );
                                // }
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
        )
        : const Center(
          child: Text(
            AppStrings.noFriendsSelected,
            style: TextStyle(color: Colors.grey),
          ),
        );
  }
}
