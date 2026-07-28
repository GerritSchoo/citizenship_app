import 'dart:async';
import 'package:flutter/foundation.dart';
import 'package:in_app_purchase/in_app_purchase.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../analytics/analytics_service.dart';
import '../core/remote_config_service.dart';

/// Wrapper around in_app_purchase for Play Store billing.
class PurchaseService extends ChangeNotifier {
  PurchaseService._();

  static final PurchaseService instance = PurchaseService._();

  final InAppPurchase _iap = InAppPurchase.instance;

  // Product IDs you will create in the Play Console.
  static const Set<String> productIds = {
    'citizenship_premium_monthly',
    'citizenship_premium_lifetime',
    // 'citizenship_premium_semiannual', // Future use
    // 'citizenship_premium_yearly', // Future use
  };

  bool _available = false;
  bool get isAvailable => _available;

  List<ProductDetails> _products = [];
  List<ProductDetails> get products => _products;

  Set<String> _activeProductIds = {};

  StreamSubscription<List<PurchaseDetails>>? _subscription;
  
  // Reactive state for UI
  final ValueNotifier<bool> isProNotifier = ValueNotifier<bool>(false);

  /// Dev override — set to true to treat every user as Pro during development.
  static bool debugForcePremium = false;

  bool get isPro {
    if (debugForcePremium) return true;
    // Check global testing/gating flag. 
    // If lock is disabled (false), everyone gets pro access.
    if (!RemoteConfigService.instance.subscriptionLockEnabled) return true;
    return _activeProductIds.isNotEmpty;
  }

  bool isProductActive(String id) => _activeProductIds.contains(id);

  Future<void> init() async {
    // 1. Load local state immediately
    final prefs = await SharedPreferences.getInstance();
    final activeList = prefs.getStringList('active_products') ?? [];
    _activeProductIds = activeList.toSet();
    isProNotifier.value = isPro;

    // 2. Check store availability
    _available = await _iap.isAvailable();
    
    // 3. Start listening to the global stream
    _startListening();

    if (_available) {
      // 4. Load products
      final response = await _iap.queryProductDetails(productIds);
      if (response.error == null) {
        _products = response.productDetails.toList();
        notifyListeners(); // Notify UI that products are loaded
      }
      
      // 5. Build robust restoration check
      await _iap.restorePurchases();
    }
  }

  void _startListening() {
    _subscription = _iap.purchaseStream.listen((purchases) {
      _handlePurchaseUpdates(purchases);
    }, onDone: () {
      _subscription?.cancel();
    }, onError: (error) {
      // Handle error
    });
  }

  Future<void> _handlePurchaseUpdates(List<PurchaseDetails> purchases) async {
    bool changed = false;

    for (final purchase in purchases) {
      if (purchase.status == PurchaseStatus.purchased) {
        if (_activeProductIds.add(purchase.productID)) {
          changed = true;
          unawaited(AnalyticsService.instance.logPurchaseCompleted(purchase.productID));
        }
      } else if (purchase.status == PurchaseStatus.restored) {
        if (_activeProductIds.add(purchase.productID)) {
          changed = true;
        }
      } else if (purchase.status == PurchaseStatus.error) {
        // Handle error if needed
      }

      if (purchase.pendingCompletePurchase) {
        await _iap.completePurchase(purchase);
      }
    }

    if (changed) {
      final prefs = await SharedPreferences.getInstance();
      await prefs.setStringList('active_products', _activeProductIds.toList());
      isProNotifier.value = isPro;
      notifyListeners();
    }
  }

  @override
  void dispose() {
    _subscription?.cancel();
    super.dispose();
  }

  ProductDetails? getProductById(String id) {
    try {
      return _products.firstWhere((p) => p.id == id);
    } catch (_) {
      return null;
    }
  }

  Future<void> buy(ProductDetails product) async {
    final param = PurchaseParam(productDetails: product);
    await _iap.buyNonConsumable(purchaseParam: param);
  }
  
  Future<void> restorePurchases() async {
    await _iap.restorePurchases();
  }
}


