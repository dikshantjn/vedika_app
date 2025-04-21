// ViewModel: BedBookingOrderViewModel.dart
import 'package:flutter/material.dart';
import 'package:vedika_healthcare/features/hospital/presentation/models/BedBooking.dart';
import 'package:vedika_healthcare/features/orderHistory/data/services/BedBookingOrderService.dart';

class BedBookingOrderViewModel extends ChangeNotifier {
  final BedBookingOrderService _service = BedBookingOrderService();
  List<BedBooking> _orders = [];
  bool _isLoading = false;
  String? _error;

  List<BedBooking> get orders => _orders;
  bool get isLoading => _isLoading;
  String? get error => _error;

  Future<void> fetchAppointments(String userId) async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      _orders = await _service.getCompletedAppointmentsByUser(userId);
    } catch (e) {
      _error = 'Failed to fetch appointments: $e';
    }

    _isLoading = false;
    notifyListeners();
  }
}