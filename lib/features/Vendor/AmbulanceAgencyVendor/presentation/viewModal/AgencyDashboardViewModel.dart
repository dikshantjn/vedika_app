import 'package:get/get.dart';
import 'package:vedika_healthcare/features/Vendor/AmbulanceAgencyVendor/data/services/AmbulanceBookingService.dart';
import 'package:vedika_healthcare/features/Vendor/Registration/Services/VendorLoginService.dart';
import 'package:vedika_healthcare/features/ambulance/data/models/AmbulanceBooking.dart';

class AgencyDashboardViewModel extends GetxController {
  var liveRequests = <Map<String, String>>[].obs;

  var totalBookings = 0.obs;
  var todaysBookings = 0.obs;
  var avgResponseTime = 0.obs;
  var operationalKms = 0.0.obs;

  var vehicleStats = <String, double>{
    "BLS": 40.0,
    "ALS": 70.0,
    "ICU": 50.0,
    "Air": 30.0,
    "Train": 10.0,
  }.obs;

  var pendingBookings = <AmbulanceBooking>[].obs;

  final _bookingService = AmbulanceBookingService(); // Use your actual service
  final _loginService = VendorLoginService();        // Use your actual login service

  @override
  void onInit() {
    super.onInit();
    fetchDashboardData();
    fetchPendingBookings();
  }

  void fetchDashboardData() {
    liveRequests.assignAll([
      {"title": "ICU Ambulance Required"},
      {"title": "Air Ambulance Emergency"},
      {"title": "Train Ambulance Needed"},
    ]);

    totalBookings.value = 120;
    todaysBookings.value = 8;
    avgResponseTime.value = 12;
    operationalKms.value = 20.7;
  }

  Future<void> fetchPendingBookings() async {
    String? vendorId = await _loginService.getVendorId();
    try {
      final bookings = await _bookingService.getPendingBookings(vendorId!);
      pendingBookings.assignAll(bookings);
    } catch (e) {
      print("Error fetching bookings: $e");
    }
  }

  /// 🔄 Use this inside RefreshIndicator to refresh all dashboard data
  Future<void> refreshDashboardData() async {
    await Future.delayed(const Duration(milliseconds: 600)); // optional delay
    fetchDashboardData();
    await fetchPendingBookings();
  }
}
