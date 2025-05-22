import 'package:flutter/material.dart';
import 'package:vedika_healthcare/features/Vendor/AmbulanceAgencyVendor/data/services/AmbulanceBookingService.dart';
import 'package:vedika_healthcare/features/Vendor/Registration/Services/VendorLoginService.dart';
import 'package:vedika_healthcare/features/ambulance/data/models/AmbulanceBooking.dart';
import 'package:vedika_healthcare/features/Vendor/AmbulanceAgencyVendor/data/modals/AmbulanceAgency.dart';
import 'package:vedika_healthcare/features/Vendor/AmbulanceAgencyVendor/data/services/AmbulanceAgencyService.dart';

class AgencyDashboardViewModel extends ChangeNotifier {
  final _bookingService = AmbulanceBookingService();
  final _loginService = VendorLoginService();
  final _agencyService = AmbulanceAgencyService();

  AmbulanceAgency? _agencyProfile;
  AmbulanceAgency? get agencyProfile => _agencyProfile;

  int _totalBookings = 0;
  int get totalBookings => _totalBookings;

  int _todaysBookings = 0;
  int get todaysBookings => _todaysBookings;

  int _avgResponseTime = 0;
  int get avgResponseTime => _avgResponseTime;

  double _operationalKms = 0.0;
  double get operationalKms => _operationalKms;

  Map<String, double> _vehicleStats = {
    "BLS": 40.0,
    "ALS": 70.0,
    "ICU": 50.0,
    "Air": 30.0,
    "Train": 10.0,
  };
  Map<String, double> get vehicleStats => _vehicleStats;

  List<AmbulanceBooking> _pendingBookings = [];
  List<AmbulanceBooking> get pendingBookings => _pendingBookings;

  AgencyDashboardViewModel() {
    fetchDashboardData();
    fetchPendingBookings();
    fetchAgencyProfile();
  }

  Future<void> fetchAgencyProfile() async {
    try {
      String? vendorId = await _loginService.getVendorId();
      if (vendorId != null) {
        _agencyProfile = await _agencyService.getAgencyProfile(vendorId);
        notifyListeners();
      }
    } catch (e) {
      print("Error fetching agency profile: $e");
    }
  }

  void fetchDashboardData() {
    _totalBookings = 120;
    _todaysBookings = 8;
    _avgResponseTime = 12;
    _operationalKms = 20.7;
    notifyListeners();
  }

  Future<void> fetchPendingBookings() async {
    String? vendorId = await _loginService.getVendorId();
    try {
      if (vendorId != null) {
        final bookings = await _bookingService.getPendingBookings(vendorId);
        _pendingBookings = bookings;
        notifyListeners();
      }
    } catch (e) {
      print("Error fetching bookings: $e");
    }
  }

  Future<void> refreshDashboardData() async {
    await Future.delayed(const Duration(milliseconds: 600));
    fetchDashboardData();
    await fetchPendingBookings();
    await fetchAgencyProfile();
  }
}
