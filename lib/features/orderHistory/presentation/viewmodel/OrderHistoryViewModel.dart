import 'package:flutter/foundation.dart';
import 'dart:typed_data';
import 'package:vedika_healthcare/core/auth/data/services/StorageService.dart';
import 'package:vedika_healthcare/features/Vendor/ProductPartner/data/models/ProductOrder.dart';
import 'package:vedika_healthcare/features/orderHistory/data/services/OrderHistoryService.dart';
import 'package:vedika_healthcare/features/orderHistory/data/services/ProductOrderService.dart';

class OrderHistoryViewModel extends ChangeNotifier {
  final OrderHistoryService _service = OrderHistoryService();
  final ProductOrderService _productOrderService = ProductOrderService();
  
  List<ProductOrder> _productOrders = [];
  bool _isLoading = false;
  String? _error;

  List<ProductOrder> get productOrders => _productOrders;
  bool get isLoading => _isLoading;
  String? get error => _error;

  Future<void> fetchProductOrders() async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      String? userId = await StorageService.getUserId();
      if (userId == null) {
        throw Exception('User ID not found');
      }

      _productOrders = await _service.fetchProductOrders(userId);
    } catch (e) {
      _error = e.toString();
      _productOrders = [];
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<Uint8List> fetchProductOrderInvoiceBytes(String orderId) async {
    return await _productOrderService.fetchProductOrderInvoiceBytes(orderId);
  }
} 