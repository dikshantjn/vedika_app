import 'dart:io';

import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:vedika_healthcare/features/Vendor/AmbulanceAgencyVendor/data/modals/AmbulanceAgency.dart';
import 'package:vedika_healthcare/features/Vendor/AmbulanceAgencyVendor/data/services/AmbulanceAgencyService.dart';
import 'package:vedika_healthcare/features/Vendor/AmbulanceAgencyVendor/data/services/AmbulanceAgencyStorageService.dart';
import 'package:vedika_healthcare/features/Vendor/Registration/Services/VendorLoginService.dart';

class EditAgencyProfileViewModel extends ChangeNotifier {
  // Form keys for different sections
  final formKey = GlobalKey<FormState>();
  final basicInfoKey = GlobalKey<FormState>();
  final operationalInfoKey = GlobalKey<FormState>();
  final mediaLocationKey = GlobalKey<FormState>();

  final VendorLoginService _loginService = VendorLoginService();
  final AmbulanceAgencyService _service = AmbulanceAgencyService();
  final AmbulanceAgencyStorageService _storageService = AmbulanceAgencyStorageService();

  AmbulanceAgency? _agency;

  // Controllers for Text Fields
  final agencyNameController = TextEditingController();
  final gstNumberController = TextEditingController();
  final panNumberController = TextEditingController();
  final ownerNameController = TextEditingController();
  final registrationNumberController = TextEditingController();
  final contactNumberController = TextEditingController();
  final emailController = TextEditingController();
  final websiteController = TextEditingController();
  final addressController = TextEditingController();
  final cityController = TextEditingController();
  final stateController = TextEditingController();
  final pinCodeController = TextEditingController();
  final landmarkController = TextEditingController();
  final driverLicenseController = TextEditingController();
  final preciseLocationController = TextEditingController();
  final distanceLimitController = TextEditingController();
  final numOfAmbulancesController = TextEditingController();

  // Booleans
  bool _driverKYC = false;
  bool _driverTrained = false;
  bool _gpsTrackingAvailable = false;
  bool _is24x7Available = false;
  bool _isOnlinePaymentAvailable = false;
  bool _isLive = false;
  bool _isLoading = true;
  String? _error;

  // Lists
  List<String> _ambulanceTypes = [];
  List<String> _ambulanceEquipment = [];
  List<String> _languageProficiency = [];
  List<String> _operationalAreas = [];

  // Media
  List<Map<String, String>> trainingCertifications = [];
  List<Map<String, String>> officePhotos = [];

  // ======= GETTERS =======
  bool get driverKYC => _driverKYC;
  bool get driverTrained => _driverTrained;
  bool get gpsTrackingAvailable => _gpsTrackingAvailable;
  bool get is24x7Available => _is24x7Available;
  bool get isOnlinePaymentAvailable => _isOnlinePaymentAvailable;
  bool get isLive => _isLive;
  String? get error => _error;

  List<String> get ambulanceTypes => _ambulanceTypes;
  List<String> get ambulanceEquipment => _ambulanceEquipment;
  List<String> get languageProficiency => _languageProficiency;
  List<String> get operationalAreas => _operationalAreas;
  bool get isLoading => _isLoading;

  // ======= SETTERS =======

  void setLoading(bool loading) {
    _isLoading = loading;
    notifyListeners();  // Notify listeners to update UI
  }
  void setDriverKYC(bool value) {
    _driverKYC = value;
    notifyListeners();
  }

  void setDriverTrained(bool value) {
    _driverTrained = value;
    notifyListeners();
  }

  void setGpsTrackingAvailable(bool value) {
    _gpsTrackingAvailable = value;
    notifyListeners();
  }

  void setIs24x7Available(bool value) {
    _is24x7Available = value;
    notifyListeners();
  }

  void setIsOnlinePaymentAvailable(bool value) {
    _isOnlinePaymentAvailable = value;
    notifyListeners();
  }

  void toggleIsLive(bool value) {
    _isLive = value;
    notifyListeners();
  }

  void setAmbulanceTypes(List<String> types) {
    _ambulanceTypes = types;
    notifyListeners();
  }

  void setAmbulanceEquipment(List<String> equipment) {
    _ambulanceEquipment = equipment;
    notifyListeners();
  }

  void setLanguageProficiency(List<String> languages) {
    _languageProficiency = languages;
    notifyListeners();
  }

  void setOperationalAreas(List<String> areas) {
    _operationalAreas = areas;
    notifyListeners();
  }

  // ======= FORM LOGIC =======
  bool validateAndSave() {
    final isValid = formKey.currentState?.validate() ?? false;
    if (isValid) formKey.currentState?.save();
    return isValid;
  }

