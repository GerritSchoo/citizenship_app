import 'dart:async';
import 'package:flutter/material.dart';
import '../analytics/progress_repository.dart';
import '../../app.dart';
import '../../l10n/app_localizations.dart';
import '../core/quiz_mode.dart';
import 'achievement_model.dart';

class AchievementService {
  AchievementService._();
  static final AchievementService instance = AchievementService._();

  // Define a small starter set of achievements. More can be added later.
  static const List<AchievementDef> all = [
    AchievementDef(
      id: 'learn.first_correct',
      category: AchievementCategory.learn,
      difficulty: AchievementDifficulty.easy,
      nameKey: 'ach_learn_first_correct_name',
      descKey: 'ach_learn_first_correct_desc',
      icon: Icons.lightbulb_outline,
    ),
    AchievementDef(
      id: 'quiz.first_correct',
      category: AchievementCategory.quiz,
      difficulty: AchievementDifficulty.easy,
      nameKey: 'ach_quiz_first_correct_name',
      descKey: 'ach_quiz_first_correct_desc',
      icon: Icons.quiz_outlined,
    ),
    AchievementDef(
      id: 'exam.pass',
      category: AchievementCategory.exam,
      difficulty: AchievementDifficulty.medium,
      nameKey: 'ach_exam_pass_name',
      descKey: 'ach_exam_pass_desc',
      icon: Icons.verified_outlined,
    ),
    AchievementDef(
      id: 'exam.30_correct',
      category: AchievementCategory.exam,
      difficulty: AchievementDifficulty.hard,
      nameKey: 'ach_exam_30_name',
      descKey: 'ach_exam_30_desc',
      icon: Icons.emoji_events_outlined,
    ),
    // Beginner practice milestones
    AchievementDef(
      id: 'practice.10_correct',
      category: AchievementCategory.learn,
      difficulty: AchievementDifficulty.easy,
      nameKey: 'ach_practice_10_name',
      descKey: 'ach_practice_10_desc',
      icon: Icons.filter_1_outlined,
    ),
    // Intermediate practice milestone
    AchievementDef(
      id: 'practice.100_correct',
      category: AchievementCategory.quiz,
      difficulty: AchievementDifficulty.medium,
      nameKey: 'ach_practice_100_name',
      descKey: 'ach_practice_100_desc',
      icon: Icons.filter_9_plus_outlined,
    ),
    // Expert practice milestone
    AchievementDef(
      id: 'practice.1000_correct',
      category: AchievementCategory.quiz,
      difficulty: AchievementDifficulty.hard,
      nameKey: 'ach_practice_1000_name',
      descKey: 'ach_practice_1000_desc',
      icon: Icons.all_inclusive,
    ),
    // First exam submitted
    AchievementDef(
      id: 'exam.first',
      category: AchievementCategory.exam,
      difficulty: AchievementDifficulty.easy,
      nameKey: 'ach_exam_first_name',
      descKey: 'ach_exam_first_desc',
      icon: Icons.flag_outlined,
    ),
    // Intermediate exam score
    AchievementDef(
      id: 'exam.25_correct',
      category: AchievementCategory.exam,
      difficulty: AchievementDifficulty.medium,
      nameKey: 'ach_exam_25_name',
      descKey: 'ach_exam_25_desc',
      icon: Icons.military_tech_outlined,
    ),
    // Expert perfect exam
    AchievementDef(
      id: 'exam.perfect',
      category: AchievementCategory.exam,
      difficulty: AchievementDifficulty.hard,
      nameKey: 'ach_exam_perfect_name',
      descKey: 'ach_exam_perfect_desc',
      icon: Icons.star_outline,
    ),
    // Expert: three passes in a row
    AchievementDef(
      id: 'exam.pass_streak3',
      category: AchievementCategory.exam,
      difficulty: AchievementDifficulty.hard,
      nameKey: 'ach_exam_streak3_name',
      descKey: 'ach_exam_streak3_desc',
      icon: Icons.auto_awesome_outlined,
    ),
    // Expert: fast pass
    AchievementDef(
      id: 'exam.fast_pass',
      category: AchievementCategory.exam,
      difficulty: AchievementDifficulty.hard,
      nameKey: 'ach_exam_fast_name',
      descKey: 'ach_exam_fast_desc',
      icon: Icons.flash_on_outlined,
    ),
    // Harder exam achievements
    AchievementDef(
      id: 'exam.fast_pass_5min',
      category: AchievementCategory.exam,
      difficulty: AchievementDifficulty.hard,
      nameKey: 'ach_exam_fast5_name',
      descKey: 'ach_exam_fast5_desc',
      icon: Icons.flash_on_outlined,
    ),
    AchievementDef(
      id: 'exam.pass_10',
      category: AchievementCategory.exam,
      difficulty: AchievementDifficulty.hard,
      nameKey: 'ach_exam_pass10_name',
      descKey: 'ach_exam_pass10_desc',
      icon: Icons.verified_user_outlined,
    ),
    AchievementDef(
      id: 'exam.perfect_3',
      category: AchievementCategory.exam,
      difficulty: AchievementDifficulty.hard,
      nameKey: 'ach_exam_perfect3_name',
      descKey: 'ach_exam_perfect3_desc',
      icon: Icons.star_half_outlined,
    ),
    AchievementDef(
      id: 'exam.pass_streak5',
      category: AchievementCategory.exam,
      difficulty: AchievementDifficulty.hard,
      nameKey: 'ach_exam_streak5_name',
      descKey: 'ach_exam_streak5_desc',
      icon: Icons.auto_awesome_outlined,
    ),
    // --- Timer mode achievements ---
    AchievementDef(
      id: 'timer.first',
      category: AchievementCategory.quiz,
      difficulty: AchievementDifficulty.easy,
      nameKey: 'ach_timer_first_name',
      descKey: 'ach_timer_first_desc',
      icon: Icons.timer_outlined,
    ),
    AchievementDef(
      id: 'timer.10_correct',
      category: AchievementCategory.quiz,
      difficulty: AchievementDifficulty.easy,
      nameKey: 'ach_timer_10_name',
      descKey: 'ach_timer_10_desc',
      icon: Icons.timer_outlined,
    ),
    AchievementDef(
      id: 'timer.20_correct',
      category: AchievementCategory.quiz,
      difficulty: AchievementDifficulty.medium,
      nameKey: 'ach_timer_20_name',
      descKey: 'ach_timer_20_desc',
      icon: Icons.timer_outlined,
    ),
    AchievementDef(
      id: 'timer.30_correct',
      category: AchievementCategory.quiz,
      difficulty: AchievementDifficulty.hard,
      nameKey: 'ach_timer_30_name',
      descKey: 'ach_timer_30_desc',
      icon: Icons.timer_outlined,
    ),
    // --- Mistakes mode achievements ---
    AchievementDef(
      id: 'mistakes.reviewed',
      category: AchievementCategory.quiz,
      difficulty: AchievementDifficulty.easy,
      nameKey: 'ach_mistakes_review_name',
      descKey: 'ach_mistakes_review_desc',
      icon: Icons.rule_folder_outlined,
    ),
    AchievementDef(
      id: 'mistakes.clean',
      category: AchievementCategory.quiz,
      difficulty: AchievementDifficulty.medium,
      nameKey: 'ach_mistakes_clean_name',
      descKey: 'ach_mistakes_clean_desc',
      icon: Icons.emoji_events_outlined,
    ),
    // --- Topics mode achievements ---
    AchievementDef(
      id: 'topics.first',
      category: AchievementCategory.quiz,
      difficulty: AchievementDifficulty.easy,
      nameKey: 'ach_topics_first_name',
      descKey: 'ach_topics_first_desc',
      icon: Icons.category_outlined,
    ),
    // Long-term practice milestones
    AchievementDef(
      id: 'practice.2500_correct',
      category: AchievementCategory.learn,
      difficulty: AchievementDifficulty.hard,
      nameKey: 'ach_practice_2500_name',
      descKey: 'ach_practice_2500_desc',
      icon: Icons.filter_9_plus_outlined,
    ),
    AchievementDef(
      id: 'practice.5000_correct',
      category: AchievementCategory.learn,
      difficulty: AchievementDifficulty.hard,
      nameKey: 'ach_practice_5000_name',
      descKey: 'ach_practice_5000_desc',
      icon: Icons.filter_9_plus_outlined,
    ),
    AchievementDef(
      id: 'practice.10000_correct',
      category: AchievementCategory.learn,
      difficulty: AchievementDifficulty.hard,
      nameKey: 'ach_practice_10000_name',
      descKey: 'ach_practice_10000_desc',
      icon: Icons.all_inclusive,
    ),
    // Activity streaks
    AchievementDef(
      id: 'streak.7_days',
      category: AchievementCategory.quiz,
      difficulty: AchievementDifficulty.medium,
      nameKey: 'ach_streak7_name',
      descKey: 'ach_streak7_desc',
      icon: Icons.calendar_today_outlined,
    ),
    AchievementDef(
      id: 'streak.30_days',
      category: AchievementCategory.quiz,
      difficulty: AchievementDifficulty.hard,
      nameKey: 'ach_streak30_name',
      descKey: 'ach_streak30_desc',
      icon: Icons.calendar_month_outlined,
    ),
  ];

