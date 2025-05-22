import 'package:flutter/material.dart';
import 'package:vedika_healthcare/features/Vendor/Registration/Services/VendorLoginService.dart';
import 'package:vedika_healthcare/features/Vendor/Service/VendorService.dart';

class AmbulanceMainViewModel extends ChangeNotifier {
  final VendorLoginService _loginService = VendorLoginService();
  final VendorService _vendorService = VendorService();
  
  bool _isActive = false;
  bool _isLoading = false;

  bool get isActive => _isActive;
  bool get isLoading => _isLoading;

  AmbulanceMainViewModel() {
    fetchVendorStatus();
  }

  Future<void> fetchVendorStatus() async {
    try {
      String? vendorId = await _loginService.getVendorId();
      if (vendorId != null) {
        _isActive = await _vendorService.getVendorStatus(vendorId);
        notifyListeners();
      }
    } catch (e) {
      print("Error fetching vendor status: $e");
    }
  }

  Future<bool> toggleVendorStatus() async {
    try {
      _isLoading = true;
      notifyListeners();
      
      String? vendorId = await _loginService.getVendorId();
      if (vendorId != null) {
        final status = await _vendorService.toggleVendorStatus(vendorId);
        _isActive = status;
        notifyListeners();
        return status;
      }
      return false;
    } catch (e) {
      print("Error toggling vendor status: $e");
      return false;
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }
}
