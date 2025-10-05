import 'package:flutter/material.dart';

import '../models/question.dart';
import '../theme/app_theme.dart';

class MockExamResultScreen extends StatelessWidget {
  final int total;
  final int correct;
  final List<Question> questions;
  final List<int?> answers;

  const MockExamResultScreen({Key? key, required this.total, required this.correct, required this.questions, required this.answers}) : super(key: key);

  String _gradeText(int correct) {
    // Not used anymore; kept for compatibility but return category
    if (correct >= 31) return 'sehr gut';
    if (correct >= 27) return 'gut';
    if (correct >= 23) return 'befriedigend';
    if (correct >= 17) return 'ausreichend';
    if (correct >= 10) return 'mangelhaft';
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
                    const SizedBox(height: 12),
                    // Grade category, range and description
                    Builder(builder: (ctx) {
                      final category = _gradeText(correct);
                      final gradeColors = Theme.of(ctx).extension<GradeColors>()!;
                      Color bg;
                      IconData cueIcon;
                      Color iconColor;
                      switch (category) {
                        case 'sehr gut':
                          bg = gradeColors.sehrGut.withOpacity(0.12);
                          cueIcon = Icons.check_circle;
                          iconColor = gradeColors.sehrGut;
                          break;
                        case 'gut':
                          bg = gradeColors.gut.withOpacity(0.12);
                          cueIcon = Icons.check_circle;
                          iconColor = gradeColors.gut;
                          break;
                        case 'befriedigend':
                          bg = gradeColors.befriedigend.withOpacity(0.12);
                          cueIcon = Icons.warning;
                          iconColor = gradeColors.befriedigend;
                          break;
                        case 'ausreichend':
                          bg = gradeColors.ausreichend.withOpacity(0.12);
                          cueIcon = Icons.warning;
                          iconColor = gradeColors.ausreichend;
                          break;
                        case 'mangelhaft':
                          bg = gradeColors.mangelhaft.withOpacity(0.12);
                          cueIcon = Icons.cancel;
                          iconColor = gradeColors.mangelhaft;
                          break;
                        case 'ungenügend':
                        default:
                          bg = gradeColors.ungenuegend.withOpacity(0.12);
                          cueIcon = Icons.cancel;
                          iconColor = gradeColors.ungenuegend;
                          break;
                      }

                      return Card(
                        color: bg,
                        child: Padding(
                          padding: const EdgeInsets.all(12.0),
                          child: Row(
                            children: [
                              Icon(cueIcon, color: iconColor, size: 28),
                              const SizedBox(width: 12),
                              Expanded(child: Text(category.toUpperCase(), style: Theme.of(ctx).textTheme.titleSmall)),
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
