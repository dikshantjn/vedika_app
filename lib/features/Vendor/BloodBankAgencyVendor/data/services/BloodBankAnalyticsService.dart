class BloodBankAnalyticsService {
  static Future<Map<String, dynamic>> getAnalytics(String timeFilter) async {
    await Future.delayed(const Duration(milliseconds: 400));

    // Order & Demand Tracking
    final int totalRequests = 842;
    final int confirmed = 612;
    final int declined = 230;
    final List<Map<String, dynamic>> topDemand = [
      {'type': 'O+', 'count': 220},
      {'type': 'B+', 'count': 195},
      {'type': 'A+', 'count': 170},
    ];
    final List<Map<String, dynamic>> leastDemand = [
      {'type': 'AB-', 'count': 8},
      {'type': 'O-', 'count': 14},
      {'type': 'A-', 'count': 22},
    ];
    final List<Map<String, dynamic>> regionRequests = [
      {'region': 'Hinjewadi', 'requests': 96},
      {'region': 'Kharadi', 'requests': 80},
      {'region': 'Hadapsar', 'requests': 74},
      {'region': 'Kothrud', 'requests': 66},
      {'region': 'Baner', 'requests': 52},
    ];
    final List<Map<String, dynamic>> excessDemandAlerts = [
      {'type': 'O-', 'gap': 18},
      {'type': 'B-', 'gap': 12},
    ];

    // Time & Service Performance
    final int avgTimeToConfirmMin = 11; // minutes
    final int avgTimeToFulfillmentMin = 95; // minutes
    final Map<String, double> pickupVsDelivery = {'pickup': 62.0, 'delivery': 38.0};
    final int selfPickAvgWaitMin = 14;
    final int homeDeliveryAvgMin = 78;

    // Seasonal & Event-Based Insights
    final List<Map<String, dynamic>> seasonalTrends = [
      {'month': 'Jan', 'incidents': 38},
      {'month': 'Feb', 'incidents': 35},
      {'month': 'Mar', 'incidents': 41},
      {'month': 'Apr', 'incidents': 39},
      {'month': 'May', 'incidents': 52},
      {'month': 'Jun', 'incidents': 58},
      {'month': 'Jul', 'incidents': 61},
      {'month': 'Aug', 'incidents': 57},
      {'month': 'Sep', 'incidents': 49},
      {'month': 'Oct', 'incidents': 44},
      {'month': 'Nov', 'incidents': 40},
      {'month': 'Dec', 'incidents': 46},
    ];
    final List<Map<String, dynamic>> monthlyTrendsByType = [
      {'type': 'O+', 'monthly': [18,20,22,19,26,30,31,29,24,22,20,21]},
      {'type': 'B+', 'monthly': [16,18,19,18,22,25,27,26,23,20,19,18]},
      {'type': 'A+', 'monthly': [15,16,18,17,21,23,24,23,21,19,18,17]},
    ];

    // Inventory & Readiness
    final List<Map<String, dynamic>> stockByType = [
      {'type': 'O+', 'units': 36},
      {'type': 'B+', 'units': 28},
      {'type': 'A+', 'units': 24},
      {'type': 'AB+', 'units': 12},
      {'type': 'O-', 'units': 6},
      {'type': 'A-', 'units': 8},
      {'type': 'B-', 'units': 7},
      {'type': 'AB-', 'units': 3},
    ];
    final int lowStockThreshold = 10;
    final List<String> fastMovingTypes = ['O+', 'B+', 'A+'];
    final List<String> oversupplyWarnings = ['AB+', 'B+'];

    // Customer Insights
    final Map<String, int> repeatBuyers = {'30d': 48, '60d': 76, '90d': 101};
    final List<Map<String, dynamic>> topRegionsServed = [
      {'region': 'Hinjewadi', 'requests': 96},
      {'region': 'Kharadi', 'requests': 80},
      {'region': 'Hadapsar', 'requests': 74},
      {'region': 'Kothrud', 'requests': 66},
    ];

    return {
      'totalRequests': totalRequests,
      'confirmed': confirmed,
      'declined': declined,
      'topDemand': topDemand,
      'leastDemand': leastDemand,
      'regionRequests': regionRequests,
      'excessDemandAlerts': excessDemandAlerts,
      'avgTimeToConfirmMin': avgTimeToConfirmMin,
      'avgTimeToFulfillmentMin': avgTimeToFulfillmentMin,
      'pickupVsDelivery': pickupVsDelivery,
      'selfPickAvgWaitMin': selfPickAvgWaitMin,
      'homeDeliveryAvgMin': homeDeliveryAvgMin,
      'seasonalTrends': seasonalTrends,
      'monthlyTrendsByType': monthlyTrendsByType,
      'stockByType': stockByType,
      'lowStockThreshold': lowStockThreshold,
      'fastMovingTypes': fastMovingTypes,
      'oversupplyWarnings': oversupplyWarnings,
      'repeatBuyers': repeatBuyers,
      'topRegionsServed': topRegionsServed,
    };
  }
}


