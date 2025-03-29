import 'package:vedika_healthcare/core/auth/data/models/UserModel.dart';
import 'package:vedika_healthcare/features/Vendor/MedicalStoreVendor/data/models/CartModel.dart';

class MedicineOrderModel {
  final String orderId;
  final String prescriptionId;
  final String userId;
  final String vendorId;
  final String? addressId; // ✅ Added Address ID
  final String? appliedCoupon; // ✅ Added Coupon
  final double discountAmount; // ✅ Added Discount Amount
  final double subtotal; // ✅ Added Subtotal
  final double totalAmount;
  final String orderStatus;
  final String? paymentMethod; // ✅ Added Payment Method
  final String? transactionId; // ✅ Added Transaction ID
  final String paymentStatus; // ✅ Payment Status (Paid, Unpaid, Failed, Refunded)
  final String deliveryStatus; // ✅ Delivery Status (Pending, Out for Delivery, Delivered, Returned)
  final DateTime? estimatedDeliveryDate; // ✅ Estimated Delivery Date
  final String? trackingId; // ✅ Tracking ID for shipment
  final DateTime createdAt;
  final DateTime updatedAt;
  final UserModel user;
  final List<CartModel> orderItems;

  MedicineOrderModel({
    required this.orderId,
    required this.prescriptionId,
    required this.userId,
    required this.vendorId,
    this.addressId,
    this.appliedCoupon,
    required this.discountAmount,
    required this.subtotal,
    required this.totalAmount,
    required this.orderStatus,
    this.paymentMethod,
    this.transactionId,
    required this.paymentStatus,
    required this.deliveryStatus,
    this.estimatedDeliveryDate,
    this.trackingId,
    required this.createdAt,
    required this.updatedAt,
    required this.user,
    required this.orderItems,
  });

  factory MedicineOrderModel.fromJson(Map<String, dynamic> json) {
    return MedicineOrderModel(
      orderId: json['orderId'] ?? 'ORD-UNKNOWN',
      prescriptionId: json['prescriptionId'] ?? '',
      userId: json['userId'] ?? '',
      vendorId: json['vendorId'] ?? '',
      addressId: json['addressId'],
      appliedCoupon: json['appliedCoupon'],
      discountAmount: (json['discountAmount'] as num?)?.toDouble() ?? 0.0,
      subtotal: (json['subtotal'] as num?)?.toDouble() ?? 0.0,
      totalAmount: (json['totalAmount'] as num?)?.toDouble() ?? 0.0,
      orderStatus: json['orderStatus'] ?? 'Pending',
      paymentMethod: json['paymentMethod'],
      transactionId: json['transactionId'],
      paymentStatus: json['paymentStatus'] ?? 'Unpaid',
      deliveryStatus: json['deliveryStatus'] ?? 'Pending',
      estimatedDeliveryDate: json['estimatedDeliveryDate'] != null
          ? DateTime.parse(json['estimatedDeliveryDate'])
          : null,
      trackingId: json['trackingId'],
      createdAt: json['createdAt'] != null
          ? DateTime.parse(json['createdAt'])
          : DateTime.now(),
      updatedAt: json['updatedAt'] != null
          ? DateTime.parse(json['updatedAt'])
          : DateTime.now(),
      user: json['User'] != null ? UserModel.fromJson(json['User']) : UserModel.empty(),
      orderItems: (json['orderItems'] as List?)
          ?.map((e) => CartModel.fromJson(e))
          .toList() ??
          [],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      "orderId": orderId,
      "prescriptionId": prescriptionId,
      "userId": userId,
      "vendorId": vendorId,
      "addressId": addressId,
      "appliedCoupon": appliedCoupon,
      "discountAmount": discountAmount,
      "subtotal": subtotal,
      "totalAmount": totalAmount,
      "orderStatus": orderStatus,
      "paymentMethod": paymentMethod,
      "transactionId": transactionId,
      "paymentStatus": paymentStatus,
      "deliveryStatus": deliveryStatus,
      "estimatedDeliveryDate": estimatedDeliveryDate?.toIso8601String(),
      "trackingId": trackingId,
      "createdAt": createdAt.toIso8601String(),
      "updatedAt": updatedAt.toIso8601String(),
      "user": user.toJson(),
      "orderItems": orderItems.map((e) => e.toJson()).toList(),
    };
  }
}
