import 'dart:io';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:vedika_healthcare/core/auth/data/services/StorageService.dart';
import 'package:vedika_healthcare/features/userProfile/data/models/PersonalProfile.dart';
import 'package:vedika_healthcare/features/userProfile/data/services/UserProfileService.dart';

class UserPersonalProfileViewModel extends ChangeNotifier {
  final UserProfileService _userProfileService = UserProfileService();
  PersonalProfile? _personalProfile;
  bool _isProfileUpdated = false;
  bool _isUploading = false;

  PersonalProfile? get personalProfile => _personalProfile;
  bool get isProfileUpdated => _isProfileUpdated;
  bool get isUploading => _isUploading;

  Future<void> fetchUserProfile() async {
    String? userId = await StorageService.getUserId();
    if (userId != null) {
      _personalProfile = await _userProfileService.getUserProfile(userId);
      _isProfileUpdated = false;
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

  Future<bool> editUserProfile(PersonalProfile profile, {File? profileImage}) async {
    String? userId = await StorageService.getUserId();
    if (userId == null) return false;

    try {
      _isUploading = true;
      notifyListeners();

      String? photoUrl = profile.photoUrl;
      
      // If there's a new profile image, upload it
      if (profileImage != null) {
        photoUrl = await _userProfileService.uploadProfilePicture(profileImage, userId);
        if (photoUrl == null) {
          _isUploading = false;
          notifyListeners();
          return false;
        }
      }

      // Create updated profile with new photo URL
      final updatedProfile = PersonalProfile(
        name: profile.name,
        photoUrl: photoUrl ?? profile.photoUrl,
        phoneNumber: profile.phoneNumber,
        abhaId: profile.abhaId,
        email: profile.email,
        dateOfBirth: profile.dateOfBirth,
        gender: profile.gender,
        bloodGroup: profile.bloodGroup,
        height: profile.height,
        weight: profile.weight,
        emergencyContactNumber: profile.emergencyContactNumber,
        location: profile.location,
      );

      bool success = await _userProfileService.editUserProfile(userId, updatedProfile);
      if (success) {
        _personalProfile = updatedProfile;
        _isProfileUpdated = true;
        notifyListeners();
      }

      _isUploading = false;
      notifyListeners();
      return success;
    } catch (e) {
      print("Error in editUserProfile: $e");
      _isUploading = false;
      notifyListeners();
      return false;
    }
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

