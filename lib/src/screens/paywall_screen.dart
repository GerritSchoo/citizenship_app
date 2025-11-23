import 'package:flutter/material.dart';
import 'package:in_app_purchase/in_app_purchase.dart';
import '../../l10n/app_localizations.dart';
import '../payments/purchase_service.dart';

class PaywallScreen extends StatefulWidget {
  const PaywallScreen({super.key});

  @override
  State<PaywallScreen> createState() => _PaywallScreenState();
}

class _PaywallScreenState extends State<PaywallScreen> {
  bool _initializing = true;
  bool _isAvailable = false;
  String? _error;

  @override
  void initState() {
    super.initState();
    PurchaseService.instance.startListening(_onPurchaseUpdate);
    _initPurchases();
  }

  @override
  void dispose() {
    PurchaseService.instance.stopListening();
    super.dispose();
  }

  Future<void> _initPurchases() async {
    await PurchaseService.instance.init();
    if (!mounted) return;
    setState(() {
      _initializing = false;
      _isAvailable = PurchaseService.instance.isAvailable;
    });
  }

  Future<void> _onPurchaseUpdate(PurchaseDetails purchase) async {
    // Für Tests: Einfach bei erfolgreichem Kauf abschließen und Paywall schließen.
    if (purchase.status == PurchaseStatus.purchased ||
        purchase.status == PurchaseStatus.restored) {
      await PurchaseService.instance.completeIfPending(purchase);
      if (!mounted) return;
      Navigator.of(context).maybePop();
    } else if (purchase.status == PurchaseStatus.error) {
      if (!mounted) return;
      setState(() => _error = purchase.error?.message ?? 'Purchase error');
    }
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final theme = Theme.of(context);
    return Scaffold(
      appBar: AppBar(title: Text(l10n.paywall_title)),
      body: LayoutBuilder(
        builder: (context, constraints) {
          final isCompactHeight = constraints.maxHeight < 550;
          return SafeArea(
            child: Center(
              child: ConstrainedBox(
                constraints: const BoxConstraints(maxWidth: 600),
                child: Padding(
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      Text(l10n.paywall_subtitle, style: theme.textTheme.titleMedium),
                      const SizedBox(height: 8),
                      if (_initializing)
                        const LinearProgressIndicator()
                      else if (!_isAvailable)
                        Text(l10n.paywall_unavailable,
                            style: theme.textTheme.bodySmall?.copyWith(color: theme.colorScheme.error)),
                      if (_error != null) ...[
                        const SizedBox(height: 8),
                        Text(_error!, style: theme.textTheme.bodySmall?.copyWith(color: theme.colorScheme.error)),
                      ],
                      const SizedBox(height: 16),
                      // Bereich für Pläne; bleibt scrollbar als Fallback,
                      // ist aber durch kompaktere Karten meist voll sichtbar.
                      Expanded(
                        child: SingleChildScrollView(
                          padding: const EdgeInsets.only(bottom: 8),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.stretch,
                            children: [
                              _PlanCard(
                                title: l10n.paywall_monthly,
                                highlight: false,
                                pricePerMonth: l10n.paywall_plan_monthly_price,
                                totalLabel: l10n.paywall_plan_monthly_total,
                                saveLabel: l10n.paywall_plan_monthly_flexible,
                                onPressed: (!_initializing && _isAvailable)
                                    ? () async {
                                        final product = PurchaseService.instance
                                            .getProductById('citizenship_premium_monthly');
                                        if (product != null) {
                                          await PurchaseService.instance.buy(product);
                                        }
                                      }
                                    : null,
                              ),
                              const SizedBox(height: 12),
                              _PlanCard(
                                title: l10n.paywall_half_yearly,
                                highlight: true,
                                pricePerMonth: l10n.paywall_plan_half_yearly_price,
                                totalLabel: l10n.paywall_plan_half_yearly_total,
                                saveLabel: l10n.paywall_plan_half_yearly_save,
                                onPressed: (!_initializing && _isAvailable)
                                    ? () async {
                                        final product = PurchaseService.instance
                                            .getProductById('citizenship_premium_semiannual');
                                        if (product != null) {
                                          await PurchaseService.instance.buy(product);
                                        }
                                      }
                                    : null,
                              ),
                              const SizedBox(height: 12),
                              _PlanCard(
                                title: l10n.paywall_yearly,
                                highlight: false,
                                pricePerMonth: l10n.paywall_plan_yearly_price,
                                totalLabel: l10n.paywall_plan_yearly_total,
                                saveLabel: l10n.paywall_plan_yearly_save,
                                onPressed: (!_initializing && _isAvailable)
                                    ? () async {
                                        final product = PurchaseService.instance
                                            .getProductById('citizenship_premium_yearly');
                                        if (product != null) {
                                          await PurchaseService.instance.buy(product);
                                        }
                                      }
                                    : null,
                              ),
                              if (isCompactHeight) const SizedBox(height: 8),
                            ],
                          ),
                        ),
                      ),
                      Center(
                        child: TextButton(
                          onPressed: () => Navigator.of(context).maybePop(),
                          child: Text(l10n.close),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          );
        },
      ),
    );
  }
}

class _PlanCard extends StatelessWidget {
  final String title;
  final String pricePerMonth;
  final String totalLabel;
  final String saveLabel;
  final bool highlight;
  final VoidCallback? onPressed;

  const _PlanCard({
    required this.title,
    required this.pricePerMonth,
    required this.totalLabel,
    required this.saveLabel,
    required this.highlight,
    required this.onPressed,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    final bg = highlight
        ? colorScheme.primaryContainer
        : theme.brightness == Brightness.dark
            ? colorScheme.surfaceContainerHighest
            : Colors.white;

    return Material(
      color: bg,
      elevation: highlight ? 2 : 0,
      borderRadius: BorderRadius.circular(12),
      child: InkWell(
        borderRadius: BorderRadius.circular(12),
        onTap: onPressed,
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
          child: Row(
            children: [
              Icon(
                Icons.workspace_premium_outlined,
                color: highlight ? colorScheme.primary : colorScheme.secondary,
                size: 24,
              ),
              const SizedBox(width: 10),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Text(
                          title,
                          style: theme.textTheme.titleSmall?.copyWith(
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                        if (highlight) ...[
                          const SizedBox(width: 6),
                          Container(
                            padding: const EdgeInsets.symmetric(
                                horizontal: 6, vertical: 2),
                            decoration: BoxDecoration(
                              color: colorScheme.primary,
                              borderRadius: BorderRadius.circular(999),
                            ),
                            child: Text(
                              'Beliebt',
                              style: theme.textTheme.labelSmall
                                  ?.copyWith(color: colorScheme.onPrimary),
                            ),
                          ),
                        ],
                      ],
                    ),
                    const SizedBox(height: 2),
                    Text(
                      pricePerMonth,
                      style: theme.textTheme.bodySmall
                          ?.copyWith(fontWeight: FontWeight.w600),
                    ),
                    const SizedBox(height: 1),
                    Text(
                      totalLabel,
                      style: theme.textTheme.bodySmall,
                    ),
                    const SizedBox(height: 1),
                    Text(
                      saveLabel,
                      style: theme.textTheme.bodySmall?.copyWith(
                        color: colorScheme.primary,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(width: 8),
              SizedBox(
                height: 32,
                child: FilledButton(
                  onPressed: onPressed,
                  style: FilledButton.styleFrom(
                    padding:
                        const EdgeInsets.symmetric(horizontal: 12, vertical: 0),
                  ),
                  child: const Text('Wählen'),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

