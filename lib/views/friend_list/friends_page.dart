import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';
import 'package:splitrip/controller/appPageController/app_page_controller.dart';
import 'package:splitrip/controller/trip/trip_controller.dart';
import 'package:splitrip/widgets/myappbar.dart';
import '../../controller/friend/friend_controller.dart';
import '../../model/friend/friend_model.dart';

class FriendsPage extends StatelessWidget {
  FriendsPage({super.key});

  final FriendController controller = Get.find<FriendController>();

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Obx(() {
      final token = controller.authToken.value;

      if (token == null) {
        return Scaffold(
          appBar: _buildAppBar(context, theme, showActions: false),
          body: _unauthenticatedState(theme),
        );
      }

      if (controller.isLoading.value) {
        return const Scaffold(body: Center(child: CircularProgressIndicator()));
      }

      if (controller.errorMessage.isNotEmpty) {
        return Scaffold(
          appBar: _buildAppBar(context, theme, showActions: true),
          body: _stateMessage(
            controller.errorMessage.value,
            theme.colorScheme.error,
            context,
          ),
        );
      }

      if (controller.friendsList.isEmpty) {
        return Scaffold(
          appBar: _buildAppBar(context, theme, showActions: true),
          body: _emptyState(theme),
        );
      }

      return Scaffold(
        appBar: _buildAppBar(context, theme, showActions: true),
        body: Obx(() {
          if (controller.isLoading.value) {
            return const Center(child: CircularProgressIndicator());
          }

          if (controller.friendsList.isEmpty) {
            return const Center(child: Text("No participants found."));
          }

          return ListView.separated(
            padding: const EdgeInsets.fromLTRB(16, 16, 16, 32),
            itemCount: controller.friendsList.length,
            separatorBuilder: (_, __) => const SizedBox(height: 12),
            itemBuilder: (context, index) {
              final friend = controller.friendsList[index];
              return _buildFriendTile(friend, theme);
            },
          );
        }),
      );
    });
  }
}

