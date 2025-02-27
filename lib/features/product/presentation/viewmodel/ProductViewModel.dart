import 'package:flutter/foundation.dart';
import 'package:vedika_healthcare/features/product/data/models/Product.dart';
import 'package:vedika_healthcare/features/product/data/repositories/ProductRepository.dart';

class ProductViewModel extends ChangeNotifier {
  final ProductRepository _productRepository = ProductRepository();
  List<Product> _products = [];

  List<Product> get products => _products;

  ProductViewModel() {
    fetchProducts();
  }

  void fetchProducts() {
    _products = _productRepository.fetchProducts();
    notifyListeners();
  }

  Product? getProductById(String id) {
    try {
      return _products.firstWhere((product) => product.id == id);
    } catch (e) {
      return null; // Return null if product is not found
    }
  }

  List<Product> filterProductsByCategory(String category) {
    return _products.where((product) => product.category == category).toList();
  }
}
