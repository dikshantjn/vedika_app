import 'package:flutter/material.dart';
import 'package:vedika_healthcare/features/ambulance/presentation/view/AmbulanceSearchPage.dart';
import 'package:vedika_healthcare/features/bloodBank/presentation/view/DonorRegistrationPage.dart';
import 'package:vedika_healthcare/features/bloodBank/presentation/view/bloodBankPage.dart';
import 'package:vedika_healthcare/features/clinic/data/models/Clinic.dart';
import 'package:vedika_healthcare/features/clinic/presentation/view/BookClinicAppointmentPage.dart';
import 'package:vedika_healthcare/features/clinic/presentation/view/ClinicSearchPage.dart';
import 'package:vedika_healthcare/features/hospital/presentation/view/BookAppointmentPage.dart';
import 'package:vedika_healthcare/features/hospital/presentation/view/HospitalSearchPage.dart';

class AppRoutes {
  static const String medicine = "/medicine";
  static const String labTest = "/labTest";
  static const String bloodBank = "/bloodBank";
  static const String clinic = "/clinic";  // New Route
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
  static const String bookClinicAppointment  = "/bookClinicAppointment";

  static Map<String, WidgetBuilder> getRoutes() {
    return {
      bloodBank: (context) => BloodBankMapScreen(),
      ambulanceSearch: (context) => AmbulanceSearchPage(),
      clinic: (context) => ClinicSearchPage(),  // Added route for clinic
      hospital: (context) => HospitalSearchPage(),
      donorRegistration: (context) => DonorRegistrationPage(),
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
        final clinic = settings.arguments as Clinic;  // Expecting a Clinic object
        return MaterialPageRoute(
          builder: (context) => BookClinicAppointmentPage(clinic: clinic),
        );
      default:
        return MaterialPageRoute(
          builder: (context) => Scaffold(body: Center(child: Text('Page Not Found'))),
        );
    }
  }
}
