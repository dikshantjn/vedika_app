import 'package:flutter/material.dart';
import 'package:vedika_healthcare/features/home/data/models/Product.dart';
import 'package:vedika_healthcare/features/home/data/services/ProductService.dart';

class ProductViewModel extends ChangeNotifier {
  List<Product> _products = [];
  String _selectedCategory = '';
  String _selectedSubCategory = '';
  String _searchQuery = '';
  bool _isLoading = false;
  String? _error;

  // Getters
  List<Product> get products => _products;
  String get selectedCategory => _selectedCategory;
  String get selectedSubCategory => _selectedSubCategory;
  String get searchQuery => _searchQuery;
  bool get isLoading => _isLoading;
  String? get error => _error;

  // Load products by category
  Future<void> loadProductsByCategory(String category) async {
    _isLoading = true;
    _error = null;
    _selectedCategory = category;
    _selectedSubCategory = '';
    notifyListeners();

    try {
      _products = ProductService.getProductsByCategory(category);
      _isLoading = false;
      notifyListeners();
    } catch (e) {
      _error = 'Failed to load products: ${e.toString()}';
      _isLoading = false;
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
      _products = ProductService.getProductsBySubCategory(subCategory);
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
    _isLoading = true;
    _error = null;
    _searchQuery = query;
    notifyListeners();

    try {
      _products = ProductService.searchProducts(query);
      _isLoading = false;
      notifyListeners();
    } catch (e) {
      _error = 'Failed to search products: ${e.toString()}';
      _isLoading = false;
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
  Product? getProductById(String id) {
    return ProductService.getProductById(id);
  }
} 