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
  final double deliveryCharge; // ✅ Delivery Charge
  final double platformFee; // ✅ Platform Fee
   String orderStatus;
  final String? paymentMethod; // ✅ Added Payment Method
  final String? transactionId; // ✅ Added Transaction ID
  final String paymentStatus; // ✅ Payment Status (Paid, Unpaid, Failed, Refunded)
  final String deliveryStatus; // ✅ Delivery Status (Pending, Out for Delivery, Delivered, Returned)
  final DateTime? estimatedDeliveryDate; // ✅ Estimated Delivery Date
  final String? trackingId; // ✅ Tracking ID for shipment
  final bool selfDelivery; // ✅ Self delivery flag
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
    this.selfDelivery = false,
    required this.createdAt,
    required this.updatedAt,
    required this.user,
    required this.orderItems,
    required this.deliveryCharge,
    required this.platformFee,
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
      selfDelivery: json['selfDelivery'] ?? false,
      createdAt: json['createdAt'] != null
          ? DateTime.parse(json['createdAt'])
          : DateTime.now(),
      updatedAt: json['updatedAt'] != null
          ? DateTime.parse(json['updatedAt'])
          : DateTime.now(),
      user: json['User'] != null ? UserModel.fromJson(json['User']) : UserModel.empty(),
      orderItems: (json['Carts'] as List?)
          ?.map((e) => CartModel.fromJson(e))
          .toList() ??
          [],
      deliveryCharge: (json['deliveryCharge'] as num?)?.toDouble() ?? 0.0,
      platformFee: (json['platformFee'] as num?)?.toDouble() ?? 0.0,
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
      "selfDelivery": selfDelivery,
      "createdAt": createdAt.toIso8601String(),
      "updatedAt": updatedAt.toIso8601String(),
      "user": user.toJson(),
      "orderItems": orderItems.map((e) => e.toJson()).toList(),
      "deliveryCharge": deliveryCharge,
      "platformFee": platformFee,
    };
  }

  /// ✅ **Add `copyWith` method**
  MedicineOrderModel copyWith({
    String? orderId,
    String? prescriptionId,
    String? userId,
    String? vendorId,
    String? addressId,
    String? appliedCoupon,
    double? discountAmount,
    double? subtotal,
    double? totalAmount,
    String? orderStatus,
    String? paymentMethod,
    String? transactionId,
    String? paymentStatus,
    String? deliveryStatus,
    DateTime? estimatedDeliveryDate,
    String? trackingId,
    bool? selfDelivery,
    DateTime? createdAt,
    DateTime? updatedAt,
    UserModel? user,
    List<CartModel>? orderItems,
    double? deliveryCharge,
    double? platformFee,
  }) {
    return MedicineOrderModel(
      orderId: orderId ?? this.orderId,
      prescriptionId: prescriptionId ?? this.prescriptionId,
      userId: userId ?? this.userId,
      vendorId: vendorId ?? this.vendorId,
      addressId: addressId ?? this.addressId,
      appliedCoupon: appliedCoupon ?? this.appliedCoupon,
      discountAmount: discountAmount ?? this.discountAmount,
      subtotal: subtotal ?? this.subtotal,
      totalAmount: totalAmount ?? this.totalAmount,
      orderStatus: orderStatus ?? this.orderStatus,
      paymentMethod: paymentMethod ?? this.paymentMethod,
      transactionId: transactionId ?? this.transactionId,
      paymentStatus: paymentStatus ?? this.paymentStatus,
      deliveryStatus: deliveryStatus ?? this.deliveryStatus,
      estimatedDeliveryDate: estimatedDeliveryDate ?? this.estimatedDeliveryDate,
      trackingId: trackingId ?? this.trackingId,
      selfDelivery: selfDelivery ?? this.selfDelivery,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
      user: user ?? this.user,
      orderItems: orderItems ?? this.orderItems,
      deliveryCharge: deliveryCharge ?? this.deliveryCharge,
      platformFee: platformFee ?? this.platformFee,
    );
  }
}
