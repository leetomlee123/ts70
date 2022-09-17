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
    apiKey: 'AIzaSyBIdtpPCLZiU-5et2_cWpVOgCQrbgLqwHQ',
    appId: '1:1091396025886:web:e5a88ea51ce6b1fdcbf80f',
    messagingSenderId: '1091396025886',
    projectId: 'ts70-fe81d',
    authDomain: 'ts70-fe81d.firebaseapp.com',
    storageBucket: 'ts70-fe81d.appspot.com',
    measurementId: 'G-2Y8VDLXLW2',
  );

  static const FirebaseOptions android = FirebaseOptions(
    apiKey: 'AIzaSyAuhCRaeeVPwGCKnT7hKoHTifK9xI007Bg',
    appId: '1:1091396025886:android:466b76892605b446cbf80f',
    messagingSenderId: '1091396025886',
    projectId: 'ts70-fe81d',
    storageBucket: 'ts70-fe81d.appspot.com',
  );

  static const FirebaseOptions ios = FirebaseOptions(
    apiKey: 'AIzaSyBO29BcKSM_71EraF-iY6De1MGN8I1AOCQ',
    appId: '1:1091396025886:ios:30fff23fe43b9d3ccbf80f',
    messagingSenderId: '1091396025886',
    projectId: 'ts70-fe81d',
    storageBucket: 'ts70-fe81d.appspot.com',
    iosClientId: '1091396025886-tgr5th3tt88vqmfgb78vk8rk12lik4qc.apps.googleusercontent.com',
    iosBundleId: 'com.example.ts70',
  );

  static const FirebaseOptions macos = FirebaseOptions(
    apiKey: 'AIzaSyBO29BcKSM_71EraF-iY6De1MGN8I1AOCQ',
    appId: '1:1091396025886:ios:30fff23fe43b9d3ccbf80f',
    messagingSenderId: '1091396025886',
    projectId: 'ts70-fe81d',
    storageBucket: 'ts70-fe81d.appspot.com',
    iosClientId: '1091396025886-tgr5th3tt88vqmfgb78vk8rk12lik4qc.apps.googleusercontent.com',
    iosBundleId: 'com.example.ts70',
  );
}
