// File generated by FlutterFire CLI.
// ignore_for_file: type=lint
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
        return windows;
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
    apiKey: 'AIzaSyD5MVW2LPTze4SpKjT1YUQSeaTKaB8a4pM',
    appId: '1:833748789546:web:acc6afaa0a12e3d4f25653',
    messagingSenderId: '833748789546',
    projectId: 'glicometrics',
    authDomain: 'glicometrics.firebaseapp.com',
    storageBucket: 'glicometrics.appspot.com',
    measurementId: 'G-4NC5B7R7P3',
  );

  static const FirebaseOptions android = FirebaseOptions(
    apiKey: 'AIzaSyCMI7EVs8ZBIkOQqIdT7XdlcJCyQ8Ik520',
    appId: '1:833748789546:android:b39dc9ac0377e45cf25653',
    messagingSenderId: '833748789546',
    projectId: 'glicometrics',
    storageBucket: 'glicometrics.appspot.com',
  );

  static const FirebaseOptions ios = FirebaseOptions(
    apiKey: 'AIzaSyDleY9aUGdiECK8mWQUD3DRwer5rOMgerE',
    appId: '1:833748789546:ios:3a896c15aa101ac2f25653',
    messagingSenderId: '833748789546',
    projectId: 'glicometrics',
    storageBucket: 'glicometrics.appspot.com',
    iosBundleId: 'com.example.main',
  );

  static const FirebaseOptions macos = FirebaseOptions(
    apiKey: 'AIzaSyDleY9aUGdiECK8mWQUD3DRwer5rOMgerE',
    appId: '1:833748789546:ios:3a896c15aa101ac2f25653',
    messagingSenderId: '833748789546',
    projectId: 'glicometrics',
    storageBucket: 'glicometrics.appspot.com',
    iosBundleId: 'com.example.main',
  );

  static const FirebaseOptions windows = FirebaseOptions(
    apiKey: 'AIzaSyD5MVW2LPTze4SpKjT1YUQSeaTKaB8a4pM',
    appId: '1:833748789546:web:6a3cec0e5fd3bd21f25653',
    messagingSenderId: '833748789546',
    projectId: 'glicometrics',
    authDomain: 'glicometrics.firebaseapp.com',
    storageBucket: 'glicometrics.appspot.com',
    measurementId: 'G-4Y7R8PT649',
  );

}