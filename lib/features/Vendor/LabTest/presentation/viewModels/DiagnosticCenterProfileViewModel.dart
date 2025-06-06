import 'package:flutter/material.dart';
import 'package:vedika_healthcare/features/Vendor/LabTest/data/models/DiagnosticCenter.dart';
import 'package:vedika_healthcare/features/Vendor/LabTest/data/services/LabTestService.dart';
import 'package:vedika_healthcare/features/Vendor/LabTest/data/services/LabTestStorageService.dart';
import 'package:vedika_healthcare/features/Vendor/Registration/Services/VendorLoginService.dart';
import 'package:vedika_healthcare/features/Vendor/Service/VendorService.dart';
import 'package:logger/logger.dart';
import 'dart:io';
import 'package:file_picker/file_picker.dart';
import 'package:path/path.dart' as path;

class DiagnosticCenterProfileViewModel extends ChangeNotifier {
  final LabTestService _labTestService = LabTestService();
  final VendorLoginService _loginService = VendorLoginService();
  final VendorService _statusService = VendorService();
  final LabTestStorageService _storageService = LabTestStorageService();
  final Logger _logger = Logger();

  DiagnosticCenter? _profile;
  String? _error;
  bool _isLoading = false;
  bool _isEditing = false;
  bool _isServiceActive = false;
  bool _isLoadingStatus = false;
  String? _statusError;

  // Controllers for form fields
  final TextEditingController nameController = TextEditingController();
  final TextEditingController gstNumberController = TextEditingController();
  final TextEditingController panNumberController = TextEditingController();
  final TextEditingController ownerNameController = TextEditingController();
  final TextEditingController businessTimingsController = TextEditingController();
  final TextEditingController homeCollectionGeoLimitController = TextEditingController();
  final TextEditingController addressController = TextEditingController();
  final TextEditingController stateController = TextEditingController();
  final TextEditingController cityController = TextEditingController();
  final TextEditingController pincodeController = TextEditingController();
  final TextEditingController nearbyLandmarkController = TextEditingController();
  final TextEditingController floorController = TextEditingController();
  final TextEditingController mainContactNumberController = TextEditingController();
  final TextEditingController emergencyContactNumberController = TextEditingController();
  final TextEditingController emailController = TextEditingController();
  final TextEditingController websiteController = TextEditingController();
  final TextEditingController locationController = TextEditingController();

  // State variables
  String _sampleCollectionMethod = 'Both';
  List<String> _testTypes = [];
  List<String> _businessDays = [];
  List<String> _languagesSpoken = [];
  bool _emergencyHandlingFastTrack = false;
  bool _parkingAvailable = false;
  bool _wheelchairAccess = false;
  bool _liftAccess = false;
  bool _ambulanceServiceAvailable = false;
  Map<String, String> _regulatoryComplianceUrl = {};
  Map<String, String> _qualityAssuranceUrl = {};
  List<Map<String, String>> _filesAndImages = [];

  // Getters
  DiagnosticCenter? get profile => _profile;
  String? get error => _error;
  bool get isLoading => _isLoading;
  bool get isEditing => _isEditing;
  bool get isServiceActive => _isServiceActive;
  bool get isLoadingStatus => _isLoadingStatus;
  String? get statusError => _statusError;
  String get sampleCollectionMethod => _sampleCollectionMethod;
  List<String> get testTypes => _testTypes;
  List<String> get businessDays => _businessDays;
  List<String> get languagesSpoken => _languagesSpoken;
  bool get emergencyHandlingFastTrack => _emergencyHandlingFastTrack;
  bool get parkingAvailable => _parkingAvailable;
  bool get wheelchairAccess => _wheelchairAccess;
  bool get liftAccess => _liftAccess;
  bool get ambulanceServiceAvailable => _ambulanceServiceAvailable;
  Map<String, String> get regulatoryComplianceUrl => _regulatoryComplianceUrl;
  Map<String, String> get qualityAssuranceUrl => _qualityAssuranceUrl;
  List<Map<String, String>> get filesAndImages => _filesAndImages;

