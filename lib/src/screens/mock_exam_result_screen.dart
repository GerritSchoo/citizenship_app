import 'package:flutter/material.dart';

import '../models/question.dart';
import '../widgets/exam_result_indicator.dart';
import '../../l10n/app_localizations.dart';
import '../achievements/achievement_service.dart';
import '../analytics/progress_repository.dart';
import '../payments/purchase_service.dart';
import 'paywall_screen.dart';

class MockExamResultScreen extends StatefulWidget {
  final int total;
  final int correct;
  final List<Question> questions;
  final List<int?> answers;

  const MockExamResultScreen({super.key, required this.total, required this.correct, required this.questions, required this.answers});

  @override
  State<MockExamResultScreen> createState() => _MockExamResultScreenState();
}

class _MockExamResultScreenState extends State<MockExamResultScreen> {
  bool _awarded = false;
  bool _paywallPrompted = false;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    // Award achievements once when arriving to result screen
    if (!_awarded) {
      _awarded = true;
      // Post-frame to ensure Scaffold is ready for SnackBar
      WidgetsBinding.instance.addPostFrameCallback((_) {
        AchievementService.instance.onExamSubmitted(context, correct: widget.correct, total: widget.total);
      });
    }
    // Show subscription prompt after the third completed exam if lock is enabled
    if (!_paywallPrompted && !PurchaseService.instance.isPro) {
      _paywallPrompted = true;
      WidgetsBinding.instance.addPostFrameCallback((_) async {
        await ProgressRepository.instance.init();
        final results = await ProgressRepository.instance.examResults();
        final completed = results.where((e) => e.completed).length;
        if (!mounted) return;
        if (completed >= 3) {
          final l10n = AppLocalizations.of(context);
          final go = await showDialog<bool>(
            context: context,
            builder: (c) => AlertDialog(
              title: Text(l10n.trial_exhausted_title),
              content: Text(l10n.trial_exhausted_body),
              actions: [
                TextButton(onPressed: () => Navigator.of(c).pop(false), child: Text(l10n.trial_later)),
                FilledButton(onPressed: () => Navigator.of(c).pop(true), child: Text(l10n.trial_subscribe)),
              ],
            ),
          );
          if (go == true && mounted) {
            await Navigator.push(context, MaterialPageRoute(builder: (_) => const PaywallScreen()));
          }
        }
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final pass = widget.correct >= 17;
    return Scaffold(
      appBar: AppBar(
        title: Text(l10n.result_title, maxLines: 1, overflow: TextOverflow.ellipsis),
      ),
      body: Padding(
        padding: const EdgeInsets.all(12.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Card(
              child: Padding(
                padding: const EdgeInsets.all(12.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      pass ? l10n.result_passed : l10n.result_failed,
                      style: Theme.of(context).textTheme.titleLarge,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                    const SizedBox(height: 8),
                    Text(l10n.result_correct_of_total(widget.correct.toString(), widget.total.toString())),
                    const SizedBox(height: 12),
                    // Grade category, range and description
                    Builder(builder: (ctx) {
                      final cat = gradeForCorrect(widget.correct);
                      final label = labelForCategory(ctx, cat).toUpperCase();
                      final icon = iconForCategory(cat);
                      final color = colorForCategory(ctx, cat);
                      final bg = color.withValues(alpha: 0.12);
                      return Card(
                        color: bg,
                        child: Padding(
                          padding: const EdgeInsets.all(12.0),
                          child: Row(
                            children: [
                              Icon(icon, color: color, size: 28),
                              const SizedBox(width: 12),
                              Expanded(child: Text(label, style: Theme.of(ctx).textTheme.titleSmall)),
                            ],
                          ),
                        ),
                      );
                    }),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 12),
            Expanded(
              child: ListView.builder(
                itemCount: widget.questions.length,
                itemBuilder: (c, i) {
                  final q = widget.questions[i];
                  final sel = widget.answers[i];
                  return Card(
                    child: ListTile(
                      title: Text(q.text, maxLines: 3, overflow: TextOverflow.ellipsis),
                      subtitle: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const SizedBox(height: 6),
                          Text(l10n.result_your_answer(sel == null ? l10n.no_answer : q.answers[sel])),
                          Text(l10n.result_correct_answer(q.answers[q.correctIndex])),
                        ],
                      ),
                    ),
                  );
                },
              ),
            ),
            ElevatedButton(
              onPressed: () {
                Navigator.of(context).popUntil((route) => route.isFirst);
              },
              child: Text(l10n.back_to_home),
            )
          ],
        ),
      ),
    );
  }
}