  final StreamController<AchievementDef> _unlocked = StreamController.broadcast();
  Stream<AchievementDef> get unlockedStream => _unlocked.stream;

  AchievementDef? byId(String id) => all.firstWhere(
        (a) => a.id == id,
        orElse: () => const AchievementDef(
          id: 'unknown',
          category: AchievementCategory.learn,
          difficulty: AchievementDifficulty.easy,
          nameKey: 'unknown',
          descKey: 'unknown',
          icon: Icons.help_outline,
        ),
      );

  Future<void> onPracticeAnswered(BuildContext context, {required bool inLearn, required bool isCorrect, QuizMode? quizMode}) async {
    if (!isCorrect) return;
    // Capture dependencies before async gaps to avoid using BuildContext afterwards
    final app = App.of(context);
    final l10n = AppLocalizations.of(context);
    await ProgressRepository.instance.init();
    final id = inLearn ? 'learn.first_correct' : 'quiz.first_correct';
    if (await ProgressRepository.instance.isAchievementUnlocked(id)) return;
    await ProgressRepository.instance.unlockAchievement(id);
    _notifyCaptured(app, l10n, byId(id)!);
    // Topics mode: first correct in Topics quiz
    if (!inLearn && quizMode == QuizMode.topics) {
      const topicsId = 'topics.first';
      if (!await ProgressRepository.instance.isAchievementUnlocked(topicsId)) {
        await ProgressRepository.instance.unlockAchievement(topicsId);
        _notifyCaptured(app, l10n, byId(topicsId)!);
      }
    }
    // Check cumulative practice thresholds (including long-term)
    try {
      final stats = await ProgressRepository.instance.overallStats(includePractice: true, includeExam: false);
      final milestones = <int, String>{
        10: 'practice.10_correct',
        100: 'practice.100_correct',
        1000: 'practice.1000_correct',
        2500: 'practice.2500_correct',
        5000: 'practice.5000_correct',
        10000: 'practice.10000_correct',
      };
      for (final entry in milestones.entries) {
        if (stats.correct >= entry.key && !(await ProgressRepository.instance.isAchievementUnlocked(entry.value))) {
          await ProgressRepository.instance.unlockAchievement(entry.value);
          _notifyCaptured(app, l10n, byId(entry.value)!);
        }
      }
    } catch (_) {}
    await _checkDailyStreaks(app, l10n);
  }