  void toggleEditMode() {
    _isEditing = !_isEditing;
    notifyListeners();
  }

  Future<void> loadServiceStatus() async {
    try {
      _isLoadingStatus = true;
      _statusError = null;
      notifyListeners();

      String? vendorId = await _loginService.getVendorId();
      if (vendorId == null) {
        throw Exception('Vendor ID not found');
      }
      
      final status = await _statusService.getVendorStatus(vendorId);
      
      _isServiceActive = status;
      _isLoadingStatus = false;
      notifyListeners();
    } catch (e) {
      _statusError = e.toString();
      _isLoadingStatus = false;
      notifyListeners();
    }
  }

  Future<void> loadProfile() async {
    try {
      _isLoading = true;
      _error = null;
      notifyListeners();

      // Get vendor ID
      final String? vendorId = await _loginService.getVendorId();
      
      _logger.i('Loading profile for vendor ID: $vendorId');

      if (vendorId == null) {
        throw Exception('Vendor ID not found');
      }

      // Fetch the profile from the API using the new getLabProfile method
      try {
        final profile = await _labTestService.getLabProfile(vendorId);
        
        _logger.i('Profile received: ${profile.toJson()}');
        
        if (profile != null) {
          _profile = profile;
          
          // Set default values for any null fields
          if (_profile!.regulatoryComplianceUrl == null) {
            _profile = _profile!.copyWith(regulatoryComplianceUrl: {});
          }
          if (_profile!.qualityAssuranceUrl == null) {
            _profile = _profile!.copyWith(qualityAssuranceUrl: {});
          }
          if (_profile!.testTypes == null) {
            _profile = _profile!.copyWith(testTypes: []);
          }
          if (_profile!.businessDays == null) {
            _profile = _profile!.copyWith(businessDays: []);
          }
          if (_profile!.languagesSpoken == null) {
            _profile = _profile!.copyWith(languagesSpoken: []);
          }
          if (_profile!.filesAndImages == null) {
            _profile = _profile!.copyWith(filesAndImages: []);
          }
          
          _initializeControllers();
          _initializeStateVariables();
          _logger.i('✅ Profile loaded successfully');
        } else {
          throw Exception('Received null profile from API');
        }
      } catch (e) {
        _logger.e('Error fetching profile: $e');
        throw Exception('Failed to fetch profile: $e');
      }

      _isLoading = false;
      notifyListeners();
    } catch (e) {
      _logger.e('Error loading profile: $e');
      _error = e.toString();
      _isLoading = false;
      notifyListeners();
    }
  }

  void _initializeControllers() {
    if (_profile == null) return;

    nameController.text = _profile!.name;
    gstNumberController.text = _profile!.gstNumber;
    panNumberController.text = _profile!.panNumber;
    ownerNameController.text = _profile!.ownerName;
    businessTimingsController.text = _profile!.businessTimings;
    homeCollectionGeoLimitController.text = _profile!.homeCollectionGeoLimit;
    addressController.text = _profile!.address;
    stateController.text = _profile!.state;
    cityController.text = _profile!.city;
    pincodeController.text = _profile!.pincode;
    nearbyLandmarkController.text = _profile!.nearbyLandmark;
    floorController.text = _profile!.floor;
    mainContactNumberController.text = _profile!.mainContactNumber;
    emergencyContactNumberController.text = _profile!.emergencyContactNumber;
    emailController.text = _profile!.email;
    websiteController.text = _profile!.website;
    locationController.text = _profile!.location;
  }

