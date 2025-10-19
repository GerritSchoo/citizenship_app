import 'package:flutter/material.dart';
import 'src/screens/home_screen.dart';
import 'src/screens/initial_setup_screen.dart';
import 'src/theme/app_theme.dart';
import 'src/core/prefs.dart';

class App extends StatefulWidget {
  const App({super.key});

  static AppState? of(BuildContext context) => context.findAncestorStateOfType<AppState>();

  @override
  State<App> createState() => AppState();
}

class AppState extends State<App> {
  String? _initialStateCode;
  bool _loading = true;
  ThemeMode _themeMode = ThemeMode.system;

  @override
  void initState() {
    super.initState();
    _loadPrefs();
  }

  Future<void> _loadPrefs() async {
    final code = await AppPrefs.getSelectedState();
    final themeStr = await AppPrefs.getThemeMode();
    final mode = switch (themeStr) {
      'light' => ThemeMode.light,
      'dark' => ThemeMode.dark,
      _ => ThemeMode.system,
    };
    if (!mounted) return;
    setState(() {
      _initialStateCode = code;
      _loading = false;
      _themeMode = mode;
    });
  }

  Future<void> setThemeMode(ThemeMode mode) async {
    setState(() => _themeMode = mode);
    final str = switch (mode) {
      ThemeMode.light => 'light',
      ThemeMode.dark => 'dark',
      _ => 'system',
    };
    await AppPrefs.saveThemeMode(str);
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
      themeMode: _themeMode,
      home: _initialStateCode == null ? const InitialSetupScreen() : const HomeScreen(),
    );
  }
}
