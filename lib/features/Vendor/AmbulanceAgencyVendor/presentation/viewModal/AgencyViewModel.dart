import 'package:flutter/material.dart';
import 'package:vedika_healthcare/features/Vendor/AmbulanceAgencyVendor/data/modals/AmbulanceAgency.dart';

class AgencyViewModel extends ChangeNotifier {
  // Initialize with a sample agency data, including the new isLive property
  AmbulanceAgency _agency = AmbulanceAgency(
    agencyName: "Sample Agency",
    gstNumber: "123456789",
    panNumber: "ABCDE1234F",
    ownerName: "John Doe",
    registrationNumber: "AB123456",
    address: "123 Sample Street",
    landmark: "Near Park",
    contactNumber: "9876543210",
    email: "contact@sampleagency.com",
    website: "www.sampleagency.com",
    numOfAmbulances: 5,
    driverKYC: true,
    driverTrained: true,
    ambulanceTypes: ["BLS", "ALS"],
    gpsTrackingAvailable: true,
    ambulanceEquipment: ["Oxygen", "Defibrillator"],
    trainingCertifications: [{"type": "First Aid", "url": "cert1"}],
    languageProficiency: ["English", "Hindi"],
    operationalAreas: ["Area 1", "Area 2"],
    is24x7Available: true,
    distanceLimit: 50.0,
    isOnlinePaymentAvailable: true,
    officePhotos: [{"name": "office1", "url": "https://example.com/photo1.jpg"}],
    preciseLocation: "Longitude: 20.34, Latitude: 25.78",
    vendorId: "VENDOR123",
    generatedId: "GEN123",
    driverLicense: "DL123456",
    state: "State Name",
    city: "City Name",
    pinCode: "123456",
    isLive: false, // Initially, the agency is offline
  );

  // Getter to retrieve the agency data
  AmbulanceAgency get agency => _agency;

  // Method to toggle the agency status (Live/Offline)
  void toggleAgencyStatus() {
    _agency = _agency.copyWith(isLive: !_agency.isLive);
    notifyListeners();
  }

  // Method to update the agency info (for example, name, contact, etc.)
  void updateAgencyInfo({
    String? agencyName,
    String? gstNumber,
    String? panNumber,
    String? ownerName,
    String? registrationNumber,
    String? address,
    String? landmark,
    String? contactNumber,
    String? email,
    String? website,
    int? numOfAmbulances,
    bool? driverKYC,
    bool? driverTrained,
    List<String>? ambulanceTypes,
    bool? gpsTrackingAvailable,
    List<String>? ambulanceEquipment,
    List<Map<String, String>>? trainingCertifications,
    List<String>? languageProficiency,
    List<String>? operationalAreas,
    bool? is24x7Available,
    double? distanceLimit,
    bool? isOnlinePaymentAvailable,
    List<Map<String, String>>? officePhotos,
    String? preciseLocation,
    String? vendorId,
    String? generatedId,
    String? driverLicense,
    String? state,
    String? city,
    String? pinCode,
    bool? isLive,
  }) {
    _agency = _agency.copyWith(
      agencyName: agencyName,
      gstNumber: gstNumber,
      panNumber: panNumber,
      ownerName: ownerName,
      registrationNumber: registrationNumber,
      address: address,
      landmark: landmark,
      contactNumber: contactNumber,
      email: email,
      website: website,
      numOfAmbulances: numOfAmbulances,
      driverKYC: driverKYC,
      driverTrained: driverTrained,
      ambulanceTypes: ambulanceTypes,
      gpsTrackingAvailable: gpsTrackingAvailable,
      ambulanceEquipment: ambulanceEquipment,
      trainingCertifications: trainingCertifications,
      languageProficiency: languageProficiency,
      operationalAreas: operationalAreas,
      is24x7Available: is24x7Available,
      distanceLimit: distanceLimit,
      isOnlinePaymentAvailable: isOnlinePaymentAvailable,
      officePhotos: officePhotos,
      preciseLocation: preciseLocation,
      vendorId: vendorId,
      generatedId: generatedId,
      driverLicense: driverLicense,
      state: state,
      city: city,
      pinCode: pinCode,
      isLive: isLive,
    );
    notifyListeners();
  }
}
