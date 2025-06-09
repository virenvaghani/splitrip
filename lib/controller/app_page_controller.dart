import 'package:flutter/Material.dart';
import 'package:get/get.dart';

import '../views/friend_list/friends_page.dart';
import '../views/profile/profile_page.dart';
import '../views/trip/trip_screen.dart';
class AppPageController extends GetxController {
  final List<Widget> pages = [
     FriendsPage(),
     TripScreen(),
     ProfilePage(),
  ];
  var pageIndex = 1.obs; // Default to 0 (FriendsPage)

  void changePage(int index) {
    if (index >= 0 && index <= 2) { // Ensure valid index (0, 1, 2)
      pageIndex.value = index;
    }
  }
}