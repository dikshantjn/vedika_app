import 'dart:math';

class AmbulanceAgencyAnalyticsService {
  // Mock analytics data for dashboard
  static Future<Map<String, dynamic>> getAnalytics(String timeFilter) async {
    await Future.delayed(const Duration(milliseconds: 400));

    final random = Random(42);

    // Users and usage
    final int usersAcquired = 1542;
    final int dau = 286;
    final int mau = 1248;
    final int returningCustomers = 432;
    final double returningRate = mau == 0 ? 0 : (returningCustomers / mau) * 100;

    // Cancellations & times
    final double cancellationRate = 7.8; // %
    final int avgPickupTimeMin = 12; // minutes
    final int timeToAcceptSec = 38; // seconds

    // Trips & revenue
    final int tripsBooked = 368;
    final double revenue = 485000.0; // INR

    // Repeat usage & attrition
    final int repeatUsage = 196;
    final double attritionRate = 4.2; // %

    // Demand vs scheduled
    final int emergency = 248;
    final int scheduled = 120;

    // Seasonal trends (accident/incident peaks): months vs count
    final List<Map<String, dynamic>> seasonalTrends = [
      {'month': 'Jan', 'incidents': 28},
      {'month': 'Feb', 'incidents': 31},
      {'month': 'Mar', 'incidents': 34},
      {'month': 'Apr', 'incidents': 29},
      {'month': 'May', 'incidents': 42},
      {'month': 'Jun', 'incidents': 48},
      {'month': 'Jul', 'incidents': 51},
      {'month': 'Aug', 'incidents': 47},
      {'month': 'Sep', 'incidents': 40},
      {'month': 'Oct', 'incidents': 36},
      {'month': 'Nov', 'incidents': 33},
      {'month': 'Dec', 'incidents': 38},
    ];

    // Area-based requests (demand) and oversupply mapping
    final List<Map<String, dynamic>> areaDemand = [
      {'area': 'Hinjewadi', 'requests': 64},
      {'area': 'Kharadi', 'requests': 52},
      {'area': 'Hadapsar', 'requests': 44},
      {'area': 'Kothrud', 'requests': 38},
      {'area': 'Baner', 'requests': 29},
    ];
    final List<Map<String, dynamic>> oversupply = [
      {'area': 'Pimple Saudagar', 'excess': 22},
      {'area': 'Wakad', 'excess': 15},
      {'area': 'Aundh', 'excess': 12},
    ];

    // DAU/MAU weekly pattern (usage)
    final List<Map<String, dynamic>> dauMauPattern = [
      {'day': 'Mon', 'dau': 260, 'mau': 1200},
      {'day': 'Tue', 'dau': 275, 'mau': 1210},
      {'day': 'Wed', 'dau': 300, 'mau': 1220},
      {'day': 'Thu', 'dau': 280, 'mau': 1230},
      {'day': 'Fri', 'dau': 295, 'mau': 1240},
      {'day': 'Sat', 'dau': 310, 'mau': 1245},
      {'day': 'Sun', 'dau': 320, 'mau': 1248},
    ];

    return {
      'usersAcquired': usersAcquired,
      'dau': dau,
      'mau': mau,
      'returningCustomers': returningCustomers,
      'returningRate': double.parse(returningRate.toStringAsFixed(1)),
      'cancellationRate': cancellationRate,
      'avgPickupTimeMin': avgPickupTimeMin,
      'timeToAcceptSec': timeToAcceptSec,
      'tripsBooked': tripsBooked,
      'revenue': revenue,
      'repeatUsage': repeatUsage,
      'attritionRate': attritionRate,
      'emergency': emergency,
      'scheduled': scheduled,
      'seasonalTrends': seasonalTrends,
      'areaDemand': areaDemand,
      'oversupply': oversupply,
      'dauMauPattern': dauMauPattern,
    };
  }
}


