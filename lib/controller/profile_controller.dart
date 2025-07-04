import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:splitrip/controller/app_page_controller.dart';
import 'package:splitrip/controller/friend/friend_controller.dart';
import 'package:splitrip/controller/trip/trip_controller.dart';
import 'package:splitrip/controller/user_controller.dart';
import 'package:splitrip/services/auth_service.dart';
import '../widgets/my_snackbar.dart';

class ProfileController extends GetxController {
  RxBool isloading = false.obs;
  final AuthService authService = Get.find<AuthService>();
  final UserController userController = Get.find<UserController>();
  final TripController tripController = Get.find<TripController>();
  final FriendController friendController = Get.find<FriendController>();
  final AppPageController appPageController = Get.find<AppPageController>();


  // Reactive properties for user data
  final RxString userName = ''.obs;
  final RxString userEmail = ''.obs;
  final RxString photoUrl = ''.obs;

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
      if (result != null) {
        final user = result['firebaseUser'] as User;
        final providerData = result['providerData'] as Map<String, dynamic>;
        await userController.setUser(
          providerData['displayName'] ?? user.displayName ?? 'Google User',
          providerData['email'] ?? user.email ?? 'Email',
          providerData['photoUrl'] ?? user.photoURL,
        );
        tripController.isAuthenticated.value = true;
        tripController.iniStateMethodForTripScreen(context: context);
        friendController.fetchLinkedParticipants();
        Get.back();
        CustomSnackBar.show(
          title: 'Success',
          message: 'Logged in successfully',
        );
        appPageController.pageIndex.value = 1;
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
        final user = result['firebaseUser'] as User;
        final providerData = result['providerData'] as Map<String, dynamic>;
        await userController.setUser(
          providerData['displayName'] ?? user.displayName ?? 'Facebook User',
          providerData['email'] ?? user.email ?? 'Email',
          providerData['photoUrl'] ?? user.photoURL,
        );
        tripController.isAuthenticated.value = true;
        tripController.iniStateMethodForTripScreen(context: context);
        Get.back();
        CustomSnackBar.show(
          title: 'Success',
          message: 'Logged in successfully',
        );
        appPageController.pageIndex.value = 1;
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
            errorMessage =
                'An account already exists with a different credential';
            break;
          default:
            errorMessage =
                'Failed to sign in with Facebook: ${e.message ?? e.toString()}';
        }
      } else {
        errorMessage = 'Failed to sign in with Facebook: $e';
      }
      CustomSnackBar.show(title: 'Error', message: errorMessage);
      print('Facebook sign-in error: $e');
    }
  }

  Future<void> signOut() async {
    isloading.value = true;
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.remove('auth_token');
      await authService.signOut();
      await userController.clearUser();
      isloading.value = false;
      tripController.isAuthenticated.value = false;
    } catch (e) {
      Get.snackbar('Error', 'Failed to sign out: $e');
    }
  }
}
