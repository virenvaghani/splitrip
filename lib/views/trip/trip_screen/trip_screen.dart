import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:splitrip/controller/appPageController/app_page_controller.dart';
import 'package:splitrip/controller/participant/participent_selection_controller.dart';
import 'package:splitrip/controller/trip/trip_controller.dart';
import 'package:splitrip/controller/trip/trip_detail_controller.dart';
import 'package:splitrip/controller/trip/trip_screen_controller.dart';
import 'package:splitrip/data/constants.dart';
import 'package:splitrip/model/trip/trip_model.dart';
import 'package:splitrip/views/trip/scan_trip/generate_qr_screen.dart';
import 'package:splitrip/widgets/myappbar.dart';

import '../../../model/currency/currency_model.dart';

class TripScreen extends StatelessWidget {
  TripScreen({super.key});

  final TripController tripController = Get.find<TripController>();
  final TripDetailController tripDetailController = Get.find<TripDetailController>();
  final AppPageController appPageController = Get.find<AppPageController>();
  final TripScreenController tripScreenController = Get.find<TripScreenController>();

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);


    return Obx(() {
      final token = tripScreenController.authToken.value;

      if (token == null) {
        return Scaffold(
          appBar: _buildAppBar(context, theme, showActions: false),
          body: _unauthenticatedState(theme),
        );
      }

      if (tripScreenController.isLoading.value) {
        return const Scaffold(body: Center(child: CircularProgressIndicator()));
      }

      if (tripScreenController.tripModelList.isEmpty) {
        return Scaffold(
          appBar: _buildAppBar(context, theme, showActions: true),
          body: _buildEmptyState(
            theme,
            'Welcome 👋',
            'Looks like you haven’t added any trips yet.',
            'Tap the button below to start your first journey!',
            'Get Started',
            PageConstant.maintainTripPage,
            tripScreenController,
          ),
        );
      }

      return Scaffold(
        appBar: _buildAppBar(context, theme, showActions: true),
        body: _buildBody(context, theme),
      );
    });
  }

  PreferredSizeWidget _buildAppBar(BuildContext context, ThemeData theme, {required bool showActions}) {
    return CustomAppBar(
      title: "Trips",
      centerTitle: false,
      actions: showActions
          ? [
        tripScreenController.archivedTripList.isNotEmpty
            ? IconButton(
          onPressed: () {
            Get.toNamed(PageConstant.archiveScreen);
          },
          icon: Icon(Icons.archive_outlined, color: theme.primaryColor),
          tooltip: 'Archive',
        )
            : const SizedBox.shrink(),
        IconButton(onPressed: () {
          Get.toNamed(PageConstant.scanscreen);
        }, icon: Icon(Icons.qr_code_scanner, color: theme.primaryColor,)),
        IconButton(
          onPressed: () async {
            final result = await Get.toNamed(
              PageConstant.maintainTripPage,
              arguments: {"Call From": "Add"},
            );

            if (result != null && result is Map<String, dynamic>) {
              final Trip newTrip = Trip.fromJson(result);
              tripScreenController.tripModelList.add(newTrip);
              tripScreenController.update();
            }
          },
          icon: Icon(Icons.add, color: theme.primaryColor),
        ),
      ]
          : [],
    );
  }

  String getCurrencyDetailById(int id, {String type = 'code'}) {
    final currency = Kconstant.currencyModelList.firstWhere(
          (c) => c.id == id,
      orElse: () => CurrencyModel(id: id, name: 'Unknown', code: '', symbol: ''),
    );

    switch (type) {
      case 'name':
        return currency.name;
      case 'symbol':
        return currency.symbol;
      case 'code':
      default:
        return currency.code;
    }
  }


  Widget _buildBody(BuildContext context, ThemeData theme) {
    if (tripScreenController.tripModelList.isNotEmpty) {
      final visibleTrips = tripScreenController.tripModelList.toList();
      if (visibleTrips.isEmpty) {
        return _buildEmptyState(theme, 'No Active Trips 😕', 'All trips are either archived or deleted.',
            'Create a new trip to start planning again!', 'Create Trip', PageConstant.maintainTripPage, tripScreenController);
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
                  onTap: () {
                    Get.toNamed(PageConstant.tripDetailScreen, arguments: {'tripId':trip.id});
                  },
                  onLongPress: () => _showTripContextMenu(itemContext, trip),
                  child: Card(
                    elevation: 0,
                    color: theme.cardTheme.color,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                      side: BorderSide(color: theme.colorScheme.primary.withValues(alpha: 0.2)),
                    ),
                    child: Container(
                      height: 80,
                      decoration: BoxDecoration(
                        gradient: LinearGradient(
                          colors: [
                            theme.colorScheme.primary.withValues(alpha: 0.05),
                            theme.colorScheme.secondary.withValues(alpha: 0.05),
                          ],
                          begin: Alignment.topLeft,
                          end: Alignment.bottomRight,
                        ),
                        borderRadius: BorderRadius.circular(12),
                        boxShadow: [
                          BoxShadow(
                            color: theme.colorScheme.onSurface.withValues(alpha: 0.05),
                            blurRadius: 4,
                            offset: const Offset(0, 2),
                          ),
                        ],
                      ),
                      child: Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 20),
                        child: Row(
                          children: [
                            CircleAvatar(
                              radius: 24,
                              backgroundColor: theme.scaffoldBackgroundColor,
                              child: Text(
                                trip.tripEmoji,
                                style: theme.textTheme.headlineSmall,
                              ),
                            ),
                            const SizedBox(width: 14),
                            Expanded(
                              child: Column(
                                mainAxisAlignment: MainAxisAlignment.center,
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    trip.tripName,
                                    style: theme.textTheme.titleMedium?.copyWith(
                                      fontWeight: FontWeight.w600,
                                      color: theme.colorScheme.onSurface,
                                    ),
                                  ),
                                  const SizedBox(height: 4),
                                  Row(
                                    children: [
                                      Icon(Icons.currency_exchange_rounded, size: 14, color: theme.hintColor),
                                      const SizedBox(width: 4),
                                      Text(
                                        "Currency: ${getCurrencyDetailById(trip.defaultCurrency, type: 'code')}",
                                        style: theme.textTheme.labelSmall?.copyWith(color: theme.hintColor),
                                      ),
                                      const SizedBox(width: 12),
                                      Icon(Icons.people_alt_outlined, size: 14, color: theme.hintColor),
                                      const SizedBox(width: 4),
                                      Text(
                                        "${trip.totalParticipants} Friends",
                                        style: theme.textTheme.labelSmall?.copyWith(color: theme.hintColor),
                                      ),
                                    ],
                                  ),
                                  const SizedBox(height: 2),
                                  Text(
                                    "Spent: ${getCurrencyDetailById(trip.defaultCurrency, type: 'symbol')}6,000", // TODO: Replace hardcoded value
                                    style: theme.textTheme.labelSmall?.copyWith(
                                      color: theme.colorScheme.primary,
                                      fontWeight: FontWeight.w500,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                            const Icon(Icons.arrow_forward_ios_rounded, size: 18, color: Colors.grey),
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
      return _buildEmptyState(theme, 'Welcome 👋', 'Looks like you haven’t added any trips yet.',
          'Tap the button below to start your first journey!', 'Get Started', PageConstant.maintainTripPage, tripScreenController);
    }
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
          Text('Welcome Aboard! ✨', style: theme.textTheme.headlineSmall?.copyWith(fontWeight: FontWeight.bold, color: theme.colorScheme.onSurface), textAlign: TextAlign.center),
          const SizedBox(height: 12),
          Text('It looks like you haven’t signed up yet.',
              style: theme.textTheme.bodyLarge?.copyWith(color: theme.colorScheme.onSurface.withValues(alpha: 0.6)),
              textAlign: TextAlign.center),
          const SizedBox(height: 8),
          Text('Tap the button below to join and start your journey!',
              style: theme.textTheme.bodyMedium?.copyWith(color: theme.colorScheme.onSurface.withValues(alpha: 0.5)),
              textAlign: TextAlign.center),
          const SizedBox(height: 24),
          TextButton(
            onPressed: () {
              appPageController.pageIndex.value = 2;
            },
            style: _buttonStyle(theme),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Text('Sign Up Now',
                    style: theme.textTheme.labelLarge?.copyWith(fontWeight: FontWeight.w600, color: theme.colorScheme.primary)),
                const SizedBox(width: 8),
                Icon(Icons.arrow_forward, size: 16, color: theme.colorScheme.primary),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildEmptyState(ThemeData theme, String title, String subtitle, String message, String buttonText,
      String route, TripScreenController tripScreenController) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 24, vertical: 32),
      padding: const EdgeInsets.all(28),
      decoration: _boxDecoration(theme),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.center,
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(title, style: theme.textTheme.headlineSmall?.copyWith(fontWeight: FontWeight.bold, color: theme.colorScheme.onSurface), textAlign: TextAlign.center),
          const SizedBox(height: 12),
          Text(subtitle, style: theme.textTheme.bodyLarge?.copyWith(color: theme.colorScheme.onSurface.withValues(alpha: 0.6)), textAlign: TextAlign.center),
          const SizedBox(height: 8),
          Text(message, style: theme.textTheme.bodyMedium?.copyWith(color: theme.colorScheme.onSurface.withValues(alpha: 0.5)), textAlign: TextAlign.center),
          const SizedBox(height: 24),
          TextButton(
            onPressed: () async {
              final result = await Get.toNamed(route, arguments: {"Call From": "Add"});
              if (result != null && result is Map<String, dynamic>) {
                final Trip newTrip = Trip.fromJson(result);
                tripController.tripModelList.add(newTrip);
                tripController.update();
              }
            },
            style: _buttonStyle(theme),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(buttonText,
                    style: theme.textTheme.labelLarge?.copyWith(fontWeight: FontWeight.w600, color: theme.colorScheme.primary)),
                const SizedBox(width: 8),
                Icon(Icons.arrow_forward, size: 16, color: theme.colorScheme.primary),
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
      border: Border.all(color: theme.colorScheme.primary.withValues(alpha: 0.2), width: 1),
      boxShadow: [BoxShadow(color: theme.colorScheme.onSurface.withValues(alpha: 0.05), blurRadius: 4, offset: const Offset(0, 2))],
    );
  }

  ButtonStyle _buttonStyle(ThemeData theme) {
    return TextButton.styleFrom(
      backgroundColor: theme.colorScheme.primary.withValues(alpha: 0.1),
      foregroundColor: theme.colorScheme.primary,
      padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(8),
        side: BorderSide(color: theme.colorScheme.primary.withValues(alpha: 0.3), width: 1),
      ),
      splashFactory: NoSplash.splashFactory,
      tapTargetSize: MaterialTapTargetSize.shrinkWrap,
    );
  }



  void _showTripContextMenu(BuildContext context, Trip trip) async {
    final theme = Theme.of(context);
    final RenderBox renderBox = context.findRenderObject() as RenderBox;
    final Offset position = renderBox.localToGlobal(Offset.zero);

    final selected = await showMenu<String>(
      context: context,
      position: RelativeRect.fromLTRB(position.dy, position.dy + 30, position.dx, position.dy),
      items: [
        _popupMenuItem(Icons.edit, 'Edit', 'edit', Colors.green),
        _popupMenuItem(Icons.archive, 'Archive', 'archive', theme.colorScheme.primary),
        _popupMenuItem(Icons.qr_code, 'Qr Code', 'Qr Code', Colors.grey),
        _popupMenuItem(Icons.delete, 'Delete', 'delete', theme.colorScheme.error),
      ],
      elevation: 8,
      color: theme.cardTheme.color,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
    );

    if (selected != null) {
      if(context.mounted){
        _handleContextMenuSelection(selected, trip, context, theme);
      }
    }
  }

  PopupMenuItem<String> _popupMenuItem(IconData icon, String label, String value, Color color) {
    return PopupMenuItem(
      value: value,
      child: Row(
        children: [
          Icon(icon, color: color),
          const SizedBox(width: 10),
          Text(label, style: value == 'delete' ? TextStyle(color: color) : null),
        ],
      ),
    );
  }

  void _handleContextMenuSelection(String selected, Trip trip, BuildContext context, ThemeData theme) async {
    switch (selected) {
      case 'edit':
        final result = await Get.toNamed(PageConstant.maintainTripPage, arguments: {"trip_id": trip.id});
        if (result != null && result is Map<String, dynamic>) {
          final Trip newTrip = Trip.fromJson(result);
          final index = tripController.tripModelList.indexWhere((t) => t.id == newTrip.id);
          if (index != -1) {
            tripController.tripModelList[index] = newTrip;
            tripController.update();
          }
        }
        break;
      case 'archive':
        tripScreenController.addToArchive(trip);
        break;
      case 'delete':
        _showDeleteConfirmationDialog(context, trip, theme);
        break;
      case 'Qr Code':
       Get.to(GenerateQRPage( tripId: int.parse(trip.id!)));
        break;
    }
  }

  void _showDeleteConfirmationDialog(BuildContext context, Trip trip, ThemeData theme) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text('Delete Trip', style: theme.textTheme.titleMedium?.copyWith(color: theme.colorScheme.onSurface)),
        content: Text(
            'Are you sure you want to delete "${trip.tripName}"? This action cannot be undone.',
            style: theme.textTheme.bodyMedium?.copyWith(color: theme.colorScheme.onSurface.withValues(alpha: 0.8))),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text('Cancel', style: theme.textTheme.labelLarge?.copyWith(color: theme.colorScheme.onSurface.withValues(alpha: 0.6))),
          ),
          TextButton(
            onPressed: () {
              tripScreenController.deletetrip(trip);
              Navigator.pop(context);
            },
            child: Text('Delete', style: theme.textTheme.labelLarge?.copyWith(color: theme.colorScheme.error)),
          ),
        ],
      ),
    );
  }

}
