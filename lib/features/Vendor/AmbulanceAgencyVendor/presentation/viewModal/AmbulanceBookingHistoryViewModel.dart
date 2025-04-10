import 'package:flutter/material.dart';
import 'package:vedika_healthcare/features/Vendor/AmbulanceAgencyVendor/data/services/AmbulanceBookingHistoryService.dart';
import 'package:vedika_healthcare/features/Vendor/Registration/Services/VendorLoginService.dart';
import 'package:vedika_healthcare/features/ambulance/data/models/AmbulanceBooking.dart';

class AmbulanceBookingHistoryViewModel extends ChangeNotifier {
  List<AmbulanceBooking> bookingHistory = [];
  bool isLoading = false;
  String? errorMessage;
  final VendorLoginService _loginService = VendorLoginService();

  // ✅ Fetch Completed Booking History by Vendor
  Future<void> fetchBookingHistory() async {
    String? vendorId = await _loginService.getVendorId();

    isLoading = true;
    errorMessage = null;
    notifyListeners();

    try {
      bookingHistory =
      await AmbulanceBookingHistoryService.getCompletedRequestsByVendor(vendorId!);
    } catch (e) {
      errorMessage = e.toString();
    } finally {
      isLoading = false;
      notifyListeners();
    }
  }
}
