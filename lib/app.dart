import 'package:flutter/material.dart';
import 'src/screens/home_screen.dart';
import 'src/screens/initial_setup_screen.dart';
import 'src/screens/disclaimer_screen.dart';
import 'src/theme/app_theme.dart';
import 'src/core/prefs.dart';
import 'src/analytics/progress_repository.dart';
import 'src/payments/purchase_service.dart';
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
  bool _disclaimerAccepted = false;
  ThemeMode _themeMode = ThemeMode.system;
  final _messengerKey = GlobalKey<ScaffoldMessengerState>();
  Locale? _locale;
  String? _contentLocaleCode;
  
  String? get contentLocale => _contentLocaleCode;
  Locale? get uiLocale => _locale;
  // Testing toggle: always show initial setup screen (for development)
  static bool alwaysShowInitialSetup = false;
  // Testing toggle: treat every user as Pro, bypassing all premium gates
  static bool get debugForcePremium => PurchaseService.debugForcePremium;
  static set debugForcePremium(bool v) => PurchaseService.debugForcePremium = v;

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
    bool disclaimerDone = await AppPrefs.getDisclaimerAccepted();

    // Debug override: If alwaysShowInitialSetup is true, force disclaimer flow to re-run
    if (AppState.alwaysShowInitialSetup) {
      disclaimerDone = false;
    }

    final mode = switch (themeStr) {
      'light' => ThemeMode.light,
      'dark' => ThemeMode.dark,
      _ => ThemeMode.system,
    };

    final supportedLocales =
        AppLocalizations.supportedLocales.map((loc) => loc.languageCode).toSet();
    final sanitizedLocaleCode =
        (localeCode != null && supportedLocales.contains(localeCode)) ? localeCode : null;

    if (!mounted) return;
    setState(() {
      _initialStateCode = code;
      _loading = false;
      _themeMode = mode;
      _disclaimerAccepted = disclaimerDone;
      _locale = sanitizedLocaleCode != null ? Locale(sanitizedLocaleCode) : null;
      _contentLocaleCode = contentLocaleCode;
    });
    // Initialize default language for repository so first load matches saved locale
    // Use content locale if set, otherwise fallback to UI locale.
    // If saved content locale is a premium language and user is not Pro, fall back to 'en'.
    const premiumContentLangs = {'fr', 'es', 'tr', 'ru', 'uk', 'ar'};
    final resolvedContentLang = (contentLocaleCode != null &&
            premiumContentLangs.contains(contentLocaleCode) &&
            !PurchaseService.instance.isPro)
        ? 'en'
        : contentLocaleCode;
    final targetLang = resolvedContentLang ?? localeCode ?? 'de';
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

  Future<void> setSelectedState(String stateCode) async {
    setState(() => _initialStateCode = stateCode);
    await AppPrefs.saveSelectedState(stateCode);
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
    final Widget homeWidget = _loading
        ? const Scaffold(body: Center(child: CircularProgressIndicator()))
        : (AppState.alwaysShowInitialSetup
            ? const InitialSetupScreen()
            : (_initialStateCode == null
                ? const InitialSetupScreen()
                : (_disclaimerAccepted
                    ? const HomeScreen()
                    : const DisclaimerScreen())));

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
        void syncContent(String code) {
          if (_contentLocaleCode == null) {
            QuestionRepository.setDefaultLanguage(code);
          }
        }

        bool isSupported(Locale locale) =>
            supported.any((candidate) => candidate.languageCode == locale.languageCode);

        if (_locale != null && isSupported(_locale!)) {
          syncContent(_locale!.languageCode);
          return _locale;
        }

        if (deviceLocale != null) {
          for (final locale in supported) {
            if (locale.languageCode == deviceLocale.languageCode) {
              syncContent(locale.languageCode);
              return locale;
            }
          }
        }

        final fallback = supported.first;
        syncContent(fallback.languageCode);
        return fallback;
      },
      locale: _locale,
      home: homeWidget,
    );
  }
}
