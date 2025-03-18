class MedicalStoreAnalyticsModel {
  final int totalOrders;
  final int averageOrderValue;
  final int ordersToday;
  final int returnsThisWeek;

  MedicalStoreAnalyticsModel({
    required this.totalOrders,
    required this.averageOrderValue,
    required this.ordersToday,
    required this.returnsThisWeek,
  });
}