  void updateAgencyProfile() async {
    if (!validateAndSave()) return;
    String? vendorId = await _loginService.getVendorId();


    // Set loading state to true before starting the update
    setLoading(true);

    // Collecting all the updated data
    print("Profile Updated:");

    final updatedAgency = AmbulanceAgency(
      distanceLimit: double.tryParse(distanceLimitController.text) ?? 0.0, // Ensure distance is a double
      agencyName: agencyNameController.text,
      gstNumber: gstNumberController.text,
      panNumber: panNumberController.text,
      ownerName: ownerNameController.text,
      registrationNumber: registrationNumberController.text,
      contactNumber: contactNumberController.text,
      email: emailController.text,
      website: websiteController.text,
      address: addressController.text,
      city: cityController.text,
      state: stateController.text,
      pinCode: pinCodeController.text,
      landmark: landmarkController.text,
      driverLicense: driverLicenseController.text,
      preciseLocation: preciseLocationController.text,
      numOfAmbulances: int.parse(numOfAmbulancesController.text),
      driverKYC: _driverKYC,
      driverTrained: _driverTrained,
      gpsTrackingAvailable: _gpsTrackingAvailable,
      is24x7Available: _is24x7Available,
      isOnlinePaymentAvailable: _isOnlinePaymentAvailable,
      isLive: _isLive,
      ambulanceTypes: _ambulanceTypes,
      ambulanceEquipment: _ambulanceEquipment,
      languageProficiency: _languageProficiency,
      operationalAreas: _operationalAreas,
      generatedId: "",
      officePhotos: [],
      trainingCertifications: [],
      vendorId: "",
    );

    try {
      // Call the service method to update the profile
      await AmbulanceAgencyService().updateAgencyProfile(
        vendorId: vendorId!, // Vendor ID, replace with dynamic value
        updatedAgency: updatedAgency,
      );
      // Show success toast
      Fluttertoast.showToast(
        msg: "Agency profile updated successfully!",
        toastLength: Toast.LENGTH_SHORT,
        gravity: ToastGravity.TOP,
        backgroundColor: Colors.green,
        textColor: Colors.white,
        fontSize: 16.0,
      );
      print("✅ Agency profile updated successfully!");
    } catch (e) {
      // Show error toast
      Fluttertoast.showToast(
        msg: "Failed to update agency profile: ${e.toString()}",
        toastLength: Toast.LENGTH_SHORT,
        gravity: ToastGravity.TOP,
        backgroundColor: Colors.red,
        textColor: Colors.white,
        fontSize: 16.0,
      );
      print("❌ Failed to update agency profile: $e");
    } finally {
      // Set loading state to false after the update is done
      setLoading(false);
    }
  }




