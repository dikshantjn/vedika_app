import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:vedika_healthcare/core/auth/data/services/StorageService.dart';
import 'package:vedika_healthcare/features/userProfile/data/models/PersonalProfile.dart';
import 'package:vedika_healthcare/features/userProfile/data/services/UserProfileService.dart';

class UserPersonalProfileViewModel extends ChangeNotifier {
  final UserProfileService _userProfileService = UserProfileService();
  PersonalProfile? _personalProfile;
  bool _isProfileUpdated = false;  // New variable to track profile update status

  PersonalProfile? get personalProfile => _personalProfile;
  bool get isProfileUpdated => _isProfileUpdated;  // Getter for isProfileUpdated

  Future<void> fetchUserProfile() async {
    String? userId = await StorageService.getUserId();
    if (userId != null) {
      _personalProfile = await _userProfileService.getUserProfile(userId);
      _isProfileUpdated = false;  // Reset to false when profile is fetched
      notifyListeners();
    }
  }

  Future<bool> saveUserProfile(PersonalProfile profile) async {
    bool success = await _userProfileService.saveUserProfile(profile);
    if (success) {
      _personalProfile = profile;
      notifyListeners();
    }
    return success;
  }

  Future<bool> editUserProfile(PersonalProfile profile) async {
    String? userId = await StorageService.getUserId();
    if (userId == null) return false;

    bool success = await _userProfileService.editUserProfile(userId, profile);
    if (success) {
      _personalProfile = profile;
      _isProfileUpdated = true;  // Set to true when profile is edited
      notifyListeners();
    }
    return success;
  }

  String get formattedDateOfBirth {
    return _personalProfile != null
        ? DateFormat('M/d/yyyy').format(_personalProfile!.dateOfBirth)
        : '';
  }

  double calculateProfileCompletion() {
    if (_personalProfile == null) return 0.0;
    int completedFields = 0;

    if (_personalProfile!.name.isNotEmpty) completedFields++;
    if (_personalProfile!.email.isNotEmpty) completedFields++;
    if (_personalProfile!.phoneNumber.isNotEmpty) completedFields++;
    if (_personalProfile!.location.isNotEmpty) completedFields++;
    if (_personalProfile!.dateOfBirth != null) completedFields++;
    if (_personalProfile!.gender.isNotEmpty) completedFields++;
    if (_personalProfile!.bloodGroup.isNotEmpty) completedFields++;
    if (_personalProfile!.height != null) completedFields++;
    if (_personalProfile!.weight != null) completedFields++;
    if (_personalProfile!.emergencyContactNumber.isNotEmpty) completedFields++;

    return completedFields / 10.0;
  }

  bool isProfileComplete() {
    if (_personalProfile == null) return false;
    return _personalProfile!.name.isNotEmpty &&
        _personalProfile!.email.isNotEmpty &&
        _personalProfile!.phoneNumber.isNotEmpty &&
        _personalProfile!.location.isNotEmpty &&
        _personalProfile!.dateOfBirth != null &&
        _personalProfile!.gender.isNotEmpty &&
        _personalProfile!.bloodGroup.isNotEmpty &&
        _personalProfile!.height != null &&
        _personalProfile!.weight != null &&
        _personalProfile!.emergencyContactNumber.isNotEmpty;
  }
}

