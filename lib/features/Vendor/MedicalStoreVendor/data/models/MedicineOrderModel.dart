import 'package:vedika_healthcare/core/auth/data/models/UserModel.dart';
import 'package:vedika_healthcare/features/Vendor/MedicalStoreVendor/data/models/CartModel.dart';

class MedicineOrderModel {
  final String orderId; // ✅ Order ID remains a String
  final String prescriptionId; // ✅ Changed from int to String
  final String userId;
  final String vendorId;
  final String orderStatus;
  final DateTime createdAt;
  final double totalAmount;
  final UserModel user;
  final List<CartModel> orderItems;

  MedicineOrderModel({
    required this.orderId,
    required this.prescriptionId,
    required this.userId,
    required this.vendorId,
    required this.orderStatus,
    required this.createdAt,
    required this.totalAmount,
    required this.user,
    required this.orderItems,
  });

  factory MedicineOrderModel.fromJson(Map<String, dynamic> json) {
    return MedicineOrderModel(
      orderId: json['orderId'] ?? 'ORD-UNKNOWN',
      prescriptionId: json['prescriptionId'] ?? '', // ✅ Now handles prescriptionId as String
      userId: json['userId'] ?? '',
      vendorId: json['vendorId'] ?? '',
      orderStatus: json['orderStatus'] ?? 'Unknown',
      createdAt: json['createdAt'] != null ? DateTime.parse(json['createdAt']) : DateTime.now(),
      totalAmount: (json['totalAmount'] as num?)?.toDouble() ?? 0.0,
      user: json['User'] != null ? UserModel.fromJson(json['User']) : UserModel.empty(),
      orderItems: (json['orderItems'] as List?)?.map((e) => CartModel.fromJson(e)).toList() ?? [],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      "orderId": orderId,
      "prescriptionId": prescriptionId, // ✅ Now correctly serialized as String
      "userId": userId,
      "vendorId": vendorId,
      "orderStatus": orderStatus,
      "createdAt": createdAt.toIso8601String(),
      "totalAmount": totalAmount,
      "user": user.toJson(),
      "orderItems": orderItems.map((e) => e.toJson()).toList(),
    };
  }
}
