import 'package:flutter/material.dart';
import 'package:vedika_healthcare/core/auth/data/services/UserService.dart';
import 'package:vedika_healthcare/core/auth/data/models/UserModel.dart';

class UserViewModel extends ChangeNotifier {
  UserModel? _user;
  bool _isLoading = true;

  // Getter for user
  UserModel? get user => _user;
  bool get isLoading => _isLoading;

  Future<void> fetchUserDetails(String userId) async {
    try {
      _isLoading = true;
      notifyListeners(); // Start loading

      UserModel? fetchedUser = await UserService().getUserById(userId);
      if (fetchedUser != null) {
        _user = fetchedUser;
      }

    } catch (error) {
      print("Error fetching user details: $error");
    } finally {
      _isLoading = false;
      notifyListeners(); // Ensure UI updates
    }
  }


  // Method to calculate the profile completion percentage
  double calculateProfileCompletion() {
    if (_user == null) return 0.0;

    // List of all fields to check if they are filled
    List<bool> requiredFields = [
      _user!.name != null && _user!.name!.isNotEmpty,
      _user!.phoneNumber != null,
      _user!.abhaId != null && _user!.abhaId!.isNotEmpty,
      _user!.emailId != null && _user!.emailId!.isNotEmpty,
      _user!.dateOfBirth != null,
      _user!.gender != null && _user!.gender!.isNotEmpty,
      _user!.bloodGroup != null && _user!.bloodGroup!.isNotEmpty,
      _user!.height != null,
      _user!.weight != null,
      _user!.emergencyContactNumber != null && _user!.emergencyContactNumber!.isNotEmpty,
      _user!.location != null && _user!.location!.isNotEmpty,
      _user!.city != null && _user!.city!.isNotEmpty,
    ];

    // Count how many fields are filled
    int filledFields = requiredFields.where((isFilled) => isFilled).length;

    // Calculate profile completion percentage
    return filledFields / requiredFields.length;
  }
}
