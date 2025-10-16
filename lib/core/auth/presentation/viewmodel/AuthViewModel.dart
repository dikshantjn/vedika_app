import 'package:flutter/material.dart';
import 'package:vedika_healthcare/core/auth/data/repositories/AuthRepository.dart';
import 'package:vedika_healthcare/core/navigation/AppRoutes.dart';
import 'package:vedika_healthcare/main.dart' show navigatorKey;

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

    // Prefer global navigator to avoid using a possibly unmounted context (e.g., drawer just popped)
    final navState = navigatorKey.currentState;
    if (navState != null) {
      navState.pushNamedAndRemoveUntil(AppRoutes.login, (route) => false);
      return;
    }

    // Fallback: if context is still mounted, schedule navigation next frame
    if (context.mounted) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (context.mounted) {
          Navigator.of(context).pushNamedAndRemoveUntil(AppRoutes.login, (route) => false);
        }
      });
    }
  }

}
