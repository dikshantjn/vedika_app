import 'dart:io';
import 'package:flutter/material.dart';
import 'package:logger/logger.dart';
import 'package:vedika_healthcare/features/Vendor/HospitalVendor/Models/HospitalProfile.dart';
import 'package:vedika_healthcare/features/Vendor/HospitalVendor/Services/HospitalVendorService.dart';
import 'package:vedika_healthcare/features/Vendor/HospitalVendor/Services/HospitalVendorStorageService.dart';
import 'package:vedika_healthcare/features/Vendor/Registration/Models/Vendor.dart';

class HospitalRegistrationViewModel extends ChangeNotifier {
  final HospitalVendorService _service = HospitalVendorService();
  final HospitalVendorStorageService _storageService = HospitalVendorStorageService();
  final Logger _logger = Logger();
  
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
  String get location => locationController.text;
  
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
    _logger.i('Setting PAN card file with data: $file');
    
    // Validate input
    if (file == null) {
      _logger.e('setPanCardFile called with null file data');
      return;
    }

    if (file['file'] == null) {
      _logger.e('PAN card file object is null');
      return;
    }

    if (file['name'] == null || file['name'].toString().isEmpty) {
      _logger.e('PAN card file name is null or empty');
      return;
    }

    // Ensure the file is actually a File object
    if (!(file['file'] is File)) {
      _logger.e('PAN card file is not a File object, type: ${file['file'].runtimeType}');
      return;
    }

    // Set the file data
    panCardFile = {
      'name': file['name'],
      'file': file['file'],
    };
    
