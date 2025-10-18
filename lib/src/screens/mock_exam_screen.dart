import 'dart:async';

import 'package:flutter/material.dart';

import '../core/controller.dart';
import '../core/prefs.dart';
import '../widgets/question_card.dart';
import '../widgets/image_answer_grid.dart';
import '../widgets/answer_text_tile.dart';
import '../utils/asset_image_cache.dart';
import '../analytics/progress_repository.dart';
import '../analytics/progress_tracker.dart';
// question model used indirectly via controller
import 'mock_exam_result_screen.dart';

/// Mock exam screen: uses Controller.loadMockExam to prepare a 33-question exam.
/// - 30 general + 3 state (if available)
/// - 60 minute countdown
/// - no immediate feedback; answers are stored in local `answers` list
class MockExamScreen extends StatefulWidget {
  const MockExamScreen({super.key});

  @override
  State<MockExamScreen> createState() => _MockExamScreenState();
}

class _MockExamScreenState extends State<MockExamScreen> {
  Controller? _controller;
  Timer? _timer;
  Duration _remaining = const Duration(minutes: 60);
  bool _submitting = false;
  ProgressTracker? _tracker;
  late final DateTime _sessionStart = DateTime.now();
  late final String _sessionId = 'exam-${_sessionStart.millisecondsSinceEpoch}';

  // local answers: index -> selected answer index (or null)
  List<int?> answers = [];

  @override
  void initState() {
    super.initState();
    AppPrefs.getSelectedState().then((stateCode) {
      _controller = Controller(stateCode: stateCode);
      _startExam();
    });
  }

  @override
  void dispose() {
    _timer?.cancel();
    super.dispose();
  }

  Future<void> _startExam() async {
    await _controller!.loadMockExam();
    answers = List<int?>.filled(_controller!.questions.length, null);
    setState(() {});
    _startTimer();
    await ProgressRepository.instance.init();
    await ProgressRepository.instance.startSession(sessionId: _sessionId, mode: SessionMode.exam, totalQuestions: _controller!.questions.length);
    _tracker = ProgressTracker(mode: SessionMode.exam, repo: ProgressRepository.instance, sessionId: _sessionId);
    _controller!.attachTracker(_tracker!);
    if (_controller!.questions.isNotEmpty) {
      _controller!.tracker?.onQuestionShown(_controller!.questions[_controller!.currentIndex]);
    }
    // Prefetch images for current + next two
    WidgetsBinding.instance.addPostFrameCallback((_) => _prefetchAroundCurrent());
  }

  void _startTimer() {
    _timer?.cancel();
    _remaining = const Duration(minutes: 60);
    _timer = Timer.periodic(const Duration(seconds: 1), (t) {
      if (!mounted) return;
      setState(() {
        _remaining = _remaining - const Duration(seconds: 1);
        if (_remaining.inSeconds <= 0) {
          _timer?.cancel();
          _submit(auto: true);
        }
      });
    });
  }

  String _format(Duration d) {
    final min = d.inMinutes.remainder(60).toString().padLeft(2, '0');
    final sec = d.inSeconds.remainder(60).toString().padLeft(2, '0');
    return '$min:$sec';
  }

  void _select(int index) {
    setState(() {
      answers[_controller!.currentIndex] = index;
    });
  }

  Future<void> _submit({bool auto = false}) async {
    if (_submitting) return;
    // Confirmation is handled by the caller (e.g. _onAbgebenPressed).
    // If called with auto=true (timer), we skip any prompt and submit directly.

    setState(() => _submitting = true);
    _timer?.cancel();

    // Evaluate and log each attempt (exam mode)
    final total = _controller!.questions.length;
    int correct = 0;
    final results = <int?>[];
    for (var i = 0; i < total; i++) {
      final q = _controller!.questions[i];
      final sel = answers[i];
      results.add(sel);
      final isCorrect = sel != null && sel == q.correctIndex;
      if (isCorrect) correct += 1;
      // Log attempt for progress/analytics
      await ProgressRepository.instance.logAttempt(
        sessionId: _sessionId,
        questionId: q.id,
        topicId: q.topicId,
        isState: _controller!.isStateQuestion(q),
        mode: SessionMode.exam,
        selectedIndex: sel,
        correctIndex: q.correctIndex,
        isCorrect: isCorrect,
        skipped: sel == null,
        timeToAnswerMs: 0, // unknown per-question after review; can be improved later
        timestamp: _sessionStart.add(Duration(seconds: i)),
      );
    }
    await ProgressRepository.instance.finishSession(sessionId: _sessionId, correctCount: correct, duration: DateTime.now().difference(_sessionStart));

    // Navigate to results; remove this route (so user lands back on home later)
    if (!mounted) return;
    Navigator.of(context).pushReplacement(
      MaterialPageRoute(builder: (_) => MockExamResultScreen(total: total, correct: correct, questions: _controller!.questions, answers: results)),
    );
  }

