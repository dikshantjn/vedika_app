import 'package:flutter/material.dart';
import 'package:vedika_healthcare/features/Vendor/ProductPartner/data/models/VendorProduct.dart';
import 'package:vedika_healthcare/features/home/data/services/ScannerService.dart';
import 'package:logger/logger.dart';

class ScannerViewModel extends ChangeNotifier {
  final ScannerService _scannerService = ScannerService();
  final Logger _logger = Logger();
  List<VendorProduct> _scannedProducts = [];
  bool _isLoading = false;
  String? _error;

  List<VendorProduct> get scannedProducts => _scannedProducts;
  bool get isLoading => _isLoading;
  String? get error => _error;

  Future<void> scanPrescription(String imagePath) async {
    try {
      _logger.i('Starting prescription scan for image: $imagePath');
      _isLoading = true;
      _error = null;
      notifyListeners();

      _scannedProducts = await _scannerService.scanPrescription(imagePath);
      _logger.i('Scan completed successfully. Found ${_scannedProducts.length} products');
      _isLoading = false;
      notifyListeners();
    } catch (e) {
      _logger.e('Error in scanPrescription: $e');
      _isLoading = false;
      _error = e.toString();
      notifyListeners();
    }
  }

  void clearScan() {
    _logger.i('Clearing scan results');
    _scannedProducts = [];
    _error = null;
    notifyListeners();
  }
} 