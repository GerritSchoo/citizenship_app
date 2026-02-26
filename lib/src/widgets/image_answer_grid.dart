import 'package:flutter/material.dart';
import '../theme/app_colors.dart';
import '../theme/app_theme.dart';

class ImageAnswerGrid extends StatelessWidget {
  final List<String> images;    // must match answers length
  final int correctIndex;
  final int? selectedIndex;
  final bool revealed;          // show correct/wrong cues
  final ValueChanged<int> onTap;
  final bool disableInkSplash;
  // (Deprecated) original German captions for answers and toggle (ignored)
  final List<String>? originalDeAnswers;
  final bool showOriginalDe;

  const ImageAnswerGrid({
    super.key,
    required this.images,
    required this.correctIndex,
    required this.selectedIndex,
    required this.revealed,
    required this.onTap,
    this.disableInkSplash = false,
    this.originalDeAnswers,
    this.showOriginalDe = false,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
  // final isDark = theme.brightness == Brightness.dark; // not needed with AppColors

    return GridView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      itemCount: images.length,
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 2, mainAxisSpacing: 12, crossAxisSpacing: 12, childAspectRatio: 1,
      ),
      itemBuilder: (ctx, i) {
        final isSelected = selectedIndex == i;
        final isCorrect = i == correctIndex;

  Color border = Colors.transparent;
  Color? overlay;
        IconData? icon;
        Color iconColor = theme.colorScheme.primary;

        if (revealed) {
          if (isCorrect && isSelected) {
            border = AppColors.correct;
            overlay = AppColors.correct.withValues(alpha: 0.45);
            icon = Icons.check_circle; // round check icon
            iconColor = AppColors.correct;
          } else if (!isCorrect && isSelected) {
            border = AppColors.wrong;
            overlay = AppColors.wrong.withValues(alpha: 0.45);
            icon = Icons.cancel; // round cancel icon
            iconColor = AppColors.wrong;
          } else if (isCorrect && !isSelected) {
            // Show lighter green and the same round check icon for consistency
            border = AppColors.correct;
            overlay = AppColors.correctLight.withValues(alpha: 0.55);
            icon = Icons.check_circle; // round check icon
            iconColor = AppColors.correct;
          }
        } else if (isSelected) {
          // Pre-selection subtle highlight
          border = theme.colorScheme.primary;
          overlay = theme.colorScheme.primary.withValues(alpha: 0.12);
          icon = Icons.check_circle_outline;
          iconColor = theme.colorScheme.primary;
        }

  final shape = RoundedRectangleBorder(
    borderRadius: BorderRadius.circular(AppTheme.radiusMedium),
    side: BorderSide(color: border, width: border == Colors.transparent ? 0.8 : 2),
  );
        return Material(
          color: Colors.transparent,
          shape: shape,
          // Do not clip children so image edges stay intact (not rounded)
          clipBehavior: Clip.none,
          child: InkWell(
            customBorder: shape,
            splashColor: disableInkSplash ? Colors.transparent : null,
            highlightColor: disableInkSplash ? Colors.transparent : null,
            overlayColor: disableInkSplash ? const WidgetStatePropertyAll(Colors.transparent) : null,
            splashFactory: disableInkSplash ? NoSplash.splashFactory : null,
            onTap: () => onTap(i),
            child: Stack(fit: StackFit.expand, children: [
              Container(
                decoration: BoxDecoration(
                  color: theme.colorScheme.surfaceContainerHighest,
                  borderRadius: BorderRadius.circular(AppTheme.radiusMedium),
                ),
                padding: const EdgeInsets.all(8),
                child: Center(
                  child: Image.asset(
                    images[i],
                    gaplessPlayback: true,
                    fit: BoxFit.contain,
                    filterQuality: FilterQuality.medium,
                    errorBuilder: (context, error, stackTrace) => Container(
                      alignment: Alignment.center,
                      child: const Text('Bild nicht gefunden'),
                    ),
                  ),
                ),
              ),
              if (overlay != null)
                // Keep rounded highlight while preserving image edges
                ClipRRect(
                  borderRadius: BorderRadius.circular(AppTheme.radiusMedium),
                  child: Container(color: overlay),
                ),
              // No original captions for image answers; show only translated UI per requirement
              if (icon != null)
                Positioned(right: 8, top: 8, child: Icon(icon, color: iconColor, size: 24)),
            ]),
          ),
        );
      },
    );
  }
}
