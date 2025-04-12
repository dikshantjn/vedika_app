import 'package:flutter/foundation.dart';
import 'package:vedika_healthcare/features/Vendor/BloodBankAgencyVendor/data/services/BloodBankAgencyProfileService.dart';
import 'package:vedika_healthcare/features/Vendor/Registration/Services/VendorLoginService.dart';
import '../../data/model/BloodBankAgency.dart';
import 'package:logger/logger.dart';
import 'package:flutter/material.dart';

class BloodBankAgencyProfileViewModel extends ChangeNotifier {
  final Logger logger = Logger();
  final BloodBankAgencyProfileService _service = BloodBankAgencyProfileService();
  final VendorLoginService _loginService = VendorLoginService();

  // Text controllers for each field
  final TextEditingController agencyNameController = TextEditingController();
  final TextEditingController ownerNameController = TextEditingController();
  final TextEditingController gstNumberController = TextEditingController();
  final TextEditingController panNumberController = TextEditingController();
  final TextEditingController emailController = TextEditingController();
  final TextEditingController phoneNumberController = TextEditingController();
  final TextEditingController websiteController = TextEditingController();
  final TextEditingController completeAddressController = TextEditingController();
  final TextEditingController nearbyLandmarkController = TextEditingController();
  final TextEditingController stateController = TextEditingController();
  final TextEditingController cityController = TextEditingController();
  final TextEditingController pincodeController = TextEditingController();
  final TextEditingController googleMapsLocationController = TextEditingController();
  final TextEditingController languageProficiencyController = TextEditingController();
  final TextEditingController distanceLimitationsController = TextEditingController();
  final TextEditingController deliveryOperationalAreasController = TextEditingController();

  // Map to store service controllers
  final Map<String, TextEditingController> serviceControllers = {};

  BloodBankAgency? _agency;
  BloodBankAgency? get agency => _agency;

  bool _isLoading = false;
  bool get isLoading => _isLoading;

  String? _error;
  String? get error => _error;

  bool _isEditing = false;
  bool get isEditing => _isEditing;

  // Temporary agency for storing changes while editing
  BloodBankAgency? _tempAgency;

  // Getters
  String? get agencyName => _agency?.agencyName;
  String? get gstNumber => _agency?.gstNumber;
  String? get panNumber => _agency?.panNumber;
  String? get ownerName => _agency?.ownerName;
  String? get phoneNumber => _agency?.phoneNumber;
  String? get email => _agency?.email;
  String? get website => _agency?.website;
  String? get completeAddress => _agency?.completeAddress;
  String? get nearbyLandmark => _agency?.nearbyLandmark;
  String? get state => _agency?.state;
  String? get city => _agency?.city;
  String? get pincode => _agency?.pincode;
  String? get googleMapsLocation => _agency?.googleMapsLocation;
  List<String>? get deliveryOperationalAreas => _agency?.deliveryOperationalAreas;
  int? get distanceLimitations => _agency?.distanceLimitations;
  bool? get is24x7Operational => _agency?.is24x7Operational;
  bool? get isAllDaysWorking => _agency?.isAllDaysWorking;
  String? get languageProficiency => _agency?.languageProficiency;
  List<String>? get bloodServicesProvided => _agency?.bloodServicesProvided;
  List<String>? get plateletServicesProvided => _agency?.plateletServicesProvided;
  List<String>? get otherServicesProvided => _agency?.otherServicesProvided;
  bool? get acceptsOnlinePayment => _agency?.acceptsOnlinePayment;
  List<Map<String, String>>? get agencyPhotos => _agency?.agencyPhotos;
  List<Map<String, String>>? get licenseFiles => _agency?.licenseFiles;
  List<Map<String, String>>? get registrationCertificateFiles => _agency?.registrationCertificateFiles;

