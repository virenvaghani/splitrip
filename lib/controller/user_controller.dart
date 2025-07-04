import 'package:get/get.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../data/constants.dart';

class UserController extends GetxController {
  final RxString _userName = ''.obs;
  final RxString _userEmail = ''.obs;
  final RxString _photoURL = ''.obs;
  final Rxn<User> firebaseUser = Rxn<User>();

  UserController() {
    _loadUser();
    _syncWithFirebase();
  }

  String get userName => _userName.value;
  String get userEmail => _userEmail.value;
  String get photoUrl => _photoURL.value;

  Future<void> setUser(String name, String email, [String? photoURL]) async {
    try {
      _userName.value = name.isNotEmpty ? name : 'Guest';
      _userEmail.value = email.isNotEmpty ? email : 'Email';
      _photoURL.value = photoURL?.isNotEmpty == true ? photoURL! : '';
      final SharedPreferences prefs = await SharedPreferences.getInstance();
      await prefs.setString(Kconstant.UserNameKey, _userName.value);
      await prefs.setString(Kconstant.UserEmail, _userEmail.value);
      await prefs.setString(Kconstant.photoURL, _photoURL.value);
    } catch (e) {
      Get.snackbar('Error', 'Failed to save user data: $e');
    }
  }

  Future<void> _loadUser() async {
    try {
      final SharedPreferences prefs = await SharedPreferences.getInstance();
      _userName.value = prefs.getString(Kconstant.UserNameKey) ?? 'Guest';
      _userEmail.value = prefs.getString(Kconstant.UserEmail) ?? 'Email';
      _photoURL.value = prefs.getString(Kconstant.photoURL) ?? '';
    } catch (e) {
      Get.snackbar('Error', 'Failed to load user data: $e');
    }
  }

  Future<void> _syncWithFirebase() async {
    try {
      final User? user = FirebaseAuth.instance.currentUser;
      if (user != null) {
        final String name = user.displayName ?? 'Guest';
        final String email = user.email ?? 'Email';
        final String? photoURL = user.photoURL;
        await setUser(name, email, photoURL);
      }
    } catch (e) {
      Get.snackbar('Error', 'Failed to sync with Firebase: $e');
    }
  }

  Future<void> clearUser() async {
    try {
      _userName.value = 'Guest';
      _userEmail.value = 'Email';
      _photoURL.value = '';
      final SharedPreferences prefs = await SharedPreferences.getInstance();
      await prefs.remove(Kconstant.UserNameKey);
      await prefs.remove(Kconstant.UserEmail);
      await prefs.remove(Kconstant.photoURL);
    } catch (e) {
      Get.snackbar('Error', 'Failed to clear user data: $e');
    }
  }

  void listenToAuthChanges() {
    FirebaseAuth.instance.authStateChanges().listen((User? user) async {
      firebaseUser.value = user;
      if (user != null) {
        await _syncWithFirebase();
      } else {
        await clearUser();
      }
    });
  }

  @override
  void onInit() {
    super.onInit();
    listenToAuthChanges();
  }
}