import 'package:flutter/material.dart';

import '../theme/app_theme.dart';
import '../../l10n/app_localizations.dart';

/// Grade categories matching the mock exam result screen semantics.
enum ExamGradeCategory {
  sehrGut,
  gut,
  befriedigend,
  ausreichend,
  mangelhaft,
  ungenuegend,
}

/// Computes the grade category based on number of correct answers.
/// Thresholds mirror the mock exam result screen.
ExamGradeCategory gradeForCorrect(int correct) {
  if (correct >= 31) return ExamGradeCategory.sehrGut;
  if (correct >= 27) return ExamGradeCategory.gut;
  if (correct >= 23) return ExamGradeCategory.befriedigend;
  if (correct >= 17) return ExamGradeCategory.ausreichend;
  if (correct >= 10) return ExamGradeCategory.mangelhaft;
  return ExamGradeCategory.ungenuegend;
}

String labelForCategory(BuildContext context, ExamGradeCategory c) {
  final l10n = AppLocalizations.of(context);
  switch (c) {
    case ExamGradeCategory.sehrGut:
      return l10n.grade_sehr_gut;
    case ExamGradeCategory.gut:
      return l10n.grade_gut;
    case ExamGradeCategory.befriedigend:
      return l10n.grade_befriedigend;
    case ExamGradeCategory.ausreichend:
      return l10n.grade_ausreichend;
    case ExamGradeCategory.mangelhaft:
      return l10n.grade_mangelhaft;
    case ExamGradeCategory.ungenuegend:
      return l10n.grade_ungenuegend;
  }
}

IconData iconForCategory(ExamGradeCategory c) {
  switch (c) {
    case ExamGradeCategory.sehrGut:
    case ExamGradeCategory.gut:
      return Icons.check_circle;
    case ExamGradeCategory.befriedigend:
    case ExamGradeCategory.ausreichend:
      return Icons.warning;
    case ExamGradeCategory.mangelhaft:
    case ExamGradeCategory.ungenuegend:
      return Icons.cancel;
  }
}

Color colorForCategory(BuildContext context, ExamGradeCategory c) {
  final gradeColors = Theme.of(context).extension<GradeColors>()!;
  switch (c) {
    case ExamGradeCategory.sehrGut:
      return gradeColors.sehrGut;
    case ExamGradeCategory.gut:
      return gradeColors.gut;
    case ExamGradeCategory.befriedigend:
      return gradeColors.befriedigend;
    case ExamGradeCategory.ausreichend:
      return gradeColors.ausreichend;
    case ExamGradeCategory.mangelhaft:
      return gradeColors.mangelhaft;
    case ExamGradeCategory.ungenuegend:
      return gradeColors.ungenuegend;
  }
}

/// Simple icon that visualizes the exam result category using the same
/// cues as on the result screen.
class ExamResultIcon extends StatelessWidget {
  final int correct;
  final double size;
  const ExamResultIcon({super.key, required this.correct, this.size = 24});

  @override
  Widget build(BuildContext context) {
    final cat = gradeForCorrect(correct);
    final color = colorForCategory(context, cat);
    final icon = iconForCategory(cat);
    return Icon(icon, color: color, size: size);
  }
}
