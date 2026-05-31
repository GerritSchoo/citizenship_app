import 'package:firebase_analytics/firebase_analytics.dart';

class AnalyticsService {
  static final instance = AnalyticsService._();
  AnalyticsService._();

  final _analytics = FirebaseAnalytics.instance;

  Future<void> logPaywallShown() =>
      _analytics.logEvent(name: 'paywall_shown');

  Future<void> logPurchaseStarted(String productId) =>
      _analytics.logEvent(name: 'purchase_started', parameters: {'product_id': productId});

  Future<void> logPurchaseCompleted(String productId) =>
      _analytics.logEvent(name: 'purchase_completed', parameters: {'product_id': productId});

  Future<void> logExamStarted() =>
      _analytics.logEvent(name: 'exam_started');

  Future<void> logExamCompleted(int score, int total, {required bool passed}) =>
      _analytics.logEvent(name: 'exam_completed', parameters: {
        'score': score,
        'total': total,
        'passed': passed ? 1 : 0,
      });

  Future<void> logQuizStarted(String mode) =>
      _analytics.logEvent(name: 'quiz_started', parameters: {'mode': mode});

  Future<void> logQuizCompleted(String mode, int correct, int total) =>
      _analytics.logEvent(name: 'quiz_completed', parameters: {
        'mode': mode,
        'correct': correct,
        'total': total,
      });

  Future<void> logLearningStarted(String topic) =>
      _analytics.logEvent(name: 'learning_started', parameters: {'topic': topic});
}
