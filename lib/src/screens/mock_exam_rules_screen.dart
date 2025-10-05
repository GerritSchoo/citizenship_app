import 'package:flutter/material.dart';
import 'mock_exam_screen.dart';

class MockExamRulesScreen extends StatelessWidget {
  const MockExamRulesScreen({Key? key}) : super(key: key);

  // Example rules - adjust text as needed
  static const List<String> _rules = [
    'Dauer: 60 Minuten für den kompletten Test.',
    'Zusammensetzung: 30 allgemeine Fragen + 3 länderspezifische Fragen.',
    'Bestehen: Mindestens 17 richtige Antworten sind erforderlich, um die Prüfung zu bestehen.',
    'Keine Hilfsmittel erlaubt (Bücher, Notizen, Internet).',
    'Antworten können während der Prüfung geändert werden.',
    'Die Prüfung wird automatisch abgegeben, wenn die Zeit abläuft.',
    'Nach Abgabe gibt es keine Rückkehr zur Prüfung.',
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Probeprüfung - Regeln'),
        // keep the default back button
      ),
      body: SafeArea(
        child: Column(
          children: [
            Expanded(
              child: ListView.separated(
                padding: const EdgeInsets.all(16),
                itemCount: _rules.length,
                separatorBuilder: (_, __) => const SizedBox(height: 12),
                itemBuilder: (context, index) {
                  final rule = _rules[index];
                  return Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      CircleAvatar(radius: 14, backgroundColor: Colors.blue.shade100, child: Text('${index + 1}')),
                      const SizedBox(width: 12),
                      Expanded(child: Text(rule, style: Theme.of(context).textTheme.bodyMedium)),
                    ],
                  );
                },
              ),
            ),
            Padding(
              padding: const EdgeInsets.fromLTRB(16, 8, 16, 24),
              child: SizedBox(
                width: double.infinity,
                height: 56,
                child: ElevatedButton(
                  onPressed: () {
                    Navigator.pushReplacement(context, MaterialPageRoute(builder: (_) => const MockExamScreen()));
                  },
                  style: ElevatedButton.styleFrom(shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12))),
                  child: const Text('Prüfung starten', style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600)),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
