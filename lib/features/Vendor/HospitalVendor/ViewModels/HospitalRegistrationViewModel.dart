import 'dart:io';
import 'package:flutter/material.dart';
import 'package:vedika_healthcare/features/Vendor/HospitalVendor/Models/HospitalProfile.dart';
import 'package:vedika_healthcare/features/Vendor/HospitalVendor/Services/HospitalVendorService.dart';
import 'package:vedika_healthcare/features/Vendor/HospitalVendor/Services/HospitalVendorStorageService.dart';
import 'package:vedika_healthcare/features/Vendor/Registration/Models/Vendor.dart';

class HospitalRegistrationViewModel extends ChangeNotifier {
  final HospitalVendorService _service = HospitalVendorService();
  final HospitalVendorStorageService _storageService = HospitalVendorStorageService();
  
  bool _isLoading = false;
  bool get isLoading => _isLoading;
  
  String? _error;
  String? get error => _error;
  
  final TextEditingController hospitalNameController = TextEditingController();
  final TextEditingController emailController = TextEditingController();
  final TextEditingController passwordController = TextEditingController();
  final TextEditingController confirmPasswordController = TextEditingController();
  final TextEditingController phoneController = TextEditingController();
  final TextEditingController gstNumberController = TextEditingController();
  final TextEditingController panNumberController = TextEditingController();
  final TextEditingController addressController = TextEditingController();
  final TextEditingController landmarkController = TextEditingController();
  final TextEditingController ownerNameController = TextEditingController();
  final TextEditingController workingTimeController = TextEditingController();
  final TextEditingController workingDaysController = TextEditingController();
  final TextEditingController contactNumberController = TextEditingController();
  final TextEditingController websiteController = TextEditingController();
  final TextEditingController aboutController = TextEditingController();
  final TextEditingController feesRangeController = TextEditingController();
  final TextEditingController locationController = TextEditingController();
  final TextEditingController pincodeController = TextEditingController();
  final TextEditingController ownerContactController = TextEditingController();
  
  String _selectedState = '';
  String get selectedState => _selectedState;
  
  String _selectedCity = '';
  String get selectedCity => _selectedCity;
  
  List<Map<String, String>> _certifications = [];
  List<Map<String, String>> get certifications => _certifications;
  
  List<Map<String, String>> _licenses = [];
  List<Map<String, String>> get licenses => _licenses;
  
  List<String> _specialityTypes = [];
  List<String> get specialityTypes => _specialityTypes;
  
  List<String> _servicesOffered = [];
  List<String> get servicesOffered => _servicesOffered;
  
  int _bedsAvailable = 0;
  int get bedsAvailable => _bedsAvailable;
  
  List<Map<String, dynamic>> _doctors = [];
  List<Map<String, dynamic>> get doctors => _doctors;
  
  bool _hasLiftAccess = false;
  bool get hasLiftAccess => _hasLiftAccess;
  
  bool _hasParking = false;
  bool get hasParking => _hasParking;
  
  bool _providesAmbulanceService = false;
  bool get providesAmbulanceService => _providesAmbulanceService;
  
  bool _hasWheelchairAccess = false;
  bool get hasWheelchairAccess => _hasWheelchairAccess;
  
  bool _providesOnlineConsultancy = false;
  bool get providesOnlineConsultancy => _providesOnlineConsultancy;
  
  List<String> _otherFacilities = [];
  List<String> get otherFacilities => _otherFacilities;
  
  List<String> _insuranceCompanies = [];
  List<String> get insuranceCompanies => _insuranceCompanies;
  
  List<Map<String, String>> _photos = [];
  List<Map<String, String>> get photos => _photos;
  
  List<File> _certificationFiles = [];
  List<File> _licenseFiles = [];
  List<File> _photoFiles = [];
  
  Map<String, dynamic>? panCardFile;
  List<Map<String, dynamic>> businessDocuments = [];
  
