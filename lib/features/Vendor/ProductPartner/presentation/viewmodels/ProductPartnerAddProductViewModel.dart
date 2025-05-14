import 'package:flutter/material.dart';
import 'package:vedika_healthcare/features/Vendor/Registration/Services/VendorLoginService.dart';
import 'dart:io';
import '../../data/models/VendorProduct.dart';
import '../../data/services/ProductPartnerProductService.dart';
import '../../data/services/ProductPartnerStorageService.dart';

class ProductPartnerAddProductViewModel extends ChangeNotifier {
  final ProductPartnerProductService _productService = ProductPartnerProductService();
  final ProductPartnerStorageService _storageService = ProductPartnerStorageService();
  
  bool _isLoading = false;
  String _error = '';
  final List<String> _categories = ['Period Care', 'Medicine', 'Diagnostic'];
  String _selectedCategory = 'Period Care';
  final List<String> _usp = [];
  final List<String> _images = [];
  final List<File> _tempImageFiles = []; // Store temporary files
  bool _isActive = true;
  final VendorLoginService _loginService = VendorLoginService();

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
    if (!_usp.contains(usp)) {
      _usp.add(usp);
      notifyListeners();
    }
  }

  void removeUSP(String usp) {
    _usp.remove(usp);
    notifyListeners();
  }

  Future<void> addImage(File imageFile) async {
    try {
      _tempImageFiles.add(imageFile);
      // Add a temporary URL for preview
      _images.add(imageFile.path);
      notifyListeners();
    } catch (e) {
      _error = e.toString();
      notifyListeners();
      throw Exception('Failed to add image: $e');
    }
  }

  Future<void> removeImage(int index) async {
    if (index >= 0 && index < _images.length) {
      _tempImageFiles.removeAt(index);
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
      String? vendorId = await _loginService.getVendorId();

      if (vendorId == null) {
        throw Exception('Vendor ID not found');
      }

      // Upload all images first
      final List<String> uploadedImageUrls = [];
      for (var imageFile in _tempImageFiles) {
        try {
          final imageUrl = await _storageService.uploadFile(imageFile);
          uploadedImageUrls.add(imageUrl);
        } catch (e) {
          throw Exception('Failed to upload image: $e');
        }
      }

      // Create product model with uploaded image URLs
      final product = VendorProduct(
        productId: DateTime.now().millisecondsSinceEpoch.toString(),
        vendorId: vendorId,
        name: name,
        category: _selectedCategory,
        description: description,
        howItWorks: howItWorks,
        usp: _usp,
        price: price,
        images: uploadedImageUrls,
        isActive: _isActive,
        stock: stock,
        createdAt: DateTime.now(),
        updatedAt: DateTime.now(),
      );

      // Call service to add product
      await _productService.addProduct(product);

      // Clear temporary files and images after successful creation
      _tempImageFiles.clear();
      _images.clear();
      
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

  Future<bool> updateProduct({
    required String productId,
    required String name,
    required String description,
    required String howItWorks,
    required double price,
    required int stock,
  }) async {
    try {
      print('Starting product update process...');
      _isLoading = true;
      _error = '';
      notifyListeners();

      print('Getting vendor ID...');
      String? vendorId = await _loginService.getVendorId();
      print('Vendor ID: $vendorId');
      
      if (vendorId == null) {
        print('Error: Vendor ID is null');
        throw Exception('Vendor ID not found');
      }

      print('Fetching existing product...');
      final existingProduct = await _productService.getProductById(productId);
      print('Existing product: ${existingProduct?.toJson()}');
      
      if (existingProduct == null) {
        print('Error: Existing product is null');
        throw Exception('Product not found');
      }

      print('Processing images...');
      print('Current images: $_images');
      print('Temp image files: ${_tempImageFiles.map((f) => f.path).toList()}');
      
      final List<String> finalImageUrls = [];
      
      for (var i = 0; i < _images.length; i++) {
        final imagePath = _images[i];
        print('Processing image $i: $imagePath');
        
        if (imagePath.startsWith('http')) {
          print('Keeping existing image URL: $imagePath');
          finalImageUrls.add(imagePath);
        } else if (i < _tempImageFiles.length) {
          try {
            print('Uploading new image: ${_tempImageFiles[i].path}');
            final imageUrl = await _storageService.uploadFile(_tempImageFiles[i]);
            print('New image uploaded successfully: $imageUrl');
            finalImageUrls.add(imageUrl);
          } catch (e) {
            print('Error uploading image: $e');
            throw Exception('Failed to upload image: $e');
          }
        }
      }

      print('Creating updated product model...');
      final updatedProduct = VendorProduct(
        productId: productId,
        vendorId: vendorId,
        name: name,
        category: _selectedCategory,
        description: description,
        howItWorks: howItWorks,
        usp: _usp,
        price: price,
        images: finalImageUrls,
        isActive: _isActive,
        stock: stock,
        createdAt: existingProduct.createdAt,
        updatedAt: DateTime.now(),
      );
      print('Updated product model: ${updatedProduct.toJson()}');

      print('Calling service to update product...');
      await _productService.updateProduct(productId, updatedProduct);
      print('Product updated successfully');

      print('Cleaning up...');
      _tempImageFiles.clear();
      _images.clear();
      
      _isLoading = false;
      notifyListeners();
      return true;
    } catch (e, stackTrace) {
      print('Error in updateProduct: $e');
      print('Stack trace: $stackTrace');
      _isLoading = false;
      _error = e.toString();
      notifyListeners();
      return false;
    }
  }
} 