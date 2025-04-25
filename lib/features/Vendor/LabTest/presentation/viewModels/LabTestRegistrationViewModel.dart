import 'dart:io';
import 'package:flutter/material.dart';
import 'package:vedika_healthcare/features/Vendor/LabTest/data/models/DiagnosticCenter.dart';
import 'package:vedika_healthcare/features/Vendor/LabTest/data/services/LabTestService.dart';
import 'package:vedika_healthcare/features/Vendor/LabTest/data/services/LabTestStorageService.dart';
import 'package:vedika_healthcare/shared/utils/state_city_data.dart';
import 'package:logger/logger.dart';
import 'package:vedika_healthcare/features/Vendor/DoctorConsultationVendor/Models/Vendor.dart';

class LabTestRegistrationViewModel extends ChangeNotifier {
  final LabTestService _labTestService = LabTestService();
  final LabTestStorageService _storageService = LabTestStorageService();
  final Logger _logger = Logger();

  final DiagnosticCenter profile = DiagnosticCenter(
    name: '',
    gstNumber: '',
    panNumber: '',
    ownerName: '',
    regulatoryComplianceUrl: {'name': '', 'url': ''},
    qualityAssuranceUrl: {'name': '', 'url': ''},
    sampleCollectionMethod: '',
    testTypes: [],
    businessTimings: '',
    businessDays: [],
    homeCollectionGeoLimit: '',
    emergencyHandlingFastTrack: false,
    address: '',
    state: '',
    city: '',
    pincode: '',
    nearbyLandmark: '',
    floor: '',
    parkingAvailable: false,
    wheelchairAccess: false,
    liftAccess: false,
    ambulanceServiceAvailable: false,
    mainContactNumber: '',
    emergencyContactNumber: '',
    email: '',
    website: '',
    languagesSpoken: [],
    centerPhotosUrl: '',
    googleMapsLocationUrl: '',
    password: '',
    filesAndImages: [],
    location: '',
  );

  bool _isLoading = false;
  String? _error;
  Map<String, String> _validationErrors = {};

  // File handling
  File? regulatoryComplianceFile;
  String? regulatoryComplianceFileName;
  File? qualityAssuranceFile;
  String? qualityAssuranceFileName;
  List<Map<String, dynamic>> centerPhotoFiles = [];

  // State and city data
  List<StateModel> states = [];
  List<String> availableCities = [];

  bool get isLoading => _isLoading;
  String? get error => _error;
  Map<String, String> get validationErrors => _validationErrors;

  LabTestRegistrationViewModel() {
    _loadStateCityData();
  }

  void _loadStateCityData() {
    states = StateCityDataProvider.states;
    if (states.isNotEmpty) {
      availableCities = StateCityDataProvider.getCities(states.first.name);
    }
  }

  // Setters for profile fields
  void setCenterName(String value) {
    profile.name = value;
    notifyListeners();
  }

  void setGstNumber(String value) {
    profile.gstNumber = value;
    notifyListeners();
  }

  void setPanNumber(String value) {
    profile.panNumber = value;
    notifyListeners();
  }

  void setOwnerName(String value) {
    profile.ownerName = value;
    notifyListeners();
  }

  void setEmail(String value) {
    profile.email = value;
    notifyListeners();
  }

  void setPassword(String value) {
    profile.password = value;
    notifyListeners();
  }

  void setConfirmPassword(String value) {
    // This is just for validation, not stored in profile
    notifyListeners();
  }

  void setMainContactNumber(String value) {
    profile.mainContactNumber = value;
    notifyListeners();
  }

  void setEmergencyContactNumber(String value) {
    profile.emergencyContactNumber = value;
    notifyListeners();
  }

  void setBusinessTimings(String value) {
    profile.businessTimings = value;
    notifyListeners();
  }

  void setBusinessDays(List<String> value) {
    profile.businessDays = value;
    notifyListeners();
  }

  void setSampleCollectionMethod(String value) {
    profile.sampleCollectionMethod = value;
    notifyListeners();
  }

  void setHomeCollectionGeoLimit(String value) {
    profile.homeCollectionGeoLimit = value;
    notifyListeners();
  }

  void setTestTypes(List<String> value) {
    profile.testTypes = value;
    notifyListeners();
  }

  void setEmergencyHandlingFastTrack(bool value) {
    profile.emergencyHandlingFastTrack = value;
    notifyListeners();
  }

  void setAddress(String value) {
    profile.address = value;
    notifyListeners();
  }

  void setState(String value) {
    profile.state = value;
    availableCities = StateCityDataProvider.getCities(value);
    notifyListeners();
  }

  void setCity(String value) {
    profile.city = value;
    notifyListeners();
  }

  void setPincode(String value) {
    profile.pincode = value;
    notifyListeners();
  }

  void setNearbyLandmark(String value) {
    profile.nearbyLandmark = value;
    notifyListeners();
  }

  void setFloor(String value) {
    profile.floor = value;
    notifyListeners();
  }

  void setLocation(String value) {
    profile.location = value;
    notifyListeners();
  }

