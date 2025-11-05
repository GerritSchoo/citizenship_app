import 'package:flutter/material.dart';
import 'package:intl/intl.dart' as intl;

import '../../l10n/app_localizations.dart';
import '../core/highscore_store.dart';
import '../theme/app_theme.dart';

class TimerResultsScreen extends StatefulWidget {
  final int correct;
  final int answered;
  const TimerResultsScreen({super.key, required this.correct, required this.answered});

  @override
  State<TimerResultsScreen> createState() => _TimerResultsScreenState();
}

class _TimerResultsScreenState extends State<TimerResultsScreen> {
  List<TimerHighscore> _scores = const [];
  bool _loading = true;

  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load() async {
    final list = await HighscoreStore.instance.topScores(limit: 10);
    if (!mounted) return;
    setState(() {
      _scores = list;
      _loading = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    return Scaffold(
      appBar: AppBar(title: Text(l10n.timer_results_title)),
      body: _loading
          ? const Center(child: CircularProgressIndicator())
          : ListView(
              padding: const EdgeInsets.all(16),
              children: [
                Card(
                  child: Padding(
                    padding: const EdgeInsets.all(16),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(l10n.result_title, style: theme.textTheme.titleMedium),
                        const SizedBox(height: 8),
                        Row(
                          children: [
                            Container(
                              height: 44,
                              width: 44,
                              decoration: BoxDecoration(
                                color: colorScheme.tertiary.withValues(alpha: 0.12),
                                borderRadius: BorderRadius.circular(AppTheme.radiusSmall),
                              ),
                              child: Icon(Icons.timer_outlined, color: colorScheme.tertiary, size: 26),
                            ),
                            const SizedBox(width: 12),
                            Expanded(
                              child: Text(
                                l10n.result_correct_of_total(widget.correct, widget.answered),
                                style: theme.textTheme.titleMedium,
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                ),
                const SizedBox(height: 16),
                Text(l10n.leaderboard_title, style: theme.textTheme.titleSmall),
                const SizedBox(height: 8),
                if (_scores.isEmpty)
                  Card(
                    child: Padding(
                      padding: const EdgeInsets.all(16),
                      child: Text('—'),
                    ),
                  )
                else
                  Card(
                    child: ListView.separated(
                      shrinkWrap: true,
                      physics: const NeverScrollableScrollPhysics(),
                      itemCount: _scores.length,
                      separatorBuilder: (_, __) => const Divider(height: 1),
                      itemBuilder: (context, index) {
                        final s = _scores[index];
                        final rank = index + 1;
                        final locale = Localizations.localeOf(context).toString();
                        final dateText = intl.DateFormat('dd.MM.yyyy', locale).format(s.when);
                        return ListTile(
                          leading: CircleAvatar(
                            radius: 16,
                            backgroundColor: colorScheme.surfaceContainerHighest,
                            child: Text('$rank', style: theme.textTheme.labelMedium),
                          ),
                          title: Text(l10n.leaderboard_correct_answers(s.correct)),
                          subtitle: Text(dateText),
                        );
                      },
                    ),
                  ),
                const SizedBox(height: 16),
              ],
            ),
      bottomNavigationBar: SafeArea(
        minimum: const EdgeInsets.fromLTRB(16, 8, 16, 16),
        child: FilledButton.tonal(
          onPressed: () => Navigator.of(context).maybePop(),
          child: Text(l10n.back_to_home),
        ),
      ),
    );
  }
}
