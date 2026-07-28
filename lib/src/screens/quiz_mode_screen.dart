import 'package:flutter/material.dart';
import '../../l10n/app_localizations.dart';
import '../theme/app_theme.dart';
import '../core/quiz_mode.dart';
import '../core/prefs.dart';
import '../payments/purchase_service.dart';
import 'paywall_screen.dart';
import 'quiz_screen.dart';
import 'quiz_topics_screen.dart';
import 'swipe_quiz_screen.dart';

const int _kQuizFreeLimit = 10;

class QuizModeScreen extends StatefulWidget {
  const QuizModeScreen({super.key});

  @override
  State<QuizModeScreen> createState() => _QuizModeScreenState();
}

class _QuizModeScreenState extends State<QuizModeScreen> {
  bool _isPro = false;
  int _quizTrialCount = 0;

  @override
  void initState() {
    super.initState();
    _isPro = PurchaseService.instance.isPro;
    PurchaseService.instance.isProNotifier.addListener(_onProChanged);
    _loadTrialCount();
  }

  @override
  void dispose() {
    PurchaseService.instance.isProNotifier.removeListener(_onProChanged);
    super.dispose();
  }

  void _onProChanged() {
    if (mounted) setState(() => _isPro = PurchaseService.instance.isPro);
  }

  Future<void> _loadTrialCount() async {
    final count = await AppPrefs.getQuizTrialCount();
    if (mounted) setState(() => _quizTrialCount = count);
  }

  // Checks the limit and increments — for modes that start a quiz immediately.
  Future<void> _checkAndStart(VoidCallback startFn) async {
    if (_isPro) {
      startFn();
      return;
    }
    final count = await AppPrefs.getQuizTrialCount();
    if (count >= _kQuizFreeLimit) {
      if (!mounted) return;
      _showQuizLimitSheet();
      return;
    }
    await AppPrefs.incrementQuizTrialCount();
    if (mounted) setState(() => _quizTrialCount = count + 1);
    startFn();
  }

  // Checks the limit only — for Topics, which navigates to a picker screen.
  // The actual increment happens when a quiz starts inside QuizTopicsScreen.
  Future<void> _checkLimitOnly(Future<void> Function() startFn) async {
    if (_isPro) {
      await startFn();
      return;
    }
    final count = await AppPrefs.getQuizTrialCount();
    if (count >= _kQuizFreeLimit) {
      if (!mounted) return;
      _showQuizLimitSheet();
      return;
    }
    await startFn();
  }

  void _showQuizLimitSheet() {
    final l10n = AppLocalizations.of(context);
    showModalBottomSheet<void>(
      context: context,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(AppTheme.radiusLarge)),
      ),
      builder: (ctx) => SingleChildScrollView(
        padding: EdgeInsets.fromLTRB(24, 24, 24, 32 + MediaQuery.viewInsetsOf(ctx).bottom),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(Icons.lock_outline, size: 48, color: Theme.of(ctx).colorScheme.primary),
            const SizedBox(height: 16),
            Text(
              l10n.premium_quiz_limit_title,
              style: Theme.of(ctx).textTheme.titleLarge?.copyWith(fontWeight: FontWeight.bold),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 8),
            Text(
              l10n.premium_quiz_limit_body(_kQuizFreeLimit),
              style: Theme.of(ctx).textTheme.bodyMedium,
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 24),
            FilledButton(
              onPressed: () {
                Navigator.pop(ctx);
                Navigator.push(context, MaterialPageRoute(builder: (_) => const PaywallScreen()));
              },
              style: FilledButton.styleFrom(minimumSize: const Size.fromHeight(48)),
              child: Text(l10n.unlock_premium),
            ),
            const SizedBox(height: 8),
            TextButton(
              onPressed: () => Navigator.pop(ctx),
              child: Text(l10n.not_now),
            ),
          ],
        ),
      ),
    );
  }

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

  Future<void> _startTopics() async {
    await Navigator.push(
      context,
      MaterialPageRoute(builder: (_) => const QuizTopicsScreen()),
    );
    // Reload count so banner reflects any increments done inside QuizTopicsScreen.
    if (!mounted) return;
    final updated = await AppPrefs.getQuizTrialCount();
    if (mounted) setState(() => _quizTrialCount = updated);
  }

  void _startSwipeTF() {
    Navigator.push(
      context,
      MaterialPageRoute(builder: (_) => const SwipeQuizScreen()),
    );
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final colorScheme = Theme.of(context).colorScheme;
    final sessionsUsed = _quizTrialCount;
    final showBanner = !_isPro;

    return Scaffold(
      appBar: AppBar(title: Text(l10n.quiz_modes_title)),
      body: SafeArea(
        child: ListView(
          padding: const EdgeInsets.all(16),
          children: [
            if (showBanner) ...[
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                decoration: BoxDecoration(
                  color: sessionsUsed >= _kQuizFreeLimit
                      ? colorScheme.errorContainer
                      : colorScheme.primaryContainer,
                  borderRadius: BorderRadius.circular(AppTheme.radiusSmall),
                ),
                child: Row(
                  children: [
                    Icon(
                      sessionsUsed >= _kQuizFreeLimit ? Icons.lock_outline : Icons.info_outline,
                      size: 18,
                      color: sessionsUsed >= _kQuizFreeLimit
                          ? colorScheme.onErrorContainer
                          : colorScheme.onPrimaryContainer,
                    ),
                    const SizedBox(width: 8),
                    Expanded(
                      child: Text(
                        l10n.quiz_sessions_remaining(sessionsUsed, _kQuizFreeLimit),
                        style: Theme.of(context).textTheme.bodySmall?.copyWith(
                          color: sessionsUsed >= _kQuizFreeLimit
                              ? colorScheme.onErrorContainer
                              : colorScheme.onPrimaryContainer,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 16),
            ],
            _ModeCard(
              icon: Icons.rule_folder_outlined,
              color: colorScheme.error,
              title: l10n.quiz_mode_mistakes,
              subtitle: '',
              description: l10n.quiz_mode_mistakes_desc,
              onTap: () => _checkAndStart(_startMistakes),
            ),
            const SizedBox(height: 12),
            _ModeCard(
              icon: Icons.category_outlined,
              color: colorScheme.primary,
              title: l10n.quiz_mode_topics,
              subtitle: '',
              description: l10n.quiz_mode_topics_desc,
              onTap: () => _checkLimitOnly(_startTopics),
            ),
            const SizedBox(height: 12),
            _ModeCard(
              icon: Icons.timer_outlined,
              color: colorScheme.tertiary,
              title: l10n.quiz_mode_timer,
              subtitle: '',
              description: l10n.quiz_mode_timer_desc,
              onTap: () => _checkAndStart(_startTimer),
            ),
            const SizedBox(height: 12),
            _ModeCard(
              icon: Icons.swap_horiz,
              color: colorScheme.secondary,
              title: l10n.quiz_mode_swipe_tf,
              subtitle: '',
              description: l10n.quiz_mode_swipe_tf_desc,
              onTap: () => _checkAndStart(_startSwipeTF),
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
