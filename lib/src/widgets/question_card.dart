import 'package:flutter/material.dart';

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
              style: theme.textTheme.titleLarge?.copyWith(fontWeight: FontWeight.bold),
            ),
            if (image != null && image!.isNotEmpty) ...[
              const SizedBox(height: 12),
              ClipRRect(
                borderRadius: BorderRadius.circular(10),
                child: Container(
                  color: theme.colorScheme.surfaceVariant,
                  padding: const EdgeInsets.all(8),
                  child: Center(
                    child: Image.asset(
                      image!,
                      fit: BoxFit.contain,
                      filterQuality: FilterQuality.medium,
                      errorBuilder: (_, __, ___) => Container(
                        height: 140,
                        alignment: Alignment.center,
                        child: const Text('Bild nicht gefunden'),
                      ),
                    ),
                  ),
                ),
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
