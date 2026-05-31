import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'dart:ui';
import 'package:flutter/foundation.dart' show kIsWeb, defaultTargetPlatform, TargetPlatform;
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_crashlytics/firebase_crashlytics.dart';
import 'package:sqflite_common_ffi/sqflite_ffi.dart';
import 'package:sqflite_common_ffi_web/sqflite_ffi_web.dart';
import 'app.dart';
import 'firebase_options.dart';
import 'src/payments/purchase_service.dart';
import 'src/core/remote_config_service.dart';

/// Entry point of the application.
Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform);

  FlutterError.onError = FirebaseCrashlytics.instance.recordFlutterFatalError;
  PlatformDispatcher.instance.onError = (error, stack) {
    FirebaseCrashlytics.instance.recordError(error, stack, fatal: true);
    return true;
  };

  await RemoteConfigService.instance.init();

  // Set edge-to-edge system UI mode
  SystemChrome.setEnabledSystemUIMode(SystemUiMode.edgeToEdge);

  // Configure cross-platform database backends so analytics persist on all targets
  if (kIsWeb) {
    databaseFactory = databaseFactoryFfiWeb; // IndexedDB backend via sqflite API
  } else {
    switch (defaultTargetPlatform) {
      case TargetPlatform.windows:
      case TargetPlatform.linux:
      case TargetPlatform.macOS:
        sqfliteFfiInit();
        databaseFactory = databaseFactoryFfi; // Native SQLite via FFI
        break;
      default:
        // Android/iOS use default sqflite
        break;
    }
  }
  
  // Initialize PurchaseService to check for active subscriptions
  await PurchaseService.instance.init();

  runApp(const App());
}
