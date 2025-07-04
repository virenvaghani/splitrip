// lib/main.dart
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:provider/provider.dart';
import 'package:splitrip/controller/emoji_controller.dart';
import 'package:splitrip/controller/friend/friend_controller.dart';
import 'package:splitrip/controller/profile_controller.dart';
import 'package:splitrip/controller/trip/trip_controller.dart';
import 'package:splitrip/data/constants.dart';
import 'package:splitrip/services/auth_service.dart';
import 'package:splitrip/views/profile/profile_page.dart';
import 'package:splitrip/views/trip/maintain_trip_screen_.dart';
import 'package:splitrip/views/trip/transaction/add_transaction_screen.dart';
import 'package:splitrip/views/trip/trip_screen.dart';
import 'controller/animation_controller.dart';
import 'controller/button_controller.dart';
import 'controller/theme_controller.dart';
import 'controller/user_controller.dart';
import 'controller/app_page_controller.dart';
import 'views/dashboard.dart';
import 'firebase_options.dart'; // Import AnimationProvider

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform);

  // Register GetX controllers
  Get.put(AuthService());
  Get.put(UserController());
  Get.put(TripController());
  Get.put(FriendController());
  Get.put(AppPageController());
  Get.lazyPut(() => ProfileController(),);

  Get.put(EmojiController());

  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => ThemeController()),
        ChangeNotifierProvider(create: (_) => ButtonState()),
      ],
      child: Consumer<ThemeController>(
        builder: (context, themeController, child) {
          return GetMaterialApp(
            defaultTransition: Transition.rightToLeftWithFade,
            transitionDuration: const Duration(milliseconds: 300),
            debugShowCheckedModeBanner: false,
            themeMode:
                themeController.isDarkMode ? ThemeMode.dark : ThemeMode.light,
            theme: themeController.currentTheme,
            darkTheme: themeController.currentTheme,
            home: DashBoard(),
            getPages: [
              /* GetPage(
                name: Constant().routeSplashActivity,
                page: () => const SplashActivity(),
                //page: () => const DashboardActivity(), IDENTITY_INSERT is set to OFF.
              ),*/
              GetPage(
                name: PageConstant.MaintainTripPage,
                page: () => MaintainTripScreen(),
              ),
              GetPage(name: PageConstant.ProfilePage, page: () => ProfilePage(),),
              GetPage(name: PageConstant.TripScreen, page: () => TripScreen(),),
              GetPage(
                name: PageConstant.AddTransactionScreen,
                page: () =>  AddTransactionScreen(),
              ),

            ],
          );
        },
      ),
    );
  }
}

