import 'dart:math';
import '../models/question.dart';
import 'progress_repository.dart';

class ProgressTracker {
  final SessionMode mode; // practice (learn+quiz) or exam
  final ProgressRepository repo;
  final String sessionId;
  // Determines whether a question should be logged as a state question.
  // Defaults to always false if not provided.
  final bool Function(Question) isStateResolver;

  DateTime? _shownAt;

  ProgressTracker({required this.mode, required this.repo, required this.sessionId, bool Function(Question)? isStateResolver})
      : isStateResolver = isStateResolver ?? ((_) => false);

  void onQuestionShown(Question q) {
    _shownAt = DateTime.now();
  }

  Future<void> onAnswered({required Question q, required int selectedIndex}) async {
    final now = DateTime.now();
    final start = _shownAt ?? now;
    final timeMs = max(0, now.difference(start).inMilliseconds);
    await repo.logAttempt(
      sessionId: sessionId,
      questionId: q.id,
      topicId: q.topicId,
      isState: isStateResolver(q),
      mode: mode,
      selectedIndex: selectedIndex,
      correctIndex: q.correctIndex,
      isCorrect: selectedIndex == q.correctIndex,
      skipped: false,
      timeToAnswerMs: timeMs,
      timestamp: now,
    );
    _shownAt = now;
  }

  Future<void> onSkipped(Question q) async {
    final now = DateTime.now();
    final start = _shownAt ?? now;
    final timeMs = max(0, now.difference(start).inMilliseconds);
    await repo.logAttempt(
      sessionId: sessionId,
      questionId: q.id,
      topicId: q.topicId,
      isState: isStateResolver(q),
      mode: mode,
      selectedIndex: null,
      correctIndex: q.correctIndex,
      isCorrect: false,
      skipped: true,
      timeToAnswerMs: timeMs,
      timestamp: now,
    );
    _shownAt = now;
  }
}
