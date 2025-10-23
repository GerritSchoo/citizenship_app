import 'package:flutter/material.dart';

enum AchievementCategory { learn, quiz, exam }

enum AchievementDifficulty { easy, medium, hard }

@immutable
class AchievementDef {
  final String id; // stable id for persistence
  final AchievementCategory category;
  final AchievementDifficulty difficulty;
  final String nameKey; // l10n key for title
  final String descKey; // l10n key for description
  final IconData icon; // unique icon for this achievement

  const AchievementDef({
    required this.id,
    required this.category,
    required this.difficulty,
    required this.nameKey,
    required this.descKey,
    required this.icon,
  });
}

@immutable
class AchievementStatus {
  final AchievementDef def;
  final bool unlocked;
  const AchievementStatus({required this.def, required this.unlocked});
}