  void _initializeStateVariables() {
    if (_profile == null) return;

    _sampleCollectionMethod = _profile!.sampleCollectionMethod;
    _testTypes = List<String>.from(_profile!.testTypes ?? []);
    _businessDays = List<String>.from(_profile!.businessDays ?? []);
    _languagesSpoken = List<String>.from(_profile!.languagesSpoken ?? []);
    _emergencyHandlingFastTrack = _profile!.emergencyHandlingFastTrack;
    _parkingAvailable = _profile!.parkingAvailable;
    _wheelchairAccess = _profile!.wheelchairAccess;
    _liftAccess = _profile!.liftAccess;
    _ambulanceServiceAvailable = _profile!.ambulanceServiceAvailable;
    _regulatoryComplianceUrl = Map<String, String>.from(_profile!.regulatoryComplianceUrl ?? {});
    _qualityAssuranceUrl = Map<String, String>.from(_profile!.qualityAssuranceUrl ?? {});
    _filesAndImages = List<Map<String, String>>.from(_profile!.filesAndImages ?? []);
  }

  // Update methods for different profile sections
  void updateBasicInfo({
    String? name,
    String? gstNumber,
    String? panNumber,
    String? ownerName,
  }) {
    if (_profile == null) return;

    _profile = _profile!.copyWith(
      name: name,
      gstNumber: gstNumber,
      panNumber: panNumber,
      ownerName: ownerName,
    );
    notifyListeners();
  }

  void updateContactInfo({
    String? mainContactNumber,
    String? emergencyContactNumber,
    String? email,
    String? website,
  }) {
    if (_profile == null) return;

    _profile = _profile!.copyWith(
      mainContactNumber: mainContactNumber,
      emergencyContactNumber: emergencyContactNumber,
      email: email,
      website: website,
    );
    notifyListeners();
  }

  void updateLocationInfo({
    String? address,
    String? state,
    String? city,
    String? pincode,
    String? nearbyLandmark,
    String? floor,
    String? location,
  }) {
    if (_profile == null) return;

    if (address != null) addressController.text = address;
    if (state != null) stateController.text = state;
    if (city != null) cityController.text = city;
    if (pincode != null) pincodeController.text = pincode;
    if (nearbyLandmark != null) nearbyLandmarkController.text = nearbyLandmark;
    if (floor != null) floorController.text = floor;
    if (location != null) locationController.text = location;

    _profile = _profile!.copyWith(
      address: address ?? _profile!.address,
      state: state ?? _profile!.state,
      city: city ?? _profile!.city,
      pincode: pincode ?? _profile!.pincode,
      nearbyLandmark: nearbyLandmark ?? _profile!.nearbyLandmark,
      floor: floor ?? _profile!.floor,
      location: location ?? _profile!.location,
    );
    
    _logger.i('Updated location info: ${_profile!.location}');
    notifyListeners();
  }

  void updateBusinessInfo({
    String? businessTimings,
    String? homeCollectionGeoLimit,
    String? sampleCollectionMethod,
    List<String>? testTypes,
    List<String>? businessDays,
  }) {
    if (_profile == null) return;

    if (sampleCollectionMethod != null) {
      _sampleCollectionMethod = sampleCollectionMethod;
    }
    if (testTypes != null) {
      _testTypes = testTypes;
    }
    if (businessDays != null) {
      _businessDays = businessDays;
    }
    if (businessTimings != null) {
      businessTimingsController.text = businessTimings;
    }
    if (homeCollectionGeoLimit != null) {
      homeCollectionGeoLimitController.text = homeCollectionGeoLimit;
    }

    _profile = _profile!.copyWith(
      businessTimings: businessTimings ?? _profile!.businessTimings,
      homeCollectionGeoLimit: homeCollectionGeoLimit ?? _profile!.homeCollectionGeoLimit,
      sampleCollectionMethod: _sampleCollectionMethod,
      testTypes: _testTypes,
      businessDays: _businessDays,
    );
    notifyListeners();
  }

