import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';
import 'package:icons_plus/icons_plus.dart';
import 'package:splitrip/controller/trip/trip_screen_controller.dart';
import 'package:splitrip/model/trip/trip_model.dart';
import 'package:splitrip/widgets/myappbar.dart';

class ArchiveScreen extends StatelessWidget {
  ArchiveScreen({super.key});

  final TripScreenController tripScreenController = Get.find<TripScreenController>();

  @override
  Widget build(BuildContext context) {
    return AnnotatedRegion<SystemUiOverlayStyle>(
      value: SystemUiOverlayStyle(
        systemNavigationBarColor:
            Theme.of(context).scaffoldBackgroundColor, // navigation bar color
        statusBarColor: Theme.of(context).scaffoldBackgroundColor,
        statusBarBrightness: Brightness.light,
        statusBarIconBrightness: Brightness.dark,
        systemNavigationBarContrastEnforced: true,
        systemNavigationBarIconBrightness: Brightness.dark,
        systemStatusBarContrastEnforced: true,
      ),
      child: SafeArea(
        child: Scaffold(
          appBar: _buildAppBar(context),
          body: _buildBody(context),
        ),
      ),
    );
  }

  /// Builds the custom app bar for the archive screen.
  PreferredSizeWidget _buildAppBar(BuildContext context) {
    return CustomAppBar(
      centerTitle: true,
      title: "Archived Trips",
      actions: [
        IconButton(
          icon: const Icon(Icons.refresh),
          onPressed:
              tripScreenController.refreshArchivedTrips, // Assumes method exists
          tooltip: 'Refresh Trips',
        ),
      ],
    );
  }

  /// Builds the main body content, handling empty and non-empty states.
  Widget _buildBody(BuildContext context) {
    final theme = Theme.of(context);

    return Obx(() {
      final archivedTrips = tripScreenController.archivedTripList;

      if (archivedTrips.isEmpty) {
        return Center(
          child: Text(
            "No archived trips found",
            style: theme.textTheme.bodyLarge?.copyWith(
              color: theme.colorScheme.onSurface.withValues(alpha: 0.6),
            ),
          ),
        );
      }

      // Validate unique trip IDs to prevent key conflicts
      final uniqueIds = archivedTrips.map((trip) => trip.id).toSet();
      if (uniqueIds.length != archivedTrips.length) {
        debugPrint(
          'Warning: Duplicate trip IDs detected, which may cause key conflicts.',
        );
      }

      return ReorderableListView.builder(
        itemCount: archivedTrips.length,
        onReorder: (oldIndex, newIndex) {
          // Adjust newIndex to account for the dragged item's position
          if (newIndex > oldIndex) newIndex -= 1;
          // Prevent invalid index access
          if (oldIndex >= 0 &&
              oldIndex < archivedTrips.length &&
              newIndex >= 0 &&
              newIndex <= archivedTrips.length) {
            final trip = archivedTrips.removeAt(oldIndex);
            archivedTrips.insert(newIndex, trip);
            // Refresh the list to update UI
            tripScreenController.archivedTripList.refresh();
            // Persist the new order
            try {
              tripScreenController.saveTripOrder(); // Assumes method exists
              debugPrint(
                'Reordered trip ${trip.id} from index $oldIndex to $newIndex',
              );
            } catch (e) {
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: Text('Failed to save trip order: $e'),
                  backgroundColor: theme.colorScheme.error,
                ),
              );
            }
          } else {
            debugPrint(
              'Invalid reorder indices: oldIndex=$oldIndex, newIndex=$newIndex',
            );
          }
        },
        padding: const EdgeInsets.symmetric(vertical: 10, horizontal: 12),
        itemBuilder: (context, index) {
          final trip = archivedTrips[index];
          return _TripListItem(
            key: ValueKey(trip.id ?? 'trip_$index'), // Fallback for null IDs
            trip: trip,
            index: index, // Pass index for drag handle
            onMenuTap:
                (position) => _showTripContextMenu(context, trip, position),
          );
        },
        proxyDecorator:
            (child, index, animation) => Material(
              color: Colors.transparent,
              child: ScaleTransition(
                scale: animation.drive(Tween(begin: 1.0, end: 1.05)),
                child: child,
              ),
            ),
      );
    });
  }

  /// Shows a context menu for trip actions (unarchive, delete).
  void _showTripContextMenu(BuildContext context, Trip trip, Offset position) {
    final theme = Theme.of(context);

    showMenu(
      context: context,
      position: RelativeRect.fromLTRB(
        position.dy,
        position.dy + 30,
        position.dx,
        position.dy,
      ),
      items: [
        PopupMenuItem(
          value: 'unarchive',
          child: Row(
            children: [
              Icon(Icons.unarchive, color: theme.colorScheme.primary, size: 20),
              const SizedBox(width: 8),
              Text(
                'Unarchive',
                style: theme.textTheme.bodyMedium?.copyWith(
                  color: theme.colorScheme.onSurface,
                ),
              ),
            ],
          ),
        ),
        PopupMenuItem(
          value: 'delete',
          child: Row(
            children: [
              Icon(Icons.delete, color: theme.colorScheme.error, size: 20),
              const SizedBox(width: 8),
              Text(
                'Delete',
                style: theme.textTheme.bodyMedium?.copyWith(
                  color: theme.colorScheme.error,
                ),
              ),
            ],
          ),
        ),
      ],
      elevation: 8,
      color: theme.cardTheme.color,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
    ).then((value) {
      if (value == null) return;

      switch (value) {
        case 'unarchive':
          try {
            tripScreenController.addToArchive(trip);
          } catch (e) {
            if(context.mounted){
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: Text('Failed to unarchive trip: $e'),
                  backgroundColor: theme.colorScheme.error,
                ),
              );
              return;
            }

          }
          break;
        case 'delete':
          if(context.mounted){
            _showDeleteConfirmationDialog(context, trip, theme);
          }
          break;
      }
    });
  }

  /// Shows a confirmation dialog before deleting a trip.
  void _showDeleteConfirmationDialog(
    BuildContext context,
    Trip trip,
    ThemeData theme,
  ) {
    showDialog(
      context: context,
      builder:
          (context) => AlertDialog(
            title: Text(
              'Delete Trip',
              style: theme.textTheme.titleMedium?.copyWith(
                color: theme.colorScheme.onSurface,
              ),
            ),
            content: Text(
              'Are you sure you want to delete "${trip.tripName}" This action cannot be undone.',
              style: theme.textTheme.bodyMedium?.copyWith(
                color: theme.colorScheme.onSurface.withValues(alpha: 0.8),
              ),
            ),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(context),
                child: Text(
                  'Cancel',
                  style: theme.textTheme.labelLarge?.copyWith(
                    color: theme.colorScheme.onSurface.withValues(alpha: 0.6),
                  ),
                ),
              ),
              TextButton(
                onPressed: () {
                  try {
                    tripScreenController.deletetrip(trip);
                    Navigator.pop(context);
                  } catch (e) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(
                        content: Text('Failed to delete trip: $e'),
                        backgroundColor: theme.colorScheme.error,
                      ),
                    );
                  }
                },
                child: Text(
                  'Delete',
                  style: theme.textTheme.labelLarge?.copyWith(
                    color: theme.colorScheme.error,
                  ),
                ),
              ),
            ],
          ),
    );
  }
}

