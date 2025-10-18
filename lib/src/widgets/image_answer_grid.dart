import 'package:flutter/material.dart';
// Using theme-derived colors for overlays; no direct AppColors dependency

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
    final isDark = theme.brightness == Brightness.dark;

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
          if (isCorrect) {
            border = Colors.green.shade700;
            overlay = (isDark ? Colors.green.shade200 : Colors.green).withOpacity(0.12);
            icon = Icons.check_circle;
            iconColor = Colors.green.shade700;
          } else if (isSelected) {
            border = Colors.red.shade700;
            overlay = (isDark ? Colors.red.shade200 : Colors.red).withOpacity(0.12);
            icon = Icons.cancel;
            iconColor = Colors.red.shade700;
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
          clipBehavior: Clip.antiAlias,
          child: InkWell(
            customBorder: shape,
            onTap: () => onTap(i),
            child: Stack(fit: StackFit.expand, children: [
              Container(
                color: theme.colorScheme.surfaceVariant,
                padding: const EdgeInsets.all(8),
                child: Center(
                  child: Image.asset(
                    images[i],
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
                Container(color: overlay),
              if (icon != null)
                Positioned(right: 8, top: 8, child: Icon(icon, color: iconColor, size: 24)),
            ]),
          ),
        );
      },
    );
  }
}
