class MedicineProduct {
  String productId;
  String name;
  double price;
  double discount;
  String manufacturer;
  String type; // Tablet, Syrup, Injection, etc.
  String packSizeLabel;
  String shortComposition;
  List<String> productURLs; // List to store multiple image URLs
  int quantity; // New field for stock quantity

  MedicineProduct({
    required this.productId,
    required this.name,
    required this.price,
    required this.discount,
    required this.manufacturer,
    required this.type,
    required this.packSizeLabel,
    required this.shortComposition,
    required this.productURLs,
    required this.quantity,
  });

  // ✅ Convert to JSON (Handles null values safely)
  Map<String, dynamic> toJson() {
    return {
      'productId': productId,
      'name': name,
      'price': price,
      'discount': discount,
      'manufacturer': manufacturer,
      'type': type,
      'packSizeLabel': packSizeLabel,
      'shortComposition': shortComposition,
      'productURLs': productURLs.isNotEmpty ? productURLs : [],
      'quantity': quantity,
    };
  }

  // ✅ Convert from JSON (Handles missing or null values)
  factory MedicineProduct.fromJson(Map<String, dynamic> json) {
    return MedicineProduct(
      productId: json['productId'] ?? '', // Avoids null assignment
      name: json['name'] ?? 'Unknown',
      price: (json['price'] as num?)?.toDouble() ?? 0.0, // Handles null safely
      discount: (json['discount'] as num?)?.toDouble() ?? 0.0, // Handles null safely
      manufacturer: json['manufacturer'] ?? 'Unknown',
      type: json['type'] ?? 'Unknown',
      packSizeLabel: json['packSizeLabel'] ?? 'Unknown',
      shortComposition: json['shortComposition'] ?? 'Unknown',
      productURLs: (json['productURLs'] as List?)?.map((e) => e.toString()).toList() ?? [],
      quantity: json['quantity'] is int ? json['quantity'] : int.tryParse(json['quantity']?.toString() ?? '0') ?? 0,
    );
  }
}
