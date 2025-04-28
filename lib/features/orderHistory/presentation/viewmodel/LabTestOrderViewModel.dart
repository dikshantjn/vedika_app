import 'package:flutter/material.dart';
import 'package:vedika_healthcare/features/Vendor/LabTest/data/models/LabTestBooking.dart';
import 'package:vedika_healthcare/features/orderHistory/data/services/LabTestOrderService.dart';

class LabTestOrderViewModel extends ChangeNotifier {
  final LabTestOrderService _service = LabTestOrderService();
  List<LabTestBooking> _orders = [];
  bool _isLoading = false;
  String? _error;

  List<LabTestBooking> get orders => _orders;
  bool get isLoading => _isLoading;
  String? get error => _error;

  Future<void> fetchCompletedLabTestOrders(String userId) async {
    try {
      _isLoading = true;
      _error = null;
      notifyListeners();

      _orders = await _service.getCompletedLabTestOrders(userId);
      _isLoading = false;
      notifyListeners();
    } catch (e) {
      _isLoading = false;
      _error = e.toString();
      notifyListeners();
    }
  }
} 