import 'package:flutter/material.dart';
import '../../data/model/BloodBankBooking.dart';
import '../../data/model/BloodBankRequest.dart';
import '../../data/services/BloodBankBookingService.dart';
import '../../../../../core/auth/data/models/UserModel.dart';

class BloodBankBookingViewModel extends ChangeNotifier {
  final BloodBankBookingService _service = BloodBankBookingService();
  List<BloodBankBooking> _bookings = [];
  Map<String, BloodBankRequest> _requests = {};
  bool _isLoading = false;
  String? _error;

  // Getters
  List<BloodBankBooking> get bookings => _bookings;
  bool get isLoading => _isLoading;
  String? get error => _error;

  // Filtered getters
  List<BloodBankBooking> get completedBookings =>
      _bookings.where((booking) => booking.status == 'completed').toList();

  List<BloodBankBooking> get confirmedBookings =>
      _bookings.where((booking) => booking.status == 'confirmed').toList();

  List<BloodBankBooking> get cancelledBookings =>
      _bookings.where((booking) => booking.status == 'cancelled').toList();

  // Statistics getters
  double get totalRevenue =>
      completedBookings.fold(0, (sum, booking) => sum + booking.totalAmount);

  int get totalCompletedBookings => completedBookings.length;

  double get averageBookingValue =>
      totalCompletedBookings > 0 ? totalRevenue / totalCompletedBookings : 0;

  Future<void> loadBookings(String vendorId) async {
    try {
      _isLoading = true;
      _error = null;
      notifyListeners();

      // Load bookings
      _bookings = await _service.getBookings(vendorId);
      
      // Load requests for all bookings
      for (var booking in _bookings) {
        final request = await _service.getRequestById(booking.requestId);
        if (request != null) {
          _requests[booking.requestId] = request;
        }
      }
    } catch (e) {
      _error = 'Failed to load bookings';
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<void> updateBookingStatus(String bookingId, String status) async {
    try {
      _isLoading = true;
      _error = null;
      notifyListeners();

      await _service.updateBookingStatus(bookingId, status);
      await loadBookings('vendor1'); // Reload bookings after update
    } catch (e) {
      _error = 'Failed to update booking status';
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  BloodBankRequest? getRequestById(String requestId) {
    return _requests[requestId];
  }

  // Get user details for a booking
  UserModel? getUserDetails(String bookingId) {
    try {
      final booking = _bookings.firstWhere((b) => b.bookingId == bookingId);
      return booking.user;
    } catch (e) {
      return null;
    }
  }

  // Get booking by ID
  BloodBankBooking? getBookingById(String bookingId) {
    try {
      return _bookings.firstWhere((b) => b.bookingId == bookingId);
    } catch (e) {
      return null;
    }
  }
} 