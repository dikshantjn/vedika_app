import 'package:flutter/material.dart';
import 'package:vedika_healthcare/features/Vendor/Registration/Services/VendorLoginService.dart';
import '../../data/model/BloodBankBooking.dart';
import '../../data/services/BloodBankBookingService.dart';
import '../../../../../core/auth/data/models/UserModel.dart';

class BloodBankBookingViewModel extends ChangeNotifier {
  final BloodBankBookingService _service = BloodBankBookingService();
  final VendorLoginService _loginService = VendorLoginService();

  List<BloodBankBooking> _bookings = [];
  bool _isLoading = false;
  String? _error;

  // Getters
  List<BloodBankBooking> get bookings => _bookings;
  bool get isLoading => _isLoading;
  String? get error => _error;

  bool _isProcessing = false;
  bool _isMarkingCompleted = false;
  bool get isMarkingCompleted => _isMarkingCompleted;


  // Filtered getters
  List<BloodBankBooking> get confirmedBookings => 
      _bookings.where((booking) => 
        booking.status.toLowerCase() != 'cancelled' && 
        booking.status.toLowerCase() != 'completed'
      ).toList();
  
  List<BloodBankBooking> get completedBookings =>
      _bookings.where((booking) => booking.status.toLowerCase() == 'completed').toList();
  
  List<BloodBankBooking> get cancelledBookings =>
      _bookings.where((booking) => booking.status.toLowerCase() == 'cancelled').toList();

  // Statistics getters
  double get totalRevenue =>
      completedBookings.fold(0, (sum, booking) => sum + booking.totalAmount);

  int get totalCompletedBookings => completedBookings.length;

  double get averageBookingValue =>
      totalCompletedBookings > 0 ? totalRevenue / totalCompletedBookings : 0;

  Future<void> loadBookings() async {
    String? token = await _loginService.getVendorToken();
    String? vendorId = await _loginService.getVendorId();

    try {
      _isLoading = true;
      _error = null;
      notifyListeners();

      _bookings = await _service.getBookings(vendorId!, token!);
    } catch (e) {
      _error = 'Failed to load bookings';
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<void> processBooking(String bookingId) async {
    String? token = await _loginService.getVendorToken();
    String? vendorId = await _loginService.getVendorId();

    try {
      _isLoading = true;
      _error = null;
      notifyListeners();

      await _service.updateBookingStatus(bookingId, 'completed', token!);
      await loadBookings(); // Reload the bookings to get updated data
    } catch (e) {
      _error = 'Failed to process booking';
      throw e;
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<void> notifyUser(String bookingId, {
    String? notes,
    double? totalAmount,
    double? discount,
    int? units,
  }) async {
    try {
      _isLoading = true;
      notifyListeners();

      final token = await _loginService.getVendorToken();
      final vendorId = await _loginService.getVendorId();

      if (token == null || vendorId == null) {
        throw Exception('Vendor authentication information not found');
      }

      await _service.notifyUser(
        bookingId,
        token,
        notes: notes,
        totalAmount: totalAmount,
        discount: discount,
        units: units,
      );

      // Reload bookings after notifying
      await loadBookings();
    } catch (e) {
      _error = e.toString();
      notifyListeners();
      rethrow;
    } finally {
      _isLoading = false;
      notifyListeners();
    }
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
  
  // Get blood request details for a booking
  Map<String, dynamic>? getBloodRequestDetailsForBooking(String bookingId) {
    try {
      final booking = _bookings.firstWhere((b) => b.bookingId == bookingId);
      if (booking.bloodRequest != null) {
        return {
          'bloodTypes': booking.bloodType,
          'units': booking.bloodRequest!.units,
        };
      }
      return null;
    } catch (e) {
      return null;
    }
  }
} 