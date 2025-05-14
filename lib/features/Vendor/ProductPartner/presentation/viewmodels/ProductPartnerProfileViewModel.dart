import 'dart:io';
import 'package:flutter/material.dart';
import '../../data/services/ProductPartnerProfileService.dart';
import '../../data/models/product_partner_model.dart';

class ProductPartnerProfileViewModel extends ChangeNotifier {
  final ProductPartnerProfileService _service = ProductPartnerProfileService();
  bool _isLoading = false;
  bool _isEditing = false;
  String? _error;
  ProductPartner? _profile;
  List<Map<String, dynamic>> _licenseDocuments = [];
  List<Map<String, dynamic>> _additionalPhotos = [];

  // Text controllers
  final TextEditingController brandNameController = TextEditingController();
  final TextEditingController companyLegalNameController = TextEditingController();
  final TextEditingController gstNumberController = TextEditingController();
  final TextEditingController panCardNumberController = TextEditingController();
  final TextEditingController bankAccountNumberController = TextEditingController();
  final TextEditingController addressController = TextEditingController();
  final TextEditingController cityController = TextEditingController();
  final TextEditingController stateController = TextEditingController();
  final TextEditingController pincodeController = TextEditingController();

  // Getters
  bool get isLoading => _isLoading;
  bool get isEditing => _isEditing;
  String? get error => _error;
  ProductPartner? get profile => _profile;
  List<Map<String, dynamic>> get licenseDocuments => _licenseDocuments;
  List<Map<String, dynamic>> get additionalPhotos => _additionalPhotos;

  // Initialize the ViewModel with vendor ID
  Future<void> initialize(String vendorId) async {
    await loadProfile(vendorId);
  }

