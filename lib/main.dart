import 'package:flutter/material.dart';
import 'package:flutter/foundation.dart' show kIsWeb, defaultTargetPlatform, TargetPlatform;
import 'package:sqflite_common_ffi/sqflite_ffi.dart';
import 'package:sqflite_common_ffi_web/sqflite_ffi_web.dart';
import 'app.dart';

/// Entry point of the application.
Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
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
  runApp(const App());
}
