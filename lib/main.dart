// lib/main.dart

import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:provider/provider.dart';
import 'package:splitrip/controller/splash_screen/splash_screen_controller.dart';
import 'package:splitrip/controller/trip/trip_screen_controller.dart';
import 'package:splitrip/views/trip/archive/archive_screen.dart';
import 'package:splitrip/views/trip/trip_detail/transaction/transaction_screen.dart';
import 'package:splitrip/views/trip/trip_detail/trip_detail_screen.dart';

import 'firebase_options.dart';
import 'data/constants.dart';

// Services & Controllers
import 'services/auth_service.dart';
import 'controller/loginButton/button_controller.dart';
import 'controller/theme/theme_controller.dart';
import 'controller/profile/user_controller.dart';
import 'controller/friend/friend_controller.dart';
import 'controller/emoji_controller/emoji_controller.dart';
import 'controller/trip/trip_controller.dart';
import 'controller/trip/trip_detail_controller.dart';
import 'controller/appPageController/app_page_controller.dart';
import 'controller/participant/participent_selection_controller.dart';

// Views
import 'views/dashboard/dashboard.dart';
import 'views/splash/splash_screen.dart';
import 'views/profile/profile_page.dart';
import 'views/trip/trip_screen/trip_screen.dart';
import 'views/trip/maintain_trip/maintain_trip_screen_.dart';
import 'views/participant/participant_selection_screen.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform);

  // ✅ Global GetX controller registration
  Get.put(AuthService());
  Get.put(UserController());
  Get.put(TripController());
  Get.put(TripScreenController());
  Get.put(FriendController());
  Get.put(AppPageController());
  Get.put(TripDetailController());
  Get.put(EmojiController());
  Get.lazyPut(() => SplashScreenController());
  Get.lazyPut(
    () => TripParticipantSelectorController(0),
  ); // Initialized with dummy tripId

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

            debugShowCheckedModeBanner: false,
            defaultTransition: Transition.rightToLeftWithFade,
            transitionDuration: const Duration(milliseconds: 300),
            themeMode:
                themeController.isDarkMode ? ThemeMode.dark : ThemeMode.light,
            theme: themeController.currentTheme,
            darkTheme: themeController.currentTheme,
            initialRoute: PageConstant.splashScreen,
            getPages: [
              GetPage(
                name: PageConstant.splashScreen,
                page: () =>  SplashScreen(),
              ),
              GetPage(
                name: PageConstant.selectionPage,
                page: () => TripParticipantSelectorPage(),
              ),
              GetPage(
                name: PageConstant.maintainTripPage,
                page: () => MaintainTripScreen(),
              ),
              GetPage(
                name: PageConstant.profilePage,
                page: () => ProfilePage(),
              ),
              GetPage(name: PageConstant.tripScreen, page: () => TripScreen()),
              GetPage(
                name: PageConstant.addTransactionScreen,
                page: () => TransactionScreen(),
              ),
              GetPage(
                name: PageConstant.archiveScreen,
                page: () => ArchiveScreen(),
              ),
              GetPage(
                name: PageConstant.tripDetailScreen,
                page: () => TripDetailScreen(),
              ),
              GetPage(
                name: PageConstant.dashboard,
                page: () =>  DashBoard(),
              ),
            ],
          );
        },
      ),
    );
  }
}
