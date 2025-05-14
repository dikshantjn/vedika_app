import '../models/VendorProduct.dart';

class ProductPartnerProductService {
  // Singleton pattern
  static final ProductPartnerProductService _instance = ProductPartnerProductService._internal();
  factory ProductPartnerProductService() => _instance;
  ProductPartnerProductService._internal();

  Future<VendorProduct> addProduct(VendorProduct product) async {
    try {
      // TODO: Implement actual API call
      // For now, just print the product data
      print('Adding new product:');
      print('Product ID: ${product.productId}');
      print('Vendor ID: ${product.vendorId}');
      print('Name: ${product.name}');
      print('Category: ${product.category}');
      print('Description: ${product.description}');
      print('How It Works: ${product.howItWorks}');
      print('USP: ${product.usp.join(", ")}');
      print('Price: \$${product.price}');
      print('Images: ${product.images.join(", ")}');
      print('Is Active: ${product.isActive}');
      print('Stock: ${product.stock}');
      print('Created At: ${product.createdAt}');
      print('Updated At: ${product.updatedAt}');

      // Simulate API delay
      await Future.delayed(const Duration(seconds: 1));

      // Return the product (in real implementation, this would be the response from the API)
      return product;
    } catch (e) {
      print('Error adding product: $e');
      rethrow;
    }
  }
} 