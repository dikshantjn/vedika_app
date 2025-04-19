import 'package:flutter/material.dart';
import 'package:vedika_healthcare/features/Vendor/HospitalVendor/Models/HospitalProfile.dart';
import 'package:vedika_healthcare/features/Vendor/HospitalVendor/Services/HospitalVendorService.dart';
import 'package:vedika_healthcare/features/Vendor/HospitalVendor/Services/HospitalVendorStorageService.dart';
import 'package:file_picker/file_picker.dart';
import 'dart:io';

import 'package:vedika_healthcare/features/Vendor/Registration/Services/VendorLoginService.dart';
import 'package:vedika_healthcare/features/Vendor/Service/VendorService.dart';

class HospitalProfileViewModel extends ChangeNotifier {
  bool _isLoading = false;
  bool get isLoading => _isLoading;
  
  String? _error;
  String? get error => _error;
  
  bool _isEditing = false;
  bool get isEditing => _isEditing;
  
  bool _isActive = false;
  bool get isActive => _isActive;
  
  HospitalProfile? _hospitalProfile;
  HospitalProfile? get hospitalProfile => _hospitalProfile;
  final VendorLoginService _loginService = VendorLoginService();
  final VendorService _vendorService = VendorService();

  // Controllers for editing
  final TextEditingController nameController = TextEditingController();
  final TextEditingController ownerNameController = TextEditingController();
  final TextEditingController gstNumberController = TextEditingController();
  final TextEditingController panNumberController = TextEditingController();
  final TextEditingController emailController = TextEditingController();
  final TextEditingController phoneController = TextEditingController();
  final TextEditingController websiteController = TextEditingController();
  final TextEditingController addressController = TextEditingController();
  final TextEditingController landmarkController = TextEditingController();
  final TextEditingController cityController = TextEditingController();
  final TextEditingController stateController = TextEditingController();
  final TextEditingController pincodeController = TextEditingController();
  final TextEditingController workingTimeController = TextEditingController();
  final TextEditingController workingDaysController = TextEditingController();
  final TextEditingController bedsAvailableController = TextEditingController();
  final TextEditingController feesRangeController = TextEditingController();
  final TextEditingController aboutController = TextEditingController();

  final HospitalVendorService _service = HospitalVendorService();
  final HospitalVendorStorageService _storageService = HospitalVendorStorageService();
  String? _vendorId;

  @override
  void dispose() {
    nameController.dispose();
    ownerNameController.dispose();
    gstNumberController.dispose();
    panNumberController.dispose();
    emailController.dispose();
    phoneController.dispose();
    websiteController.dispose();
    addressController.dispose();
    landmarkController.dispose();
    cityController.dispose();
    stateController.dispose();
    pincodeController.dispose();
    workingTimeController.dispose();
    workingDaysController.dispose();
    bedsAvailableController.dispose();
    feesRangeController.dispose();
    aboutController.dispose();
    super.dispose();
  }

  void toggleEditMode() {
    _isEditing = !_isEditing;
    if (_isEditing && _hospitalProfile != null) {
      _initializeControllers();
    }
    notifyListeners();
  }

  // Get the vendor ID from the login service
  Future<String?> getVendorId() async {
    return await _loginService.getVendorId();
  }
  void _initializeControllers() {
    nameController.text = _hospitalProfile!.name;
    ownerNameController.text = _hospitalProfile!.ownerName;
    gstNumberController.text = _hospitalProfile!.gstNumber;
    panNumberController.text = _hospitalProfile!.panNumber;
    emailController.text = _hospitalProfile!.email;
    phoneController.text = _hospitalProfile!.contactNumber;
    websiteController.text = _hospitalProfile!.website ?? '';
    addressController.text = _hospitalProfile!.address;
    landmarkController.text = _hospitalProfile!.landmark;
    cityController.text = _hospitalProfile!.city;
    stateController.text = _hospitalProfile!.state;
    pincodeController.text = _hospitalProfile!.pincode;
    workingTimeController.text = _hospitalProfile!.workingTime;
    workingDaysController.text = _hospitalProfile!.workingDays;
    bedsAvailableController.text = _hospitalProfile!.bedsAvailable.toString();
    feesRangeController.text = _hospitalProfile!.feesRange;
    aboutController.text = _hospitalProfile!.about;
  }

  Future<void> fetchHospitalProfile() async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      // Get vendor ID from storage
      _vendorId = await getVendorId();
      if (_vendorId == null) {
        throw Exception('Vendor ID not found');
      }

      // Fetch current vendor status
      _isActive = await _vendorService.getVendorStatus(_vendorId!);
      print("✅ Current Vendor Status: $_isActive");

      // Fetch profile from API
      _hospitalProfile = await _service.getHospitalProfile(_vendorId!);
      