    _logger.i('PAN card file set successfully:');
    _logger.i('Name: ${panCardFile!['name']}');
    _logger.i('File type: ${panCardFile!['file'].runtimeType}');
    _logger.i('File path: ${(panCardFile!['file'] as File).path}');
    
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
        _logger.e('Registration failed: Hospital name is required');
        _isLoading = false;
        notifyListeners();
        return false;
      }
      if (email.isEmpty) {
        _error = 'Email is required';
        _logger.e('Registration failed: Email is required');
        _isLoading = false;
        notifyListeners();
        return false;
      }
      if (password.isEmpty) {
        _error = 'Password is required';
        _logger.e('Registration failed: Password is required');
        _isLoading = false;
        notifyListeners();
        return false;
      }
      if (phone.isEmpty) {
        _error = 'Phone number is required';
        _logger.e('Registration failed: Phone number is required');
        _isLoading = false;
        notifyListeners();
        return false;
      }
      if (gstNumber.isEmpty) {
        _error = 'GST number is required';
        _logger.e('Registration failed: GST number is required');
        _isLoading = false;
        notifyListeners();
        return false;
      }
      if (panNumber.isEmpty) {
        _error = 'PAN number is required';
        _logger.e('Registration failed: PAN number is required');
        _isLoading = false;
        notifyListeners();
        return false;
      }
      if (_selectedState.isEmpty) {
        _error = 'State is required';
        _logger.e('Registration failed: State is required');
        _isLoading = false;
        notifyListeners();
        return false;
      }
      if (_selectedCity.isEmpty) {
        _error = 'City is required';
        _logger.e('Registration failed: City is required');
        _isLoading = false;
        notifyListeners();
        return false;
      }
      if (pincode.isEmpty) {
        _error = 'Pincode is required';
        _logger.e('Registration failed: Pincode is required');
        _isLoading = false;
        notifyListeners();
        return false;
      }

      final String tempVendorId = DateTime.now().millisecondsSinceEpoch.toString();
      _logger.i('Starting file uploads with tempVendorId: $tempVendorId');

      if (_certificationFiles.isNotEmpty) {
        try {
          _logger.i('Uploading ${_certificationFiles.length} certification files');
          _certifications = await _storageService.uploadMultipleFiles(
            _certificationFiles,
            vendorId: tempVendorId,
            fileType: 'certifications',
          );
          _logger.i('Successfully uploaded certification files');
        } catch (e) {
          _error = 'Failed to upload certifications: $e';
          _logger.e('Certification upload failed', error: e, stackTrace: StackTrace.current);
          _isLoading = false;
          notifyListeners();
          return false;
        }
      }

      if (_licenseFiles.isNotEmpty) {
        try {
          _logger.i('Uploading ${_licenseFiles.length} license files');
          _licenses = await _storageService.uploadMultipleFiles(
            _licenseFiles,
            vendorId: tempVendorId,
            fileType: 'licenses',
          );
          _logger.i('Successfully uploaded license files');
        } catch (e) {
          _error = 'Failed to upload licenses: $e';
          _logger.e('License upload failed', error: e, stackTrace: StackTrace.current);
          _isLoading = false;
          notifyListeners();
          return false;
        }
      }

      if (_photoFiles.isNotEmpty) {
        try {
          _logger.i('Uploading ${_photoFiles.length} photo files');
          _photos = await _storageService.uploadMultipleFiles(
            _photoFiles,
            vendorId: tempVendorId,
            fileType: 'photos',
          );
          _logger.i('Successfully uploaded photo files');
        } catch (e) {
          _error = 'Failed to upload photos: $e';
          _logger.e('Photo upload failed', error: e, stackTrace: StackTrace.current);
          _isLoading = false;
          notifyListeners();
          return false;
        }
      }

      // Debug logging for PAN card file
      if (panCardFile != null) {
        _logger.i('PAN card file before upload:');
        _logger.i('Name: ${panCardFile!['name']}');
        _logger.i('File type: ${panCardFile!['file']?.runtimeType}');
        if (panCardFile!['file'] != null) {
          _logger.i('File path: ${(panCardFile!['file'] as File).path}');
        } else {
          _logger.w('PAN card file object is null');
        }
      } else {
        _logger.w('PAN card file is null before upload attempt');
      }

      // Upload PAN card file if exists
      if (panCardFile != null && panCardFile!['file'] != null) {
        try {
          final file = panCardFile!['file'] as File;
          final fileName = panCardFile!['name'] as String?;
          
          if (fileName == null || fileName.isEmpty) {
            _error = 'PAN card file name is missing';
            _logger.e('PAN card file name is missing in upload attempt');
            _isLoading = false;
            notifyListeners();
            return false;
          }

          _logger.i('Uploading PAN card file: $fileName');
          final result = await _storageService.uploadFile(
            file,
            vendorId: tempVendorId,
            fileType: 'pan_card',
          );
          panCardFile = {
            'name': fileName,
            'url': result['url'],
          };
          _logger.i('Successfully uploaded PAN card file');
        } catch (e) {
          _error = 'Failed to upload PAN card: $e';
          _logger.e('PAN card upload failed - File: ${panCardFile!['name']}', 
            error: e, 
            stackTrace: StackTrace.current
          );
          _isLoading = false;
          notifyListeners();
          return false;
        }
      }

      if (businessDocuments.isNotEmpty) {
        try {
          _logger.i('Uploading ${businessDocuments.length} business documents');
          for (int i = 0; i < businessDocuments.length; i++) {
            final doc = businessDocuments[i];
            final file = doc['file'] as File?;
            final fileName = doc['name'] as String?;

            if (file == null) {
              _error = 'Business document file is null';
              _logger.e('Business document file is null at index $i');
              _isLoading = false;
              notifyListeners();
              return false;
            }

            if (fileName == null || fileName.isEmpty) {
              _error = 'Business document file name is missing';
              _logger.e('Business document file name is missing at index $i');
              _isLoading = false;
              notifyListeners();
              return false;
            }

            _logger.i('Uploading business document: $fileName');
            final result = await _storageService.uploadFile(
              file,
              vendorId: tempVendorId,
              fileType: 'business_documents',
            );
            businessDocuments[i] = {
              'name': fileName,
              'url': result['url'],
            };
            _logger.i('Successfully uploaded business document: $fileName');
          }
        } catch (e) {
          _error = 'Failed to upload business documents: $e';
          _logger.e('Business documents upload failed - Count: ${businessDocuments.length}', 
            error: e, 
            stackTrace: StackTrace.current
          );
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
      _logger.i('Created vendor object with ID: $tempVendorId');

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
        location: location,
        panCardFile: panCardFile,
        businessDocuments: businessDocuments,
      );
      _logger.i('Created hospital profile object');

      _logger.i('Calling hospital registration API');
      final response = await _service.registerHospital(vendor, hospital);
      _logger.i('API response status code: ${response.statusCode}');

      if (response.statusCode == 200 || response.statusCode == 201) {
        _logger.i('Registration successful, clearing file lists');
        _certificationFiles.clear();
        _licenseFiles.clear();
        _photoFiles.clear();
        _certifications.clear();
        _licenses.clear();
        _photos.clear();
        panCardFile = null;
        businessDocuments.clear();
      } else {
        _logger.w('Registration failed with status code: ${response.statusCode}');
      }

      _isLoading = false;
      notifyListeners();
      return response.statusCode == 200 || response.statusCode == 201;
    } catch (e) {
      _error = e.toString();
      _logger.e('Registration failed - Hospital: $hospitalName, Email: $email, Phone: $phone', 
        error: e, 
        stackTrace: StackTrace.current
      );
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

  // Add these new methods for file uploads
  void uploadCertifications(List<Map<String, Object>> files) {
    if (files.isNotEmpty) {
      for (var file in files) {
        final fileName = file['name'] as String?;
        final fileObj = file['file'] as File?;
        
        if (fileName != null && fileObj != null) {
          // Add to certification files list for later upload
          _certificationFiles.add(fileObj);
          
          // Add to certifications list with name only (URL will be added after upload)
          if (!_certifications.any((e) => e['name'] == fileName)) {
            _certifications.add({
              'name': fileName,
              'url': '', // URL will be set after upload
            });
          }
        }
      }
      notifyListeners();
    }
  }

  void uploadLicenses(List<Map<String, Object>> files) {
    if (files.isNotEmpty) {
      for (var file in files) {
        final fileName = file['name'] as String?;
        final fileObj = file['file'] as File?;
        
        if (fileName != null && fileObj != null) {
          // Add to license files list for later upload
          _licenseFiles.add(fileObj);
          
          // Add to licenses list with name only (URL will be added after upload)
          if (!_licenses.any((e) => e['name'] == fileName)) {
            _licenses.add({
              'name': fileName,
              'url': '', // URL will be set after upload
            });
          }
        }
      }
      notifyListeners();
    }
  }

  void uploadPanCard(Map<String, Object> file) {
    final fileName = file['name'] as String?;
    final fileObj = file['file'] as File?;
    
    if (fileName != null && fileObj != null) {
      // Set PAN card file for later upload
      panCardFile = {
        'name': fileName,
        'file': fileObj,
      };
      notifyListeners();
    }
  }

  void uploadBusinessDocuments(List<Map<String, Object>> files) {
    if (files.isNotEmpty) {
      for (var file in files) {
        final fileName = file['name'] as String?;
        final fileObj = file['file'] as File?;
        
        if (fileName != null && fileObj != null) {
          // Add to business documents list with file object
          if (!businessDocuments.any((e) => e['name'] == fileName)) {
            businessDocuments.add({
              'name': fileName,
              'file': fileObj,
            });
          }
        }
      }
      notifyListeners();
    }
  }
} 