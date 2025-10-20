import 'dart:convert';
import 'package:flutter/services.dart' show rootBundle;
import 'package:flutter/foundation.dart' show FlutterError;

class QuestionLoader {
  /// Load questions base file and optionally merge a locale overlay.
  /// languageCode: 'de', 'en', ... When null or 'de', returns base only.
  static Future<Map<String, dynamic>> loadJson({String? languageCode}) async {
    try {
      final String response = await rootBundle.loadString('assets/questions.json');
      final dynamic decoded = json.decode(response);
      if (decoded is! Map<String, dynamic>) {
        throw const FormatException('Ungültiges Format: Erwartet wurde ein JSON-Objekt an der Wurzel.');
      }
      final lang = (languageCode ?? 'de').toLowerCase();
      if (lang == 'de') {
        return decoded;
      }

  // Try overlay from assets/i18n/questions_<lang>.json
  final overlayPath = 'assets/i18n/questions_$lang.json';
      Map<String, dynamic>? overlay;
      try {
        final String overlayStr = await rootBundle.loadString(overlayPath);
        final dynamic overlayDecoded = json.decode(overlayStr);
        if (overlayDecoded is Map<String, dynamic>) overlay = overlayDecoded;
      } on FlutterError {
        // Missing overlay -> return base
        return decoded;
      }

      if (overlay == null) return decoded;
      return _mergeOverlay(base: decoded, overlay: overlay);
    } on FlutterError catch (e) {
      // Asset missing or not bundled
      throw Exception('Fragen-Datei nicht gefunden (assets/questions.json). Details: ${e.message}');
    } on FormatException catch (e) {
      throw Exception('Die Fragen konnten nicht geladen werden: ${e.message}');
    } catch (e) {
      // Any other unexpected error
      throw Exception('Unerwarteter Fehler beim Laden der Fragen: $e');
    }
  }

  static Map<String, dynamic> _mergeOverlay({required Map<String, dynamic> base, required Map<String, dynamic> overlay}) {
    // Deep-copy base to avoid mutating callers
    final result = json.decode(json.encode(base)) as Map<String, dynamic>;

    // Merge topics title by id
    if (overlay['topics'] is List) {
      final baseTopics = (result['topics'] as List<dynamic>? ?? []);
      final byId = <String, Map<String, dynamic>>{
        for (final t in baseTopics)
          if (t is Map<String, dynamic>) (t['id'] as String): t,
      };
      for (final o in (overlay['topics'] as List)) {
        final om = o as Map<String, dynamic>;
        final id = om['id'] as String?;
        if (id != null && byId.containsKey(id)) {
          if (om['title'] is String) byId[id]!['title'] = om['title'];
        }
      }
      result['topics'] = byId.values.toList();
    }

    Map<String, Map<String, dynamic>> mapById(List<dynamic>? list) {
      final items = list ?? const [];
      return {
        for (final e in items)
          if (e is Map<String, dynamic> && e['id'] is String) e['id'] as String: e,
      };
    }

    void mergeQuestion(Map<String, dynamic> baseQ, Map<String, dynamic> ovQ) {
      if (ovQ['text'] is String) baseQ['text'] = ovQ['text'];
      if (ovQ['answers'] is List) baseQ['answers'] = (ovQ['answers'] as List).map((e) => e.toString()).toList();
      if (ovQ['explanation'] is String) baseQ['explanation'] = ovQ['explanation'];
    }

    // generalQuestions
    if (overlay['generalQuestions'] is List) {
      final baseMap = mapById(result['generalQuestions'] as List<dynamic>?);
      for (final o in (overlay['generalQuestions'] as List)) {
        if (o is! Map<String, dynamic>) continue;
        final id = o['id'] as String?;
        if (id != null && baseMap.containsKey(id)) {
          mergeQuestion(baseMap[id]!, o);
        }
      }
      result['generalQuestions'] = baseMap.values.toList();
    }

    // stateQuestions: map of state -> list
    if (overlay['stateQuestions'] is Map<String, dynamic>) {
      final baseStates = (result['stateQuestions'] as Map<String, dynamic>? ?? <String, dynamic>{});
      final overlayStates = overlay['stateQuestions'] as Map<String, dynamic>;
      overlayStates.forEach((state, list) {
        final baseList = (baseStates[state] as List<dynamic>?) ?? const [];
        final baseMap = mapById(baseList);
        if (list is List) {
          for (final o in list) {
            if (o is! Map<String, dynamic>) continue;
            final id = o['id'] as String?;
            if (id != null && baseMap.containsKey(id)) {
              mergeQuestion(baseMap[id]!, o);
            }
          }
          baseStates[state] = baseMap.values.toList();
        }
      });
      result['stateQuestions'] = baseStates;
    }

    return result;
  }
}
