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

  final TripController tripController = Get.find<TripController>();
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
          body: tripController.isMantainTripLoading.value
              ? const Center(child: CircularProgressIndicator())
              : bodyWidget(context: context, theme: theme),
          bottomNavigationBar: tripController.isMantainTripLoading.value == false
              ? bottomNavigationBarWidget(context: context, theme: theme)
              : null,
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
            final tripId = int.tryParse(argumentData['trip_id']?.toString() ?? '');
            if (tripId != null) {
              tripController.saveTripData(tripId: tripId);
            } else {
              // Handle the case where tripId is not a valid integer
              print('Error: trip_id is not a valid integer');
              // Optionally, show a user-friendly error message or take alternative action
            }
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
                      tripController.emojiController.selectedEmoji.value?.char ??
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
                  padding: const EdgeInsets.only(left: 5.0),
                  child: Text(
                    AppStrings.titleLabel,
                    style: theme.textTheme.titleMedium,
                  ),
                ),
                CustomTextField(
                  hintText: AppStrings.enterTripName,
                  controller: tripController.tripNameController,
                  validator: (value) {
                    if (value == null || value.trim().isEmpty) {
                      return AppStrings.tripNameValidation;
                    }
                    return null;
                  },
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
                  padding: const EdgeInsets.only(left: 5.0),
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
                  items: AppConstants.currencies
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
    required BuildContext context,
    required ThemeData theme,
  }) {
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
                    padding: const EdgeInsets.only(top: 15.0, bottom: 5.0),
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
                    padding: const EdgeInsets.only(bottom: 5.0),
                    child: Row(
                      crossAxisAlignment: CrossAxisAlignment.center,
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Expanded(
                          child: Padding(
                            padding: const EdgeInsets.only(left: 2.0),
                            child: Text(
                              AppStrings.selectParticipants,
                              style: theme.textTheme.titleMedium!.copyWith(
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ),
                        ),
                        IconButton(
                          iconSize: 24,
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
                    child: NotificationListener<OverscrollIndicatorNotification>(
                      onNotification: (OverscrollIndicatorNotification overscroll) {
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
                              tripController.isAddparticipantLoading.value
                                  ? const Center(child: CircularProgressIndicator())
                                  : Wrap(
                                crossAxisAlignment: WrapCrossAlignment.start,
                                alignment: WrapAlignment.start,
                                runSpacing: AppSpacers.smallSpacing,
                                spacing: AppSpacers.smallSpacing,
                                children: [
                                  ...List.generate(
                                    tripController.selectedfriendModelList.length,
                                        (index) {
                                      FriendModel friendModel =
                                      tripController.selectedfriendModelList[index];
                                      return ChoiceChip(
                                        materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
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
                                          side: BorderSide(color: AppColors.darkText),
                                        ),
                                        elevation: 0.0,
                                        pressElevation: 3.0,
                                        selectedColor: friendModel.isSelected
                                            ? theme.primaryColor
                                            : AppColors.darkText,
                                        surfaceTintColor: Colors.transparent,
                                        checkmarkColor: AppColors.darkText,
                                        avatar: friendModel.isSelected
                                            ? Icon(
                                          Icons.check_circle_outline,
                                          color: AppColors.lightBackground,
                                        )
                                            : null,
                                        labelPadding: EdgeInsets.only(
                                          left: friendModel.isSelected ? 0.0 : 10.0,
                                          right: 10.0,
                                          top: 2.0,
                                          bottom: 2.0,
                                        ),
                                        labelStyle: theme.textTheme.titleMedium!.copyWith(
                                          color: friendModel.isSelected
                                              ? AppColors.lightBackground
                                              : theme.primaryColorDark,
                                          fontWeight: friendModel.isSelected
                                              ? FontWeight.bold
                                              : FontWeight.normal,
                                        ),
                                        showCheckmark: false,
                                        selected: friendModel.isSelected,
                                        label: Padding(
                                          padding: EdgeInsets.only(
                                            left: friendModel.isSelected ? 0.0 : 5.0,
                                            right: 5.0,
                                            top: 2.0,
                                            bottom: 2.0,
                                          ),
                                          child: Column(
                                            mainAxisAlignment: MainAxisAlignment.start,
                                            crossAxisAlignment: CrossAxisAlignment.start,
                                            mainAxisSize: MainAxisSize.min,
                                            children: [
                                              Text(friendModel.participant.name ?? 'Unknown'),
                                              Row(
                                                mainAxisSize: MainAxisSize.min,
                                                crossAxisAlignment: CrossAxisAlignment.center,
                                                children: [
                                                  Text(
                                                    "Member:",
                                                    style: AppStyles.chipLabelStyle(
                                                      theme,
                                                      friendModel.isSelected,
                                                    ),
                                                  ),
                                                  Text(
                                                    friendModel.participant.member.toString(),
                                                    style: AppStyles.chipLabelStyle(
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
                                          friendModel.isSelected = !friendModel.isSelected;
                                          tripController.selectedfriendModelList.refresh();
                                        },
                                      );
                                    },
                                  ),
                                  GestureDetector(
                                    onTap: () {
                                      tripController.isVisibleAddFriendForm.value = true;
                                    },
                                    child: Chip(
                                      materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
                                      shadowColor: Colors.transparent,
                                      color: WidgetStatePropertyAll(theme.primaryColor),
                                      padding: EdgeInsets.zero,
                                      backgroundColor: theme.primaryColor,
                                      shape: RoundedRectangleBorder(
                                        borderRadius: AppBorders.chipRadius,
                                        side: BorderSide(color: theme.primaryColor),
                                      ),
                                      elevation: 0.0,
                                      surfaceTintColor: Colors.transparent,
                                      avatar: Icon(
                                        Icons.add_circle_outline,
                                        color: AppColors.lightBackground,
                                      ),
                                      labelPadding: const EdgeInsets.only(
                                        right: 10.0,
                                        top: 2.0,
                                        bottom: 2.0,
                                      ),
                                      labelStyle: theme.textTheme.titleMedium!.copyWith(
                                        color: AppColors.lightBackground,
                                        fontWeight: FontWeight.normal,
                                      ),
                                      label: Padding(
                                        padding: const EdgeInsets.only(
                                          right: 5.0,
                                          top: 2.0,
                                          bottom: 2.0,
                                        ),
                                        child: Column(
                                          mainAxisAlignment: MainAxisAlignment.start,
                                          crossAxisAlignment: CrossAxisAlignment.start,
                                          mainAxisSize: MainAxisSize.min,
                                          children: [
                                            Text(AppStrings.addFriend),
                                            Text(
                                              AppStrings.clickHere,
                                              style: theme.textTheme.labelSmall!.copyWith(
                                                color: AppColors.lightBackground,
                                                fontWeight: FontWeight.normal,
                                              ),
                                            ),
                                          ],
                                        ),
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                              if (tripController.isVisibleAddFriendForm.value) ...[
                                Padding(
                                  padding: const EdgeInsets.only(top: 10.0),
                                  child: Divider(color: theme.disabledColor),
                                ),
                                Form(
                                  key: tripController.addParticipantFormKey,
                                  child: Row(
                                    children: [
                                      Expanded(
                                        child: Padding(
                                          padding: AppPaddings.smallPadding,
                                          child: CustomTextField(
                                            controller: tripController.newParticipantNameController,
                                            hintText: AppStrings.nameLabel,
                                            validator: (value) {
                                              if (value == null || value.trim().isEmpty) {
                                                return AppStrings.nameValidation;
                                              }
                                              return null;
                                            },
                                          ),
                                        ),
                                      ),
                                      Expanded(
                                        child: Padding(
                                          padding: AppPaddings.smallPadding,
                                          child: CustomTextField(
                                            controller: tripController.newParticipantMembersController,
                                            hintText: AppStrings.memberLabel,
                                            keyboardType: TextInputType.number,
                                            inputFormatters: [FilteringTextInputFormatter.digitsOnly],
                                            validator: (value) {
                                              if (value == null || value.trim().isEmpty) {
                                                return AppStrings.memberInvalid;
                                              }
                                              if (int.tryParse(value) == null || int.parse(value) <= 0) {
                                                return AppStrings.memberInvalid;
                                              }
                                              return null;
                                            },
                                          ),
                                        ),
                                      ),
                                      TextButton(
                                        onPressed: () {
                                          if (tripController.addParticipantFormKey.currentState?.validate() ?? false) {
                                            tripController.addNewParticipant(
                                              context: context,
                                              theme: theme,
                                              participantData: {
                                                'name': tripController.newParticipantNameController.text.trim(),
                                                'member': int.parse(tripController.newParticipantMembersController.text.trim()),
                                              },
                                            );
                                            tripController.newParticipantNameController.clear();
                                            tripController.newParticipantMembersController.clear();
                                          }
                                        },
                                        child: Text(
                                          AppStrings.addLabel,
                                          style: TextStyle(color: theme.primaryColor),
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              ],
                            ],
                          ),
                        ),
                      ),
                    ),
                  ),
                  if (tripController.validationMsgForSelectFriend.value.isNotEmpty)
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
                      child: ElevatedButton(
                        style: AppStyles.elevatedButtonStyle(theme),
                        onPressed: () {
                          tripController.addParticipantMethod(context: context, theme: theme);
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
                borderRadius: tripController.participantModelList.length - 1 == index
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
                          selectedFriends[index].name ?? 'Unknown',
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
                            tripController.removeFromParticipantList(
                              context: context,
                              theme: theme,
                              participantReferenceId: selectedFriends[index].referenceId,
                            );
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