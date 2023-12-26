// File generated by FlutterFire CLI.
// ignore_for_file: lines_longer_than_80_chars, avoid_classes_with_only_static_members
import 'package:firebase_core/firebase_core.dart' show FirebaseOptions;
import 'package:flutter/foundation.dart'
    show defaultTargetPlatform, kIsWeb, TargetPlatform;

/// Default [FirebaseOptions] for use with your Firebase apps.
///
/// Example:
/// ```dart
/// import 'firebase_options.dart';
/// // ...
/// await Firebase.initializeApp(
///   options: DefaultFirebaseOptions.currentPlatform,
/// );
/// ```
class DefaultFirebaseOptions {
  static FirebaseOptions get currentPlatform {
    if (kIsWeb) {
      return web;
    }
    switch (defaultTargetPlatform) {
      case TargetPlatform.android:
        return android;
      case TargetPlatform.iOS:
        return ios;
      case TargetPlatform.macOS:
        return macos;
      case TargetPlatform.windows:
        throw UnsupportedError(
          'DefaultFirebaseOptions have not been configured for windows - '
          'you can reconfigure this by running the FlutterFire CLI again.',
        );
      case TargetPlatform.linux:
        throw UnsupportedError(
          'DefaultFirebaseOptions have not been configured for linux - '
          'you can reconfigure this by running the FlutterFire CLI again.',
        );
      default:
        throw UnsupportedError(
          'DefaultFirebaseOptions are not supported for this platform.',
        );
    }
  }

  static const FirebaseOptions web = FirebaseOptions(
    apiKey: 'AIzaSyCwjaiReQysLa2CIM6vxGBv4tMihaCSsp0',
    appId: '1:1069065982306:web:1707d5ca6ab3fbb9fedc3b',
    messagingSenderId: '1069065982306',
    projectId: 'm1-point-of-sale',
    authDomain: 'm1-point-of-sale.firebaseapp.com',
    storageBucket: 'm1-point-of-sale.appspot.com',
    measurementId: 'G-HW98QFXLW9',
  );

  static const FirebaseOptions android = FirebaseOptions(
    apiKey: 'AIzaSyDzBjcEWw_lXVyeqrmPvllJB-NUeO-kD1o',
    appId: '1:1069065982306:android:dc65a73a07871b58fedc3b',
    messagingSenderId: '1069065982306',
    projectId: 'm1-point-of-sale',
    storageBucket: 'm1-point-of-sale.appspot.com',
  );

  static const FirebaseOptions ios = FirebaseOptions(
    apiKey: 'AIzaSyD9FBJ95VfJaK_vFl-bBgePSkULNI5fIsc',
    appId: '1:1069065982306:ios:a35799e3441f2e43fedc3b',
    messagingSenderId: '1069065982306',
    projectId: 'm1-point-of-sale',
    storageBucket: 'm1-point-of-sale.appspot.com',
    iosClientId: '1069065982306-8s72a7103cjfe9q9onkq28gee7jm9epf.apps.googleusercontent.com',
    iosBundleId: 'com.example.flutterPosRevised',
  );

  static const FirebaseOptions macos = FirebaseOptions(
    apiKey: 'AIzaSyD9FBJ95VfJaK_vFl-bBgePSkULNI5fIsc',
    appId: '1:1069065982306:ios:023e2a8adcbebd17fedc3b',
    messagingSenderId: '1069065982306',
    projectId: 'm1-point-of-sale',
    storageBucket: 'm1-point-of-sale.appspot.com',
    iosClientId: '1069065982306-9c4rb7psl3st66tl01q2jrn8iogo1cub.apps.googleusercontent.com',
    iosBundleId: 'com.example.flutterPosRevised.RunnerTests',
  );
}