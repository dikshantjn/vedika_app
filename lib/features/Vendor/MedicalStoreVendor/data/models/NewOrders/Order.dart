import 'package:vedika_healthcare/core/auth/data/models/UserModel.dart';
import 'package:vedika_healthcare/features/Vendor/MedicalStoreVendor/data/models/NewOrders/Prescription.dart';
import 'package:vedika_healthcare/features/Vendor/MedicalStoreVendor/data/models/NewOrders/OrderMedicine.dart';
import 'package:vedika_healthcare/features/DeliveryAddress/data/modal/DeliveryAddressModel.dart';

// Helper function to parse double from string or number
double _parseDoubleFromJson(dynamic value) {
  if (value == null) return 0.0;
  if (value is double) return value;
  if (value is int) return value.toDouble();
  if (value is String) return double.tryParse(value) ?? 0.0;
  return 0.0;
}

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
  // 💰 Billing Details
  final double subtotal;
  final double discount;
  final double deliveryCharges;
  final double gst;
  final double platformFee;
  final double totalAmount;
  final String? addressId;
  final String? paymentId;
  final String status;
  final String? note;
  final DateTime createdAt;
  final DateTime updatedAt;
  final Prescription? prescription;
  final UserModel? user;
  final OrderVendor? vendor;
  final DeliveryAddressModel? deliveryAddress;
  final List<OrderMedicine>? medicines; // List of medicines in the order

  Order({
    required this.orderId,
    required this.vendorId,
    required this.prescriptionId,
    required this.userId,
    this.subtotal = 0.0,
    this.discount = 0.0,
    this.deliveryCharges = 0.0,
    this.gst = 0.0,
    required this.platformFee,
    required this.totalAmount,
    this.addressId,
    this.paymentId,
    required this.status,
    this.note,
    required this.createdAt,
    required this.updatedAt,
    this.prescription,
    this.user,
    this.vendor,
    this.deliveryAddress,
    this.medicines,
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

    // Parse nested delivery address data
    DeliveryAddressModel? deliveryAddress;
    if (json['deliveryAddress'] != null) {
      deliveryAddress = DeliveryAddressModel.fromJson(json['deliveryAddress']);
    }

    // Parse medicines list
    List<OrderMedicine>? medicines;
    if (json['medicines'] != null && json['medicines'] is List) {
      medicines = (json['medicines'] as List)
          .map((item) => OrderMedicine.fromJson(item))
          .toList();
    }

    return Order(
      orderId: json['orderId'] ?? '',
      vendorId: json['vendorId'] ?? '',
      prescriptionId: json['prescriptionId'] ?? '',
      userId: json['userId'] ?? '',
      subtotal: _parseDoubleFromJson(json['subtotal']),
      discount: _parseDoubleFromJson(json['discount']),
      deliveryCharges: _parseDoubleFromJson(json['deliveryCharges']),
      gst: _parseDoubleFromJson(json['gst']),
      platformFee: _parseDoubleFromJson(json['platformFee']),
      totalAmount: _parseDoubleFromJson(json['totalAmount']),
      addressId: json['addressId'],
      paymentId: json['paymentId'],
      status: json['status'] ?? 'pending',
      note: json['note'],
      createdAt: DateTime.parse(json['createdAt'] ?? DateTime.now().toIso8601String()),
      updatedAt: DateTime.parse(json['updatedAt'] ?? DateTime.now().toIso8601String()),
      prescription: prescription,
      user: user, // Parse user data if available
      vendor: vendor,
      deliveryAddress: deliveryAddress,
      medicines: medicines,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'orderId': orderId,
      'vendorId': vendorId,
      'prescriptionId': prescriptionId,
      'userId': userId,
      'subtotal': subtotal,
      'discount': discount,
      'deliveryCharges': deliveryCharges,
      'gst': gst,
      'platformFee': platformFee,
      'totalAmount': totalAmount,
      'addressId': addressId,
      'paymentId': paymentId,
      'status': status,
      'note': note,
      'createdAt': createdAt.toIso8601String(),
      'updatedAt': updatedAt.toIso8601String(),
      'prescription': prescription?.toJson(),
      'user': user?.toJson(),
      'vendor': vendor?.toJson(),
      'deliveryAddress': deliveryAddress?.toJson(),
      'medicines': medicines?.map((m) => m.toJson()).toList(),
    };
  }

  Order copyWith({
    String? orderId,
    String? vendorId,
    String? prescriptionId,
    String? userId,
    double? subtotal,
    double? discount,
    double? deliveryCharges,
    double? gst,
    double? platformFee,
    double? totalAmount,
    String? addressId,
    String? paymentId,
    String? status,
    String? note,
    DateTime? createdAt,
    DateTime? updatedAt,
    Prescription? prescription,
    UserModel? user,
    OrderVendor? vendor,
    DeliveryAddressModel? deliveryAddress,
    List<OrderMedicine>? medicines,
  }) {
    return Order(
      orderId: orderId ?? this.orderId,
      vendorId: vendorId ?? this.vendorId,
      prescriptionId: prescriptionId ?? this.prescriptionId,
      userId: userId ?? this.userId,
      subtotal: subtotal ?? this.subtotal,
      discount: discount ?? this.discount,
      deliveryCharges: deliveryCharges ?? this.deliveryCharges,
      gst: gst ?? this.gst,
      platformFee: platformFee ?? this.platformFee,
      totalAmount: totalAmount ?? this.totalAmount,
      addressId: addressId ?? this.addressId,
      paymentId: paymentId ?? this.paymentId,
      status: status ?? this.status,
      note: note ?? this.note,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
      prescription: prescription ?? this.prescription,
      user: user ?? this.user,
      vendor: vendor ?? this.vendor,
      deliveryAddress: deliveryAddress ?? this.deliveryAddress,
      medicines: medicines ?? this.medicines,
    );
  }
}
