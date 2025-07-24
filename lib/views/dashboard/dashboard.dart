import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';
import 'package:splitrip/widgets/my_navigation_bar.dart';
import '../../controller/appPageController/app_page_controller.dart';

class DashBoard extends StatelessWidget {
   DashBoard({super.key});

  final AppPageController pageController = Get.find<AppPageController>();
  @override
  Widget build(BuildContext context) {

    return GetX<AppPageController>(initState: (state) {
    },builder: (controller) {
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
    },);
  }
}
