class ProductCart {
  final String? cartId;
  final String? userId;
  final String? productId;
  final int? quantity;
  final DateTime? addedAt;
  final String? imageUrl;
  final String? productName;
  final double? price;

  ProductCart({
    this.cartId,
    this.userId,
    this.productId,
    this.quantity,
    this.addedAt,
    this.imageUrl,
    this.productName,
    this.price,
  });

  factory ProductCart.fromJson(Map<String, dynamic> json) {
    return ProductCart(
      cartId: json['cartId'] as String?,
      userId: json['userId'] as String?,
      productId: json['productId'] as String?,
      quantity: json['quantity'] as int?,
      addedAt: json['addedAt'] != null ? DateTime.parse(json['addedAt']) : null,
      imageUrl: json['imageUrl'] as String?,
      productName: json['productName'] as String?,
      price: (json['price'] as num?)?.toDouble(),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'cartId': cartId,
      'userId': userId,
      'productId': productId,
      'quantity': quantity,
      'addedAt': addedAt?.toIso8601String(),
      'imageUrl': imageUrl,
      'productName': productName,
      'price': price,
    };
  }
} 