import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';
import 'package:splitrip/controller/profile/profile_controller.dart';
import 'package:splitrip/widgets/My_navigation_bar.dart';
import '../controller/appPageController/app_page_controller.dart';
import '../controller/trip/trip_controller.dart';
import '../controller/profile/user_controller.dart';

class DashBoard extends StatelessWidget {
  const DashBoard({super.key});

  @override
  Widget build(BuildContext context) {

    final ProfileController profileController = Get.put(ProfileController());
    final AppPageController pageController = Get.find<AppPageController>();
    final TripController tripController = Get.find<TripController>();
    final UserController userController = Get.find<UserController>();

    return Obx(() {
      return Scaffold(
        body:AnnotatedRegion<SystemUiOverlayStyle>(
          value: SystemUiOverlayStyle(
            systemNavigationBarColor:Theme.of(context).scaffoldBackgroundColor, // navigation bar color
            statusBarColor: Theme.of(context).scaffoldBackgroundColor,
            statusBarBrightness: Brightness.light,
            statusBarIconBrightness: Brightness.dark,
            systemNavigationBarContrastEnforced: true,
            systemNavigationBarIconBrightness: Brightness.dark,
            systemStatusBarContrastEnforced: true,
          ),
          child: SafeArea(child:  IndexedStack(
            index: pageController.pageIndex.value,
            children: pageController.pageBuilders
                .map((builder) => builder())
                .toList(),
          ),),
        ),
        bottomNavigationBar: SafeArea(child: const MyNavigationBar()),
      );
    });
  }
}
