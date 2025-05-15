class VendorProduct {
  final String productId;
  final String vendorId;
  final String name;
  final String category;
  final String? subCategory;
  final String description;
  final String howItWorks;
  final List<String> usp;
  final double price;
  final List<String> images;
  final List<String>? additionalImages;
  final String? demoLink;
  final String? videoUrl;
  final List<String> highlights;
  final bool comingSoon;
  final List<PriceTier>? priceTiers;
  final double rating;
  final int reviewCount;
  final Map<String, dynamic>? specifications;
  final bool isActive;
  final int stock;
  final DateTime createdAt;
  final DateTime updatedAt;

  VendorProduct({
    required this.productId,
    required this.vendorId,
    required this.name,
    required this.category,
    this.subCategory,
    required this.description,
    required this.howItWorks,
    required this.usp,
    required this.price,
    required this.images,
    this.additionalImages,
    this.demoLink,
    this.videoUrl,
    required this.highlights,
    required this.comingSoon,
    this.priceTiers,
    required this.rating,
    required this.reviewCount,
    this.specifications,
    required this.isActive,
    required this.stock,
    required this.createdAt,
    required this.updatedAt,
  });

  factory VendorProduct.fromJson(Map<String, dynamic> json) {
    return VendorProduct(
      productId: json['productId'] ?? '',
      vendorId: json['vendorId'] ?? '',
      name: json['name'] ?? '',
      category: json['category'] ?? '',
      subCategory: json['subCategory'],
      description: json['description'] ?? '',
      howItWorks: json['howItWorks'] ?? '',
      usp: List<String>.from(json['usp'] ?? []),
      price: (json['price'] ?? 0.0).toDouble(),
      images: List<String>.from(json['images'] ?? []),
      additionalImages: json['additionalImages'] != null 
          ? List<String>.from(json['additionalImages'])
          : null,
      demoLink: json['demoLink'],
      videoUrl: json['videoUrl'],
      highlights: List<String>.from(json['highlights'] ?? []),
      comingSoon: json['comingSoon'] ?? false,
      priceTiers: json['priceTiers'] != null
          ? (json['priceTiers'] as List).map((tier) => PriceTier.fromJson(tier)).toList()
          : null,
      rating: (json['rating'] ?? 0.0).toDouble(),
      reviewCount: json['reviewCount'] ?? 0,
      specifications: json['specifications'],
      isActive: json['isActive'] ?? true,
      stock: json['stock'] ?? 0,
      createdAt: json['createdAt'] != null 
          ? DateTime.parse(json['createdAt'])
          : DateTime.now(),
      updatedAt: json['updatedAt'] != null 
          ? DateTime.parse(json['updatedAt'])
          : DateTime.now(),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'productId': productId,
      'vendorId': vendorId,
      'name': name,
      'category': category,
      'subCategory': subCategory,
      'description': description,
      'howItWorks': howItWorks,
      'usp': usp,
      'price': price,
      'images': images,
      'additionalImages': additionalImages,
      'demoLink': demoLink,
      'videoUrl': videoUrl,
      'highlights': highlights,
      'comingSoon': comingSoon,
      'priceTiers': priceTiers?.map((tier) => tier.toJson()).toList(),
      'rating': rating,
      'reviewCount': reviewCount,
      'specifications': specifications,
      'isActive': isActive,
      'stock': stock,
      'createdAt': createdAt.toIso8601String(),
      'updatedAt': updatedAt.toIso8601String(),
    };
  }
}

class PriceTier {
  final String name;
  final double price;
  final String? description;

  PriceTier({
    required this.name,
    required this.price,
    this.description,
  });

  factory PriceTier.fromJson(Map<String, dynamic> json) {
    return PriceTier(
      name: json['name'] ?? '',
      price: (json['price'] ?? 0.0).toDouble(),
      description: json['description'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'name': name,
      'price': price,
      'description': description,
    };
  }
} 