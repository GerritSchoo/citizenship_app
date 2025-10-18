import 'dart:convert';
import 'package:flutter/services.dart' show rootBundle;
import 'package:flutter/foundation.dart' show FlutterError;

class QuestionLoader {
  static Future<Map<String, dynamic>> loadJson() async {
    try {
      final String response = await rootBundle.loadString('assets/questions.json');
      final dynamic decoded = json.decode(response);
      if (decoded is! Map<String, dynamic>) {
        throw const FormatException('Ungültiges Format: Erwartet wurde ein JSON-Objekt an der Wurzel.');
      }
      return decoded;
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
}
