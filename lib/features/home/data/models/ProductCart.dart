class ProductCart {
  final String? cartId;
  final String? userId;
  final String? productId;
  final int? quantity;
  final DateTime? addedAt;
  final String? imageUrl;
  final String? productName;
  final double? price;
  final String? category;

  ProductCart({
    this.cartId,
    this.userId,
    this.productId,
    this.quantity,
    this.addedAt,
    this.imageUrl,
    this.productName,
    this.price,
    this.category,
  });

  factory ProductCart.fromJson(Map<String, dynamic> json) {
    // Base fields
    String? imageUrl = json['imageUrl'] as String?;
    String? productName = json['productName'] as String?;
    double? price = (json['price'] as num?)?.toDouble();
    String? category;

    // If nested product object is present, prefer its values
    final Map<String, dynamic>? product = json['product'] as Map<String, dynamic>?;
    if (product != null) {
      // images is a list; use first when available
      final List<dynamic>? images = product['images'] as List<dynamic>?;
      if ((images != null) && images.isNotEmpty) {
        final String? firstImage = images.first as String?;
        if (firstImage != null && firstImage.isNotEmpty) {
          imageUrl = firstImage;
        }
      }
      productName ??= product['name'] as String?;
      final num? p = product['price'] as num?;
      price ??= p?.toDouble();
      category = product['category'] as String?;
    }

    return ProductCart(
      cartId: json['cartId'] as String?,
      userId: json['userId'] as String?,
      productId: json['productId'] as String?,
      quantity: json['quantity'] as int?,
      addedAt: json['addedAt'] != null ? DateTime.parse(json['addedAt']) : null,
      imageUrl: imageUrl,
      productName: productName,
      price: price,
      category: category,
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
      'category': category,
    };
  }
} 