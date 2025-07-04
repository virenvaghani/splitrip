import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../views/friend_list/friends_page.dart';
import '../views/profile/profile_page.dart';
import '../views/trip/trip_screen.dart';

class AppPageController extends GetxController {
  // Lazy page builders instead of directly instantiated widgets
  final List<Widget Function()> pageBuilders = [
        () => FriendsPage(),
        () => TripScreen(),
        () => ProfilePage(),
  ];

  var pageIndex = 1.obs; // Default to TripScreen

  // Use this getter to access the current page lazily
  Widget get currentPage => pageBuilders[pageIndex.value]();

  // Change page index safely
  void changePage(int index) {
    if (index >= 0 && index < pageBuilders.length) {
      pageIndex.value = index;
    }
  }
}
