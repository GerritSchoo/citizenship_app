import 'package:flutter/material.dart';

import '../models/question.dart';

class LearningSessionScreen extends StatefulWidget {
  final List<Question> questions;
  final String title;

  const LearningSessionScreen({super.key, required this.questions, required this.title});

  @override
  State<LearningSessionScreen> createState() => _LearningSessionScreenState();
}

class _LearningSessionScreenState extends State<LearningSessionScreen> {
  int _currentIndex = 0;

  void _goToNext() {
    if (_currentIndex < widget.questions.length - 1) {
      setState(() {
        _currentIndex += 1;
      });
    }
  }

  void _goToPrevious() {
    if (_currentIndex > 0) {
      setState(() {
        _currentIndex -= 1;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    if (widget.questions.isEmpty) {
      return Scaffold(
        appBar: AppBar(title: Text(widget.title)),
        body: const Center(child: Text('Keine Fragen verfugbar.')),
      );
    }

    final theme = Theme.of(context);
    final question = widget.questions[_currentIndex];
    final total = widget.questions.length;
    final positionLabel = 'Frage ${_currentIndex + 1} von $total';
    final bool isLastQuestion = _currentIndex >= total - 1;

    final Color highlightColor = theme.colorScheme.secondaryContainer;
    final Color onHighlightColor = theme.colorScheme.onSecondaryContainer;

    return Scaffold(
      appBar: AppBar(title: Text(widget.title)),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Text(positionLabel, style: theme.textTheme.titleMedium),
              const SizedBox(height: 12),
              Card(
                child: Padding(
                  padding: const EdgeInsets.all(16),
                  child: Text(
                    question.text,
                    style: theme.textTheme.titleLarge?.copyWith(fontWeight: FontWeight.bold),
                  ),
                ),
              ),
              const SizedBox(height: 16),
              Expanded(
                child: ListView(
                  children: [
                    ...List.generate(question.answers.length, (index) {
                      final isCorrect = index == question.correctIndex;
                      return Padding(
                        padding: const EdgeInsets.only(bottom: 12),
                        child: Card(
                          color: isCorrect ? highlightColor : null,
                          child: ListTile(
                            leading: Icon(
                              isCorrect ? Icons.check_circle : Icons.radio_button_unchecked,
                              color: isCorrect ? onHighlightColor : theme.iconTheme.color,
                            ),
                            title: Text(
                              question.answers[index],
                              style: theme.textTheme.bodyLarge?.copyWith(
                                color: isCorrect ? onHighlightColor : null,
                                fontWeight: isCorrect ? FontWeight.w600 : null,
                              ),
                            ),
                          ),
                        ),
                      );
                    }),
                    const SizedBox(height: 12),
                    Card(
                      child: Padding(
                        padding: const EdgeInsets.all(16),
                        child: Text(
                          question.explanation,
                          style: theme.textTheme.bodyMedium,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 16),
              Row(
                children: [
                  Expanded(
                    child: OutlinedButton(
                      onPressed: _currentIndex > 0 ? _goToPrevious : null,
                      child: const Text('Zuruck'),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: ElevatedButton(
                      onPressed: isLastQuestion
                          ? () => Navigator.of(context).pop()
                          : _goToNext,
                      child: Text(isLastQuestion ? 'Fertig' : 'Weiter'),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}
