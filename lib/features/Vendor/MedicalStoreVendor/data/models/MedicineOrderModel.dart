import 'package:vedika_healthcare/core/auth/data/models/UserModel.dart';
import 'package:vedika_healthcare/features/Vendor/MedicalStoreVendor/data/models/CartModel.dart';

class MedicineOrderModel {
  final int orderId;
  final int prescriptionId;
  final String userId;
  final String vendorId;
  final String orderStatus;
  final DateTime createdAt;
  final double totalAmount;
  final UserModel user;
  final List<CartModel> orderItems; // ✅ Added orderItems

  MedicineOrderModel({
    required this.orderId,
    required this.prescriptionId,
    required this.userId,
    required this.vendorId,
    required this.orderStatus,
    required this.createdAt,
    required this.totalAmount,
    required this.user,
    required this.orderItems, // ✅ Added to constructor
  });

  factory MedicineOrderModel.fromJson(Map<String, dynamic> json) {
    return MedicineOrderModel(
      orderId: json['orderId'] != null ? json['orderId'] : 0,  // Handle null for orderId
      prescriptionId: json['prescriptionId'] != null ? json['prescriptionId'] : 0, // Handle null for prescriptionId
      userId: json['userId'] ?? '',  // Ensure userId is not null
      vendorId: json['vendorId'] ?? '',  // Default to empty string if null
      orderStatus: json['orderStatus'] ?? 'Unknown',  // Default to 'Unknown' if null
      createdAt: json['createdAt'] != null ? DateTime.parse(json['createdAt']) : DateTime.now(),  // Default to current date if null
      totalAmount: json['totalAmount'] != null ? (json['totalAmount']?.toDouble() ?? 0.0) : 0.0,  // Ensure it's parsed correctly
      user: json['User'] != null ? UserModel.fromJson(json['User']) : UserModel.empty(),  // Handle null User model
      orderItems: (json['orderItems'] as List?)?.map((e) => CartModel.fromJson(e)).toList() ?? [],  // Deserialize safely
    );
  }

  Map<String, dynamic> toJson() {
    return {
      "orderId": orderId,
      "prescriptionId": prescriptionId,
      "userId": userId,
      "vendorId": vendorId,
      "orderStatus": orderStatus,
      "createdAt": createdAt.toIso8601String(),
      "totalAmount": totalAmount,
      "user": user.toJson(),
      "orderItems": orderItems.map((e) => e.toJson()).toList(),  // Serialize orderItems
    };
  }
}
