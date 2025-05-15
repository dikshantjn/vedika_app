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
  final List<String> _categories = [
    'Dental Care',
    'Genetic Testing',
    'Heart Care',
    'Baby Care',
    'Elder Care',
    'Women Care',
    'Digital Health Tracker',
    'Digital Health Ring',
    'Epilepsy Care',
    'UTI Test Kit',
    'Wellness Care Kit',
    'Pregnancy Care',
    'Wound Care',
    'Portable ECG',
    'Period Care'
  ];
  String _selectedCategory = 'Dental Care';
  final List<String> _usp = [];
  final List<String> _images = [];
  final List<File> _tempImageFiles = [];
  bool _isActive = true;
  final VendorLoginService _loginService = VendorLoginService();

  // New fields
  String? _demoLink;
  String? _videoUrl;
  final List<String> _highlights = [];
  bool _comingSoon = false;
  final List<PriceTier> _priceTiers = [];
  String? _subCategory;
  double _rating = 0.0;
  int _reviewCount = 0;
  Map<String, dynamic>? _specifications;
  final List<String> _additionalImages = [];
  final List<File> _tempAdditionalImageFiles = [];

  // Getters
  bool get isLoading => _isLoading;
  String get error => _error;
  List<String> get categories => _categories;
  String get selectedCategory => _selectedCategory;
  List<String> get usp => _usp;
  List<String> get images => _images;
  bool get isActive => _isActive;
  // New getters
  String? get demoLink => _demoLink;
  String? get videoUrl => _videoUrl;
  List<String> get highlights => _highlights;
  bool get comingSoon => _comingSoon;
  List<PriceTier> get priceTiers => _priceTiers;
  String? get subCategory => _subCategory;
  double get rating => _rating;
  int get reviewCount => _reviewCount;
  Map<String, dynamic>? get specifications => _specifications;
  List<String> get additionalImages => _additionalImages;

  // Setters
  void setCategory(String category) {
    _selectedCategory = category;
    notifyListeners();
  }

  void setActive(bool value) {
    _isActive = value;
    notifyListeners();
  }

  // New setters
  void setDemoLink(String? value) {
    _demoLink = value;
    notifyListeners();
  }

  void setVideoUrl(String? value) {
    _videoUrl = value;
    notifyListeners();
  }

  void setComingSoon(bool value) {
    _comingSoon = value;
    notifyListeners();
  }

  void setSubCategory(String? value) {
    _subCategory = value;
    notifyListeners();
  }

  void setRating(double value) {
    _rating = value;
    notifyListeners();
  }

  void setReviewCount(int value) {
    _reviewCount = value;
    notifyListeners();
  }

  void setSpecifications(Map<String, dynamic>? value) {
    _specifications = value;
    notifyListeners();
  }

  void addHighlight(String highlight) {
    if (!_highlights.contains(highlight)) {
      _highlights.add(highlight);
      notifyListeners();
    }
  }

  void removeHighlight(String highlight) {
    _highlights.remove(highlight);
    notifyListeners();
  }

  void addPriceTier(PriceTier tier) {
    _priceTiers.add(tier);
    notifyListeners();
  }

  void removePriceTier(int index) {
    if (index >= 0 && index < _priceTiers.length) {
      _priceTiers.removeAt(index);
      notifyListeners();
    }
  }

  Future<void> addAdditionalImage(File imageFile) async {
    try {
      _tempAdditionalImageFiles.add(imageFile);
      _additionalImages.add(imageFile.path);
      notifyListeners();
    } catch (e) {
      _error = e.toString();
      notifyListeners();
      throw Exception('Failed to add additional image: $e');
    }
  }

  Future<void> removeAdditionalImage(int index) async {
    if (index >= 0 && index < _additionalImages.length) {
      _tempAdditionalImageFiles.removeAt(index);
      _additionalImages.removeAt(index);
      notifyListeners();
    }
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

      // Upload additional images
      final List<String> uploadedAdditionalImageUrls = [];
      for (var imageFile in _tempAdditionalImageFiles) {
        try {
          final imageUrl = await _storageService.uploadFile(imageFile);
          uploadedAdditionalImageUrls.add(imageUrl);
        } catch (e) {
          throw Exception('Failed to upload additional image: $e');
        }
      }

      // Create product model with all fields
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
        // New fields
        demoLink: _demoLink,
        videoUrl: _videoUrl,
        highlights: _highlights,
        comingSoon: _comingSoon,
        priceTiers: _priceTiers.isNotEmpty ? _priceTiers : null,
        subCategory: _subCategory,
        rating: _rating,
        reviewCount: _reviewCount,
        specifications: _specifications,
        additionalImages: uploadedAdditionalImageUrls.isNotEmpty ? uploadedAdditionalImageUrls : null,
      );

      // Call service to add product
      await _productService.addProduct(product);

      // Clear all temporary data
      _tempImageFiles.clear();
      _images.clear();
      _tempAdditionalImageFiles.clear();
      _additionalImages.clear();
      _highlights.clear();
      _priceTiers.clear();
      
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
      _isLoading = true;
      _error = '';
      notifyListeners();

      String? vendorId = await _loginService.getVendorId();
      if (vendorId == null) {
        throw Exception('Vendor ID not found');
      }

      final existingProduct = await _productService.getProductById(productId);
      if (existingProduct == null) {
        throw Exception('Product not found');
      }

      // Process main images
      final List<String> finalImageUrls = [];
      for (var i = 0; i < _images.length; i++) {
        final imagePath = _images[i];
        if (imagePath.startsWith('http')) {
          finalImageUrls.add(imagePath);
        } else if (i < _tempImageFiles.length) {
          final imageUrl = await _storageService.uploadFile(_tempImageFiles[i]);
          finalImageUrls.add(imageUrl);
        }
      }

      // Process additional images
      final List<String> finalAdditionalImageUrls = [];
      for (var i = 0; i < _additionalImages.length; i++) {
        final imagePath = _additionalImages[i];
        if (imagePath.startsWith('http')) {
          finalAdditionalImageUrls.add(imagePath);
        } else if (i < _tempAdditionalImageFiles.length) {
          final imageUrl = await _storageService.uploadFile(_tempAdditionalImageFiles[i]);
          finalAdditionalImageUrls.add(imageUrl);
        }
      }

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
        // New fields
        demoLink: _demoLink,
        videoUrl: _videoUrl,
        highlights: _highlights,
        comingSoon: _comingSoon,
        priceTiers: _priceTiers.isNotEmpty ? _priceTiers : null,
        subCategory: _subCategory,
        rating: _rating,
        reviewCount: _reviewCount,
        specifications: _specifications,
        additionalImages: finalAdditionalImageUrls.isNotEmpty ? finalAdditionalImageUrls : null,
      );

      await _productService.updateProduct(productId, updatedProduct);

      // Clear temporary data
      _tempImageFiles.clear();
      _images.clear();
      _tempAdditionalImageFiles.clear();
      _additionalImages.clear();
      
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