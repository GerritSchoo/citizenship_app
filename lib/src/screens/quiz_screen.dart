import 'package:flutter/material.dart';
import 'dart:async';
import '../data/question_repository.dart';
import '../models/question.dart';
import '../core/controller.dart';
import '../core/prefs.dart';
import '../widgets/question_card.dart';
import '../widgets/image_answer_grid.dart';
import '../widgets/answer_text_tile.dart';
import '../analytics/progress_repository.dart';
import '../analytics/progress_tracker.dart';
import '../utils/asset_image_cache.dart';
import '../../l10n/app_localizations.dart';
import '../achievements/achievement_service.dart';
import '../core/quiz_mode.dart';
import '../core/highscore_store.dart';
import 'timer_results_screen.dart';
import 'mistakes_results_screen.dart';
import '../core/mistakes_selection_store.dart';
import '../../app.dart';

class QuizScreen extends StatefulWidget {
  final QuizConfig? config;
  // When provided, the quiz will use exactly these questions (by id), shuffled.
  // Used for the Mistakes iterative flow to retry only incorrect questions.
  final List<String>? fixedQuestionIds;
  const QuizScreen({super.key, this.config, this.fixedQuestionIds});

  @override
  State<QuizScreen> createState() => _QuizScreenState();
}

class _QuizScreenState extends State<QuizScreen> {
  final QuestionRepository _repo = QuestionRepository();
  Controller? _controller; // becomes available after async init
  ProgressTracker? _tracker;
  late final DateTime _sessionStart = DateTime.now();
  late final String _sessionId = 'practice-${_sessionStart.millisecondsSinceEpoch}';
  bool _showOriginalDe = false; // per-screen toggle
  Timer? _timer;
  int _remainingSeconds = 0;
  bool _sessionFinished = false;
  bool _mistakesFlow = false;

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
    final cfg = widget.config;
    // Ensure analytics available before any mode that reads from it
    await ProgressRepository.instance.init();
    // Determine whether this run is part of the Mistakes flow
    _mistakesFlow = (cfg?.mode == QuizMode.mistakes) || (widget.fixedQuestionIds != null);

    if (widget.fixedQuestionIds != null && widget.fixedQuestionIds!.isNotEmpty) {
      await _repo.init(languageCode: QuestionRepository.defaultLanguageCode);
      final all = <Question>[];
      all.addAll(_repo.generalQuestions);
      final state = code;
      if (state != null && _repo.hasStateQuestions(state)) {
        all.addAll(_repo.getStateQuestions(state));
      }
      final byId = {for (final q in all) q.id: q};
      final picked = <Question>[];
      for (final id in widget.fixedQuestionIds!) {
        final q = byId[id];
        if (q != null) picked.add(q);
      }
      if (picked.isNotEmpty) {
        ctrl.setQuestions(picked, shuffle: true);
      } else {
        await ctrl.loadCombined(shuffle: true);
      }
    } else if (cfg == null) {
      await ctrl.loadCombined(shuffle: true);
    } else {
      await _repo.init(languageCode: QuestionRepository.defaultLanguageCode);
      if (cfg.mode == QuizMode.topics && (cfg.topicIds?.isNotEmpty ?? false)) {
        final items = <Question>[];
        for (final id in cfg.topicIds!) {
          items.addAll(_repo.getQuestionsByTopic(id));
        }
        ctrl.setQuestions(items, shuffle: true);
      } else if (cfg.mode == QuizMode.mistakes) {
        // Build selection for Mistakes mode according to new rules:
        // - If there are recent wrong answers: 10 recent wrong (practice) + 10 random from all
        // - If none: 20 random from all
        // - Exclude the last used 20 from the previous Mistakes run
        final all = <Question>[];
        all.addAll(_repo.generalQuestions);
        final state = code;
        if (state != null && _repo.hasStateQuestions(state)) {
          all.addAll(_repo.getStateQuestions(state));
        }
        final lastUsed = await MistakesSelectionStore.instance.getLastUsedIds();
        // Map questions by id for quick lookup and apply exclusion set
        final byId = {for (final q in all) q.id: q};

        // Recent wrong question ids (already ordered by recency desc in repo method)
        final recentWrongIds = await ProgressRepository.instance
            .recentlyIncorrectQuestionIds(limit: 200);

        final selected = <Question>[];
        final selectedIds = <String>{};

        // Helper to add by id if exists and not excluded or duplicate
        void addByIdIfEligible(String id) {
          if (selected.length >= (cfg.mistakeCount ?? 20)) return;
          if (lastUsed.contains(id)) return; // exclude last used round
          if (selectedIds.contains(id)) return; // no duplicates
          final q = byId[id];
          if (q != null) {
            selected.add(q);
            selectedIds.add(id);
          }
        }

        // 1) Take up to 10 recent wrong
        int wrongTarget = 10;
        for (final id in recentWrongIds) {
          if (selected.length >= wrongTarget) break;
          addByIdIfEligible(id);
        }

        // 2) Fill the rest with random from the remaining pool
        final remainingTarget = (cfg.mistakeCount ?? 20) - selected.length;
        if (remainingTarget > 0) {
          // Build a pool of eligible random candidates
          final pool = all.where((q) => !lastUsed.contains(q.id) && !selectedIds.contains(q.id)).toList();
          pool.shuffle();
          for (final q in pool) {
            if (selected.length >= (cfg.mistakeCount ?? 20)) break;
            selected.add(q);
            selectedIds.add(q.id);
          }
        }

        // 3) If there were no recent wrongs, ensure we have up to 20 random
        if (recentWrongIds.isEmpty && selected.isEmpty) {
          final pool = all.where((q) => !lastUsed.contains(q.id)).toList();
          pool.shuffle();
          selected.addAll(pool.take(cfg.mistakeCount ?? 20));
        }

        if (selected.isNotEmpty) {
          ctrl.setQuestions(selected, shuffle: true);
        } else {
          // Fallback: load combined shuffled
          await ctrl.loadCombined(shuffle: true);
        }
      } else if (cfg.mode == QuizMode.state) {
        // Only state-specific questions
        final state = code;
        if (state != null && _repo.hasStateQuestions(state)) {
          final items = _repo.getStateQuestions(state);
          ctrl.setQuestions(items, shuffle: true);
        } else {
          await ctrl.loadCombined(shuffle: true);
        }
      } else if (cfg.mode == QuizMode.timer) {
        await ctrl.loadCombined(shuffle: true);
        _startTimer(cfg.timerSeconds ?? 120);
      } else {
        await ctrl.loadCombined(shuffle: true);
      }
    }
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

