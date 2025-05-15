import 'package:flutter/material.dart';
import 'package:vedika_healthcare/features/Vendor/ProductPartner/data/models/VendorProduct.dart';
import 'package:vedika_healthcare/features/home/data/services/ProductService.dart';

class ProductViewModel extends ChangeNotifier {
  final ProductService _productService = ProductService();
  List<VendorProduct> _products = [];
  String _selectedCategory = '';
  String _selectedSubCategory = '';
  String _searchQuery = '';
  bool _isLoading = false;
  String? _error;

  // Getters
  List<VendorProduct> get products => _products;
  String get selectedCategory => _selectedCategory;
  String get selectedSubCategory => _selectedSubCategory;
  String get searchQuery => _searchQuery;
  bool get isLoading => _isLoading;
  String? get error => _error;

  // Load products by category
  Future<void> loadProductsByCategory(String category) async {
    try {
      _isLoading = true;
      _error = null;
      notifyListeners();

      _products = await _productService.getProductsByCategory(category);
      
      _isLoading = false;
      notifyListeners();
    } catch (e) {
      _isLoading = false;
      _error = e.toString();
      notifyListeners();
    }
  }

  // Load products by subcategory
  Future<void> loadProductsBySubCategory(String subCategory) async {
    _isLoading = true;
    _error = null;
    _selectedSubCategory = subCategory;
    notifyListeners();

    try {
      _products = await _productService.getProductsBySubCategory(subCategory);
      _isLoading = false;
      notifyListeners();
    } catch (e) {
      _error = 'Failed to load products: ${e.toString()}';
      _isLoading = false;
      notifyListeners();
    }
  }

  // Search products
  Future<void> searchProducts(String query) async {
    try {
      _isLoading = true;
      _error = null;
      notifyListeners();

      _products = await _productService.searchProducts(query);
      
      _isLoading = false;
      notifyListeners();
    } catch (e) {
      _isLoading = false;
      _error = e.toString();
      notifyListeners();
    }
  }

  // Clear search
  void clearSearch() {
    _searchQuery = '';
    if (_selectedCategory.isNotEmpty) {
      loadProductsByCategory(_selectedCategory);
    } else {
      _products = [];
      notifyListeners();
    }
  }

  // Get product by ID
  Future<VendorProduct?> getProductById(String id) async {
    try {
      return await _productService.getProductById(id);
    } catch (e) {
      _error = e.toString();
      notifyListeners();
      return null;
    }
  }
} 