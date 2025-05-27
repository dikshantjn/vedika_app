import 'package:flutter/material.dart';
import 'package:vedika_healthcare/core/navigation/AppRoutes.dart';
import 'package:vedika_healthcare/features/Vendor/Registration/Services/VendorLoginService.dart';
import 'package:vedika_healthcare/shared/services/FCMService.dart';
import 'package:vedika_healthcare/core/constants/colorpalette/ColorPalette.dart';
import 'package:device_info_plus/device_info_plus.dart';

class VendorLoginViewModel extends ChangeNotifier {
  String? selectedRole;
  int? roleNumber;  // Role number for selected vendor type
  final TextEditingController emailController = TextEditingController();
  final TextEditingController passwordController = TextEditingController();
  String? _deviceId;

  final VendorLoginService _vendorLoginService = VendorLoginService(); // Vendor login service instance
  final DeviceInfoPlugin _deviceInfo = DeviceInfoPlugin();

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
    "Product Partner": 8,
  };

  // Initialize device ID
  Future<void> initializeDeviceId() async {
    try {
      if (WidgetsBinding.instance.platformDispatcher.platformBrightness == Brightness.dark) {
        // For Android
        final androidInfo = await _deviceInfo.androidInfo;
        _deviceId = androidInfo.id;
      } else {
        // For iOS
        final iosInfo = await _deviceInfo.iosInfo;
        _deviceId = iosInfo.identifierForVendor;
      }
    } catch (e) {
      print("Error getting device ID: $e");
      _deviceId = "unknown-device";
    }
  }

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

      // Ensure device ID is initialized
      if (_deviceId == null) {
        await initializeDeviceId();
      }

      String email = emailController.text.trim();
      String password = passwordController.text.trim();
      int role = roleNumber!;
      String deviceId = _deviceId ?? "unknown-device";

      print("📢 Attempting login...");
      print("🔹 Email: $email");
      print("🔹 Password: $password");
      print("🔹 Role: $selectedRole, Role Number: $role");
      print("🔹 Device ID: $deviceId");

      try {
        var response = await _vendorLoginService.loginVendor(email, password, role, deviceId);

        print("✅ Login response received: $response");

        // Remove loading indicator before showing any dialogs
        if (Navigator.canPop(context)) {
          Navigator.of(context).pop();
        }

        if (response['success'] == true) {
        String? vendorId = await VendorLoginService().getVendorId();
        await FCMService().getVendorTokenAndSend(vendorId ?? " ");

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
            case 8: // Product Partner
              await Navigator.of(context).pushReplacementNamed(AppRoutes.VendorProductPartnerDashBoard);
              break;
            default:
              print("❌ Unknown role");
          }
        } else {
          String errorMessage = response['message'] ?? "Invalid credentials or role.";
          print("❌ Login failed: $errorMessage");

          // Check if the message contains status information
          if (errorMessage.toLowerCase().contains('currently')) {
            String status = errorMessage.toLowerCase().contains('pending') ? 'pending' : 'not approved';
            _showAccountStatusDialog(context, status, errorMessage);
          } else {
            _showErrorDialog(context, errorMessage);
          }
        }
      } catch (e) {
        print("🚨 Error during login: $e");
        // Remove loading indicator before showing error dialog
        if (Navigator.canPop(context)) {
          Navigator.of(context).pop();
        }
        _showErrorDialog(context, "An error occurred: $e");
      }
    } else {
      print("⚠️ Missing fields - Please enter all required fields.");
      _showErrorDialog(context, "Please fill in all fields and select a role");
    }
  }

  void _showErrorDialog(BuildContext context, String message) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
          ),
          title: Row(
            children: [
              Icon(
                Icons.error_outline_rounded,
                color: Colors.red,
                size: 28,
              ),
              SizedBox(width: 12),
              Text(
                'Login Error',
                style: TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                  color: Colors.red,
                ),
              ),
            ],
          ),
          content: Text(
            message,
            style: TextStyle(
              fontSize: 16,
              color: Colors.grey[800],
            ),
          ),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();
              },
              child: Text(
                'OK',
                style: TextStyle(
                  color: Colors.grey[600],
                  fontSize: 16,
                ),
              ),
            ),
          ],
        );
      },
    );
  }

  void _showAccountStatusDialog(BuildContext context, String status, String message) {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (BuildContext context) {
        return WillPopScope(
          onWillPop: () async => false,
          child: Dialog(
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(20),
            ),
            elevation: 0,
            backgroundColor: Colors.transparent,
            child: Container(
              padding: EdgeInsets.all(20),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(20),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.1),
                    blurRadius: 20,
                    offset: Offset(0, 10),
                  ),
                ],
              ),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  // Status Icon Container
                  Container(
                    padding: EdgeInsets.all(15),
                    decoration: BoxDecoration(
                      color: status == 'pending' 
                          ? Colors.orange.withOpacity(0.1)
                          : Colors.red.withOpacity(0.1),
                      shape: BoxShape.circle,
                    ),
                    child: Icon(
                      status == 'pending' ? Icons.hourglass_empty : Icons.warning_amber_rounded,
                      color: status == 'pending' ? Colors.orange : Colors.red,
                      size: 40,
                    ),
                  ),
                  SizedBox(height: 20),

                  // Title
                  Text(
                    status == 'pending' ? 'Account Pending' : 'Account Not Approved',
                    style: TextStyle(
                      fontSize: 24,
                      fontWeight: FontWeight.bold,
                      color: status == 'pending' ? Colors.orange : Colors.red,
                    ),
                  ),
                  SizedBox(height: 15),

                  // Message
                  Container(
                    padding: EdgeInsets.all(15),
                    decoration: BoxDecoration(
                      color: Colors.grey[50],
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(
                        color: Colors.grey[200]!,
                        width: 1,
                      ),
                    ),
                    child: Text(
                      message,
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        fontSize: 16,
                        color: Colors.grey[800],
                        height: 1.5,
                      ),
                    ),
                  ),
                  SizedBox(height: 20),

                  // What to do next section
                  Container(
                    padding: EdgeInsets.all(15),
                    decoration: BoxDecoration(
                      color: Colors.blue[50],
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            Icon(
                              Icons.info_outline,
                              color: Colors.blue[700],
                              size: 20,
                            ),
                            SizedBox(width: 8),
                            Text(
                              'What to do next?',
                              style: TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.bold,
                                color: Colors.blue[700],
                              ),
                            ),
                          ],
                        ),
                        SizedBox(height: 8),
                        Text(
                          'Please contact our support team for assistance with your account status.',
                          style: TextStyle(
                            fontSize: 14,
                            color: Colors.blue[900],
                            height: 1.5,
                          ),
                        ),
                      ],
                    ),
                  ),
                  SizedBox(height: 25),

                  // Buttons
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                    children: [
                      // Close Button
                      Expanded(
                        child: TextButton(
                          onPressed: () {
                            Navigator.of(context).pop();
                          },
                          style: TextButton.styleFrom(
                            padding: EdgeInsets.symmetric(vertical: 12),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(8),
                              side: BorderSide(color: Colors.grey[300]!),
                            ),
                          ),
                          child: Text(
                            'Close',
                            style: TextStyle(
                              color: Colors.grey[700],
                              fontSize: 16,
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                        ),
                      ),
                      SizedBox(width: 12),
                      // Contact Support Button
                      Expanded(
                        child: ElevatedButton(
                          onPressed: () {
                            // TODO: Implement contact support functionality
                            Navigator.of(context).pop();
                          },
                          style: ElevatedButton.styleFrom(
                            backgroundColor: ColorPalette.primaryColor,
                            padding: EdgeInsets.symmetric(vertical: 12),
                            elevation: 0,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(8),
                            ),
                          ),
                          child: Text(
                            'Contact Support',
                            style: TextStyle(
                              color: Colors.white,
                              fontSize: 16,
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
        );
      },
    );
  }

  /// **🔹 Logout Vendor**
  Future<void> logout() async {
    try {
      String? vendorId = await VendorLoginService().getVendorId();
      await FCMService().deleteVendorTokenFromServer(vendorId!);
      
      var response = await _vendorLoginService.logoutVendor();
      
      if (response['success']) {
        _isVendorLoggedIn = false; // Update login state
        notifyListeners();
      } else {
        print("❌ Logout failed: ${response['message']}");
      }
    } catch (e) {
      print("🚨 Error during logout: $e");
    }
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
      case 8: // Product Partner
        routeToNavigate = AppRoutes.VendorProductPartnerDashBoard;
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
