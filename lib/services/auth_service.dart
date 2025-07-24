  import 'package:firebase_auth/firebase_auth.dart';
  import 'package:flutter_facebook_auth/flutter_facebook_auth.dart';
  import 'package:get/get.dart';
  import 'package:google_sign_in/google_sign_in.dart';
  import 'package:shared_preferences/shared_preferences.dart';
  import '../api/api.dart';

class AuthService extends GetxService {
  final GoogleSignIn _googleSignIn = GoogleSignIn.standard(scopes: ['email']);
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FacebookAuth _facebookAuth = FacebookAuth.instance;

  final Rx<User?> _currentUser = Rx<User?>(null);
  final RxBool isSigningIn = false.obs;

  @override
  void onInit() {
    super.onInit();
    _auth.authStateChanges().listen((user) {
      _currentUser.value = user;
    });
    _currentUser.value = _auth.currentUser;
  }

  User? get currentUser => _currentUser.value;

  bool isLoggedIn() => _auth.currentUser != null;

  Stream<bool> get isLoggedInStream =>
      _auth.authStateChanges().map((user) => user != null);

  Future<Map<String, dynamic>?> signInWithGoogle() async {
    isSigningIn.value = true;
    try {
      print('Starting Google Sign-In');

      // Attempt Google Sign-In
      final GoogleSignInAccount? googleUser = await _googleSignIn.signIn();

      if (googleUser == null) {
        print('Google Sign-In cancelled by user');
        return null;
      }

      final GoogleSignInAuthentication googleAuth =
      await googleUser.authentication;

      final AuthCredential credential = GoogleAuthProvider.credential(
        accessToken: googleAuth.accessToken,
        idToken: googleAuth.idToken,
      );

      final UserCredential userCredential =
      await _auth.signInWithCredential(credential);

      final User? firebaseUser = userCredential.user;
      final String? idToken = await firebaseUser?.getIdToken();

      print('Google Sign-In successful: ${firebaseUser?.email}');

      // Send user data to backend
      await ApiService().saveUserToBackend(
        email: googleUser.email,
        displayName: googleUser.displayName ?? 'Google User',
        photoUrl: googleUser.photoUrl ?? '',
        provider: 'google',
      );

      // Optionally store Firebase ID token
      final prefs = await SharedPreferences.getInstance();
      await prefs.setString('firebase_id_token', idToken ?? '');

      return {
        'firebaseUser': firebaseUser,
        'providerData': {
          'displayName': googleUser.displayName,
          'email': googleUser.email,
          'photoUrl': googleUser.photoUrl,
        },
      };
    } catch (e, stackTrace) {
      print('Google Sign-In error: $e\nStackTrace: $stackTrace');
      Get.snackbar('Error', 'Google Sign-In failed: $e');
      return null;
    } finally {
      isSigningIn.value = false;
    }
  }

  Future<Map<String, dynamic>?> signInWithFacebook() async {
    isSigningIn.value = true;
    try {
      print('Starting Facebook Sign-In');

      final LoginResult loginResult = await _facebookAuth.login(
        permissions: ['public_profile', 'email'],
      );

      if (loginResult.status == LoginStatus.success) {
        final OAuthCredential credential =
        FacebookAuthProvider.credential(loginResult.accessToken!.tokenString);

        final UserCredential userCredential =
        await _auth.signInWithCredential(credential);

        final facebookData = await _facebookAuth.getUserData(
          fields: "name,email,picture.width(200)",
        );

        final firebaseUser = userCredential.user;
        final idToken = await firebaseUser?.getIdToken();

        final String email = facebookData['email'] ??
            firebaseUser?.email ??
            'unknown@facebook.com';

        await ApiService().saveUserToBackend(
          email: email,
          displayName:
          facebookData['name'] ?? firebaseUser?.displayName ?? 'Facebook User',
          photoUrl:
          facebookData['picture']?['data']?['url'] ?? firebaseUser?.photoURL ?? '',
          provider: 'facebook',
        );

        final prefs = await SharedPreferences.getInstance();
        await prefs.setString('firebase_id_token', idToken ?? '');

        return {
          'firebaseUser': firebaseUser,
          'providerData': {
            'displayName': facebookData['name'],
            'email': email,
            'photoUrl': facebookData['picture']?['data']?['url'],
          },
        };
      } else if (loginResult.status == LoginStatus.cancelled) {
        print('Facebook Sign-In cancelled');
        return null;
      } else {
        Get.snackbar('Error', 'Facebook login failed: ${loginResult.message}');
        return null;
      }
    } catch (e, stackTrace) {
      print('Facebook Sign-In error: $e\nStackTrace: $stackTrace');
      Get.snackbar('Error', 'Facebook Sign-In failed: $e');
      return null;
    } finally {
      isSigningIn.value = false;
    }
  }

  Future<void> signOut() async {
    try {
      await _googleSignIn.signOut();
      await _facebookAuth.logOut();
      await _auth.signOut();
      final prefs = await SharedPreferences.getInstance();
      await prefs.remove('firebase_id_token');
    } catch (e) {
      print('Sign-out error: $e');
      Get.snackbar('Error', 'Sign-out failed: $e');
    }
  }
}
