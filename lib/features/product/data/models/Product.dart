class Product {
  final String id;
  final String name;
  final String category;
  final double price;
  final String manufacturer;
  final String expiryDate;
  final bool requiresPrescription;
  final double rating;
  final String image;

  Product({
    required this.id,
    required this.name,
    required this.category,
    required this.price,
    required this.manufacturer,
    required this.expiryDate,
    required this.requiresPrescription,
    required this.rating,
    required this.image,
  });

  factory Product.fromJson(Map<String, dynamic> json) {
    return Product(
      id: json['id'],
      name: json['name'],
      category: json['category'],
      price: json['price'].toDouble(),
      manufacturer: json['manufacturer'],
      expiryDate: json['expiryDate'],
      requiresPrescription: json['requiresPrescription'],
      rating: json['rating'].toDouble(),
      image: json['image'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'category': category,
      'price': price,
      'manufacturer': manufacturer,
      'expiryDate': expiryDate,
      'requiresPrescription': requiresPrescription,
      'rating': rating,
      'image': image,
    };
  }
}

