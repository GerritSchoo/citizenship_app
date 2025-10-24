import 'package:flutter/material.dart';
import '../theme/app_colors.dart';
import '../theme/app_theme.dart';

class AnswerTextTile extends StatelessWidget {
  final String text;
  final bool revealed;
  final bool isSelected;
  final bool isCorrect;
  final VoidCallback onTap;
  final Duration animationDuration;
  final bool disableInkSplash;
  // Optional original German text to render subtly under the main text
  final String? originalDe;

  const AnswerTextTile({
    super.key,
    required this.text,
    required this.revealed,
    required this.isSelected,
    required this.isCorrect,
    required this.onTap,
    this.animationDuration = const Duration(milliseconds: 160),
    this.disableInkSplash = false,
    this.originalDe,
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
      boxColor = theme.colorScheme.primary.withValues(alpha: 0.12);
      icon = Icons.check_circle_outline;
      iconColor = theme.colorScheme.primary;
    }

    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 6),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          borderRadius: BorderRadius.circular(AppTheme.radiusMedium),
          splashColor: disableInkSplash ? Colors.transparent : null,
          highlightColor: disableInkSplash ? Colors.transparent : null,
          overlayColor: disableInkSplash ? const WidgetStatePropertyAll(Colors.transparent) : null,
          splashFactory: disableInkSplash ? NoSplash.splashFactory : null,
          onTap: onTap,
          child: AnimatedContainer(
            duration: animationDuration,
            decoration: BoxDecoration(
              color: boxColor,
              borderRadius: BorderRadius.circular(AppTheme.radiusMedium),
            ),
            padding: const EdgeInsets.symmetric(vertical: 14, horizontal: 16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Flexible(child: Text(text, style: theme.textTheme.bodyMedium)),
                    if (icon != null) Icon(icon, color: iconColor, size: 24),
                  ],
                ),
                if (originalDe != null && originalDe!.isNotEmpty)
                  Padding(
                    padding: const EdgeInsets.only(top: 4),
                    child: Text(
                      originalDe!,
                      style: theme.textTheme.bodySmall?.copyWith(
                        color: theme.colorScheme.onSurface.withValues(alpha: 0.6),
                        fontStyle: FontStyle.italic,
                      ),
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
