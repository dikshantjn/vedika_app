class AmbulanceOrder {
  final String orderNumber;
  final String date;
  final String status;
  final String serviceType;
  final String total;
  final List<String> imageUrls;

  AmbulanceOrder({
    required this.orderNumber,
    required this.date,
    required this.status,
    required this.serviceType,
    required this.total,
    required this.imageUrls,
  });
}