  Future<void> onExamSubmitted(BuildContext context, {required int correct, required int total}) async {
    // Capture dependencies before async gaps to avoid using BuildContext afterwards
    final app = App.of(context);
    final l10n = AppLocalizations.of(context);
    await ProgressRepository.instance.init();
    // First exam ever
    const idFirst = 'exam.first';
    if (!await ProgressRepository.instance.isAchievementUnlocked(idFirst)) {
      // If this is the first completed exam session, unlock
      final results = await ProgressRepository.instance.examResults(limit: 2);
      if (results.isNotEmpty) {
        await ProgressRepository.instance.unlockAchievement(idFirst);
        _notifyCaptured(app, l10n, byId(idFirst)!);
      }
    }
    if (correct >= 17) {
      const idPass = 'exam.pass';
      if (!await ProgressRepository.instance.isAchievementUnlocked(idPass)) {
        await ProgressRepository.instance.unlockAchievement(idPass);
        _notifyCaptured(app, l10n, byId(idPass)!);
      }
    }
    if (correct >= 25) {
      const id25 = 'exam.25_correct';
      if (!await ProgressRepository.instance.isAchievementUnlocked(id25)) {
        await ProgressRepository.instance.unlockAchievement(id25);
        _notifyCaptured(app, l10n, byId(id25)!);
      }
    }
    if (correct >= 30) {
      const id30 = 'exam.30_correct';
      if (!await ProgressRepository.instance.isAchievementUnlocked(id30)) {
        await ProgressRepository.instance.unlockAchievement(id30);
        _notifyCaptured(app, l10n, byId(id30)!);
      }
    }
    if (correct >= total) {
      const idPerfect = 'exam.perfect';
      if (!await ProgressRepository.instance.isAchievementUnlocked(idPerfect)) {
        await ProgressRepository.instance.unlockAchievement(idPerfect);
        _notifyCaptured(app, l10n, byId(idPerfect)!);
      }
    }
    // Fast pass: under 10 minutes
    try {
      final latest = (await ProgressRepository.instance.examResults(limit: 1)).firstOrNull;
      if (latest != null && latest.completed && latest.passed && latest.durationMs <= 10 * 60 * 1000) {
        const idFast = 'exam.fast_pass';
        if (!await ProgressRepository.instance.isAchievementUnlocked(idFast)) {
          await ProgressRepository.instance.unlockAchievement(idFast);
          _notifyCaptured(app, l10n, byId(idFast)!);
        }
      }
      if (latest != null && latest.completed && latest.passed && latest.durationMs <= 5 * 60 * 1000) {
        const idFast5 = 'exam.fast_pass_5min';
        if (!await ProgressRepository.instance.isAchievementUnlocked(idFast5)) {
          await ProgressRepository.instance.unlockAchievement(idFast5);
          _notifyCaptured(app, l10n, byId(idFast5)!);
        }
      }
    } catch (_) {}
    // Pass streak 3
    try {
      final last3 = await ProgressRepository.instance.examResults(limit: 3);
      if (last3.length == 3 && last3.every((e) => e.completed && e.passed)) {
        const idStreak = 'exam.pass_streak3';
        if (!await ProgressRepository.instance.isAchievementUnlocked(idStreak)) {
          await ProgressRepository.instance.unlockAchievement(idStreak);
          _notifyCaptured(app, l10n, byId(idStreak)!);
        }
      }
    } catch (_) {}
    // Pass streak 5, total passes, and perfects count
    try {
      final last5 = await ProgressRepository.instance.examResults(limit: 5);
      if (last5.length == 5 && last5.every((e) => e.completed && e.passed)) {
        const idStreak5 = 'exam.pass_streak5';
        if (!await ProgressRepository.instance.isAchievementUnlocked(idStreak5)) {
          await ProgressRepository.instance.unlockAchievement(idStreak5);
          _notifyCaptured(app, l10n, byId(idStreak5)!);
        }
      }
      final all = await ProgressRepository.instance.examResults(limit: 1000);
      final passed = all.where((e) => e.completed && e.passed).length;
      if (passed >= 10 && !await ProgressRepository.instance.isAchievementUnlocked('exam.pass_10')) {
        await ProgressRepository.instance.unlockAchievement('exam.pass_10');
        _notifyCaptured(app, l10n, byId('exam.pass_10')!);
      }
      final perfects = all.where((e) => e.completed && e.correct >= e.total).length;
      if (perfects >= 3 && !await ProgressRepository.instance.isAchievementUnlocked('exam.perfect_3')) {
        await ProgressRepository.instance.unlockAchievement('exam.perfect_3');
        _notifyCaptured(app, l10n, byId('exam.perfect_3')!);
      }
    } catch (_) {}
    await _checkDailyStreaks(app, l10n);
  }

