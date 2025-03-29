import 'package:flutter/material.dart';
import 'package:vedika_healthcare/core/auth/data/services/StorageService.dart';
import 'package:vedika_healthcare/features/TrackOrder/data/Services/TrackOrderService.dart';
import 'package:vedika_healthcare/features/Vendor/MedicalStoreVendor/data/models/MedicineOrderModel.dart';

class TrackOrderViewModel extends ChangeNotifier {
  final TrackOrderService _service = TrackOrderService(); // Initialized internally
  List<MedicineOrderModel> _orders = [];
  bool _isLoading = false;
  String? _error;

  List<MedicineOrderModel> get orders => _orders;
  bool get isLoading => _isLoading;
  String? get error => _error;

  TrackOrderViewModel();

  Future<void> fetchOrders() async {
    String? userId = await StorageService.getUserId();

    _isLoading = true;
    notifyListeners();

    try {
      _orders = await _service.fetchUserOrders();
      _error = null;
    } catch (e) {
      _error = 'Failed to fetch orders: ${e.toString()}';
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<void> updateOrderStatus(String orderId, String status) async {
    try {
      final updatedOrder = await _service.updateOrderStatus(orderId,status);
      final index = _orders.indexWhere((o) => o.orderId == orderId);
      if (index != -1) {
        _orders[index] = updatedOrder;
        notifyListeners();
      }
    } catch (e) {
      _error = 'Failed to update order status: ${e.toString()}';
      notifyListeners();
    }
  }

  void clearError() {
    _error = null;
    notifyListeners();
  }
}
