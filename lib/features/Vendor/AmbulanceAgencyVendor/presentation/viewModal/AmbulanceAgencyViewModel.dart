import 'dart:io';

import 'package:flutter/material.dart';
import 'package:vedika_healthcare/features/Vendor/AmbulanceAgencyVendor/data/modals/AmbulanceAgency.dart';
import 'package:vedika_healthcare/features/Vendor/AmbulanceAgencyVendor/data/services/AmbulanceAgencyService.dart';
import 'package:vedika_healthcare/features/Vendor/AmbulanceAgencyVendor/data/services/AmbulanceAgencyStorageService.dart';
import 'package:vedika_healthcare/features/Vendor/Registration/Models/Vendor.dart';

class AmbulanceAgencyViewModel extends ChangeNotifier {
  // Controllers for text input fields
  final TextEditingController agencyNameController = TextEditingController();
  final TextEditingController gstNumberController = TextEditingController();
  final TextEditingController panNumberController = TextEditingController();
  final TextEditingController ownerNameController = TextEditingController();
  final TextEditingController registrationNumberController = TextEditingController();
  final TextEditingController addressController = TextEditingController();
  final TextEditingController landmarkController = TextEditingController();
  final TextEditingController contactNumberController = TextEditingController();
  final TextEditingController emailController = TextEditingController();
  final TextEditingController websiteController = TextEditingController();
  final TextEditingController numOfAmbulancesController = TextEditingController();
  final TextEditingController distanceLimitController = TextEditingController();
  final TextEditingController preciseLocationController = TextEditingController();
  final TextEditingController vendorIdController = TextEditingController();
  final TextEditingController generatedIdController = TextEditingController();
  final TextEditingController driverLicenseController = TextEditingController();
  final TextEditingController stateController = TextEditingController();
  final TextEditingController cityController = TextEditingController();
  final TextEditingController pinCodeController = TextEditingController();

  // Boolean fields
  bool driverKYC = false;
  bool driverTrained = false;
  bool gpsTrackingAvailable = false;
  bool is24x7Available = false;
  bool isOnlinePaymentAvailable = false;

  // Temporary holding for files before upload
  List<Map<String, dynamic>> officePhotoFiles = [];
  List<Map<String, dynamic>> trainingCertificationFiles = [];

  // List fields
  List<String> ambulanceTypes = [];
  List<String> ambulanceEquipment = [];
  List<Map<String, String>> trainingCertifications = [];
  List<String> languageProficiency = [];
  List<String> operationalAreas = [];
  List<Map<String, String>> officePhotos = [];

  final AmbulanceAgencyStorageService _storageService = AmbulanceAgencyStorageService();

  // Form validation
  bool validateForm() {
    return agencyNameController.text.isNotEmpty &&
        gstNumberController.text.isNotEmpty &&
        ownerNameController.text.isNotEmpty &&
        contactNumberController.text.isNotEmpty &&
        driverLicenseController.text.isNotEmpty &&
        stateController.text.isNotEmpty &&
        cityController.text.isNotEmpty &&
        pinCodeController.text.isNotEmpty;
  }

  // Update boolean fields
  void updateBooleanField(String fieldName, bool value) {
    switch (fieldName) {
      case 'driverKYC':
        driverKYC = value;
        break;
      case 'driverTrained':
        driverTrained = value;
        break;
      case 'gpsTrackingAvailable':
        gpsTrackingAvailable = value;
        break;
      case 'is24x7Available':
        is24x7Available = value;
        break;
      case 'isOnlinePaymentAvailable':
        isOnlinePaymentAvailable = value;
        break;
    }
    notifyListeners();
  }

  void updateListField(String fieldName, List<dynamic> values) {
    switch (fieldName) {
      case 'ambulanceTypes':
        ambulanceTypes = List<String>.from(values);
        break;
      case 'ambulanceEquipment':
        ambulanceEquipment = List<String>.from(values);
        break;
      case 'trainingCertifications':
        trainingCertifications = List<Map<String, String>>.from(values);
        break;
      case 'languageProficiency':
        languageProficiency = List<String>.from(values);
        break;
      case 'operationalAreas':
        operationalAreas = List<String>.from(values);
        break;
      case 'officePhotos':
        officePhotos = List<Map<String, String>>.from(values);
        break;
    }
    notifyListeners();
  }


