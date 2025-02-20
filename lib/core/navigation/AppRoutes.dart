import 'package:flutter/material.dart';
import 'package:vedika_healthcare/features/bloodBank/presentation/view/DonorRegistrationPage.dart';
import 'package:vedika_healthcare/features/bloodBank/presentation/view/bloodBankPage.dart';
import 'package:vedika_healthcare/features/bookAppointment/presentation/view/BookAppointmentPage.dart';
import 'package:vedika_healthcare/features/hospital/presentation/view/HospitalSearchPage.dart';


class AppRoutes {
  static const String medicine = "/medicine";
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
  static const String donorRegistration = "/DonorRegistrationPage"; // New Route
  static const String bookAppoinment = "/BookAppointmentPage";

  static Map<String, WidgetBuilder> getRoutes() {
    return {
      // medicine: (context) => MedicinePage(),
      // labTest: (context) => LabTestPage(),
      bloodBank: (context) => BloodBankMapScreen(),
      // clinic: (context) => ClinicPage(),
      hospital: (context) => HospitalSearchPage(),
      // vendor: (context) => VendorPage(),
      // settings: (context) => SettingsPage(),
      // help: (context) => HelpPage(),
      // terms: (context) => TermsPage(),
      // profile: (context) => ProfilePage(),
      // vedikaPlus: (context) => VedikaPlusPage(),
      donorRegistration: (context) => DonorRegistrationPage(),
    };
  }

  static Route<dynamic> generateRoute(RouteSettings settings) {
    switch (settings.name) {
      case bookAppoinment:
        final hospital = settings.arguments as Map<String, dynamic>; // Get hospital data
        return MaterialPageRoute(
          builder: (context) => BookAppointmentPage(hospital: hospital),
        );
      default:
        return MaterialPageRoute(
          builder: (context) => Scaffold(body: Center(child: Text('Page Not Found'))),
        );
    }
  }
}
