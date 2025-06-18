import 'package:uuid/uuid.dart';
import 'package:vedika_healthcare/features/home/data/models/Product.dart';
import 'package:vedika_healthcare/features/Vendor/MedicalStoreVendor/data/models/MedicineProduct.dart';

class CartModel {
  final String cartId;
  final String orderId;
  final String name;
  final double price;
  int quantity;
  final String? productId;  // For product items
  final String? medicineId; // For medicine items
  final String? imageUrl;   // For product items
  final String? category;   // For product items
  final bool isProduct;     // To distinguish between product and medicine items
  final MedicineProduct? medicineProduct;

  // Constructor
  CartModel({
    required this.cartId,
    required this.orderId,
    required this.name,
    required this.price,
    required this.quantity,
    this.productId,
    this.medicineId,
    this.imageUrl,
    this.category,
    this.isProduct = false,
    this.medicineProduct,
  });

  // Factory constructor to create CartModel from JSON
  factory CartModel.fromJson(Map<String, dynamic> json) {
    return CartModel(
      cartId: json['cartId'] ?? const Uuid().v4(),
      orderId: json['orderId'] ?? '',
      name: json['name'] ?? '',
      price: (json['price'] as num?)?.toDouble() ?? 0.0,
      quantity: json['quantity'] ?? 0,
      productId: json['productId'] ?? '',
      medicineId: json['medicineId'] ?? '',
      imageUrl: json['imageUrl'] ?? '',
      category: json['category'] ?? '',
      isProduct: json['isProduct'] ?? false,
      medicineProduct: json['MedicineProduct'] != null
          ? MedicineProduct.fromJson(json['MedicineProduct'])
          : null,
    );
  }

  // Method to convert CartModel to JSON
  Map<String, dynamic> toJson() {
    return {
      'cartId': cartId,
      'orderId': orderId,
      'name': name,
      'price': price,
      'quantity': quantity,
      'productId': productId,
      'medicineId': medicineId,
      'imageUrl': imageUrl,
      'category': category,
      'isProduct': isProduct,
      'MedicineProduct': medicineProduct?.toJson(),
    };
  }

  // CopyWith method for creating a copy with updated properties
  CartModel copyWith({
    String? cartId,
    String? orderId,
    String? name,
    double? price,
    int? quantity,
    String? productId,
    String? medicineId,
    String? imageUrl,
    String? category,
    bool? isProduct,
    MedicineProduct? medicineProduct,
  }) {
    return CartModel(
      cartId: cartId ?? this.cartId,
      orderId: orderId ?? this.orderId,
      name: name ?? this.name,
      price: price ?? this.price,
      quantity: quantity ?? this.quantity,
      productId: productId ?? this.productId,
      medicineId: medicineId ?? this.medicineId,
      imageUrl: imageUrl ?? this.imageUrl,
      category: category ?? this.category,
      isProduct: isProduct ?? this.isProduct,
      medicineProduct: medicineProduct ?? this.medicineProduct,
    );
  }

  // Override toString method for better debugging
  @override
  String toString() {
    return 'CartModel(cartId: $cartId, orderId: $orderId, name: $name, price: $price, quantity: $quantity, productId: $productId, medicineId: $medicineId, imageUrl: $imageUrl, category: $category, isProduct: $isProduct, medicineProduct: $medicineProduct)';
  }

  factory CartModel.fromProduct(Product product, {required String cartId, required String orderId}) {
    return CartModel(
      cartId: cartId,
      orderId: orderId,
      name: product.name,
      price: product.priceTiers != null && product.priceTiers!.isNotEmpty 
          ? product.priceTiers!.first.price 
          : (product.price ?? 0.0),
      quantity: 1,
      productId: product.id,
      imageUrl: product.imageUrl,
      category: product.category,
      isProduct: true,
    );
  }
}
