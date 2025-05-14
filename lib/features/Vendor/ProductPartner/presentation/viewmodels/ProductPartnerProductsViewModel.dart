import 'package:flutter/material.dart';
import '../../data/models/VendorProduct.dart';

class ProductPartnerProductsViewModel extends ChangeNotifier {
  bool _isLoading = false;
  List<VendorProduct> _products = [];
  String _selectedCategory = 'All';
  String _searchQuery = '';
  List<String> _categories = ['All', 'Period Care', 'Medicine', 'Diagnostic'];

  // Getters
  bool get isLoading => _isLoading;
  List<VendorProduct> get products => _filteredProducts;
  String get selectedCategory => _selectedCategory;
  String get searchQuery => _searchQuery;
  List<String> get categories => _categories;

  // Filtered products based on category and search
  List<VendorProduct> get _filteredProducts {
    return _products.where((product) {
      final matchesCategory = _selectedCategory == 'All' || product.category == _selectedCategory;
      final matchesSearch = _searchQuery.isEmpty ||
          product.name.toLowerCase().contains(_searchQuery.toLowerCase()) ||
          product.description.toLowerCase().contains(_searchQuery.toLowerCase());
      return matchesCategory && matchesSearch;
    }).toList();
  }

  Future<void> fetchProducts() async {
    _isLoading = true;
    notifyListeners();

    try {
      // TODO: Implement API call to fetch products
      // For now using dummy data
      await Future.delayed(const Duration(seconds: 1));
      _products = [
        VendorProduct(
          productId: '1',
          vendorId: 'v1',
          name: 'Organic Cotton Pads',
          category: 'Period Care',
          description: 'Soft and comfortable organic cotton pads for daily use.',
          howItWorks: 'Use as needed for maximum comfort and protection.',
          usp: ['Organic', 'Comfortable', 'Eco-friendly'],
          price: 12.99,
          images: ['https://example.com/pad1.jpg'],
          isActive: true,
          stock: 100,
          createdAt: DateTime.now(),
          updatedAt: DateTime.now(),
        ),
        VendorProduct(
          productId: '2',
          vendorId: 'v1',
          name: 'Digital Thermometer',
          category: 'Diagnostic',
          description: 'Accurate digital thermometer for quick temperature readings.',
          howItWorks: 'Place under tongue or armpit for 30 seconds.',
          usp: ['Fast', 'Accurate', 'Easy to use'],
          price: 24.99,
          images: ['https://example.com/thermo1.jpg'],
          isActive: true,
          stock: 50,
          createdAt: DateTime.now(),
          updatedAt: DateTime.now(),
        ),
      ];
    } catch (e) {
      // Handle error
      print('Error fetching products: $e');
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  void setCategory(String category) {
    _selectedCategory = category;
    notifyListeners();
  }

  void setSearchQuery(String query) {
    _searchQuery = query;
    notifyListeners();
  }

  Future<void> toggleProductStatus(String productId) async {
    try {
      // TODO: Implement API call to toggle product status
      final index = _products.indexWhere((p) => p.productId == productId);
      if (index != -1) {
        final product = _products[index];
        _products[index] = VendorProduct(
          productId: product.productId,
          vendorId: product.vendorId,
          name: product.name,
          category: product.category,
          description: product.description,
          howItWorks: product.howItWorks,
          usp: product.usp,
          price: product.price,
          images: product.images,
          isActive: !product.isActive,
          stock: product.stock,
          createdAt: product.createdAt,
          updatedAt: DateTime.now(),
        );
        notifyListeners();
      }
    } catch (e) {
      print('Error toggling product status: $e');
    }
  }

  Future<void> deleteProduct(String productId) async {
    try {
      // TODO: Implement API call to delete product
      _products.removeWhere((p) => p.productId == productId);
      notifyListeners();
    } catch (e) {
      print('Error deleting product: $e');
    }
  }
} 