class MedicalStoreInsightsModel {
  final int totalOrdersReceived;
  final int ordersConfirmed;
  final String avgTimeToFulfillPrescription; // e.g., "2h 45m"
  final String mostOrderedMedicine; // e.g., "Paracetamol 500mg"
  final int unavailableRequestsThisWeek;
  final String topRegionOfDemand; // e.g., "Andheri East, Mumbai"
  final double revenueThisMonth; // e.g., 245000.00
  final int fastMovingMedicineCount;
  final int repeatBuyers30Days;
  final double deliveryCompletionRate; // percentage 0-100

  const MedicalStoreInsightsModel({
    required this.totalOrdersReceived,
    required this.ordersConfirmed,
    required this.avgTimeToFulfillPrescription,
    required this.mostOrderedMedicine,
    required this.unavailableRequestsThisWeek,
    required this.topRegionOfDemand,
    required this.revenueThisMonth,
    required this.fastMovingMedicineCount,
    required this.repeatBuyers30Days,
    required this.deliveryCompletionRate,
  });
}