  // Upload and add a file to officePhotos
  Future<void> uploadAndAddOfficePhoto(File file, String fileType) async {
    try {
      final String vendorId = vendorIdController.text;
      final Map<String, String> uploadedFile = await _storageService.uploadFile(
        file,
        vendorId: vendorId,
        fileType: fileType,
      );
      officePhotos.add(uploadedFile);
      notifyListeners();
    } catch (e) {
      print('Error uploading and adding photo: $e');
    }
  }

  // Convert form data into model
  AmbulanceAgency getAmbulanceAgency() {
    return AmbulanceAgency(
      agencyName: agencyNameController.text,
      gstNumber: gstNumberController.text,
      panNumber: panNumberController.text,
      ownerName: ownerNameController.text,
      registrationNumber: registrationNumberController.text,
      address: addressController.text,
      landmark: landmarkController.text,
      contactNumber: contactNumberController.text,
      email: emailController.text,
      website: websiteController.text,
      numOfAmbulances: int.tryParse(numOfAmbulancesController.text) ?? 0,
      driverKYC: driverKYC,
      driverTrained: driverTrained,
      ambulanceTypes: ambulanceTypes,
      gpsTrackingAvailable: gpsTrackingAvailable,
      ambulanceEquipment: ambulanceEquipment,
      trainingCertifications: trainingCertifications,
      languageProficiency: languageProficiency,
      operationalAreas: operationalAreas,
      is24x7Available: is24x7Available,
      distanceLimit: double.tryParse(distanceLimitController.text) ?? 0.0,
      isOnlinePaymentAvailable: isOnlinePaymentAvailable,
      officePhotos: officePhotos,
      preciseLocation: preciseLocationController.text,
      vendorId: vendorIdController.text,
      generatedId: generatedIdController.text,
      driverLicense: driverLicenseController.text,
      state: stateController.text,
      city: cityController.text,
      pinCode: pinCodeController.text,
      isLive: true
    );
  }

  Future<void> submitRegistration() async {
    if (!validateForm()) {
      throw Exception('Please fill all required fields.');
    }

    try {
      // 1. Upload office photos
      officePhotos = [];
      for (var item in officePhotoFiles) {
        final result = await _storageService.uploadFile(
          item['file'],
          vendorId: vendorIdController.text,
          fileType: 'office_photo',
        );
        officePhotos.add({'name': item['name'], 'url': result['url'] ?? ''});
      }

      // 2. Upload training certificates
      trainingCertifications = [];
      for (var item in trainingCertificationFiles) {
        final result = await _storageService.uploadFile(
          item['file'],
          vendorId: vendorIdController.text,
          fileType: 'training_certification',
        );
        trainingCertifications.add({'name': item['name'], 'url': result['url'] ?? ''});
      }

      // 3. Build ambulance agency model
      final agencyData = getAmbulanceAgency();

      // 4. Build vendor model from agency data
      final vendor = Vendor(
        vendorRole: 4, // Example: 3 for Ambulance agency vendor
        vendorId: vendorIdController.text,
        phoneNumber: contactNumberController.text,
        email: emailController.text,
        generatedId: generatedIdController.text,
      );

      // 5. Submit both models
      await AmbulanceAgencyService().registerAgencyWithVendor(
        agency: agencyData,
        vendor: vendor,
      );

    } catch (e) {
      print('Registration submission failed: $e');
      rethrow;
    }
  }


  @override
  void dispose() {
    agencyNameController.dispose();
    gstNumberController.dispose();
    panNumberController.dispose();
    ownerNameController.dispose();
    registrationNumberController.dispose();
    addressController.dispose();
    landmarkController.dispose();
    contactNumberController.dispose();
    emailController.dispose();
    websiteController.dispose();
    numOfAmbulancesController.dispose();
    distanceLimitController.dispose();
    preciseLocationController.dispose();
    vendorIdController.dispose();
    generatedIdController.dispose();
    driverLicenseController.dispose();
    stateController.dispose();
    cityController.dispose();
    pinCodeController.dispose();
    super.dispose();
  }


  void addOfficePhoto(File file, String name) {
    officePhotoFiles.add({'file': file, 'name': name});
    notifyListeners();
  }

  void addTrainingCertification(File file, String name) {
    trainingCertificationFiles.add({'file': file, 'name': name});
    notifyListeners();
  }
}
