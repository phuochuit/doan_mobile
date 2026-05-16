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
        throw UnsupportedError(
          'DefaultFirebaseOptions have not been configured for ios - '
          'you can reconfigure this by running the FlutterFire CLI again.',
        );
      case TargetPlatform.macOS:
        throw UnsupportedError(
          'DefaultFirebaseOptions have not been configured for macos - '
          'you can reconfigure this by running the FlutterFire CLI again.',
        );
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
    apiKey: 'AIzaSyCaSCwk-LJQegHyk8TJglrno-WxgVx9tPI',
    appId: '1:229867903592:web:8c45432cc05d7531bf39dd',
    messagingSenderId: '229867903592',
    projectId: 'doanflutter-eb304',
    authDomain: 'doanflutter-eb304.firebaseapp.com',
    storageBucket: 'doanflutter-eb304.firebasestorage.app',
    measurementId: 'G-LYCKY1TP7G',
  );

  static const FirebaseOptions android = FirebaseOptions(
    apiKey: 'AIzaSyDrQEuI0wUNphaeTD9JdZ7fKec226Gjx90',
    appId: '1:229867903592:android:5faefb5c3b9ba2c8bf39dd',
    messagingSenderId: '229867903592',
    projectId: 'doanflutter-eb304',
    storageBucket: 'doanflutter-eb304.firebasestorage.app',
  );

  static const FirebaseOptions windows = FirebaseOptions(
    apiKey: 'AIzaSyCaSCwk-LJQegHyk8TJglrno-WxgVx9tPI',
    appId: '1:229867903592:web:d0b9b2b3ed1b5b46bf39dd',
    messagingSenderId: '229867903592',
    projectId: 'doanflutter-eb304',
    authDomain: 'doanflutter-eb304.firebaseapp.com',
    storageBucket: 'doanflutter-eb304.firebasestorage.app',
    measurementId: 'G-7WTMZ9CY6E',
  );

}