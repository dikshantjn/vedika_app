import 'package:flutter/material.dart';
import 'package:vedika_healthcare/features/Vendor/BloodBankAgencyVendor/data/services/BloodBankRegistrationService.dart';
import 'package:logger/logger.dart';

class VendorBloodBankMainViewModel extends ChangeNotifier {
  final Logger logger = Logger();
  final BloodBankRegistrationService _bloodBankService = BloodBankRegistrationService();

  bool _isServiceActive = false;
  bool _isLoading = false;
  String? _errorMessage;

  // Getters
  bool get isServiceActive => _isServiceActive;
  bool get isLoading => _isLoading;
  String? get errorMessage => _errorMessage;

  // Initialize the service status
  Future<void> initializeServiceStatus() async {
    _isLoading = true;
    notifyListeners();

    try {
      // TODO: Replace with actual API call to get service status
      // final response = await _bloodBankService.getServiceStatus();
      // _isServiceActive = response['isActive'];
      
      // Mock data for now
      _isServiceActive = true;
      
      _isLoading = false;
      notifyListeners();
    } catch (e) {
      logger.e('Error initializing service status: $e');
      _errorMessage = 'Failed to load service status';
      _isLoading = false;
      notifyListeners();
    }
  }

  // Toggle service status
  Future<void> toggleServiceStatus() async {
    _isLoading = true;
    notifyListeners();

    try {
      // TODO: Replace with actual API call to toggle service status
      // await _bloodBankService.updateServiceStatus(!_isServiceActive);
      
      // Mock data for now
      _isServiceActive = !_isServiceActive;
      
      _isLoading = false;
      notifyListeners();
    } catch (e) {
      logger.e('Error toggling service status: $e');
      _errorMessage = 'Failed to update service status';
      _isLoading = false;
      notifyListeners();
    }
  }

  // Clear error message
  void clearError() {
    _errorMessage = null;
    notifyListeners();
  }
} 