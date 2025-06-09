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
    apiKey: 'AlzaSyCETH7wV7NKoI4LViJ6HIqh0IViyNn0',
    appId: '1:546130267973:web:your-web-app-id',
    messagingSenderId: '546130267973',
    projectId: 'umrah-visa-manager-50d91',
    authDomain: 'umrah-visa-manager-50d91.firebaseapp.com',
    storageBucket: 'umrah-visa-manager-50d91.appspot.com',
  );

  static const FirebaseOptions android = FirebaseOptions(
    apiKey: 'AlzaSyCETH7wV7NKoI4LViJ6HIqh0IViyNn0',
    appId: '1:546130267973:android:606ba6896e529eaeb6782c',
    messagingSenderId: '546130267973',
    projectId: 'umrah-visa-manager-50d91',
    storageBucket: 'umrah-visa-manager-50d91.appspot.com',
  );

  static const FirebaseOptions ios = FirebaseOptions(
    apiKey: 'AlzaSyCETH7wV7NKoI4LViJ6HIqh0IViyNn0',
    appId: '1:546130267973:ios:your-ios-app-id',
    messagingSenderId: '546130267973',
    projectId: 'umrah-visa-manager-50d91',
    storageBucket: 'umrah-visa-manager-50d91.appspot.com',
    iosBundleId: 'com.example.umrahVisaManager',
  );

  static const FirebaseOptions macos = FirebaseOptions(
    apiKey: 'AlzaSyCETH7wV7NKoI4LViJ6HIqh0IViyNn0',
    appId: '1:546130267973:macos:your-macos-app-id',
    messagingSenderId: '546130267973',
    projectId: 'umrah-visa-manager-50d91',
    storageBucket: 'umrah-visa-manager-50d91.appspot.com',
    iosBundleId: 'com.example.umrahVisaManager',
  );

  static const FirebaseOptions windows = FirebaseOptions(
    apiKey: 'AlzaSyCETH7wV7NKoI4LViJ6HIqh0IViyNn0',
    appId: '1:546130267973:windows:your-windows-app-id',
    messagingSenderId: '546130267973',
    projectId: 'umrah-visa-manager-50d91',
    authDomain: 'umrah-visa-manager-50d91.firebaseapp.com',
    storageBucket: 'umrah-visa-manager-50d91.appspot.com',
  );
}