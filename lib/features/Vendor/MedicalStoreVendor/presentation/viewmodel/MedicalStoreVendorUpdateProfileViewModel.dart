import 'dart:io';
import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'package:vedika_healthcare/features/Vendor/MedicalStoreVendor/data/services/MedicalStoreFileUploadService.dart';
import 'package:vedika_healthcare/features/Vendor/Registration/MedicalRegistration/Service/MedicalStoreVendorService.dart';
import 'package:vedika_healthcare/features/Vendor/Registration/Models/VendorMedicalStoreProfile.dart';
import 'package:vedika_healthcare/features/Vendor/Registration/Services/VendorLoginService.dart';

class MedicalStoreVendorUpdateProfileViewModel extends ChangeNotifier {
  final MedicalStoreVendorService _service = MedicalStoreVendorService();
  final VendorLoginService _loginService = VendorLoginService(); // Vendor Login Service

  // Store Information Fields
  String storeId = '';
  String storeName = '';
  String ownerName = '';
  String gstNumber = '';
  String panNumber = '';
  String medicineType = 'Alopathy'; // Default value
  bool isRareMedicationsAvailable = false;
  bool isOnlinePayment = false;
  String address = '';
  String nearbyLandmark = '';
  String storeTiming = '';
  String storeOpenDays = '';
  String contactNumber = '';
  String emailId = '';
  String website = '';
  String floor = '';
  bool isLiftAccess = false;
  bool isWheelchairAccess = false;
  bool isParkingAvailable = false;
  String location = '';
  String state = '';
  String city = '';
  String pincode = '';
  String licenseNumber = '';
  List<String> specialMedications = [];
  List<String> paymentOptions = [];
  bool isEditMode = false;

  // **File Upload Data (Storing file paths temporarily as Strings)**
  List<Map<String, Object>> registrationCertificates = []; // { dt: "filename", file: File }
  List<Map<String, Object>> complianceCertificates = [];
  List<Map<String, Object>> photos = [];

  // **Final Lists to hold Strings only**
  List<String> registrationCertificatesList = [];  // Changed to List<String>
  List<String> complianceCertificatesList = [];  // Changed to List<String>
  List<String> photosList = [];  // Changed to List<String>

  // Loading and Error Handling
  bool _isLoading = false;
  String? _errorMessage;

  bool get isLoading => _isLoading;
  String? get errorMessage => _errorMessage;

  // **Toggle Edit Mode**
  void toggleEditMode(bool value) {
    isEditMode = value;
    notifyListeners();
  }

  // **Convert current profile data into VendorMedicalStoreProfile**
  VendorMedicalStoreProfile toVendorMedicalStoreProfile() {
    return VendorMedicalStoreProfile(
      vendorId: storeId.isNotEmpty ? storeId : null,
      name: storeName,
      address: address,
      landmark: nearbyLandmark,
      state: state,
      city: city,
      pincode: pincode,
      contactNumber: contactNumber,
      emailId: emailId,
      ownerName: ownerName,
      licenseNumber: licenseNumber,
      gstNumber: gstNumber,
      panNumber: panNumber,
      storeTiming: storeTiming,
      storeDays: storeOpenDays,
      floor: floor,
      medicineType: medicineType,
      isRareMedicationsAvailable: isRareMedicationsAvailable,
      isOnlinePayment: isOnlinePayment,
      isLiftAccess: isLiftAccess,
      isWheelchairAccess: isWheelchairAccess,
      isParkingAvailable: isParkingAvailable,
      location: location,
      availableMedicines: specialMedications,
      registrationCertificates: registrationCertificatesList,
      complianceCertificates: complianceCertificatesList,
      photos: photosList,
    );
  }

  // **Upload Methods**
  void uploadComplianceCertificates(List<Map<String, Object>> files) {
    if (files.isNotEmpty) {
      complianceCertificates.addAll(files);
      complianceCertificatesList.addAll(files.map((e) => e['name'] as String)); // Add only file names/URLs
      notifyListeners();
    }
  }

  void uploadRegistrationCertificates(List<Map<String, Object>> files) {
    if (files.isNotEmpty) {
      registrationCertificates.addAll(files);
      registrationCertificatesList.addAll(files.map((e) => e['name'] as String)); // Add only file names/URLs
      notifyListeners();
    }
  }

  Future<void> uploadPhotos() async {
    FilePickerResult? result = await FilePicker.platform.pickFiles(
      type: FileType.custom,
      allowedExtensions: ['pdf', 'png', 'jpg', 'jpeg'],
      allowMultiple: true,
    );

    if (result != null) {
      photos.addAll(result.files.map((file) => {"name": file.name, "file": File(file.path!)}));
      photosList.addAll(result.files.map((file) => file.name)); // Add only file names/URLs
      notifyListeners();
    }
  }

  Future<Map<String, Object>?> pickFile() async {
    FilePickerResult? result = await FilePicker.platform.pickFiles(
      type: FileType.custom,
      allowedExtensions: ['pdf', 'png', 'jpg', 'jpeg'],
    );
    return result != null ? {"name": result.files.single.name, "file": File(result.files.single.path!)} : null;
  }

