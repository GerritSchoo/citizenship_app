import 'dart:convert';
import 'package:flutter/services.dart' show rootBundle;

class QuestionLoader {
  static Future<Map<String, dynamic>> loadJson() async {
    final String response = await rootBundle.loadString('assets/questions.json');
    return json.decode(response);
  }
}
