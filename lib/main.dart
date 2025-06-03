// lib/main.dart
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:provider/provider.dart';
import 'package:splitrip/controller/profile_controller.dart';
import 'package:splitrip/services/auth_service.dart';
import 'controller/animation_controller.dart';
import 'controller/button_controller.dart';
import 'controller/theme_controller.dart';
import 'controller/user_controller.dart';
import 'controller/app_page_controller.dart';
import 'views/widget_tree.dart';
import 'firebase_options.dart'; // Import AnimationProvider

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform);

  // Register GetX controllers
  Get.put(AuthService());
  Get.put(UserController());
  Get.lazyPut(() => ProfileController());
  Get.put(AppPageController());

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
          return AnimatedTheme(
            data: themeController.currentTheme,
            duration: const Duration(milliseconds: 200),
            child: AnimationProviderWrapper(
              child: GetMaterialApp(
                debugShowCheckedModeBanner: false,
                themeMode: themeController.isDarkMode
                    ? ThemeMode.dark
                    : ThemeMode.light,
                theme: themeController.lightTheme,
                darkTheme: themeController.darkTheme,
                home:  WidgetTree(),
              ),
            ),
          );
        },
      ),
    );
  }
}

// Wrapper widget to provide TickerProvider and AnimationProvider
class AnimationProviderWrapper extends StatefulWidget {
  final Widget child;

  const AnimationProviderWrapper({super.key, required this.child});

  @override
  AnimationProviderWrapperState createState() => AnimationProviderWrapperState();
}

class AnimationProviderWrapperState extends State<AnimationProviderWrapper>
    with TickerProviderStateMixin {
  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider(
      create: (_) => AnimationProvider(this), // Pass this as vsync
      child: widget.child,
    );
  }
}