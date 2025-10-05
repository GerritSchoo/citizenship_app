import 'package:flutter/material.dart';
import '../data/question_repository.dart';
import '../models/question.dart';
import '../core/controller.dart';
import '../theme/app_colors.dart';

class QuizScreen extends StatefulWidget {
  const QuizScreen({super.key});

  @override
  State<QuizScreen> createState() => _QuizScreenState();
}

class _QuizScreenState extends State<QuizScreen> {
  final QuestionRepository _repo = QuestionRepository();
  late final Controller _controller;

  @override
  void initState() {
    super.initState();
    _controller = Controller(repository: _repo);
    _controller.addListener(() => setState(() {}));
    _loadData();
  }

  Future<void> _loadData() async {
    await _controller.load(shuffle: true);
  }

  void _nextQuestion() {
    _controller.next();
  }

  @override
  Widget build(BuildContext context) {
    if (_controller.error != null) {
      return Scaffold(
        appBar: AppBar(title: const Text('Quiz')),
        body: SafeArea(
          child: Center(
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text('Failed to load questions', style: Theme.of(context).textTheme.bodyLarge),
                  const SizedBox(height: 8),
                  Text(_controller.error!, style: Theme.of(context).textTheme.bodyMedium),
                  const SizedBox(height: 12),
                  ElevatedButton(
                    onPressed: _loadData,
                    child: const Text('Retry'),
                  ),
                ],
              ),
            ),
          ),
        ),
      );
    }

    if (_controller.questions.isEmpty && _controller.isLoading) {
      return const Scaffold(
        body: Center(child: CircularProgressIndicator()),
      );
    }

    final Question question = _controller.questions[_controller.currentIndex];
    final bool isDark = Theme.of(context).brightness == Brightness.dark;

    return Scaffold(
      appBar: AppBar(title: const Text("Quiz")),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            children: [
              // Question Card
              Card(
                child: Padding(
                  padding: const EdgeInsets.all(16),
                  child: Text(
                    question.text,
                    style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                          fontWeight: FontWeight.bold,
                          fontSize: 20,
                        ),
                    textAlign: TextAlign.center,
                  ),
                ),
              ),

              const SizedBox(height: 16),

              // Answers + Explanation
              Expanded(
                child: ListView(
                  children: [
                    ...List.generate(question.answers.length, (index) {
                      final isSelected = _controller.selectedIndex == index;
                      final isCorrect = index == question.correctIndex;

                      Color boxColor = Theme.of(context).cardColor;
                      IconData? icon;

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
                              padding: const EdgeInsets.symmetric(
                                  vertical: 14, horizontal: 16),
                              child: Row(
                                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                children: [
                                  Flexible(
                                    child: Text(
                                      question.answers[index],
                                      style: Theme.of(context).textTheme.bodyLarge,
                                    ),
                                  ),
                                  if (icon != null)
                                    Icon(icon, color: Theme.of(context).colorScheme.onPrimary, size: 24),
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
                            style: Theme.of(context).textTheme.bodyMedium,
                          ),
                        ),
                      ),
                  ],
                ),
              ),

              const SizedBox(height: 12),

              ElevatedButton(
                onPressed: _controller.selectedIndex != null ? _nextQuestion : null,
                style: ElevatedButton.styleFrom(
                  minimumSize: const Size(double.infinity, 48),
                ),
                child: const Text("Next Question"),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
