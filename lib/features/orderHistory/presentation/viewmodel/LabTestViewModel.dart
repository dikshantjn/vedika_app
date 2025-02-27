import 'package:flutter/material.dart';
import 'package:vedika_healthcare/features/orderHistory/data/models/LabTestOrder.dart';
import 'package:vedika_healthcare/features/orderHistory/data/repositories/LabTestRepository.dart';

class LabTestViewModel extends ChangeNotifier {
  final LabTestRepository _repository = LabTestRepository();
  List<LabTestOrder> _labTestOrders = [];
  bool _isLoading = false;

  List<LabTestOrder> get labTestOrders => _labTestOrders;
  bool get isLoading => _isLoading;

  // Fetch lab test orders from the repository
  Future<void> fetchLabTestOrders() async {
    _isLoading = true;
    notifyListeners();

    try {
      _labTestOrders = await _repository.fetchLabTestOrders();
    } catch (e) {
      print("Error fetching lab test orders: $e");
    }

    _isLoading = false;
    notifyListeners();
  }
}
