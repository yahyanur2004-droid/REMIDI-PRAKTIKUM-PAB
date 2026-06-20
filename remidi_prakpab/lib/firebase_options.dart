import 'package:firebase_core/firebase_core.dart';
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
        return linux;
      default:
        throw UnsupportedError(
          'FirebaseOptions are not supported for this platform.',
        );
    }
  }

  static const FirebaseOptions web = FirebaseOptions(
    apiKey: 'AIzaSyDaYdUWhdLJr4X848kBOQW3NsinXqcsn0k',
    authDomain: 'remidi-13906.firebaseapp.com',
    projectId: 'remidi-13906',
    storageBucket: 'remidi-13906.firebasestorage.app',
    messagingSenderId: '625436442151',
    appId: '1:625436442151:web:86987511c40e22a6f4d802',
    measurementId: 'G-D9CJPR14KX',
  );

  static const FirebaseOptions android = FirebaseOptions(
    apiKey: 'AIzaSyB80kZMavrdhEebN9uA5j_wI_RDFlGyUvk',
    appId: '1:625436442151:android:20cba07720ee520ef4d802',
    messagingSenderId: '625436442151',
    projectId: 'remidi-13906',
    storageBucket: 'remidi-13906.firebasestorage.app',
  );

  static const FirebaseOptions ios = FirebaseOptions(
    apiKey: 'YOUR_IOS_API_KEY',
    appId: 'YOUR_IOS_APP_ID',
    messagingSenderId: 'YOUR_IOS_MESSAGING_SENDER_ID',
    projectId: 'remidi-13906',
    storageBucket: 'remidi-13906.appspot.com',
    iosBundleId: 'com.remidi.pab',
  );

  static const FirebaseOptions macos = FirebaseOptions(
    apiKey: 'YOUR_MACOS_API_KEY',
    appId: 'YOUR_MACOS_APP_ID',
    messagingSenderId: 'YOUR_MACOS_MESSAGING_SENDER_ID',
    projectId: 'remidi-13906',
    storageBucket: 'remidi-13906.appspot.com',
  );

  static const FirebaseOptions windows = FirebaseOptions(
    apiKey: 'YOUR_WINDOWS_API_KEY',
    appId: 'YOUR_WINDOWS_APP_ID',
    messagingSenderId: 'YOUR_WINDOWS_MESSAGING_SENDER_ID',
    projectId: 'remidi-13906',
    storageBucket: 'remidi-13906.appspot.com',
  );

  static const FirebaseOptions linux = windows;
}
