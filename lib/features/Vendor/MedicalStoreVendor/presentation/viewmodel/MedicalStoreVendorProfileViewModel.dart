import 'package:flutter/material.dart';
import 'package:vedika_healthcare/features/Vendor/Registration/MedicalRegistration/Service/MedicalStoreVendorService.dart';
import 'package:vedika_healthcare/features/Vendor/Registration/Models/VendorMedicalStoreProfile.dart';
import 'package:vedika_healthcare/features/Vendor/Registration/Services/VendorLoginService.dart';

class MedicalStoreVendorProfileViewModel extends ChangeNotifier {
  VendorMedicalStoreProfile? _profile;
  final MedicalStoreVendorService _service = MedicalStoreVendorService();
  final VendorLoginService _loginService = VendorLoginService(); // Vendor Login Service
  bool _isLoading = false;
  String? _errorMessage;

  VendorMedicalStoreProfile? get profile => _profile;
  bool get isLoading => _isLoading;
  String? get errorMessage => _errorMessage;

  Future<void> fetchProfileData() async {
    if (_isLoading) return; // Prevent multiple calls
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    try {
      // **🔹 Get JWT Token from Storage**
      String? token = await _loginService.getVendorToken();

      if (token == null) {
        _errorMessage = "Vendor Token not found";
        print("❌ Error: $_errorMessage");  // 🔹 Print error
      } else {
        _profile = await _service.fetchVendorProfile(token);

        if (_profile == null) {
          _errorMessage = "Vendor Profile is null after fetching";
          print("❌ Error: $_errorMessage");
        } else {
          print("✅ Vendor Profile Fetched Successfully: $_profile");
        }
      }
    } catch (error, stackTrace) {
      _errorMessage = error.toString();
      print("❌ Exception in fetchProfileData: $_errorMessage");
      print(stackTrace);  // 🔹 Print stack trace for debugging
    }

    _isLoading = false;
    notifyListeners();
  }

}
