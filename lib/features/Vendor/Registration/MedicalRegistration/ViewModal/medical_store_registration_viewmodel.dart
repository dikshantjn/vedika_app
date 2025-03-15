import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:vedika_healthcare/features/Vendor/Registration/MedicalRegistration/Service/MedicalStoreVendorService.dart';
import 'package:vedika_healthcare/features/Vendor/Registration/Models/Vendor.dart';
import 'package:vedika_healthcare/features/Vendor/Registration/Models/VendorMedicalStoreProfile.dart';
import 'package:vedika_healthcare/features/Vendor/Registration/Models/hospital_model.dart';
import 'package:vedika_healthcare/shared/utils/state_city_data.dart';

class MedicalStoreRegistrationViewModel extends ChangeNotifier {

  // MedicalStoreVendorService instance
  final MedicalStoreVendorService _vendorService = MedicalStoreVendorService();
  // Controllers for text fields
  final List<TextEditingController> _controllers = List.generate(
    18, // Increased count to include new fields
        (_) => TextEditingController(),
  );

  VoidCallback get registrationUpload => licenseUpload;

  TextEditingController get storeNameController => _controllers[0];
  TextEditingController get ownerNameController => _controllers[1];
  TextEditingController get stateController => _controllers[2];
  TextEditingController get cityController => _controllers[3];
  TextEditingController get pincodeController => _controllers[4];
  TextEditingController get contactNumberController => _controllers[5];
  TextEditingController get emailController => _controllers[6];
  TextEditingController get websiteController => _controllers[7];
  TextEditingController get gstNumberController => _controllers[8];
  TextEditingController get drugLicenseNumberController => _controllers[9];
  TextEditingController get addressController => _controllers[10];
  TextEditingController get panNumberController => _controllers[11];
  TextEditingController get specialMedicationsController => _controllers[12];
  TextEditingController get storeTimingController => _controllers[13];
  TextEditingController get storeDaysController => _controllers[14];

  // **Newly Added Controllers**
  TextEditingController get landmarkController => _controllers[15];
  TextEditingController get contactController => _controllers[16];

  TextEditingController floorController = TextEditingController(); // Separate controller

  // Dropdown selections
  ValueNotifier<String?> medicineType = ValueNotifier<String?>(null);
  ValueNotifier<String?> paymentOptions = ValueNotifier<String?>(null);

  // Checkboxes
  ValueNotifier<bool> liftAccess = ValueNotifier<bool>(false);
  ValueNotifier<bool> wheelchairAccess = ValueNotifier<bool>(false);
  ValueNotifier<bool> parking = ValueNotifier<bool>(false);

  // Medical Store Data
  String generatedStoreId = "";

  // Registration Certificates (e.g., Drug License, GST Registration)
  List<RegistrationCertificate> registrationCertificates = [];
  TextEditingController medicalOwnerController = TextEditingController();

  // Store Images
  List<MedicalStoreImage> imageUrls = [];

  Map<String, String> certificateDescriptions = {}; // Maps certificate URLs to descriptions
  Map<String, String> imageDescriptions = {}; // Maps image URLs to descriptions

  /// **Set Registration Certificates**
  void setRegistrationCertificates(List<RegistrationCertificate> certificates) {
    registrationCertificates = certificates;
    notifyListeners();
  }

  /// **Add a Single Registration Certificate**
  void addRegistrationCertificate(RegistrationCertificate certificate) {
    if (!registrationCertificates.contains(certificate)) {
      registrationCertificates.add(certificate);
      notifyListeners();
    }
  }

  /// **Remove a Registration Certificate**
  void removeRegistrationCertificate(RegistrationCertificate certificate) {
    registrationCertificates.remove(certificate);
    notifyListeners();
  }

  /// **Set Store Images**
  void setMedicalStoreImages(List<MedicalStoreImage> images) {
    imageUrls = images;
    notifyListeners();
  }

  /// **Add a Single Store Image**
  void addImage(MedicalStoreImage image) {
    if (!imageUrls.contains(image)) {
      imageUrls.add(image);
      notifyListeners();
    }
  }

  /// **Remove a Store Image**
  void removeImage(MedicalStoreImage image) {
    imageUrls.remove(image);
    notifyListeners();
  }