  void _onAbgebenPressed() async {
    if (_submitting) return;
    final ok = await showDialog<bool>(
      context: context,
      builder: (c) {
        return AlertDialog(
          title: const Text('Prüfung abgeben?'),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Text('Möchtest du die Prüfung jetzt abgeben? Du kannst danach nicht zurück.'),
              const SizedBox(height: 16),
              Row(
                children: [
                  Expanded(
                    child: SizedBox(
                      height: 44,
                      child: ElevatedButton(
                        onPressed: () => Navigator.of(c).pop(true),
                        child: const Text('Ja'),
                      ),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: SizedBox(
                      height: 44,
                      child: ElevatedButton(
                        onPressed: () => Navigator.of(c).pop(false),
                        child: const Text('Nein'),
                      ),
                    ),
                  ),
                ],
              ),
            ],
          ),
        );
      },
    );

    if (ok == true) {
      await _submit(auto: false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return WillPopScope(
      onWillPop: () async => false,
      child: Scaffold(
        appBar: null,
        body: SafeArea(
          child: (_controller == null || _controller!.isLoading)
              ? const Center(child: CircularProgressIndicator())
              : _controller!.questions.isEmpty
                  ? const Center(child: Text('Keine Fragen verfügbar'))
                  : Padding(
                      padding: const EdgeInsets.all(12.0),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.stretch,
                        children: [
                          // Heading
                          Center(child: Text('Probeprüfung', style: Theme.of(context).textTheme.titleLarge)),
                          const SizedBox(height: 8),
                          // Timer (left) and Abgeben button (right) on the same row
                          Row(
                            children: [
                              // Timer on the left
                              Text(_format(_remaining), style: Theme.of(context).textTheme.titleMedium),
                              const Spacer(),
                              ElevatedButton(
                                onPressed: _submitting ? null : _onAbgebenPressed,
                                child: const Text('Abgeben'),
                              ),
                            ],
                          ),
                          const SizedBox(height: 12),
                          // position label and questions below
                          Text(_controller!.positionLabel(), style: Theme.of(context).textTheme.titleSmall),
                          const SizedBox(height: 8),
                          Expanded(
                            child: ListView(
                              padding: EdgeInsets.zero,
                              children: [
                                QuestionCard(
                                  text: _controller!.questions[_controller!.currentIndex].text,
                                  index: _controller!.currentIndex,
                                  image: _controller!.questions[_controller!.currentIndex].hasContextImage
                                      ? _controller!.questions[_controller!.currentIndex].image
                                      : null,
                                ),
                                const SizedBox(height: 12),
                                if (_controller!.questions[_controller!.currentIndex].hasAnswerImages)
                                  Padding(
                                    padding: const EdgeInsets.only(bottom: 12),
                                    child: ImageAnswerGrid(
                                      images: _controller!.questions[_controller!.currentIndex].answerImages!,
                                      correctIndex: _controller!.questions[_controller!.currentIndex].correctIndex,
                                      selectedIndex: answers[_controller!.currentIndex],
                                      revealed: false, // no reveal in mock exam before submit
                                      onTap: (i) => _select(i),
                                      disableInkSplash: true,
                                    ),
                                  )
                                else
                                  ...List.generate(_controller!.questions[_controller!.currentIndex].answers.length, (i) {
                                    final a = _controller!.questions[_controller!.currentIndex].answers[i];
                                    final sel = answers[_controller!.currentIndex];
                                    final selected = sel == i;
                                    // In mock exam, revealed is always false before submit
                                    return AnswerTextTile(
                                      text: a,
                                      revealed: false,
                                      isSelected: selected,
                                      isCorrect: i == _controller!.questions[_controller!.currentIndex].correctIndex,
                                      onTap: () => _select(i),
                                      disableInkSplash: true,
                                      animationDuration: Duration.zero,
                                    );
                                  }),
                                const SizedBox(height: 12),
                              ],
                            ),
                          ),
                          Row(
                            children: [
                              Expanded(
                                child: ElevatedButton(
                                  style: ElevatedButton.styleFrom(
                                    minimumSize: const Size.fromHeight(48),
                                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                                  ),
                                  onPressed: _controller!.currentIndex > 0
                                      ? () {
                                          setState(() {
                                            _controller!.previous();
                                          });
                                          _prefetchAroundCurrent();
                                        }
                                      : null,
                                      // Prefetch around new index
                                      onLongPress: null,
                                  child: const Text('Zurück'),
                                ),
                              ),
                              const SizedBox(width: 8),
                              Expanded(
                                child: ElevatedButton(
                                  style: ElevatedButton.styleFrom(
                                    minimumSize: const Size.fromHeight(48),
                                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                                  ),
                                  onPressed: _controller!.currentIndex < _controller!.questions.length - 1 ? () { setState(() { _controller!.next(); }); _prefetchAroundCurrent(); } : null,
                                  child: const Text('Weiter'),
                                ),
                              ),
                            ],
                          )
                        ],
                      ),
                    ),
        ),
      ),
    );
  }

  void _prefetchAroundCurrent() {
    if (!mounted || _controller == null || _controller!.questions.isEmpty) return;
    final ctx = context;
    final idx = _controller!.currentIndex;
    final qs = _controller!.questions;
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

// result moved to mock_exam_result_screen.dart
