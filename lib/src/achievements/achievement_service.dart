import 'dart:async';
import 'package:flutter/material.dart';
import '../analytics/progress_repository.dart';
import '../../app.dart';
import '../../l10n/app_localizations.dart';
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

  Future<void> onPracticeAnswered(BuildContext context, {required bool inLearn, required bool isCorrect}) async {
    if (!isCorrect) return;
    // Capture dependencies before async gaps to avoid using BuildContext afterwards
    final app = App.of(context);
    final l10n = AppLocalizations.of(context);
    await ProgressRepository.instance.init();
    final id = inLearn ? 'learn.first_correct' : 'quiz.first_correct';
    if (await ProgressRepository.instance.isAchievementUnlocked(id)) return;
    await ProgressRepository.instance.unlockAchievement(id);
    _notifyCaptured(app, l10n, byId(id)!);
    // Check cumulative practice thresholds
    try {
      final stats = await ProgressRepository.instance.overallStats(includePractice: true, includeExam: false);
      final milestones = <int, String>{
        10: 'practice.10_correct',
        100: 'practice.100_correct',
        1000: 'practice.1000_correct',
      };
      for (final entry in milestones.entries) {
        if (stats.correct >= entry.key && !(await ProgressRepository.instance.isAchievementUnlocked(entry.value))) {
          await ProgressRepository.instance.unlockAchievement(entry.value);
          _notifyCaptured(app, l10n, byId(entry.value)!);
        }
      }
    } catch (_) {}
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
      default:
        return '';
    }
  }
}
