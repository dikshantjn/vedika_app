import 'dart:io';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:file_picker/file_picker.dart';
import 'package:vedika_healthcare/features/Vendor/MedicalStoreVendor/data/services/MedicalStoreFileUploadService.dart';
import 'package:vedika_healthcare/features/Vendor/Registration/MedicalRegistration/Service/MedicalStoreVendorService.dart';
import 'package:vedika_healthcare/features/Vendor/Registration/Models/Vendor.dart';
import 'package:vedika_healthcare/features/Vendor/Registration/Models/VendorMedicalStoreProfile.dart';
import 'package:vedika_healthcare/shared/utils/state_city_data.dart';

class MedicalStoreRegistrationViewModel extends ChangeNotifier {
  final MedicalStoreVendorService _vendorService = MedicalStoreVendorService();

  // Controllers for text fields
  final List<TextEditingController> _controllers = List.generate(
    20, (_) => TextEditingController(),
  );

  TextEditingController get storeNameController => _controllers[0];
  TextEditingController get ownerNameController => _controllers[1];
  TextEditingController get stateController => _controllers[2];
  TextEditingController get cityController => _controllers[3];
  TextEditingController get pincodeController => _controllers[4];
  TextEditingController get contactNumberController => _controllers[5];
  TextEditingController get emailController => _controllers[6];
  TextEditingController get websiteController => _controllers[7];
  TextEditingController get gstNumberController => _controllers[8];
  TextEditingController get licenseNumberController => _controllers[9];
  TextEditingController get addressController => _controllers[10];
  TextEditingController get panNumberController => _controllers[11];
  TextEditingController get specialMedicationsController => _controllers[12];
  TextEditingController get storeTimingController => _controllers[13];
  TextEditingController get storeDaysController => _controllers[14];
  TextEditingController get landmarkController => _controllers[15];
  TextEditingController get floorController => _controllers[16];
  TextEditingController get locationController => _controllers[17];
  String get location => locationController.text;

  // Setter for location (if needed)
  set location(String newLocation) {
    locationController.text = newLocation;
    notifyListeners();
  }

  // Dropdown selections
  ValueNotifier<String?> medicineType = ValueNotifier<String?>(null);
  ValueNotifier<String?> paymentOptions = ValueNotifier<String?>(null);

  // Checkboxes
  ValueNotifier<bool> isRareMedicationsAvailable = ValueNotifier<bool>(false);
  ValueNotifier<bool> isOnlinePayment = ValueNotifier<bool>(false);
  ValueNotifier<bool> isLiftAccess = ValueNotifier<bool>(false);
  ValueNotifier<bool> isWheelchairAccess = ValueNotifier<bool>(false);
  ValueNotifier<bool> isParkingAvailable = ValueNotifier<bool>(false);
  final ValueNotifier<String?> getLocation = ValueNotifier<String?>(null);

  // Medical Store Data
  String generatedStoreId = "";

  // File Uploads (Maintain Name & File Object)
  List<Map<String, Object>> registrationCertificates = [];
  List<Map<String, Object>> complianceCertificates = [];
  List<Map<String, Object>> storePhotos = [];

  /// **Set Registration Certificates**
  set setRegistrationCertificates(List<Map<String, Object>> certificates) {
    registrationCertificates = certificates;
    notifyListeners();
  }

  /// **Set Compliance Certificates**
  set setComplianceCertificates(List<Map<String, Object>> certificates) {
    complianceCertificates = certificates;
    notifyListeners();
  }

  /// **Set Store Photos**
  set setStorePhotos(List<Map<String, Object>> photos) {
    storePhotos = photos;
    notifyListeners();
  }

  /// **Upload Registration Certificates**
  Future<void> uploadRegistrationCertificates(List<Map<String, Object>> selectedFiles) async {
    print("Selected Files: $selectedFiles"); // Debugging line to see the content of the files

    if (selectedFiles != null && selectedFiles.isNotEmpty) {
      print("Uploading Registration Certificates...");
      print("Selected Files: $selectedFiles"); // Debugging line to see the content of the files

      registrationCertificates.addAll(selectedFiles);
      print("Updated Registration Certificates List: $registrationCertificates"); // Debugging the updated list

      notifyListeners();
    } else {
      print("No registration certificates selected or selectedFiles is empty.");
    }
  }

  /// **Upload Compliance Certificates**
  Future<void> uploadComplianceCertificates(List<Map<String, Object>> selectedFiles) async {
    print("Selected Files: $selectedFiles"); // Debugging line to see the content of the files

    if (selectedFiles != null && selectedFiles.isNotEmpty) {
      print("Uploading Compliance Certificates...");
      print("Selected Files: $selectedFiles"); // Debugging line to see the content of the files

      complianceCertificates.addAll(selectedFiles);
      print("Updated Compliance Certificates List: $complianceCertificates"); // Debugging the updated list

      notifyListeners();
    } else {
      print("No compliance certificates selected or selectedFiles is empty.");
    }
  }