  void setLiftAccess(bool value) {
    profile.liftAccess = value;
    notifyListeners();
  }

  void setWheelchairAccess(bool value) {
    profile.wheelchairAccess = value;
    notifyListeners();
  }

  void setParkingAvailable(bool value) {
    profile.parkingAvailable = value;
    notifyListeners();
  }

  void setAmbulanceServiceAvailable(bool value) {
    profile.ambulanceServiceAvailable = value;
    notifyListeners();
  }

  // File handling methods
  void setRegulatoryComplianceFile(File file, String fileName) {
    regulatoryComplianceFile = file;
    regulatoryComplianceFileName = fileName;
    notifyListeners();
  }

  void setQualityAssuranceFile(File file, String fileName) {
    qualityAssuranceFile = file;
    qualityAssuranceFileName = fileName;
    notifyListeners();
  }

  void addCenterPhotoFile(File file, String fileName) {
    centerPhotoFiles.add({
      'file': file,
      'name': fileName,
    });
    notifyListeners();
  }

  void removeCenterPhotoFile(int index) {
    if (index >= 0 && index < centerPhotoFiles.length) {
      centerPhotoFiles.removeAt(index);
      notifyListeners();
    }
  }

  // Validation methods
  bool validateProfile() {
    _validationErrors.clear();
    _logger.i('Starting profile validation...');
    
    // Basic Information
    if (profile.name.isEmpty) {
      _validationErrors['name'] = 'Center name is required';
      _logger.w('Validation error: Center name is empty');
    }
    if (profile.gstNumber.isEmpty) {
      _validationErrors['gstNumber'] = 'GST number is required';
      _logger.w('Validation error: GST number is empty');
    }
    if (profile.panNumber.isEmpty) {
      _validationErrors['panNumber'] = 'PAN number is required';
      _logger.w('Validation error: PAN number is empty');
    }
    if (profile.ownerName.isEmpty) {
      _validationErrors['ownerName'] = 'Owner name is required';
      _logger.w('Validation error: Owner name is empty');
    }

    // Contact Information
    if (profile.email.isEmpty) {
      _validationErrors['email'] = 'Email is required';
      _logger.w('Validation error: Email is empty');
    } else if (!RegExp(r'^[\w-\.]+@([\w-]+\.)+[\w-]{2,4}$').hasMatch(profile.email)) {
      _validationErrors['email'] = 'Please enter a valid email';
      _logger.w('Validation error: Invalid email format');
    }
    if (profile.password.isEmpty) {
      _validationErrors['password'] = 'Password is required';
      _logger.w('Validation error: Password is empty');
    } else if (profile.password.length < 6) {
      _validationErrors['password'] = 'Password must be at least 6 characters';
      _logger.w('Validation error: Password too short');
    }
    if (profile.mainContactNumber.isEmpty) {
      _validationErrors['mainContactNumber'] = 'Main contact number is required';
      _logger.w('Validation error: Main contact number is empty');
    }
    if (profile.emergencyContactNumber.isEmpty) {
      _validationErrors['emergencyContactNumber'] = 'Emergency contact number is required';
      _logger.w('Validation error: Emergency contact number is empty');
    }

    // Business Information
    if (profile.businessTimings.isEmpty) {
      _validationErrors['businessTimings'] = 'Business timings is required';
      _logger.w('Validation error: Business timings is empty');
    }
    if (profile.businessDays.isEmpty) {
      _validationErrors['businessDays'] = 'At least one business day is required';
      _logger.w('Validation error: No business days selected');
    }
    if (profile.sampleCollectionMethod.isEmpty) {
      _validationErrors['sampleCollectionMethod'] = 'Sample collection method is required';
      _logger.w('Validation error: Sample collection method not selected');
    }
    if (profile.homeCollectionGeoLimit.isEmpty) {
      _validationErrors['homeCollectionGeoLimit'] = 'Home collection geo limit is required';
      _logger.w('Validation error: Home collection geo limit is empty');
    }
    if (profile.testTypes.isEmpty) {
      _validationErrors['testTypes'] = 'At least one test type is required';
      _logger.w('Validation error: No test types selected');
    }

    // Location Information
    if (profile.address.isEmpty) {
      _validationErrors['address'] = 'Address is required';
      _logger.w('Validation error: Address is empty');
    }
    if (profile.state.isEmpty) {
      _validationErrors['state'] = 'State is required';
      _logger.w('Validation error: State not selected');
    }
    if (profile.city.isEmpty) {
      _validationErrors['city'] = 'City is required';
      _logger.w('Validation error: City not selected');
    }
    if (profile.pincode.isEmpty) {
      _validationErrors['pincode'] = 'Pincode is required';
      _logger.w('Validation error: Pincode is empty');
    } else if (!RegExp(r'^\d{6}$').hasMatch(profile.pincode)) {
      _validationErrors['pincode'] = 'Please enter a valid 6-digit pincode';
      _logger.w('Validation error: Invalid pincode format');
    }
    if (profile.nearbyLandmark.isEmpty) {
      _validationErrors['nearbyLandmark'] = 'Nearby landmark is required';
      _logger.w('Validation error: Nearby landmark is empty');
    }
    if (profile.floor.isEmpty) {
      _validationErrors['floor'] = 'Floor is required';
      _logger.w('Validation error: Floor is empty');
    }
    if (profile.location.isEmpty) {
      _validationErrors['location'] = 'Location is required';
      _logger.w('Validation error: Location is empty');
    }

    // Document Validation
    if (regulatoryComplianceFile == null) {
      _validationErrors['regulatoryCompliance'] = 'Regulatory compliance document is required';
      _logger.w('Validation error: Regulatory compliance document not uploaded');
    }
    if (qualityAssuranceFile == null) {
      _validationErrors['qualityAssurance'] = 'Quality assurance document is required';
      _logger.w('Validation error: Quality assurance document not uploaded');
    }
    if (centerPhotoFiles.isEmpty) {
      _validationErrors['centerPhotos'] = 'At least one center photo is required';
      _logger.w('Validation error: No center photos uploaded');
    }

    if (_validationErrors.isNotEmpty) {
      _logger.e('Validation failed with ${_validationErrors.length} errors:');
      _validationErrors.forEach((key, value) {
        _logger.e('$key: $value');
      });
    } else {
      _logger.i('All validations passed successfully');
    }

    notifyListeners();
    return _validationErrors.isEmpty;
  }