Widget _buildFriendTile(FriendModel friend, ThemeData theme) {
  final participant = friend.participant;
  final participatedTrips = participant.participatedTrips;
  final ValueNotifier<bool> isExpanded = ValueNotifier(false);

  return Padding(
    padding: const EdgeInsets.symmetric(vertical: 6, horizontal: 8),
    child: Container(
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [
            theme.colorScheme.primary.withOpacity(0.1),
            theme.colorScheme.secondary.withOpacity(0.1),
          ],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: theme.colorScheme.primary.withOpacity(0.3),
          width: 1.5,
        ),
        boxShadow: [
          BoxShadow(
            color: theme.colorScheme.onSurface.withOpacity(0.1),
            blurRadius: 8,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(16),
        child: Material(
          color: Colors.transparent,
          child: InkWell(
            onTap: () => isExpanded.value = !isExpanded.value,
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      CircleAvatar(
                        radius: 24,
                        backgroundColor: theme.colorScheme.primary.withOpacity(0.2),
                        child: Text(
                          participant.name != null
                              ? participant.name![0].toUpperCase()
                              : "?",
                          style: theme.textTheme.titleLarge?.copyWith(
                            color: theme.colorScheme.primary,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Text(
                          participant.name != null ? participant.name.toString() : "Unknown",
                          style: theme.textTheme.titleMedium?.copyWith(
                            fontWeight: FontWeight.w600,
                            color: theme.colorScheme.onSurface,
                          ),
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                      ValueListenableBuilder<bool>(
                        valueListenable: isExpanded,
                        builder: (context, expanded, _) {
                          return AnimatedContainer(
                            duration: const Duration(milliseconds: 200),
                            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                            decoration: BoxDecoration(
                              color: theme.colorScheme.primary.withOpacity(0.2),
                              borderRadius: BorderRadius.circular(10),
                              border: Border.all(
                                color: theme.colorScheme.primary.withOpacity(0.4),
                              ),
                            ),
                            child: Text(
                              '${participatedTrips!.length} Trip${participatedTrips.length == 1 ? '' : 's'}',
                              style: theme.textTheme.labelMedium?.copyWith(
                                color: theme.colorScheme.primary,
                                fontWeight: FontWeight.w700,
                                fontSize: 12,
                              ),
                            ),
                          );
                        },
                      ),
                    ],
                  ),
                  ValueListenableBuilder<bool>(
                    valueListenable: isExpanded,
                    builder: (context, expanded, _) {
                      return AnimatedCrossFade(
                        firstChild: const SizedBox.shrink(),
                        secondChild: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const SizedBox(height: 12),
                            if (participatedTrips != null)
                              ...participatedTrips.asMap().entries.map((entry) {
                                final trip = entry.value;
                                final ValueNotifier<bool> isTripExpanded = ValueNotifier(false);
                                return Padding(
                                  padding: const EdgeInsets.only(bottom: 12),
                                  child: Container(
                                    decoration: BoxDecoration(
                                      color: theme.colorScheme.surface.withOpacity(0.8),
                                      borderRadius: BorderRadius.circular(12),
                                      border: Border.all(
                                        color: theme.colorScheme.primary.withOpacity(0.2),
                                      ),
                                    ),
                                    child: Material(
                                      color: Colors.transparent,
                                      child: InkWell(
                                        onTap: () => isTripExpanded.value = !isTripExpanded.value,
                                        borderRadius: BorderRadius.circular(12),
                                        child: Padding(
                                          padding: const EdgeInsets.all(12),
                                          child: Column(
                                            crossAxisAlignment: CrossAxisAlignment.start,
                                            children: [
                                              Row(
                                                children: [
                                                  Icon(
                                                    Icons.card_travel,
                                                    size: 22,
                                                    color: theme.colorScheme.primary,
                                                  ),
                                                  const SizedBox(width: 8),
                                                  Expanded(
                                                    child: Text(
                                                      trip.tripName.isNotEmpty ? trip.tripName : "Unnamed Trip",
                                                      style: theme.textTheme.bodyLarge?.copyWith(
                                                        fontWeight: FontWeight.w600,
                                                        color: theme.colorScheme.onSurface,
                                                      ),
                                                      overflow: TextOverflow.ellipsis,
                                                    ),
                                                  ),
                                                ],
                                              ),
                                              ValueListenableBuilder<bool>(
                                                valueListenable: isTripExpanded,
                                                builder: (context, tripExpanded, _) {
                                                  return AnimatedCrossFade(
                                                    firstChild: const SizedBox.shrink(),
                                                    secondChild: Column(
                                                      crossAxisAlignment: CrossAxisAlignment.start,
                                                      children: [
                                                        const SizedBox(height: 8),
                                                        Divider(
                                                          color: theme.colorScheme.primary.withOpacity(0.2),
                                                          thickness: 1,
                                                        ),
                                                        const SizedBox(height: 8),
                                                        Text(
                                                          'Linked Users:',
                                                          style: theme.textTheme.bodyMedium?.copyWith(
                                                            fontWeight: FontWeight.w600,
                                                            color: theme.colorScheme.primary,
                                                          ),
                                                        ),
                                                        const SizedBox(height: 4),
                                                        if (trip.linkedUsers != null)
                                                          ...trip.linkedUsers!.map((user) {
                                                            return Padding(
                                                              padding: const EdgeInsets.only(left: 16, bottom: 4),
                                                              child: Row(
                                                                children: [
                                                                  CircleAvatar(
                                                                    backgroundImage: NetworkImage(user.image.isNotEmpty ? user.image : ''),
                                                                    radius: 18,
                                                                  ),
                                                                  const SizedBox(width: 8),
                                                                  Expanded(
                                                                    child: Text(
                                                                      user.name.isNotEmpty ? user.name : "Unknown User",
                                                                      style: theme.textTheme.bodyMedium?.copyWith(
                                                                        color: theme.colorScheme.onSurface.withOpacity(0.8),
                                                                        fontSize: 14,
                                                                      ),
                                                                      overflow: TextOverflow.ellipsis,
                                                                    ),
                                                                  ),
                                                                ],
                                                              ),
                                                            );
                                                          }).toList()
                                                        else
                                                          Padding(
                                                            padding: const EdgeInsets.only(left: 16),
                                                            child: Text(
                                                              'No linked users',
                                                              style: theme.textTheme.bodySmall?.copyWith(
                                                                color: theme.colorScheme.onSurface.withOpacity(0.5),
                                                                fontSize: 13,
                                                              ),
                                                            ),
                                                          ),
                                                      ],
                                                    ),
                                                    crossFadeState: tripExpanded
                                                        ? CrossFadeState.showSecond
                                                        : CrossFadeState.showFirst,
                                                    duration: const Duration(milliseconds: 200),
                                                    alignment: Alignment.topLeft,
                                                  );
                                                },
                                              ),
                                            ],
                                          ),
                                        ),
                                      ),
                                    ),
                                  ),
                                );
                              }).toList()
                            else
                              Padding(
                                padding: const EdgeInsets.only(top: 8),
                                child: Text(
                                  'No participated trips',
                                  style: theme.textTheme.bodySmall?.copyWith(
                                    color: theme.colorScheme.onSurface.withOpacity(0.5),
                                    fontSize: 13,
                                  ),
                                ),
                              ),
                          ],
                        ),
                        crossFadeState: expanded
                            ? CrossFadeState.showSecond
                            : CrossFadeState.showFirst,
                        duration: const Duration(milliseconds: 300),
                        alignment: Alignment.topLeft,
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

PreferredSizeWidget _buildAppBar(
    BuildContext context,
    ThemeData theme, {
      required bool showActions,
    }) {
  return CustomAppBar(
    title: "Friends",
    centerTitle: false,
    actions: showActions
        ? [
      IconButton(
        icon: Icon(Icons.refresh, color: theme.colorScheme.primary),
        onPressed: () => Get.find<FriendController>().fetchLinkedParticipants(),
      ),
      IconButton(
        icon: Icon(
          Icons.person_add_alt_1,
          color: theme.colorScheme.primary,
        ),
        onPressed: () {
          _addFriend(context: context, theme: theme);
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

Widget _emptyState(ThemeData theme) {
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
          onPressed: () => _addFriend(context: Get.context!, theme: theme),
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

void _addFriend({required BuildContext context, required ThemeData theme}) {
  TripController tripController = Get.find<TripController>();

  showDialog(
    context: context,
    builder: (context) {
      return tripController.isAddparticipantLoading.value ? Center(child: CircularProgressIndicator() ,) : Dialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        child: Container(
          padding: const EdgeInsets.all(20),
          decoration: BoxDecoration(
            gradient: LinearGradient(
              colors: [
                theme.colorScheme.primary.withOpacity(0.05),
                theme.colorScheme.secondary.withOpacity(0.05),
              ],
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ),
            borderRadius: BorderRadius.circular(12),
            boxShadow: [
              BoxShadow(
                color: theme.colorScheme.onSurface.withOpacity(0.05),
                blurRadius: 4,
                offset: const Offset(0, 2),
              ),
            ],
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                "Add New Friend",
                style: theme.textTheme.titleLarge?.copyWith(
                  fontWeight: FontWeight.bold,
                  color: theme.colorScheme.onSurface,
                ),
              ),
              const SizedBox(height: 16),
              _customInputField(
                controller: tripController.newParticipantNameController,
                label: "Friend Name",
                theme: theme,
              ),
              const SizedBox(height: 12),
              _customInputField(
                controller: tripController.newParticipantMembersController,
                label: "Number of Members",
                theme: theme,
                inputType: TextInputType.number,
                inputFormatters: [FilteringTextInputFormatter.digitsOnly],
              ),
              const SizedBox(height: 20),
              Row(
                children: [
                  Expanded(
                    child: _customDialogButton(
                      label: "Cancel",
                      theme: theme,
                      onPressed: () {
                        Get.back();
                        tripController.newParticipantNameController.clear();
                        tripController.newParticipantMembersController.clear();
                      },
                      backgroundColor:
                      theme.colorScheme.surfaceContainerHighest,
                      textColor: theme.colorScheme.onSurface,
                    ),
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    child: _customDialogButton(
                      label: "Add Friend",
                      theme: theme,
                      onPressed: () async {
                        final name =
                        tripController.newParticipantNameController.text
                            .trim();
                        final members = int.tryParse(
                          tripController
                              .newParticipantMembersController
                              .text
                              .trim(),
                        ) ??
                            0;
                        if (name.isNotEmpty && members > 0) {
                          tripController.isAddparticipantLoading.value = true;
                          await tripController.addNewParticipant(
                            context: context,
                            theme: theme,
                            participantData: {'name': name, 'member': members},
                          );
                          tripController.newParticipantNameController.clear();
                          tripController.newParticipantMembersController.clear();
                          Get.back();
                        } else {
                          ScaffoldMessenger.of(context).showSnackBar(
                            SnackBar(
                              content: Text(
                                'Please enter a valid name and number of members',
                                style: TextStyle(
                                  color: theme.colorScheme.onErrorContainer,
                                ),
                              ),
                              backgroundColor: theme.colorScheme.errorContainer,
                            ),
                          );
                        }
                      },
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      );
    },
  );
}

Widget _customInputField({
  required TextEditingController controller,
  required String label,
  required ThemeData theme,
  TextInputType inputType = TextInputType.text,
  List<TextInputFormatter>? inputFormatters,
}) {
  return TextField(
    controller: controller,
    keyboardType: inputType,
    inputFormatters: inputFormatters,
    decoration: InputDecoration(
      labelText: label,
      labelStyle: TextStyle(color: theme.disabledColor),
      filled: true,
      fillColor: theme.colorScheme.surfaceContainer,
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: BorderSide.none,
      ),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: BorderSide(
          color: theme.colorScheme.primary.withOpacity(0.2),
        ),
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: BorderSide(
          color: theme.colorScheme.primary.withOpacity(0.4),
        ),
      ),
    ),
  );
}

Widget _customDialogButton({
  required String label,
  required VoidCallback onPressed,
  required ThemeData theme,
  Color? backgroundColor,
  Color? textColor,
}) {
  return TextButton(
    onPressed: onPressed,
    style: TextButton.styleFrom(
      backgroundColor:
      backgroundColor ?? theme.colorScheme.primary.withOpacity(0.1),
      foregroundColor: textColor ?? theme.colorScheme.primary,
      padding: const EdgeInsets.symmetric(vertical: 12),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
        side: BorderSide(color: theme.colorScheme.primary.withOpacity(0.3)),
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