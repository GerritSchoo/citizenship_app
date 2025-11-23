import 'dart:async';

import 'package:in_app_purchase/in_app_purchase.dart';

/// Wrapper around in_app_purchase for Play Store billing.
///
/// This does not perform server-side verification. For a production app,
/// you should verify purchases on a backend.
class PurchaseService {
  PurchaseService._();

  static final PurchaseService instance = PurchaseService._();

  final InAppPurchase _iap = InAppPurchase.instance;

  // Product IDs you will create in the Play Console.
  // Make sure these match exactly the IDs in the Play Console.
  static const Set<String> productIds = {
    'citizenship_premium_monthly',
    'citizenship_premium_semiannual',
    'citizenship_premium_yearly',
  };

  bool _available = false;
  bool get isAvailable => _available;

  List<ProductDetails> _products = [];
  List<ProductDetails> get products => _products;

  StreamSubscription<List<PurchaseDetails>>? _subscription;

  void startListening(void Function(PurchaseDetails) onPurchaseUpdate) {
    _subscription?.cancel();
    _subscription = _iap.purchaseStream.listen((purchases) {
      for (final p in purchases) {
        onPurchaseUpdate(p);
      }
    }, onDone: () => _subscription = null);
  }

  Future<void> stopListening() async {
    await _subscription?.cancel();
    _subscription = null;
  }

  Future<void> init() async {
    _available = await _iap.isAvailable();
    if (!_available) {
      _products = [];
      return;
    }
    final response = await _iap.queryProductDetails(productIds);
    if (response.error != null) {
      _products = [];
      return;
    }
    _products = response.productDetails.toList();
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

  Future<void> completeIfPending(PurchaseDetails purchase) async {
    if (purchase.pendingCompletePurchase) {
      await _iap.completePurchase(purchase);
    }
  }
}


