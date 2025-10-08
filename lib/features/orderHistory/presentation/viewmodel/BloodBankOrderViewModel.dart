import 'dart:typed_data';
import 'package:flutter/material.dart';
import 'package:vedika_healthcare/core/auth/data/repositories/AuthRepository.dart';
import 'package:vedika_healthcare/core/auth/data/services/StorageService.dart';
import 'package:vedika_healthcare/features/Vendor/BloodBankAgencyVendor/data/model/BloodBankBooking.dart';
import 'package:vedika_healthcare/features/orderHistory/data/repositories/BloodBankOrderRepository.dart';
import 'package:vedika_healthcare/features/orderHistory/data/services/BloodBankOrderService.dart';

class BloodBankOrderViewModel extends ChangeNotifier {
  final BloodBankOrderRepository _repository = BloodBankOrderRepository();
  final AuthRepository _authRepository = AuthRepository();
  final BloodBankOrderService _service = BloodBankOrderService();

  List<BloodBankBooking> _bookings = [];
  bool _isLoading = false;
  String? _errorMessage;

  List<BloodBankBooking> get bookings => _bookings;
  bool get isLoading => _isLoading;
  String? get errorMessage => _errorMessage;

  /// Fetch Completed Bookings
  Future<void> fetchCompletedBookings() async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    try {
      // Get user ID and token
      final userId = await StorageService.getUserId();
      final token = await _authRepository.getToken();

      if (userId == null || token == null) {
        throw Exception('User not authenticated');
      }

      _bookings = await _repository.getBloodBankOrders(userId, token);
    } catch (e) {
      _errorMessage = e.toString();
    }

    _isLoading = false;
    notifyListeners();
  }

  /// Place a New Booking
  Future<bool> placeBooking(BloodBankBooking booking) async {
    try {
      await _repository.placeBloodBankOrder(booking);
      notifyListeners();
      return true;
    } catch (e) {
      _errorMessage = "Failed to place booking.";
      notifyListeners();
      return false;
    }
  }

  /// Cancel a Booking
  Future<void> cancelBooking(String bookingId) async {
    try {
      await _repository.cancelBloodBankOrder(bookingId);
      notifyListeners();
    } catch (e) {
      _errorMessage = "Failed to cancel booking.";
      notifyListeners();
    }
  }

  /// Fetch blood bank invoice bytes
  Future<Uint8List> fetchBloodBankInvoiceBytes(String bookingId) async {
    try {
      return await _service.fetchBloodBankInvoiceBytes(bookingId);
    } catch (e) {
      print("ViewModel Error fetching blood bank invoice: $e");
      rethrow;
    }
  }
}
