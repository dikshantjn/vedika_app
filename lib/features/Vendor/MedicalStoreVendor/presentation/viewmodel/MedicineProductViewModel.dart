import 'package:flutter/material.dart';
import 'package:dio/dio.dart';
import 'package:vedika_healthcare/features/Vendor/MedicalStoreVendor/data/models/MedicineProduct.dart';
import 'package:vedika_healthcare/features/Vendor/MedicalStoreVendor/data/services/MedicineProductService.dart';
import 'package:vedika_healthcare/features/Vendor/Registration/Services/VendorLoginService.dart';

class MedicineProductViewModel extends ChangeNotifier {
  final VendorLoginService _loginService = VendorLoginService();
  MedicineProductService? _medicineService; // Nullable until initialized

  List<MedicineProduct> _products = [];
  bool _isLoading = false;
  String? _errorMessage;

  List<MedicineProduct> get products => _products;
  bool get isLoading => _isLoading;
  String? get errorMessage => _errorMessage;

  // ✅ Constructor to initialize the token & service
  MedicineProductViewModel() {
    _initialize();
  }

  // 📌 Initialize token & medicine service
  Future<void> _initialize() async {
    try {
      String? token = await _loginService.getVendorToken();
      if (token != null) {
        _medicineService = MedicineProductService(token);
        await fetchProducts(); // Fetch products after initialization
      } else {
        _errorMessage = "Failed to retrieve token";
        debugPrint("Error: $_errorMessage");
        notifyListeners();
      }
    } catch (e) {
      _errorMessage = "Initialization error: ${e.toString()}";
      debugPrint("Error: $_errorMessage");
      notifyListeners();
    }
  }

  // 📌 Fetch All Products
  Future<void> fetchProducts() async {
    if (_medicineService == null) {
      debugPrint("Error: MedicineProductService is not initialized.");
      return;
    }

    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    try {
      Response response = await _medicineService!.getAllProducts();
      if (response.statusCode == 200) {
        _products = (response.data as List)
            .map((json) => MedicineProduct.fromJson(json))
            .toList();
      } else {
        _errorMessage = response.data['error'] ?? "Failed to load products";
        debugPrint("Error: $_errorMessage");
      }
    } catch (e) {
      _errorMessage = "Error fetching products: ${e.toString()}";
      debugPrint("Error: $_errorMessage");
    }

    _isLoading = false;
    notifyListeners();
  }

  Future<void> addProduct(MedicineProduct product) async {
    if (_medicineService == null) {
      debugPrint("Error: MedicineProductService is not initialized.");
      return;
    }

    _isLoading = true;
    notifyListeners();

    try {
      // Add product to the local list first to immediately reflect in UI
      _products.add(product);  // Add the new product to the list
      notifyListeners();  // Notify listeners to refresh the UI

      // Now, send the product data to the backend
      Response response = await _medicineService!.addProduct(product.toJson());
      if (response.statusCode == 201) {
        // If the product is successfully added, update it with the server's response
        _products.last = MedicineProduct.fromJson(response.data);
      } else {
        // If the product isn't added successfully, remove it from the list
        _products.remove(product);
        _errorMessage = response.data['error'] ?? "Failed to add product";
        debugPrint("Error: $_errorMessage");
      }
    } catch (e) {
      _errorMessage = "Error adding product: ${e.toString()}";
      debugPrint("Error: $_errorMessage");
    }

    _isLoading = false;
    notifyListeners();
  }


  // 📌 Edit Product
  Future<void> editProduct(String id, MedicineProduct updatedProduct) async {
    if (_medicineService == null) {
      debugPrint("Error: MedicineProductService is not initialized.");
      return;
    }

    _isLoading = true;
    notifyListeners();

    try {
      Response response = await _medicineService!.updateProduct(id, updatedProduct.toJson());
      if (response.statusCode == 200) {
        final index = _products.indexWhere((prod) => prod.productId == id);
        if (index != -1) {
          _products[index] = updatedProduct;
          notifyListeners(); // Ensure the UI updates after editing
        }
      } else {
        _errorMessage = response.data['error'] ?? "Failed to update product";
        debugPrint("Error: $_errorMessage");
      }
    } catch (e) {
      _errorMessage = "Error updating product: ${e.toString()}";
      debugPrint("Error: $_errorMessage");
    }

    _isLoading = false;
    notifyListeners();
  }

  // 📌 Delete Product
  Future<void> deleteProduct(String id) async {
    if (_medicineService == null) {
      debugPrint("Error: MedicineProductService is not initialized.");
      return;
    }

    _isLoading = true;
    notifyListeners();

    try {
      Response response = await _medicineService!.deleteProduct(id);
      if (response.statusCode == 200) {
        _products.removeWhere((prod) => prod.productId == id);
        notifyListeners(); // Ensure the UI updates after deletion
      } else {
        _errorMessage = response.data['error'] ?? "Failed to delete product";
        debugPrint("Error: $_errorMessage");
      }
    } catch (e) {
      _errorMessage = "Error deleting product: ${e.toString()}";
      debugPrint("Error: $_errorMessage");
    }

    _isLoading = false;
    notifyListeners();
  }
}
