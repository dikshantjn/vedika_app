import 'package:flutter/material.dart';
import 'package:vedika_healthcare/core/auth/data/services/StorageService.dart';
import 'package:vedika_healthcare/features/userProfile/data/models/MedicalProfile.dart';
import 'package:vedika_healthcare/features/userProfile/data/services/MedicalProfileService.dart';

class UserMedicalProfileViewModel extends ChangeNotifier {
  final MedicalProfileService _medicalProfileService = MedicalProfileService();

  MedicalProfile? _medicalProfile;
  bool _isLoading = false;
  String? _errorMessage;

  // Getters
  MedicalProfile? get medicalProfile => _medicalProfile;
  bool get isLoading => _isLoading;
  String? get errorMessage => _errorMessage;

  // ✅ Set loading state
  void _setLoading(bool value) {
    _isLoading = value;
    notifyListeners();
  }

  // ✅ Set error message
  void _setError(String? message) {
    _errorMessage = message;
    notifyListeners();
  }

  // ✅ Fetch Medical Profile from API
  Future<void> fetchMedicalProfile() async {
    _setLoading(true);
    _setError(null);

    try {
      String? userId = await StorageService.getUserId();
      if (userId != null) {
        _medicalProfile = await _medicalProfileService.getMedicalProfile(userId);
      } else {
        _setError("User ID not found");
      }
    } catch (e) {
      _setError("Failed to load medical profile: $e");
    } finally {
      // Ensure notifyListeners is called after the build phase
      WidgetsBinding.instance.addPostFrameCallback((_) {
        _setLoading(false); // Final state update after build phase
      });
    }
  }

  // ✅ Create Medical Profile
  Future<void> createMedicalProfile(MedicalProfile profile) async {
    _setLoading(true);
    _setError(null);

    try {
      _medicalProfile = await _medicalProfileService.createMedicalProfile(profile);
    } catch (e) {
      _setError("Failed to create medical profile: $e");
    } finally {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        _setLoading(false); // Final state update after build phase
      });
    }
  }

  // ✅ Update Medical Profile
  Future<void> updateMedicalProfile(MedicalProfile updatedProfile) async {
    _setLoading(true);
    _setError(null);

    try {
      String? userId = await StorageService.getUserId();
      if (userId != null) {
        _medicalProfile = await _medicalProfileService.updateMedicalProfile(userId, updatedProfile);
      } else {
        _setError("User ID not found");
      }
    } catch (e) {
      _setError("Failed to update medical profile: $e");
    } finally {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        _setLoading(false); // Final state update after build phase
      });
    }
  }

  // ✅ Delete Medical Profile
  Future<void> deleteMedicalProfile() async {
    _setLoading(true);
    _setError(null);

    try {
      String? userId = await StorageService.getUserId();
      if (userId != null) {
        await _medicalProfileService.deleteMedicalProfile(userId);
        _medicalProfile = null; // Clear the profile after deletion
      } else {
        _setError("User ID not found");
      }
    } catch (e) {
      _setError("Failed to delete medical profile: $e");
    } finally {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        _setLoading(false); // Final state update after build phase
      });
    }
  }
}