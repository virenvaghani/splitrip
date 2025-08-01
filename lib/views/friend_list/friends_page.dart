import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:splitrip/controller/appPageController/app_page_controller.dart';
import 'package:splitrip/controller/trip/trip_controller.dart';
import 'package:splitrip/widgets/myappbar.dart';
import '../../controller/friend/friend_controller.dart';
import '../../data/constants.dart';
import '../../model/friend/friend_model.dart';

class FriendsPage extends StatelessWidget {
  FriendsPage({super.key});

  final FriendController friendController = Get.find<FriendController>();

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return GetX<FriendController>(
      builder: (controller) {
        final token = controller.authToken.value;

        if (token == null) {
          return Scaffold(
            appBar: _buildAppBar(
              context,
              friendController,
              theme,
              showActions: false,
            ),
            body: _unauthenticatedState(theme),
          );
        }

        if (controller.isLoading.value) {
          return const Scaffold(
            body: Center(child: CircularProgressIndicator()),
          );
        }

        if (controller.errorMessage.isNotEmpty) {
          return Scaffold(
            appBar: _buildAppBar(
              context,
              friendController,
              theme,
              showActions: true,
            ),
            body: _stateMessage(
              controller.errorMessage.value,
              theme.colorScheme.error,
              context,
            ),
          );
        }

        if (Kconstant.friendModelList.isEmpty) {
          return Scaffold(
            appBar: _buildAppBar(
              context,
              friendController,
              theme,
              showActions: true,
            ),
            body: _emptyState(theme, friendController),
          );
        }

        return Scaffold(
          appBar: _buildAppBar(
            context,
            friendController,
            theme,
            showActions: true,
          ),
          body: ListView.separated(
            padding: const EdgeInsets.fromLTRB(16, 12, 16, 12),
            itemCount: Kconstant.friendModelList.length,
            separatorBuilder: (_, _) => const SizedBox(height: 8),
            itemBuilder: (context, index) {
              final friend = Kconstant.friendModelList[index];
              return _buildFriendTile(context, friend, theme, friendController);
            },
          ),
        );
      },
    );
  }
}