  void _startTimer(int seconds) {
    _timer?.cancel();
    _remainingSeconds = seconds;
    _timer = Timer.periodic(const Duration(seconds: 1), (t) async {
      if (!mounted) return;
      if (_remainingSeconds <= 1) {
        t.cancel();
        setState(() => _remainingSeconds = 0);
        await _onTimerFinished();
      } else {
        setState(() => _remainingSeconds -= 1);
      }
    });
  }

  Future<void> _onTimerFinished() async {
    // Compute result
    int correct = 0;
    int answered = 0;
    try {
      correct = await ProgressRepository.instance.sessionCorrectCount(_sessionId);
      answered = await ProgressRepository.instance.sessionAttemptCount(_sessionId);
    } catch (_) {}
    // Persist highscore
    try {
      await HighscoreStore.instance.addTimerScore(correct: correct, answered: answered);
    } catch (_) {}
    // Finish analytics session with measured duration
    final duration = DateTime.now().difference(_sessionStart);
    try {
      await ProgressRepository.instance.finishSession(sessionId: _sessionId, correctCount: correct, duration: duration);
      _sessionFinished = true;
    } catch (_) {}
    if (!mounted) return;
    // Navigate to results screen (replace quiz)
    Navigator.of(context).pushReplacement(
      MaterialPageRoute(
        builder: (_) => TimerResultsScreen(correct: correct, answered: answered),
      ),
    );
  }

  Future<void> _loadData() async {
    final ctrl = _controller;
    if (ctrl == null) return;
    await ctrl.load(shuffle: true);
  }

