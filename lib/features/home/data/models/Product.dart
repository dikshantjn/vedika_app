class Product {
  final String id;
  final String category;
  final String name;
  final String imageUrl;
  final String description;
  final String usp;
  final String howToUse;
  final double? price;
  final String? demoLink;
  final String? videoUrl;
  final List<String> highlights;
  final bool comingSoon;
  final List<PriceTier>? priceTiers;
  final String? subCategory;
  final double rating;
  final int reviewCount;
  final bool isAvailable;
  final Map<String, dynamic>? specifications;
  final List<String>? additionalImages;

  Product({
    required this.id,
    required this.category,
    required this.name,
    required this.imageUrl,
    required this.description,
    required this.usp,
    required this.howToUse,
    this.price,
    this.demoLink,
    this.videoUrl,
    required this.highlights,
    this.comingSoon = false,
    this.priceTiers,
    this.subCategory,
    this.rating = 0.0,
    this.reviewCount = 0,
    this.isAvailable = true,
    this.specifications,
    this.additionalImages,
  });

  factory Product.fromJson(Map<String, dynamic> json) {
    return Product(
      id: json['id'],
      category: json['category'],
      name: json['name'],
      imageUrl: json['imageUrl'],
      description: json['description'],
      usp: json['usp'],
      howToUse: json['howToUse'],
      price: json['price']?.toDouble(),
      demoLink: json['demoLink'],
      videoUrl: json['videoUrl'],
      highlights: List<String>.from(json['highlights']),
      comingSoon: json['comingSoon'] ?? false,
      priceTiers: json['priceTiers'] != null
          ? List<PriceTier>.from(
              json['priceTiers'].map((x) => PriceTier.fromJson(x)))
          : null,
      subCategory: json['subCategory'],
      rating: json['rating']?.toDouble() ?? 0.0,
      reviewCount: json['reviewCount'] ?? 0,
      isAvailable: json['isAvailable'] ?? true,
      specifications: json['specifications'],
      additionalImages: json['additionalImages'] != null
          ? List<String>.from(json['additionalImages'])
          : null,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'category': category,
      'name': name,
      'imageUrl': imageUrl,
      'description': description,
      'usp': usp,
      'howToUse': howToUse,
      'price': price,
      'demoLink': demoLink,
      'videoUrl': videoUrl,
      'highlights': highlights,
      'comingSoon': comingSoon,
      'priceTiers': priceTiers?.map((x) => x.toJson()).toList(),
      'subCategory': subCategory,
      'rating': rating,
      'reviewCount': reviewCount,
      'isAvailable': isAvailable,
      'specifications': specifications,
      'additionalImages': additionalImages,
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
      name: json['name'],
      price: json['price'].toDouble(),
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