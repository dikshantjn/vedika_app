import 'package:flutter/material.dart';
import 'package:vedika_healthcare/features/Vendor/Registration/Services/VendorLoginService.dart';
import 'package:vedika_healthcare/features/Vendor/Service/VendorService.dart';

class AmbulanceMainViewModel extends ChangeNotifier {
  final VendorLoginService _loginService = VendorLoginService();
  final VendorService _vendorService = VendorService();
  bool _isActive = false;
  bool get isActive => _isActive;

  Future<void> fetchVendorStatus() async {

    String? vendorId = await _loginService.getVendorId();
    _isActive = await _vendorService.getVendorStatus(vendorId!);
    notifyListeners();
  }

  Future<bool> toggleVendorStatus() async {
    String? vendorId = await _loginService.getVendorId();
    final status = await _vendorService.toggleVendorStatus(vendorId!);
    _isActive = status;
    notifyListeners();
    return status;
  }
}
