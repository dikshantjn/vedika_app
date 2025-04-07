import 'package:get/get.dart';

class AgencyDashboardViewModel extends GetxController {
  // Live Requests
  var liveRequests = <Map<String, String>>[].obs;

  // Summary counts
  var totalBookings = 0.obs;
  var todaysBookings = 0.obs;

  // New stats for response time and kms
  var avgResponseTime = 0.obs; // in minutes
  var operationalKms = 0.0.obs; // in kilometers

  // Analytics data (Vehicle type bookings)
  var vehicleStats = {
    "BLS": 40.0,
    "ALS": 70.0,
    "ICU": 50.0,
    "Air": 30.0,
    "Train": 10.0,
  }.obs;

  @override
  void onInit() {
    super.onInit();
    fetchDashboardData();
  }

  void fetchDashboardData() {
    // Simulate fetching from API/database
    liveRequests.assignAll([
      {
        "title": "ICU Ambulance Required",
        "route": "Kothrud → Pune Station"
      },
      {
        "title": "Air Ambulance Emergency",
        "route": "Nashik → Mumbai"
      },
      {
        "title": "Train Ambulance Needed",
        "route": "Solapur → Pune"
      },
    ]);

    totalBookings.value = 120;
    todaysBookings.value = 8;

    avgResponseTime.value = 12; // in minutes
    operationalKms.value = 325.7; // in kilometers

    vehicleStats["BLS"] = 40;
    vehicleStats["ALS"] = 70;
    vehicleStats["ICU"] = 50;
    vehicleStats["Air"] = 30;
    vehicleStats["Train"] = 10;
  }
}
