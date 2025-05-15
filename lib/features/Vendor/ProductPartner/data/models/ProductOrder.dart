import 'package:uuid/uuid.dart';
import 'package:vedika_healthcare/core/auth/data/models/UserModel.dart';
import 'ProductOrderItem.dart';

class ProductOrder {
  final String orderId;
  final String userId;
  final double totalAmount;
  final String status;
  final DateTime placedAt;
  final List<ProductOrderItem>? orderItems;
  final UserModel? user;

  ProductOrder({
    String? orderId,
    required this.userId,
    required this.totalAmount,
    this.status = 'pending',
    DateTime? placedAt,
    this.orderItems,
    this.user,
  }) : 
    orderId = orderId ?? const Uuid().v4(),
    placedAt = placedAt ?? DateTime.now();

  factory ProductOrder.fromJson(Map<String, dynamic> json) {
    return ProductOrder(
      orderId: json['orderId'] ?? '',
      userId: json['userId'] ?? '',
      totalAmount: (json['totalAmount'] ?? 0.0).toDouble(),
      status: json['status'] ?? '',
      placedAt: json['placedAt'] != null 
          ? DateTime.parse(json['placedAt'])
          : DateTime.now(),
      orderItems: json['items'] != null
          ? List<ProductOrderItem>.from(
              json['items'].map((x) => ProductOrderItem.fromJson(x)))
          : null,
      user: json['User'] != null ? UserModel.fromJson({
        'userId': json['User']['userId'],
        'name': json['User']['name'],
        'photo': json['User']['photo'],
        'phone_number': json['User']['phone_number'],
        'emailId': json['User']['emailId'],
        'gender': json['User']['gender'],
        'city': json['User']['city'],
        'location': json['User']['location'],
        'status': true,
        'createdAt': DateTime.now().toIso8601String(),
      }) : null,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'orderId': orderId,
      'userId': userId,
      'totalAmount': totalAmount,
      'status': status,
      'placedAt': placedAt.toIso8601String(),
      'items': orderItems?.map((x) => x.toJson()).toList(),
      'User': user?.toJson(),
    };
  }

  ProductOrder copyWith({
    String? orderId,
    String? userId,
    double? totalAmount,
    String? status,
    DateTime? placedAt,
    List<ProductOrderItem>? orderItems,
    UserModel? user,
  }) {
    return ProductOrder(
      orderId: orderId ?? this.orderId,
      userId: userId ?? this.userId,
      totalAmount: totalAmount ?? this.totalAmount,
      status: status ?? this.status,
      placedAt: placedAt ?? this.placedAt,
      orderItems: orderItems ?? this.orderItems,
      user: user ?? this.user,
    );
  }
} 