  /// **Upload Store Photos**
  Future<void> uploadStorePhotos(List<Map<String, Object>> selectedFiles) async {
    print("Selected Files: $selectedFiles"); // Debugging line to see the content of the files

    if (selectedFiles != null && selectedFiles.isNotEmpty) {
      print("Uploading Store Photos...");
      print("Selected Files: $selectedFiles"); // Debugging line to see the content of the files

      storePhotos.addAll(selectedFiles);
      print("Updated Store Photos List: $storePhotos"); // Debugging the updated list

      notifyListeners();
    } else {
      print("No store photos selected or selectedFiles is empty.");
    }
  }

  /// **File Picker Helper**
  Future<List<Map<String, Object>>?> _pickFiles() async {
    FilePickerResult? result = await FilePicker.platform.pickFiles(
      type: FileType.custom,
      allowedExtensions: ['pdf', 'png', 'jpg', 'jpeg'],
      allowMultiple: true,
    );

    if (result != null) {
      return result.files
          .where((file) => file.path != null)
          .map((file) => {
        "dt": file.name,
        "file": File(file.path!)
      })
          .toList();
    }
    return null;
  }

  /// **Generate Unique Store ID**
  int _storeCounter = 1;
  void generateStoreId() {
    final storeName = storeNameController.text.trim();
    final stateName = stateController.text.trim();
    final cityName = cityController.text.trim();

    final stateCode = StateCityDataProvider.getStateCode(stateName);
    final cityCode = StateCityDataProvider.getCityCode(stateName, cityName);

    if (storeName.isEmpty || stateCode.isEmpty || cityCode.isEmpty) {
      generatedStoreId = "Invalid - Complete Address Required";
    } else {
      final sequentialNumber = NumberFormat("00000").format(_storeCounter);
      generatedStoreId = "C-$stateCode-$cityCode-$sequentialNumber";
      _storeCounter++;
    }

    notifyListeners();
  }

