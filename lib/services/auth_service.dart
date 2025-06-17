import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter_facebook_auth/flutter_facebook_auth.dart';
import 'package:get/get.dart';
import 'package:google_sign_in/google_sign_in.dart';
import '../api/api.dart';

class AuthService extends GetxService {
  final GoogleSignIn _googleSignIn = GoogleSignIn(scopes: ['email']);
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FacebookAuth _facebookAuth = FacebookAuth.instance;
  final Rx<User?> _currentUser = Rx<User?>(null);

  @override
  void onInit() {
    super.onInit();
    _auth.authStateChanges().listen((user) {
      _currentUser.value = user;
    });
    _currentUser.value = _auth.currentUser;
  }

  User? get currentUser => _currentUser.value;

  Future<Map<String, dynamic>?> signInWithGoogle() async {
    try {
      print('Starting Google Sign-In');
      final GoogleSignInAccount? googleUser = await _googleSignIn.signIn();
      if (googleUser == null) {
        print('Google Sign-In cancelled by user');
        return null;
      }

      final GoogleSignInAuthentication googleAuth = await googleUser.authentication;
      final credential = GoogleAuthProvider.credential(
        accessToken: googleAuth.accessToken,
        idToken: googleAuth.idToken,
      );

      final userCredential = await _auth.signInWithCredential(credential);
      print('Google Sign-In successful for user: ${googleUser.email}');
      print('Google Sign-In successful for user: ${googleUser.photoUrl}');

      await ApiService().saveUserToBackend(
          email: googleUser.email,
          displayName: googleUser.displayName ?? 'Google User',
          photoUrl: googleUser.photoUrl ?? '',
          provider: 'google',);
      return {
        'firebaseUser': userCredential.user,
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
    }
  }

  Future<Map<String, dynamic>?> signInWithFacebook() async {
    try {
      print('Starting Facebook Sign-In');
      final LoginResult loginResult = await _facebookAuth.login(
        permissions: ['public_profile', 'email'],
      );

      print('Facebook Login Status: ${loginResult.status}');
      print('Facebook Login Message: ${loginResult.message}');
      print('Access Token: ${loginResult.accessToken?.tokenString}');

      if (loginResult.status == LoginStatus.success) {
        final OAuthCredential facebookAuthCredential =
        FacebookAuthProvider.credential(loginResult.accessToken!.tokenString);

        try {
          final userCredential = await _auth.signInWithCredential(facebookAuthCredential);
          final facebookData = await _facebookAuth.getUserData(
            fields: "name,email,picture.width(200)",
          );

          print('Facebook Sign-In successful, user data: $facebookData');

          return {
            'firebaseUser': userCredential.user,
            'providerData': {
              'displayName': facebookData['name'] ?? userCredential.user?.displayName ?? 'Facebook User',
              'email': facebookData['email'] ?? userCredential.user?.email ?? 'Email',
              'photoUrl': facebookData['picture']?['data']?['url'] ?? userCredential.user?.photoURL,
            },
          };
        } on FirebaseAuthException catch (e) {
          print('Firebase Auth error: $e');
          if (e.code == 'account-exists-with-different-credential') {
            print('Existing account found for email: ${e.email}, creating new account');
            // Since multiple accounts are allowed, retry with a new credential
            try {
              final userCredential = await _auth.signInWithCredential(facebookAuthCredential);
              final facebookData = await _facebookAuth.getUserData(
                fields: "name,email,picture.width(200)",
              );
              await ApiService().saveUserToBackend(
                email: facebookData['email'] ?? userCredential.user?.email ?? '',
                displayName: facebookData['name'] ?? userCredential.user?.displayName ?? 'Facebook User',
                photoUrl: facebookData['picture']?['data']?['url'] ?? userCredential.user?.photoURL ?? '',
                provider: 'facebook',
              );
              print('New Facebook account created, user data: $facebookData');
              return {
                'firebaseUser': userCredential.user,
                'providerData': {
                  'displayName': facebookData['name'] ?? userCredential.user?.displayName ?? 'Facebook User',
                  'email': facebookData['email'] ?? userCredential.user?.email ?? 'Email',
                  'photoUrl': facebookData['picture']?['data']?['url'] ?? userCredential.user?.photoURL,
                },
              };
            } catch (retryError) {
              print('Failed to create new Facebook account: $retryError');
              Get.snackbar('Error', 'Failed to create Facebook account: $retryError');
              return null;
            }
          } else {
            Get.snackbar('Error', 'Facebook Sign-In failed: $e');
            return null;
          }
        }
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
    }
  }

  Future<void> signOut() async {
    try {
      await _googleSignIn.signOut();
      await _facebookAuth.logOut();
      await _auth.signOut();
    } catch (e) {
      print('Sign-out error: $e');
      Get.snackbar('Error', 'Sign-out failed: $e');
    }
  }
}

