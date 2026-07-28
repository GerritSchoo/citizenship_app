import 'package:shared_preferences/shared_preferences.dart';

class AppPrefs {
  static const _keySelectedState = 'selectedStateCode';
  static const _keyLocale = 'locale';
  static const _keyContentLocale = 'contentLocale';
  static const _keyThemeMode = 'themeMode'; // 'system' | 'light' | 'dark'
  static const _keyDisclaimerAccepted = 'disclaimerAccepted';
  // Tracks completed exam count independently of analytics so resets cannot bypass the trial gate.
  static const _keyExamTrialCount = 'examTrialCount';
  // Tracks quiz session count independently of analytics so resets cannot bypass the trial gate.
  static const _keyQuizTrialCount = 'quizTrialCount';
  // Tracks whether an in-app review prompt has been requested (only ask once per install).
  static const _keyReviewRequested = 'reviewRequested';

  static Future<void> saveDisclaimerAccepted(bool accepted) async {
    final p = await SharedPreferences.getInstance();
    await p.setBool(_keyDisclaimerAccepted, accepted);
  }

  static Future<bool> getDisclaimerAccepted() async {
    final p = await SharedPreferences.getInstance();
    // Default to false if not set
    return p.getBool(_keyDisclaimerAccepted) ?? false;
  }


  static Future<void> saveSelectedState(String code) async {
    final p = await SharedPreferences.getInstance();
    await p.setString(_keySelectedState, code);
  }

  static Future<String?> getSelectedState() async {
    final p = await SharedPreferences.getInstance();
    return p.getString(_keySelectedState);
  }

  static Future<void> saveLocale(String localeCode) async {
    final p = await SharedPreferences.getInstance();
    await p.setString(_keyLocale, localeCode);
  }

  static Future<String?> getLocale() async {
    final p = await SharedPreferences.getInstance();
    return p.getString(_keyLocale);
  }

  static Future<void> saveContentLocale(String localeCode) async {
    final p = await SharedPreferences.getInstance();
    await p.setString(_keyContentLocale, localeCode);
  }

  static Future<String?> getContentLocale() async {
    final p = await SharedPreferences.getInstance();
    return p.getString(_keyContentLocale);
  }

  static Future<int> getExamTrialCount() async {
    final p = await SharedPreferences.getInstance();
    return p.getInt(_keyExamTrialCount) ?? 0;
  }

  static Future<void> incrementExamTrialCount() async {
    final p = await SharedPreferences.getInstance();
    await p.setInt(_keyExamTrialCount, (p.getInt(_keyExamTrialCount) ?? 0) + 1);
  }

  static Future<int> getQuizTrialCount() async {
    final p = await SharedPreferences.getInstance();
    return p.getInt(_keyQuizTrialCount) ?? 0;
  }

  static Future<void> incrementQuizTrialCount() async {
    final p = await SharedPreferences.getInstance();
    await p.setInt(_keyQuizTrialCount, (p.getInt(_keyQuizTrialCount) ?? 0) + 1);
  }

  static Future<bool> getReviewRequested() async {
    final p = await SharedPreferences.getInstance();
    return p.getBool(_keyReviewRequested) ?? false;
  }

  static Future<void> setReviewRequested() async {
    final p = await SharedPreferences.getInstance();
    await p.setBool(_keyReviewRequested, true);
  }

  static Future<void> clearAll() async {
    final p = await SharedPreferences.getInstance();
    await p.remove(_keySelectedState);
    await p.remove(_keyLocale);
    await p.remove(_keyContentLocale);
    await p.remove(_keyThemeMode);
  }

  static Future<void> saveThemeMode(String mode) async {
    // mode must be one of 'system', 'light', 'dark'
    final p = await SharedPreferences.getInstance();
    await p.setString(_keyThemeMode, mode);
  }

  static Future<String?> getThemeMode() async {
    final p = await SharedPreferences.getInstance();
    return p.getString(_keyThemeMode);
  }
}
