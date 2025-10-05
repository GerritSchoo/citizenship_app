import 'package:shared_preferences/shared_preferences.dart';

class AppPrefs {
  static const _keySelectedState = 'selectedStateCode';
  static const _keyLocale = 'locale';

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
  }
}
