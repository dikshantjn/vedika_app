import 'package:vedika_healthcare/features/home/data/models/HealthDay.dart';

class BannerModal {
  final String id; // Added Banner ID
  final String title;
  final String description;
  final String image;
  final int color;
  final String type;
  final HealthDay? healthDay; // Optional field

  BannerModal({
    required this.id, // Required ID
    required this.title,
    required this.description,
    required this.image,
    required this.color,
    required this.type,
    this.healthDay,
  });

  factory BannerModal.fromJson(Map<String, dynamic> json) {
    return BannerModal(
      id: json["id"], // Parse ID from JSON
      title: json["title"],
      description: json["description"],
      image: json["image"],
      color: int.parse(json["color"]),
      type: json["type"],
      healthDay: json["type"] == "health_days" && json["healthDay"] != null
          ? HealthDay.fromJson(json["healthDay"]) // Parse HealthDay if available
          : null,
    );
  }
}
