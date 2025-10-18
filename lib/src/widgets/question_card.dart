import 'package:flutter/material.dart';
import 'dart:async';
import 'package:citizenship_quiz_app/src/screens/image_viewer_screen.dart';

class QuestionCard extends StatelessWidget {
  final String text;
  final int index;
  final String? image; // optional context image
  final String? subtitle;

  const QuestionCard({
    super.key,
    required this.text,
    required this.index,
    this.image,
    this.subtitle,
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
            if (image != null && image!.isNotEmpty) ...[
              const SizedBox(height: 12),
              _TappableProportionalAssetImage(
                imagePath: image!,
                backgroundColor: theme.colorScheme.surfaceVariant,
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
        child: LayoutBuilder(
          builder: (context, constraints) {
            return FutureBuilder<ImageInfo>(
              future: _getImageInfo(imagePath),
              builder: (context, snapshot) {
                if (snapshot.hasError) {
                  return SizedBox(
                    height: 140,
                    child: const Center(child: Text('Bild nicht gefunden')),
                  );
                }
                if (!snapshot.hasData) {
                  return const SizedBox(height: 140, child: Center(child: CircularProgressIndicator(strokeWidth: 2)));
                }
                final info = snapshot.data!;
                final aspect = info.image.width / info.image.height;
                // Compute target size to fit within maxHeight and available width
                final availableWidth = constraints.maxWidth;
                double targetWidth = availableWidth;
                double targetHeight = targetWidth / aspect;
                if (targetHeight > maxHeight) {
                  targetHeight = maxHeight;
                  targetWidth = targetHeight * aspect;
                }
                final innerRadius = borderRadius > 2 ? borderRadius - 2 : borderRadius;

                return SizedBox(
                  height: targetHeight,
                  child: Center(
                    child: ClipRRect(
                      borderRadius: BorderRadius.circular(innerRadius),
                      child: Image.asset(
                        imagePath,
                        width: targetWidth,
                        height: targetHeight,
                        fit: BoxFit.fill, // already computed proportional size
                        filterQuality: FilterQuality.medium,
                        errorBuilder: (_, __, ___) => SizedBox(
                          height: 140,
                          child: const Center(child: Text('Bild nicht gefunden')),
                        ),
                      ),
                    ),
                  ),
                );
              },
            );
          },
        ),
      ),
    );
  }

  Future<ImageInfo> _getImageInfo(String assetPath) async {
    final imageProvider = AssetImage(assetPath);
    final completer = Completer<ImageInfo>();
    final stream = imageProvider.resolve(const ImageConfiguration());
    late final ImageStreamListener listener;
    listener = ImageStreamListener((ImageInfo info, bool _) {
      completer.complete(info);
    }, onError: (error, stackTrace) {
      completer.completeError(error, stackTrace);
    });
    stream.addListener(listener);
    try {
      final info = await completer.future;
      return info;
    } finally {
      stream.removeListener(listener);
    }
  }
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
