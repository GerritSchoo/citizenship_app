import 'package:flutter/material.dart';

import '../../l10n/app_localizations.dart';
import '../achievements/achievement_service.dart';
import '../data/question_repository.dart';
import '../models/question.dart';
import '../core/prefs.dart';
import '../theme/app_theme.dart';
import 'quiz_screen.dart';

class MistakesResultsScreen extends StatefulWidget {
  final List<String> questionIds;
  const MistakesResultsScreen({super.key, required this.questionIds});

  @override
  State<MistakesResultsScreen> createState() => _MistakesResultsScreenState();
}

class _MistakesResultsScreenState extends State<MistakesResultsScreen> {
  bool _loading = true;
  List<Question> _questions = const [];
  final QuestionRepository _repo = QuestionRepository();

  @override
  void initState() {
    super.initState();
    _load();
    // Unlock mistakes achievements after navigation settles
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!mounted) return;
      AchievementService.instance.onMistakesReviewed(context, wrongCount: widget.questionIds.length);
    });
  }

  Future<void> _load() async {
    await _repo.init(languageCode: QuestionRepository.defaultLanguageCode);
    final all = <Question>[];
    all.addAll(_repo.generalQuestions);
    final code = await AppPrefs.getSelectedState();
    if (code != null && _repo.hasStateQuestions(code)) {
      all.addAll(_repo.getStateQuestions(code));
    }
    final byId = {for (final q in all) q.id: q};
    // Append state questions of any state; since we don't know state here, we rely on general mapping first.
    // QuestionRepository getStateQuestions requires code; we cannot resolve without prefs here.
    // If some wrongIds are state-only, they won't show a title; that's acceptable since this list is informational.
    final picked = <Question>[];
    for (final id in widget.questionIds) {
      final q = byId[id];
      if (q != null) picked.add(q);
    }
    if (!mounted) return;
    setState(() {
      _questions = picked;
      _loading = false;
    });
  }

  void _retry() {
    Navigator.of(context).pushReplacement(
      MaterialPageRoute(
        builder: (_) => QuizScreen(fixedQuestionIds: widget.questionIds),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    final hasMistakes = widget.questionIds.isNotEmpty;
    return Scaffold(
      appBar: AppBar(title: Text(hasMistakes ? l10n.mistakes_results_title : l10n.mistakes_all_correct_title)),
      body: _loading
          ? const Center(child: CircularProgressIndicator())
          : hasMistakes
              ? ListView(
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
                                    color: colorScheme.error.withValues(alpha: 0.12),
                                    borderRadius: BorderRadius.circular(AppTheme.radiusSmall),
                                  ),
                                  child: Icon(Icons.rule_folder_outlined, color: colorScheme.error, size: 26),
                                ),
                                const SizedBox(width: 12),
                                Expanded(
                                  child: Text(
                                    l10n.questions_count(_questions.length),
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
                    Card(
                      child: ListView.separated(
                        shrinkWrap: true,
                        physics: const NeverScrollableScrollPhysics(),
                        itemCount: _questions.length,
                        separatorBuilder: (_, __) => const Divider(height: 1),
                        itemBuilder: (context, index) {
                          final q = _questions[index];
                          return ListTile(
                            leading: CircleAvatar(
                              radius: 16,
                              backgroundColor: colorScheme.surfaceContainerHighest,
                              child: Text('${index + 1}', style: theme.textTheme.labelMedium),
                            ),
                            title: Text(q.text),
                          );
                        },
                      ),
                    ),
                    const SizedBox(height: 16),
                  ],
                )
              : Center(
                  child: Padding(
                    padding: const EdgeInsets.all(24),
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(Icons.emoji_events_outlined, size: 64, color: colorScheme.primary),
                        const SizedBox(height: 12),
                        Text(l10n.mistakes_all_correct_title, style: theme.textTheme.headlineSmall, textAlign: TextAlign.center),
                      ],
                    ),
                  ),
                ),
      bottomNavigationBar: SafeArea(
        minimum: const EdgeInsets.fromLTRB(16, 8, 16, 16),
        child: hasMistakes
            ? FilledButton.tonal(
                onPressed: _retry,
                child: Text(l10n.mistakes_retry_wrong),
              )
            : FilledButton.tonal(
                onPressed: () => Navigator.of(context).maybePop(),
                child: Text(l10n.back_to_home),
              ),
      ),
    );
  }
}
