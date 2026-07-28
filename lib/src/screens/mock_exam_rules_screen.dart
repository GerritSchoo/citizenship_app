import 'package:flutter/material.dart';
import '../payments/purchase_service.dart';
import '../theme/app_theme.dart';
import 'mock_exam_screen.dart';
import '../../l10n/app_localizations.dart';
import '../core/prefs.dart';
import 'paywall_screen.dart';

class MockExamRulesScreen extends StatelessWidget {
  const MockExamRulesScreen({super.key});

  List<String> _rules(BuildContext context) => [
        AppLocalizations.of(context).rule_duration,
        AppLocalizations.of(context).rule_composition,
        AppLocalizations.of(context).rule_pass,
        AppLocalizations.of(context).rule_no_aids,
        AppLocalizations.of(context).rule_change_answers,
        AppLocalizations.of(context).rule_auto_submit,
        AppLocalizations.of(context).rule_no_return,
      ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
  title: Text(AppLocalizations.of(context).exam_rules_title, maxLines: 1, overflow: TextOverflow.ellipsis),
        // keep the default back button
      ),
      body: SafeArea(
        child: Column(
          children: [
            Expanded(
              child: ListView.separated(
                padding: const EdgeInsets.all(16),
                itemCount: _rules(context).length,
                separatorBuilder: (context, _) => const SizedBox(height: 12),
                itemBuilder: (context, index) {
                  final rule = _rules(context)[index];
                  final theme = Theme.of(context);
                  final cs = theme.colorScheme;
                  return Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      CircleAvatar(
                        radius: 14,
                        backgroundColor: cs.primaryContainer,
                        child: Text(
                          '${index + 1}',
                          style: theme.textTheme.labelMedium?.copyWith(
                            color: cs.onPrimaryContainer,
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(child: Text(rule, style: theme.textTheme.bodyMedium, softWrap: true)),
                    ],
                  );
                },
              ),
            ),
            Padding(
              padding: const EdgeInsets.fromLTRB(16, 8, 16, 24),
              child: SizedBox(
                width: double.infinity,
                height: 56,
                child: ElevatedButton(
                  onPressed: () async {
                    // Gate starting the exam if subscription lock is enabled and 3 trials are used
                    final isPro = PurchaseService.instance.isPro;
                    if (!isPro) {
                      final trialCount = await AppPrefs.getExamTrialCount();
                      if (trialCount >= 3) {
                        if (!context.mounted) return;
                        showModalBottomSheet<void>(
                          context: context,
                          isScrollControlled: true,
                          shape: const RoundedRectangleBorder(
                            borderRadius: BorderRadius.vertical(top: Radius.circular(AppTheme.radiusLarge)),
                          ),
                          builder: (ctx) {
                            final l10n = AppLocalizations.of(ctx);
                            return SingleChildScrollView(
                              padding: EdgeInsets.fromLTRB(24, 24, 24, 32 + MediaQuery.viewInsetsOf(ctx).bottom),
                              child: Column(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  Icon(Icons.lock_outline, size: 48, color: Theme.of(ctx).colorScheme.primary),
                                  const SizedBox(height: 16),
                                  Text(
                                    l10n.trial_exhausted_title,
                                    style: Theme.of(ctx).textTheme.titleLarge?.copyWith(fontWeight: FontWeight.bold),
                                    textAlign: TextAlign.center,
                                  ),
                                  const SizedBox(height: 8),
                                  Text(
                                    l10n.trial_exhausted_body,
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
                            );
                          },
                        );
                        return; // do not start exam
                      }
                    }
                    if (!context.mounted) return;
                    Navigator.pushReplacement(context, MaterialPageRoute(builder: (_) => const MockExamScreen()));
                  },
                  style: ElevatedButton.styleFrom(
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(AppTheme.radiusMedium),
                    ),
                  ),
                  child: Text(AppLocalizations.of(context).exam_start, style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w600)),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