  Future<void> loadProfile(String vendorId) async {
    try {
      _isLoading = true;
      _error = null;
      notifyListeners();

      print('Loading profile for vendor: $vendorId');
      _profile = await _service.getProfile(vendorId);
      _initializeControllers();
      _loadDocuments();
      print('Profile loaded successfully');
    } catch (e) {
      print('Error loading profile: $e');
      _error = e.toString();
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  void _initializeControllers() {
    if (_profile != null) {
      brandNameController.text = _profile!.brandName;
      companyLegalNameController.text = _profile!.companyLegalName;
      gstNumberController.text = _profile!.gstNumber;
      panCardNumberController.text = _profile!.panCardNumber;
      bankAccountNumberController.text = _profile!.bankAccountNumber;
      addressController.text = _profile!.address;
      cityController.text = _profile!.city;
      stateController.text = _profile!.state;
      pincodeController.text = _profile!.pincode;
    }
  }

  void _loadDocuments() {
    if (_profile != null) {
      _licenseDocuments.clear();
      _additionalPhotos.clear();
      
      // Load license details
      for (var license in _profile!.licenseDetails) {
        _licenseDocuments.add({
          'name': license['name'] as String,
          'expiry': license['expiry'] as String,
          'number': license['number'] as String,
          'filePath': license['filePath'] as String,
        });
      }
    }
  }

  void toggleEditMode() {
    _isEditing = !_isEditing;
    notifyListeners();
  }

  void updateBasicInfo({
    String? brandName,
    String? companyLegalName,
    String? gstNumber,
    String? panCardNumber,
  }) {
    if (brandName != null) brandNameController.text = brandName;
    if (companyLegalName != null) companyLegalNameController.text = companyLegalName;
    if (gstNumber != null) gstNumberController.text = gstNumber;
    if (panCardNumber != null) panCardNumberController.text = panCardNumber;
    notifyListeners();
  }

  void updateBusinessInfo({
    String? bankAccountNumber,
  }) {
    if (bankAccountNumber != null) bankAccountNumberController.text = bankAccountNumber;
    notifyListeners();
  }

  void updateLocationInfo({
    String? address,
    String? state,
    String? city,
    String? pincode,
  }) {
    if (address != null) addressController.text = address;
    if (state != null) stateController.text = state;
    if (city != null) cityController.text = city;
    if (pincode != null) pincodeController.text = pincode;
    notifyListeners();
  }

  void addLicense(Map<String, dynamic> license) {
    _licenseDocuments.add(license);
    notifyListeners();
  }

  void removeLicense(int index) {
    _licenseDocuments.removeAt(index);
    notifyListeners();
  }

  Future<bool> uploadDocument(File file, String type, String name) async {
    try {
      if (_profile == null) {
        print('Cannot upload document: profile is null');
        return false;
      }

      print('Uploading document of type: $type, name: $name');
      final uploadedDoc = await _service.uploadDocument(
        file,
        _profile!.vendorId ?? '',
      );
      
      if (uploadedDoc != null) {
        print('Document uploaded successfully');
        if (type == 'license') {
          _licenseDocuments.add(uploadedDoc);
        } else {
          _additionalPhotos.add(uploadedDoc);
        }
        notifyListeners();
        return true;
      }
      print('Document upload failed: no response data');
      return false;
    } catch (e) {
      print('Error uploading document: $e');
      _error = e.toString();
      notifyListeners();
      return false;
    }
  }

  Future<bool> saveChanges() async {
    if (_profile == null) {
      print('Cannot save changes: Profile is null');
      return false;
    }

    try {
      print('Saving profile changes for vendor: ${_profile!.vendorId}');
      
      // Create a copy of the current profile with updated values
      final updatedProfile = ProductPartner(
        vendorId: _profile!.vendorId,
        brandName: brandNameController.text.isNotEmpty ? brandNameController.text : _profile!.brandName,
        companyLegalName: companyLegalNameController.text.isNotEmpty ? companyLegalNameController.text : _profile!.companyLegalName,
        gstNumber: gstNumberController.text.isNotEmpty ? gstNumberController.text : _profile!.gstNumber,
        panCardNumber: panCardNumberController.text.isNotEmpty ? panCardNumberController.text : _profile!.panCardNumber,
        bankAccountNumber: bankAccountNumberController.text.isNotEmpty ? bankAccountNumberController.text : _profile!.bankAccountNumber,
        address: addressController.text.isNotEmpty ? addressController.text : _profile!.address,
        pincode: pincodeController.text.isNotEmpty ? pincodeController.text : _profile!.pincode,
        city: cityController.text.isNotEmpty ? cityController.text : _profile!.city,
        state: stateController.text.isNotEmpty ? stateController.text : _profile!.state,
        email: _profile!.email,
        phoneNumber: _profile!.phoneNumber,
        profilePicture: _profile!.profilePicture,
        password: _profile!.password,
        location: _profile!.location,
        licenseDetails: _licenseDocuments.map((doc) => {
          'name': doc['name']?.toString() ?? '',
          'expiry': doc['expiry']?.toString() ?? '',
          'number': doc['number']?.toString() ?? '',
          'filePath': doc['filePath']?.toString() ?? '',
        }).toList(),
      );

      print('Updated profile data: ${updatedProfile.toJson()}');
      final success = await _service.updateProfile(updatedProfile);
      if (success) {
        _profile = updatedProfile;
        _isEditing = false;
        notifyListeners();
      }
      return success;
    } catch (e) {
      print('Error saving profile changes: $e');
      return false;
    }
  }

  void deleteDocument(String type, int index) {
    if (type == 'license') {
      _licenseDocuments.removeAt(index);
    } else if (type == 'photo') {
      _additionalPhotos.removeAt(index);
    }
    notifyListeners();
  }

  @override
  void dispose() {
    brandNameController.dispose();
    companyLegalNameController.dispose();
    gstNumberController.dispose();
    panCardNumberController.dispose();
    bankAccountNumberController.dispose();
    addressController.dispose();
    cityController.dispose();
    stateController.dispose();
    pincodeController.dispose();
    super.dispose();
  }
} 