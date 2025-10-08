class BlogCategoryModel {
  final String categoryId;
  final String name;
  final DateTime createdAt;
  final DateTime updatedAt;

  BlogCategoryModel({
    required this.categoryId,
    required this.name,
    required this.createdAt,
    required this.updatedAt,
  });

  factory BlogCategoryModel.fromJson(Map<String, dynamic> json) {
    return BlogCategoryModel(
      categoryId: json['categoryId'] ?? '',
      name: json['name'] ?? '',
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
      'categoryId': categoryId,
      'name': name,
      'createdAt': createdAt.toIso8601String(),
      'updatedAt': updatedAt.toIso8601String(),
    };
  }
}