  Future<void> registerVendor(BuildContext context) async {
    try {
      print("Register Vendor method called");

      final vendor = Vendor(
        generatedId: generatedStoreId,
        vendorRole: 3,
        phoneNumber: contactNumberController.text,
        email: emailController.text,
      );

      // Create the medical store object without the URLs for registration, compliance, and photos
      final medicalStore = VendorMedicalStoreProfile(
        vendorId: null, // Initially null, will be updated after registration
        name: storeNameController.text,
        address: addressController.text,
        landmark: landmarkController.text,
        state: stateController.text,
        city: cityController.text,
        pincode: pincodeController.text,
        contactNumber: contactNumberController.text,
        emailId: emailController.text,
        ownerName: ownerNameController.text,
        licenseNumber: licenseNumberController.text,
        gstNumber: gstNumberController.text,
        panNumber: panNumberController.text,
        storeTiming: storeTimingController.text,
        storeDays: storeDaysController.text,
        floor: floorController.text,
        medicineType: medicineType.value ?? "",
        isRareMedicationsAvailable: isRareMedicationsAvailable.value,
        isOnlinePayment: isOnlinePayment.value,
        isLiftAccess: isLiftAccess.value,
        isWheelchairAccess: isWheelchairAccess.value,
        isParkingAvailable: isParkingAvailable.value,
        location: getLocation.value!,
        availableMedicines: [specialMedicationsController.text],
        registrationCertificates: [], // Initially empty
        complianceCertificates: [],  // Initially empty
        photos: [],  // Initially empty
      );

      // Send the data to the backend
      print("Sending data to server...");
      final response = await _vendorService.registerVendor(
        vendor: vendor,
        medicalStore: medicalStore,
      );

      // Log the server response
      print("Response from server: ${response.statusCode}, ${response.data}");

      // Handle the response
      if (response.statusCode == 200 || response.statusCode == 201) {
        // Extract vendorId from the server response
        final vendorId = response.data['vendor']['vendorId'];
        print("Extracted vendorId: $vendorId");

        // Update the medical store object with the vendorId
        final updatedMedicalStore = VendorMedicalStoreProfile(
          vendorId: vendorId, // Set the vendorId
          name: storeNameController.text,
          address: addressController.text,
          landmark: landmarkController.text,
          state: stateController.text,
          city: cityController.text,
          pincode: pincodeController.text,
          contactNumber: contactNumberController.text,
          emailId: emailController.text,
          ownerName: ownerNameController.text,
          licenseNumber: licenseNumberController.text,
          gstNumber: gstNumberController.text,
          panNumber: panNumberController.text,
          storeTiming: storeTimingController.text,
          storeDays: storeDaysController.text,
          floor: floorController.text,
          medicineType: medicineType.value ?? "",
          isRareMedicationsAvailable: isRareMedicationsAvailable.value,
          isOnlinePayment: isOnlinePayment.value,
          isLiftAccess: isLiftAccess.value,
          isWheelchairAccess: isWheelchairAccess.value,
          isParkingAvailable: isParkingAvailable.value,
          location: getLocation.value!,
          availableMedicines: [specialMedicationsController.text],
          registrationCertificates: [], // Initially empty
          complianceCertificates: [],  // Initially empty
          photos: [],  // Initially empty
        );

        // Only upload files if the server response is successful
        List<String> registrationCertificateUrls = [];
        for (var cert in registrationCertificates) {
          var file = cert['file'] as File;
          var name = cert['name'] as String;
          print("Uploading registration certificate...");

          try {
            String? url = await MedicalStoreFileUploadService().uploadFileWithMetadata(file, name);
            if (url != null) {
              registrationCertificateUrls.add(url);
              print("Registration certificate uploaded successfully: $url");
            } else {
              print("Failed to upload registration certificate: $cert");
            }
          } catch (uploadError) {
            print("Error uploading registration certificate: $uploadError");
          }
        }

        List<String> complianceCertificateUrls = [];
        for (var cert in complianceCertificates) {
          var file = cert['file'] as File;
          var name = cert['name'] as String;
          print("Uploading compliance certificate...");

          try {
            String? url = await MedicalStoreFileUploadService().uploadFileWithMetadata(file, name);
            if (url != null) {
              complianceCertificateUrls.add(url);
              print("Compliance certificate uploaded successfully: $url");
            } else {
              print("Failed to upload compliance certificate: $cert");
            }
          } catch (uploadError) {
            print("Error uploading compliance certificate: $uploadError");
          }
        }

        List<String> photoUrls = [];
        for (var photo in storePhotos) {
          var file = photo['file'] as File;
          var name = photo['name'] as String;
          print("Uploading store photo...");

          try {
            String? url = await MedicalStoreFileUploadService().uploadFileWithMetadata(file, name);
            if (url != null) {
              photoUrls.add(url);
              print("Store photo uploaded successfully: $url");
            } else {
              print("Failed to upload store photo: $photo");
            }
          } catch (uploadError) {
            print("Error uploading store photo: $uploadError");
          }
        }

        // Update the medical store object with the URLs for registration, compliance, and photos
        final updatedMedicalStoreWithUrls = VendorMedicalStoreProfile(
          vendorId: vendorId, // Use the same vendorId
          name: storeNameController.text,
          address: addressController.text,
          landmark: landmarkController.text,
          state: stateController.text,
          city: cityController.text,
          pincode: pincodeController.text,
          contactNumber: contactNumberController.text,
          emailId: emailController.text,
          ownerName: ownerNameController.text,
          licenseNumber: licenseNumberController.text,
          gstNumber: gstNumberController.text,
          panNumber: panNumberController.text,
          storeTiming: storeTimingController.text,
          storeDays: storeDaysController.text,
          floor: floorController.text,
          medicineType: medicineType.value ?? "",
          isRareMedicationsAvailable: isRareMedicationsAvailable.value,
          isOnlinePayment: isOnlinePayment.value,
          isLiftAccess: isLiftAccess.value,
          isWheelchairAccess: isWheelchairAccess.value,
          isParkingAvailable: isParkingAvailable.value,
          location: getLocation.value!
          ,
          availableMedicines: [specialMedicationsController.text],
          registrationCertificates: registrationCertificateUrls,
          complianceCertificates: complianceCertificateUrls,
          photos: photoUrls,
        );

        // Send the updated medical store object to the backend
        final updateResponse = await _vendorService.updateMedicalStore(
          medicalStore: updatedMedicalStoreWithUrls,
        );

        if (updateResponse.statusCode == 200) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text("Vendor registered and files uploaded successfully"),
              backgroundColor: Colors.green,
            ),
          );
        } else {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text("Failed to update medical store with file URLs: ${updateResponse.data}"),
              backgroundColor: Colors.red,
            ),
          );
        }
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text("Failed to register vendor: ${response.data}"),
            backgroundColor: Colors.red,
          ),
        );
      }
    } catch (e) {
      print("Error during registration: $e");
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text("Error during registration: $e"),
          backgroundColor: Colors.red,
        ),
      );
    }
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

