import 'package:flutter/material.dart';
import 'package:vedika_healthcare/features/Vendor/AmbulanceAgencyVendor/presentation/view/AmbulanceRegistrationScreen.dart';
import 'package:vedika_healthcare/features/Vendor/BloodBankAgencyVendor/presentation/view/BloodBankRegistrationScreen.dart';
import 'package:vedika_healthcare/features/Vendor/Registration/HospitalRegistration/View/hospital_registration_form.dart';
import 'package:vedika_healthcare/features/Vendor/Registration/HospitalRegistration/Widgets/login_widget.dart';
import 'package:vedika_healthcare/features/Vendor/Registration/MedicalRegistration/View/MedicalStoreRegistrationScreen.dart';

import 'package:vedika_healthcare/features/Vendor/Registration/Views/clinic_registration_form.dart';
import 'package:vedika_healthcare/features/Vendor/Registration/Views/delivery_partner_registration_form.dart';
import 'package:vedika_healthcare/features/Vendor/Registration/Views/pathology_registration_form.dart';


class VendorRegistrationPage extends StatefulWidget {
  @override
  _VendorRegistrationPageState createState() => _VendorRegistrationPageState();
}

class _VendorRegistrationPageState extends State<VendorRegistrationPage> {
  String? selectedVendorType;

  @override
  Widget build(BuildContext context) {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      setState(() {
        selectedVendorType = null;  // Reset value when coming back to the screen
      });
    });

    return Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 30),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              // Back Button
              Align(
                alignment: Alignment.topLeft,
                child: IconButton(
                  icon: Icon(Icons.arrow_back, color: Colors.black),
                  onPressed: () {
                    setState(() {
                      selectedVendorType = null; // Reset the selected vendor type when going back
                    });
                    Navigator.pop(context); // Pop the screen
                  },
                ),
              ),

              // Display Login Widget
              LoginWidget(),
              SizedBox(height: 25),
              Divider(color: Colors.grey[400], thickness: 1.5),
              SizedBox(height: 25),

              // Registration Section
              Text(
                "Vendor Registration",
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                  color: Colors.teal.shade700,
                ),
              ),
              SizedBox(height: 10),
              Text(
                "Select the vendor type and fill in the registration form.",
                textAlign: TextAlign.center,
                style: TextStyle(fontSize: 16, color: Colors.grey[700]),
              ),
              SizedBox(height: 25),

              // Vendor Type Dropdown
              Container(
                width: double.infinity,
                padding: EdgeInsets.symmetric(horizontal: 16, vertical: 4),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: Colors.grey.shade400, width: 1.5),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.grey.withOpacity(0.2),
                      spreadRadius: 1,
                      blurRadius: 5,
                      offset: Offset(0, 2),
                    ),
                  ],
                ),
                child: DropdownButtonHideUnderline(
                  child: DropdownButton<String>(
                    isExpanded: true,
                    value: selectedVendorType,
                    hint: Text(
                      "Choose Vendor Type",
                      style: TextStyle(fontSize: 16, color: Colors.grey[800]),
                    ),
                    items: [
                      "Hospital",
                      "Clinic",
                      "Medical Store",
                      "Ambulance Agency",
                      "Blood Bank",
                      "Pathology/Diagnostic Center",
                      "Delivery Partner"
                    ].map((String vendor) {
                      return DropdownMenuItem<String>(
                        value: vendor,
                        child: Row(
                          children: [
                            Icon(Icons.business, color: Colors.teal),
                            SizedBox(width: 10),
                            Text(vendor, style: TextStyle(fontSize: 16, fontWeight: FontWeight.w500)),
                          ],
                        ),
                      );
                    }).toList(),
                    onChanged: (String? value) {
                      setState(() {
                        selectedVendorType = value;
                      });

                      // Navigate to the selected vendor's registration screen
                      if (value != null) {
                        Widget registrationScreen;

                        // Determine which screen to navigate to based on vendor type
                        switch (value) {
                          case "Hospital":
                            registrationScreen = HospitalRegistrationForm();
                            break;
                          case "Clinic":
                            registrationScreen = ClinicRegistrationForm();
                            break;
                          case "Medical Store":
                            registrationScreen = MedicalStoreRegistrationScreen();
                            break;
                          case "Ambulance Agency":
                            registrationScreen = AmbulanceRegistrationScreen();
                            break;
                          case "Blood Bank":
                            registrationScreen = BloodBankRegistrationScreen();
                            break;
                          case "Pathology/Diagnostic Center":
                            registrationScreen = PathologyRegistrationForm();
                            break;
                          case "Delivery Partner":
                            registrationScreen = DeliveryPartnerRegistrationForm();
                            break;
                          default:
                            registrationScreen = Container(); // Fallback case
                        }

                        // Navigate to the selected registration screen
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) => registrationScreen,
                          ),
                        );
                      }
                    },
                    icon: Icon(Icons.arrow_drop_down_circle, color: Colors.teal),
                    dropdownColor: Colors.white,
                  ),
                ),
              ),
              SizedBox(height: 25),
            ],
          ),
        ),
      ),
    );
  }
}
