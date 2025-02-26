class MedicineOrder {
  final String orderNumber;
  final String date;
  final String status;
  final String items;
  final String total;
  final List<String> imageUrls;  // Changed from String to List<String>

  MedicineOrder({
    required this.orderNumber,
    required this.date,
    required this.status,
    required this.items,
    required this.total,
    required this.imageUrls,  // Pass a list of image URLs in the constructor
  });
}
