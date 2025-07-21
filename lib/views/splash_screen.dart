import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../controller/profile/profile_controller.dart';
import '../controller/splash_screen/splash_screen_controller.dart';

class SplashScreen extends StatelessWidget {
  const SplashScreen({super.key});


  @override
  Widget build(BuildContext context) {
    final ProfileController profileController = Get.put(ProfileController());
    // Initialize controller here
    final SplashScreenController splashScreenController = Get.put(SplashScreenController());

    return const Scaffold(
      body: Center(child: CircularProgressIndicator()),
    );
  }
}
