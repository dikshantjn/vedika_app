import 'package:flutter/material.dart';
import 'package:vedika_healthcare/core/navigation/AppRoutes.dart';
import 'package:vedika_healthcare/features/Vendor/Registration/Services/VendorLoginService.dart';
import 'package:vedika_healthcare/shared/services/FCMService.dart';

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

      try {
        var response = await _vendorLoginService.loginVendor(email, password, role);

        print("✅ Login response received: $response");
        String? vendorId = await VendorLoginService().getVendorId();
        await FCMService().getVendorTokenAndSend(vendorId ?? " ");

        if (response.containsKey('success') && response['success'] == true) {
          _isVendorLoggedIn = true;  // Update login state
          notifyListeners();

          await Future.delayed(const Duration(seconds: 1));

          // Navigate to respective dashboard based on role
          switch (role) {
            case 1: // Hospital
              await Navigator.of(context).pushReplacementNamed(AppRoutes.VendorHospitalDashBoard);
              break;
            case 2: // Clinic
              await Navigator.of(context).pushReplacementNamed(AppRoutes.VendorClinicDashBoard);
              break;
            case 3: // Medical Store
              await Navigator.of(context).pushReplacementNamed(AppRoutes.VendorMedicalStoreDashBoard);
              break;
            case 4: // Ambulance Agency
              await Navigator.of(context).pushReplacementNamed(AppRoutes.AmbulanceAgencyDashboard);
              break;
            case 5: // Blood Bank
              await Navigator.of(context).pushReplacementNamed(AppRoutes.VendorBloodBankDashBoard);
              break;
            case 6: // Pathology/Diagnostic Center
              await Navigator.of(context).pushReplacementNamed(AppRoutes.VendorPathologyDashBoard);
              break;
            case 7: // Delivery Partner
              await Navigator.of(context).pushReplacementNamed(AppRoutes.VendorDeliveryPartnerDashBoard);
              break;
            default:
              print("❌ Unknown role");
          }

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
    String? vendorId = await VendorLoginService().getVendorId();
    await FCMService().deleteVendorTokenFromServer(vendorId!);
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

  Future<void> navigateToDashboard(BuildContext context, int? roleNumber) async {
    if (!context.mounted) {
      print("🔹Context is not valid: $roleNumber");
      return; // Make sure context is still valid
    }

    print("🔹 Role Number in Navigation: $roleNumber");

    // Validate role
    if (roleNumber == null) {
      print("❌ Invalid role number");
      return;
    }

    // Select route based on roleNumber
    String? routeToNavigate;
    switch (roleNumber) {
      case 1: // Hospital
        routeToNavigate = AppRoutes.VendorHospitalDashBoard;
        break;
      case 2: // Clinic
        routeToNavigate = AppRoutes.VendorClinicDashBoard;
        break;
      case 3: // Medical Store
        routeToNavigate = AppRoutes.VendorMedicalStoreDashBoard;
        break;
      case 4: // Ambulance Agency
        routeToNavigate = AppRoutes.AmbulanceAgencyDashboard;
        break;
      case 5: // Blood Bank
        routeToNavigate = AppRoutes.VendorBloodBankDashBoard;
        break;
      case 6: // Pathology/Diagnostic Center
        routeToNavigate = AppRoutes.VendorPathologyDashBoard;
        break;
      case 7: // Delivery Partner
        routeToNavigate = AppRoutes.VendorDeliveryPartnerDashBoard;
        break;
      default:
        print("❌ Unknown role");
        return; // If role is invalid, return
    }

    // Log the route being navigated to
    print("🔹 Navigating to route: $routeToNavigate");

    // Ensure the route is valid before attempting navigation
    if (routeToNavigate != null) {
      try {
        // Ensure context is valid and not disposed
        if (context.mounted) {
          Navigator.of(context).pushReplacementNamed(routeToNavigate);
          print("✅ Successfully navigated to: $routeToNavigate");
        } else {
          print("❌ Error: The context is no longer valid or mounted.");
        }
      } catch (e) {
        print("🚨 Error during navigation: $e");
      }
    } else {
      print("❌ Invalid route: $routeToNavigate");
    }
  }

}
