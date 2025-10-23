import 'package:flutter/material.dart';
import '../../l10n/app_localizations.dart';

class PaywallScreen extends StatelessWidget {
  const PaywallScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    return Scaffold(
      appBar: AppBar(title: Text(l10n.paywall_title)),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Text(l10n.paywall_subtitle, style: Theme.of(context).textTheme.titleMedium),
            const SizedBox(height: 16),
            Card(
              child: ListTile(
                leading: const Icon(Icons.workspace_premium_outlined),
                title: Text(l10n.paywall_monthly),
                subtitle: const Text('€0.99 / month'),
                trailing: FilledButton(onPressed: () => Navigator.of(context).maybePop(), child: const Text('OK')),
              ),
            ),
            const SizedBox(height: 12),
            Card(
              child: ListTile(
                leading: const Icon(Icons.workspace_premium_outlined),
                title: Text(l10n.paywall_yearly),
                subtitle: const Text('€9.99 / year'),
                trailing: FilledButton(onPressed: () => Navigator.of(context).maybePop(), child: const Text('OK')),
              ),
            ),
            const Spacer(),
            Center(child: TextButton(onPressed: () => Navigator.of(context).maybePop(), child: const Text('Close'))),
          ],
        ),
      ),
    );
  }
}
