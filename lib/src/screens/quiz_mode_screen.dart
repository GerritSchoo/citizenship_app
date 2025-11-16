import 'package:flutter/material.dart';
import '../../l10n/app_localizations.dart';
import '../theme/app_theme.dart';
import '../core/quiz_mode.dart';
import 'quiz_screen.dart';
import 'quiz_topics_screen.dart';

class QuizModeScreen extends StatefulWidget {
  const QuizModeScreen({super.key});

  @override
  State<QuizModeScreen> createState() => _QuizModeScreenState();
}

class _QuizModeScreenState extends State<QuizModeScreen> {
  // No data loading needed; screen shows static mode options with localized descriptions.

  void _startMistakes() {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => QuizScreen(config: QuizConfig.mistakes(count: 20)),
      ),
    );
  }

  void _startTimer() {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => QuizScreen(config: QuizConfig.timer(seconds: 120)),
      ),
    );
  }

  void _startTopics() {
    Navigator.push(
      context,
      MaterialPageRoute(builder: (_) => const QuizTopicsScreen()),
    );
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    return Scaffold(
      appBar: AppBar(title: Text(l10n.quiz_modes_title)),
      body: SafeArea(
        child: ListView(
          padding: const EdgeInsets.all(16),
          children: [
            _ModeCard(
              icon: Icons.rule_folder_outlined,
              color: Theme.of(context).colorScheme.error,
              title: l10n.quiz_mode_mistakes,
              subtitle: '',
              description: l10n.quiz_mode_mistakes_desc,
              onTap: _startMistakes,
            ),
            const SizedBox(height: 12),
            _ModeCard(
              icon: Icons.category_outlined,
              color: Theme.of(context).colorScheme.primary,
              title: l10n.quiz_mode_topics,
              subtitle: '',
              description: l10n.quiz_mode_topics_desc,
              onTap: _startTopics,
            ),
            const SizedBox(height: 12),
            _ModeCard(
              icon: Icons.timer_outlined,
              color: Theme.of(context).colorScheme.tertiary,
              title: l10n.quiz_mode_timer,
              subtitle: '',
              description: l10n.quiz_mode_timer_desc,
              onTap: _startTimer,
            ),
          ],
        ),
      ),
    );
  }
}

class _ModeCard extends StatelessWidget {
  final IconData icon;
  final Color color;
  final String title;
  final String subtitle;
  final String description;
  final VoidCallback onTap;
  const _ModeCard({required this.icon, required this.color, required this.title, required this.subtitle, required this.description, required this.onTap});

  @override
  Widget build(BuildContext context) {
    final bg = Theme.of(context).brightness == Brightness.dark
        ? Theme.of(context).colorScheme.surfaceContainerHighest.withValues(alpha: 0.4)
        : Colors.white;
    return Material(
      color: bg,
      elevation: 2,
      borderRadius: BorderRadius.circular(AppTheme.radiusMedium),
      clipBehavior: Clip.antiAlias,
      child: InkWell(
        splashColor: Colors.transparent,
        highlightColor: Colors.transparent,
        hoverColor: Colors.transparent,
        focusColor: Colors.transparent,
        splashFactory: NoSplash.splashFactory,
        onTap: onTap,
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Row(
            children: [
              Container(
                height: 44,
                width: 44,
                decoration: BoxDecoration(
                  color: color.withValues(alpha: 0.12),
                  borderRadius: BorderRadius.circular(AppTheme.radiusSmall),
                ),
                child: Icon(icon, color: color, size: 26),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(title, style: Theme.of(context).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.w700)),
                    const SizedBox(height: 4),
                    // Description line: match style with Topics screen subtitles
                    Text(description, style: Theme.of(context).textTheme.bodySmall),
                    if (subtitle.isNotEmpty) ...[
                      const SizedBox(height: 2),
                      Text(subtitle, style: Theme.of(context).textTheme.bodySmall),
                    ],
                  ],
                ),
              ),
              const Icon(Icons.chevron_right),
            ],
          ),
        ),
      ),
    );
  }
}
