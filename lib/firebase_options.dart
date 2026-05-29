// This file is a placeholder. You need to configure Firebase for your project.
// Follow these steps to set up Firebase:
//
// 1. Install Firebase CLI and FlutterFire CLI:
//    npm install -g firebase-tools
//    dart pub global activate flutterfire_cli
//
// 2. Login to Firebase:
//    firebase login
//
// 3. Create a Firebase project at https://console.firebase.google.com/
//
// 4. Run FlutterFire configure from your project root:
//    flutterfire configure
//
//    This will:
//    - Connect your Flutter app to your Firebase project
//    - Generate this file (firebase_options.dart) with your project's configuration
//    - Configure platform-specific files (AndroidManifest.xml, Info.plist, etc.)
//
// 5. Enable Authentication methods in Firebase Console:
//    - Go to Authentication > Sign-in method
//    - Enable Email/Password
//    - Enable Google Sign-In (and configure OAuth consent screen)
//
// TEMPORARY: Placeholder for development
// This will be replaced when you run 'flutterfire configure'

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
          'you need to run `flutterfire configure` to generate firebase_options.dart',
        );
      default:
        throw UnsupportedError(
          'DefaultFirebaseOptions are not supported for this platform.',
        );
    }
  }

  static const FirebaseOptions web = FirebaseOptions(
    apiKey: 'AIzaSyCjCashccDMxQaiWqzUM_G3erZ4Omtm3Ts',
    appId: '1:150585545366:web:79c3f779c53bbd5d5028b7',
    messagingSenderId: '150585545366',
    projectId: 'ally-by-avea',
    authDomain: 'ally-by-avea.firebaseapp.com',
    databaseURL: 'https://ally-by-avea-default-rtdb.firebaseio.com',
    storageBucket: 'ally-by-avea.firebasestorage.app',
    measurementId: 'G-7TEYDZTZBT',
  );

  static const FirebaseOptions macos = FirebaseOptions(
    apiKey: 'AIzaSyC_VURhbKgPbrLzM4AanwCAUGzRMuoemic',
    appId: '1:150585545366:ios:26437e80f17c8ac85028b7',
    messagingSenderId: '150585545366',
    projectId: 'ally-by-avea',
    databaseURL: 'https://ally-by-avea-default-rtdb.firebaseio.com',
    storageBucket: 'ally-by-avea.firebasestorage.app',
    iosClientId: '150585545366-023rvvecsblleg87tvtsca6fsi5vqjs9.apps.googleusercontent.com',
    iosBundleId: 'com.example.explorationProject',
  );

  static const FirebaseOptions ios = FirebaseOptions(
    apiKey: 'AIzaSyC_VURhbKgPbrLzM4AanwCAUGzRMuoemic',
    appId: '1:150585545366:ios:26437e80f17c8ac85028b7',
    messagingSenderId: '150585545366',
    projectId: 'ally-by-avea',
    databaseURL: 'https://ally-by-avea-default-rtdb.firebaseio.com',
    storageBucket: 'ally-by-avea.firebasestorage.app',
    iosClientId: '150585545366-023rvvecsblleg87tvtsca6fsi5vqjs9.apps.googleusercontent.com',
    iosBundleId: 'com.example.explorationProject',
  );

  static const FirebaseOptions android = FirebaseOptions(
    apiKey: 'AIzaSyBmxO5cBcTfH8ZAQVxvKqVSp5x2GNY7s3E',
    appId: '1:150585545366:android:80e04bb1d6754a6a5028b7',
    messagingSenderId: '150585545366',
    projectId: 'ally-by-avea',
    databaseURL: 'https://ally-by-avea-default-rtdb.firebaseio.com',
    storageBucket: 'ally-by-avea.firebasestorage.app',
  );

  static const FirebaseOptions windows = FirebaseOptions(
    apiKey: 'AIzaSyCjCashccDMxQaiWqzUM_G3erZ4Omtm3Ts',
    appId: '1:150585545366:web:a58b210068ec9c155028b7',
    messagingSenderId: '150585545366',
    projectId: 'ally-by-avea',
    authDomain: 'ally-by-avea.firebaseapp.com',
    databaseURL: 'https://ally-by-avea-default-rtdb.firebaseio.com',
    storageBucket: 'ally-by-avea.firebasestorage.app',
    measurementId: 'G-M2YVPJV9R7',
  );

}