import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:google_nav_bar/google_nav_bar.dart';
import 'package:splitrip/theme/theme.dart';
import '../controller/app_page_controller.dart';

class MyNavigationBar extends StatelessWidget {
  const MyNavigationBar({super.key});

  @override
  Widget build(BuildContext context) {
    final AppPageController pageController = Get.find<AppPageController>();

    return Obx(
      () => Container(
        padding: const EdgeInsets.symmetric(horizontal: 15.0, vertical: 10.0),
        child: GNav(
          tabs: const [
            GButton(icon: Icons.group, text: "Friends"),
            GButton(icon: Icons.home, text: "Home"),
            GButton(icon: Icons.person, text: "Profile"),
          ],
          onTabChange: (index) {
            pageController.changePage(index);
          },
          activeColor: Colors.white,
          tabBackgroundColor: colortheme.themecolor.shade400,
          gap: 8,
          padding: const EdgeInsets.all(16),
          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
          selectedIndex: pageController.pageIndex.value,
        ),
      ),
    );
  }
}
