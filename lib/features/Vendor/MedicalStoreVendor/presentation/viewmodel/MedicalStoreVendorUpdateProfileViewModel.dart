import 'dart:convert';
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
      for (var file in files) {
        if (!complianceCertificates.any((e) => e['name'] == file['name'])) {
          complianceCertificates.add(file);
          complianceCertificatesList.add(file['name'] as String);
        }
      }
      notifyListeners();
    }
  }

  void uploadRegistrationCertificates(List<Map<String, Object>> files) {
    if (files.isNotEmpty) {
      for (var file in files) {
        if (!registrationCertificates.any((e) => e['name'] == file['name'])) {
          registrationCertificates.add(file);
          registrationCertificatesList.add(file['name'] as String);
        }
      }
      notifyListeners();
    }
  }


  Future<void> updateStoreProfile(BuildContext context) async {
    if (_isLoading) return; // Prevent multiple calls
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    try {
      // Convert ViewModel data into VendorMedicalStoreProfile
      VendorMedicalStoreProfile profile = toVendorMedicalStoreProfile();

      List<String> registrationCertificateUrls = _flattenUrls(profile.registrationCertificates) ?? [];
      List<String> complianceCertificateUrls = _flattenUrls(profile.complianceCertificates) ?? [];
      List<String> photoUrls = _flattenUrls(profile.photos) ?? [];

      // **TEMP VARIABLES TO STORE NEWLY UPLOADED FILES ONLY**
      List<String> newRegistrationCertificateUrls = [];
      List<String> newComplianceCertificateUrls = [];
      List<String> newPhotoUrls = [];

      // Upload new registration certificates
      for (var cert in registrationCertificates) {
        var file = cert['file'] as File;
        var name = cert['name'] as String;
        try {
          String? url = await MedicalStoreFileUploadService().uploadFileWithMetadata(file, name);
          if (url != null && !registrationCertificateUrls.contains(url)) {
            newRegistrationCertificateUrls.add(url); // Store new URLs separately
          }
        } catch (uploadError) {
          print("Error uploading registration certificate: $uploadError");
        }
      }

      // Upload new compliance certificates
      for (var cert in complianceCertificates) {
        var file = cert['file'] as File;
        var name = cert['name'] as String;
        try {
          String? url = await MedicalStoreFileUploadService().uploadFileWithMetadata(file, name);
          if (url != null && !complianceCertificateUrls.contains(url)) {
            newComplianceCertificateUrls.add(url);
          }
        } catch (uploadError) {
          print("Error uploading compliance certificate: $uploadError");
        }
      }

      // Upload new photos
      for (var photo in photos) {
        var file = photo['file'] as File;
        var name = photo['name'] as String;
        try {
          String? url = await MedicalStoreFileUploadService().uploadFileWithMetadata(file, name);
          if (url != null && !photoUrls.contains(url)) {
            newPhotoUrls.add(url);
          }
        } catch (uploadError) {
          print("Error uploading photo: $uploadError");
        }
      }

      // **ONLY ADD NEW FILES TO THE FINAL LIST**
      registrationCertificateUrls.addAll(newRegistrationCertificateUrls);
      complianceCertificateUrls.addAll(newComplianceCertificateUrls);
      photoUrls.addAll(newPhotoUrls);

      // Debugging logs
      print("✅ Final Registration Certificates: $registrationCertificateUrls");
      print("✅ Final Compliance Certificates: $complianceCertificateUrls");
      print("✅ Final Photos: $photoUrls");

      // Update profile
      profile.registrationCertificates = registrationCertificateUrls;
      profile.complianceCertificates = complianceCertificateUrls;
      profile.photos = photoUrls;

      // Send updated profile to server
      final response = await _service.updateMedicalStore(medicalStore: profile);

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
      print(stackTrace);
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(
        content: Text("Error during profile update: $_errorMessage"),
        backgroundColor: Colors.red,
      ));
    }

    _isLoading = false;
    notifyListeners();
  }


  List<String>? _flattenUrls(dynamic urlList) {
    print("🔍 URL List Before Flattening: $urlList");

    // If the list is empty or null, return null directly
    if (urlList == null || urlList.isEmpty) {
      print("⚠️ [DEBUG] URL list is empty, returning null");
      return null;
    }

    Set<String> flattenedUrls = {}; // Use Set to ensure uniqueness

    void extractUrls(dynamic item) {
      if (item is String) {
        if (item.startsWith("http")) {
          flattenedUrls.add(item.trim()); // Add valid URL
        } else {
          try {
            dynamic decoded = jsonDecode(item);
            extractUrls(decoded);
          } catch (e) {
            // Ignore non-URL values
          }
        }
      } else if (item is List) {
        for (var subItem in item) {
          extractUrls(subItem);
        }
      }
    }

    extractUrls(urlList);

    // If no valid URLs are found, return null instead of an empty list
    if (flattenedUrls.isEmpty) {
      print("⚠️ [DEBUG] No valid URLs found, returning null");
      return null;
    }

    List<String> finalList = flattenedUrls.where((url) => url.isNotEmpty).toList();
    print("✅ Flattened URL List (Only URLs): $finalList");
    return finalList;
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

  Future<void> deleteRegistrationCertificate(String fileUrl) async {
    try {
      bool success = await MedicalStoreFileUploadService().deleteFile(fileUrl);
      if (success) {
        // Fetch the latest list from the database
        List<String> updatedUrls = await _fetchUpdatedUrlsFromDB("registrationCertificates");

        // Remove the deleted file from the list
        updatedUrls.removeWhere((url) => url == fileUrl);

        // Update the database with the new list
        await _updateUrlsInDB("registrationCertificates", updatedUrls);

        // Update the ViewModel
        registrationCertificatesList = updatedUrls;
        notifyListeners();

        print("✅ Successfully deleted file from Firebase and updated DB.");
      } else {
        print("❌ Failed to delete file from Firebase.");
      }
    } catch (e) {
      print("❌ Error deleting registration certificate: $e");
    }
  }

  Future<void> deleteComplianceCertificate(String fileUrl) async {
    try {
      bool success = await MedicalStoreFileUploadService().deleteFile(fileUrl);
      if (success) {
        // Fetch the latest list from the database
        List<String> updatedUrls = await _fetchUpdatedUrlsFromDB("complianceCertificates");

        // Ensure the deleted file is removed from the list
        updatedUrls.removeWhere((url) => url == fileUrl);

        print("✅ Updated list after deletion: $updatedUrls");

        // Update the database with the new filtered list
        await _updateUrlsInDB("complianceCertificates", updatedUrls);

        // Update the ViewModel
        complianceCertificatesList = updatedUrls;
        notifyListeners();

        print("✅ Successfully deleted file from Firebase and updated DB.");
      } else {
        print("❌ Failed to delete file from Firebase.");
      }
    } catch (e) {
      print("❌ Error deleting compliance certificate: $e");
    }
  }

  Future<void> _updateUrlsInDB(String column, List<String> updatedUrls) async {
    try {
      print("🔍 [DEBUG] Updating $column in DB...");
      print("📝 [DEBUG] Raw updated URLs before processing: $updatedUrls");

      // Fetch the existing profile
      VendorMedicalStoreProfile profile = toVendorMedicalStoreProfile();

      // Ensure the list is properly formatted and remove empty items
      List<String> finalUrls = _flattenUrlsForDeletion(updatedUrls) ?? [];

      print("✅ [DEBUG] Flattened URLs (before filtering deleted file): $finalUrls");

      // Ensure we are not adding any deleted files back
      finalUrls = finalUrls.toSet().toList(); // Remove duplicates, if any

      print("✅ [DEBUG] Final filtered URLs: $finalUrls");

      // If there are no URLs left, store `null` or an empty list to avoid JSON issues
      if (finalUrls.isEmpty) {
        finalUrls = []; // You can also set it to null if necessary
      }

      // Update the relevant field in the profile
      switch (column) {
        case "registrationCertificates":
          profile.registrationCertificates = finalUrls;
          break;
        case "complianceCertificates":
          profile.complianceCertificates = finalUrls;
          break;
        default:
          print("⚠️ [DEBUG] Invalid column name: $column");
          return;
      }

      // Debug before updating
      print("📌 [DEBUG] Updated profile before sending to DB: ${profile.toJson()}");

      // Send updated profile to the server
      await _service.updateMedicalStore(medicalStore: profile);

      print("✅ Successfully updated $column in DB: $finalUrls");
    } catch (e, stackTrace) {
      print("❌ Error updating URLs in DB: $e");
      print("🛑 StackTrace: $stackTrace");
    }
  }

  List<String> _flattenUrlsForDeletion(List<dynamic>? urlList) {
    if (urlList == null) return [];

    print("🔍 Before flattening: $urlList");

    // Ensure we only keep valid strings
    List<String> flattenedList = urlList
        .expand((e) => e is List<dynamic> ? e.whereType<String>() : (e is String ? [e] : <String>[]))
        .toList();

    print("✅ After flattening: $flattenedList");

    return flattenedList;
  }





  Future<List<String>> _fetchUpdatedUrlsFromDB(String column) async {
    try {
      String? token = await _loginService.getVendorToken();

      VendorMedicalStoreProfile? profile = await _service.fetchVendorProfile(token!);
      if (profile == null) return [];

      switch (column) {
        case "registrationCertificates":
          return List<String>.from(profile.registrationCertificates);
        case "complianceCertificates":
          return List<String>.from(profile.complianceCertificates);
        default:
          return [];
      }
    } catch (e) {
      print("❌ Error fetching URLs from DB: $e");
      return [];
    }
  }



  /// Function to extract file name from a Firebase URL (Handles JSON arrays too)
  String extractFileName(String url) {
    try {
      // Check if `url` is a JSON-encoded list
      if (url.trim().startsWith("[")) {
        List<dynamic> decodedList = jsonDecode(url); // Decode JSON string
        if (decodedList.isNotEmpty && decodedList.first is String) {
          url = decodedList.first; // Use the first valid URL from the list
        } else {
          throw FormatException("Empty or invalid URL list");
        }
      }

      Uri uri = Uri.parse(url);
      String path = uri.pathSegments.last;
      return Uri.decodeComponent(path.split('%2F').last.split('?').first);
    } catch (e) {
      print("❌ Error extracting file name: $e (Input: $url)");
      return "Unknown File";
    }
  }
}
