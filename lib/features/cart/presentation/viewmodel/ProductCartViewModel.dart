import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'dart:async';
import 'package:vedika_healthcare/core/constants/ApiEndpoints.dart';
import 'package:vedika_healthcare/core/constants/apiConstants.dart';
import 'package:vedika_healthcare/features/cart/data/services/ProductCartPaymentService.dart';
import 'package:vedika_healthcare/features/cart/data/services/ProductCartService.dart';
import 'package:vedika_healthcare/features/cart/data/services/ProductOrderPlacementService.dart';
import 'package:vedika_healthcare/features/home/data/models/ProductCart.dart';

class ProductCartViewModel extends ChangeNotifier {
  final ProductCartService _cartService;
  final ProductOrderPlacementService _orderPlacementService;
  final ProductCartPaymentService _paymentService;

  ProductCartViewModel({
    Dio? dio,
    ProductCartPaymentService? paymentService,
  })  : _cartService = ProductCartService(dio ?? Dio()),
        _orderPlacementService = ProductOrderPlacementService(dio ?? Dio()),
        _paymentService = paymentService ?? ProductCartPaymentService();

  List<ProductCart> _items = [];
  bool _isLoading = false;
  double _subtotal = 0.0;
  double _deliveryFee = 0.0;
  double _platformFee = 10.0;
  double _discount = 0.0;

  List<ProductCart> get items => _items;
  bool get isLoading => _isLoading;
  double get subtotal => _subtotal;
  double get deliveryFee => _deliveryFee;
  double get platformFee => _platformFee;
  double get discount => _discount;
  double get total => (_subtotal - _discount + _deliveryFee + _platformFee).clamp(1, double.infinity);

  Future<void> loadCart() async {
    _isLoading = true;
    notifyListeners();
    try {
      _items = await _cartService.getProductCartItems();
      _recalculateSubtotal();
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  void setDeliveryFee(double fee) {
    _deliveryFee = fee;
    notifyListeners();
  }

  void setDiscount(double value) {
    _discount = value;
    notifyListeners();
  }

  Future<void> incrementQuantity(String cartId) async {
    final item = _items.firstWhere((e) => e.cartId == cartId);
    final updated = await _cartService.updateCartItemQuantity(cartId, (item.quantity ?? 0) + 1);
    _replaceItem(updated);
  }

  Future<void> decrementQuantity(String cartId) async {
    final item = _items.firstWhere((e) => e.cartId == cartId);
    final current = (item.quantity ?? 0);
    // Do not remove the item when quantity is 1; just ignore the decrement
    if (current <= 1) {
      return;
    }
    final updated = await _cartService.updateCartItemQuantity(cartId, current - 1);
    _replaceItem(updated);
  }

  Future<void> removeItem(String cartId) async {
    final ok = await _cartService.deleteCartItem(cartId);
    if (ok) {
      _items.removeWhere((e) => e.cartId == cartId);
      _recalculateSubtotal();
      notifyListeners();
    }
  }

  void _replaceItem(ProductCart updated) {
    final idx = _items.indexWhere((e) => e.cartId == updated.cartId);
    if (idx != -1) {
      final existing = _items[idx];
      // Merge to preserve product metadata when backend returns partial object
      _items[idx] = ProductCart(
        cartId: updated.cartId ?? existing.cartId,
        userId: updated.userId ?? existing.userId,
        productId: updated.productId ?? existing.productId,
        quantity: updated.quantity ?? existing.quantity,
        addedAt: updated.addedAt ?? existing.addedAt,
        imageUrl: updated.imageUrl ?? existing.imageUrl,
        productName: updated.productName ?? existing.productName,
        price: updated.price ?? existing.price,
        category: updated.category ?? existing.category,
      );
      _recalculateSubtotal();
      notifyListeners();
    }
  }

  void _recalculateSubtotal() {
    double sum = 0.0;
    for (final item in _items) {
      final qty = item.quantity ?? 0;
      final price = item.price ?? 0.0;
      sum += qty * price;
    }
    _subtotal = sum;
  }

  Future<Map<String, dynamic>> payAndPlaceOrder({
    required BuildContext context,
  }) async {
    if (total <= 0) {
      throw Exception('Invalid total amount');
    }

    final completer = Completer<Map<String, dynamic>>();

    _paymentService.openPaymentGateway(
      amount: total,
      apiKey: ApiConstants.razorpayApiKey,
      title: 'Product Order',
      description: 'Payment for your product order',
      onSuccess: (_) async {
        try {
          final res = await _orderPlacementService.placeProductOrder();
          completer.complete(res);
          // Order placed: clear local items and notify for count refresh
          _items.clear();
          _recalculateSubtotal();
          notifyListeners();
        } catch (e) {
          completer.completeError(e);
        }
      },
      onError: (err) {
        completer.completeError(Exception(err.message ?? 'Payment failed'));
      },
    );

    return completer.future;
  }

  @override
  void dispose() {
    _paymentService.dispose();
    super.dispose();
  }
}


