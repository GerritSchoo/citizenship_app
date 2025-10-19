import 'package:shared_preferences/shared_preferences.dart';

class AppPrefs {
  static const _keySelectedState = 'selectedStateCode';
  static const _keyLocale = 'locale';
  static const _keyThemeMode = 'themeMode'; // 'system' | 'light' | 'dark'

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

  static Future<void> clearAll() async {
    final p = await SharedPreferences.getInstance();
    await p.remove(_keySelectedState);
    await p.remove(_keyLocale);
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