  void updateFacilities({
    bool? parkingAvailable,
    bool? wheelchairAccess,
    bool? liftAccess,
    bool? ambulanceServiceAvailable,
    bool? emergencyHandlingFastTrack,
    List<String>? languagesSpoken,
  }) {
    if (_profile == null) return;

    if (parkingAvailable != null) {
      _parkingAvailable = parkingAvailable;
    }
    if (wheelchairAccess != null) {
      _wheelchairAccess = wheelchairAccess;
    }
    if (liftAccess != null) {
      _liftAccess = liftAccess;
    }
    if (ambulanceServiceAvailable != null) {
      _ambulanceServiceAvailable = ambulanceServiceAvailable;
    }
    if (emergencyHandlingFastTrack != null) {
      _emergencyHandlingFastTrack = emergencyHandlingFastTrack;
    }
    if (languagesSpoken != null) {
      _languagesSpoken = languagesSpoken;
    }

    _profile = _profile!.copyWith(
      parkingAvailable: _parkingAvailable,
      wheelchairAccess: _wheelchairAccess,
      liftAccess: _liftAccess,
      ambulanceServiceAvailable: _ambulanceServiceAvailable,
      emergencyHandlingFastTrack: _emergencyHandlingFastTrack,
      languagesSpoken: _languagesSpoken,
    );
    notifyListeners();
  }

  void updateDocuments({
    Map<String, String>? regulatoryComplianceUrl,
    Map<String, String>? qualityAssuranceUrl,
    List<Map<String, String>>? filesAndImages,
  }) {
    if (_profile == null) return;

    _profile = _profile!.copyWith(
      regulatoryComplianceUrl: regulatoryComplianceUrl,
      qualityAssuranceUrl: qualityAssuranceUrl,
      filesAndImages: filesAndImages,
    );
    notifyListeners();
  }

  Future<bool> saveChanges() async {
    try {
      _isLoading = true;
      notifyListeners();

      // Update profile from controllers
      _updateProfileFromControllers();
      
      if (_profile == null) {
        throw Exception('Profile is null');
      }
      
      // Get vendor ID and ensure it's set in the profile
      final String? vendorId = await _loginService.getVendorId();
      
      if (vendorId == null) {
        throw Exception('Vendor ID not found');
      }
      
      // Set the vendorId in the profile object
      _profile = _profile!.copyWith(vendorId: vendorId);
      
      // Update the profile using the new updateLabProfile API
      final success = await _labTestService.updateLabProfile(_profile!);
      
      if (!success) {
        throw Exception('Failed to update profile');
      }

      _isLoading = false;
      _isEditing = false;
      notifyListeners();
      return true;
    } catch (e) {
      _logger.e('Error saving profile: $e');
      _error = e.toString();
      _isLoading = false;
      notifyListeners();
      return false;
    }
  }

  void _updateProfileFromControllers() {
    if (_profile == null) return;

    _profile = _profile!.copyWith(
      name: nameController.text,
      gstNumber: gstNumberController.text,
      panNumber: panNumberController.text,
      ownerName: ownerNameController.text,
      businessTimings: businessTimingsController.text,
      homeCollectionGeoLimit: homeCollectionGeoLimitController.text,
      address: addressController.text,
      state: stateController.text,
      city: cityController.text,
      pincode: pincodeController.text,
      nearbyLandmark: nearbyLandmarkController.text,
      floor: floorController.text,
      mainContactNumber: mainContactNumberController.text,
      emergencyContactNumber: emergencyContactNumberController.text,
      email: emailController.text,
      website: websiteController.text,
      location: locationController.text,
      sampleCollectionMethod: _sampleCollectionMethod,
      testTypes: _testTypes,
      businessDays: _businessDays,
      languagesSpoken: _languagesSpoken,
      emergencyHandlingFastTrack: _emergencyHandlingFastTrack,
      parkingAvailable: _parkingAvailable,
      wheelchairAccess: _wheelchairAccess,
      liftAccess: _liftAccess,
      ambulanceServiceAvailable: _ambulanceServiceAvailable,
      regulatoryComplianceUrl: _regulatoryComplianceUrl,
      qualityAssuranceUrl: _qualityAssuranceUrl,
      filesAndImages: _filesAndImages,
    );
  }

