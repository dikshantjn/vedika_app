import 'package:flutter/material.dart';
import 'package:vedika_healthcare/features/Vendor/DoctorConsultationVendor/Models/DoctorClinicProfile.dart';
import 'package:vedika_healthcare/features/Vendor/DoctorConsultationVendor/Services/DoctorClinicService.dart';
import 'package:vedika_healthcare/features/Vendor/Registration/Services/VendorLoginService.dart';
import 'package:logger/logger.dart';

class DoctorClinicProfileViewModel extends ChangeNotifier {
  final DoctorClinicService _doctorClinicService = DoctorClinicService();
  final VendorLoginService _loginService = VendorLoginService();
  final Logger _logger = Logger();

  DoctorClinicProfile? _profile;
  String? _error;
  bool _isLoading = false;
  bool _isEditing = false;

  // Controllers for form fields
  final TextEditingController doctorNameController = TextEditingController();
  final TextEditingController genderController = TextEditingController();
  final TextEditingController emailController = TextEditingController();
  final TextEditingController phoneNumberController = TextEditingController();
  final TextEditingController licenseNumberController = TextEditingController();
  final TextEditingController experienceYearsController = TextEditingController();
  final TextEditingController consultationFeesRangeController = TextEditingController();
  final TextEditingController addressController = TextEditingController();
  final TextEditingController stateController = TextEditingController();
  final TextEditingController cityController = TextEditingController();
  final TextEditingController pincodeController = TextEditingController();
  final TextEditingController nearbyLandmarkController = TextEditingController();
  final TextEditingController floorController = TextEditingController();
  final TextEditingController locationController = TextEditingController();

  // Getters
  DoctorClinicProfile? get profile => _profile;
  String? get error => _error;
  bool get isLoading => _isLoading;
  bool get isEditing => _isEditing;

  void toggleEditMode() {
    _isEditing = !_isEditing;
    notifyListeners();
  }

