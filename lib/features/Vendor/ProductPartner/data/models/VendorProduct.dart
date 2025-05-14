class VendorProduct {
  final String productId;
  final String vendorId;
  final String name;
  final String category;
  final String description;
  final String howItWorks;
  final List<String> usp;
  final double price;
  final List<String> images;
  final bool isActive;
  final int stock;
  final DateTime createdAt;
  final DateTime updatedAt;

  VendorProduct({
    required this.productId,
    required this.vendorId,
    required this.name,
    required this.category,
    required this.description,
    required this.howItWorks,
    required this.usp,
    required this.price,
    required this.images,
    required this.isActive,
    required this.stock,
    required this.createdAt,
    required this.updatedAt,
  });

  factory VendorProduct.fromJson(Map<String, dynamic> json) {
    return VendorProduct(
      productId: json['id'],
      vendorId: json['vendorId'],
      name: json['name'],
      category: json['category'],
      description: json['description'],
      howItWorks: json['howItWorks'],
      usp: List<String>.from(json['usp']),
      price: (json['price'] as num).toDouble(),
      images: List<String>.from(json['images']),
      isActive: json['isActive'] ?? true,
      stock: json['stock'] ?? 0,
      createdAt: DateTime.parse(json['createdAt']),
      updatedAt: DateTime.parse(json['updatedAt']),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': productId,
      'vendorId': vendorId,
      'name': name,
      'category': category,
      'description': description,
      'howItWorks': howItWorks,
      'usp': usp,
      'price': price,
      'images': images,
      'isActive': isActive,
      'stock': stock,
      'createdAt': createdAt.toIso8601String(),
      'updatedAt': updatedAt.toIso8601String(),
    };
  }
} 