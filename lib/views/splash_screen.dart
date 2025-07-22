import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../controller/splash_screen/splash_screen_controller.dart';

class SplashScreen extends StatelessWidget {
   SplashScreen({super.key});

  final SplashScreenController splashScreenController = Get.put(SplashScreenController());
  @override
  Widget build(BuildContext context) {


    return  GetX<SplashScreenController>(
      builder: (context) {
        return Scaffold(
          body: Center(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                CircularProgressIndicator(),
                Text(splashScreenController.appName.value)
              ],
            ),
          ),
        );
      }
    );
  }
}
