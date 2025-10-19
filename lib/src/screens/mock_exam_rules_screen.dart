import 'package:flutter/material.dart';
import 'mock_exam_screen.dart';
import '../../l10n/app_localizations.dart';

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
                separatorBuilder: (_, __) => const SizedBox(height: 12),
                itemBuilder: (context, index) {
                  final rule = _rules(context)[index];
                  return Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      CircleAvatar(radius: 14, backgroundColor: Colors.blue.shade100, child: Text('${index + 1}')),
                      const SizedBox(width: 12),
                      Expanded(child: Text(rule, style: Theme.of(context).textTheme.bodyMedium, softWrap: true)),
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
                  onPressed: () {
                    Navigator.pushReplacement(context, MaterialPageRoute(builder: (_) => const MockExamScreen()));
                  },
                  style: ElevatedButton.styleFrom(shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12))),
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
