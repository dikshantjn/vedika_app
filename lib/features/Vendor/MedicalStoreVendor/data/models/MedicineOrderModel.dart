class MedicineOrderModel {
  final int orderId;
  final int prescriptionId;  // Change prescriptionId to int
  final String userId;
  final String vendorId;
  final String orderStatus;
  final DateTime createdAt;
  final double totalAmount;

  MedicineOrderModel({
    required this.orderId,
    required this.prescriptionId,  // Accept prescriptionId as int
    required this.userId,
    required this.vendorId,
    required this.orderStatus,
    required this.createdAt,
    required this.totalAmount,
  });

  factory MedicineOrderModel.fromJson(Map<String, dynamic> json) {
    return MedicineOrderModel(
      orderId: json['orderId'],
      prescriptionId: json['prescriptionId'],  // Keep it as int
      userId: json['userId'],
      vendorId: json['vendorId'],
      orderStatus: json['orderStatus'],
      createdAt: DateTime.parse(json['createdAt']),
      totalAmount: json['totalAmount']?.toDouble() ?? 0.0,  // Handle missing or incorrect type
    );
  }

  Map<String, dynamic> toJson() {
    return {
      "orderId": orderId,
      "prescriptionId": prescriptionId,  // Store prescriptionId as int
      "userId": userId,
      "vendorId": vendorId,
      "orderStatus": orderStatus,
      "createdAt": createdAt.toIso8601String(),
      "totalAmount": totalAmount,
    };
  }
}
