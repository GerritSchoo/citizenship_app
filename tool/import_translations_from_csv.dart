import 'dart:convert';
import 'dart:io';
import 'package:csv/csv.dart';

/// Imports translations from tool/questions_export.csv into
/// assets/i18n/questions_en.json overlay.
///
/// Expected CSV columns:
/// type,id,topicId,text_de,text_en,answer0_de,answer0_en,answer1_de,answer1_en,answer2_de,answer2_en,answer3_de,answer3_en,explanation_de,explanation_en
///
/// Only *_en columns are used to write overlay values. If an *_en field is
/// empty, the existing overlay (or fallback) value is kept.
Future<void> main() async {
  final csvFile = File('tool/questions_export.csv');
  if (!await csvFile.exists()) {
    stderr.writeln('CSV not found: ${csvFile.path}');
    exitCode = 1;
    return;
  }

  final csvContent = await csvFile.readAsString();
  final rows = const CsvToListConverter(eol: '\n').convert(csvContent);
  if (rows.isEmpty) {
    stderr.writeln('CSV is empty');
    exitCode = 1;
    return;
  }

  final header = rows.first.map((e) => e.toString()).toList();
  final index = {
    for (var i = 0; i < header.length; i++) header[i]: i,
  };

  String col(String name, List<dynamic> row) =>
      (index.containsKey(name) && index[name]! < row.length) ? (row[index[name]!] ?? '').toString() : '';

  // Load base and existing overlay if present
  // Ensure base file exists (for sanity); overlay merges happen at runtime
  if (!await File('assets/questions.json').exists()) {
    stderr.writeln('Base file missing: assets/questions.json');
    exitCode = 1;
    return;
  }
  final overlayPath = 'assets/i18n/questions_en.json';
  final overlayFile = File(overlayPath);
  Map<String, dynamic> overlay;
  if (await overlayFile.exists()) {
    overlay = json.decode(await overlayFile.readAsString()) as Map<String, dynamic>;
  } else {
    overlay = {'topics': [], 'generalQuestions': [], 'stateQuestions': <String, dynamic>{}};
  }

  // Build maps by id for quick update
  Map<String, Map<String, dynamic>> byIdMap(List<dynamic>? list) {
    final items = list ?? const [];
    return {
      for (final e in items)
        if (e is Map<String, dynamic> && e['id'] is String) e['id'] as String: e,
    };
  }

  final overlayGeneral = byIdMap(overlay['generalQuestions'] as List<dynamic>?);
  final overlayStates = (overlay['stateQuestions'] as Map<String, dynamic>? ?? <String, dynamic>{});

  // Topics: update titles from CSV text_en when type == 'topic'
  // If your CSV includes topic rows, they can be used; otherwise keep generator mapping.

  // Questions: update from rows where type == 'general' or startsWith 'state:'
  for (var r = 1; r < rows.length; r++) {
    final row = rows[r];
    final type = col('type', row);
    final id = col('id', row);
    if (id.isEmpty) continue;

    final textEn = col('text_en', row);
    final a0En = col('answer0_en', row);
    final a1En = col('answer1_en', row);
    final a2En = col('answer2_en', row);
    final a3En = col('answer3_en', row);
    final explEn = col('explanation_en', row);

    if (type == 'general') {
      final target = overlayGeneral[id] ?? <String, dynamic>{'id': id};
      if (textEn.isNotEmpty) target['text'] = textEn;
      final answers = <String>[];
      if (a0En.isNotEmpty) answers.add(a0En);
      if (a1En.isNotEmpty) answers.add(a1En);
      if (a2En.isNotEmpty) answers.add(a2En);
      if (a3En.isNotEmpty) answers.add(a3En);
      if (answers.isNotEmpty) target['answers'] = answers;
      if (explEn.isNotEmpty) target['explanation'] = explEn;
      overlayGeneral[id] = target;
    } else if (type.startsWith('state:')) {
      final stateCode = type.split(':').last.toUpperCase();
      final stateList = (overlayStates[stateCode] as List<dynamic>?) ?? <dynamic>[];
  final byId = byIdMap(stateList);
      final target = byId[id] ?? <String, dynamic>{'id': id};
      if (textEn.isNotEmpty) target['text'] = textEn;
      final answers = <String>[];
      if (a0En.isNotEmpty) answers.add(a0En);
      if (a1En.isNotEmpty) answers.add(a1En);
      if (a2En.isNotEmpty) answers.add(a2En);
      if (a3En.isNotEmpty) answers.add(a3En);
      if (answers.isNotEmpty) target['answers'] = answers;
      if (explEn.isNotEmpty) target['explanation'] = explEn;
      byId[id] = target;
      overlayStates[stateCode] = byId.values.toList();
    }
  }

  // Write back overlay (preserve topics)
  overlay['generalQuestions'] = overlayGeneral.values.toList();
  overlay['stateQuestions'] = overlayStates;

  final encoder = const JsonEncoder.withIndent('  ');
  await overlayFile.writeAsString(encoder.convert(overlay));
  stdout.writeln('Updated overlay: $overlayPath');
}