/// A widget representing a single trip item in the archive list.
class _TripListItem extends StatelessWidget {
  final Trip trip;
  final int index;
  final Function(Offset) onMenuTap;

  const _TripListItem({
    required Key key,
    required this.trip,
    required this.index,
    required this.onMenuTap,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Card(
      elevation: 0,
      color: theme.cardTheme.color,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
        side: BorderSide(color: theme.colorScheme.primary.withValues(alpha: 0.2)),
      ),
      child: ReorderableDelayedDragStartListener(
        index: index,
        child: ListTile(
          contentPadding: const EdgeInsets.symmetric(horizontal: 16),
          leading: CircleAvatar(
            backgroundColor: theme.scaffoldBackgroundColor,
            child: Text(trip.tripEmoji ),
          ),
          title: Text(
            trip.tripName,
            style: theme.textTheme.bodyLarge?.copyWith(
              fontWeight: FontWeight.w500,
              color: theme.colorScheme.onSurface,
            ),
          ),
          subtitle: Text(
            "Currency: ${trip.tripCurrency}",
            style: theme.textTheme.bodyMedium,
          ),
          trailing: IconButton(
            icon: const Icon(
              Bootstrap.three_dots_vertical,
              size: 24,
              color: Colors.grey,
            ),
            onPressed: () {
              // Calculate position relative to the IconButton
              final RenderBox? renderBox =
                  context.findRenderObject() as RenderBox?;
              final position =
                  renderBox != null
                      ? renderBox.localToGlobal(Offset.zero)
                      : Offset(100, 100); // Fallback position
              onMenuTap(position);
            },
            tooltip: 'Trip Options',
          ),
        ),
      ),
    );
  }
}