  String get email => emailController.text;
  String get password => passwordController.text;
  String get hospitalName => hospitalNameController.text;
  String get phone => phoneController.text;
  String get gstNumber => gstNumberController.text;
  String get panNumber => panNumberController.text;
  String get address => addressController.text;
  String get landmark => landmarkController.text;
  String get ownerName => ownerNameController.text;
  String get contactNumber => contactNumberController.text;
  String get website => websiteController.text;
  String get pincode => pincodeController.text;
  
  void updateBedsAvailable(int value) {
    _bedsAvailable = value;
    notifyListeners();
  }
  
  void updateSpecialityTypes(List<String> types) {
    _specialityTypes = types;
    notifyListeners();
  }
  
  void updateServicesOffered(List<String> services) {
    _servicesOffered = services;
    notifyListeners();
  }
  
  void updateOtherFacilities(List<String> facilities) {
    _otherFacilities = facilities;
    notifyListeners();
  }
  
  void updateInsuranceCompanies(List<String> companies) {
    _insuranceCompanies = companies;
    notifyListeners();
  }
  
  void toggleLiftAccess() {
    _hasLiftAccess = !_hasLiftAccess;
    notifyListeners();
  }
  
  void toggleParking() {
    _hasParking = !_hasParking;
    notifyListeners();
  }
  
  void toggleAmbulanceService() {
    _providesAmbulanceService = !_providesAmbulanceService;
    notifyListeners();
  }
  
  void toggleWheelchairAccess() {
    _hasWheelchairAccess = !_hasWheelchairAccess;
    notifyListeners();
  }
  
  void toggleOnlineConsultancy() {
    _providesOnlineConsultancy = !_providesOnlineConsultancy;
    notifyListeners();
  }
  
  void addCertification(Map<String, String> certification) {
    _certifications.add(certification);
    notifyListeners();
  }
  
  void addLicense(Map<String, String> license) {
    _licenses.add(license);
    notifyListeners();
  }
  
  void addDoctor(Map<String, dynamic> doctor) {
    _doctors.add(doctor);
    notifyListeners();
  }
  
  void addPhoto(Map<String, String> photo) {
    _photos.add(photo);
    notifyListeners();
  }
  
  void updateState(String state) {
    _selectedState = state;
    _selectedCity = ''; // Reset city when state changes
    notifyListeners();
  }

  void updateCity(String city) {
    _selectedCity = city;
    notifyListeners();
  }
  
  void addCertificationFile(File file) {
    _certificationFiles.add(file);
    notifyListeners();
  }

  void addLicenseFile(File file) {
    _licenseFiles.add(file);
    notifyListeners();
  }

  void addPhotoFile(File file) {
    _photoFiles.add(file);
    notifyListeners();
  }

  void removeCertificationFile(int index) {
    _certificationFiles.removeAt(index);
    notifyListeners();
  }

  void removeLicenseFile(int index) {
    _licenseFiles.removeAt(index);
    notifyListeners();
  }

  void removePhotoFile(int index) {
    _photoFiles.removeAt(index);
    notifyListeners();
  }
  
  void setPanCardFile(Map<String, dynamic> file) {
    panCardFile = file;
    notifyListeners();
  }

  void addBusinessDocument(Map<String, dynamic> document) {
    businessDocuments.add(document);
    notifyListeners();
  }

  void removeBusinessDocument(int index) {
    if (index >= 0 && index < businessDocuments.length) {
      businessDocuments.removeAt(index);
      notifyListeners();
    }
  }
  
