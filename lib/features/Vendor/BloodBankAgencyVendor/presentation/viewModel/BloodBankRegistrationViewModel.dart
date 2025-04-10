import 'dart:io';
import 'package:flutter/material.dart';
import 'package:vedika_healthcare/features/Vendor/BloodBankAgencyVendor/data/model/BloodBankAgency.dart';
import 'package:vedika_healthcare/features/Vendor/BloodBankAgencyVendor/data/services/BloodbankAgencyStorageService.dart';
import 'package:vedika_healthcare/shared/utils/state_city_data.dart';
import 'package:logger/logger.dart';

class BloodBankRegistrationViewModel extends ChangeNotifier {
  final Logger logger = Logger();

  // Create an instance of BloodbankAgencyStorageService directly here
  final BloodbankAgencyStorageService storageService = BloodbankAgencyStorageService();

  // Text Controllers
  final agencyNameController = TextEditingController();
  final ownerNameController = TextEditingController();
  final gstNumberController = TextEditingController();
  final panNumberController = TextEditingController();
  final govtRegNumberController = TextEditingController();
  final addressController = TextEditingController();
  final landmarkController = TextEditingController();
  final mainContactController = TextEditingController();
  final emergencyContactController = TextEditingController();
  final emailController = TextEditingController();
  final websiteController = TextEditingController();
  final distanceLimitController = TextEditingController();
  final otherServicesController = TextEditingController();
  final preciseLocationController = TextEditingController();
  final pincodeController = TextEditingController();
  final phoneNumberController = TextEditingController();

  // Toggles
  bool is24x7 = false;
  bool allDaysWorking = false;
  bool acceptsOnlinePayment = false;
  bool providesPlatelets = false;

  // Multi-select using ValueNotifier
  final ValueNotifier<List<String>> selectedBloodServices = ValueNotifier([]);
  final ValueNotifier<List<String>> selectedLanguages = ValueNotifier([]);
  final ValueNotifier<List<String>> operationalAreas = ValueNotifier([]);

  // File lists
  List<Map<File, String>> licenseFiles = [];
  List<Map<File, String>> registrationCertificateFiles = [];
  List<Map<File, String>> agencyPhotos = [];

  // File upload states
  List<Map<String, String>> uploadedLicenseFiles = [];
  List<Map<String, String>> uploadedRegistrationCertificateFiles = [];
  List<Map<String, String>> uploadedAgencyPhotos = [];

  // Loading state - make it private and provide getter
  bool isLoading = false;
  bool get Loading => isLoading;
  // Location
  double? latitude;
  double? longitude;

  // State and City Dropdown Management
  final List<String> statesList = StateCityDataProvider.states.map((e) => e.name).toList();
  List<String> citiesList = [];

  final ValueNotifier<String?> selectedState = ValueNotifier<String?>(null);
  final ValueNotifier<String?> selectedCity = ValueNotifier<String?>(null);

  final List<String> bloodOptions = ['Whole Blood', 'Plasma', 'RBC', 'Platelets'];
  final List<String> languages = ['English', 'Hindi', 'Marathi', 'Gujarati'];

  BloodBankRegistrationViewModel() {
    selectedState.addListener(_onStateChanged);
  }

  void _onStateChanged() {
    final state = selectedState.value;
    if (state != null) {
      citiesList = StateCityDataProvider.getCities(state);
    } else {
      citiesList = [];
    }
    selectedCity.value = null; // Reset city on state change
    notifyListeners(); // Notify UI
  }

  // Setters and Location
  void setSelectedState(String state) {
    selectedState.value = state;
    citiesList = StateCityDataProvider.getCities(state);
    selectedCity.value = null;
    notifyListeners();
  }

  void setSelectedCity(String city) {
    selectedCity.value = city;
    notifyListeners();
  }

  // Add Operational Area
  void addOperationalArea(String area) {
    operationalAreas.value = [...operationalAreas.value, area];
    notifyListeners();
  }

  void removeOperationalArea(String area) {
    operationalAreas.value = operationalAreas.value.where((e) => e != area).toList();
    notifyListeners();
  }

  // Toggle Methods
  void toggle24x7(bool value) {
    is24x7 = value;
    notifyListeners();
  }

  void toggleAllDays(bool value) {
    allDaysWorking = value;
    notifyListeners();
  }

  void toggleOnlinePayment(bool value) {
    acceptsOnlinePayment = value;
    notifyListeners();
  }

  void togglePlatelets(bool value) {
    providesPlatelets = value;
    notifyListeners();
  }

  // Multi-select Updates
  void updateBloodServices(String service, bool isSelected) {
    final list = selectedBloodServices.value;
    isSelected ? list.add(service) : list.remove(service);
    selectedBloodServices.value = List.from(list);
  }

  void updateLanguages(String language, bool isSelected) {
    final list = selectedLanguages.value;
    isSelected ? list.add(language) : list.remove(language);
    selectedLanguages.value = List.from(list);
  }

  // Location Setter
  void setLatLng(double lat, double lng) {
    latitude = lat;
    longitude = lng;
    notifyListeners();
  }

