import 'package:flutter/material.dart';
import 'package:dio/dio.dart';
import '../../data/services/ProductPartnerOrderService.dart';
import '../../data/models/ProductOrder.dart';

class ProductPartnerOrdersViewModel extends ChangeNotifier {
  final ProductPartnerOrderService _orderService;
  bool _isLoading = false;
  bool get isLoading => _isLoading;

  List<ProductOrder> _orders = [];
  List<ProductOrder> get orders => _orders;

  ProductPartnerOrdersViewModel()
      : _orderService = ProductPartnerOrderService(Dio());

  Future<void> fetchOrders(String vendorId) async {
    _isLoading = true;
    notifyListeners();

    try {
      _orders = await _orderService.getPendingOrdersByVendorId(vendorId);
    } catch (e) {
      debugPrint('Error fetching orders: $e');
      // You might want to handle the error differently, e.g., show a snackbar
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<void> updateOrderStatus(String orderId, String newStatus) async {
    _isLoading = true;
    notifyListeners();

    try {
      final updatedOrder = await _orderService.updateOrderStatus(orderId, newStatus);
      final orderIndex = _orders.indexWhere((order) => order.orderId == orderId);
      if (orderIndex != -1) {
        _orders[orderIndex] = updatedOrder;
      }
    } catch (e) {
      debugPrint('Error updating order status: $e');
      rethrow; // Rethrow to handle in UI
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }
} 