  // Notify using captured references (no BuildContext after awaits)
  void _notifyCaptured(AppState? app, AppLocalizations l10n, AchievementDef def) {
    final title = localizeName(l10n, def);
    app?.showSnack(l10n.achievement_unlocked(title));
    _unlocked.add(def);
  }

  // (Old) context-based notifier removed in favor of _notifyCaptured

  // Helpers to localize name/desc from ARB keys
  String localizeName(AppLocalizations l10n, AchievementDef def) {
    switch (def.nameKey) {
      case 'ach_learn_first_correct_name':
        return l10n.ach_learn_first_correct_name;
      case 'ach_quiz_first_correct_name':
        return l10n.ach_quiz_first_correct_name;
      case 'ach_exam_pass_name':
        return l10n.ach_exam_pass_name;
      case 'ach_exam_30_name':
        return l10n.ach_exam_30_name;
      case 'ach_practice_10_name':
        return l10n.ach_practice_10_name;
      case 'ach_practice_100_name':
        return l10n.ach_practice_100_name;
      case 'ach_practice_1000_name':
        return l10n.ach_practice_1000_name;
      case 'ach_exam_first_name':
        return l10n.ach_exam_first_name;
      case 'ach_exam_25_name':
        return l10n.ach_exam_25_name;
      case 'ach_exam_perfect_name':
        return l10n.ach_exam_perfect_name;
      case 'ach_exam_streak3_name':
        return l10n.ach_exam_streak3_name;
      case 'ach_exam_fast_name':
        return l10n.ach_exam_fast_name;
      case 'ach_exam_fast5_name':
        return l10n.ach_exam_fast5_name;
      case 'ach_exam_pass10_name':
        return l10n.ach_exam_pass10_name;
      case 'ach_exam_perfect3_name':
        return l10n.ach_exam_perfect3_name;
      case 'ach_exam_streak5_name':
        return l10n.ach_exam_streak5_name;
      // New keys: guard with fallbacks until gen_l10n updated
      case 'ach_timer_first_name':
        return l10n.ach_timer_first_name;
      case 'ach_timer_10_name':
        return l10n.ach_timer_10_name;
      case 'ach_timer_20_name':
        return l10n.ach_timer_20_name;
      case 'ach_timer_30_name':
        return l10n.ach_timer_30_name;
      case 'ach_mistakes_review_name':
        return l10n.ach_mistakes_review_name;
      case 'ach_mistakes_clean_name':
        return l10n.ach_mistakes_clean_name;
      case 'ach_topics_first_name':
        return l10n.ach_topics_first_name;
      case 'ach_practice_2500_name':
        return l10n.ach_practice_2500_name;
      case 'ach_practice_5000_name':
        return l10n.ach_practice_5000_name;
      case 'ach_practice_10000_name':
        return l10n.ach_practice_10000_name;
      case 'ach_streak7_name':
        return l10n.ach_streak7_name;
      case 'ach_streak30_name':
        return l10n.ach_streak30_name;
      default:
        return def.id; // Fallback: show id if a new key is missing
    }
  }