  Future<void> updateStoreProfile(BuildContext context) async {
    if (_isLoading) return; // Prevent multiple calls
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    try {
      // Convert ViewModel data into a VendorMedicalStoreProfile
      VendorMedicalStoreProfile profile = toVendorMedicalStoreProfile();

      // Flatten the existing URLs if they are in nested lists and add them to a new list
      List<String> registrationCertificateUrls = _flattenUrls(profile.registrationCertificates);
      List<String> complianceCertificateUrls = _flattenUrls(profile.complianceCertificates);
      List<String> photoUrls = _flattenUrls(profile.photos);

      // Upload the new registration certificates and append their URLs
      for (var cert in registrationCertificates) {
        var file = cert['file'] as File;
        var name = cert['name'] as String;
        try {
          String? url = await MedicalStoreFileUploadService().uploadFileWithMetadata(file, name);
          if (url != null && !registrationCertificateUrls.contains(url)) {
            registrationCertificateUrls.add(url); // Append URL to the list if not already present
          }
        } catch (uploadError) {
          print("Error uploading registration certificate: $uploadError");
        }
      }

      // Upload the new compliance certificates and append their URLs
      for (var cert in complianceCertificates) {
        var file = cert['file'] as File;
        var name = cert['name'] as String;
        try {
          String? url = await MedicalStoreFileUploadService().uploadFileWithMetadata(file, name);
          if (url != null && !complianceCertificateUrls.contains(url)) {
            complianceCertificateUrls.add(url); // Append URL to the list if not already present
          }
        } catch (uploadError) {
          print("Error uploading compliance certificate: $uploadError");
        }
      }

      // Upload the new photos and append their URLs
      for (var photo in photos) {
        var file = photo['file'] as File;
        var name = photo['name'] as String;
        try {
          String? url = await MedicalStoreFileUploadService().uploadFileWithMetadata(file, name);
          if (url != null && !photoUrls.contains(url)) {
            photoUrls.add(url); // Append URL to the list if not already present
          }
        } catch (uploadError) {
          print("Error uploading photo: $uploadError");
        }
      }

      // Print the updated URLs lists for debug
      print("Updated Registration Certificates: $registrationCertificateUrls");
      print("Updated Compliance Certificates: $complianceCertificateUrls");
      print("Updated Photos: $photoUrls");

      // Update the profile with the new list of URLs
      profile.registrationCertificates = registrationCertificateUrls;
      profile.complianceCertificates = complianceCertificateUrls;
      profile.photos = photoUrls;

      // Call the updateMedicalStore service method
      final response = await _service.updateMedicalStore(medicalStore: profile);

      // Check if the update was successful (response status code can be checked)
      if (response.statusCode == 200) {
        print("✅ Store Profile updated successfully");
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(
          content: Text("Vendor profile updated successfully"),
          backgroundColor: Colors.green,
        ));
      } else {
        _errorMessage = "Failed to update the profile";
        print("❌ Error: $_errorMessage");
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(
          content: Text("Failed to update the profile: $_errorMessage"),
          backgroundColor: Colors.red,
        ));
      }
    } catch (e, stackTrace) {
      _errorMessage = "Error: ${e.toString()}";
      print("❌ Exception: $_errorMessage");
      print(stackTrace); // Print stack trace for debugging
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(
        content: Text("Error during profile update: $_errorMessage"),
        backgroundColor: Colors.red,
      ));
    }

    _isLoading = false;
    notifyListeners();
  }

// Helper function to flatten the list of URLs
  List<String> _flattenUrls(List<dynamic> urlList) {
    List<String> flattenedUrls = [];

    for (var item in urlList) {
      if (item is String) {
        flattenedUrls.add(item); // If it's a direct URL, add it
      } else if (item is List) {
        flattenedUrls.addAll(item.cast<String>()); // If it's a nested list, add the URLs inside
      }
    }

    return flattenedUrls;
  }




  // **Fetch Profile Data**
  Future<void> fetchProfileData() async {
    if (_isLoading) return; // Prevent multiple calls
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    try {
      // Simulating fetching JWT Token from storage
      String? token = await _loginService.getVendorToken();

      if (token == null) {
        _errorMessage = "Vendor Token not found";
        print("❌ Error: $_errorMessage");  // 🔹 Print error
      } else {
        // Simulate a service to fetch vendor profile
        VendorMedicalStoreProfile? profile = await _service.fetchVendorProfile(token);

        if (profile == null) {
          _errorMessage = "Vendor Profile is null after fetching";
          print("❌ Error: $_errorMessage");
        } else {
          _setProfileData(profile);  // Set the profile data into ViewModel
          print("✅ Vendor Profile Fetched Successfully: $profile");
        }
      }
    } catch (error, stackTrace) {
      _errorMessage = error.toString();
      print("❌ Exception in fetchProfileData: $_errorMessage");
      print(stackTrace);  // 🔹 Print stack trace for debugging
    }

    _isLoading = false;
    notifyListeners();
  }

  // Set Profile Data in ViewModel
  void _setProfileData(VendorMedicalStoreProfile profile) {
    storeId = profile.vendorId ?? '';
    storeName = profile.name;
    ownerName = profile.ownerName;
    gstNumber = profile.gstNumber;
    panNumber = profile.panNumber;
    medicineType = profile.medicineType;
    isRareMedicationsAvailable = profile.isRareMedicationsAvailable;
    isOnlinePayment = profile.isOnlinePayment;
    address = profile.address;
    nearbyLandmark = profile.landmark;
    storeTiming = profile.storeTiming;
    storeOpenDays = profile.storeDays;
    contactNumber = profile.contactNumber;
    emailId = profile.emailId;
    website = profile.emailId; // You can update accordingly if needed
    floor = profile.floor;
    isLiftAccess = profile.isLiftAccess;
    isWheelchairAccess = profile.isWheelchairAccess;
    isParkingAvailable = profile.isParkingAvailable;
    location = profile.location;
    state = profile.state;
    city = profile.city;
    pincode = profile.pincode;
    licenseNumber = profile.licenseNumber;
    specialMedications = profile.availableMedicines;

    // Convert to only file names (Strings)
    registrationCertificatesList = profile.registrationCertificates;
    complianceCertificatesList = profile.complianceCertificates;
    photosList = profile.photos;

    notifyListeners();
  }
}
