import 'package:vedika_healthcare/core/auth/data/models/UserModel.dart';
import 'package:vedika_healthcare/features/Vendor/MedicalStoreVendor/data/models/NewOrders/Prescription.dart';

// Simplified vendor model for orders (since API only provides basic info)
class OrderVendor {
  final String vendorId;
  final String name;

  OrderVendor({
    required this.vendorId,
    required this.name,
  });

  factory OrderVendor.fromJson(Map<String, dynamic> json) {
    return OrderVendor(
      vendorId: json['vendorId'] ?? '',
      name: json['name'] ?? '',
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'vendorId': vendorId,
      'name': name,
    };
  }
}

class Order {
  final String orderId;
  final String vendorId;
  final String prescriptionId;
  final String userId;
  final double totalAmount;
  final double platformFee;
  final String? addressId;
  final String? paymentId;
  final String status;
  final String? note;
  final DateTime createdAt;
  final DateTime updatedAt;
  final Prescription? prescription;
  final UserModel? user;
  final OrderVendor? vendor;

  Order({
    required this.orderId,
    required this.vendorId,
    required this.prescriptionId,
    required this.userId,
    required this.totalAmount,
    required this.platformFee,
    this.addressId,
    this.paymentId,
    required this.status,
    this.note,
    required this.createdAt,
    required this.updatedAt,
    this.prescription,
    this.user,
    this.vendor,
  });

  factory Order.fromJson(Map<String, dynamic> json) {
    // Parse nested prescription data
    Prescription? prescription;
    if (json['prescription'] != null) {
      prescription = Prescription.fromJson(json['prescription']);
    }
    
    // Parse nested vendor data
    OrderVendor? vendor;
    if (json['vendor'] != null) {
      vendor = OrderVendor.fromJson(json['vendor']);
    }
    
    // Parse nested user data
    UserModel? user;
    if (json['user'] != null) {
      user = UserModel.fromJson(json['user']);
    }
    
    return Order(
      orderId: json['orderId'] ?? '',
      vendorId: json['vendorId'] ?? '',
      prescriptionId: json['prescriptionId'] ?? '',
      userId: json['userId'] ?? '',
      totalAmount: (json['totalAmount'] ?? 0.0).toDouble(),
      platformFee: (json['platformFee'] ?? 0.0).toDouble(),
      addressId: json['addressId'],
      paymentId: json['paymentId'],
      status: json['status'] ?? 'pending',
      note: json['note'],
      createdAt: DateTime.parse(json['createdAt'] ?? DateTime.now().toIso8601String()),
      updatedAt: DateTime.parse(json['updatedAt'] ?? DateTime.now().toIso8601String()),
      prescription: prescription,
      user: user, // Parse user data if available
      vendor: vendor,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'orderId': orderId,
      'vendorId': vendorId,
      'prescriptionId': prescriptionId,
      'userId': userId,
      'totalAmount': totalAmount,
      'platformFee': platformFee,
      'addressId': addressId,
      'paymentId': paymentId,
      'status': status,
      'note': note,
      'createdAt': createdAt.toIso8601String(),
      'updatedAt': updatedAt.toIso8601String(),
      'prescription': prescription?.toJson(),
      'user': user?.toJson(),
      'vendor': vendor?.toJson(),
    };
  }

  Order copyWith({
    String? orderId,
    String? vendorId,
    String? prescriptionId,
    String? userId,
    double? totalAmount,
    double? platformFee,
    String? addressId,
    String? paymentId,
    String? status,
    String? note,
    DateTime? createdAt,
    DateTime? updatedAt,
    Prescription? prescription,
    UserModel? user,
    OrderVendor? vendor,
  }) {
    return Order(
      orderId: orderId ?? this.orderId,
      vendorId: vendorId ?? this.vendorId,
      prescriptionId: prescriptionId ?? this.prescriptionId,
      userId: userId ?? this.userId,
      totalAmount: totalAmount ?? this.totalAmount,
      platformFee: platformFee ?? this.platformFee,
      addressId: addressId ?? this.addressId,
      paymentId: paymentId ?? this.paymentId,
      status: status ?? this.status,
      note: note ?? this.note,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
      prescription: prescription ?? this.prescription,
      user: user ?? this.user,
      vendor: vendor ?? this.vendor,
    );
  }
}