  // Get formatted error message for display
  String getFormattedErrorMessage() {
    if (_validationErrors.isEmpty) return '';
    
    final buffer = StringBuffer();
    buffer.writeln('Please fix the following errors:');
    buffer.writeln();
    
    _validationErrors.forEach((key, value) {
      buffer.writeln('• $value');
    });
    
    return buffer.toString();
  }

  // Upload files to Firebase Storage and update profile with URLs
  Future<bool> _uploadFilesToStorage() async {
    try {
      _isLoading = true;
      notifyListeners();

      // Upload regulatory compliance file
      if (regulatoryComplianceFile != null) {
        final String url = await _storageService.uploadFile(
          regulatoryComplianceFile!,
          fileType: 'regulatory_compliance'
        );
        profile.regulatoryComplianceUrl = {
          'name': regulatoryComplianceFileName ?? 'Regulatory Compliance',
          'url': url
        };
        _logger.i('Regulatory compliance file uploaded: $url');
      }

      // Upload quality assurance file
      if (qualityAssuranceFile != null) {
        final String url = await _storageService.uploadFile(
          qualityAssuranceFile!,
          fileType: 'quality_assurance'
        );
        profile.qualityAssuranceUrl = {
          'name': qualityAssuranceFileName ?? 'Quality Assurance',
          'url': url
        };
        _logger.i('Quality assurance file uploaded: $url');
      }

      // Upload center photos
      if (centerPhotoFiles.isNotEmpty) {
        List<String> photoUrls = [];
        for (var photoData in centerPhotoFiles) {
          final File file = photoData['file'];
          final String url = await _storageService.uploadFile(
            file,
            fileType: 'center_photos'
          );
          photoUrls.add(url);
          _logger.i('Center photo uploaded: $url');
        }
        profile.centerPhotosUrl = photoUrls.join(',');
      }

      return true;
    } catch (e) {
      _logger.e('Error uploading files: $e');
      _error = 'Failed to upload files: $e';
      notifyListeners();
      return false;
    }
  }

  // Submit profile
  Future<bool> submitProfile() async {
    try {
      // First validate the profile
      if (!validateProfile()) {
        _error = getFormattedErrorMessage();
        _logger.e('Submission failed due to validation errors:\n$_error');
        notifyListeners();
        return false;
      }

      _isLoading = true;
      _error = null;
      notifyListeners();

      // Upload files to Firebase Storage
      bool filesUploaded = await _uploadFilesToStorage();
      if (!filesUploaded) {
        _isLoading = false;
        _error = 'Failed to upload files, please try again';
        _logger.e('File upload failed: $_error');
        notifyListeners();
        return false;
      }

      // Create Vendor model
      final vendor = Vendor(
        vendorRole: 6, // Lab Test vendor role
        phoneNumber: profile.mainContactNumber,
        email: profile.email,
        password: profile.password,
      );

      // Log the profile data before submission
      _logger.i('Submitting diagnostic center profile: ${profile.toJson()}');
      _logger.i('Submitting vendor data: ${vendor.toJson()}');

      // Submit the profile with vendor data
      final success = await _labTestService.registerDiagnosticCenter(profile, vendor);
      
      _isLoading = false;
      if (!success) {
        _error = 'Failed to register diagnostic center. Please try again.';
        _logger.e('Registration failed: $_error');
      }
      notifyListeners();
      
      return success;
    } catch (e) {
      _isLoading = false;
      _error = 'An error occurred: $e';
      _logger.e('Exception during submission: $e');
      notifyListeners();
      return false;
    }
  }
} 