import 'package:flutter/foundation.dart';
import 'package:vedika_healthcare/core/auth/data/services/StorageService.dart';
import 'package:vedika_healthcare/features/Vendor/ProductPartner/data/models/ProductOrder.dart';
import 'package:vedika_healthcare/features/orderHistory/data/services/OrderHistoryService.dart';

class OrderHistoryViewModel extends ChangeNotifier {
  final OrderHistoryService _service = OrderHistoryService();
  
  List<ProductOrder> _deliveredProductOrders = [];
  bool _isLoading = false;
  String? _error;

  List<ProductOrder> get deliveredProductOrders => _deliveredProductOrders;
  bool get isLoading => _isLoading;
  String? get error => _error;

  Future<void> fetchDeliveredProductOrders() async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      String? userId = await StorageService.getUserId();
      if (userId == null) {
        throw Exception('User ID not found');
      }

      _deliveredProductOrders = await _service.fetchDeliveredProductOrders(userId);
    } catch (e) {
      _error = e.toString();
      _deliveredProductOrders = [];
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }
} 