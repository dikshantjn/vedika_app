import 'package:flutter/material.dart';
import 'package:vedika_healthcare/features/Vendor/AmbulanceAgencyVendor/presentation/view/AmbulanceRegistrationScreen.dart';
import 'package:vedika_healthcare/features/Vendor/BloodBankAgencyVendor/presentation/view/BloodBankRegistrationScreen.dart';
import 'package:vedika_healthcare/features/Vendor/DoctorConsultationVendor/Views/doctor_clinic_registration_screen.dart';
import 'package:vedika_healthcare/features/Vendor/HospitalVendor/Views/HospitalRegistrationScreen.dart';
import 'package:vedika_healthcare/features/Vendor/LabTest/presentation/views/lab_test_registration_screen.dart';
import 'package:vedika_healthcare/features/Vendor/Registration/MedicalRegistration/View/MedicalStoreRegistrationScreen.dart';
import 'package:vedika_healthcare/features/Vendor/ProductPartner/presentation/views/product_partner_registration_screen.dart';

import 'package:vedika_healthcare/features/Vendor/Registration/Views/clinic_registration_form.dart';
import 'package:vedika_healthcare/features/Vendor/Registration/Views/delivery_partner_registration_form.dart';
import 'package:vedika_healthcare/features/Vendor/Registration/Views/login_widget.dart';
import 'package:vedika_healthcare/features/Vendor/Registration/Views/pathology_registration_form.dart';


class VendorRegistrationPage extends StatefulWidget {
  @override
  _VendorRegistrationPageState createState() => _VendorRegistrationPageState();
}

class _VendorRegistrationPageState extends State<VendorRegistrationPage> {
  String? selectedVendorType;

  final List<VendorTypeOption> vendorTypes = [
    VendorTypeOption("Hospital", Icons.local_hospital, "Register your hospital with us"),
    VendorTypeOption("Clinic", Icons.medical_services, "Join as a clinic partner"),
    VendorTypeOption("Medical Store", Icons.local_pharmacy, "List your pharmacy services"),
    VendorTypeOption("Ambulance Agency", Icons.emergency, "Provide emergency services"),
    VendorTypeOption("Blood Bank", Icons.bloodtype, "Register your blood bank"),
    VendorTypeOption("Pathology/Diagnostic Center", Icons.science, "Join as a diagnostic center"),
    VendorTypeOption("Delivery Partner", Icons.delivery_dining, "Become a delivery partner"),
    VendorTypeOption("Product Partner", Icons.inventory_2, "Sell your healthcare products"),
  ];

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;
    
    return Container(
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            Colors.teal.shade50,
            Colors.white,
          ],
          stops: [0.0, 1.0],
        ),
      ),
      child: Scaffold(
        backgroundColor: Colors.transparent,
        body: SafeArea(
          child: SingleChildScrollView(
            physics: AlwaysScrollableScrollPhysics(),
            child: Padding(
              padding: EdgeInsets.symmetric(
                horizontal: size.width * 0.05,
                vertical: size.height * 0.02,
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _buildHeader(context),
                  SizedBox(height: size.height * 0.02),
                  LoginWidget(),
                  SizedBox(height: size.height * 0.03),
                  _buildDivider(),
                  SizedBox(height: size.height * 0.03),
                  _buildRegistrationSection(size),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildHeader(BuildContext context) {
    return Row(
      children: [
        IconButton(
          icon: Container(
            padding: EdgeInsets.all(8),
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: Colors.white,
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.1),
                  blurRadius: 8,
                  offset: Offset(0, 2),
                ),
              ],
            ),
            child: Icon(Icons.arrow_back, color: Colors.teal.shade700),
          ),
          onPressed: () {
            setState(() {
              selectedVendorType = null;
            });
            Navigator.pop(context);
          },
        ),
      ],
    );
  }

  Widget _buildDivider() {
    return Row(
      children: [
        Expanded(
          child: Container(
            height: 1.5,
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: [
                  Colors.transparent,
                  Colors.grey.shade300,
                  Colors.grey.shade300,
                  Colors.transparent,
                ],
              ),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildRegistrationSection(Size size) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          "Join Our Healthcare Network",
          style: TextStyle(
            fontSize: 28,
            fontWeight: FontWeight.bold,
            color: Colors.teal.shade700,
            letterSpacing: 0.5,
          ),
        ),
        SizedBox(height: 12),
        Text(
          "Choose your category and start serving the community",
          style: TextStyle(
            fontSize: 16,
            color: Colors.grey.shade600,
            letterSpacing: 0.2,
          ),
        ),
        SizedBox(height: size.height * 0.03),
        _buildVendorTypeGrid(size),
      ],
    );
  }

  Widget _buildVendorTypeGrid(Size size) {
    return GridView.builder(
      shrinkWrap: true,
      physics: NeverScrollableScrollPhysics(),
      gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: size.width > 600 ? 3 : 2,
        childAspectRatio: 1.3,
        crossAxisSpacing: 16,
        mainAxisSpacing: 16,
      ),
      itemCount: vendorTypes.length,
      itemBuilder: (context, index) {
        return _buildVendorTypeCard(vendorTypes[index]);
      },
    );
  }

  Widget _buildVendorTypeCard(VendorTypeOption vendor) {
    bool isSelected = selectedVendorType == vendor.title;

    return GestureDetector(
      onTap: () {
        setState(() {
          selectedVendorType = vendor.title;
        });
        _navigateToRegistrationScreen(vendor.title);
      },
      child: AnimatedContainer(
        duration: Duration(milliseconds: 200),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(20),
          border: Border.all(
            color: isSelected ? Colors.teal.shade700 : Colors.transparent,
            width: 2,
          ),
          boxShadow: [
            BoxShadow(
              color: isSelected 
                  ? Colors.teal.shade100.withOpacity(0.5)
                  : Colors.grey.withOpacity(0.1),
              blurRadius: 10,
              spreadRadius: 0,
              offset: Offset(0, 4),
            ),
          ],
        ),
        child: Padding(
          padding: EdgeInsets.all(12),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Container(
                padding: EdgeInsets.all(10),
                decoration: BoxDecoration(
                  color: Colors.teal.shade50,
                  shape: BoxShape.circle,
                ),
                child: Icon(
                  vendor.icon,
                  color: Colors.teal.shade700,
                  size: 28,
                ),
              ),
              SizedBox(height: 8),
              Text(
                vendor.title,
                style: TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.w600,
                  color: Colors.teal.shade700,
                ),
                textAlign: TextAlign.center,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
              ),
              SizedBox(height: 4),
              Flexible(
                child: Text(
                  vendor.description,
                  style: TextStyle(
                    fontSize: 11,
                    color: Colors.grey.shade600,
                  ),
                  textAlign: TextAlign.center,
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  void _navigateToRegistrationScreen(String vendorType) {
    Widget registrationScreen;

    switch (vendorType) {
      case "Hospital":
        registrationScreen = HospitalRegistrationScreen();
        break;
      case "Clinic":
        registrationScreen = DoctorClinicRegistrationScreen();
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
        registrationScreen = LabTestRegistrationScreen();
        break;
      case "Delivery Partner":
        registrationScreen = DeliveryPartnerRegistrationForm();
        break;
      case "Product Partner":
        registrationScreen = ProductPartnerRegistrationScreen();
        break;
      default:
        registrationScreen = Container();
    }

    Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => registrationScreen),
    );
  }
}

class VendorTypeOption {
  final String title;
  final IconData icon;
  final String description;

  VendorTypeOption(this.title, this.icon, this.description);
}
