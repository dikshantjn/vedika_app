import 'package:flutter/material.dart';
import 'package:vedika_healthcare/core/auth/presentation/view/LogoutPage.dart';
import 'package:vedika_healthcare/core/auth/presentation/view/userLoginScreen.dart';
import 'package:vedika_healthcare/features/HealthRecords/presentation/view/HealthRecordsPage.dart';
import 'package:vedika_healthcare/features/TrackOrder/presentation/view/TrackOrderScreen.dart';
import 'package:vedika_healthcare/features/Vendor/MedicalStoreVendor/presentation/view/Dashboard/VendorMedicalStoreDashBoard.dart';
import 'package:vedika_healthcare/features/Vendor/Registration/Views/vendor_registration_page.dart';
import 'package:vedika_healthcare/features/userProfile/presentation/view/UserProfilePage.dart';
import 'package:vedika_healthcare/features/ambulance/presentation/view/AmbulanceSearchPage.dart';
import 'package:vedika_healthcare/features/bloodBank/presentation/view/DonorRegistrationPage.dart';
import 'package:vedika_healthcare/features/bloodBank/presentation/view/EnableBloodBankLocationServiceScreen.dart';
import 'package:vedika_healthcare/features/bloodBank/presentation/view/bloodBankPage.dart';
import 'package:vedika_healthcare/features/clinic/data/models/Clinic.dart';
import 'package:vedika_healthcare/features/clinic/presentation/view/BookClinicAppointmentPage.dart';
import 'package:vedika_healthcare/features/clinic/presentation/view/ClinicSearchPage.dart';
import 'package:vedika_healthcare/features/home/presentation/view/HomePage.dart';
import 'package:vedika_healthcare/features/hospital/presentation/view/BookAppointmentPage.dart';
import 'package:vedika_healthcare/features/hospital/presentation/view/HospitalSearchPage.dart';
import 'package:vedika_healthcare/features/labTest/data/models/LabModel.dart';
import 'package:vedika_healthcare/features/labTest/presentation/view/BookLabTestAppointmentPage.dart';
import 'package:vedika_healthcare/features/labTest/presentation/view/LabSearchPage.dart';
import 'package:vedika_healthcare/features/medicineDelivery/presentation/view/CartScreen.dart';
import 'package:vedika_healthcare/features/medicineDelivery/presentation/view/medicineOrderScreen.dart';
import 'package:vedika_healthcare/features/notifications/presentation/view/NotificationPage.dart';
import 'package:vedika_healthcare/features/orderHistory/presentation/view/OrderHistoryPage.dart';

class AppRoutes {
  static const String medicineOrder = "/medicineOrder";
  static const String home = "/home";
  static const String labTest = "/labTest";
  static const String bloodBank = "/bloodBank";
  static const String clinic = "/clinic";
  static const String hospital = "/hospital";
  static const String vendor = "/vendor";
  static const String settings = "/settings";
  static const String help = "/help";
  static const String terms = "/terms";
  static const String profile = "/profile";
  static const String vedikaPlus = "/vedikaPlus";
  static const String donorRegistration = "/DonorRegistrationPage";
  static const String bookAppointment = "/BookAppointmentPage";
  static const String ambulanceSearch = "/ambulance";
  static const String bookClinicAppointment = "/bookClinicAppointment";
  static const String orderHistory = "/orderHistory"; // New route
  static const String enableBloodBankLocation = "/enableBloodBankLocation"; // New route
  static const String goToCart = "/goToCart"; // New route
  static const String bookLabTestAppointment = "/bookLabTestAppointment";
  static const String notification = "/notification";
  static const String userProfile = "/userProfile";
  static const String healthRecords = "/healthRecords";
  static const String login = "/login";
  static const String logout = "/logout";


  //Vendor
  static const String VendorMedicalStoreDashBoard = "/VendorMedicalStoreDashBoard";
  static const String MedicalStoreVendordashboard = "/MedicalStoreVendordashboard";
  static const String MedicalStoreVendorOrders = "/orders";
  static const String MedicalStoreVendorInventory = "/inventory";
  static const String MedicalStoreVendorReturns = "/returns";
  static const String MedicalStoreVendorSettings = "/settings";
  static const String trackOrderScreen = "/trackOrder";




  static Map<String, WidgetBuilder> getRoutes() {
    return {
      home: (context) => HomePage(),
      bloodBank: (context) => BloodBankMapScreen(),
      ambulanceSearch: (context) => AmbulanceSearchPage(),
      clinic: (context) => ClinicSearchPage(),
      hospital: (context) => HospitalSearchPage(),
      donorRegistration: (context) => DonorRegistrationPage(),
      orderHistory: (context) => OrderHistoryPage(), // Added route for EnableLocationPage
      enableBloodBankLocation: (context) => EnableBloodBankLocationServiceScreen(), // Added route for EnableLocationPage

      medicineOrder: (context) => MedicineOrderScreen(), // Added route for EnableLocationPage
      goToCart: (context) => CartScreen(), // Added route for EnableLocationPage

      labTest: (context) => LabSearchPage(), // Added route for EnableLocationPage
      notification: (context) => NotificationPage(), // Added route for EnableLocationPage
      userProfile: (context) => UserProfilePage(), // Added route for EnableLocationPage
      healthRecords: (context) => HealthRecordsPage(), // Added route for EnableLocationPage
      login: (context) => UserLoginScreen(), // Added route for EnableLocationPage
      logout: (context) => LogoutPage(), // Added route for EnableLocationPage


      //vendor
      vendor: (context) => VendorRegistrationPage(), // Added route for EnableLocationPage
      VendorMedicalStoreDashBoard: (context) => VendorMedicalStoreDashBoardScreen(), // Added route for EnableLocationPage
      trackOrderScreen: (context) => TrackOrderScreen(), // Added route for EnableLocationPage


    };
  }

  static Route<dynamic> generateRoute(RouteSettings settings) {
    switch (settings.name) {
      case bookAppointment:
        final hospital = settings.arguments as Map<String, dynamic>;
        return MaterialPageRoute(
          builder: (context) => BookAppointmentPage(hospital: hospital),
        );

      case bookClinicAppointment:
        final clinic = settings.arguments as Clinic;
        return MaterialPageRoute(
          builder: (context) => BookClinicAppointmentPage(clinic: clinic),
        );

      case bookLabTestAppointment:
        final lab = settings.arguments as LabModel;  // Extracting LabModel argument
        return MaterialPageRoute(
          builder: (context) => BookLabTestAppointmentPage(lab: lab),
        );

      default:
        return MaterialPageRoute(
          builder: (context) => Scaffold(body: Center(child: Text('Page Not Found'))),
        );
    }
  }

}
