import 'package:flutter/material.dart';

import '../models/question.dart';
import '../widgets/exam_result_indicator.dart';

class MockExamResultScreen extends StatelessWidget {
  final int total;
  final int correct;
  final List<Question> questions;
  final List<int?> answers;

  const MockExamResultScreen({super.key, required this.total, required this.correct, required this.questions, required this.answers});



  @override
  Widget build(BuildContext context) {
    final pass = correct >= 17;
    return Scaffold(
      appBar: AppBar(
        title: const Text('Ergebnis'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(12.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Card(
              child: Padding(
                padding: const EdgeInsets.all(12.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(pass ? 'Bestanden' : 'Nicht bestanden', style: Theme.of(context).textTheme.titleLarge),
                    const SizedBox(height: 8),
                    Text('Richtige Antworten: $correct von $total'),
                    const SizedBox(height: 12),
                    // Grade category, range and description
                    Builder(builder: (ctx) {
                      final cat = gradeForCorrect(correct);
                      final label = labelForCategory(cat).toUpperCase();
                      final icon = iconForCategory(cat);
                      final color = colorForCategory(ctx, cat);
                      final bg = color.withValues(alpha: 0.12);
                      return Card(
                        color: bg,
                        child: Padding(
                          padding: const EdgeInsets.all(12.0),
                          child: Row(
                            children: [
                              Icon(icon, color: color, size: 28),
                              const SizedBox(width: 12),
                              Expanded(child: Text(label, style: Theme.of(ctx).textTheme.titleSmall)),
                            ],
                          ),
                        ),
                      );
                    }),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 12),
            Expanded(
              child: ListView.builder(
                itemCount: questions.length,
                itemBuilder: (c, i) {
                  final q = questions[i];
                  final sel = answers[i];
                  return Card(
                    child: ListTile(
                      title: Text(q.text),
                      subtitle: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const SizedBox(height: 6),
                          Text('Deine Antwort: ${sel == null ? 'Keine' : q.answers[sel]}'),
                          Text('Richtige Antwort: ${q.answers[q.correctIndex]}'),
                        ],
                      ),
                    ),
                  );
                },
              ),
            ),
            ElevatedButton(
              onPressed: () {
                Navigator.of(context).popUntil((route) => route.isFirst);
              },
              child: const Text('Zurück zur Startseite'),
            )
          ],
        ),
      ),
    );
  }
}