  String localizeDescription(AppLocalizations l10n, AchievementDef def) {
    switch (def.descKey) {
      case 'ach_learn_first_correct_desc':
        return l10n.ach_learn_first_correct_desc;
      case 'ach_quiz_first_correct_desc':
        return l10n.ach_quiz_first_correct_desc;
      case 'ach_exam_pass_desc':
        return l10n.ach_exam_pass_desc;
      case 'ach_exam_30_desc':
        return l10n.ach_exam_30_desc;
      case 'ach_practice_10_desc':
        return l10n.ach_practice_10_desc;
      case 'ach_practice_100_desc':
        return l10n.ach_practice_100_desc;
      case 'ach_practice_1000_desc':
        return l10n.ach_practice_1000_desc;
      case 'ach_exam_first_desc':
        return l10n.ach_exam_first_desc;
      case 'ach_exam_25_desc':
        return l10n.ach_exam_25_desc;
      case 'ach_exam_perfect_desc':
        return l10n.ach_exam_perfect_desc;
      case 'ach_exam_streak3_desc':
        return l10n.ach_exam_streak3_desc;
      case 'ach_exam_fast_desc':
        return l10n.ach_exam_fast_desc;
      case 'ach_exam_fast5_desc':
        return l10n.ach_exam_fast5_desc;
      case 'ach_exam_pass10_desc':
        return l10n.ach_exam_pass10_desc;
      case 'ach_exam_perfect3_desc':
        return l10n.ach_exam_perfect3_desc;
      case 'ach_exam_streak5_desc':
        return l10n.ach_exam_streak5_desc;
      // New keys: guard with fallbacks until gen_l10n updated
      case 'ach_timer_first_desc':
        return l10n.ach_timer_first_desc;
      case 'ach_timer_10_desc':
        return l10n.ach_timer_10_desc;
      case 'ach_timer_20_desc':
        return l10n.ach_timer_20_desc;
      case 'ach_timer_30_desc':
        return l10n.ach_timer_30_desc;
      case 'ach_mistakes_review_desc':
        return l10n.ach_mistakes_review_desc;
      case 'ach_mistakes_clean_desc':
        return l10n.ach_mistakes_clean_desc;
      case 'ach_topics_first_desc':
        return l10n.ach_topics_first_desc;
      case 'ach_practice_2500_desc':
        return l10n.ach_practice_2500_desc;
      case 'ach_practice_5000_desc':
        return l10n.ach_practice_5000_desc;
      case 'ach_practice_10000_desc':
        return l10n.ach_practice_10000_desc;
      case 'ach_streak7_desc':
        return l10n.ach_streak7_desc;
      case 'ach_streak30_desc':
        return l10n.ach_streak30_desc;
      default:
        return '';
    }
  }

