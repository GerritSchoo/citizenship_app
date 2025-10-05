import 'package:flutter/material.dart';
import 'src/screens/home_screen.dart';
import 'src/screens/initial_setup_screen.dart';
import 'src/theme/app_theme.dart';
import 'src/core/prefs.dart';

class App extends StatefulWidget {
  const App({super.key});

  @override
  State<App> createState() => _AppState();
}

class _AppState extends State<App> {
  String? _initialStateCode;
  bool _loading = true;

  @override
  void initState() {
    super.initState();
    _loadPrefs();
  }

  Future<void> _loadPrefs() async {
    final code = await AppPrefs.getSelectedState();
    if (!mounted) return;
    setState(() {
      _initialStateCode = code;
      _loading = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    if (_loading) {
      return MaterialApp(home: const Scaffold(body: Center(child: CircularProgressIndicator())));
    }

    return MaterialApp(
      title: 'Citizenship Test Quiz',
      debugShowCheckedModeBanner: false,
      theme: AppTheme.lightTheme,
      darkTheme: AppTheme.darkTheme,
      themeMode: ThemeMode.system,
      home: _initialStateCode == null ? const InitialSetupScreen() : const HomeScreen(),
    );
  }
}
