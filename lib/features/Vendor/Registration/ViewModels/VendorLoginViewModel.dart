import 'package:flutter/material.dart';
import 'package:vedika_healthcare/core/navigation/AppRoutes.dart';
import 'package:vedika_healthcare/features/Vendor/Registration/Services/VendorLoginService.dart';

class VendorLoginViewModel extends ChangeNotifier {
  String? selectedRole;
  int? roleNumber;  // Role number for selected vendor type
  final TextEditingController emailController = TextEditingController();
  final TextEditingController passwordController = TextEditingController();

  final VendorLoginService _vendorLoginService = VendorLoginService(); // Vendor login service instance

  bool _isVendorLoggedIn = false; // To track vendor login state

  // Getter for login status
  bool get isVendorLoggedIn => _isVendorLoggedIn;

  // Vendor types with corresponding role numbers
  final Map<String, int> vendorRoleNumbers = {
    "Hospital": 1,
    "Clinic": 2,
    "Medical Store": 3,
    "Ambulance Agency": 4,
    "Blood Bank": 5,
    "Pathology/Diagnostic Center": 6,
    "Delivery Partner": 7,
  };

  /// **🔹 Check Vendor Login Status**
  Future<void> checkLoginStatus() async {
    _isVendorLoggedIn = await _vendorLoginService.isVendorLoggedIn();

    // Await the getVendorToken() method and then print the token value
    String? vendorToken = await _vendorLoginService.getVendorToken();
    print("Vendor Token: $vendorToken");

    notifyListeners();
  }

  /// **🔹 Vendor Login**
  Future<void> login(BuildContext context) async {
    if (emailController.text.trim().isNotEmpty &&
        passwordController.text.trim().isNotEmpty &&
        selectedRole != null &&
        roleNumber != null) {

      String email = emailController.text.trim();
      String password = passwordController.text.trim();
      int role = roleNumber!;

      print("📢 Attempting login...");
      print("🔹 Email: $email");
      print("🔹 Password: $password");
      print("🔹 Role: $selectedRole, Role Number: $role");

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Logging in...")),
      );

      try {
        var response = await _vendorLoginService.loginVendor(email, password, role);

        print("✅ Login response received: $response");

        if (response.containsKey('success') && response['success'] == true) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text("Login Successful")),
          );

          _isVendorLoggedIn = true;  // Update login state
          notifyListeners();

          await Future.delayed(const Duration(seconds: 1));

          // Navigate to Vendor Dashboard (Adjust route as needed)
          await Navigator.of(context).pushReplacementNamed(AppRoutes.VendorMedicalStoreDashBoard);
        } else {
          String errorMessage = response['message'] ?? "Invalid credentials or role.";
          print("❌ Login failed: $errorMessage");

          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text(errorMessage)),
          );
        }
      } catch (e) {
        print("🚨 Error during login: $e");

        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text("An error occurred: $e")),
        );
      }
    } else {
      print("⚠️ Missing fields - Please enter all required fields.");
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Please fill in all fields and select a role")),
      );
    }
  }

  /// **🔹 Logout Vendor**
  Future<void> logout() async {
    await _vendorLoginService.logoutVendor();
    _isVendorLoggedIn = false; // Update login state
    notifyListeners();
  }

  /// **🔹 Update Selected Role**
  void updateRole(String newRole) {
    selectedRole = newRole;
    roleNumber = vendorRoleNumbers[newRole];
    print("Selected Role: $selectedRole, Role Number: $roleNumber");
    notifyListeners();
  }

  /// **🔹 Validate Email**
  bool isValidEmail() {
    return emailController.text.isNotEmpty && emailController.text.contains('@');
  }

  /// **🔹 Validate Password**
  bool isValidPassword() {
    return passwordController.text.isNotEmpty && passwordController.text.length >= 6;
  }
}
