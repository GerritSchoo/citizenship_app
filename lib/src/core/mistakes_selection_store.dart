import 'dart:convert';

import 'package:shared_preferences/shared_preferences.dart';

/// Stores the last set of question IDs used in a Mistakes run
/// so the next Mistakes run can exclude them.
class MistakesSelectionStore {
  MistakesSelectionStore._();
  static final MistakesSelectionStore instance = MistakesSelectionStore._();

  static const _keyLastUsed = 'mistakes_last_used_ids_v1';

  Future<Set<String>> getLastUsedIds() async {
    final prefs = await SharedPreferences.getInstance();
    final raw = prefs.getString(_keyLastUsed);
    if (raw == null || raw.isEmpty) return <String>{};
    try {
      final list = (jsonDecode(raw) as List).cast<String>();
      return list.toSet();
    } catch (_) {
      return <String>{};
    }
  }

  Future<void> setLastUsedIds(List<String> ids) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_keyLastUsed, jsonEncode(ids));
  }

  Future<void> clear() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove(_keyLastUsed);
  }
}
