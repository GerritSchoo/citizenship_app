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
  String? _contentLocaleCode;
  
  String? get contentLocale => _contentLocaleCode;
  Locale? get uiLocale => _locale;
  // Testing toggle: enable subscription lock after 3 trial exams
  // Set to true to activate gating flows (menu + popup after trials)
  static bool subscriptionLockEnabled = true;
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
    final contentLocaleCode = await AppPrefs.getContentLocale();
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
      _contentLocaleCode = contentLocaleCode;
    });
    // Initialize default language for repository so first load matches saved locale
    // Use content locale if set, otherwise fallback to UI locale
    final targetLang = contentLocaleCode ?? localeCode ?? 'de';
    QuestionRepository.setDefaultLanguage(targetLang);
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
    await AppPrefs.saveLocale(locale.languageCode);
    
    // If content locale is NOT set, we sync content to UI locale
    if (_contentLocaleCode == null) {
      QuestionRepository.setDefaultLanguage(locale.languageCode);
      // ignore: unawaited_futures
      QuestionRepository().reloadForLanguage(locale.languageCode);
    }
  }

  Future<void> setContentLocale(String localeCode) async {
    setState(() => _contentLocaleCode = localeCode);
    await AppPrefs.saveContentLocale(localeCode);
    
    QuestionRepository.setDefaultLanguage(localeCode);
    await QuestionRepository().reloadForLanguage(localeCode);
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
        // Helper to sync content language only if user hasn't strictly set a content locale
        void syncContent(String code) {
          if (_contentLocaleCode == null) {
            QuestionRepository.setDefaultLanguage(code);
          }
        }

        // If user chose a locale explicitly, honor it
        if (_locale != null) {
          syncContent(_locale!.languageCode);
          return _locale;
        }
        // Otherwise, resolve from device
        if (deviceLocale == null) {
          final resolved = supported.first;
          syncContent(resolved.languageCode);
          return resolved;
        }
        for (final l in supported) {
          if (l.languageCode == deviceLocale.languageCode) {
            syncContent(l.languageCode);
            return l;
          }
        }
        final fallback = supported.first;
        syncContent(fallback.languageCode);
        return fallback; // default fallback
      },
      locale: _locale,
      home: AppState.alwaysShowInitialSetup
          ? const InitialSetupScreen()
          : (_initialStateCode == null ? const InitialSetupScreen() : const HomeScreen()),
    );
  }
}
