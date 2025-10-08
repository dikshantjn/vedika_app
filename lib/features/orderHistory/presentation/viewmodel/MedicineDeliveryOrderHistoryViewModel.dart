import 'package:flutter/foundation.dart';
import 'package:vedika_healthcare/core/auth/data/services/StorageService.dart';
import 'package:vedika_healthcare/features/Vendor/MedicalStoreVendor/data/models/NewOrders/Order.dart';
import 'package:vedika_healthcare/features/orderHistory/data/services/MedicineDeliveryOrderService.dart';

class MedicineDeliveryOrderHistoryViewModel extends ChangeNotifier {
  final MedicineDeliveryOrderService _service = MedicineDeliveryOrderService();

  // List of delivered orders for the user
  List<Order> _orders = [];

  // Loading state
  bool _isLoading = false;

  // Error message
  String? _error;

  // Getter for orders
  List<Order> get orders => _orders;

  // Getter for loading state
  bool get isLoading => _isLoading;

  // Getter for error
  String? get error => _error;

  // Fetch the delivered orders for the current user
  Future<void> fetchDeliveredOrdersByUser() async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      String? userId = await StorageService.getUserId();
      if (userId == null) {
        _error = "User not found";
        _orders = [];
        return;
      }

      _orders = await _service.getDeliveredOrdersByUser(userId);
      debugPrint("Fetched ${_orders.length} delivered medicine orders");
    } catch (e) {
      _error = "Failed to fetch delivered orders: $e";
      _orders = [];
      debugPrint("Error fetching delivered medicine orders: $e");
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  // Download medicine delivery invoice
  Future<void> downloadInvoice(String orderId) async {
    try {
      await _service.downloadMedicineDeliveryInvoice(orderId);
      debugPrint("Invoice downloaded successfully for order: $orderId");
    } catch (e) {
      _error = "Failed to download invoice: $e";
      debugPrint("Error downloading invoice: $e");
      notifyListeners();
      rethrow;
    }
  }

  // Clear error
  void clearError() {
    _error = null;
    notifyListeners();
  }
}
