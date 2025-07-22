import 'package:get/get.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:splitrip/data/authenticate_value.dart';

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

  // Future<void> setUserFromProvider({
  //   required String provider,
  //   required Map<String, dynamic> providerData,
  // }) async {
  //   String name = 'Guest';
  //   String email = 'Email';
  //   String imageUrl = '';
  //   try {
  //
  //
  //     if (provider == 'facebook') {
  //       name = providerData['name'] ?? 'Facebook User';
  //       email = providerData['email'] ?? 'Email';
  //       imageUrl = providerData['picture']?['data']?['url'] ?? '';
  //     } else if (provider == 'google') {
  //       name = providerData['displayName'] ?? 'Google User';
  //       email = providerData['email'] ?? 'Email';
  //       imageUrl = providerData['photoUrl'] ?? '';
  //     }
  //     _loadUser();
  //
  //   } catch (e) {
  //     Get.snackbar('Error', 'Failed to save user data: \$e');
  //   }
  // }

  Future<void> _loadUser() async {
    try {
      _userName.value = (await AuthStatusStorage.getUserName()) ?? 'Guest';
      _userEmail.value = (await AuthStatusStorage.getUserEmail()) ?? 'Email';
      _photoURL.value = (await AuthStatusStorage.getUserImage()) ?? '';

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
        _userName.value = name;
        _userEmail.value = email;
        _photoURL.value = photoURL ?? '';

      }
    } catch (e) {
      Get.snackbar('Error', 'Failed to sync with Firebase: \$e');
    }
  }

  Future<void> clearUser() async {
    try {
      _userName.value = 'Guest';
      _userEmail.value = 'Email';
      _photoURL.value = '';
      await AuthStatusStorage.clearAllUserData();
    } catch (e) {
      Get.snackbar('Error', 'Failed to clear user data: \$e');
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
    _loadUser();
  }
}
