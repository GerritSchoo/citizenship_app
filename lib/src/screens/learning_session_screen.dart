import 'package:flutter/material.dart';

import '../models/question.dart';
import '../theme/app_colors.dart';
import '../core/controller.dart';

class LearningSessionScreen extends StatefulWidget {
  final List<Question> questions;
  final String title;

  const LearningSessionScreen({super.key, required this.questions, required this.title});

  @override
  State<LearningSessionScreen> createState() => _LearningSessionScreenState();
}

class _LearningSessionScreenState extends State<LearningSessionScreen> {
  late final Controller _controller;

  void _goToNext() {
    _controller.next();
  }

  void _goToPrevious() {
    _controller.previous();
  }

  @override
  void initState() {
    super.initState();
    _controller = Controller();
    _controller.addListener(() => setState(() {}));
    // use provided list (learning session should not shuffle)
    _controller.setQuestions(widget.questions, shuffle: false);
  }

  @override
  void dispose() {
    _controller.removeListener(() {});
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    if (_controller.questions.isEmpty) {
      return Scaffold(
        appBar: AppBar(title: Text(widget.title)),
        body: const Center(child: Text('Keine Fragen verfugbar.')),
      );
    }

    final theme = Theme.of(context);
    final question = _controller.questions[_controller.currentIndex];
    final total = _controller.questions.length;
    final positionLabel = 'Frage ${_controller.currentIndex + 1} von $total';
    final bool isLastQuestion = _controller.isLast;

  // colors are provided by AppColors when needed

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
                      final isSelected = _controller.selectedIndex == index;
                      final isCorrect = index == question.correctIndex;

                      Color boxColor = theme.cardColor;
                      IconData? icon;

                      final bool isDark = theme.brightness == Brightness.dark;

                      if (_controller.selectedIndex != null) {
                        if (isSelected && isCorrect) {
                          boxColor = isDark ? AppColors.correctDark : AppColors.correct;
                          icon = Icons.check_circle;
                        } else if (isSelected && !isCorrect) {
                          boxColor = isDark ? AppColors.wrongDark : AppColors.wrong;
                          icon = Icons.cancel;
                        } else if (isCorrect) {
                          boxColor = isDark
                              ? AppColors.correctDark.withAlpha(128)
                              : AppColors.correctLight;
                          icon = Icons.check;
                        }
                      }

                      return Padding(
                        padding: const EdgeInsets.symmetric(vertical: 6),
                        child: Material(
                          color: Colors.transparent,
                          child: InkWell(
                            borderRadius: BorderRadius.circular(16),
                            onTap: () => _controller.select(index),
                            child: AnimatedContainer(
                              duration: const Duration(milliseconds: 200),
                              decoration: BoxDecoration(
                                color: boxColor,
                                borderRadius: BorderRadius.circular(16),
                              ),
                              padding: const EdgeInsets.symmetric(vertical: 14, horizontal: 16),
                              child: Row(
                                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                children: [
                                  Flexible(
                                    child: Text(
                                      question.answers[index],
                                      style: theme.textTheme.bodyLarge,
                                    ),
                                  ),
                                  if (icon != null)
                                    Icon(icon, color: theme.colorScheme.onPrimary, size: 24),
                                ],
                              ),
                            ),
                          ),
                        ),
                      );
                    }),

                    const SizedBox(height: 16),

                    if (_controller.selectedIndex != null)
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
                      onPressed: _controller.currentIndex > 0 ? _goToPrevious : null,
                      child: const Text('Zuruck'),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: ElevatedButton(
                      onPressed: _controller.selectedIndex != null
                          ? (isLastQuestion ? () => Navigator.of(context).pop() : _goToNext)
                          : null,
                      style: ElevatedButton.styleFrom(minimumSize: const Size.fromHeight(48)),
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
