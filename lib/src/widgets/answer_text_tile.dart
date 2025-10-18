import 'package:flutter/material.dart';
import '../theme/app_colors.dart';

class AnswerTextTile extends StatelessWidget {
  final String text;
  final bool revealed;
  final bool isSelected;
  final bool isCorrect;
  final VoidCallback onTap;

  const AnswerTextTile({
    super.key,
    required this.text,
    required this.revealed,
    required this.isSelected,
    required this.isCorrect,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    Color boxColor = theme.cardColor;
    IconData? icon;
    Color iconColor = theme.colorScheme.onPrimary;

    if (revealed) {
      if (isSelected && isCorrect) {
        boxColor = isDark ? AppColors.correctDark : AppColors.correct;
        icon = Icons.check_circle;
        iconColor = theme.colorScheme.onPrimary;
      } else if (isSelected && !isCorrect) {
        boxColor = isDark ? AppColors.wrongDark : AppColors.wrong;
        icon = Icons.cancel;
        iconColor = theme.colorScheme.onPrimary;
      } else if (isCorrect) {
        boxColor = isDark ? AppColors.correctDark.withAlpha(128) : AppColors.correctLight;
        icon = Icons.check_circle;
        iconColor = theme.colorScheme.onPrimary;
      }
    } else if (isSelected) {
      // Subtle selection before reveal
      boxColor = theme.colorScheme.primary.withOpacity(0.12);
      icon = Icons.check_circle_outline;
      iconColor = theme.colorScheme.primary;
    }

    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 6),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          borderRadius: BorderRadius.circular(16),
          onTap: onTap,
          child: AnimatedContainer(
            duration: const Duration(milliseconds: 160),
            decoration: BoxDecoration(
              color: boxColor,
              borderRadius: BorderRadius.circular(16),
            ),
            padding: const EdgeInsets.symmetric(vertical: 14, horizontal: 16),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Flexible(child: Text(text, style: theme.textTheme.bodyMedium)),
                if (icon != null) Icon(icon, color: iconColor, size: 24),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
