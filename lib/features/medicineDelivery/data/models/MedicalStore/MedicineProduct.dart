class MedicineProduct {
  final String id;
  final String name;
  final String description;
  final double price;
  final int stock;
  final String manufacturer;
  final List<String> imageUrl; // imageUrls as a list of strings
  final int quantity; // Added quantity for cart functionality

  MedicineProduct({
    required this.id,
    required this.name,
    required this.description,
    required this.price,
    required this.stock,
    required this.manufacturer,
    required this.imageUrl,
    this.quantity = 1, // Default quantity to 1
  });

  // Convert JSON to Model
  factory MedicineProduct.fromJson(Map<String, dynamic> json) {
    return MedicineProduct(
      id: json['id'] ?? '',
      name: json['name'] ?? '',
      description: json['description'] ?? '',
      price: (json['price'] ?? 0).toDouble(),
      stock: json['stock'] ?? 0,
      manufacturer: json['manufacturer'] ?? '',
      imageUrl: List<String>.from(json['imageUrl'] ?? []), // Handling it as a List<String>
      quantity: json['quantity'] ?? 1,
    );
  }

  // Convert Model to JSON
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'description': description,
      'price': price,
      'stock': stock,
      'manufacturer': manufacturer,
      'imageUrl': imageUrl,
      'quantity': quantity,
    };
  }

  // Create a copy of the object with updated values
  MedicineProduct copyWith({
    String? id,
    String? name,
    String? description,
    double? price,
    int? stock,
    String? manufacturer,
    List<String>? imageUrl,
    int? quantity,
  }) {
    return MedicineProduct(
      id: id ?? this.id,
      name: name ?? this.name,
      description: description ?? this.description,
      price: price ?? this.price,
      stock: stock ?? this.stock,
      manufacturer: manufacturer ?? this.manufacturer,
      imageUrl: imageUrl ?? this.imageUrl,
      quantity: quantity ?? this.quantity,
    );
  }
}
