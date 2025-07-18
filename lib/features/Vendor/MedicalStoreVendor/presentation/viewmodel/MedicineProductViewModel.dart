import 'package:flutter/material.dart';
import 'package:vedika_healthcare/features/Vendor/MedicalStoreVendor/data/models/MedicineProduct.dart';
import 'package:vedika_healthcare/features/Vendor/MedicalStoreVendor/data/services/MedicineProductService.dart';
import 'package:vedika_healthcare/features/Vendor/Registration/Services/VendorLoginService.dart';

class MedicineProductViewModel extends ChangeNotifier {
  final VendorLoginService _loginService = VendorLoginService();
  final MedicineProductService _medicineService = MedicineProductService();

  List<MedicineProduct> _products = [];
  List<MedicineProduct> _filteredProducts = [];
  bool _isLoading = false;
  String? _errorMessage;
  String _searchQuery = '';

  List<MedicineProduct> get products => _searchQuery.isEmpty ? _products : _filteredProducts;
  bool get isLoading => _isLoading;
  String? get errorMessage => _errorMessage;
  String get searchQuery => _searchQuery;

  // ✅ Search Products
  void searchProducts(String query) {
    _searchQuery = query;
    if (query.isEmpty) {
      _filteredProducts = [];
    } else {
      _filteredProducts = _products.where((product) {
        return product.name.toLowerCase().contains(query.toLowerCase()) ||
               product.manufacturer.toLowerCase().contains(query.toLowerCase()) ||
               product.type.toLowerCase().contains(query.toLowerCase()) ||
               product.shortComposition.toLowerCase().contains(query.toLowerCase());
      }).toList();
    }
    notifyListeners();
  }

  // ✅ Clear Search
  void clearSearch() {
    _searchQuery = '';
    _filteredProducts = [];
    notifyListeners();
  }

  // ✅ Fetch All Products
  Future<void> fetchProducts() async {
    String? vendorId = await VendorLoginService().getVendorId();

    if (vendorId == null) {
      _errorMessage = "Vendor ID not set";
      notifyListeners();
      return;
    }

    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    try {
      String? token = await _loginService.getVendorToken();
      if (token == null) throw Exception("Failed to retrieve token");

      _products = await _medicineService.getAllProducts(token, vendorId);
      _filteredProducts = [];
    } catch (e) {
      _errorMessage = "Error fetching products: ${e.toString()}";
    }

    _isLoading = false;
    notifyListeners();
  }

  // ✅ Add Product
  Future<void> addProduct(MedicineProduct product) async {
    _isLoading = true;
    notifyListeners();

    try {
      String? token = await _loginService.getVendorToken();
      if (token == null) throw Exception("Failed to retrieve token");

      MedicineProduct newProduct = await _medicineService.addProduct(token, product);
      _products.add(newProduct);
    } catch (e) {
      _errorMessage = "Error adding product: ${e.toString()}";
    }

    _isLoading = false;
    notifyListeners();
  }

  // ✅ Edit Product
  Future<void> editProduct(String id, MedicineProduct updatedProduct) async {
    _isLoading = true;
    notifyListeners();

    try {
      String? token = await _loginService.getVendorToken();
      if (token == null) throw Exception("Failed to retrieve token");

      MedicineProduct newProduct = await _medicineService.updateProduct(token, id, updatedProduct);
      final index = _products.indexWhere((prod) => prod.productId == id);
      if (index != -1) {
        _products[index] = newProduct;
      }
    } catch (e) {
      _errorMessage = "Error updating product: ${e.toString()}";
    }

    _isLoading = false;
    notifyListeners();
  }

  // ✅ Delete Product
  Future<void> deleteProduct(String id) async {
    _isLoading = true;
    notifyListeners();

    try {
      String? token = await _loginService.getVendorToken();
      if (token == null) throw Exception("Failed to retrieve token");

      await _medicineService.deleteProduct(token, id);
      _products.removeWhere((prod) => prod.productId == id);
    } catch (e) {
      _errorMessage = "Error deleting product: ${e.toString()}";
    }

    _isLoading = false;
    notifyListeners();
  }
}
