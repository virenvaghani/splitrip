import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';
import 'package:dropdown_button2/dropdown_button2.dart';
import 'package:splitrip/controller/trip/trip_controller.dart';
import 'package:splitrip/data/constants.dart';
import 'package:splitrip/model/friend/friend_model.dart';
import 'package:splitrip/widgets/myappbar.dart';
import '../../../../widgets/emoji_selector.dart';
import '../../../controller/splash_screen/splash_screen_controller.dart';
import '../../../data/trip_constant.dart';
import '../../../model/currency/currency_model.dart';
import '../../../model/friend/participant_model.dart';
import '../../../theme/theme_colors.dart';
import '../../../widgets/my_textfield.dart';

class MaintainTripScreen extends StatelessWidget {
  MaintainTripScreen({super.key});

  final TripController tripController = Get.find<TripController>();
  final SplashScreenController splashScreenController = Get.put(
      SplashScreenController());

  final argumentData = Get.arguments;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return GetX<TripController>(
      initState: (state) {
        tripController.initStateMethodForMaintain(argumentData: argumentData);
      },
      builder: (_) {
        return AnnotatedRegion<SystemUiOverlayStyle>(
          value: SystemUiOverlayStyle(
            systemNavigationBarColor: Theme
                .of(context)
                .scaffoldBackgroundColor,
            // navigation bar color
            statusBarColor: Theme
                .of(context)
                .scaffoldBackgroundColor,
            statusBarBrightness: Brightness.light,
            statusBarIconBrightness: Brightness.dark,
            systemNavigationBarContrastEnforced: true,
            systemNavigationBarIconBrightness: Brightness.dark,
            systemStatusBarContrastEnforced: true,
          ),
          child: SafeArea(
            child: Scaffold(
              appBar: CustomAppBar(
                title: AppStrings.newTripTitle, centerTitle: true,),
              body:
              tripController.isMantainTripLoading.value
                  ? const Center(child: CircularProgressIndicator())
                  : bodyWidget(context: context, theme: theme),
              bottomNavigationBar:
              tripController.isMantainTripLoading.value == false
                  ? bottomNavigationBarWidget(
                context: context,
                theme: theme,
              )
                  : null,
            ),
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
          onPressed: () => tripController.saveTrip(argumentData: argumentData),
          child: Center(
            child: Text(
              int.tryParse(argumentData['trip_id']?.toString() ?? '') != null
                  ? AppStrings.updateTrip
                  : AppStrings.createTrip,
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
                    if (value == null || value
                        .trim()
                        .isEmpty) {
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
          child: Obx(() {
            final selectedId = tripController.selectedCurrencyId.value;

            final selectedCurrency = Kconstant.currencyModelList.firstWhere(
                  (currency) => currency.id == selectedId,
              orElse: () => CurrencyModel(
                id: 0, // Use a unique ID that doesn't exist in the list
                code: 'INR',
                name: 'Indian Rupee',
                symbol: '₹',
              ),
            );

            final double fontSize =
            selectedCurrency.symbol.length > 2 ? 18.0 : 24.0;

            return Container(
              height: 50,
              width: 50,
              decoration: AppStyles.kBoxDecoration,
              child: Center(
                child: Text(
                  selectedCurrency.symbol,
                  style: theme.textTheme.headlineLarge?.copyWith(
                    color: theme.primaryColor,
                    fontSize: fontSize,
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
              ),
            );
          }),
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
                Obx(() {
                  final selectedId = tripController.selectedCurrencyId.value;

                  // Ensure unique items in the dropdown
                  final uniqueCurrencies = Kconstant.currencyModelList
                      .asMap()
                      .entries
                      .fold<List<CurrencyModel>>([], (list, entry) {
                    if (!list.any((c) => c.id == entry.value.id)) {
                      list.add(entry.value);
                    }
                    return list;
                  });

                  return DropdownButtonFormField2<int>(
                    iconStyleData: AppStyles.dropdownIconStyle,
                    decoration: AppStyles.dropdownDecoration(theme),
                    hint: Text(
                      AppStrings.selectCurrency,
                      style: AppStyles.hintStyle(theme),
                    ),
                    items: [
                      ...uniqueCurrencies.map(
                            (currency) => DropdownMenuItem<int>(
                          value: currency.id,
                          child: Text(
                            currency.name,
                            style: theme.textTheme.bodyLarge,
                          ),
                        ),
                      ),
                    ],
                    value: selectedId == 0 ? null : selectedId,
                    onChanged: (value) {
                      if (value == -1) {
                      } else if (value != null) {
                        tripController.selectedCurrencyId.value = value;
                      }
                    },
                    validator: (value) {
                      if (value == null || value <= 0) {
                        return AppStrings.currencyValidation;
                      }
                      return null;
                    },
                    dropdownStyleData: DropdownStyleData(
                      decoration: BoxDecoration(
                        borderRadius: AppBorders.defaultRadius,
                        color: theme.cardTheme.color,
                      ),
                      maxHeight: 500.0,
                      elevation: 1,
                    ),
                  );
                }),
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
          //border: Border.all(color: theme.colorScheme.primary.withValues(alpha: )(0.2))
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
    final TextEditingController searchController = TextEditingController();

    return showModalBottomSheet(
      context: context,
      enableDrag: true,
      isDismissible: true,
      isScrollControlled: true,
      useSafeArea: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24.0)),
      ),
      backgroundColor: theme.colorScheme.surface,
      builder: (context) {
        return GetX<TripController>(
          builder: (_) {
            final filteredFriends =
            (searchController.text.isEmpty
                ? tripController.availableParticipantModel.toList()
                : tripController.availableParticipantModel
                .where(
                  (friend) =>
              friend.participant.name?.toLowerCase().contains(
                searchController.text.toLowerCase(),
              ) ??
                  false,
            )
                .toList())
              ..sort(
                    (a, b) =>
                    (a.participant.name ?? '')
                        .toLowerCase()
                        .compareTo((b.participant.name ?? '').toLowerCase()),
              );

            return Padding(
              padding: MediaQuery
                  .of(context)
                  .viewInsets,
              child: SizedBox(
                height: MediaQuery
                    .of(context)
                    .size
                    .height * 0.8,
                child: Padding(
                  padding: const EdgeInsets.symmetric(
                      horizontal: 14, vertical: 8),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Center(
                        child: Container(
                          width: 48.0,
                          height: 4.0,
                          margin: const EdgeInsets.only(bottom: 16.0),
                          decoration: BoxDecoration(
                            color: theme.dividerColor.withValues(alpha: 0.3),
                            borderRadius: BorderRadius.circular(2.0),
                          ),
                        ),
                      ),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text(
                            AppStrings.selectParticipants,
                            style: theme.textTheme.headlineSmall!.copyWith(
                              fontWeight: FontWeight.bold,
                              fontSize: 20.0,
                              color: theme.colorScheme.onSurface,
                            ),
                          ),
                          IconButton(
                            icon: const Icon(Icons.close, size: 28.0),
                            color: theme.colorScheme.onSurface.withValues(
                              alpha: 0.7,
                            ),
                            onPressed: () {
                              Get.back();
                              tripController.newParticipantMembersController
                                  .clear();
                              tripController.newParticipantNameController
                                  .clear();
                            },
                          ),
                        ],
                      ),
                      const SizedBox(height: 16.0),
                      if (!tripController.isVisibleAddFriendForm.value) ...[
                        TextField(
                          controller: searchController,
                          decoration: InputDecoration(
                            hintText: 'Search participants...',
                            prefixIcon: Icon(
                              Icons.search,
                              color: theme.colorScheme.onSurfaceVariant,
                            ),
                            filled: true,
                            fillColor: theme.highlightColor,
                            border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(16.0),
                              borderSide: BorderSide.none,
                            ),
                            contentPadding: const EdgeInsets.symmetric(
                              vertical: 14.0,
                              horizontal: 16.0,
                            ),
                          ),
                          style: theme.textTheme.bodyLarge,
                          onChanged:
                              (_) =>
                              tripController.availableParticipantModel
                                  .refresh(),
                        ),
                      ],
                      const SizedBox(height: 16.0),
                      if (!tripController.isVisibleAddFriendForm.value) ...[
                        GestureDetector(
                          onTap: () {
                            tripController.isVisibleAddFriendForm.value = true;
                          },
                          child: AnimatedContainer(
                            duration: const Duration(milliseconds: 200),
                            curve: Curves.easeInOut,
                            decoration: BoxDecoration(
                              color: theme.colorScheme.surfaceContainer,
                              borderRadius: BorderRadius.circular(16.0),
                              border: Border.all(
                                color: theme.colorScheme.primary.withValues(
                                  alpha: 0.2,
                                ),
                              ),
                              boxShadow: [
                                BoxShadow(
                                  color: theme.colorScheme.shadow.withValues(
                                    alpha: 0.05,
                                  ),
                                  blurRadius: 8.0,
                                  offset: const Offset(0, 2),
                                ),
                              ],
                            ),
                            child: ListTile(
                              contentPadding: const EdgeInsets.symmetric(
                                horizontal: 16.0,
                                vertical: 8.0,
                              ),
                              leading: Icon(
                                Icons.add_circle_outline,
                                color: theme.colorScheme.primary,
                                size: 28.0,
                              ),
                              title: Text(
                                AppStrings.addFriend,
                                style: theme.textTheme.bodyLarge!.copyWith(
                                  fontWeight: FontWeight.w600,
                                  color: theme.colorScheme.primary,
                                ),
                              ),
                            ),
                          ),
                        ),
                      ],

                      Flexible(
                        fit: FlexFit.loose,
                        child: NotificationListener<
                            OverscrollIndicatorNotification
                        >(
                          onNotification: (overscroll) {
                            overscroll.disallowIndicator();
                            return true;
                          },
                          child:
                          tripController.isVisibleAddFriendForm.value
                              ? tripController.isAddparticipantLoading.value
                              ? Expanded(
                            child: Center(
                              child: CircularProgressIndicator(),
                            ),
                          )
                              : Form(
                            key: tripController.addParticipantFormKey,
                            child: Stack(
                              alignment: Alignment.center,
                              children: [
                                Column(
                                  crossAxisAlignment:
                                  CrossAxisAlignment.stretch,
                                  children: [
                                    TextFormField(
                                      controller:
                                      tripController
                                          .newParticipantNameController,
                                      decoration: InputDecoration(
                                        hintText: AppStrings.nameLabel,
                                        filled: true,
                                        fillColor: theme.highlightColor,
                                        border: OutlineInputBorder(
                                          borderRadius:
                                          BorderRadius.circular(12),
                                          borderSide: BorderSide.none,
                                        ),
                                        contentPadding:
                                        const EdgeInsets.symmetric(
                                          vertical: 14,
                                          horizontal: 16,
                                        ),
                                      ),
                                      style: theme.textTheme.bodyMedium
                                          ?.copyWith(
                                        color:
                                        theme
                                            .colorScheme
                                            .onSurface,
                                        fontWeight: FontWeight.w500,
                                      ),
                                    ),
                                    const SizedBox(height: 12),
                                    TextFormField(
                                      controller:
                                      tripController
                                          .newParticipantMembersController,
                                      keyboardType:
                                      TextInputType.number,
                                      inputFormatters: [
                                        FilteringTextInputFormatter
                                            .digitsOnly,
                                      ],
                                      decoration: InputDecoration(
                                        hintText:
                                        AppStrings.memberLabel,
                                        filled: true,
                                        fillColor: theme.highlightColor,
                                        border: OutlineInputBorder(
                                          borderRadius:
                                          BorderRadius.circular(12),
                                          borderSide: BorderSide.none,
                                        ),
                                        contentPadding:
                                        const EdgeInsets.symmetric(
                                          vertical: 14,
                                          horizontal: 16,
                                        ),
                                      ),
                                      style: theme.textTheme.bodyMedium
                                          ?.copyWith(
                                        color:
                                        theme
                                            .colorScheme
                                            .onSurface,
                                        fontWeight: FontWeight.w500,
                                      ),
                                    ),
                                    const SizedBox(height: 16),
                                    SizedBox(
                                      height: 52,
                                      width: double.infinity,
                                      child: Obx(() {
                                        return Row(
                                          children: [
                                            Expanded(
                                              child: TextButton(
                                                onPressed: () {
                                                  tripController
                                                      .isVisibleAddFriendForm
                                                      .value = false;
                                                },
                                                child: Text("Cancel"),
                                              ),
                                            ),
                                            Expanded(
                                              child: TextButton(
                                                style: TextButton.styleFrom(
                                                  backgroundColor: theme
                                                      .colorScheme
                                                      .primary
                                                      .withValues(
                                                    alpha: 0.1,
                                                  ),
                                                  foregroundColor:
                                                  theme
                                                      .colorScheme
                                                      .primary,
                                                  padding:
                                                  const EdgeInsets.symmetric(
                                                    vertical: 12,
                                                  ),
                                                  shape: RoundedRectangleBorder(
                                                    borderRadius:
                                                    BorderRadius.circular(
                                                      12,
                                                    ),
                                                    side: BorderSide(
                                                      color: theme
                                                          .colorScheme
                                                          .primary
                                                          .withValues(
                                                        alpha: 0.3,
                                                      ),
                                                    ),
                                                  ),
                                                ),
                                                onPressed: () async {
                                                  if (tripController
                                                      .addParticipantFormKey
                                                      .currentState
                                                      ?.validate() ??
                                                      false) {
                                                    tripController
                                                        .isAddparticipantLoading
                                                        .value = true;
                                                    await tripController
                                                        .addNewParticipant(
                                                      context: context,
                                                      theme: theme,
                                                      participantData: {
                                                        'name':
                                                        tripController
                                                            .newParticipantNameController
                                                            .text
                                                            .trim(),
                                                        'member': int.parse(
                                                          tripController
                                                              .newParticipantMembersController
                                                              .text
                                                              .trim(),
                                                        ),
                                                      },
                                                    );
                                                    tripController
                                                        .newParticipantNameController
                                                        .clear();
                                                    tripController
                                                        .newParticipantMembersController
                                                        .clear();
                                                    tripController
                                                        .isVisibleAddFriendForm
                                                        .value = false;
                                                    tripController
                                                        .isAddparticipantLoading
                                                        .value = false;
                                                    tripController
                                                        .availableParticipantModel
                                                        .refresh();
                                                  }
                                                },
                                                child: Text(
                                                  AppStrings.addLabel,
                                                  style: theme
                                                      .textTheme
                                                      .labelLarge
                                                      ?.copyWith(
                                                    fontWeight:
                                                    FontWeight
                                                        .w600,
                                                  ),
                                                ),
                                              ),
                                            ),
                                          ],
                                        );
                                      }),
                                    ),
                                  ],
                                ),
                              ],
                            ),
                          )
                              : SingleChildScrollView(
                            child: Column(
                              children: [
                                ...List.generate(
                                    filteredFriends.length, (index,) {
                                  FriendModel friendModel =
                                  filteredFriends[index];
                                  return Padding(
                                    padding:
                                    const EdgeInsets.symmetric(
                                      vertical: 2,
                                      horizontal: 3,
                                    ),
                                    child: AnimatedContainer(
                                      duration: const Duration(
                                        milliseconds: 200,
                                      ),
                                      curve: Curves.easeInOut,
                                      decoration: BoxDecoration(
                                        color:
                                        friendModel.isSelected
                                            ? theme
                                            .colorScheme
                                            .primaryContainer
                                            .withValues(
                                          alpha: 0.1,
                                        )
                                            : theme
                                            .colorScheme
                                            .surfaceContainer,
                                        borderRadius:
                                        BorderRadius.circular(
                                          16.0,
                                        ),
                                        border: Border.all(
                                          color:
                                          friendModel.isSelected
                                              ? theme
                                              .colorScheme
                                              .primary
                                              .withValues(
                                            alpha: 0.8,
                                          )
                                              : Colors
                                              .transparent,
                                          width: 1.5,
                                        ),
                                        // boxShadow: [
                                        //   BoxShadow(
                                        //     color: theme.colorScheme.shadow
                                        //         .withValues(alpha: )(0.05),
                                        //     blurRadius: 8.0,
                                        //     offset: const Offset(0, 2),
                                        //   ),
                                        // ],
                                      ),
                                      child: ListTile(
                                        contentPadding:
                                        const EdgeInsets.symmetric(
                                          horizontal: 16.0,
                                          vertical: 8.0,
                                        ),
                                        leading: Transform.scale(
                                          scale: 1.2,
                                          child: Checkbox(
                                            value:
                                            friendModel
                                                .isSelected,
                                            onChanged: (value) {
                                              friendModel
                                                  .isSelected =
                                                  value ?? false;
                                              tripController
                                                  .availableParticipantModel
                                                  .refresh();
                                            },
                                            activeColor:
                                            theme
                                                .colorScheme
                                                .primary,
                                            checkColor:
                                            theme
                                                .colorScheme
                                                .onPrimary,
                                            shape: RoundedRectangleBorder(
                                              borderRadius:
                                              BorderRadius.circular(
                                                6.0,
                                              ),
                                            ),
                                          ),
                                        ),
                                        title: Text(
                                          friendModel
                                              .participant
                                              .name ??
                                              'Unknown',
                                          style: theme.textTheme.bodyLarge!
                                              .copyWith(
                                            fontWeight:
                                            friendModel
                                                .isSelected
                                                ? FontWeight
                                                .w600
                                                : FontWeight
                                                .normal,
                                            color:
                                            friendModel
                                                .isSelected
                                                ? theme
                                                .colorScheme
                                                .primary
                                                : theme
                                                .colorScheme
                                                .onSurface,
                                          ),
                                        ),
                                        trailing: Text(
                                          "Members: ${friendModel
                                              .participant.member}",
                                          style: theme.textTheme.bodyMedium!
                                              .copyWith(
                                            color:
                                            friendModel
                                                .isSelected
                                                ? theme
                                                .colorScheme
                                                .primary
                                                .withValues(
                                              alpha:
                                              0.8,
                                            )
                                                : theme
                                                .colorScheme
                                                .onSurfaceVariant,
                                          ),
                                        ),
                                        onTap: () {
                                          friendModel.isSelected =
                                          !friendModel
                                              .isSelected;
                                          tripController
                                              .availableParticipantModel
                                              .refresh();
                                        },
                                      ),
                                    ),
                                  );
                                }),
                                const SizedBox(height: 8.0),
                              ],
                            ),
                          ),
                        ),
                      ),
                      if (tripController
                          .validationMsgForSelectFriend
                          .value
                          .isNotEmpty)
                        Padding(
                          padding: const EdgeInsets.only(
                              top: 12.0, bottom: 16.0),
                          child: Text(
                            "* ${tripController.validationMsgForSelectFriend
                                .value}",
                            style: theme.textTheme.bodyMedium!.copyWith(
                              color: theme.colorScheme.error,
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                        ),
                      const SizedBox(height: 8.0),
                      tripController.isVisibleAddFriendForm.value ? SizedBox
                          .shrink() : SizedBox(
                        width: double.infinity,
                        child: TextButton(
                          style: TextButton.styleFrom(
                            backgroundColor: theme
                                .colorScheme
                                .primary
                                .withValues(
                              alpha: 0.1,
                            ),
                            foregroundColor:
                            theme
                                .colorScheme
                                .primary,
                            padding:
                            const EdgeInsets.symmetric(
                              vertical: 12,
                            ),
                            shape: RoundedRectangleBorder(
                              borderRadius:
                              BorderRadius.circular(
                                12,
                              ),
                              side: BorderSide(
                                color: theme
                                    .colorScheme
                                    .primary
                                    .withValues(
                                  alpha: 0.3,
                                ),
                              ),
                            ),
                          ),
                          onPressed: () {
                            tripController.addParticipantMethod(
                              context: context,
                              theme: theme,
                            );
                          },
                          child: Text(
                            AppStrings.addParticipant,
                            style: theme.textTheme.titleLarge!.copyWith(
                              color: theme.colorScheme.primary,
                            ),
                          ),
                        ),
                      ),
                      const SizedBox(height: 16.0),
                    ],
                  ),
                ),
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
    final selectedFriends = tripController.selectedParticipantModel;
    return selectedFriends.isNotEmpty
        ? Column(
      children: [
        Container(
          width: double.infinity,
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
                      style: theme.textTheme.bodyMedium!.copyWith(
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
                      style: theme.textTheme.titleMedium!.copyWith(
                        fontWeight: FontWeight.bold,
                        color: theme.colorScheme.onSurface,
                      ),
                    ),
                  ),
                  Padding(
                    padding: AppPaddings.tableCellPadding,
                    child: Container(),
                  ),
                ],
              ),
            ],
          ),
        ),
        Column(
          children: List.generate(selectedFriends.length, (index) {
            // Create a new list with the linked participant first
            final sortedFriends = List<ParticipantModel>.from(selectedFriends)
              ..sort((a, b) {
                if (a.isLinked && !b.isLinked) return -1; // Linked participant comes first
                if (!a.isLinked && b.isLinked) return 1;
                return 0; // Maintain original order for others
              });

            final participant = sortedFriends[index];

            return Container(
              width: double.infinity,
              decoration: BoxDecoration(
                color: theme.scaffoldBackgroundColor,
                borderRadius: tripController.selectedParticipantModel.length - 1 == index
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
                        child: Row(
                          children: [
                            Text(
                              participant.displayName,
                              maxLines: 1,
                              style: theme.textTheme.titleMedium!.copyWith(
                                color: theme.colorScheme.onSurface,
                              ),
                            ),
                            participant.isLinked
                                ? Padding(
                              padding: const EdgeInsets.only(left: 8),
                              child: Container(
                                decoration: BoxDecoration(
                                  borderRadius: const BorderRadius.all(Radius.circular(10)),
                                  color: theme.primaryColor.withValues(alpha: 0.5),
                                ),
                                child: Padding(
                                  padding: const EdgeInsets.symmetric(horizontal: 3.0),
                                  child: Text(
                                    'me',
                                    style: theme.textTheme.labelMedium!.copyWith(
                                      color: theme.colorScheme.onPrimary,
                                    ),
                                  ),
                                ),
                              ),
                            )
                                : const SizedBox.shrink(),
                          ],
                        ),
                      ),
                      Padding(
                        padding: AppPaddings.tableCellPadding,
                        child: Center(
                          child: Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 10,
                              vertical: 6,
                            ),
                            decoration: BoxDecoration(
                              color: theme.highlightColor.withValues(
                                alpha: 0.2,
                              ),
                              borderRadius: BorderRadius.circular(8),
                            ),
                            child: TextFormField(
                              initialValue: "${participant.customMemberCount ?? participant.member ?? 1.0}",
                              keyboardType: const TextInputType.numberWithOptions(decimal: true),
                              style: theme.textTheme.titleMedium!.copyWith(
                                color: theme.colorScheme.onSurface,
                              ),
                              decoration: const InputDecoration(
                                border: InputBorder.none,
                                isDense: true,
                                contentPadding: EdgeInsets.zero,
                              ),
                              onChanged: (value) {
                                final parsedValue = double.tryParse(value);
                                if (parsedValue != null && parsedValue > 0) {
                                  participant.customMemberCount = parsedValue;
                                  tripController.selectedParticipantModel.refresh();
                                }
                              },
                            ),
                          ),
                        ),
                      ),
                      Padding(
                        padding: AppPaddings.tableCellPadding,
                        child: GestureDetector(
                          child: Icon(
                            Icons.remove_circle_outline,
                            color: Colors.red.shade600,
                            size: AppSizes.mediumIcon,
                          ),
                          onTap: () {
                            tripController.removeFromParticipantList(
                              context: context,
                              theme: theme,
                              participantReferenceId: participant.referenceId,
                              argumentData: argumentData,
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