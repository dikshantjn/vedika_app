import 'package:flutter/material.dart';
import 'package:vedika_healthcare/features/orderHistory/data/models/BloodBankOrder.dart';
import 'package:vedika_healthcare/features/orderHistory/data/repositories/BloodBankOrderRepository.dart';

class BloodBankOrderViewModel extends ChangeNotifier {
  final BloodBankOrderRepository _repository = BloodBankOrderRepository();

  List<BloodBankOrder> _orders = [];
  bool _isLoading = false;
  String? _errorMessage;

  List<BloodBankOrder> get orders => _orders;
  bool get isLoading => _isLoading;
  String? get errorMessage => _errorMessage;

  /// Fetch Orders
  Future<void> fetchOrders(String userId) async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    try {
      _orders = await _repository.getBloodBankOrders(userId);
    } catch (e) {
      _errorMessage = "Failed to load orders.";
    }

    _isLoading = false;
    notifyListeners();
  }

  /// Place a New Order
  Future<bool> placeOrder(BloodBankOrder order) async {
    try {
      await _repository.placeBloodBankOrder(order);
      _orders.add(order);
      notifyListeners();
      return true;
    } catch (e) {
      _errorMessage = "Failed to place order.";
      notifyListeners();
      return false;
    }
  }

  /// Cancel an Order
  Future<void> cancelOrder(String orderId) async {
    try {
      await _repository.cancelBloodBankOrder(orderId);
      _orders.removeWhere((order) => order.orderId == orderId);
      notifyListeners();
    } catch (e) {
      _errorMessage = "Failed to cancel order.";
      notifyListeners();
    }
  }
}
