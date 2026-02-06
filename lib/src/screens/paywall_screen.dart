import 'package:flutter/material.dart';
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
    PurchaseService.instance.isProNotifier.addListener(_onProStatusChanged);
    PurchaseService.instance.addListener(_onServiceUpdate);
    _initPurchases();
  }

  @override
  void dispose() {
    PurchaseService.instance.isProNotifier.removeListener(_onProStatusChanged);
    PurchaseService.instance.removeListener(_onServiceUpdate);
    super.dispose();
  }

  void _onServiceUpdate() {
    if (mounted) setState(() {});
  }

  void _onProStatusChanged() {
    if (PurchaseService.instance.isPro) {
      if (mounted) {
        Navigator.of(context).maybePop();
      }
    }
  }

  Future<void> _initPurchases() async {
    // Try to initialize if not available or if products haven't been loaded yet
    if (!PurchaseService.instance.isAvailable || PurchaseService.instance.products.isEmpty) {
       await PurchaseService.instance.init();
    }
    
    if (!mounted) return;
    setState(() {
      _initializing = false;
      _isAvailable = PurchaseService.instance.isAvailable;
    });
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final theme = Theme.of(context);
    return Scaffold(
      appBar: AppBar(
        title: Text(l10n.paywall_title),
      ),
      body: SafeArea(
        child: Column(
          children: [
            Expanded(
              child: SingleChildScrollView(
                child: Center(
                  child: ConstrainedBox(
                    constraints: const BoxConstraints(maxWidth: 600),
                    child: Padding(
                      padding: const EdgeInsets.all(16),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.stretch,
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Text(l10n.paywall_subtitle, style: theme.textTheme.titleMedium),
                          const SizedBox(height: 8),
                          if (_initializing) const LinearProgressIndicator(),
                          if (!_isAvailable && !_initializing)
                            Padding(
                              padding: const EdgeInsets.only(bottom: 8.0),
                              child: Text(
                                l10n.paywall_unavailable,
                                style: theme.textTheme.bodyMedium?.copyWith(color: theme.colorScheme.error),
                              ),
                            ),
                          if (_error != null) ...[
                            const SizedBox(height: 8),
                            Text(_error!, style: theme.textTheme.bodySmall?.copyWith(color: theme.colorScheme.error)),
                          ],
                          const SizedBox(height: 16),
                          
                          // Two cards: Monthly & Lifetime
                          Builder(
                            builder: (context) {
                              final instance = PurchaseService.instance;
                              final monthlyProduct = instance.getProductById('citizenship_premium_monthly');
                              final lifetimeProduct = instance.getProductById('citizenship_premium_lifetime');
                              
                              final isMonthlyActive = instance.isProductActive('citizenship_premium_monthly');
                              final isLifetimeActive = instance.isProductActive('citizenship_premium_lifetime');
                              final anyActive = instance.isPro;

                              // Placeholder prices for visualization
                              final displayPriceMonthly = monthlyProduct?.price ?? '6.99 €';
                              final displayPriceLifetime = lifetimeProduct?.price ?? '14.99 €';

                              return Column(
                                crossAxisAlignment: CrossAxisAlignment.stretch,
                                children: [
                                  // 1. Monthly Card
                                  _PlanCard(
                                    title: l10n.paywall_monthly,
                                    price: displayPriceMonthly, 
                                    description: l10n.paywall_cancel_anytime,
                                    buttonText: isMonthlyActive ? (l10n.purchased ?? 'Active') : l10n.paywall_subscribe_action,
                                    isActive: isMonthlyActive,
                                    onPressed: (_isAvailable && monthlyProduct != null && !anyActive)
                                        ? () async {
                                            await instance.buy(monthlyProduct);
                                          }
                                        : null,
                                  ),
                                  
                                  const SizedBox(height: 12),
                                  
                                  // 2. Lifetime Card
                                  _PlanCard(
                                    title: l10n.paywall_lifetime,
                                    price: displayPriceLifetime,
                                    description: l10n.paywall_lifetime_description,
                                    buttonText: isLifetimeActive ? (l10n.purchased ?? 'Active') : l10n.paywall_buy_action,
                                    isPopular: true,
                                    isActive: isLifetimeActive,
                                    onPressed: (_isAvailable && lifetimeProduct != null && !anyActive)
                                        ? () async {
                                            await instance.buy(lifetimeProduct);
                                          }
                                        : null,
                                  ),
                                ],
                              );
                            },
                          ),
                          const SizedBox(height: 16),
                          TextButton(
                            onPressed: () async {
                              await PurchaseService.instance.restorePurchases();
                            },
                            child: Text(l10n.restore_purchases ?? 'Restore Purchases'),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _PlanCard extends StatelessWidget {
  final String title;
  final String price;
  final String description;
  final String buttonText;
  final VoidCallback? onPressed;
  final bool isPopular;
  final bool isActive;

  const _PlanCard({
    required this.title,
    required this.price,
    required this.description,
    required this.buttonText,
    required this.onPressed,
    this.isPopular = false,
    this.isActive = false,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    final l10n = AppLocalizations.of(context);

    // Determine colors based on active/popular state
    final borderColor = isActive 
        ? Colors.green 
        : (isPopular ? colorScheme.primary : Colors.transparent);
    
    final borderWidth = (isActive || isPopular) ? 2.0 : 0.0;
    
    return Stack(
      children: [
        Material(
          color: isPopular ? colorScheme.primaryContainer : colorScheme.surfaceContainerHigh,
          elevation: isPopular ? 4 : 1,
          shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(16),
              side: isActive || isPopular 
                  ? BorderSide(color: borderColor, width: borderWidth) 
                  : BorderSide.none
          ),
          child: InkWell(
            borderRadius: BorderRadius.circular(16),
            onTap: onPressed,
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  Text(
                    title,
                    style: theme.textTheme.titleMedium?.copyWith(
                      fontWeight: FontWeight.bold,
                      color: isPopular ? colorScheme.onPrimaryContainer : colorScheme.onSurface,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Expanded(
                        child: Text(
                          description,
                          style: theme.textTheme.bodySmall?.copyWith(
                             color: (isPopular ? colorScheme.onPrimaryContainer : colorScheme.onSurface).withValues(alpha: 0.8),
                          ),
                        ),
                      ),
                      const SizedBox(width: 8),
                      Text(
                        price,
                        style: theme.textTheme.titleMedium?.copyWith(
                          fontWeight: FontWeight.bold,
                          color: isPopular ? colorScheme.primary : colorScheme.onSurface,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 12),
                  FilledButton(
                    onPressed: onPressed,
                    style: FilledButton.styleFrom(
                      backgroundColor: isActive 
                          ? Colors.green 
                          : (isPopular ? colorScheme.primary : colorScheme.secondaryContainer),
                      foregroundColor: isActive
                          ? Colors.white
                          : (isPopular ? colorScheme.onPrimary : colorScheme.onSecondaryContainer),
                      padding: const EdgeInsets.symmetric(vertical: 12),
                      textStyle: const TextStyle(fontSize: 14, fontWeight: FontWeight.bold),
                    ),
                    child: Text(isActive ? (l10n.purchased ?? 'Purchased') : buttonText),
                  ),
                ],
              ),
            ),
          ),
        ),
        if (isPopular && !isActive)
          Positioned(
            top: 0,
            right: 0,
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
              decoration: BoxDecoration(
                color: colorScheme.secondary,
                borderRadius: const BorderRadius.only(
                  topRight: Radius.circular(16),
                  bottomLeft: Radius.circular(16),
                ),
              ),
              child: Text(
                l10n.paywall_popular_badge,
                style: theme.textTheme.labelSmall?.copyWith(
                  color: colorScheme.onSecondary,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          ),
        if (isActive)
          Positioned(
            top: 0,
            right: 0,
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
              decoration: const BoxDecoration(
                color: Colors.green,
                borderRadius: BorderRadius.only(
                  topRight: Radius.circular(16),
                  bottomLeft: Radius.circular(16),
                ),
              ),
              child: const Icon(Icons.check, size: 16, color: Colors.white),
            ),
          ),
      ],
    );
  }
}

