// Firebase configuration for GymLife v2.
//
// The real Firebase project credentials are NOT committed to this repository.
// They are injected at build time via --dart-define, for example:
//
//   flutter build web --release \
//     --dart-define=FIREBASE_WEB_API_KEY=... \
//     --dart-define=FIREBASE_WEB_APP_ID=... \
//     --dart-define=FIREBASE_ANDROID_API_KEY=... \
//     --dart-define=FIREBASE_ANDROID_APP_ID=... \
//     --dart-define=FIREBASE_IOS_API_KEY=... \
//     --dart-define=FIREBASE_IOS_APP_ID=... \
//     --dart-define=FIREBASE_MESSAGING_SENDER_ID=... \
//     --dart-define=FIREBASE_PROJECT_ID=... \
//     --dart-define=FIREBASE_AUTH_DOMAIN=... \
//     --dart-define=FIREBASE_DATABASE_URL=... \
//     --dart-define=FIREBASE_STORAGE_BUCKET=... \
//     --dart-define=FIREBASE_WEB_MEASUREMENT_ID=...
//
// Alternatively, run `flutterfire configure` to regenerate this file with your
// own Firebase project's values. Values left as defaults will not connect.
// ignore_for_file: type=lint
import 'package:firebase_core/firebase_core.dart' show FirebaseOptions;
import 'package:flutter/foundation.dart'
    show defaultTargetPlatform, kIsWeb, TargetPlatform;

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
    apiKey: String.fromEnvironment(
      'FIREBASE_WEB_API_KEY',
      defaultValue: 'YOUR_WEB_API_KEY',
    ),
    appId: String.fromEnvironment(
      'FIREBASE_WEB_APP_ID',
      defaultValue: 'YOUR_WEB_APP_ID',
    ),
    messagingSenderId: String.fromEnvironment(
      'FIREBASE_MESSAGING_SENDER_ID',
      defaultValue: 'YOUR_MESSAGING_SENDER_ID',
    ),
    projectId: String.fromEnvironment(
      'FIREBASE_PROJECT_ID',
      defaultValue: 'YOUR_PROJECT_ID',
    ),
    authDomain: String.fromEnvironment(
      'FIREBASE_AUTH_DOMAIN',
      defaultValue: 'YOUR_PROJECT_ID.firebaseapp.com',
    ),
    databaseURL: String.fromEnvironment(
      'FIREBASE_DATABASE_URL',
      defaultValue: 'YOUR_DATABASE_URL',
    ),
    storageBucket: String.fromEnvironment(
      'FIREBASE_STORAGE_BUCKET',
      defaultValue: 'YOUR_PROJECT_ID.firebasestorage.app',
    ),
    measurementId: String.fromEnvironment(
      'FIREBASE_WEB_MEASUREMENT_ID',
      defaultValue: 'YOUR_MEASUREMENT_ID',
    ),
  );

  static const FirebaseOptions android = FirebaseOptions(
    apiKey: String.fromEnvironment(
      'FIREBASE_ANDROID_API_KEY',
      defaultValue: 'YOUR_ANDROID_API_KEY',
    ),
    appId: String.fromEnvironment(
      'FIREBASE_ANDROID_APP_ID',
      defaultValue: 'YOUR_ANDROID_APP_ID',
    ),
    messagingSenderId: String.fromEnvironment(
      'FIREBASE_MESSAGING_SENDER_ID',
      defaultValue: 'YOUR_MESSAGING_SENDER_ID',
    ),
    projectId: String.fromEnvironment(
      'FIREBASE_PROJECT_ID',
      defaultValue: 'YOUR_PROJECT_ID',
    ),
    databaseURL: String.fromEnvironment(
      'FIREBASE_DATABASE_URL',
      defaultValue: 'YOUR_DATABASE_URL',
    ),
    storageBucket: String.fromEnvironment(
      'FIREBASE_STORAGE_BUCKET',
      defaultValue: 'YOUR_PROJECT_ID.firebasestorage.app',
    ),
  );

  static const FirebaseOptions ios = FirebaseOptions(
    apiKey: String.fromEnvironment(
      'FIREBASE_IOS_API_KEY',
      defaultValue: 'YOUR_IOS_API_KEY',
    ),
    appId: String.fromEnvironment(
      'FIREBASE_IOS_APP_ID',
      defaultValue: 'YOUR_IOS_APP_ID',
    ),
    messagingSenderId: String.fromEnvironment(
      'FIREBASE_MESSAGING_SENDER_ID',
      defaultValue: 'YOUR_MESSAGING_SENDER_ID',
    ),
    projectId: String.fromEnvironment(
      'FIREBASE_PROJECT_ID',
      defaultValue: 'YOUR_PROJECT_ID',
    ),
    databaseURL: String.fromEnvironment(
      'FIREBASE_DATABASE_URL',
      defaultValue: 'YOUR_DATABASE_URL',
    ),
    storageBucket: String.fromEnvironment(
      'FIREBASE_STORAGE_BUCKET',
      defaultValue: 'YOUR_PROJECT_ID.firebasestorage.app',
    ),
    iosBundleId: String.fromEnvironment(
      'FIREBASE_IOS_BUNDLE_ID',
      defaultValue: 'com.codemelvin.gymlifeV2',
    ),
  );

  static const FirebaseOptions macos = FirebaseOptions(
    apiKey: String.fromEnvironment(
      'FIREBASE_IOS_API_KEY',
      defaultValue: 'YOUR_IOS_API_KEY',
    ),
    appId: String.fromEnvironment(
      'FIREBASE_IOS_APP_ID',
      defaultValue: 'YOUR_IOS_APP_ID',
    ),
    messagingSenderId: String.fromEnvironment(
      'FIREBASE_MESSAGING_SENDER_ID',
      defaultValue: 'YOUR_MESSAGING_SENDER_ID',
    ),
    projectId: String.fromEnvironment(
      'FIREBASE_PROJECT_ID',
      defaultValue: 'YOUR_PROJECT_ID',
    ),
    databaseURL: String.fromEnvironment(
      'FIREBASE_DATABASE_URL',
      defaultValue: 'YOUR_DATABASE_URL',
    ),
    storageBucket: String.fromEnvironment(
      'FIREBASE_STORAGE_BUCKET',
      defaultValue: 'YOUR_PROJECT_ID.firebasestorage.app',
    ),
    iosBundleId: String.fromEnvironment(
      'FIREBASE_IOS_BUNDLE_ID',
      defaultValue: 'com.codemelvin.gymlifeV2',
    ),
  );

  static const FirebaseOptions windows = FirebaseOptions(
    apiKey: String.fromEnvironment(
      'FIREBASE_WEB_API_KEY',
      defaultValue: 'YOUR_WEB_API_KEY',
    ),
    appId: String.fromEnvironment(
      'FIREBASE_WEB_APP_ID',
      defaultValue: 'YOUR_WEB_APP_ID',
    ),
    messagingSenderId: String.fromEnvironment(
      'FIREBASE_MESSAGING_SENDER_ID',
      defaultValue: 'YOUR_MESSAGING_SENDER_ID',
    ),
    projectId: String.fromEnvironment(
      'FIREBASE_PROJECT_ID',
      defaultValue: 'YOUR_PROJECT_ID',
    ),
    authDomain: String.fromEnvironment(
      'FIREBASE_AUTH_DOMAIN',
      defaultValue: 'YOUR_PROJECT_ID.firebaseapp.com',
    ),
    databaseURL: String.fromEnvironment(
      'FIREBASE_DATABASE_URL',
      defaultValue: 'YOUR_DATABASE_URL',
    ),
    storageBucket: String.fromEnvironment(
      'FIREBASE_STORAGE_BUCKET',
      defaultValue: 'YOUR_PROJECT_ID.firebasestorage.app',
    ),
    measurementId: String.fromEnvironment(
      'FIREBASE_WEB_MEASUREMENT_ID',
      defaultValue: 'YOUR_MEASUREMENT_ID',
    ),
  );
}
