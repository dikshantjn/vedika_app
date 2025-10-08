import 'dart:typed_data';
import 'package:flutter/foundation.dart';
import 'package:vedika_healthcare/core/auth/data/services/StorageService.dart';
import 'package:vedika_healthcare/features/ambulance/data/models/AmbulanceBooking.dart';
import 'package:vedika_healthcare/features/orderHistory/data/repositories/AmbulanceOrderRepository.dart';

class AmbulanceOrderViewModel extends ChangeNotifier {
  final AmbulanceOrderRepository _repository = AmbulanceOrderRepository();

  List<AmbulanceBooking> _orders = [];
  List<AmbulanceBooking> get orders => _orders;

  bool _isLoading = false;
  bool get isLoading => _isLoading;

  String? _errorMessage;
  String? get errorMessage => _errorMessage;

  /// Load completed orders from API
  Future<void> loadCompletedOrders() async {
    String? userId = await StorageService.getUserId();

    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    try {
      _orders = await _repository.fetchCompletedOrdersByUser(userId!);
    } catch (e) {
      _errorMessage = "Failed to load completed orders";
      print("ViewModel Error: $e");
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  /// Fetch ambulance invoice bytes
  Future<Uint8List> fetchAmbulanceInvoiceBytes(String bookingId) async {
    try {
      return await _repository.fetchAmbulanceInvoiceBytes(bookingId);
    } catch (e) {
      print("ViewModel Error fetching ambulance invoice: $e");
      rethrow;
    }
  }
}