      // Update profile's active status
      if (_hospitalProfile != null) {
        _hospitalProfile = _hospitalProfile!.copyWith(isActive: _isActive);
      }
    } catch (e) {
      _error = 'Failed to load hospital profile: $e';
      print("❌ Error fetching profile: $e");
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<void> updateProfile() async {
    if (_hospitalProfile == null || _vendorId == null) return;

    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      // Create updated profile
      final updatedProfile = _hospitalProfile!.copyWith(
        name: nameController.text,
        ownerName: ownerNameController.text,
        gstNumber: gstNumberController.text,
        panNumber: panNumberController.text,
        email: emailController.text,
        contactNumber: phoneController.text,
        website: websiteController.text,
        address: addressController.text,
        landmark: landmarkController.text,
        city: cityController.text,
        state: stateController.text,
        pincode: pincodeController.text,
        workingTime: workingTimeController.text,
        workingDays: workingDaysController.text,
        bedsAvailable: int.tryParse(bedsAvailableController.text) ?? 0,
        feesRange: feesRangeController.text,
        about: aboutController.text,
      );

      // Update profile via API
      await _service.updateHospitalProfile(_vendorId!, updatedProfile);
      
      // Update local profile
      _hospitalProfile = updatedProfile;
      _isEditing = false;
    } catch (e) {
      _error = 'Failed to update profile: $e';
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<void> uploadFile(String documentType, {required bool isImage}) async {
    if (_vendorId == null) {
      _error = 'Vendor ID not found';
      notifyListeners();
      return;
    }

    try {
      FilePickerResult? result = await FilePicker.platform.pickFiles(
        type: isImage ? FileType.image : FileType.custom,
        allowedExtensions: isImage ? null : ['pdf'],
        allowMultiple: false,
      );

      if (result != null && result.files.isNotEmpty) {
        final file = File(result.files.single.path!);
        final fileName = result.files.single.name;
        
        final resultMap = await _storageService.uploadFile(
          file,
          vendorId: _vendorId!,
          fileType: documentType,
        );

        final newDocument = {
          'name': fileName,
          'url': resultMap['url'] ?? '',
        };

        if (_hospitalProfile != null) {
          switch (documentType) {
            case 'photos':
              final updatedPhotos = List<Map<String, String>>.from(_hospitalProfile!.photos);
              updatedPhotos.add(newDocument);
              _hospitalProfile = _hospitalProfile!.copyWith(photos: updatedPhotos);
              break;
            case 'certifications':
              final updatedCerts = List<Map<String, String>>.from(_hospitalProfile!.certifications);
              updatedCerts.add(newDocument);
              _hospitalProfile = _hospitalProfile!.copyWith(certifications: updatedCerts);
              break;
            case 'licenses':
              final updatedLicenses = List<Map<String, String>>.from(_hospitalProfile!.licenses);
              updatedLicenses.add(newDocument);
              _hospitalProfile = _hospitalProfile!.copyWith(licenses: updatedLicenses);
              break;
          }
          notifyListeners();
        }
      }
    } catch (e) {
      _error = 'Failed to upload file: $e';
      notifyListeners();
    }
  }

  Future<void> deleteFile(String documentType, int index) async {
    try {
      if (_hospitalProfile != null) {
        String? url;
        List<Map<String, String>> updatedDocuments;

        switch (documentType) {
          case 'photos':
            url = _hospitalProfile!.photos[index]['url'];
            updatedDocuments = List<Map<String, String>>.from(_hospitalProfile!.photos);
            updatedDocuments.removeAt(index);
            _hospitalProfile = _hospitalProfile!.copyWith(photos: updatedDocuments);
            break;
          case 'certifications':
            url = _hospitalProfile!.certifications[index]['url'];
            updatedDocuments = List<Map<String, String>>.from(_hospitalProfile!.certifications);
            updatedDocuments.removeAt(index);
            _hospitalProfile = _hospitalProfile!.copyWith(certifications: updatedDocuments);
            break;
          case 'licenses':
            url = _hospitalProfile!.licenses[index]['url'];
            updatedDocuments = List<Map<String, String>>.from(_hospitalProfile!.licenses);
            updatedDocuments.removeAt(index);
            _hospitalProfile = _hospitalProfile!.copyWith(licenses: updatedDocuments);
            break;
          default:
            return;
        }

        if (url != null) {
          await _storageService.deleteFile(url);
        }
        notifyListeners();
      }
    } catch (e) {
      _error = 'Failed to delete file: $e';
      notifyListeners();
    }
  }

  void updateBasicInfo({
    String? name,
    String? ownerName,
    String? gstNumber,
    String? panNumber,
    String? email,
    String? phoneNumber,
    String? website,
  }) {
    if (_hospitalProfile != null) {
      _hospitalProfile = _hospitalProfile!.copyWith(
        name: name ?? _hospitalProfile!.name,
        ownerName: ownerName ?? _hospitalProfile!.ownerName,
        gstNumber: gstNumber ?? _hospitalProfile!.gstNumber,
        panNumber: panNumber ?? _hospitalProfile!.panNumber,
        email: email ?? _hospitalProfile!.email,
        contactNumber: phoneNumber ?? _hospitalProfile!.contactNumber,
        website: website ?? _hospitalProfile!.website,
      );
      notifyListeners();
    }
  }

  void updateAddress({
    String? address,
    String? landmark,
    String? city,
    String? state,
    String? pincode,
  }) {
    if (_hospitalProfile != null) {
      _hospitalProfile = _hospitalProfile!.copyWith(
        address: address ?? _hospitalProfile!.address,
        landmark: landmark ?? _hospitalProfile!.landmark,
        city: city ?? _hospitalProfile!.city,
        state: state ?? _hospitalProfile!.state,
        pincode: pincode ?? _hospitalProfile!.pincode,
      );
      notifyListeners();
    }
  }

  void updateMedicalInfo({
    String? workingTime,
    String? workingDays,
    int? bedsAvailable,
    String? feesRange,
  }) {
    if (_hospitalProfile != null) {
      _hospitalProfile = _hospitalProfile!.copyWith(
        workingTime: workingTime ?? _hospitalProfile!.workingTime,
        workingDays: workingDays ?? _hospitalProfile!.workingDays,
        bedsAvailable: bedsAvailable ?? _hospitalProfile!.bedsAvailable,
        feesRange: feesRange ?? _hospitalProfile!.feesRange,
      );
      notifyListeners();
    }
  }

  void updateFacilities({
    bool? hasLiftAccess,
    bool? hasParking,
    bool? providesAmbulanceService,
    bool? hasWheelchairAccess,
    bool? providesOnlineConsultancy,
  }) {
    if (_hospitalProfile != null) {
      _hospitalProfile = _hospitalProfile!.copyWith(
        hasLiftAccess: hasLiftAccess ?? _hospitalProfile!.hasLiftAccess,
        hasParking: hasParking ?? _hospitalProfile!.hasParking,
        providesAmbulanceService: providesAmbulanceService ?? _hospitalProfile!.providesAmbulanceService,
        hasWheelchairAccess: hasWheelchairAccess ?? _hospitalProfile!.hasWheelchairAccess,
        providesOnlineConsultancy: providesOnlineConsultancy ?? _hospitalProfile!.providesOnlineConsultancy,
      );
      notifyListeners();
    }
  }

  void updateServices({
    List<String>? specialityTypes,
    List<String>? servicesOffered,
    List<String>? insuranceCompanies,
  }) {
    if (_hospitalProfile != null) {
      _hospitalProfile = _hospitalProfile!.copyWith(
        specialityTypes: specialityTypes ?? _hospitalProfile!.specialityTypes,
        servicesOffered: servicesOffered ?? _hospitalProfile!.servicesOffered,
        insuranceCompanies: insuranceCompanies ?? _hospitalProfile!.insuranceCompanies,
      );
      notifyListeners();
    }
  }

  Future<void> toggleActiveStatus() async {
    try {
      print("🔄 Toggling Vendor Status...");
      
      if (_vendorId == null) {
        _vendorId = await getVendorId();
        if (_vendorId == null) {
          print("❌ Error: Vendor ID is null during toggle");
          return;
        }
      }

      // Call the toggle status API
      final newStatus = await _vendorService.toggleVendorStatus(_vendorId!);
      print("✅ Vendor Status Toggled: $newStatus");
      
      // Update local state
      _isActive = newStatus;
      
      // Update profile's active status
      if (_hospitalProfile != null) {
        _hospitalProfile = _hospitalProfile!.copyWith(isActive: newStatus);
      }
      
      notifyListeners();
      print("✅ Local State Updated - isActive: $_isActive");
      
      // Verify the new status matches the server
      final verifiedStatus = await _vendorService.getVendorStatus(_vendorId!);
      print("✅ Verified Server Status: $verifiedStatus");
      
      if (verifiedStatus != newStatus) {
        print("⚠️ Status mismatch detected. Updating to server status.");
        _isActive = verifiedStatus;
        if (_hospitalProfile != null) {
          _hospitalProfile = _hospitalProfile!.copyWith(isActive: verifiedStatus);
        }
        notifyListeners();
      }
    } catch (e) {
      print("❌ Error toggling vendor status: $e");
      // Revert the switch if the API call fails
      _isActive = !_isActive;
      if (_hospitalProfile != null) {
        _hospitalProfile = _hospitalProfile!.copyWith(isActive: _isActive);
      }
      notifyListeners();
    }
  }
} 