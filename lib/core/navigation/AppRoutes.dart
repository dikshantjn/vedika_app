import 'package:flutter/material.dart';
import 'package:vedika_healthcare/features/bloodBank/presentation/view/bloodBankPage.dart';


class AppRoutes {
  static const String medicine = "/medicine";
  static const String labTest = "/labTest";
  static const String bloodBank = "/bloodBank";
  static const String clinic = "/clinic";
  static const String hospital = "/hospital";

  static Map<String, WidgetBuilder> getRoutes() {
    return {
      // medicine: (context) => (),
      // labTest: (context) => LabTestPage(),
      bloodBank: (context) => BloodBankMapScreen(),
      // clinic: (context) => ClinicPage(),
      // hospital: (context) => HospitalPage(),
    };
  }
}
