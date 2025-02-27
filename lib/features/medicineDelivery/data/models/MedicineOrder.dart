class MedicineOrder {
  final String orderId;
  final String userId;
  final String prescriptionUrl;
  final String status;
  final double totalAmount;

  MedicineOrder({required this.orderId, required this.userId, required this.prescriptionUrl, required this.status, required this.totalAmount});

  factory MedicineOrder.fromJson(Map<String, dynamic> json) {
    return MedicineOrder(
      orderId: json['orderId'],
      userId: json['userId'],
      prescriptionUrl: json['prescriptionUrl'],
      status: json['status'],
      totalAmount: json['totalAmount'].toDouble(),
    );
  }
}