  Future<void> loadProfile() async {
    try {
      _isLoading = true;
      _error = null;
      notifyListeners();

      // Get vendor ID
      final String? vendorId = await _loginService.getVendorId();

      if (vendorId == null) {
        throw Exception('Vendor ID not found');
      }

      // Fetch the clinic profile from the API
      final profile = await _doctorClinicService.getClinicProfile(vendorId);
      
      if (profile != null) {
        _profile = profile;
        // Initialize controllers with profile data
        _initializeControllers();
        _logger.i('✅ Profile loaded successfully');
      } else {
        throw Exception('Failed to load clinic profile');
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

    doctorNameController.text = _profile!.doctorName;
    genderController.text = _profile!.gender;
    emailController.text = _profile!.email;
    phoneNumberController.text = _profile!.phoneNumber;
    licenseNumberController.text = _profile!.licenseNumber;
    experienceYearsController.text = _profile!.experienceYears.toString();
    consultationFeesRangeController.text = _profile!.consultationFeesRange;
    addressController.text = _profile!.address;
    stateController.text = _profile!.state;
    cityController.text = _profile!.city;
    pincodeController.text = _profile!.pincode;
    nearbyLandmarkController.text = _profile!.nearbyLandmark;
    floorController.text = _profile!.floor;
    locationController.text = _profile!.location;
  }

  // Update methods for different profile sections
  void updateBasicInfo({
    String? doctorName,
    String? gender,
    String? email,
    String? phoneNumber,
    String? licenseNumber,
  }) {
    if (_profile == null) return;

    _profile = _profile!.copyWith(
      doctorName: doctorName,
      gender: gender,
      email: email,
      phoneNumber: phoneNumber,
      licenseNumber: licenseNumber,
    );
    notifyListeners();
  }

  void updateProfessionalDetails({
    List<String>? educationalQualifications,
    List<String>? specializations,
    int? experienceYears,
    List<String>? languageProficiency,
    bool? hasTelemedicineExperience,
  }) {
    if (_profile == null) return;

    _profile = _profile!.copyWith(
      educationalQualifications: educationalQualifications,
      specializations: specializations,
      experienceYears: experienceYears,
      languageProficiency: languageProficiency,
      hasTelemedicineExperience: hasTelemedicineExperience,
    );
    notifyListeners();
  }

  void updateConsultationDetails({
    String? consultationFeesRange,
    List<Map<String, String>>? consultationTimeSlots,
    List<String>? consultationDays,
    List<String>? consultationTypes,
    List<String>? insurancePartners,
  }) {
    if (_profile == null) return;

    _profile = _profile!.copyWith(
      consultationFeesRange: consultationFeesRange,
      consultationTimeSlots: consultationTimeSlots,
      consultationDays: consultationDays,
      consultationTypes: consultationTypes,
      insurancePartners: insurancePartners,
    );
    notifyListeners();
  }

  void updateLocationDetails({
    String? address,
    String? state,
    String? city,
    String? pincode,
    String? nearbyLandmark,
    String? floor,
    bool? hasLiftAccess,
    bool? hasWheelchairAccess,
    bool? hasParking,
    List<String>? otherFacilities,
    String? location,
  }) {
    if (_profile == null) return;

    _profile = _profile!.copyWith(
      address: address,
      state: state,
      city: city,
      pincode: pincode,
      nearbyLandmark: nearbyLandmark,
      floor: floor,
      hasLiftAccess: hasLiftAccess,
      hasWheelchairAccess: hasWheelchairAccess,
      hasParking: hasParking,
      otherFacilities: otherFacilities,
      location: location,
    );
    notifyListeners();
  }

  void updateClinicPhotos(List<Map<String, String>> clinicPhotos) {
    if (_profile == null) return;

    _profile = _profile!.copyWith(clinicPhotos: clinicPhotos);
    notifyListeners();
  }

  void updateProfilePicture(String profilePicture) {
    if (_profile == null) return;

    _profile = _profile!.copyWith(profilePicture: profilePicture);
    notifyListeners();
  }

  void updateMedicalLicenseFile(List<Map<String, String>> medicalLicenseFile) {
    if (_profile == null) return;

    _profile = _profile!.copyWith(medicalLicenseFile: medicalLicenseFile);
    notifyListeners();
  }

  // Convert time slots to the API expected format
  List<Map<String, dynamic>> _formatTimeSlots(List<Map<String, String>> timeSlots) {
    return timeSlots.map((slot) {
      return {
        'start': slot['startTime'] ?? '',
        'end': slot['endTime'] ?? ''
      };
    }).toList();
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
      
      // Get vendor ID
      final String? vendorId = await _loginService.getVendorId();
      
      if (vendorId == null) {
        throw Exception('Vendor ID not found');
      }
      
      // Create a copy of the profile with time slots in the right format for the API
      // and make sure to preserve the profile picture that might have been updated
      final updatedProfile = _profile!.copyWith(
        consultationTimeSlots: _profile!.consultationTimeSlots,
        profilePicture: _profile!.profilePicture // Ensure profile picture is included
      );
      
      // Update the profile using the API
      final success = await _doctorClinicService.updateClinicProfile(
        vendorId, 
        updatedProfile, 
        formattedTimeSlots: _formatTimeSlots(updatedProfile.consultationTimeSlots)
      );
      
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
      doctorName: doctorNameController.text,
      gender: genderController.text,
      email: emailController.text,
      phoneNumber: phoneNumberController.text,
      licenseNumber: licenseNumberController.text,
      experienceYears: int.tryParse(experienceYearsController.text) ?? _profile!.experienceYears,
      consultationFeesRange: consultationFeesRangeController.text,
      address: addressController.text,
      state: stateController.text,
      city: cityController.text,
      pincode: pincodeController.text,
      nearbyLandmark: nearbyLandmarkController.text,
      floor: floorController.text,
      location: locationController.text,
      profilePicture: _profile!.profilePicture // Preserve profile picture during controller update
    );
  }

  @override
  void dispose() {
    // Dispose controllers
    doctorNameController.dispose();
    genderController.dispose();
    emailController.dispose();
    phoneNumberController.dispose();
    licenseNumberController.dispose();
    experienceYearsController.dispose();
    consultationFeesRangeController.dispose();
    addressController.dispose();
    stateController.dispose();
    cityController.dispose();
    pincodeController.dispose();
    nearbyLandmarkController.dispose();
    floorController.dispose();
    locationController.dispose();
    super.dispose();
  }
} 