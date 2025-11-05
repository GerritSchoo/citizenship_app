import 'dart:convert';
import 'dart:io';

/// Normalizes ARB files so that app_en.arb and app_de.arb have identical key
/// order and contain the union of keys. Metadata keys ("@<key>") are kept
/// adjacent to their corresponding message key. "@@" keys are placed first.
Future<void> main(List<String> args) async {
  final root = Directory.current.path.replaceAll('\\', '/');
  final enPath = '$root/lib/l10n/app_en.arb';
  final dePath = '$root/lib/l10n/app_de.arb';

  Map<String, dynamic> readJson(String path) {
    final text = File(path).readAsStringSync();
    return json.decode(text) as Map<String, dynamic>;
  }

  final en = readJson(enPath);
  final de = readJson(dePath);

  // Helper predicates.
  bool isMeta(String k) => k.startsWith('@') && !k.startsWith('@@');
  bool isGlobal(String k) => k.startsWith('@@');

  // Preserve EN message key order as baseline (excluding metadata and globals).
  final enMessageOrder = <String>[];
  for (final k in en.keys) {
    if (!isMeta(k) && !isGlobal(k)) {
      enMessageOrder.add(k);
    }
  }

  // Include any DE-only message keys, appended sorted to keep determinism.
  final deOnly = de.keys
      .where((k) => !isMeta(k) && !isGlobal(k) && !enMessageOrder.contains(k))
      .toList()
    ..sort();

  final masterMessageOrder = <String>[...enMessageOrder, ...deOnly];

  // Build the union of global @@ keys from both (EN order, then DE extras).
  final globalKeys = <String>[
    ...en.keys.where(isGlobal),
    ...de.keys.where(isGlobal).where((k) => !en.containsKey(k)),
  ];

  Map<String, dynamic> buildLocale(Map<String, dynamic> src, Map<String, dynamic> fallback) {
    final out = <String, dynamic>{};

    // Globals first in a stable order captured above.
    for (final g in globalKeys) {
      out[g] = src.containsKey(g) ? src[g] : (fallback[g] ?? out[g]);
    }

    // Messages in master order, followed by their metadata if present.
    for (final key in masterMessageOrder) {
      final metaKey = '@$key';
      out[key] = src.containsKey(key)
          ? src[key]
          : (fallback.containsKey(key) ? fallback[key] : '');
      if (src.containsKey(metaKey) || fallback.containsKey(metaKey)) {
        out[metaKey] = src.containsKey(metaKey)
            ? src[metaKey]
            : (fallback[metaKey] ?? {});
      }
    }

    return out;
  }

  Map<String, dynamic> enOut = buildLocale(en, de);
  Map<String, dynamic> deOut = buildLocale(de, en);

  // Pretty-print JSON with two-space indentation.
  String pretty(Map<String, dynamic> m) {
    // jsonEncode preserves LinkedHashMap order from insertion in Dart.
    final encoder = const JsonEncoder.withIndent('  ');
    return encoder.convert(m) + '\n';
  }

  File(enPath).writeAsStringSync(pretty(enOut));
  File(dePath).writeAsStringSync(pretty(deOut));

  // Done.
  stdout.writeln('Normalized ARB files written.');
}
