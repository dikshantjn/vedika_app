import 'package:flutter/material.dart';
import 'package:vedika_healthcare/features/Vendor/Registration/Services/VendorLoginService.dart';
import 'package:vedika_healthcare/features/Vendor/Service/VendorService.dart';

class VendorBloodBankMainViewModel extends ChangeNotifier {
  final VendorService _statusService = VendorService();
  final VendorLoginService _loginService = VendorLoginService();

  bool _isServiceActive = false;
  bool _isLoading = false;
  String? _error;
  bool _isToggling = false;

  bool get isServiceActive => _isServiceActive;
  bool get isLoading => _isLoading;
  String? get error => _error;
  bool get isToggling => _isToggling;

  Future<void> initializeServiceStatus() async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      String? vendorId = await _loginService.getVendorId();
      if (vendorId == null) {
        throw Exception('Vendor ID not found');
      }
      
      final status = await _statusService.getVendorStatus(vendorId);
      _isServiceActive = status;
      _error = null;
    } catch (e) {
      _error = e.toString();
      _isServiceActive = false;
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<void> toggleServiceStatus() async {
    if (_isToggling) return; // Prevent multiple simultaneous toggles
    
    _isToggling = true;
    _error = null;
    notifyListeners();

    try {
      String? vendorId = await _loginService.getVendorId();
      if (vendorId == null) {
        throw Exception('Vendor ID not found');
      }
      
      // Optimistically update the UI
      _isServiceActive = !_isServiceActive;
      notifyListeners();
      
      // Perform the actual toggle
      final newStatus = await _statusService.toggleVendorStatus(vendorId);
      
      // Update with the actual status from the server
      _isServiceActive = newStatus;
      _error = null;
    } catch (e) {
      // Revert the optimistic update on error
      _isServiceActive = !_isServiceActive;
      _error = e.toString();
    } finally {
      _isToggling = false;
      notifyListeners();
    }
  }
} 