  Future<bool> registerHospital() async {
    try {
      _isLoading = true;
      notifyListeners();

      if (hospitalName.isEmpty) {
        _error = 'Hospital name is required';
        _isLoading = false;
        notifyListeners();
        return false;
      }
      if (email.isEmpty) {
        _error = 'Email is required';
        _isLoading = false;
        notifyListeners();
        return false;
      }
      if (password.isEmpty) {
        _error = 'Password is required';
        _isLoading = false;
        notifyListeners();
        return false;
      }
      if (phone.isEmpty) {
        _error = 'Phone number is required';
        _isLoading = false;
        notifyListeners();
        return false;
      }
      if (gstNumber.isEmpty) {
        _error = 'GST number is required';
        _isLoading = false;
        notifyListeners();
        return false;
      }
      if (panNumber.isEmpty) {
        _error = 'PAN number is required';
        _isLoading = false;
        notifyListeners();
        return false;
      }
      if (_selectedState.isEmpty) {
        _error = 'State is required';
        _isLoading = false;
        notifyListeners();
        return false;
      }
      if (_selectedCity.isEmpty) {
        _error = 'City is required';
        _isLoading = false;
        notifyListeners();
        return false;
      }
      if (pincode.isEmpty) {
        _error = 'Pincode is required';
        _isLoading = false;
        notifyListeners();
        return false;
      }

      final String tempVendorId = DateTime.now().millisecondsSinceEpoch.toString();

      if (_certificationFiles.isNotEmpty) {
        try {
          _certifications = await _storageService.uploadMultipleFiles(
            _certificationFiles,
            vendorId: tempVendorId,
            fileType: 'certifications',
          );
        } catch (e) {
          _error = 'Failed to upload certifications: $e';
          _isLoading = false;
          notifyListeners();
          return false;
        }
      }

      if (_licenseFiles.isNotEmpty) {
        try {
          _licenses = await _storageService.uploadMultipleFiles(
            _licenseFiles,
            vendorId: tempVendorId,
            fileType: 'licenses',
          );
        } catch (e) {
          _error = 'Failed to upload licenses: $e';
          _isLoading = false;
          notifyListeners();
          return false;
        }
      }

      if (_photoFiles.isNotEmpty) {
        try {
          _photos = await _storageService.uploadMultipleFiles(
            _photoFiles,
            vendorId: tempVendorId,
            fileType: 'photos',
          );
        } catch (e) {
          _error = 'Failed to upload photos: $e';
          _isLoading = false;
          notifyListeners();
          return false;
        }
      }

      final vendor = Vendor(
        vendorRole: 1,
        phoneNumber: phone,
        email: email,
        password: password,
        generatedId: tempVendorId,
      );

      final hospital = HospitalProfile(
        name: hospitalName,
        gstNumber: gstNumber,
        panNumber: panNumber,
        address: address,
        landmark: landmark,
        ownerName: ownerName,
        certifications: _certifications,
        licenses: _licenses,
        specialityTypes: _specialityTypes,
        servicesOffered: _servicesOffered,
        bedsAvailable: _bedsAvailable,
        doctors: _doctors,
        workingTime: workingTimeController.text,
        workingDays: workingDaysController.text,
        contactNumber: phone,
        email: email,
        website: website,
        hasLiftAccess: _hasLiftAccess,
        hasParking: _hasParking,
        providesAmbulanceService: _providesAmbulanceService,
        about: aboutController.text,
        hasWheelchairAccess: _hasWheelchairAccess,
        providesOnlineConsultancy: _providesOnlineConsultancy,
        feesRange: feesRangeController.text,
        otherFacilities: _otherFacilities,
        insuranceCompanies: _insuranceCompanies,
        photos: _photos,
        state: _selectedState,
        city: _selectedCity,
        pincode: pincode,
      );
      
      final response = await _service.registerHospital(vendor, hospital);
      
      if (response.statusCode == 200 || response.statusCode == 201) {
        _certificationFiles.clear();
        _licenseFiles.clear();
        _photoFiles.clear();
        _certifications.clear();
        _licenses.clear();
        _photos.clear();
      }

      _isLoading = false;
      notifyListeners();
      return response.statusCode == 200 || response.statusCode == 201;
    } catch (e) {
      _error = e.toString();
      _isLoading = false;
      notifyListeners();
      return false;
    }
  }
  
  @override
  void dispose() {
    hospitalNameController.dispose();
    emailController.dispose();
    passwordController.dispose();
    confirmPasswordController.dispose();
    phoneController.dispose();
    gstNumberController.dispose();
    panNumberController.dispose();
    addressController.dispose();
    landmarkController.dispose();
    ownerNameController.dispose();
    workingTimeController.dispose();
    workingDaysController.dispose();
    contactNumberController.dispose();
    websiteController.dispose();
    aboutController.dispose();
    feesRangeController.dispose();
    locationController.dispose();
    pincodeController.dispose();
    ownerContactController.dispose();
    super.dispose();
  }
} 