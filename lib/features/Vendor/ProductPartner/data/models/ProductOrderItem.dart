import 'package:uuid/uuid.dart';
import 'VendorProduct.dart';

class ProductOrderItem {
  final String orderItemId;
  final String orderId;
  final String productId;
  final int quantity;
  final double priceAtPurchase;
  final VendorProduct? vendorProduct;

  ProductOrderItem({
    required this.orderItemId,
    required this.orderId,
    required this.productId,
    required this.quantity,
    required this.priceAtPurchase,
    this.vendorProduct,
  });

  factory ProductOrderItem.fromJson(Map<String, dynamic> json) {
    return ProductOrderItem(
      orderItemId: json['orderItemId'] ?? '',
      orderId: json['orderId'] ?? '',
      productId: json['productId'] ?? '',
      quantity: json['quantity'] ?? 0,
      priceAtPurchase: (json['priceAtPurchase'] ?? 0.0).toDouble(),
      vendorProduct: json['VendorProduct'] != null 
          ? VendorProduct.fromJson(json['VendorProduct'])
          : null,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'orderItemId': orderItemId,
      'orderId': orderId,
      'productId': productId,
      'quantity': quantity,
      'priceAtPurchase': priceAtPurchase,
      'VendorProduct': vendorProduct?.toJson(),
    };
  }

  ProductOrderItem copyWith({
    String? orderItemId,
    String? orderId,
    String? productId,
    int? quantity,
    double? priceAtPurchase,
    VendorProduct? vendorProduct,
  }) {
    return ProductOrderItem(
      orderItemId: orderItemId ?? this.orderItemId,
      orderId: orderId ?? this.orderId,
      productId: productId ?? this.productId,
      quantity: quantity ?? this.quantity,
      priceAtPurchase: priceAtPurchase ?? this.priceAtPurchase,
      vendorProduct: vendorProduct ?? this.vendorProduct,
    );
  }
} 