  Future<void> addRegistrationCertificateFile(File file, String name) async {
    // Check if the file with the same name already exists in the list
    if (registrationCertificateFiles.any((fileMap) => fileMap.containsValue(name))) {
      logger.w('File with name $name already added.');
      return; // Prevent adding the same file
    }
    registrationCertificateFiles.add({file: name});
    notifyListeners();  // Notify UI to reflect changes
  }

  Future<void> addLicenseFile(File file, String name) async {
    // Check if the file with the same name already exists in the list
    if (licenseFiles.any((fileMap) => fileMap.containsValue(name))) {
      logger.w('File with name $name already added.');
      return; // Prevent adding the same file
    }
    licenseFiles.add({file: name});
    notifyListeners();  // Notify UI to reflect changes
  }

  Future<void> addOfficePhoto(File file, String name) async {
    // Check if the file with the same name already exists in the list
    if (agencyPhotos.any((fileMap) => fileMap.containsValue(name))) {
      logger.w('File with name $name already added.');
      return; // Prevent adding the same file
    }
    agencyPhotos.add({file: name});
    notifyListeners();  // Notify UI to reflect changes
  }

  Future<void> submitRegistration() async {
    if (isLoading) {
      logger.w('Uploading in progress. Please wait until all files are uploaded.');
      return;
    }


    // Set loading state to true when the process starts
    isLoading = true;
    notifyListeners(); // Notify UI about loading state change

    // Check if necessary files are selected
    if (licenseFiles.isEmpty || registrationCertificateFiles.isEmpty) {
      logger.w('License file or registration certificate is missing.');
      isLoading = false; // Reset loading state before returning
      return;
    }

    // Upload License Files
    for (var fileMap in licenseFiles) {
      final file = fileMap.keys.first;
      final name = fileMap[file];
      if (file != null && name != null) {
        final downloadUrl = await storageService.uploadFile(file, fileType: 'licenses');
        uploadedLicenseFiles.add({'name': name, 'url': downloadUrl});
        notifyListeners(); // Update UI after each file upload if needed
      }

    }

    // Upload Registration Certificate Files
    for (var fileMap in registrationCertificateFiles) {
      final file = fileMap.keys.first;
      final name = fileMap[file];
      if (file != null && name != null) {
        final downloadUrl = await storageService.uploadFile(file, fileType: 'registration_certificates');
        uploadedRegistrationCertificateFiles.add({'name': name, 'url': downloadUrl});
        notifyListeners(); // Update UI after each file upload if needed

      }
    }

    // Upload Agency Photos
    for (var fileMap in agencyPhotos) {
      final file = fileMap.keys.first;
      final name = fileMap[file];
      if (file != null && name != null) {
        final downloadUrl = await storageService.uploadFile(file, fileType: 'agency_photos');
        uploadedAgencyPhotos.add({'name': name, 'url': downloadUrl});
        notifyListeners(); // Update UI after each file upload if needed

      }
    }

    // Create BloodBankAgency model with uploaded URLs
    final agency = BloodBankAgency(
      agencyName: agencyNameController.text,
      gstNumber: gstNumberController.text,
      panNumber: panNumberController.text,
      ownerName: ownerNameController.text,
      completeAddress: addressController.text,
      nearbyLandmark: landmarkController.text,
      emergencyContactNumber: emergencyContactController.text,
      email: emailController.text,
      website: websiteController.text.isNotEmpty ? websiteController.text : null,
      languageProficiency: selectedLanguages.value.join(', '),
      deliveryOperationalAreas: operationalAreas.value,
      distanceLimitations: int.tryParse(distanceLimitController.text) ?? 0,
      is24x7Operational: is24x7,
      isAllDaysWorking: allDaysWorking,
      bloodServicesProvided: selectedBloodServices.value,
      plateletServicesProvided: providesPlatelets ? ['Platelets'] : [],
      otherServicesProvided: otherServicesController.text
          .split(',')
          .map((e) => e.trim())
          .where((e) => e.isNotEmpty)
          .toList(),
      acceptsOnlinePayment: acceptsOnlinePayment,
      agencyPhotos: uploadedAgencyPhotos,
      licenseFiles: uploadedLicenseFiles,
      registrationCertificateFiles: uploadedRegistrationCertificateFiles,
      googleMapsLocation: preciseLocationController.text,
      state: selectedState.value ?? '',
      city: selectedCity.value ?? '',
      pincode: pincodeController.text,
      phoneNumber: phoneNumberController.text,
    );

    logger.i("Submitting Agency:");
    logger.d(agency.toJson());

    // TODO: Call repository/API to submit agency.toJson()

    // Reset loading state after the submission
    isLoading = false;
    notifyListeners(); // Update UI after each file upload if needed

  }



  // Clean-up
  void disposeControllers() {
    agencyNameController.dispose();
    ownerNameController.dispose();
    gstNumberController.dispose();
    panNumberController.dispose();
    govtRegNumberController.dispose();
    addressController.dispose();
    landmarkController.dispose();
    mainContactController.dispose();
    emergencyContactController.dispose();
    emailController.dispose();
    websiteController.dispose();
    distanceLimitController.dispose();
    otherServicesController.dispose();
    preciseLocationController.dispose();
    pincodeController.dispose();
    phoneNumberController.dispose();
  }
}
