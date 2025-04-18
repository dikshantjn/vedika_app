import 'package:flutter/material.dart';
import 'package:vedika_healthcare/features/Vendor/HospitalVendor/Models/HospitalProfile.dart';
import 'package:vedika_healthcare/features/Vendor/HospitalVendor/Services/HospitalVendorStorageService.dart';
import 'package:file_picker/file_picker.dart';
import 'dart:io';

class HospitalProfileViewModel extends ChangeNotifier {
  bool _isLoading = false;
  bool get isLoading => _isLoading;
  
  String? _error;
  String? get error => _error;
  
  bool _isEditing = false;
  bool get isEditing => _isEditing;
  
  HospitalProfile? _hospitalProfile;
  HospitalProfile? get hospitalProfile => _hospitalProfile;
  
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
      // TODO: Replace with actual API call
      await Future.delayed(const Duration(seconds: 1));
      _hospitalProfile = HospitalProfile(
        name: 'City General Hospital',
        gstNumber: 'GST123456789',
        panNumber: 'PAN123456789',
        address: '123 Medical Street',
        landmark: 'Near City Mall',
        ownerName: 'Dr. John Smith',
        certifications: [
          {'name': 'ISO 9001', 'url': 'cert1.pdf'},
          {'name': 'NABH', 'url': 'cert2.pdf'},
        ],
        licenses: [
          {'name': 'Medical License', 'url': 'license1.pdf'},
          {'name': 'Pharmacy License', 'url': 'license2.pdf'},
        ],
        specialityTypes: ['Cardiology', 'Neurology', 'Orthopedics'],
        servicesOffered: ['Emergency Care', 'Surgery', 'Diagnostics'],
        bedsAvailable: 100,
        doctors: [
          {
            'name': 'Dr. Sarah Johnson',
            'speciality': 'Cardiology',
            'experience': '15 years',
          },
          {
            'name': 'Dr. Michael Brown',
            'speciality': 'Neurology',
            'experience': '12 years',
          },
        ],
        workingTime: '24/7',
        workingDays: 'Monday to Sunday',
        contactNumber: '+91 9876543210',
        email: 'info@cityhospital.com',
        website: 'www.cityhospital.com',
        hasLiftAccess: true,
        hasParking: true,
        providesAmbulanceService: true,
        about: 'City General Hospital is a leading healthcare provider with state-of-the-art facilities and experienced medical professionals.',
        hasWheelchairAccess: true,
        providesOnlineConsultancy: true,
        feesRange: '₹500 - ₹5000',
        otherFacilities: ['Cafeteria', 'Pharmacy', 'ATM'],
        insuranceCompanies: ['ICICI Lombard', 'HDFC Ergo', 'Bajaj Allianz'],
        photos: [
          {'name': 'Main Building', 'url': 'hospital1.jpg'},
          {'name': 'Emergency Ward', 'url': 'hospital2.jpg'},
        ],
        state: 'Maharashtra',
        city: 'Mumbai',
        pincode: '400001',
        isActive: true,
      );
      _vendorId = 'HOSP123';
    } catch (e) {
      _error = 'Failed to load hospital profile: $e';
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<void> updateProfile() async {
    if (_hospitalProfile == null) return;

    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      // TODO: Replace with actual API call
      await Future.delayed(const Duration(seconds: 1));
      
      _hospitalProfile = _hospitalProfile!.copyWith(
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
} 