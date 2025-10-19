import 'package:flutter/material.dart';
import 'src/screens/home_screen.dart';
import 'src/screens/initial_setup_screen.dart';
import 'src/theme/app_theme.dart';
import 'src/core/prefs.dart';
import 'src/analytics/progress_repository.dart';

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
  final _messengerKey = GlobalKey<ScaffoldMessengerState>();

  @override
  void initState() {
    super.initState();
    _loadPrefs();
    // Initialize analytics repository once at app start
    final repo = ProgressRepository.instance;
    repo.init().then((_) {
      if (repo.initError.value != null) _showDbInitBanner(repo.initError.value);
    });
    repo.initError.addListener(() {
      final msg = ProgressRepository.instance.initError.value;
      if (msg != null) _showDbInitBanner(msg);
    });
  }

  void _showDbInitBanner(String? details) {
    final messenger = _messengerKey.currentState;
    if (messenger == null) return;
    messenger.clearMaterialBanners();
    messenger.showMaterialBanner(
      MaterialBanner(
        content: const Text('Analytics-Speicher nicht verfügbar. Daten werden nicht gespeichert.'),
        actions: [
          if (details != null)
            TextButton(
              onPressed: () {
                // ignore: avoid_print
                print('[ProgressRepository] Init error: $details');
                messenger.hideCurrentMaterialBanner();
              },
              child: const Text('Details'),
            ),
          TextButton(
            onPressed: messenger.hideCurrentMaterialBanner,
            child: const Text('Schließen'),
          ),
        ],
      ),
    );
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
      scaffoldMessengerKey: _messengerKey,
      home: _initialStateCode == null ? const InitialSetupScreen() : const HomeScreen(),
    );
  }
}
