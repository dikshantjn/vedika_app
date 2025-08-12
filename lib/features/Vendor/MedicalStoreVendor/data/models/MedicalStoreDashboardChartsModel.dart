class MedicalStoreDashboardChartsModel {
  final List<int> dailyOrders; // e.g., last 7 days
  final List<double> dailyRevenue; // e.g., last 7 days
  final List<String> days; // labels for the above
  final Map<String, int> orderStatusCounts; // e.g., { 'Pending': 5, 'Accepted': 8, 'Delivered': 12 }
  final List<Map<String, dynamic>> regionDemand; // [{city: 'Andheri East', percentage: 32}, ...]
  final List<Map<String, dynamic>> topMedicines; // [{name: 'Paracetamol 500mg', orders: 124}, ...]
  final double deliveryCompletionRate; // 0-100

  const MedicalStoreDashboardChartsModel({
    required this.dailyOrders,
    required this.dailyRevenue,
    required this.days,
    required this.orderStatusCounts,
    required this.regionDemand,
    required this.topMedicines,
    required this.deliveryCompletionRate,
  });
}


