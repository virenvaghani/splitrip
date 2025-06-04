import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:google_nav_bar/google_nav_bar.dart';
import '../controller/app_page_controller.dart';

class MyNavigationBar extends StatelessWidget {
  const MyNavigationBar({super.key});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final AppPageController pageController = Get.find<AppPageController>();

    return Obx(
          () => Container(
        margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(12),
        ),
        child: GNav(
          tabs: const [
            GButton(icon: Icons.group, text: "Friends"),
            GButton(icon: Icons.home, text: "Home"),
            GButton(icon: Icons.person, text: "Profile"),
          ],
          onTabChange: (index) {
            pageController.changePage(index);
          },
          activeColor: theme.colorScheme.onPrimary,
          tabBackgroundGradient: LinearGradient(
            colors: [
              theme.colorScheme.primary,
              theme.colorScheme.secondary,
            ],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
          gap: 8,
          padding: const EdgeInsets.all(16),
          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
          selectedIndex: pageController.pageIndex.value,
          textStyle: theme.textTheme.labelLarge?.copyWith(
            color: theme.colorScheme.onPrimary,
            fontWeight: FontWeight.w600,
          ),
          tabBorderRadius: 30,
          iconSize: 24,
        ),
      ),
    );
  }
}