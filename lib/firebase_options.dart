import 'package:firebase_core/firebase_core.dart' show FirebaseOptions;
import 'package:flutter/foundation.dart'
    show defaultTargetPlatform, kIsWeb, TargetPlatform;

class DefaultFirebaseOptions {
  static FirebaseOptions get currentPlatform {
    if (kIsWeb) {
      throw UnsupportedError('Web platform is not configured');
    }
    switch (defaultTargetPlatform) {
      case TargetPlatform.android:
        return android;
      case TargetPlatform.iOS:
        throw UnsupportedError('iOS platform is not configured');
      default:
        throw UnsupportedError('Unsupported platform');
    }
  }

  static const FirebaseOptions android = FirebaseOptions(
    apiKey: 'AIzaSyBzCYIQ66bDk50JUMONec0jIxAc2f4ws5E',
    appId: '1:277675518255:android:8295fcffe37fd4ff2959da',
    messagingSenderId: '277675518255',
    projectId: 'splitrip-b619f',
    storageBucket: 'splitrip-b619f.firebasestorage.app',
  );
}