Widget _buildFriendTile(
  BuildContext context,
  FriendModel friend,
  ThemeData theme,
  FriendController friendController,
) {
  final participant = friend.participant;
  final participatedTrips = participant.participatedTrips;
  final ValueNotifier<bool> isExpanded = ValueNotifier(false);

  return Padding(
    padding: const EdgeInsets.symmetric(horizontal: 4),
    child: AnimatedContainer(
      duration: const Duration(milliseconds: 200),
      curve: Curves.easeInOut,
      decoration: BoxDecoration(
        color: theme.colorScheme.surfaceContainer,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: theme.colorScheme.primary.withValues(alpha: 0.15),
          width: 1.2,
        ),
        boxShadow: [
          BoxShadow(
            color: theme.shadowColor.withValues(alpha: 0.05),
            blurRadius: 6,
            offset: const Offset(0, 3),
          ),
        ],
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(16),
        child: Material(
          color: Colors.transparent,
          child: InkWell(
            onTap: () => isExpanded.value = !isExpanded.value,
            borderRadius: BorderRadius.circular(16),
            onLongPress: () {
              showDeleteDialouge(context, theme, friend, friendController);
            },
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  /// Header
                  Row(
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: [
                      CircleAvatar(
                        radius: 22,
                        backgroundColor: theme.colorScheme.primary.withValues(
                          alpha: 0.1,
                        ),
                        child: Text(
                          participant.name?.substring(0, 1).toUpperCase() ??
                              '?',
                          style: theme.textTheme.titleLarge?.copyWith(
                            color: theme.colorScheme.primary,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Text(
                          participant.name ?? 'Unknown',
                          style: theme.textTheme.titleMedium?.copyWith(
                            fontWeight: FontWeight.w600,
                            color: theme.colorScheme.onSurface,
                          ),
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 10,
                          vertical: 6,
                        ),
                        decoration: BoxDecoration(
                          color: theme.colorScheme.primary.withValues(
                            alpha: 0.08,
                          ),
                          borderRadius: BorderRadius.circular(10),
                        ),
                        child: Text(
                          '${participatedTrips?.length ?? 0} Trip${participatedTrips?.length == 1 ? '' : 's'}',
                          style: theme.textTheme.labelMedium?.copyWith(
                            color: theme.colorScheme.primary,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ),
                      SizedBox(width: 20),
                      ValueListenableBuilder<bool>(
                        valueListenable: isExpanded,
                        builder: (_, expanded, _) {
                          return AnimatedRotation(
                            turns: expanded ? 0.5 : 0.0,
                            duration: const Duration(milliseconds: 200),
                            child: Icon(
                              Icons.expand_more,
                              size: 22,
                              color: theme.iconTheme.color?.withValues(
                                alpha: 0.7,
                              ),
                            ),
                          );
                        },
                      ),
                    ],
                  ),

                  /// Trip Expansion
                  const SizedBox(height: 8),
                  ValueListenableBuilder<bool>(
                    valueListenable: isExpanded,
                    builder: (context, expanded, _) {
                      return AnimatedCrossFade(
                        duration: const Duration(milliseconds: 300),
                        crossFadeState:
                            expanded
                                ? CrossFadeState.showSecond
                                : CrossFadeState.showFirst,
                        firstChild: const SizedBox.shrink(),
                        secondChild: Column(
                          children:
                              participatedTrips?.map((trip) {
                                final ValueNotifier<bool> isTripExpanded =
                                    ValueNotifier(false);
                                return Padding(
                                  padding: const EdgeInsets.only(top: 8),
                                  child: Container(
                                    decoration: BoxDecoration(
                                      color: theme.colorScheme.primary
                                          .withValues(alpha: 0.07),
                                      borderRadius: BorderRadius.circular(12),
                                      border: Border.all(
                                        color: theme.primaryColor.withValues(
                                          alpha: 0.3,
                                        ),
                                      ),
                                    ),
                                    child: InkWell(
                                      onTap:
                                          () =>
                                              isTripExpanded.value =
                                                  !isTripExpanded.value,
                                      borderRadius: BorderRadius.circular(12),
                                      child: Padding(
                                        padding: const EdgeInsets.symmetric(
                                          horizontal: 12,
                                        ),
                                        child: Column(
                                          crossAxisAlignment:
                                              CrossAxisAlignment.start,
                                          children: [
                                            Row(
                                              children: [
                                                Text(
                                                  trip.tripEmoji,
                                                  style:
                                                      theme
                                                          .textTheme
                                                          .titleLarge,
                                                ),
                                                const SizedBox(width: 8),
                                                Expanded(
                                                  child: Text(
                                                    trip.tripName.isNotEmpty
                                                        ? trip.tripName
                                                        : "Unnamed Trip",
                                                    style:
                                                        theme
                                                            .textTheme
                                                            .bodyLarge,
                                                  ),
                                                ),
                                                IconButton(
                                                  icon: Icon(
                                                    Icons.open_in_new,
                                                    color: theme.primaryColor
                                                        .withValues(alpha: 0.7),
                                                  ),
                                                  onPressed: () {
                                                    Get.toNamed(
                                                      PageConstant
                                                          .tripDetailScreen,
                                                      arguments: {
                                                        'tripId': trip.id,
                                                      },
                                                    );
                                                  },
                                                  tooltip: 'Open Trip',
                                                  splashRadius: 20,
                                                ),
                                              ],
                                            ),
                                            ValueListenableBuilder<bool>(
                                              valueListenable: isTripExpanded,
                                              builder: (_, tripExpanded, _) {
                                                return AnimatedCrossFade(
                                                  duration: const Duration(
                                                    milliseconds: 200,
                                                  ),
                                                  crossFadeState:
                                                      tripExpanded
                                                          ? CrossFadeState
                                                              .showSecond
                                                          : CrossFadeState
                                                              .showFirst,
                                                  firstChild:
                                                      const SizedBox.shrink(),
                                                  secondChild: Column(
                                                    crossAxisAlignment:
                                                        CrossAxisAlignment
                                                            .start,
                                                    children: [
                                                      const SizedBox(height: 8),
                                                      Text(
                                                        "Linked Users",
                                                        style: theme
                                                            .textTheme
                                                            .labelLarge
                                                            ?.copyWith(
                                                              fontWeight:
                                                                  FontWeight
                                                                      .w600,
                                                            ),
                                                      ),
                                                      const SizedBox(height: 6),
                                                      ...(trip.linkedUsers?.map((
                                                            user,
                                                          ) {
                                                            return Padding(
                                                              padding:
                                                                  const EdgeInsets.symmetric(
                                                                    vertical: 4,
                                                                  ),
                                                              child: Row(
                                                                children: [
                                                                  CircleAvatar(
                                                                    radius: 18,
                                                                    backgroundImage:
                                                                        user.image.isNotEmpty
                                                                            ? NetworkImage(
                                                                              user.image,
                                                                            )
                                                                            : null,
                                                                    child:
                                                                        user.image.isEmpty
                                                                            ? const Icon(
                                                                              Icons.person_outline,
                                                                            )
                                                                            : null,
                                                                  ),
                                                                  const SizedBox(
                                                                    width: 8,
                                                                  ),
                                                                  Expanded(
                                                                    child: Text(
                                                                      user.name.isNotEmpty
                                                                          ? user
                                                                              .name
                                                                          : 'Unknown User',
                                                                      style:
                                                                          theme
                                                                              .textTheme
                                                                              .bodyMedium,
                                                                    ),
                                                                  ),
                                                                ],
                                                              ),
                                                            );
                                                          }).toList() ??
                                                          [
                                                            Text(
                                                              'No linked users',
                                                              style: theme
                                                                  .textTheme
                                                                  .bodySmall
                                                                  ?.copyWith(
                                                                    color:
                                                                        theme
                                                                            .disabledColor,
                                                                  ),
                                                            ),
                                                          ]),
                                                    ],
                                                  ),
                                                );
                                              },
                                            ),
                                          ],
                                        ),
                                      ),
                                    ),
                                  ),
                                );
                              }).toList() ??
                              [
                                Padding(
                                  padding: const EdgeInsets.only(top: 12),
                                  child: Text(
                                    'No participated trips',
                                    style: theme.textTheme.bodySmall?.copyWith(
                                      color: theme.disabledColor,
                                    ),
                                  ),
                                ),
                              ],
                        ),
                      );
                    },
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    ),
  );
}

void showDeleteDialouge(
  BuildContext context,
  ThemeData theme,
  FriendModel friend,
  FriendController friendController,
) {
  showGeneralDialog(
    context: context,
    barrierDismissible: true,
    barrierLabel: 'Dismiss',
    transitionDuration: const Duration(milliseconds: 200),
    transitionBuilder: (context, animation, secondaryAnimation, child) {
      return ScaleTransition(
        scale: CurvedAnimation(parent: animation, curve: Curves.easeOut),
        child: child,
      );
    },
    pageBuilder:
        (context, _, _) => GetX<FriendController>(builder: (controller) {
          return AlertDialog(
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(16),
            ),
            backgroundColor: theme.colorScheme.surfaceContainer,
            elevation: 4,
            contentPadding: const EdgeInsets.all(20),
            content: Semantics(
              label: 'Confirm deletion of friend ${friend.participant.name}',
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                crossAxisAlignment: CrossAxisAlignment.center,
                mainAxisSize: MainAxisSize.min,
                children: [
                  Semantics(
                    label: 'Delete confirmation warning icon',
                    child: Icon(
                      Icons.warning_amber_rounded,
                      color: theme.colorScheme.error.withValues(alpha: 0.8),
                      size: 40,
                    ),
                  ),
                  const SizedBox(height: 12),
                  Semantics(
                    label:
                    'Delete confirmation message for ${friend.participant.name}',
                    child: Text(
                      'Are you sure you want to delete "${friend.participant.name}"?',
                      style: theme.textTheme.bodyLarge?.copyWith(
                        color: theme.colorScheme.onSurface,
                        fontWeight: FontWeight.w600,
                        letterSpacing: 0.2,
                      ),
                      textAlign: TextAlign.center,
                    ),
                  ),
                  const SizedBox(height: 12),
                ],
              ),
            ),
            actions: [
              TextButton(
                onPressed: () => Get.back(),
                style: TextButton.styleFrom(
                  foregroundColor: theme.colorScheme.onSurface.withValues(
                    alpha: 0.6,
                  ),
                  padding: const EdgeInsets.symmetric(
                    horizontal: 16,
                    vertical: 12,
                  ),
                ),
                child: Text(
                  'Cancel',
                  style: theme.textTheme.labelLarge?.copyWith(
                    color: theme.hintColor,
                  ),
                ),
              ),
              TextButton(
                onPressed:friendController.isDeleteBoxIsLoading.value
                    ? null
                    : () async {
                  await friendController.deleteParticipant(friend);
                  Get.back();
                },
                child: friendController.isDeleteBoxIsLoading.value
                    ? SizedBox(
                  width: 20,
                  height: 20,
                  child: CircularProgressIndicator(
                    strokeWidth: 2,
                    color: theme.colorScheme.error,
                  ),
                )
                    :Text(
                  "Delete",
                  style: TextStyle(color: theme.colorScheme.error),
                ),
              ),
            ],
          );
        },)
  );
}

PreferredSizeWidget _buildAppBar(
  BuildContext context,
  FriendController friendController,
  ThemeData theme, {
  required bool showActions,
}) {
  return CustomAppBar(
    title: "Friends",
    centerTitle: false,
    actions:
        showActions
            ? [
              IconButton(
                icon: Icon(Icons.refresh, color: theme.colorScheme.primary),
                onPressed:
                    () =>
                        Get.find<FriendController>().fetchLinkedParticipants(),
              ),
              IconButton(
                icon: Icon(
                  Icons.person_add_alt_1,
                  color: theme.colorScheme.primary,
                ),
                onPressed: () {
                  _addFriend(
                    context: context,
                    theme: theme,
                    friendController: friendController,
                  );
                },
              ),
            ]
            : [],
  );
}

Widget _stateMessage(String text, Color color, BuildContext context) {
  return Center(
    child: Padding(
      padding: const EdgeInsets.all(24),
      child: Text(
        text,
        textAlign: TextAlign.center,
        style: Theme.of(context).textTheme.bodyLarge?.copyWith(
          color: color,
          fontWeight: FontWeight.w500,
        ),
      ),
    ),
  );
}

Widget _emptyState(ThemeData theme, FriendController friendController) {
  return Container(
    margin: const EdgeInsets.symmetric(horizontal: 24, vertical: 32),
    padding: const EdgeInsets.all(28),
    decoration: _boxDecoration(theme),
    child: Column(
      crossAxisAlignment: CrossAxisAlignment.center,
      mainAxisSize: MainAxisSize.min,
      children: [
        Text(
          "No Friends Added",
          style: theme.textTheme.headlineSmall?.copyWith(
            fontWeight: FontWeight.bold,
          ),
        ),
        const SizedBox(height: 12),
        Text(
          "You haven’t added any friends yet.",
          style: theme.textTheme.bodyLarge,
          textAlign: TextAlign.center,
        ),
        const SizedBox(height: 8),
        Text(
          "Tap the button below to add your first friend.",
          style: theme.textTheme.bodyMedium,
          textAlign: TextAlign.center,
        ),
        const SizedBox(height: 24),
        TextButton(
          onPressed:
              () => _addFriend(
                context: Get.context!,
                friendController: friendController,
                theme: theme,
              ),
          style: _buttonStyle(theme),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text("Add Friend", style: theme.textTheme.labelLarge),
              const SizedBox(width: 8),
              Icon(Icons.person_add_alt_1, size: 16),
            ],
          ),
        ),
      ],
    ),
  );
}

Widget _unauthenticatedState(ThemeData theme) {
  return Container(
    margin: const EdgeInsets.symmetric(horizontal: 24, vertical: 32),
    padding: const EdgeInsets.all(28),
    decoration: _boxDecoration(theme),
    child: Column(
      crossAxisAlignment: CrossAxisAlignment.center,
      mainAxisSize: MainAxisSize.min,
      children: [
        Text(
          "Welcome!",
          style: theme.textTheme.headlineSmall?.copyWith(
            fontWeight: FontWeight.bold,
          ),
        ),
        const SizedBox(height: 12),
        Text(
          "You need to sign in to manage friends.",
          style: theme.textTheme.bodyLarge,
          textAlign: TextAlign.center,
        ),
        const SizedBox(height: 24),
        TextButton(
          onPressed: () => Get.find<AppPageController>().pageIndex.value = 2,
          style: _buttonStyle(theme),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text("Sign In", style: theme.textTheme.labelLarge),
              const SizedBox(width: 8),
              Icon(Icons.login, size: 16),
            ],
          ),
        ),
      ],
    ),
  );
}

BoxDecoration _boxDecoration(ThemeData theme) {
  return BoxDecoration(
    color: theme.cardTheme.color,
    borderRadius: BorderRadius.circular(16),
    gradient: LinearGradient(
      colors: [
        theme.colorScheme.primary.withValues(alpha: 0.05),
        theme.colorScheme.secondary.withValues(alpha: 0.05),
      ],
      begin: Alignment.topLeft,
      end: Alignment.bottomRight,
    ),
    border: Border.all(color: theme.colorScheme.primary.withValues(alpha: 0.2)),
    boxShadow: [
      BoxShadow(
        color: theme.colorScheme.onSurface.withValues(alpha: 0.05),
        blurRadius: 4,
        offset: const Offset(0, 2),
      ),
    ],
  );
}

ButtonStyle _buttonStyle(ThemeData theme) {
  return TextButton.styleFrom(
    backgroundColor: theme.colorScheme.primary.withValues(alpha: 0.1),
    foregroundColor: theme.colorScheme.primary,
    padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
    shape: RoundedRectangleBorder(
      borderRadius: BorderRadius.circular(8),
      side: BorderSide(color: theme.colorScheme.primary.withValues(alpha: 0.3)),
    ),
    splashFactory: NoSplash.splashFactory,
    tapTargetSize: MaterialTapTargetSize.shrinkWrap,
  );
}

void _addFriend({
  required BuildContext context,
  required ThemeData theme,
  required FriendController friendController,
}) {
  showGeneralDialog(
    context: context,
    barrierDismissible: true,
    barrierLabel: 'Dismiss',
    barrierColor: Colors.black.withValues(
      alpha: 0.5,
    ), // Darker barrier for focus
    transitionDuration: const Duration(milliseconds: 300),
    transitionBuilder: (context, animation, secondaryAnimation, child) {
      return FadeTransition(
        opacity: CurvedAnimation(parent: animation, curve: Curves.easeOutCubic),
        child: SlideTransition(
          position: Tween<Offset>(
            begin: const Offset(0, 0.1),
            end: Offset.zero,
          ).animate(
            CurvedAnimation(parent: animation, curve: Curves.easeOutCubic),
          ),
          child: ScaleTransition(
            scale: Tween<double>(begin: 0.85, end: 1.0).animate(
              CurvedAnimation(parent: animation, curve: Curves.easeOutCubic),
            ),
            child: child,
          ),
        ),
      );
    },
    pageBuilder:
        (context, _, _) => GetX<TripController>(
          builder: (tripController) {
            return Dialog(
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(20),
              ), // Softer corners
              backgroundColor: theme.colorScheme.surface,
              elevation: 8, // Stronger shadow for depth
              child: AnimatedContainer(
                duration: const Duration(milliseconds: 200),
                padding: const EdgeInsets.all(24), // Increased padding
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Stack(
                  children: [
                    Column(
                      mainAxisSize: MainAxisSize.min,
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            Icon(
                              Icons.person_add_rounded,
                              color: theme.colorScheme.primary,
                              size: 28,
                            ),
                            const SizedBox(width: 12),
                            Semantics(
                              label: 'Add New Friend Dialog Title',
                              child: Text(
                                "Add New Friend",
                                style: theme.textTheme.headlineSmall?.copyWith(
                                  fontWeight: FontWeight.bold,
                                  color: theme.colorScheme.onSurface,
                                  letterSpacing: 0.5,
                                ),
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 20),
                        Semantics(
                          label: 'Friend Name Input',
                          child: TextField(
                            controller:
                                tripController.newParticipantNameController,
                            style: theme.textTheme.bodyLarge?.copyWith(
                              color: theme.colorScheme.onSurface,
                            ),
                            decoration: InputDecoration(
                              labelText: 'Friend Name',
                              labelStyle: TextStyle(
                                color: theme.colorScheme.onSurface.withValues(
                                  alpha: 0.6,
                                ),
                              ),
                              prefixIcon: Icon(
                                Icons.person_outline,
                                color: theme.colorScheme.primary,
                              ),
                              filled: true,
                              fillColor: theme.primaryColor.withValues(
                                alpha: 0.07,
                              ),
                              border: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(12),
                                borderSide: BorderSide.none,
                              ),
                              focusedBorder: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(12),
                                borderSide: BorderSide(
                                  color: theme.colorScheme.primary,
                                  width: 2,
                                ),
                              ),
                              contentPadding: const EdgeInsets.symmetric(
                                horizontal: 16,
                                vertical: 12,
                              ),
                            ),
                          ),
                        ),
                        const SizedBox(height: 16),
                        Semantics(
                          label: 'Number of Members Input',
                          child: TextField(
                            controller:
                                tripController.newParticipantMembersController,
                            style: theme.textTheme.bodyLarge?.copyWith(
                              color: theme.colorScheme.onSurface,
                            ),
                            keyboardType: TextInputType.numberWithOptions(
                              decimal: true,
                            ),
                            decoration: InputDecoration(
                              labelText: 'Number of Members',
                              labelStyle: TextStyle(
                                color: theme.colorScheme.onSurface.withValues(
                                  alpha: 0.6,
                                ),
                              ),
                              prefixIcon: Icon(
                                Icons.group_outlined,
                                color: theme.colorScheme.primary,
                              ),
                              filled: true,
                              fillColor: theme.primaryColor.withValues(
                                alpha: 0.07,
                              ),
                              border: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(12),
                                borderSide: BorderSide.none,
                              ),
                              focusedBorder: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(12),
                                borderSide: BorderSide(
                                  color: theme.colorScheme.primary,
                                  width: 2,
                                ),
                              ),
                              contentPadding: const EdgeInsets.symmetric(
                                horizontal: 16,
                                vertical: 12,
                              ),
                            ),
                          ),
                        ),
                        const SizedBox(height: 24),
                        Row(
                          children: [
                            Expanded(
                              child: Semantics(
                                label: 'Cancel Button',
                                child: TextButton(
                                  onPressed: () {
                                    Get.back();
                                    tripController.newParticipantNameController
                                        .clear();
                                    tripController
                                        .newParticipantMembersController
                                        .clear();
                                  },
                                  style: TextButton.styleFrom(
                                    backgroundColor:
                                        theme
                                            .colorScheme
                                            .surfaceContainerHighest,
                                    foregroundColor:
                                        theme.colorScheme.onSurface,
                                    padding: const EdgeInsets.symmetric(
                                      horizontal: 16,
                                      vertical: 12,
                                    ),
                                    shape: RoundedRectangleBorder(
                                      borderRadius: BorderRadius.circular(12),
                                    ),
                                  ).copyWith(
                                    overlayColor: WidgetStateProperty.all(
                                      theme.colorScheme.onSurface.withValues(
                                        alpha: 0.1,
                                      ),
                                    ),
                                  ),
                                  child: Text(
                                    'Cancel',
                                    style: theme.textTheme.labelLarge?.copyWith(
                                      fontWeight: FontWeight.w600,
                                      color: theme.colorScheme.onSurface,
                                    ),
                                  ),
                                ),
                              ),
                            ),
                            const SizedBox(width: 12),
                            Expanded(
                              child: _customDialogButton(
                                label: "Add Friend",
                                onPressed: () async {
                                  final name =
                                      tripController
                                          .newParticipantNameController
                                          .text
                                          .trim();
                                  final members =
                                      double.tryParse(
                                        tripController
                                            .newParticipantMembersController
                                            .text
                                            .trim(),
                                      ) ??
                                      0;

                                  friendController
                                      .isAddParticipantisLoading
                                      .value = true;
                                  await tripController.addNewParticipant(
                                    context: context,
                                    theme: theme,
                                    participantData: {
                                      'name': name,
                                      'member': members,
                                    },
                                  );
                                  friendController
                                      .isAddParticipantisLoading
                                      .value = false;
                                  tripController.newParticipantNameController
                                      .clear();
                                  tripController.newParticipantMembersController
                                      .clear();
                                  Get.back();
                                },
                                theme: theme,
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                    if (tripController.isAddparticipantLoading.value)
                      Positioned.fill(
                        child: Container(
                          color: theme.colorScheme.surface,
                          child: Center(
                            child: CircularProgressIndicator(
                              valueColor: AlwaysStoppedAnimation<Color>(
                                theme.colorScheme.primary,
                              ),
                              strokeWidth: 3,
                            ),
                          ),
                        ),
                      ),
                  ],
                ),
              ),
            );
          },
        ),
  );
}

Widget _customDialogButton({
  required String label,
  required VoidCallback onPressed,
  required ThemeData theme,
  Color? backgroundColor,
  Color? textColor,
  Color? borderSideColor,
}) {
  return TextButton(
    onPressed: onPressed,
    style: TextButton.styleFrom(
      backgroundColor:
          backgroundColor != null
              ? backgroundColor.withValues(alpha: 0.1)
              : theme.colorScheme.primary.withValues(alpha: 0.1),
      foregroundColor: textColor ?? theme.colorScheme.primary,
      padding: const EdgeInsets.symmetric(vertical: 12),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
        side: BorderSide(
          color:
              borderSideColor != null
                  ? borderSideColor.withValues(alpha: 0.3)
                  : theme.colorScheme.primary.withValues(alpha: 0.3),
        ),
      ),
    ),
    child: Text(
      label,
      style: theme.textTheme.labelLarge?.copyWith(
        fontWeight: FontWeight.w600,
        color: textColor ?? theme.colorScheme.primary,
      ),
    ),
  );
}
