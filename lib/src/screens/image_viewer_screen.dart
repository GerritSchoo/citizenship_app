import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../../l10n/app_localizations.dart';

class ImageViewerScreen extends StatelessWidget {
  final String imagePath;
  final String? heroTag;

  const ImageViewerScreen({super.key, required this.imagePath, this.heroTag});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;
    final overlay = isDark ? SystemUiOverlayStyle.light : SystemUiOverlayStyle.dark;

    final imageWidget = Image.asset(
      imagePath,
      gaplessPlayback: true,
      errorBuilder: (context, error, stackTrace) => Center(
        child: Text(AppLocalizations.of(context).error_image_not_found, style: theme.textTheme.bodyMedium),
      ),
      filterQuality: FilterQuality.high,
    );

    final heroWrapped = heroTag != null ? Hero(tag: heroTag!, child: imageWidget) : imageWidget;

    return AnnotatedRegion<SystemUiOverlayStyle>(
      value: overlay,
      child: Scaffold(
        backgroundColor: theme.scaffoldBackgroundColor,
        appBar: AppBar(
          backgroundColor: theme.colorScheme.surface,
          foregroundColor: theme.colorScheme.onSurface,
          elevation: 0,
          leading: IconButton(
            icon: const Icon(Icons.arrow_back),
            onPressed: () => Navigator.of(context).maybePop(),
            tooltip: AppLocalizations.of(context).back,
          ),
        ),
        body: SafeArea(
          child: Padding(
            padding: const EdgeInsets.all(12),
            child: Center(
              // Center the image and contain it within the available space.
              child: InteractiveViewer(
                minScale: 0.5,
                maxScale: 5.0,
                child: LayoutBuilder(
                  builder: (context, constraints) {
                    return SizedBox(
                      width: constraints.maxWidth,
                      height: constraints.maxHeight,
                      child: FittedBox(
                        fit: BoxFit.contain,
                        alignment: Alignment.center,
                        child: heroWrapped,
                      ),
                    );
                  },
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
