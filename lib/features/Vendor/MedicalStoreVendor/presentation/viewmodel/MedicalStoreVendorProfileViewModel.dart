import 'package:flutter/material.dart';

class MedicalStoreVendorProfileViewModel extends ChangeNotifier {
  String storeName = "ABC Medical Store";
  String gstNumber = "22ABCDE1234F1Z5";
  String panNumber = "ABCDE1234F";
  String registrationCertificate = "Registered";
  String complianceCertificate = "Compliant";
  String medicineType = "Alopathy";
  bool isRareMedicationsAvailable = true;
  bool isOnlinePayment = true;
  String address = "123, Main Road, City";
  String nearbyLandmark = "Opposite City Mall";
  String storeTiming = "9:00 AM - 9:00 PM";
  String storeOpenDays = "Monday - Saturday";
  String contactNumber = "+91 9876543210";
  String emailId = "abcmedical@gmail.com";
  String floor = "Ground Floor";
  bool isLiftAccess = true;
  bool isWheelchairAccess = true;
  bool isParkingAvailable = true;

  // ✅ Add storeImages getter
  List<String> get storeImages => [
    "assets/images/store1.jpg",
    "assets/images/store2.jpg",
    "assets/images/store3.jpg",
  ];

  void fetchProfileData() {
    // Simulating data fetching, replace with actual API call
    notifyListeners();
  }
}
