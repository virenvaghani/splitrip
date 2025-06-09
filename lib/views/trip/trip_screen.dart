import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:splitrip/controller/trip/trip_controller.dart';
import 'package:splitrip/model/trip/trip_model.dart';
import 'package:splitrip/views/trip/trip_detail_screen.dart';
import 'package:splitrip/widgets/myappbar.dart';

import '../../controller/trip/trip_controller.dart';
import 'maintain_trip_screen_.dart';

class TripScreen extends StatelessWidget {
  TripScreen({super.key});

  TripController tripController = Get.put(TripController());

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return GetX<TripController>(
      initState: (state) {
        tripController.iniStateMethodForList();
      },
      builder: (_) {
        return Scaffold(
          floatingActionButton: floatingactonbutton(context: context, theme: theme),
          appBar:appbar(context:context, theme:theme),
          body: bodyWidget(context: context, theme: theme),
        );
      },
    );
  }

  bodyWidget({required BuildContext context, required ThemeData theme}) {
    if (tripController.tripModelList.isNotEmpty) {
      return ListView.builder(
        itemCount: tripController.tripModelList.length,
        itemBuilder: (context, index) {
          return Padding(
            padding: const EdgeInsets.symmetric(horizontal: 15, vertical: 2),
            child: GestureDetector(
              onTap: () => Get.to(() => TripPage()),
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
                        color: theme.colorScheme.onSurface.withOpacity(0.05),
                        blurRadius: 4,
                        offset: const Offset(0, 2),
                      ),
                    ],
                  ),
                  alignment: Alignment.center,
                  child: AnimatedContainer(
                    duration: const Duration(milliseconds: 100),
                    child: Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 20),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Row(
                            children: [
                              CircleAvatar(
                                backgroundColor: theme.scaffoldBackgroundColor,
                                child: Text(
                                  tripController.tripModelList
                                          .elementAt(index)
                                          .tripEmoji ??
                                      "",
                                ),
                              ),
                              const SizedBox(width: 12),
                              Column(
                                mainAxisAlignment: MainAxisAlignment.center,
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    tripController.tripModelList
                                        .elementAt(index)
                                        .tripName
                                        .toString(),
                                    style: theme.textTheme.bodyLarge
                                        ?.copyWith(
                                          color: theme.colorScheme.onSurface,
                                          fontWeight: FontWeight.w500,
                                        ),
                                  ),
                                  Text(
                                    "Currency: ${tripController.tripModelList.elementAt(index).currency.toString()}",
                                    style: theme.textTheme.labelSmall,
                                  ),
                                  Text(
                                    "Members: ${tripController.tripModelList.elementAt(index).participantModelList?.length ?? 0}",
                                    style: theme.textTheme.labelSmall,
                                  )
                                ],
                              ),
                            ],
                          ),
                          Icon(
                            Icons.arrow_forward_ios,
                            color: theme.colorScheme.onSurface.withOpacity(0.6),
                            size: 20,
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              ),
            ),
          );
        },
      );
    } else {
      return Center(child: Text("No Data"));
    }
  }

  floatingactonbutton({required BuildContext context, required ThemeData theme}) {
    return ClipRRect(
      child: Container(
        height: 80,
        width: 100,
        child: ElevatedButton(
          onPressed: () {
            Get.toNamed(
              "/MaintainTripScreen",
              arguments: {"Call From": "Add"},
            );
          },
          style: ElevatedButton.styleFrom(
            padding: const EdgeInsets.symmetric(vertical: 16),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12),
            ),
            backgroundColor: Colors.transparent,
            shadowColor: Colors.transparent,
            splashFactory: NoSplash.splashFactory,
            elevation: 0,
          ).copyWith(
            backgroundColor: MaterialStateProperty.all(
              Colors.transparent,
            ),
            overlayColor: MaterialStateProperty.all(Colors.transparent),
          ),
          child: Container(
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
            padding: const EdgeInsets.symmetric(vertical: 16),
            child: Center(
              child: Text(
                'Create Trip',
                style: theme.textTheme.labelLarge?.copyWith(
                  color: theme.colorScheme.onPrimary,
                  fontWeight: FontWeight.w600,
                ),
                semanticsLabel: 'Create trip',
              ),
            ),
          ),
        ),
      ),
    );
  }

  appbar({required BuildContext context, required ThemeData theme}) {
    return  CustomAppBar(
      title: "Home",
      actions: tripController.tripModelList.isNotEmpty ? [
      IconButton(
        onPressed: () {},
        icon: Icon(
          Icons.archive_outlined,
          color: theme.primaryColor,
          size: 24,
        ),
        tooltip: 'Archive',
      ),
      ]:null,
    );
  }
}
