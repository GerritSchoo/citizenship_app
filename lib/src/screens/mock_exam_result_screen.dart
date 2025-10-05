import 'package:flutter/material.dart';

import '../models/question.dart';

class MockExamResultScreen extends StatelessWidget {
  final int total;
  final int correct;
  final List<Question> questions;
  final List<int?> answers;

  const MockExamResultScreen({Key? key, required this.total, required this.correct, required this.questions, required this.answers}) : super(key: key);

  String _gradeText(int correct) {
    if (correct >= 30) return '1.0';
    if (correct >= 29) return '1.3';
    if (correct >= 28) return '1.7';
    if (correct >= 27) return '2.0';
    if (correct >= 25) return '2.3';
    if (correct >= 23) return '2.7';
    if (correct >= 21) return '3.0';
    if (correct >= 19) return '3.3';
    if (correct >= 17) return '3.7';
    return 'ungenügend';
  }

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
                    const SizedBox(height: 8),
                    Text('Note: ${_gradeText(correct)}'),
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
