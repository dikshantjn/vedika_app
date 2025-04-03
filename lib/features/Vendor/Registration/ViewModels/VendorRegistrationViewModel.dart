import 'package:flutter/material.dart';
import 'package:vedika_healthcare/features/Vendor/Registration/HospitalRegistration/View/hospital_registration_form.dart';
import 'package:vedika_healthcare/features/Vendor/Registration/MedicalRegistration/View/MedicalStoreRegistrationScreen.dart';
import 'package:vedika_healthcare/features/Vendor/Registration/Views/AmbulanceAgencyRegistrationScreen.dart';
import 'package:vedika_healthcare/features/Vendor/Registration/Views/blood_bank_registration_form.dart';
import 'package:vedika_healthcare/features/Vendor/Registration/Views/clinic_registration_form.dart';
import 'package:vedika_healthcare/features/Vendor/Registration/Views/delivery_partner_registration_form.dart';
import 'package:vedika_healthcare/features/Vendor/Registration/Views/pathology_registration_form.dart';

class VendorRegistrationViewModel extends ChangeNotifier {
  String? selectedVendorType;
  final TextEditingController emailController = TextEditingController();
  final TextEditingController passwordController = TextEditingController();

  // Vendor types with corresponding registration forms
  final Map<String, Widget> vendorForms = {
    "Hospital": HospitalRegistrationForm(),
    "Clinic": ClinicRegistrationForm(),
    "Medical Store": MedicalStoreRegistrationScreen(),
    "Ambulance Agency": AmbulanceAgencyRegistrationScreen(),
    "Blood Bank": BloodBankRegistrationForm(),
    "Pathology/Diagnostic Center": PathologyRegistrationForm(),
    "Delivery Partner": DeliveryPartnerRegistrationForm(),
  };

  // Login action
  void login(BuildContext context) {
    // Handle login logic here
    if (emailController.text.isNotEmpty && passwordController.text.isNotEmpty) {
      // Example: You can add authentication logic here, e.g., call an API
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text("Login Successful")));
    } else {
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text("Please fill in both fields")));
    }
  }

  // Set selected vendor type
  void setSelectedVendorType(String? type) {
    selectedVendorType = type;
    notifyListeners();
  }
}
