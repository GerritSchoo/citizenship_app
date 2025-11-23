import 'package:flutter/material.dart';
import 'src/screens/home_screen.dart';
import 'src/screens/initial_setup_screen.dart';
import 'src/theme/app_theme.dart';
import 'src/core/prefs.dart';
import 'src/analytics/progress_repository.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'l10n/app_localizations.dart';
import 'package:flutter_localized_locales/flutter_localized_locales.dart';
import 'src/data/question_repository.dart';

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
  Locale? _locale;
  // Testing toggle: enable subscription lock after 3 trial exams
  // Set to true to activate gating flows (menu + popup after trials)
  static bool subscriptionLockEnabled = false;
  // Testing toggle: always show initial setup screen (for development)
  static bool alwaysShowInitialSetup = true;

  @override
  void initState() {
    super.initState();
    _loadPrefs();
    // Initialize analytics repository once at app start
    final progressRepo = ProgressRepository.instance;
    progressRepo.init().then((_) {
      if (progressRepo.initError.value != null) _showDbInitBanner(progressRepo.initError.value);
    });
    progressRepo.initError.addListener(() {
      final msg = ProgressRepository.instance.initError.value;
      if (msg != null) _showDbInitBanner(msg);
    });
  }

  void _showDbInitBanner(String? details) {
    final messenger = _messengerKey.currentState;
    if (messenger == null) return;
    final ctx = messenger.context;
    AppLocalizations? l10n;
    try {
      l10n = AppLocalizations.of(ctx);
    } catch (_) {
      l10n = null;
    }
    messenger.clearMaterialBanners();
    messenger.showMaterialBanner(
      MaterialBanner(
        content: Text(l10n?.db_unavailable ?? 'Datenbank nicht verfügbar'),
        actions: [
          if (details != null)
            TextButton(
              onPressed: () {
                // ignore: avoid_print
                print('[ProgressRepository] Init error: $details');
                messenger.hideCurrentMaterialBanner();
              },
              child: Text(l10n?.details ?? 'Details'),
            ),
          TextButton(
            onPressed: messenger.hideCurrentMaterialBanner,
            child: Text(l10n?.close ?? 'Schließen'),
          ),
        ],
      ),
    );
  }

  Future<void> _loadPrefs() async {
    final code = await AppPrefs.getSelectedState();
    final themeStr = await AppPrefs.getThemeMode();
    final localeCode = await AppPrefs.getLocale();
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
      _locale = (localeCode != null && localeCode.isNotEmpty) ? Locale(localeCode) : null;
    });
    // Initialize default language for repository so first load matches saved locale
    if (localeCode != null && localeCode.isNotEmpty) {
      QuestionRepository.setDefaultLanguage(localeCode);
    }
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

  Future<void> setLocale(Locale locale) async {
    setState(() => _locale = locale);
    // Update default language for data repository and reload questions in background
    QuestionRepository.setDefaultLanguage(locale.languageCode);
    // Trigger a background reload; consumers that call init() will get updated data
    // ignore: unawaited_futures
    QuestionRepository().reloadForLanguage(locale.languageCode);
    await AppPrefs.saveLocale(locale.languageCode);
  }

  // Global bottom SnackBar helper, accessible via App.of(context)
  void showSnack(String message) {
    final messenger = _messengerKey.currentState;
    if (messenger == null) return;
    messenger.hideCurrentSnackBar();
    messenger.showSnackBar(SnackBar(content: Text(message)));
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
      localizationsDelegates: [
        AppLocalizations.delegate,
        LocaleNamesLocalizationsDelegate(),
        GlobalMaterialLocalizations.delegate,
        GlobalWidgetsLocalizations.delegate,
        GlobalCupertinoLocalizations.delegate,
      ],
      supportedLocales: AppLocalizations.supportedLocales,
      localeResolutionCallback: (deviceLocale, supported) {
        // If user chose a locale explicitly, honor it and set repo language accordingly
        if (_locale != null) {
          QuestionRepository.setDefaultLanguage(_locale!.languageCode);
          return _locale;
        }
        // Otherwise, resolve from device and sync repository default language
        if (deviceLocale == null) {
          final resolved = supported.first;
          QuestionRepository.setDefaultLanguage(resolved.languageCode);
          return resolved;
        }
        for (final l in supported) {
          if (l.languageCode == deviceLocale.languageCode) {
            QuestionRepository.setDefaultLanguage(l.languageCode);
            return l;
          }
        }
        final fallback = supported.first;
        QuestionRepository.setDefaultLanguage(fallback.languageCode);
        return fallback; // default fallback
      },
      locale: _locale,
      home: AppState.alwaysShowInitialSetup
          ? const InitialSetupScreen()
          : (_initialStateCode == null ? const InitialSetupScreen() : const HomeScreen()),
    );
  }
}