  // Timer mode completion handler
  Future<void> onTimerCompleted(BuildContext context, {required int correct, required int answered}) async {
    final app = App.of(context);
    final l10n = AppLocalizations.of(context);
    await ProgressRepository.instance.init();
    const firstId = 'timer.first';
    if (!await ProgressRepository.instance.isAchievementUnlocked(firstId)) {
      await ProgressRepository.instance.unlockAchievement(firstId);
      _notifyCaptured(app, l10n, byId(firstId)!);
    }
    const thresholds = <int, String>{
      10: 'timer.10_correct',
      20: 'timer.20_correct',
      30: 'timer.30_correct',
    };
    for (final e in thresholds.entries) {
      if (correct >= e.key && !await ProgressRepository.instance.isAchievementUnlocked(e.value)) {
        await ProgressRepository.instance.unlockAchievement(e.value);
        _notifyCaptured(app, l10n, byId(e.value)!);
      }
    }
    await _checkDailyStreaks(app, l10n);
  }

  // Mistakes mode result handler
  Future<void> onMistakesReviewed(BuildContext context, {required int wrongCount}) async {
    final app = App.of(context);
    final l10n = AppLocalizations.of(context);
    await ProgressRepository.instance.init();
    const reviewedId = 'mistakes.reviewed';
    if (!await ProgressRepository.instance.isAchievementUnlocked(reviewedId)) {
      await ProgressRepository.instance.unlockAchievement(reviewedId);
      _notifyCaptured(app, l10n, byId(reviewedId)!);
    }
    if (wrongCount == 0) {
      const cleanId = 'mistakes.clean';
      if (!await ProgressRepository.instance.isAchievementUnlocked(cleanId)) {
        await ProgressRepository.instance.unlockAchievement(cleanId);
        _notifyCaptured(app, l10n, byId(cleanId)!);
      }
    }
    await _checkDailyStreaks(app, l10n);
  }

  // Compute 7-day and 30-day activity streaks (any attempts on each consecutive day)
  Future<void> _checkDailyStreaks(AppState? app, AppLocalizations l10n) async {
    try {
      final stats = await ProgressRepository.instance.dailyAccuracy(days: 60, includePractice: true, includeExam: true);
      if (stats.isEmpty) return;
      String dayKey(DateTime d) => DateTime(d.year, d.month, d.day).toIso8601String();
      final set = <String>{for (final s in stats) dayKey(s.date)};
      bool hasConsecutive(int n) {
        final today = DateTime.now();
        // Check streak ending today going backwards
        for (int start = 0; start <= 60 - n; start++) {
          bool ok = true;
          for (int i = 0; i < n; i++) {
            final d = DateTime(today.year, today.month, today.day).subtract(Duration(days: start + i));
            if (!set.contains(dayKey(d))) {
              ok = false;
              break;
            }
          }
          if (ok) return true;
        }
        return false;
      }
      if (hasConsecutive(7) && !await ProgressRepository.instance.isAchievementUnlocked('streak.7_days')) {
        await ProgressRepository.instance.unlockAchievement('streak.7_days');
        _notifyCaptured(app, l10n, byId('streak.7_days')!);
      }
      if (hasConsecutive(30) && !await ProgressRepository.instance.isAchievementUnlocked('streak.30_days')) {
        await ProgressRepository.instance.unlockAchievement('streak.30_days');
        _notifyCaptured(app, l10n, byId('streak.30_days')!);
      }
    } catch (_) {}
  }

}
