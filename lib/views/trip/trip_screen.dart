import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:splitrip/controller/trip/trip_controller.dart';
import 'package:splitrip/data/constants.dart';
import 'package:splitrip/views/trip/trip_detail_screen.dart';
import 'package:splitrip/widgets/myappbar.dart';

import '../../model/trip/trip_model.dart';
import '../../widgets/my_snackbar.dart';

class TripScreen extends StatelessWidget {
  TripScreen({super.key});

  final TripController tripController = Get.put(TripController());

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return GetX<TripController>(
      builder: (_) {
        return Scaffold(
          appBar: _buildAppBar(context, theme),
          body:
              tripController.isTripScreenLoading.value
                  ? const Center(child: CircularProgressIndicator())
                  : _buildBody(context, theme),
        );
      },
    );
  }

  Widget _buildBody(BuildContext context, ThemeData theme) {
    if (tripController.isAuthenticated.value) {
      if (tripController.tripModelList.isNotEmpty) {
        final visibleTrips = tripController.tripModelList
            .where((trip) => !(trip.isArchived || trip.isDeleted))
            .toList();
        if (visibleTrips.isEmpty) {
          return _buildEmptyState(
            theme,
            'No Active Trips 😕',
            'All trips are either archived or deleted.',
            'Create a new trip to start planning again!',
            'Create Trip',
            PageConstant.MaintainTripPage,
          );
        }
        return ListView.builder(
          itemCount: visibleTrips.length,
          itemBuilder: (context, index) {
            final trip = visibleTrips[index];
            return Padding(
              padding: const EdgeInsets.symmetric(horizontal: 15, vertical: 6),
              child: Builder(
                builder: (itemContext) {
                  return GestureDetector(
                    onTap: () => Get.to(() => TripPage()),
                    onLongPress: () => _showTripContextMenu(itemContext, trip),
                    child: Card(
                      elevation: 0,
                      color: theme.cardTheme.color,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                        side: BorderSide(
                          color: theme.colorScheme.primary.withOpacity(0.2),
                        ),
                      ),
                      child: Container(
                        height: 80,
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
                              color: theme.colorScheme.onSurface.withOpacity(
                                0.05,
                              ),
                              blurRadius: 4,
                              offset: const Offset(0, 2),
                            ),
                          ],
                        ),
                        child: Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 20),
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Row(
                                children: [
                                  CircleAvatar(
                                    backgroundColor:
                                        theme.scaffoldBackgroundColor,
                                    child: Text(trip.tripEmoji ?? ""),
                                  ),
                                  const SizedBox(width: 12),
                                  Column(
                                    mainAxisAlignment: MainAxisAlignment.center,
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      Text(
                                        trip.tripName,
                                        style: theme.textTheme.bodyLarge
                                            ?.copyWith(
                                              color:
                                                  theme.colorScheme.onSurface,
                                              fontWeight: FontWeight.w500,
                                            ),
                                      ),
                                      Text(
                                        "Currency: ${trip.tripCurrency}",
                                        style: theme.textTheme.labelSmall,
                                      ),
                                    ],
                                  ),
                                ],
                              ),
                              Icon(
                                Icons.arrow_forward_ios,
                                color: theme.colorScheme.onSurface.withOpacity(
                                  0.6,
                                ),
                                size: 20,
                              ),
                            ],
                          ),
                        ),
                      ),
                    ),
                  );
                },
              ),
            );
          },
        );
      } else {
        return _buildEmptyState(
          theme,
          'Welcome 👋',
          'Looks like you haven’t added any trips yet.',
          'Tap the button below to start your first journey!',
          'Get Started',
          PageConstant.MaintainTripPage,
        );
      }
    } else {
      return _buildEmptyState(
        theme,
        'Welcome Aboard! ✨',
        'It looks like you haven’t signed up yet.',
        'Tap the button below to join and start your journey!',
        'Sign Up Now',
        PageConstant.ProfilePage,
      );
    }
  }

  Widget _buildEmptyState(
    ThemeData theme,
    String title,
    String subtitle,
    String message,
    String buttonText,
    String route,
  ) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 24, vertical: 32),
      padding: const EdgeInsets.all(28),
      decoration: BoxDecoration(
        color: theme.cardTheme.color,
        borderRadius: BorderRadius.circular(16),
        gradient: LinearGradient(
          colors: [
            theme.colorScheme.primary.withOpacity(0.05),
            theme.colorScheme.secondary.withOpacity(0.05),
          ],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        border: Border.all(
          color: theme.colorScheme.primary.withOpacity(0.2),
          width: 1,
        ),
        boxShadow: [
          BoxShadow(
            color: theme.colorScheme.onSurface.withOpacity(0.05),
            blurRadius: 4,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.center,
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(
            title,
            style: theme.textTheme.headlineSmall?.copyWith(
              fontWeight: FontWeight.bold,
              color: theme.colorScheme.onSurface,
            ),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 12),
          Text(
            subtitle,
            style: theme.textTheme.bodyLarge?.copyWith(
              color: theme.colorScheme.onSurface.withValues(alpha: 0.6),
            ),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 8),
          Text(
            message,
            style: theme.textTheme.bodyMedium?.copyWith(
              color: theme.colorScheme.onSurface.withOpacity(0.5),
            ),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 24),
          TextButton(
            onPressed:
                () => Get.toNamed(route, arguments: {"Call From": "Add"}),
            style: TextButton.styleFrom(
              backgroundColor: theme.colorScheme.primary.withOpacity(0.1),
              foregroundColor: theme.colorScheme.primary,
              padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(8),
                side: BorderSide(
                  color: theme.colorScheme.primary.withOpacity(0.3),
                  width: 1,
                ),
              ),
              splashFactory: NoSplash.splashFactory,
              tapTargetSize: MaterialTapTargetSize.shrinkWrap,
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  buttonText,
                  style: theme.textTheme.labelLarge?.copyWith(
                    fontWeight: FontWeight.w600,
                    color: theme.colorScheme.primary,
                  ),
                ),
                const SizedBox(width: 8),
                Icon(
                  Icons.arrow_forward,
                  size: 16,
                  color: theme.colorScheme.primary,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  PreferredSizeWidget _buildAppBar(BuildContext context, ThemeData theme) {
    return CustomAppBar(
      title: "Trips",
      CenterTitle: false,
      actions:
          tripController.tripModelList.isNotEmpty
              ? [
                IconButton(
                  onPressed: () {
                    CustomSnackBar.show(title: "title", message: "message");
                  },
                  icon: Icon(Icons.archive_outlined, color: theme.primaryColor),
                  tooltip: 'Archive',
                ),
                IconButton(
                  onPressed: () {
                    Get.toNamed(
                      PageConstant.MaintainTripPage,
                      arguments: {"Call From": "Add"},
                    );
                  },
                  icon: Icon(Icons.add, color: theme.primaryColor),
                ),
              ]
              : null,
    );
  }

  void _showTripContextMenu(BuildContext context, Trip trip) async {
    final RenderBox renderBox = context.findRenderObject() as RenderBox;
    final Offset position = renderBox.localToGlobal(Offset.zero);

    final selected = await showMenu<String>(
      context: context,
      position: RelativeRect.fromLTRB(
        position.dy,
        position.dy + 30,
        position.dx,
        position.dy,
      ),
      items: [
        const PopupMenuItem(value: 'edit', child: Text('Edit')),
        const PopupMenuItem(value: 'archive', child: Text('Archive')),
        PopupMenuItem(
          value: 'delete',
          child: Text(
            'Delete',
            style: TextStyle(color: Theme.of(context).colorScheme.error),
          ),
        ),
      ],
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
        side: BorderSide(
          color: Theme.of(context).colorScheme.primary.withOpacity(0.2),
        ),
      ),
    );

    if (selected != null) {
      switch (selected) {
        case 'edit':
          try {
            Get.toNamed(
              PageConstant.MaintainTripPage,
              arguments: {"trip_id": trip.id},
            );
          } catch (e) {
            CustomSnackBar.show(
              title: 'Error',
              message: 'Failed to open edit page: $e',
            );
          }
          break;

        case 'archive':
          try {
           tripController.addToArchive(trip);
          } catch (e) {
            CustomSnackBar.show(
              title: 'Error',
              message: 'Failed to archive trip: $e',
            );
          }
          break;

        case 'delete':
          Get.defaultDialog(
            title: 'Delete Trip',
            middleText: 'Are you sure you want to delete ${trip.tripName}?',
            textConfirm: 'Delete',
            textCancel: 'Cancel',
            confirmTextColor: Colors.white,
            onConfirm: () async {
              try {
                // await tripController.deleteTrip(trip);
                Get.back();
                CustomSnackBar.show(
                  title: 'Deleted',
                  message: '${trip.tripName} deleted',
                );
              } catch (e) {
                CustomSnackBar.show(
                  title: 'Error',
                  message: 'Failed to delete trip: $e',
                );
              }
            },
          );
          break;
      }
    }
  }
}
