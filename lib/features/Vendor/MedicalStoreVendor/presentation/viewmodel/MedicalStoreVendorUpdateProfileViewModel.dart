import 'dart:io';
import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';

class MedicalStoreVendorUpdateProfileViewModel extends ChangeNotifier {
  // Store Information Fields
  String storeName = '';
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
  String floor = '';
  bool isLiftAccess = false;
  bool isWheelchairAccess = false;
  bool isParkingAvailable = false;
  String location = '';
  bool isEditMode = false;

  // **File Upload Data**
  List<Map<String, Object>> registrationCertificates = []; // { dt: "filename", file: File }
  List<Map<String, Object>> complianceCertificates = [];
  List<Map<String, Object>> photos = [];

  // **Toggle Edit Mode**
  void toggleEditMode(bool value) {
    isEditMode = value;
    notifyListeners();
  }

  // **Set Profile Data for Editing**
  void setProfileData({
    required String storeName,
    required String gstNumber,
    required String panNumber,
    required List<Map<String, Object>> registrationCertificates,
    required List<Map<String, Object>> complianceCertificates,
    required String medicineType,
    required bool isRareMedicationsAvailable,
    required bool isOnlinePayment,
    required String address,
    required String nearbyLandmark,
    required String storeTiming,
    required String storeOpenDays,
    required String contactNumber,
    required String emailId,
    required String floor,
    required bool isLiftAccess,
    required bool isWheelchairAccess,
    required bool isParkingAvailable,
    required List<Map<String, Object>> photos,
    required String location,
  }) {
    this.storeName = storeName;
    this.gstNumber = gstNumber;
    this.panNumber = panNumber;
    this.registrationCertificates = registrationCertificates;
    this.complianceCertificates = complianceCertificates;
    this.medicineType = medicineType;
    this.isRareMedicationsAvailable = isRareMedicationsAvailable;
    this.isOnlinePayment = isOnlinePayment;
    this.address = address;
    this.nearbyLandmark = nearbyLandmark;
    this.storeTiming = storeTiming;
    this.storeOpenDays = storeOpenDays;
    this.contactNumber = contactNumber;
    this.emailId = emailId;
    this.floor = floor;
    this.isLiftAccess = isLiftAccess;
    this.isWheelchairAccess = isWheelchairAccess;
    this.isParkingAvailable = isParkingAvailable;
    this.photos = photos;
    this.location = location;
    notifyListeners();
  }

  // **Save Profile Data**
  void saveProfile() {
    print("✅ Profile Saved!");
    print("📌 Store Name: $storeName");
    print("📌 GST Number: $gstNumber");
    print("📌 PAN Number: $panNumber");
    print("📌 Medicine Type: $medicineType");
    print("📌 Rare Medications Available: $isRareMedicationsAvailable");
    print("📌 Online Payment: $isOnlinePayment");
    print("📌 Address: $address");
    print("📌 Nearby Landmark: $nearbyLandmark");
    print("📌 Store Timing: $storeTiming");
    print("📌 Store Open Days: $storeOpenDays");
    print("📌 Contact Number: $contactNumber");
    print("📌 Email ID: $emailId");
    print("📌 Floor: $floor");
    print("📌 Lift Access: $isLiftAccess");
    print("📌 Wheelchair Access: $isWheelchairAccess");
    print("📌 Parking Available: $isParkingAvailable");
    print("📌 Location: $location");
    print("📌 Registration Certificates: ");
    registrationCertificates.forEach((fileData) {
      String fileName = fileData['name'] as String;
      File file = fileData['file'] as File;
      print("Name: $fileName, Path: ${file.path}");
    });

    print("📌 Compliance Certificates: ");
    complianceCertificates.forEach((fileData) {
      String fileName = fileData['name'] as String;
      File file = fileData['file'] as File;
      print("Name: $fileName, Path: ${file.path}");
    });

    print("📌 Uploaded Photos: ");
    photos.forEach((fileData) {
      String fileName = fileData['name'] as String;
      File file = fileData['file'] as File;
      print("Name: $fileName, Path: ${file.path}");
    });

    notifyListeners();
  }

  // **Upload Compliance Certificates**
  void uploadComplianceCertificates(List<Map<String, Object>> files) {
    if (files.isNotEmpty) {
      complianceCertificates.addAll(files); // Store the new files

      print("✅ Compliance Certificates Uploaded: ${complianceCertificates.map((file) => file['dt']).toList()}");
      notifyListeners();
    }
  }

  // **Upload Registration Certificates**
  void uploadRegistrationCertificates(List<Map<String, Object>> files) {
    if (files.isNotEmpty) {
      registrationCertificates.addAll(files); // Store the new files

      print("✅ Registration Certificates Uploaded: ${registrationCertificates.map((file) => file['dt']).toList()}");
      notifyListeners();
    }
  }

  // **Upload Photos**
  Future<void> uploadPhotos() async {
    FilePickerResult? result = await FilePicker.platform.pickFiles(
      type: FileType.custom,
      allowedExtensions: ['pdf', 'png', 'jpg', 'jpeg'],
      allowMultiple: true,
    );

    if (result != null) {
      photos.addAll(result.files.map((file) => {
        "dt": file.name,
        "file": File(file.path!)
      }));

      print("✅ Photos Uploaded: ${photos.map((file) => file['dt']).toList()}");
      notifyListeners();
    }
  }

  // **Pick a Single File**
  Future<Map<String, Object>?> pickFile() async {
    FilePickerResult? result = await FilePicker.platform.pickFiles(
      type: FileType.custom,
      allowedExtensions: ['pdf', 'png', 'jpg', 'jpeg'],
    );

    return result != null
        ? {"dt": result.files.single.name, "file": File(result.files.single.path!)}
        : null;
  }
}