  // Load agency profile
  Future<void> loadAgencyProfile() async {
    String? vendorId = await _loginService.getVendorId();
    
    if (vendorId == null) {
      _error = "Failed to get vendor ID. Please log in again.";
      _isLoading = false;
      notifyListeners();
      return;
    }

    _isLoading = true;
    _error = null;
    notifyListeners();
    
    try {
      _agency = await _service.getAgencyProfile(vendorId);
      _tempAgency = _agency;
      
      // Update controllers with agency data
      _updateControllers();
      
      _error = null;
    } catch (e) {
      _error = e.toString();
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }
  
  // Update controllers with agency data
  void _updateControllers() {
    if (_agency != null) {
      agencyNameController.text = _agency!.agencyName;
      ownerNameController.text = _agency!.ownerName;
      gstNumberController.text = _agency!.gstNumber;
      panNumberController.text = _agency!.panNumber;
      emailController.text = _agency!.email;
      phoneNumberController.text = _agency!.phoneNumber;
      websiteController.text = _agency!.website ?? '';
      completeAddressController.text = _agency!.completeAddress;
      nearbyLandmarkController.text = _agency!.nearbyLandmark;
      stateController.text = _agency!.state;
      cityController.text = _agency!.city;
      pincodeController.text = _agency!.pincode;
      googleMapsLocationController.text = _agency!.googleMapsLocation;
      languageProficiencyController.text = _agency!.languageProficiency;
      distanceLimitationsController.text = _agency!.distanceLimitations.toString();
      deliveryOperationalAreasController.text = _agency!.deliveryOperationalAreas.join(', ');
      
      // Clear existing service controllers
      serviceControllers.clear();
    }
  }

  // Toggle edit mode
  void toggleEditMode() {
    _isEditing = !_isEditing;
    if (_isEditing) {
      _tempAgency = _agency?.copyWith();
      _updateControllers();
    } else {
      _tempAgency = null;
    }
    notifyListeners();
  }

  // Update basic info
  void updateBasicInfo({
    String? agencyName,
    String? gstNumber,
    String? panNumber,
    String? website,
    String? ownerName,
    String? completeAddress,
    String? city,
    String? state,
    String? pincode,
    String? phoneNumber,
    String? email,
    String? googleMapsLocation,
  }) {
    if (_tempAgency != null) {
      _tempAgency = _tempAgency!.copyWith(
        agencyName: agencyName ?? _tempAgency!.agencyName,
        gstNumber: gstNumber ?? _tempAgency!.gstNumber,
        panNumber: panNumber ?? _tempAgency!.panNumber,
        website: website ?? _tempAgency!.website,
        ownerName: ownerName ?? _tempAgency!.ownerName,
        completeAddress: completeAddress ?? _tempAgency!.completeAddress,
        city: city ?? _tempAgency!.city,
        state: state ?? _tempAgency!.state,
        pincode: pincode ?? _tempAgency!.pincode,
        phoneNumber: phoneNumber ?? _tempAgency!.phoneNumber,
        email: email ?? _tempAgency!.email,
        googleMapsLocation: googleMapsLocation ?? _tempAgency!.googleMapsLocation,
      );
      
      // Update the main agency object to reflect changes in UI
      _agency = _tempAgency;
      
      notifyListeners();
    }
  }

  // Update services
  void updateServices({
    List<String>? bloodServicesProvided,
    List<String>? plateletServicesProvided,
    List<String>? otherServicesProvided,
    bool? acceptsOnlinePayment,
  }) {
    if (_tempAgency != null) {
      _tempAgency = _tempAgency!.copyWith(
        bloodServicesProvided: bloodServicesProvided ?? _tempAgency!.bloodServicesProvided,
        plateletServicesProvided: plateletServicesProvided ?? _tempAgency!.plateletServicesProvided,
        otherServicesProvided: otherServicesProvided ?? _tempAgency!.otherServicesProvided,
        acceptsOnlinePayment: acceptsOnlinePayment ?? _tempAgency!.acceptsOnlinePayment,
      );
      
      // Update the main agency object to reflect changes in UI
      _agency = _tempAgency;
      
      notifyListeners();
    }
  }

  // Save changes
  Future<void> saveChanges() async {
    if (_tempAgency != null) {
      _isLoading = true;
      _error = null;
      notifyListeners();
      
      try {
        _agency = await _service.updateAgencyProfile(_tempAgency!);
        _isEditing = false;
        _tempAgency = null;
        _error = null;
      } catch (e) {
        _error = e.toString();
      } finally {
        _isLoading = false;
        notifyListeners();
      }
    }
  }

  // Cancel changes
  void cancelChanges() {
    _tempAgency = _agency?.copyWith();
    _isEditing = false;
    _updateControllers();
    notifyListeners();
  }

  // Update address
  void updateAddress({
    String? completeAddress,
    String? nearbyLandmark,
    String? state,
    String? city,
    String? pincode,
    String? googleMapsLocation,
  }) {
    if (_tempAgency != null) {
      _tempAgency = _tempAgency!.copyWith(
        completeAddress: completeAddress ?? _tempAgency!.completeAddress,
        nearbyLandmark: nearbyLandmark ?? _tempAgency!.nearbyLandmark,
        state: state ?? _tempAgency!.state,
        city: city ?? _tempAgency!.city,
        pincode: pincode ?? _tempAgency!.pincode,
        googleMapsLocation: googleMapsLocation ?? _tempAgency!.googleMapsLocation,
      );
      
      // Update the main agency object to reflect changes in UI
      _agency = _tempAgency;
      
      notifyListeners();
    }
  }

  // Update operational details
  void updateOperationalDetails({
    List<String>? deliveryOperationalAreas,
    int? distanceLimitations,
    bool? is24x7Operational,
    bool? isAllDaysWorking,
    String? languageProficiency,
  }) {
    if (_tempAgency != null) {
      _tempAgency = _tempAgency!.copyWith(
        deliveryOperationalAreas: deliveryOperationalAreas ?? _tempAgency!.deliveryOperationalAreas,
        distanceLimitations: distanceLimitations ?? _tempAgency!.distanceLimitations,
        is24x7Operational: is24x7Operational ?? _tempAgency!.is24x7Operational,
        isAllDaysWorking: isAllDaysWorking ?? _tempAgency!.isAllDaysWorking,
        languageProficiency: languageProficiency ?? _tempAgency!.languageProficiency,
      );
      
      // Update the main agency object to reflect changes in UI
      _agency = _tempAgency;
      
      notifyListeners();
    }
  }

  // Update documents
  void updateDocuments({
    List<Map<String, String>>? agencyPhotos,
    List<Map<String, String>>? licenseFiles,
    List<Map<String, String>>? registrationCertificateFiles,
  }) {
    if (_tempAgency != null) {
      _tempAgency = _tempAgency!.copyWith(
        agencyPhotos: agencyPhotos ?? _tempAgency!.agencyPhotos,
        licenseFiles: licenseFiles ?? _tempAgency!.licenseFiles,
        registrationCertificateFiles: registrationCertificateFiles ?? _tempAgency!.registrationCertificateFiles,
      );
      
      // Update the main agency object to reflect changes in UI
      _agency = _tempAgency;
      
      notifyListeners();
    }
  }

  // Clear error
  void clearError() {
    _error = null;
    notifyListeners();
  }
  
  @override
  void dispose() {
    // Dispose all controllers
    agencyNameController.dispose();
    ownerNameController.dispose();
    gstNumberController.dispose();
    panNumberController.dispose();
    emailController.dispose();
    phoneNumberController.dispose();
    websiteController.dispose();
    completeAddressController.dispose();
    nearbyLandmarkController.dispose();
    stateController.dispose();
    cityController.dispose();
    pincodeController.dispose();
    googleMapsLocationController.dispose();
    languageProficiencyController.dispose();
    distanceLimitationsController.dispose();
    deliveryOperationalAreasController.dispose();
    
    // Dispose service controllers
    serviceControllers.values.forEach((controller) => controller.dispose());
    serviceControllers.clear();
    
    super.dispose();
  }
} 