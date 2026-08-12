// TEMPORARY placeholder generated for compilation.
// REPLACE this file with the output of:
//   flutterfire configure --project=<your-gymlife-v2-project-id>
// (or paste the real Firebase config from the Firebase console).
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
    apiKey: 'REPLACE_WITH_WEB_API_KEY',
    appId: 'REPLACE_WITH_WEB_APP_ID',
    messagingSenderId: 'REPLACE_WITH_MESSAGING_SENDER_ID',
    projectId: 'REPLACE_WITH_PROJECT_ID',
    authDomain: 'REPLACE_WITH_PROJECT_ID.firebaseapp.com',
    databaseURL:
        'https://REPLACE_WITH_PROJECT_ID-default-rtdb.asia-southeast1.firebasedatabase.app',
    storageBucket: 'REPLACE_WITH_PROJECT_ID.firebasestorage.app',
    measurementId: 'REPLACE_WITH_MEASUREMENT_ID',
  );

  static const FirebaseOptions android = FirebaseOptions(
    apiKey: 'REPLACE_WITH_ANDROID_API_KEY',
    appId: 'REPLACE_WITH_ANDROID_APP_ID',
    messagingSenderId: 'REPLACE_WITH_MESSAGING_SENDER_ID',
    projectId: 'REPLACE_WITH_PROJECT_ID',
    databaseURL:
        'https://REPLACE_WITH_PROJECT_ID-default-rtdb.asia-southeast1.firebasedatabase.app',
    storageBucket: 'REPLACE_WITH_PROJECT_ID.firebasestorage.app',
  );

  static const FirebaseOptions ios = FirebaseOptions(
    apiKey: 'REPLACE_WITH_IOS_API_KEY',
    appId: 'REPLACE_WITH_IOS_APP_ID',
    messagingSenderId: 'REPLACE_WITH_MESSAGING_SENDER_ID',
    projectId: 'REPLACE_WITH_PROJECT_ID',
    databaseURL:
        'https://REPLACE_WITH_PROJECT_ID-default-rtdb.asia-southeast1.firebasedatabase.app',
    storageBucket: 'REPLACE_WITH_PROJECT_ID.firebasestorage.app',
    iosBundleId: 'com.codemelvin.gymlifeV2',
  );

  static const FirebaseOptions macos = FirebaseOptions(
    apiKey: 'REPLACE_WITH_IOS_API_KEY',
    appId: 'REPLACE_WITH_IOS_APP_ID',
    messagingSenderId: 'REPLACE_WITH_MESSAGING_SENDER_ID',
    projectId: 'REPLACE_WITH_PROJECT_ID',
    databaseURL:
        'https://REPLACE_WITH_PROJECT_ID-default-rtdb.asia-southeast1.firebasedatabase.app',
    storageBucket: 'REPLACE_WITH_PROJECT_ID.firebasestorage.app',
    iosBundleId: 'com.codemelvin.gymlifeV2',
  );

  static const FirebaseOptions windows = FirebaseOptions(
    apiKey: 'REPLACE_WITH_WEB_API_KEY',
    appId: 'REPLACE_WITH_WEB_APP_ID',
    messagingSenderId: 'REPLACE_WITH_MESSAGING_SENDER_ID',
    projectId: 'REPLACE_WITH_PROJECT_ID',
    authDomain: 'REPLACE_WITH_PROJECT_ID.firebaseapp.com',
    databaseURL:
        'https://REPLACE_WITH_PROJECT_ID-default-rtdb.asia-southeast1.firebasedatabase.app',
    storageBucket: 'REPLACE_WITH_PROJECT_ID.firebasestorage.app',
  );
}
