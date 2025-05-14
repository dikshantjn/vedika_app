import 'package:flutter/material.dart';
import '../../data/models/VendorProduct.dart';
import '../../data/services/ProductPartnerProductService.dart';

class ProductPartnerAddProductViewModel extends ChangeNotifier {
  final ProductPartnerProductService _productService = ProductPartnerProductService();
  
  bool _isLoading = false;
  String _error = '';
  final List<String> _categories = ['Period Care', 'Medicine', 'Diagnostic'];
  String _selectedCategory = 'Period Care';
  final List<String> _usp = [];
  final List<String> _images = [];
  bool _isActive = true;

  // Getters
  bool get isLoading => _isLoading;
  String get error => _error;
  List<String> get categories => _categories;
  String get selectedCategory => _selectedCategory;
  List<String> get usp => _usp;
  List<String> get images => _images;
  bool get isActive => _isActive;

  // Setters
  void setCategory(String category) {
    _selectedCategory = category;
    notifyListeners();
  }

  void setActive(bool value) {
    _isActive = value;
    notifyListeners();
  }

  void addUSP(String usp) {
    _usp.add(usp);
    notifyListeners();
  }

  void removeUSP(String usp) {
    _usp.remove(usp);
    notifyListeners();
  }

  void addImage(String imageUrl) {
    _images.add(imageUrl);
    notifyListeners();
  }

  void removeImage(int index) {
    if (index >= 0 && index < _images.length) {
      _images.removeAt(index);
      notifyListeners();
    }
  }

  Future<bool> createProduct({
    required String name,
    required String description,
    required String howItWorks,
    required double price,
    required int stock,
  }) async {
    try {
      _isLoading = true;
      _error = '';
      notifyListeners();

      // Create product model
      final product = VendorProduct(
        productId: DateTime.now().millisecondsSinceEpoch.toString(),
        vendorId: 'v1', // TODO: Get from auth
        name: name,
        category: _selectedCategory,
        description: description,
        howItWorks: howItWorks,
        usp: _usp,
        price: price,
        images: _images,
        isActive: _isActive,
        stock: stock,
        createdAt: DateTime.now(),
        updatedAt: DateTime.now(),
      );

      // Call service to add product
      await _productService.addProduct(product);

      _isLoading = false;
      notifyListeners();
      return true;
    } catch (e) {
      _isLoading = false;
      _error = e.toString();
      notifyListeners();
      return false;
    }
  }
} 