import 'package:flutter/material.dart';
import 'package:vedika_healthcare/core/models/UserModal.dart';
import 'package:vedika_healthcare/core/services/AuthService.dart';


class SignupViewModel extends ChangeNotifier {
  final AuthService _authService = AuthService();

  bool _isLoading = false;
  String? _errorMessage;

  bool get isLoading => _isLoading;
  String? get errorMessage => _errorMessage;

  Future<void> signUp({
    required String name,
    required String phone,
    required String password,
  }) async {
    _isLoading = true;
    notifyListeners();

    final user = UserModel(
      userId: "", // This will be assigned by the backend
      name: name,
      phone: phone,
      password: password,
    );

    final result = await _authService.signUp(user);

    if (result == "Signup Successful") {
      _errorMessage = null;
    } else {
      _errorMessage = result;
    }

    _isLoading = false;
    notifyListeners();
  }
}
