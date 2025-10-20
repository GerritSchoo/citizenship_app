import 'dart:convert';
import 'dart:io';

/// Generates a complete English overlay skeleton for questions based on
/// the canonical German base at assets/questions.json.
///
/// Output:
/// - assets/i18n/questions_en.json (overlay with same IDs, German text copied)
/// - tool/questions_export_en.csv (to aid manual translation)
///
/// Note: This script does NOT perform automatic translation. It ensures a
/// complete overlay exists and provides a CSV for translators. The app will
/// fall back to German where English is not provided.
Future<void> main() async {
  final baseFile = File('assets/questions.json');
  if (!await baseFile.exists()) {
    stderr.writeln('Base file not found at assets/questions.json');
    exitCode = 1;
    return;
  }

  final overlayDir = Directory('assets/i18n');
  if (!await overlayDir.exists()) await overlayDir.create(recursive: true);

  final content = await baseFile.readAsString();
  final dynamic decoded = json.decode(content);
  if (decoded is! Map<String, dynamic>) {
    stderr.writeln('Invalid base JSON structure (expected root object)');
    exitCode = 1;
    return;
  }
  final base = decoded;

  // Prepare overlay structure
  final Map<String, dynamic> overlay = {
    'topics': _translateTopics(base['topics'] as List<dynamic>?),
    'generalQuestions': _copyQuestions(base['generalQuestions'] as List<dynamic>?),
    if (base['stateQuestions'] is Map<String, dynamic>)
      'stateQuestions': _copyStateQuestions(base['stateQuestions'] as Map<String, dynamic>),
  };

  final outFile = File('assets/i18n/questions_en.json');
  // Pretty-print for readability
  final encoder = const JsonEncoder.withIndent('  ');
  await outFile.writeAsString(encoder.convert(overlay));
  stdout.writeln('Wrote overlay: ${outFile.path}');

  // Optional CSV export for translators (language-agnostic file name)
  final csvFile = File('tool/questions_export.csv');
  final csv = _buildCsv(base); // Generate CSV with _en columns
  await csvFile.writeAsString(csv);
  stdout.writeln('Wrote CSV: ${csvFile.path}');
}

List<Map<String, dynamic>> _translateTopics(List<dynamic>? topics) {
  if (topics == null) return const [];
  return topics.map((t) {
    final m = (t as Map<String, dynamic>);
    final id = m['id'] as String? ?? '';
    final titleEn = _topicTitleEn(id, m['title'] as String?);
    return {'id': id, 'title': titleEn};
  }).toList();
}

String _topicTitleEn(String id, String? fallback) {
  switch (id) {
    case 'democracy':
      return 'Life in a Democracy';
    case 'history_responsibility':
      return 'History and Responsibility';
    case 'people_society':
      return 'People and Society';
    case 'state':
      return 'State Questions';
    default:
      return fallback ?? id;
  }
}

List<Map<String, dynamic>> _copyQuestions(List<dynamic>? list) {
  if (list == null) return const [];
  return list.map((q) {
    final m = (q as Map<String, dynamic>);
    // Only the fields that are translatable in overlay
    return {
      'id': m['id'],
      'text': m['text'],
      'answers': (m['answers'] as List).map((e) => e.toString()).toList(),
      'explanation': m['explanation'],
    };
  }).toList();
}

Map<String, dynamic> _copyStateQuestions(Map<String, dynamic> states) {
  final result = <String, dynamic>{};
  states.forEach((code, list) {
    if (list is List) {
      result[code] = _copyQuestions(list);
    }
  });
  return result;
}

String _buildCsv(Map<String, dynamic> base) {
  final buf = StringBuffer();
  // CSV header (include _en columns for translators to fill)
  buf.writeln('type,id,topicId,text_de,text_en,answer0_de,answer0_en,answer1_de,answer1_en,answer2_de,answer2_en,answer3_de,answer3_en,explanation_de,explanation_en');

  void addQ(String type, Map<String, dynamic> q) {
    final id = q['id'] ?? '';
    final topicId = q['topicId'] ?? '';
    final text = (q['text'] ?? '').toString().replaceAll('\n', ' ').replaceAll('"', '""');
    final ans = (q['answers'] as List).map((e) => e.toString().replaceAll('\n', ' ').replaceAll('"', '""')).toList();
    while (ans.length < 4) {
      ans.add('');
    }
    final expl = (q['explanation'] ?? '').toString().replaceAll('\n', ' ').replaceAll('"', '""');
    // Duplicate DE columns into EN as placeholders for translators
    buf.writeln('$type,"$id","$topicId","$text","$text","${ans[0]}","${ans[0]}","${ans[1]}","${ans[1]}","${ans[2]}","${ans[2]}","${ans[3]}","${ans[3]}","$expl","$expl"');
  }

  final gen = base['generalQuestions'] as List<dynamic>? ?? const [];
  for (final q in gen) {
    addQ('general', q as Map<String, dynamic>);
  }
  final states = base['stateQuestions'] as Map<String, dynamic>? ?? const {};
  states.forEach((code, list) {
    for (final q in (list as List)) {
      addQ('state:$code', q as Map<String, dynamic>);
    }
  });

  return buf.toString();
}
