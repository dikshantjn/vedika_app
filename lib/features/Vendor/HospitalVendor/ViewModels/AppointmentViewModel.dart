import 'package:flutter/material.dart';
import 'package:vedika_healthcare/core/constants/ApiEndpoints.dart';
import 'package:vedika_healthcare/features/Vendor/Registration/Services/VendorLoginService.dart';
import 'package:vedika_healthcare/features/hospital/presentation/models/BedBooking.dart';
import 'package:vedika_healthcare/features/Vendor/HospitalVendor/Services/HospitalVendorService.dart';
import 'package:dio/dio.dart';

class AppointmentViewModel extends ChangeNotifier {
  List<BedBooking> _appointments = [];
  bool _isLoading = false;
  String? _error;

  List<BedBooking> get appointments => _appointments;
  bool get isLoading => _isLoading;
  String? get error => _error;

  final Dio _dio = Dio();
  final HospitalVendorService _hospitalService = HospitalVendorService();

  Future<void> fetchAppointments() async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      // TODO: Replace with actual vendor ID from storage or auth
      String? vendorId = await VendorLoginService().getVendorId();
      _appointments = await _hospitalService.getHospitalBookingsByVendor(vendorId!);
    } catch (e) {
      _error = 'Failed to fetch bookings: $e';
    }

    _isLoading = false;
    notifyListeners();
  }

  Future<void> acceptAppointment(String bookingId) async {
    try {
      await _hospitalService.acceptAppointment(bookingId);
      await fetchAppointments();
    } catch (e) {
      _error = 'Failed to accept booking: $e';
      notifyListeners();
    }
  }

  Future<void> notifyUserPayment(String bookingId) async {
    try {
      await _hospitalService.notifyUserPayment(bookingId);
      await fetchAppointments();
    } catch (e) {
      _error = 'Failed to notify user: $e';
      notifyListeners();
    }
  }
} 