import 'package:uuid/uuid.dart';

class CartModel {
  final String cartId;
  final int? orderId;
  final String productId;
  final String name;
  final double price;
  int quantity;

  // Constructor
  CartModel({
    String? cartId, // Make cartId optional
    this.orderId,
    required this.productId,
    required this.name,
    required this.price,
    required this.quantity,
  }) : cartId = cartId ?? Uuid().v4(); // Generate cartId if not passed

  // Factory constructor to create CartModel from JSON
  factory CartModel.fromJson(Map<String, dynamic> json) {
    return CartModel(
      cartId: json['cartId'] ?? Uuid().v4(),
      orderId: json['orderId'],
      productId: json['productId'] ?? '',
      name: json['name'] ?? '',
      price: (json['price'] as num?)?.toDouble() ?? 0.0,
      quantity: json['quantity'] ?? 0,
    );
  }



  // Method to convert CartModel to JSON
  Map<String, dynamic> toJson() {
    return {
      'cartId': cartId,
      'orderId': orderId,
      'productId': productId,
      'name': name,
      'price': price,
      'quantity': quantity,
    };
  }

  // CopyWith method for creating a copy with updated properties
  CartModel copyWith({
    String? cartId,
    int? orderId,
    String? productId,
    String? name,
    double? price,
    int? quantity,
  }) {
    return CartModel(
      cartId: cartId ?? this.cartId,
      orderId: orderId ?? this.orderId,
      productId: productId ?? this.productId,
      name: name ?? this.name,
      price: price ?? this.price,
      quantity: quantity ?? this.quantity,
    );
  }

  // Override toString method for better debugging
  @override
  String toString() {
    return 'CartModel(cartId: $cartId, orderId: $orderId, productId: $productId, name: $name, price: $price, quantity: $quantity)';
  }
}
