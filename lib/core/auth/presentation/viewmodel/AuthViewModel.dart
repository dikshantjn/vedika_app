import 'package:flutter/material.dart';
import 'package:vedika_healthcare/core/auth/data/repositories/AuthRepository.dart';
import 'package:vedika_healthcare/core/navigation/AppRoutes.dart';
import 'package:vedika_healthcare/features/ambulance/data/services/AmbulanceRequestNotificationService.dart';

class AuthViewModel extends ChangeNotifier {
  final AuthRepository _authRepository = AuthRepository();
  bool _isLoggedIn = false;

  bool get isLoggedIn => _isLoggedIn;

  AuthViewModel() {
    checkLoginStatus(); // ✅ Check if user is logged in when app starts
  }

  Future<void> login(String token) async {
    await _authRepository.saveToken(token); // ✅ Save token securely
    _isLoggedIn = true;
    notifyListeners(); // ✅ Notify UI
  }

  Future<void> checkLoginStatus() async {
    String? token = await _authRepository.getToken();
    print("Retrieved Token: $token"); // ✅ Debugging

    // Ensure token is not null and not empty
    _isLoggedIn = token != null && token.isNotEmpty;
    print("Is Logged In: $_isLoggedIn"); // ✅ Debugging

    notifyListeners();
  }

  Future<void> logout(BuildContext context) async {
    await _authRepository.logout(); // ✅ Clear token
    _isLoggedIn = false;
    notifyListeners();

    // ✅ Use context directly instead of navigatorKey.currentContext
    Navigator.pushNamedAndRemoveUntil(
      context,
      AppRoutes.login, // ✅ Using AppRoutes.login
          (route) => false, // ✅ Removes all previous routes
    );
  }

}
