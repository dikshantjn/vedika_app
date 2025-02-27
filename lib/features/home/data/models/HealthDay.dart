
import 'package:vedika_healthcare/features/product/data/models/Product.dart';

class HealthDay {
  final String id;
  final String title;
  final String description;
  final String image;
  final String importance;
  final List<String> preventiveMeasures;
  final List<Product> recommendedProducts;
  final List<String> suggestedLabTests;

  HealthDay({
    required this.id,
    required this.title,
    required this.description,
    required this.image,
    required this.importance,
    required this.preventiveMeasures,
    required this.recommendedProducts,
    required this.suggestedLabTests,
  });

  // Convert JSON to HealthDay object
  factory HealthDay.fromJson(Map<String, dynamic> json) {
    return HealthDay(
      id: json['id'],
      title: json['title'],
      description: json['description'],
      image: json['image'],
      importance: json['importance'],
      preventiveMeasures: List<String>.from(json['preventiveMeasures']),
      recommendedProducts: (json['recommendedProducts'] as List)
          .map((productJson) => Product.fromJson(productJson))
          .toList(),
      suggestedLabTests: List<String>.from(json['suggestedLabTests']),
    );
  }

  // Convert HealthDay object to JSON
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'title': title,
      'description': description,
      'image': image,
      'importance': importance,
      'preventiveMeasures': preventiveMeasures,
      'recommendedProducts': recommendedProducts.map((product) => product.toJson()).toList(),
      'suggestedLabTests': suggestedLabTests,
    };
  }
}