  /// **Update Description for a Certificate**
  void updateCertificateDescription(String certificateUrl, String description) {
    certificateDescriptions[certificateUrl] = description;
    notifyListeners();
  }

  /// **Update Description for a Store Image**
  void updateImageDescription(String imageUrl, String description) {
    imageDescriptions[imageUrl] = description;
    notifyListeners();
  }

  /// **Get List of States**
  List<String> getStates() {
    return StateCityDataProvider.states.map((state) => state.name).toList();
  }

  /// **Get List of Cities for Selected State**
  List<String> getCities(String stateName) {
    return StateCityDataProvider.getCities(stateName);
  }

  void updateState(String state) {
    stateController.text = state;
    notifyListeners();
  }

  void updateCity(String city) {
    cityController.text = city;
    notifyListeners();
  }

  /// **Generate a Unique Medical Store ID**
  int _storeCounter = 1;

  void generateStoreId() {
    final storeName = storeNameController.text.trim();
    final stateName = stateController.text.trim();
    final cityName = cityController.text.trim();

    print("Store Name: $storeName");
    print("State Name: $stateName");
    print("City Name: $cityName");

    // Fetch State Code
    final stateCode = StateCityDataProvider.getStateCode(stateName);
    print("State Code: $stateCode");

    // Fetch City Code
    final cityCode = StateCityDataProvider.getCityCode(stateName, cityName);
    print("City Code: $cityCode");

    if (storeName.isEmpty || stateCode.isEmpty || cityCode.isEmpty) {
      generatedStoreId = "Invalid - Complete Address Required";
    } else {
      final nameInitial = "C"; // Store Initial
      final sequentialNumber = NumberFormat("00000").format(_storeCounter);
      generatedStoreId = "$nameInitial-$stateCode-$cityCode-$sequentialNumber";

      _storeCounter++; // Increment counter (Fetch from DB for persistence)
    }

    print("Generated Store ID: $generatedStoreId");
    notifyListeners();
  }

  /// **Handle File Uploads**
  VoidCallback licenseUpload = () {
    print("Upload Registration & Licensing Document clicked");
  };

  VoidCallback complianceUpload = () {
    print("Upload Compliance Document clicked");
  };

  VoidCallback photoUpload = () {
    print("Upload Store Photos clicked");
  };

  // **Other variables and methods**

  /// **Handle Vendor Registration**
  Future<void> registerVendor() async {
    // Collect data from controllers and prepare Vendor and VendorMedicalStoreProfile objects
    final vendor = Vendor(
      generatedId: generatedStoreId,
      vendorRole: 3, // Assuming role is Medical Store
      phoneNumber: contactNumberController.text,
      email: emailController.text,
    );

    final medicalStore = VendorMedicalStoreProfile(
      vendorId: vendor.vendorId, // Assign vendor ID after saving the Vendor
      name: storeNameController.text,
      address: addressController.text,
      landmark: landmarkController.text,
      state: stateController.text,
      city: cityController.text,
      pincode: pincodeController.text,
      contactNumber: contactNumberController.text,
      ownerName: ownerNameController.text,
      licenseNumber: drugLicenseNumberController.text,
      gstNumber: gstNumberController.text,
      storeTiming: storeTimingController.text,
      storeDays: storeDaysController.text,
      floor: floorController.text,
      availableMedicines: [specialMedicationsController.text], // Adjust as per your needs
      images: imageUrls.map((image) => image.imageUrl).toList(), // Assuming image URLs are stored
    );
    print('Sending vendor: $vendor');
    print('Sending medical store: $medicalStore');

    try {
      // Call the registerVendor method in the service class
      final response = await _vendorService.registerVendor(
        vendor: vendor, // Pass vendor as named argument
        medicalStore: medicalStore, // Pass medicalStore as named argument
      );
      if (response.statusCode == 200) {
        // Registration successful, handle success (e.g., show a message, navigate, etc.)
        print("Vendor registered successfully");
        // Optionally, notify listeners to update UI if needed
      } else {
        // Handle server-side error
        print("Failed to register vendor: ${response.data}");
      }
    } catch (e) {
      // Handle network or other errors
      print("Error during registration: $e");
    }
  }


  /// **Dispose Controllers Properly**
  @override
  void dispose() {
    for (var controller in _controllers) {
      controller.dispose();
    }
    floorController.dispose();
    super.dispose();
  }
}
