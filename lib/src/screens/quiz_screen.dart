import 'package:flutter/material.dart';
import '../data/question_repository.dart';
import '../models/question.dart';
import '../core/controller.dart';
import '../core/prefs.dart';
import '../theme/app_colors.dart';
import '../widgets/question_card.dart';
import '../widgets/image_answer_grid.dart';
import '../analytics/progress_repository.dart';
import '../analytics/progress_tracker.dart';
import '../utils/asset_image_cache.dart';
import '../../l10n/app_localizations.dart';

class QuizScreen extends StatefulWidget {
  const QuizScreen({super.key});

  @override
  State<QuizScreen> createState() => _QuizScreenState();
}

class _QuizScreenState extends State<QuizScreen> {
  final QuestionRepository _repo = QuestionRepository();
  Controller? _controller; // becomes available after async init
  ProgressTracker? _tracker;
  late final DateTime _sessionStart = DateTime.now();
  late final String _sessionId = 'practice-${_sessionStart.millisecondsSinceEpoch}';

  @override
  void initState() {
    super.initState();
    _init();
  }

  Future<void> _init() async {
    final code = await AppPrefs.getSelectedState();
  // Practice/quiz should not count skipped questions in analytics.
  final ctrl = Controller(repository: _repo, stateCode: code, logSkips: false);
    ctrl.addListener(() {
      if (!mounted) return;
      setState(() {});
      _prefetchAroundCurrent();
    });
    setState(() {
      _controller = ctrl;
    });
    await ctrl.loadCombined(shuffle: true);
    await ProgressRepository.instance.init();
    await ProgressRepository.instance.startSession(sessionId: _sessionId, mode: SessionMode.practice, totalQuestions: ctrl.questions.length);
    _tracker = ProgressTracker(
      mode: SessionMode.practice,
      repo: ProgressRepository.instance,
      sessionId: _sessionId,
      isStateResolver: (q) => ctrl.isStateQuestion(q),
    );
    ctrl.attachTracker(_tracker!);
    _prefetchAroundCurrent();
  }

  Future<void> _loadData() async {
    final ctrl = _controller;
    if (ctrl == null) return;
    await ctrl.load(shuffle: true);
  }

  void _nextQuestion() {
    final ctrl = _controller;
    if (ctrl == null) return;
    ctrl.next();
    _prefetchAroundCurrent();
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    // Show loading until controller is initialized
    if (_controller == null || (_controller!.questions.isEmpty && _controller!.isLoading)) {
      return const Scaffold(
        body: Center(child: CircularProgressIndicator()),
      );
    }

    if (_controller!.error != null) {
      return Scaffold(
        appBar: AppBar(title: Text(l10n.quiz_title)),
        body: SafeArea(
          child: Center(
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(l10n.error_loading_questions, style: Theme.of(context).textTheme.bodyLarge),
                  const SizedBox(height: 8),
                  Text(_controller!.error!, style: Theme.of(context).textTheme.bodyMedium),
                  const SizedBox(height: 12),
                  ElevatedButton(
                    onPressed: _loadData,
                    child: Text(l10n.retry),
                  ),
                ],
              ),
            ),
          ),
        ),
      );
    }
    final ctrl = _controller!;
    final Question question = ctrl.questions[ctrl.currentIndex];
    final bool isDark = Theme.of(context).brightness == Brightness.dark;

    return Scaffold(
      appBar: AppBar(title: Text(l10n.quiz_title)),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            children: [
              // Single scrollable area: question + answers + explanation
              Expanded(
                child: ListView(
                  padding: EdgeInsets.zero,
                  children: [
                    QuestionCard(
                      text: question.text,
                      index: ctrl.currentIndex,
                      image: question.hasContextImage ? question.image : null,
                    ),
                    const SizedBox(height: 16),
                    if (question.hasAnswerImages)
                      Padding(
                        padding: const EdgeInsets.only(bottom: 12),
                        child: ImageAnswerGrid(
                          images: question.answerImages!,
                          correctIndex: question.correctIndex,
                          selectedIndex: ctrl.selectedIndex,
                          revealed: ctrl.selectedIndex != null,
                          onTap: (i) => setState(() => ctrl.select(i)),
                        ),
                      ),
                    if (!question.hasAnswerImages)
                      ...List.generate(question.answers.length, (index) {
                      final isSelected = ctrl.selectedIndex == index;
                      final isCorrect = index == question.correctIndex;

                      Color boxColor = Theme.of(context).cardColor;
                      IconData? icon;

                      if (ctrl.selectedIndex != null) {
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
                          icon = Icons.check_circle;
                        }
                      }

                      return Padding(
                        padding: const EdgeInsets.symmetric(vertical: 6),
                        child: Material(
                          color: Colors.transparent,
                          child: InkWell(
                            borderRadius: BorderRadius.circular(16),
                            onTap: () => ctrl.select(index),
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
                    style: Theme.of(context).textTheme.bodyMedium,
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
                    if (ctrl.selectedIndex != null)
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
                onPressed: ctrl.selectedIndex != null ? _nextQuestion : null,
                style: ElevatedButton.styleFrom(
                  minimumSize: const Size(double.infinity, 48),
                ),
                child: Text(l10n.next_question),
              ),
            ],
          ),
        ),
      ),
    );
  }

  @override
  void dispose() {
    // Best-effort: compute correct answers from attempts if repository is available
    final duration = DateTime.now().difference(_sessionStart);
    Future(() async {
      int correct = 0;
      try {
        if (ProgressRepository.instance.isAvailable) {
          correct = await ProgressRepository.instance.sessionCorrectCount(_sessionId);
        }
      } catch (_) {}
      await ProgressRepository.instance.finishSession(sessionId: _sessionId, correctCount: correct, duration: duration);
    });
    // Clear cached images for memory hygiene when leaving quiz
    AssetImageInfoCache.clear();
    super.dispose();
  }

  void _prefetchAroundCurrent() {
    final ctrl = _controller;
    if (!mounted || ctrl == null || ctrl.questions.isEmpty) return;
    final ctx = context;
    final idx = ctrl.currentIndex;
    final qs = ctrl.questions;
    final toPrefetch = <String>{};
    for (final i in [idx, idx + 1, idx + 2]) {
      if (i >= 0 && i < qs.length) {
        final q = qs[i];
        if (q.hasContextImage && q.image != null && q.image!.isNotEmpty) {
          toPrefetch.add(q.image!);
        }
        if (q.hasAnswerImages) {
          toPrefetch.addAll(q.answerImages!.where((p) => p.isNotEmpty));
        }
      }
    }
    AssetImageInfoCache.precacheAll(ctx, toPrefetch);
  }
}
