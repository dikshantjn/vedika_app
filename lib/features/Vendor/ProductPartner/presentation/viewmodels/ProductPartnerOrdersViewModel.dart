import 'package:flutter/material.dart';
import 'package:dio/dio.dart';
import '../../data/services/ProductPartnerOrderService.dart';
import '../../data/models/ProductOrder.dart';

class ProductPartnerOrdersViewModel extends ChangeNotifier {
  final ProductPartnerOrderService _orderService;
  List<ProductOrder> _orders = [];
  List<ProductOrder> _deliveredOrders = [];
  bool _isLoading = false;
  String? _error;

  ProductPartnerOrdersViewModel(this._orderService);

  List<ProductOrder> get orders => _orders;
  List<ProductOrder> get deliveredOrders => _deliveredOrders;
  bool get isLoading => _isLoading;
  String? get error => _error;

  Future<void> fetchOrders(String vendorId) async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      _orders = await _orderService.getPendingOrdersByVendorId(vendorId);
    } catch (e) {
      _error = e.toString();
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<void> fetchConfirmedOrders(String vendorId) async {
    try {
      final confirmedOrders = await _orderService.getConfirmedOrdersByVendorId(vendorId);
      _orders.addAll(confirmedOrders);
      notifyListeners();
    } catch (e) {
      _error = e.toString();
      notifyListeners();
    }
  }

  Future<void> fetchDeliveredOrders(String vendorId) async {
    try {
      _deliveredOrders = await _orderService.getDeliveredOrdersByVendorId(vendorId);
      notifyListeners();
    } catch (e) {
      _error = e.toString();
      notifyListeners();
    }
  }

  Future<void> updateOrderStatus(String orderId, String status) async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      final updatedOrder = await _orderService.updateOrderStatus(orderId, status);
      
      // Update the order in the appropriate list
      if (status == 'delivered') {
        // Remove from orders list and add to delivered orders
        _orders.removeWhere((order) => order.orderId == orderId);
        _deliveredOrders.add(updatedOrder);
      } else {
        // Update in orders list
        final index = _orders.indexWhere((order) => order.orderId == orderId);
        if (index != -1) {
          _orders[index] = updatedOrder;
        }
      }
    } catch (e) {
      _error = e.toString();
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }
} 