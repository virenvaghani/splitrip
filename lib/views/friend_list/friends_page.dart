import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:splitrip/widgets/myappbar.dart';
import 'package:splitrip/widgets/my_snackbar.dart';
import '../../controller/friend/friend_controller.dart';
import '../../controller/trip/trip_controller.dart';

class FriendsPage extends StatelessWidget {
  FriendsPage({super.key});

  final TripController tripController = Get.find<TripController>();
  final FriendController controller = Get.find<FriendController>();

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Scaffold(
      appBar: CustomAppBar(
        title: "Friends",
        CenterTitle: false,
        titleTextStyle: theme.textTheme.titleLarge?.copyWith(
          fontWeight: FontWeight.w600,
          color: theme.colorScheme.onSurface,
        ),
        actions: [
          IconButton(
            icon: Icon(Icons.refresh, color: theme.colorScheme.primary),
            onPressed: () => controller.fetchLinkedParticipants(),
            tooltip: 'Refresh',
            splashRadius: 20,
          ),
          IconButton(
            icon: Icon(
              Icons.person_add_alt_1,
              color: theme.colorScheme.primary,
            ),
            onPressed: () {
              _addFriend(context: context, theme: theme);
            },
            tooltip: 'Add Friend',
            splashRadius: 20,
          ),
        ],
      ),
      body: GetBuilder<FriendController>(
        init: controller,
        initState: (_) => controller.fetchLinkedParticipants(),
        builder:
            (_) => Obx(() {
              if (controller.isLoading.value) {
                return const Center(child: CircularProgressIndicator());
              }

              if (controller.errorMessage.isNotEmpty) {
                return _stateMessage(
                  controller.errorMessage.value,
                  theme.colorScheme.error,
                  context,
                );
              }

              if (controller.friendsList.isEmpty) {
                return _stateMessage(
                  "No friends added yet.",
                  theme.colorScheme.outline,
                  context,
                );
              }

              return ListView.separated(
                padding: const EdgeInsets.fromLTRB(16, 16, 16, 32),
                itemCount: controller.friendsList.length,
                separatorBuilder: (_, __) => const SizedBox(height: 10),
                itemBuilder: (context, index) {
                  final friend = controller.friendsList[index];
                  final name = friend.participant.name ?? 'Unknown';
                  return _FriendTile(name: name);
                },
              );
            }),
      ),
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

  void _addFriend({required BuildContext context, required ThemeData theme}) {
    final TextEditingController nameController = TextEditingController();
    final TextEditingController memberController = TextEditingController();

    showDialog(
      context: context,
      builder: (context) {
        return Dialog(
          backgroundColor: theme.colorScheme.surface,
          surfaceTintColor: theme.colorScheme.surfaceTint,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(25),
          ),
          elevation: theme.dialogTheme.elevation ?? 4,
          child: Padding(
            padding: const EdgeInsets.all(20),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Add Friend',
                  style: theme.textTheme.headlineSmall?.copyWith(
                    color: theme.colorScheme.onSurface,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                const SizedBox(height: 16),
                TextField(
                  controller: tripController.newParticipantNameController,
                  decoration: InputDecoration(
                    labelText: 'Name',
                    labelStyle: TextStyle(
                      color: theme.colorScheme.onSurfaceVariant,
                    ),
                    filled: true,
                    fillColor: theme.colorScheme.surfaceContainerHighest,
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(25),
                      borderSide: BorderSide.none,
                    ),
                    enabledBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(25),
                      borderSide: BorderSide.none,
                    ),
                    focusedBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(25),
                      borderSide: BorderSide(
                        color: theme.colorScheme.primary,
                        width: 2,
                      ),
                    ),
                  ),
                ),
                const SizedBox(height: 12),
                TextField(
                  controller: tripController.newParticipantMembersController,
                  decoration: InputDecoration(
                    labelText: 'Member',
                    labelStyle: TextStyle(
                      color: theme.colorScheme.onSurfaceVariant,
                    ),
                    filled: true,
                    fillColor: theme.colorScheme.surfaceContainerHighest,
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(25),
                      borderSide: BorderSide.none,
                    ),
                    enabledBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(25),
                      borderSide: BorderSide.none,
                    ),
                    focusedBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(25),
                      borderSide: BorderSide(
                        color: theme.colorScheme.primary,
                        width: 2,
                      ),
                    ),
                  ),
                ),
                const SizedBox(height: 20),
                Row(
                  mainAxisAlignment: MainAxisAlignment.end,
                  children: [
                    TextButton(
                      style: TextButton.styleFrom(
                        foregroundColor: theme.colorScheme.onSurfaceVariant,
                        padding: const EdgeInsets.symmetric(
                          horizontal: 16,
                          vertical: 8,
                        ),
                      ),
                      onPressed: () => Navigator.pop(context),
                      child: Text(
                        'Cancel',
                        style: theme.textTheme.labelLarge?.copyWith(
                          color: theme.colorScheme.onSurfaceVariant,
                        ),
                      ),
                    ),
                    const SizedBox(width: 8),
                    TextButton(
                      style: FilledButton.styleFrom(
                        backgroundColor: theme.colorScheme.primary,
                        foregroundColor: theme.colorScheme.onPrimary,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(25),
                        ),
                        padding: const EdgeInsets.symmetric(
                          horizontal: 20,
                          vertical: 5,
                        ),
                      ),
                      onPressed: () {
                        tripController.addNewParticipant(
                          context: context,
                          theme: theme,
                          participantData: {
                            'name':
                                tripController.newParticipantNameController.text
                                    .trim(),
                            'member': int.parse(
                              tripController
                                  .newParticipantMembersController
                                  .text
                                  .trim(),
                            ),
                          },
                        );
                        tripController.newParticipantNameController.clear();
                        tripController.newParticipantMembersController.clear();
                      },
                      child: Text(
                        'Add',
                        style: theme.textTheme.labelLarge?.copyWith(
                          color: theme.colorScheme.onPrimary,
                        ),
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
}

class _FriendTile extends StatelessWidget {
  final String name;
  const _FriendTile({required this.name});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Container(
      decoration: BoxDecoration(
        color: theme.colorScheme.surfaceContainer.withValues(alpha: 0.4),
        border: Border(
          bottom: BorderSide(color: theme.colorScheme.outline.withOpacity(0.1)),
        ),
      ),
      child: ListTile(
        contentPadding: const EdgeInsets.symmetric(
          horizontal: 16,
          vertical: 12,
        ),
        leading: CircleAvatar(
          radius: 22,
          backgroundColor: theme.colorScheme.primaryContainer,
          child: Text(
            name[0].toUpperCase(),
            style: theme.textTheme.titleMedium?.copyWith(
              color: theme.colorScheme.onPrimaryContainer,
              fontWeight: FontWeight.bold,
            ),
          ),
        ),
        title: Text(
          name,
          style: theme.textTheme.bodyLarge?.copyWith(
            color: theme.colorScheme.onSurface,
            fontWeight: FontWeight.w600,
          ),
        ),

        trailing: IconButton(
          icon: Icon(Icons.close, size: 20, color: theme.colorScheme.error),
          onPressed: () {
            CustomSnackBar.show(
              title: "Coming Soon",
              message: "Removing friends is not available yet.",
            );
          },
          splashRadius: 20,
          tooltip: 'Remove Friend',
        ),
      ),
    );
  }
}
