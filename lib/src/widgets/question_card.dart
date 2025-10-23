import 'package:flutter/material.dart';
import 'package:citizenship_quiz_app/src/screens/image_viewer_screen.dart';

class QuestionCard extends StatelessWidget {
  final String text;
  final int index;
  final String? image; // optional context image
  final String? subtitle;
  // Optional original German question text and toggle
  final String? originalDeText;
  final bool showOriginalDe;

  const QuestionCard({
    super.key,
    required this.text,
    required this.index,
    this.image,
    this.subtitle,
    this.originalDeText,
    this.showOriginalDe = false,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              text,
              style: theme.textTheme.titleMedium?.copyWith(fontWeight: FontWeight.w700),
            ),
            if (showOriginalDe && originalDeText != null && originalDeText!.isNotEmpty) ...[
              const SizedBox(height: 6),
              Text(
                originalDeText!,
                style: theme.textTheme.bodySmall?.copyWith(
                  color: theme.colorScheme.onSurface.withValues(alpha: 0.6),
                  fontStyle: FontStyle.italic,
                ),
              ),
            ],
            if (image != null && image!.isNotEmpty) ...[
              const SizedBox(height: 12),
              _TappableProportionalAssetImage(
                imagePath: image!,
                backgroundColor: theme.colorScheme.surfaceContainerHighest,
                borderRadius: 10,
                padding: const EdgeInsets.all(8),
                maxHeightFraction: 0.35,
                heroTag: 'q-img-$index-${image!}',
              ),
            ],
            if (subtitle != null && subtitle!.isNotEmpty) ...[
              const SizedBox(height: 8),
              Text(subtitle!, style: theme.textTheme.bodyMedium),
            ],
          ],
        ),
      ),
    );
  }
}

class _ProportionalAssetImage extends StatelessWidget {
  final String imagePath;
  final Color backgroundColor;
  final double borderRadius;
  final EdgeInsetsGeometry padding;
  final double maxHeightFraction; // e.g., 0.35 of screen height

  const _ProportionalAssetImage({
    required this.imagePath,
    required this.backgroundColor,
    required this.borderRadius,
    required this.padding,
    required this.maxHeightFraction,
  });

  @override
  Widget build(BuildContext context) {
    final maxHeight = MediaQuery.of(context).size.height * maxHeightFraction;
    return ClipRRect(
      borderRadius: BorderRadius.circular(borderRadius),
      child: Container(
        color: backgroundColor,
        padding: padding,
        child: SizedBox(
          height: maxHeight,
          width: double.infinity,
          child: Center(
            child: FittedBox(
              fit: BoxFit.contain,
              alignment: Alignment.center,
              child: ClipRRect(
                borderRadius: BorderRadius.circular(borderRadius > 2 ? borderRadius - 2 : borderRadius),
                child: LayoutBuilder(builder: (context, constraints) {
                  final targetW = constraints.maxWidth.isFinite ? constraints.maxWidth.toInt() : null;
                  final targetH = maxHeight.toInt();
                  return Image.asset(
                    imagePath,
                    cacheWidth: targetW,
                    cacheHeight: targetH,
                    filterQuality: FilterQuality.medium,
                    gaplessPlayback: true,
                    errorBuilder: (_, __, ___) => const SizedBox(
                      height: 140,
                      child: Center(child: Text('Bild nicht gefunden')),
                    ),
                  );
                }),
              ),
            ),
          ),
        ),
      ),
    );
  }

  // resolution handled by AssetImageInfoCache
}

class _TappableProportionalAssetImage extends StatelessWidget {
  final String imagePath;
  final Color backgroundColor;
  final double borderRadius;
  final EdgeInsetsGeometry padding;
  final double maxHeightFraction;
  final String heroTag;

  const _TappableProportionalAssetImage({
    required this.imagePath,
    required this.backgroundColor,
    required this.borderRadius,
    required this.padding,
    required this.maxHeightFraction,
    required this.heroTag,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () {
        Navigator.of(context).push(
          PageRouteBuilder(
            pageBuilder: (_, __, ___) => ImageViewerScreen(imagePath: imagePath, heroTag: heroTag),
            transitionsBuilder: (context, animation, secondaryAnimation, child) {
              return FadeTransition(opacity: animation, child: child);
            },
          ),
        );
      },
      child: Hero(
        tag: heroTag,
        placeholderBuilder: (context, size, child) => child,
        transitionOnUserGestures: true,
        // Keep rounded context image in card
        child: _ProportionalAssetImage(
          imagePath: imagePath,
          backgroundColor: backgroundColor,
          borderRadius: borderRadius,
          padding: padding,
          maxHeightFraction: maxHeightFraction,
        ),
      ),
    );
  }
}