  Future<void> fetchAgencyProfileData() async {
    String? vendorId = await _loginService.getVendorId();
    _isLoading = true;
    notifyListeners();

    try {
      final fetchedAgency = await _service.getAgencyProfile(vendorId!);
      _agency = fetchedAgency;
      _error = null;

      // Populate controllers with fetched data
      agencyNameController.text = _agency?.agencyName ?? '';
      gstNumberController.text = _agency?.gstNumber ?? '';
      panNumberController.text = _agency?.panNumber ?? '';
      ownerNameController.text = _agency?.ownerName ?? '';
      registrationNumberController.text = _agency?.registrationNumber ?? '';
      contactNumberController.text = _agency?.contactNumber ?? '';
      emailController.text = _agency?.email ?? '';
      websiteController.text = _agency?.website ?? '';
      addressController.text = _agency?.address ?? '';
      cityController.text = _agency?.city ?? '';
      stateController.text = _agency?.state ?? '';
      pinCodeController.text = _agency?.pinCode ?? '';
      landmarkController.text = _agency?.landmark ?? '';
      driverLicenseController.text = _agency?.driverLicense ?? '';
      preciseLocationController.text = _agency?.preciseLocation ?? '';
      numOfAmbulancesController.text = _agency?.numOfAmbulances.toString() ?? '';

      // Booleans
      _driverKYC = _agency?.driverKYC ?? false;
      _driverTrained = _agency?.driverTrained ?? false;
      _gpsTrackingAvailable = _agency?.gpsTrackingAvailable ?? false;
      _is24x7Available = _agency?.is24x7Available ?? false;
      _isOnlinePaymentAvailable = _agency?.isOnlinePaymentAvailable ?? false;
      _isLive = _agency?.isLive ?? false;

      // Lists
      _ambulanceTypes = List<String>.from(_agency?.ambulanceTypes ?? []);
      _ambulanceEquipment = List<String>.from(_agency?.ambulanceEquipment ?? []);
      _languageProficiency = List<String>.from(_agency?.languageProficiency ?? []);
      _operationalAreas = List<String>.from(_agency?.operationalAreas ?? []);

      // Media
      trainingCertifications = List<Map<String, String>>.from(_agency?.trainingCertifications ?? []);
      officePhotos = List<Map<String, String>>.from(_agency?.officePhotos ?? []);
    } catch (e) {
      _error = e.toString();
      _agency = null;
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }



  void disposeControllers() {
    agencyNameController.dispose();
    gstNumberController.dispose();
    panNumberController.dispose();
    ownerNameController.dispose();
    registrationNumberController.dispose();
    contactNumberController.dispose();
    emailController.dispose();
    websiteController.dispose();
    addressController.dispose();
    cityController.dispose();
    stateController.dispose();
    pinCodeController.dispose();
    landmarkController.dispose();
    driverLicenseController.dispose();
    preciseLocationController.dispose();
    distanceLimitController.dispose();
    numOfAmbulancesController.dispose();
  }

  // ======= Dropdown/Chip Options (for UI) =======
  List<String> get ambulanceTypeOptions => ['Basic', 'Advanced', 'ICU', 'Neonatal'];
  List<String> get equipmentOptions => ['Stretcher', 'Oxygen', 'Defibrillator', 'Suction'];
  List<String> get languageOptions => ['English', 'Hindi', 'Marathi', 'Gujarati'];
  List<String> get operationalAreaOptions => ['Pune', 'Mumbai', 'Nashik', 'Nagpur'];


  Future<void> replaceFile({
    required String oldName,
    required String newName,
    required File file,
    required String fileType, // 'trainingCertifications' or 'officePhotos'
  }) async {
    String? vendorId = await _loginService.getVendorId();

    List<Map<String, String>> targetList =
    fileType == 'trainingCertifications' ? trainingCertifications : officePhotos;

    print('[replaceFile] Starting replacement: "$oldName" → "$newName"');

    final oldItemIndex = targetList.indexWhere((item) => item['name'] == oldName);
    if (oldItemIndex != -1) {
      final oldUrl = targetList[oldItemIndex]['url'];
      if (oldUrl != null && oldUrl.contains("firebasestorage.googleapis.com")) {
        print('[replaceFile] Deleting from Firebase: $oldUrl');
        await _storageService.deleteFile(oldUrl);
      }

      targetList.removeAt(oldItemIndex);
    }

    final uploaded = await _storageService.uploadFile(
      file,
      vendorId: vendorId!,
      fileType: fileType,
    );
    uploaded['name'] = newName;
    targetList.add(uploaded);

    // 🔁 Sync single item change using updateMediaItem
    await _service.updateMediaItem(
      vendorId: vendorId,
      fileType: fileType,
      oldName: oldName,
      newItem: uploaded,
    );

    print('[replaceFile] Updated $fileType in DB: $uploaded');
    notifyListeners();
  }



  Future<void> deleteFile({
    required String name,
    required String fileType, // 'trainingCertifications' or 'officePhotos'
  }) async {
    List<Map<String, String>> targetList =
    fileType == 'trainingCertifications' ? trainingCertifications : officePhotos;

    print('[deleteFile] Deleting "$name" from $fileType');

    final index = targetList.indexWhere((item) => item['name'] == name);
    if (index != -1) {
      final url = targetList[index]['url'];
      if (url != null && url.contains("firebasestorage.googleapis.com")) {
        await _storageService.deleteFile(url);
      }

      targetList.removeAt(index);

      // 🔁 Sync delete action using deleteMediaItem
      String? vendorId = await _loginService.getVendorId();
      await _service.deleteMediaItem(
        vendorId: vendorId!,
        fileType: fileType,
        name: name,
      );

      print('[deleteFile] Successfully deleted "$name" and updated DB');
      notifyListeners();
    } else {
      print('[deleteFile] File "$name" not found.');
    }
  }



  Future<void> uploadFile({
    required String fileType,
    required String fileName,
    required File file,
  }) async {
    String? vendorId = await _loginService.getVendorId();

    print('[uploadFile] Uploading file: $fileName');

    // Upload the file using your AmbulanceAgencyStorageService
    final uploaded = await _storageService.uploadFile(
      file,
      vendorId: vendorId!,
      fileType: fileType,
    );

    // Ensure that the values are non-null before proceeding
    final fileUrl = uploaded['url'] ?? ''; // Default to empty string if null
    final fileNameFinal = fileName; // This is already non-null

    // Prepare the new item (name-url pair)
    final newMediaItem = {
      "url": fileUrl,
      "name": fileNameFinal,
    };

    // Add the uploaded file to the corresponding list (either trainingCertifications or officePhotos)
    if (fileType == 'trainingCertifications') {
      trainingCertifications.add(newMediaItem);
    } else if (fileType == 'officePhotos') {
      officePhotos.add(newMediaItem);
    }

    // Call the separate addMediaItem service method to add the item to the database
    await _service.addMediaItem(
      vendorId: vendorId,
      fileType: fileType,
      newItem: newMediaItem,
    );

    print('[uploadFile] File uploaded and added to DB successfully: $newMediaItem');

    // Notify listeners to update the UI
    notifyListeners();
  }
}
