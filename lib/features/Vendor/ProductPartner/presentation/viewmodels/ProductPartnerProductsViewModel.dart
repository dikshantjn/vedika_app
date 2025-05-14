import 'package:flutter/material.dart';
import 'package:vedika_healthcare/features/Vendor/Registration/Services/VendorLoginService.dart';
import '../../data/models/VendorProduct.dart';
import '../../data/services/ProductPartnerProductService.dart';

class ProductPartnerProductsViewModel extends ChangeNotifier {
  final ProductPartnerProductService _productService = ProductPartnerProductService();
  bool _isLoading = false;
  List<VendorProduct> _products = [];
  String _selectedCategory = 'All';
  String _searchQuery = '';
  List<String> _categories = ['All', 'Period Care', 'Medicine', 'Diagnostic'];
  String? _error;
  final VendorLoginService _loginService = VendorLoginService();

  // Getters
  bool get isLoading => _isLoading;
  List<VendorProduct> get products => _filteredProducts;
  String get selectedCategory => _selectedCategory;
  String get searchQuery => _searchQuery;
  List<String> get categories => _categories;
  String? get error => _error;

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
    _error = null;
    notifyListeners();
    String? vendorId = await _loginService.getVendorId();

    try {
      _products = await _productService.getVendorProducts(vendorId!);
      // Update categories based on available products
      _updateCategories();
    } catch (e) {
      _error = e.toString();
      print('Error fetching products: $e');
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  void _updateCategories() {
    final Set<String> uniqueCategories = _products.map((p) => p.category).toSet();
    _categories = ['All', ...uniqueCategories.toList()];
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
      _isLoading = true;
      _error = null;
      notifyListeners();

      // Call service to delete product
      await _productService.deleteProduct(productId);
      
      // Remove product from local list
      _products.removeWhere((p) => p.productId == productId);
      _updateCategories(); // Update categories after deletion
      
      _isLoading = false;
      notifyListeners();
    } catch (e) {
      _isLoading = false;
      _error = e.toString();
      notifyListeners();
      throw Exception('Failed to delete product: $e');
    }
  }
} 