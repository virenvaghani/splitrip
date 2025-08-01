
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:splitrip/controller/friend/friend_controller.dart';
import 'package:splitrip/controller/profile/user_controller.dart';
import 'package:splitrip/controller/trip/trip_controller.dart';
import 'package:splitrip/controller/trip/trip_screen_controller.dart';
import 'package:splitrip/data/authenticate_value.dart';
import 'package:splitrip/data/token.dart';
import 'package:splitrip/services/auth_service.dart';

import '../../widgets/my_snackbar.dart';
import '../appPageController/app_page_controller.dart';

class ProfileController extends GetxController {
  RxBool isloading = false.obs;
  final AuthService authService = Get.find<AuthService>();
  final UserController userController = Get.find<UserController>();
  final TripController tripController = Get.find<TripController>();
  final FriendController friendController = Get.find<FriendController>();
  final AppPageController appPageController = Get.find<AppPageController>();
  final TripScreenController tripScreenController = Get.find<TripScreenController>();


  // Reactive properties for user data
  final RxString userName = ''.obs;
  final RxString userEmail = ''.obs;
  final RxString photoUrl = ''.obs;
  final authToken = RxnString();

  RxBool successLogin = false.obs;

  @override
  void onInit() {
    super.onInit();
    userName.value = userController.userName;
    userEmail.value = userController.userEmail;
    photoUrl.value = userController.photoUrl;
    // Sync user data from UserController to reactive properties
  }

  Future<void> signInWithGoogle(dynamic context) async {
    try {
      print('Opening Google login loader');
      Get.dialog(
        Dialog(
          backgroundColor: Colors.transparent,
          child: Center(
            child: CircularProgressIndicator(
              valueColor: AlwaysStoppedAnimation<Color>(
                Get.theme.colorScheme.primary,
              ),
            ),
          ),
        ),
        barrierDismissible: false,
      );

      final result = await authService.signInWithGoogle();
      print("--------------------------------------------------");
      print(result);
      if (result != null) {
        successLogin.value = true;
        await tripScreenController.fetchAndSetToken();
        await friendController.fetchAndSetToken();
        tripController.isAuthenticated.value = true;
        loadToken();
        appPageController.loadProfileImage();
        appPageController.pageIndex.value = 1;
        Get.back();
        CustomSnackBar.show(
          title: 'Success',
          message: 'Logged in successfully',
        );
      } else {
        Get.back();
        CustomSnackBar.show(
          title: 'Info',
          message: 'Google Sign-In did not return user data',
        );
      }
    } catch (e) {
      Get.back();
      CustomSnackBar.show(
        title: 'Error',
        message: 'Failed to sign in with Google: $e',
      );
    }
  }

  Future<void> signInWithFacebook(dynamic context) async {
    try {
      print('Opening Facebook login loader');
      Get.dialog(
        Dialog(
          backgroundColor: Colors.transparent,
          child: Center(
            child: CircularProgressIndicator(
              valueColor: AlwaysStoppedAnimation<Color>(
                Get.theme.colorScheme.primary,
              ),
            ),
          ),
        ),
        barrierDismissible: false,
      );

      final result = await authService.signInWithFacebook();
      if (result != null) {
        await tripScreenController.fetchAndSetToken();
        await friendController.fetchAndSetToken();
        tripController.isAuthenticated.value = true;
        appPageController.loadProfileImage();
        loadToken();
        appPageController.pageIndex.value = 1;
        Get.back();
        CustomSnackBar.show(
          title: 'Success',
          message: 'Logged in successfully',
        );

      } else {
        Get.back();
        CustomSnackBar.show(
          title: 'Info',
          message: 'Facebook Sign-In did not return user data',
        );
      }
    } catch (e) {
      Get.back();
      String errorMessage = 'Failed to sign in with Facebook';
      if (e is PlatformException) {
        switch (e.code) {
          case 'sign_in_canceled':
            errorMessage = 'Facebook login was canceled';
            break;
          case 'account-exists-with-different-credential':
            errorMessage = 'An account already exists with a different credential';
            break;
          default:
            errorMessage = 'Failed to sign in with Facebook: \${e.message ?? e.toString()}';
        }
      } else {
        errorMessage = 'Failed to sign in with Facebook: \$e';
      }
      CustomSnackBar.show(title: 'Error', message: errorMessage);
      print('Facebook sign-in error: \$e');
    }
  }


  Future<void> signOut() async {
    isloading.value = true;

    try {
      // Optional: Short delay to show loading animation before actual sign-out
      await Future.delayed(const Duration(milliseconds: 500));

      final prefs = await SharedPreferences.getInstance();
      await prefs.remove('auth_token');
      await authService.signOut();
      await userController.clearUser();

      // Ensure other controllers are also cleared
      friendController.clearAllData();
      tripScreenController.clearAllData();
      appPageController.clearProfileImage();

      // Optional: Another short delay for transition feel
      await Future.delayed(const Duration(milliseconds: 1000));

      // Final state changes
      tripController.isAuthenticated.value = false;
      successLogin.value = false;
      authToken.value = null;
      isloading.value = false;
    } catch (e) {
      isloading.value = false; // ensure loading flag is reset even on error
      Get.snackbar('Error', 'Failed to sign out: $e');
    }
  }


  void loadToken() async {
    final token = await TokenStorage.getToken();
    if (token != null) {
      authToken.value = token;
    }
    print("====================================");
    print(token);
  }
}