  void _nextQuestion() {
    final ctrl = _controller;
    if (ctrl == null) return;
    if (_mistakesFlow && ctrl.isLast && ctrl.selectedIndex != null) {
      _onMistakesFinished();
      return;
    }
    if (!_mistakesFlow && ctrl.isLast && widget.config?.mode != QuizMode.timer) {
      Navigator.of(context).pop();
      return;
    }
    ctrl.next();
    _prefetchAroundCurrent();
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final contentLang = App.of(context)?.contentLocale ?? Localizations.localeOf(context).languageCode;
    // Show loading until controller is initialized
    if (_controller == null || (_controller!.questions.isEmpty && _controller!.isLoading)) {
      return const Scaffold(
        body: Center(child: CircularProgressIndicator()),
      );
    }

    if (_controller!.error != null) {
      return Scaffold(
        appBar: AppBar(title: Text(l10n.quiz_title), actions: _buildActions(context)),
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

    final title = widget.config?.mode == QuizMode.timer && _remainingSeconds > 0
        ? '${l10n.quiz_title}  •  ${_formatTime(_remainingSeconds)}'
        : l10n.quiz_title;
    return Scaffold(
      appBar: AppBar(title: Text(title), actions: _buildActions(context)),
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
                      // Always show German as base text
                      text: question.originalDeText ?? question.text,
                      index: ctrl.currentIndex,
                      image: question.hasContextImage ? question.image : null,
                      // Overlay: translated text in selected locale when toggle is active
                      originalDeText:
                          _showOriginalDe && contentLang != 'de' ? question.text : null,
                      showOriginalDe: _showOriginalDe && contentLang != 'de',
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
                          onTap: (i) {
                            final isCorrectTap = i == question.correctIndex;
                            setState(() => ctrl.select(i));
                            if (isCorrectTap) {
                              AchievementService.instance.onPracticeAnswered(
                                context,
                                inLearn: false,
                                isCorrect: true,
                                quizMode: widget.config?.mode,
                              );
                            }
                          },
                        ),
                      ),
                    if (!question.hasAnswerImages)
                      ...List.generate(question.answers.length, (index) {
                        final isSelected = ctrl.selectedIndex == index;
                        final isCorrect = index == question.correctIndex;
                        final bool showOverlay = _showOriginalDe && contentLang != 'de';
                        final String baseAnswer =
                            question.originalDeAnswers != null && question.originalDeAnswers!.length == question.answers.length
                                ? question.originalDeAnswers![index]
                                : question.answers[index];
                        return AnswerTextTile(
                          // Always show German as base answer
                          text: baseAnswer,
                          // Overlay: translated answer in selected locale
                          originalDe: showOverlay ? question.answers[index] : null,
                          revealed: ctrl.selectedIndex != null,
                          isSelected: isSelected,
                          isCorrect: isCorrect,
                          onTap: () {
                            setState(() => ctrl.select(index));
                            if (isCorrect) {
                              AchievementService.instance.onPracticeAnswered(
                                context,
                                inLearn: false,
                                isCorrect: true,
                                quizMode: widget.config?.mode,
                              );
                            }
                          },
                        );
                      }),

                    const SizedBox(height: 16),
                    if (ctrl.selectedIndex != null)
                      Card(
                        child: Padding(
                          padding: const EdgeInsets.all(16),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              // Base explanation in German
                              Text(
                                question.originalDeExplanation?.isNotEmpty == true
                                    ? question.originalDeExplanation!
                                    : question.explanation,
                                style: Theme.of(context).textTheme.bodyMedium,
                              ),
                              // Optional overlay: explanation in selected locale
                              if (_showOriginalDe && contentLang != 'de')
                                Padding(
                                  padding: const EdgeInsets.only(top: 6),
                                  child: Text(
                                    question.explanation,
                                    style: Theme.of(context).textTheme.bodySmall?.copyWith(
                                      color: Theme.of(context).colorScheme.onSurface.withValues(alpha: 0.6),
                                      fontStyle: FontStyle.italic,
                                    ),
                                  ),
                                ),
                            ],
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
                child: Text(
                  ctrl.isLast && !_mistakesFlow && widget.config?.mode != QuizMode.timer
                      ? l10n.finish_quiz
                      : l10n.next_question,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Future<void> _onMistakesFinished() async {
    // Gather incorrect question IDs for this session
    List<String> wrongIds = const [];
    try {
      wrongIds = await ProgressRepository.instance.sessionIncorrectQuestionIds(_sessionId);
    } catch (_) {}
    // For main Mistakes runs (not retry-only flows), remember last used 20 to exclude next time
    try {
      if (widget.fixedQuestionIds == null && _controller != null && _controller!.questions.isNotEmpty) {
        final ids = _controller!.questions.map((q) => q.id).toList();
        await MistakesSelectionStore.instance.setLastUsedIds(ids);
      }
    } catch (_) {}
    if (!mounted) return;
    Navigator.of(context).pushReplacement(
      MaterialPageRoute(
        builder: (_) => MistakesResultsScreen(questionIds: wrongIds),
      ),
    );
  }

  @override
  void dispose() {
    _timer?.cancel();
    // Best-effort: compute correct answers from attempts if repository is available
    final duration = DateTime.now().difference(_sessionStart);
    Future(() async {
      if (_sessionFinished) return;
      int correct = 0;
      try {
        if (ProgressRepository.instance.isAvailable) {
          correct = await ProgressRepository.instance.sessionCorrectCount(_sessionId);
        }
      } catch (_) {}
      try {
        await ProgressRepository.instance.finishSession(sessionId: _sessionId, correctCount: correct, duration: duration);
      } catch (_) {}
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

  List<Widget>? _buildActions(BuildContext context) {
    // Determine content language to decide if "Show Original" toggle is needed
    // If content is German, we don't need a translation button (German -> German)
    final contentLang = App.of(context)?.contentLocale ?? Localizations.localeOf(context).languageCode;
    if (contentLang == 'de') return null;
    return [
      IconButton(
        tooltip: 'DE',
        icon: Icon(_showOriginalDe ? Icons.translate : Icons.translate_outlined),
        onPressed: () => setState(() => _showOriginalDe = !_showOriginalDe),
      ),
    ];
  }

  String _formatTime(int seconds) {
    final m = (seconds ~/ 60).toString().padLeft(1, '0');
    final s = (seconds % 60).toString().padLeft(2, '0');
    return '$m:$s';
  }
}
