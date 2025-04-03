import 'package:flutter/material.dart';
import 'package:vedika_healthcare/features/Vendor/AmbulanceAgencyVendor/data/modals/AmbulanceAgency.dart';

class AmbulanceAgencyViewModel extends ChangeNotifier {
  AmbulanceAgency? agency;

  // Constructor to initialize the agency object
  AmbulanceAgencyViewModel() {
    agency = AmbulanceAgency(
      agencyName: '',
      gstNumber: '',
      panNumber: '',
      ownerName: '',
      registrationNumber: '',
      address: '',
      landmark: '',
      contactNumber: '',
      email: '',
      website: '',
      numOfAmbulances: 0,
      driverKYC: false,
      driverTrained: false,
      ambulanceTypes: [],
      gpsTrackingAvailable: false,
      ambulanceEquipment: [],
      trainingCertifications: [],
      languageProficiency: [],
      operationalAreas: [],
      is24x7Available: false,
      distanceLimit: 0.0,
      isOnlinePaymentAvailable: false,
      officePhotos: '',
      preciseLocation: '',
      vendorId: '',
      generatedId: '',
      driverLicense: '', // Add driverLicense field to initialize
    );
  }

  // Form validation, including driver license check
  bool validateForm() {
    if (agency?.agencyName.isEmpty ?? true) return false;
    if (agency?.gstNumber.isEmpty ?? true) return false;
    if (agency?.ownerName.isEmpty ?? true) return false;
    if (agency?.contactNumber.isEmpty ?? true) return false;
    if (agency?.driverLicense.isEmpty ?? true) return false; // Ensure driverLicense is provided
    return true;
  }

  // Update agency data (including driverLicense)
  void updateAgency(AmbulanceAgency updatedAgency) {
    agency = updatedAgency;
    notifyListeners();
  }

  // Submit function (simulate API call)
  Future<void> submitRegistration() async {
    // Mock API call delay
    await Future.delayed(Duration(seconds: 2));
    // Handle submission (store data or show success/failure)
    print("Agency Registered: ${agency?.agencyName}");
  }
}
