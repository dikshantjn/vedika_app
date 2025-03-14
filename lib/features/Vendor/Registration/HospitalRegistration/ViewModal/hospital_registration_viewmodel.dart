import 'package:flutter/material.dart';
import 'package:vedika_healthcare/features/Vendor/Registration/Models/hospital_model.dart';

class HospitalRegistrationViewModel extends ChangeNotifier {
  late final List<TextEditingController> _controllers; // List of controllers

  // Controllers for form fields
  final TextEditingController hospitalNameController = TextEditingController();
  final TextEditingController ownerNameController = TextEditingController();
  final TextEditingController stateController = TextEditingController();
  final TextEditingController cityController = TextEditingController();
  final TextEditingController pincodeController = TextEditingController();
  final TextEditingController contactNumberController = TextEditingController();
  final TextEditingController emailController = TextEditingController();
  final TextEditingController websiteController = TextEditingController();
  final TextEditingController licenseNumberController = TextEditingController();
  final TextEditingController availableBedsController = TextEditingController();
  final TextEditingController specialtiesController = TextEditingController();
  final TextEditingController addressController = TextEditingController();

  // Hospital Data
  List<String> specialties = [];
  String generatedHospitalId = "";

  // Change to List<RegistrationCertificate> instead of List<String>
  List<RegistrationCertificate> registrationCertificates = []; // Stores multiple registration certificate objects

  // Change to List<HospitalImage> instead of List<String>
  List<HospitalImage> imageUrls = []; // Stores multiple hospital image objects

  Map<String, String> certificateDescriptions = {}; // Maps certificate URLs to descriptions
  Map<String, String> imageDescriptions = {}; // Maps image URLs to descriptions

  /// **Constructor**
  HospitalRegistrationViewModel() {
    _initControllers();
  }

  /// **Initialize Controllers**
  void _initControllers() {
    _controllers = [
      hospitalNameController,
      ownerNameController,
      stateController,
      cityController,
      pincodeController,
      contactNumberController,
      emailController,
      websiteController,
      licenseNumberController,
      availableBedsController,
      specialtiesController,
      addressController
    ];
  }

  /// **Update Specialties List**
  void setSpecialties(List<String> specialtiesList) {
    specialties = specialtiesList.toSet().toList(); // Remove duplicates
    notifyListeners();
  }

  /// **Set Multiple Registration Certificates**
  void setRegistrationCertificates(List<RegistrationCertificate> certificates) {
    registrationCertificates = certificates; // No need to convert to a set if it's already a list of objects
    notifyListeners();
  }

  /// **Add a Single Registration Certificate**
  void addRegistrationCertificate(RegistrationCertificate certificate) {
    if (!registrationCertificates.contains(certificate)) {
      registrationCertificates.add(certificate);
      notifyListeners();
    }
  }

  // In your HospitalRegistrationViewModel
  void removeRegistrationCertificate(dynamic file) {
    if (file is RegistrationCertificate) {
      registrationCertificates.remove(file);
      notifyListeners(); // to notify UI for updates
    }
  }


  /// **Set Multiple Hospital Images at Once**
  void setHospitalImages(List<HospitalImage> images) {
    imageUrls = images; // Directly assign the list of HospitalImage objects
    notifyListeners();
  }

  /// **Add a Single Hospital Image**
  void addImage(HospitalImage image) {
    if (!imageUrls.contains(image)) {
      imageUrls.add(image);
      notifyListeners();
    }
  }

  void removeImage(dynamic file) {
    if (file is HospitalImage) {
      imageUrls.remove(file);
      notifyListeners(); // to notify UI for updates
    }
  }

  /// **Update Registration Certificate Description**
  void updateCertificateDescription(String certificateUrl, String description) {
    certificateDescriptions[certificateUrl] = description;
    notifyListeners();
  }

  /// **Update Hospital Image Description**
  void updateImageDescription(String imageUrl, String description) {
    imageDescriptions[imageUrl] = description;
    notifyListeners();
  }

  /// **Generate a Unique Hospital ID**
  void generateHospitalId() {
    String nameInitial = hospitalNameController.text.isNotEmpty
        ? hospitalNameController.text[0].toUpperCase()
        : "H";

    String stateCode = stateController.text.isNotEmpty ? stateController.text.toUpperCase() : "XX";
    String cityCode = cityController.text.isNotEmpty ? cityController.text.toUpperCase() : "YY";
    String pincode = pincodeController.text.isNotEmpty ? pincodeController.text : "000000";

    if (stateCode == "XX" || cityCode == "YY" || pincode == "000000") {
      generatedHospitalId = "Invalid - Complete Address Required";
    } else {
      generatedHospitalId = "HOSP-${nameInitial}-${stateCode}-${cityCode}-$pincode";
    }
    notifyListeners();
  }

  // Get Description for a File (either image or certificate)
  String getDescriptionForFile(String filePath) {
    // Check if it's a certificate and return the description if exists
    if (certificateDescriptions.containsKey(filePath)) {
      return certificateDescriptions[filePath]!;
    }

    // Check if it's an image and return the description if exists
    if (imageDescriptions.containsKey(filePath)) {
      return imageDescriptions[filePath]!;
    }

    // Return an empty string if no description exists
    return '';
  }

  /// **Dispose Controllers Properly**
  @override
  void dispose() {
    for (var controller in _controllers) {
      controller.dispose();
    }
    super.dispose();
  }
}
