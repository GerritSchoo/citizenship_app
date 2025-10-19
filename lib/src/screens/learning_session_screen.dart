import 'package:flutter/material.dart';

import '../models/question.dart';
import '../theme/app_colors.dart';
import '../core/controller.dart';
import '../widgets/question_card.dart';
import '../widgets/image_answer_grid.dart';
import '../utils/asset_image_cache.dart';
import '../analytics/progress_repository.dart';
import '../analytics/progress_tracker.dart';
import '../../l10n/app_localizations.dart';

class LearningSessionScreen extends StatefulWidget {
  final List<Question> questions;
  final String title;
  final String? stateCode;

  const LearningSessionScreen({super.key, required this.questions, required this.title, this.stateCode});

  @override
  State<LearningSessionScreen> createState() => _LearningSessionScreenState();
}

class _LearningSessionScreenState extends State<LearningSessionScreen> {
  late final Controller _controller;
  ProgressTracker? _tracker;
  late final DateTime _sessionStart = DateTime.now();
  late final String _sessionId = 'practice-${_sessionStart.millisecondsSinceEpoch}';
  late final VoidCallback _controllerListener;

  void _goToNext() {
    _controller.next();
    _prefetchAroundCurrent();
  }

  void _goToPrevious() {
    _controller.previous();
    _prefetchAroundCurrent();
  }

  @override
  void initState() {
    super.initState();
  // In learning mode, do not count skipped questions in analytics.
  _controller = Controller(stateCode: widget.stateCode, logSkips: false);
    _controllerListener = () {
      setState(() {});
      // Also prefetch when current index changes via external calls
      _prefetchAroundCurrent();
    };
    _controller.addListener(_controllerListener);
    // use provided list (learning session should not shuffle)
    _controller.setQuestions(widget.questions, shuffle: false);
    // init analytics
    ProgressRepository.instance.init().then((_) async {
      await ProgressRepository.instance.startSession(sessionId: _sessionId, mode: SessionMode.practice, totalQuestions: widget.questions.length);
      _tracker = ProgressTracker(
        mode: SessionMode.practice,
        repo: ProgressRepository.instance,
        sessionId: _sessionId,
        isStateResolver: (q) => _controller.isStateQuestion(q),
      );
      _controller.attachTracker(_tracker!);
    });
    // Initial prefetch
    WidgetsBinding.instance.addPostFrameCallback((_) => _prefetchAroundCurrent());
  }

  @override
  void dispose() {
    _controller.removeListener(_controllerListener);
    final duration = DateTime.now().difference(_sessionStart);
    // Best-effort: compute correct answers from attempts if repository is available
    Future(() async {
      int correct = 0;
      try {
        if (ProgressRepository.instance.isAvailable) {
          correct = await ProgressRepository.instance.sessionCorrectCount(_sessionId);
        }
      } catch (_) {}
      await ProgressRepository.instance.finishSession(sessionId: _sessionId, correctCount: correct, duration: duration);
    });
    // Clear image cache to free memory at end of session
    AssetImageInfoCache.clear();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    if (_controller.questions.isEmpty) {
      return Scaffold(
        appBar: AppBar(title: Text(widget.title)),
        body: Center(child: Text(l10n.no_questions)),
      );
    }

    final theme = Theme.of(context);
    final question = _controller.questions[_controller.currentIndex];
    final total = _controller.questions.length;
  final positionLabel = l10n.position_label((_controller.currentIndex + 1).toString(), total.toString());
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
              Text(
                positionLabel,
                style: theme.textTheme.titleMedium,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
              ),
              const SizedBox(height: 12),
              Expanded(
                child: ListView(
                  padding: EdgeInsets.zero,
                  children: [
                    QuestionCard(
                      text: question.text,
                      index: _controller.currentIndex,
                      image: question.hasContextImage ? question.image : null,
                    ),
                    const SizedBox(height: 16),
                    if (question.hasAnswerImages)
                      Padding(
                        padding: const EdgeInsets.only(bottom: 12),
                        child: ImageAnswerGrid(
                          images: question.answerImages!,
                          correctIndex: question.correctIndex,
                          selectedIndex: _controller.selectedIndex,
                          revealed: _controller.selectedIndex != null,
                          onTap: (i) => _controller.select(i),
                        ),
                      ),
                    if (!question.hasAnswerImages)
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
                          icon = Icons.check_circle;
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
                    style: theme.textTheme.bodyMedium,
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
                    child: ElevatedButton(
                      style: ElevatedButton.styleFrom(
                        minimumSize: const Size.fromHeight(48),
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                      ),
                      onPressed: _controller.currentIndex > 0 ? _goToPrevious : null,
                      child: Text(l10n.back_btn),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: ElevatedButton(
                      style: ElevatedButton.styleFrom(
                        minimumSize: const Size.fromHeight(48),
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                      ),
                      // Allow skipping without answering in Learning mode
                      onPressed: isLastQuestion ? () => Navigator.of(context).pop() : _goToNext,
                      child: Text(isLastQuestion ? l10n.done_btn : l10n.next_btn),
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

  void _prefetchAroundCurrent() {
    if (!mounted || _controller.questions.isEmpty) return;
    final ctx = context;
    final idx = _controller.currentIndex;
    final qs = _controller.questions;
    // Prefetch current + next two (if available)
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
