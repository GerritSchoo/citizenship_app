import 'package:flutter/material.dart';
import '../theme/app_colors.dart';

class ImageAnswerGrid extends StatelessWidget {
  final List<String> images;    // must match answers length
  final int correctIndex;
  final int? selectedIndex;
  final bool revealed;          // show correct/wrong cues
  final ValueChanged<int> onTap;

  const ImageAnswerGrid({
    super.key,
    required this.images,
    required this.correctIndex,
    required this.selectedIndex,
    required this.revealed,
    required this.onTap,
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
            overlay = AppColors.correct.withOpacity(0.45);
            icon = Icons.check_circle; // round check icon
            iconColor = AppColors.correct;
          } else if (!isCorrect && isSelected) {
            border = AppColors.wrong;
            overlay = AppColors.wrong.withOpacity(0.45);
            icon = Icons.cancel; // round cancel icon
            iconColor = AppColors.wrong;
          } else if (isCorrect && !isSelected) {
            // Show lighter green and the same round check icon for consistency
            border = AppColors.correct;
            overlay = AppColors.correctLight.withOpacity(0.55);
            icon = Icons.check_circle; // round check icon
            iconColor = AppColors.correct;
          }
        } else if (isSelected) {
          // Pre-selection subtle highlight
          border = theme.colorScheme.primary;
          overlay = theme.colorScheme.primary.withOpacity(0.12);
          icon = Icons.check_circle_outline;
          iconColor = theme.colorScheme.primary;
        }

  final shape = RoundedRectangleBorder(borderRadius: BorderRadius.circular(12), side: BorderSide(color: border, width: border == Colors.transparent ? 0.8 : 2));
        return Material(
          color: Colors.transparent,
          shape: shape,
          // Do not clip children so image edges stay intact (not rounded)
          clipBehavior: Clip.none,
          child: InkWell(
            customBorder: shape,
            onTap: () => onTap(i),
            child: Stack(fit: StackFit.expand, children: [
              Container(
                decoration: BoxDecoration(
                  color: theme.colorScheme.surfaceVariant,
                  borderRadius: BorderRadius.circular(12),
                ),
                padding: const EdgeInsets.all(8),
                child: Center(
                  child: Image.asset(
                    images[i],
                    gaplessPlayback: true,
                    fit: BoxFit.contain,
                    filterQuality: FilterQuality.medium,
                    errorBuilder: (_, __, ___) => Container(
                      alignment: Alignment.center,
                      child: const Text('Bild nicht gefunden'),
                    ),
                  ),
                ),
              ),
              if (overlay != null)
                // Keep rounded highlight while preserving image edges
                ClipRRect(
                  borderRadius: BorderRadius.circular(12),
                  child: Container(color: overlay),
                ),
              if (icon != null)
                Positioned(right: 8, top: 8, child: Icon(icon, color: iconColor, size: 24)),
            ]),
          ),
        );
      },
    );
  }
}
