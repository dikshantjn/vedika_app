class MedicineReturnRequestModel {
  final String orderId;
  final String customerName;
  final String status;
  final DateTime createdAt;  // Added createdAt

  MedicineReturnRequestModel({required this.orderId, required this.customerName, required this.status, required this.createdAt});
}