  // Delete document
  Future<void> deleteDocument(String documentType, int index) async {
    try {
      String? url;
      List<Map<String, String>> updatedDocuments;

      switch (documentType) {
        case 'regulatoryCompliance':
          url = _regulatoryComplianceUrl.values.elementAt(index);
          final updatedMap = Map<String, String>.from(_regulatoryComplianceUrl);
          updatedMap.remove(updatedMap.keys.elementAt(index));
          updateDocuments(regulatoryComplianceUrl: updatedMap);
          break;
        case 'qualityAssurance':
          url = _qualityAssuranceUrl.values.elementAt(index);
          final updatedMap = Map<String, String>.from(_qualityAssuranceUrl);
          updatedMap.remove(updatedMap.keys.elementAt(index));
          updateDocuments(qualityAssuranceUrl: updatedMap);
          break;
        case 'filesAndImages':
          url = _filesAndImages[index]['url'];
          updatedDocuments = List.from(_filesAndImages);
          updatedDocuments.removeAt(index);
          updateDocuments(filesAndImages: updatedDocuments);
          break;
      }

      if (url != null) {
        await _storageService.deleteFile(url);
      }
    } catch (e) {
      _logger.e('Error deleting document: $e');
      rethrow;
    }
  }

  // Upload document
  Future<void> uploadDocument(String documentType, File file, String name) async {
    try {
      final String downloadUrl = await _storageService.uploadFile(
        file,
        fileType: documentType,
      );

      final Map<String, String> newDocument = {
        'name': name,
        'url': downloadUrl,
      };

      switch (documentType) {
        case 'regulatoryCompliance':
          final updatedMap = Map<String, String>.from(_regulatoryComplianceUrl);
          updatedMap[name] = downloadUrl;
          updateDocuments(regulatoryComplianceUrl: updatedMap);
          break;
        case 'qualityAssurance':
          final updatedMap = Map<String, String>.from(_qualityAssuranceUrl);
          updatedMap[name] = downloadUrl;
          updateDocuments(qualityAssuranceUrl: updatedMap);
          break;
        case 'filesAndImages':
          final updatedDocuments = List<Map<String, String>>.from(_filesAndImages);
          updatedDocuments.add(newDocument);
          updateDocuments(filesAndImages: updatedDocuments);
          
          // If this is a profile photo, update centerPhotosUrl too
          if (name.toLowerCase().contains('profile') || name.toLowerCase().contains('avatar')) {
            updateProfilePhoto(downloadUrl);
          }
          break;
        case 'profilePhoto':
          // Special case for profile photo upload
          final updatedDocuments = List<Map<String, String>>.from(_filesAndImages);
          updatedDocuments.add(newDocument);
          updateDocuments(filesAndImages: updatedDocuments);
          
          // Update centerPhotosUrl with the new profile photo URL
          updateProfilePhoto(downloadUrl);
          break;
      }
    } catch (e) {
      _logger.e('Error uploading document: $e');
      rethrow;
    }
  }
  
  // Update profile photo URL
  void updateProfilePhoto(String photoUrl) {
    if (_profile == null) return;
    
    _logger.i('Updating profile photo URL: $photoUrl');
    
    // Update centerPhotosUrl with the new profile photo URL
    _profile = _profile!.copyWith(centerPhotosUrl: photoUrl);
    notifyListeners();
  }

  @override
  void dispose() {
    nameController.dispose();
    gstNumberController.dispose();
    panNumberController.dispose();
    ownerNameController.dispose();
    businessTimingsController.dispose();
    homeCollectionGeoLimitController.dispose();
    addressController.dispose();
    stateController.dispose();
    cityController.dispose();
    pincodeController.dispose();
    nearbyLandmarkController.dispose();
    floorController.dispose();
    mainContactNumberController.dispose();
    emergencyContactNumberController.dispose();
    emailController.dispose();
    websiteController.dispose();
    locationController.dispose();
    super.dispose();
  }
} 