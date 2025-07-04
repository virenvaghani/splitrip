import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:splitrip/widgets/My_navigation_bar.dart';
import '../controller/app_page_controller.dart';

class DashBoard extends StatelessWidget {
  const DashBoard({super.key});

  @override
  Widget build(BuildContext context) {
    final AppPageController pageController = Get.find<AppPageController>();

    return Obx(() {
      return Scaffold(
        body: IndexedStack(
          index: pageController.pageIndex.value,
          children: pageController.pageBuilders
              .map((builder) => builder()) // 👈 evaluate each builder function
              .toList(),
        ),
        bottomNavigationBar: const MyNavigationBar(),
      );
    });

  }
}
