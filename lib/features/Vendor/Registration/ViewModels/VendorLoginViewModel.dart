import 'package:flutter/material.dart';
import 'package:vedika_healthcare/core/navigation/AppRoutes.dart';
import 'package:vedika_healthcare/features/Vendor/Registration/Services/VendorLoginService.dart';

class VendorLoginViewModel extends ChangeNotifier {
  String? selectedRole;
  int? roleNumber;  // Role number for selected vendor type
  final TextEditingController emailController = TextEditingController();
  final TextEditingController passwordController = TextEditingController();

  final VendorLoginService _vendorLoginService = VendorLoginService(); // Create an instance of the service

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

  Future<void> login(BuildContext context) async {
    // Check if fields are not empty and a role is selected
    if (emailController.text.isNotEmpty &&
        passwordController.text.isNotEmpty &&
        selectedRole != null && roleNumber != null) {

      // Debugging: Print selected role and role number
      print("Role: $selectedRole, Role Number: $roleNumber");

      // Show loading indicator while logging in
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text("Logging in...")));

      try {
        // Call the VendorLoginService to attempt login
        var response = await _vendorLoginService.loginVendor(
          emailController.text,
          passwordController.text,
          roleNumber!,    // Pass the role number
        );

        // Debugging: Print the response to check the structure
        print("Login response: $response");

        // Check if login was successful
        if (response != null && response['message'] == 'Login successful') {
          // Successfully logged in
          String token = response['token'];  // Store token securely
          var vendor = response['vendor'];  // You can store vendor info if needed

          // Notify user of successful login
          ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text("Login Successful")));

          // Add delay to allow snackbar to show, then navigate
          await Future.delayed(Duration(seconds: 1));

          // Use the correct Navigator context and push the route
          await Navigator.of(context).pushReplacementNamed(AppRoutes.VendorMedicalStoreDashBoard);
        } else {
          // Show error message if login failed
          ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(response['message'] ?? "Error occurred")));
        }
      } catch (e) {
        // Handle any exceptions or errors
        print("Error during login: $e");

        // Show error message if something went wrong
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text("An error occurred during login")));
      }
    } else {
      // Show error message if fields are empty or role is not selected
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text("Please fill in all fields and select a role")));
    }
  }




// Update the role selection and assign role number
  void updateRole(String newRole) {
    selectedRole = newRole;
    roleNumber = vendorRoleNumbers[newRole];  // Assign role number based on the selected role
    print("Selected Role: $selectedRole, Role Number: $roleNumber"); // Add this for debugging
    notifyListeners();
  }

  // Function to validate the email
  bool isValidEmail() {
    return emailController.text.isNotEmpty && emailController.text.contains('@');
  }

  // Function to validate the password
  bool isValidPassword() {
    return passwordController.text.isNotEmpty && passwordController.text.length >= 6;
  }
}
