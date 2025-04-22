import 'dart:io';
import 'package:flutter/material.dart';
import 'package:vedika_healthcare/features/Vendor/DoctorConsultationVendor/Models/DoctorClinicProfile.dart';
import 'package:file_picker/file_picker.dart';
import 'package:vedika_healthcare/features/Vendor/DoctorConsultationVendor/Services/DoctorClinicService.dart';
import 'package:vedika_healthcare/features/Vendor/DoctorConsultationVendor/Services/DoctorClinicStorageService.dart';
import 'package:vedika_healthcare/shared/utils/state_city_data.dart';
import 'package:vedika_healthcare/features/Vendor/DoctorConsultationVendor/Models/Vendor.dart';

class DoctorClinicRegistrationViewModel extends ChangeNotifier {
  // Service instances
  final DoctorClinicService _service = DoctorClinicService();
  final DoctorClinicStorageService _storageService = DoctorClinicStorageService();

  DoctorClinicProfile _profile = DoctorClinicProfile(
    doctorName: '',
    gender: 'Male',
    email: '',
    password: '',
    confirmPassword: '',
    phoneNumber: '',
    profilePicture: '',
    medicalLicenseFile: [],
    licenseNumber: '',
    educationalQualifications: [],
    specializations: [],
    experienceYears: 0,
    languageProficiency: [],
    hasTelemedicineExperience: false,
    consultationFeesRange: '',
    consultationTimeSlots: [],
    consultationDays: [],
    consultationTypes: [],
    insurancePartners: [],
    address: '',
    state: '',
    city: '',
    pincode: '',
    nearbyLandmark: '',
    floor: '',
    hasLiftAccess: false,
    hasWheelchairAccess: false,
    hasParking: false,
    otherFacilities: [],
    clinicPhotos: [],
    location: '',
  );

  bool _isLoading = false;
  String? _error;
  bool _isSubmitSuccess = false;
  final List<Map<String, String>> _timeSlots = [];
  
  // Temporary holding for files before upload
  File? _profilePictureFile;
  String _profilePictureName = '';
  
  File? _medicalLicenseFile;
  String _medicalLicenseName = '';
  
  final List<Map<String, dynamic>> _clinicPhotoFiles = [];
  final List<Map<String, String>> _clinicPhotos = [];
  
  List<String> _availableCities = [];
  Map<String, String> _validationErrors = {};

  // Getters
  DoctorClinicProfile get profile => _profile;
  bool get isLoading => _isLoading;
  String? get error => _error;
  bool get isSubmitSuccess => _isSubmitSuccess;
  List<Map<String, String>> get timeSlots => _timeSlots;
  File? get profilePictureFile => _profilePictureFile;
  String get profilePictureName => _profilePictureName;
  File? get medicalLicenseFile => _medicalLicenseFile;
  String get medicalLicenseName => _medicalLicenseName;
  List<String> get availableCities => _availableCities;
  List<StateModel> get states => StateCityDataProvider.states;
  Map<String, String> get validationErrors => _validationErrors;
  List<Map<String, dynamic>> get clinicPhotoFiles => _clinicPhotoFiles;

  // Profile setters
  void setDoctorName(String value) {
    _profile = _profile.copyWith(doctorName: value);
    _clearValidationError('doctorName');
    notifyListeners();
  }

  void setGender(String value) {
    _profile = _profile.copyWith(gender: value);
    notifyListeners();
  }

  void setEmail(String value) {
    _profile = _profile.copyWith(email: value);
    _clearValidationError('email');
    notifyListeners();
  }

  void setPassword(String value) {
    _profile = _profile.copyWith(password: value);
    _clearValidationError('password');
    notifyListeners();
  }

  void setConfirmPassword(String value) {
    _profile = _profile.copyWith(confirmPassword: value);
    _clearValidationError('confirmPassword');
    notifyListeners();
  }

  void setPhoneNumber(String value) {
    _profile = _profile.copyWith(phoneNumber: value);
    _clearValidationError('phoneNumber');
    notifyListeners();
  }

  void setProfilePicture(File file, String fileName) {
    _profilePictureFile = file;
    _profilePictureName = fileName;
    // We'll set the actual URL after uploading to Firebase
    notifyListeners();
  }

  void setMedicalLicenseFile(File file, String fileName) {
    _medicalLicenseFile = file;
    _medicalLicenseName = fileName;
    // We'll set the actual URL after uploading to Firebase
    _clearValidationError('medicalLicenseFile');
    notifyListeners();
  }

  void setLicenseNumber(String value) {
    _profile = _profile.copyWith(licenseNumber: value);
    _clearValidationError('licenseNumber');
    notifyListeners();
  }

  void setExperienceYears(int value) {
    _profile = _profile.copyWith(experienceYears: value);
    _clearValidationError('experienceYears');
    notifyListeners();
  }

  void setEducationalQualifications(List<String> value) {
    _profile = _profile.copyWith(educationalQualifications: value);
    _clearValidationError('educationalQualifications');
    notifyListeners();
  }

  void setSpecializations(List<String> value) {
    _profile = _profile.copyWith(specializations: value);
    _clearValidationError('specializations');
    notifyListeners();
  }

  void setLanguageProficiency(List<String> value) {
    _profile = _profile.copyWith(languageProficiency: value);
    notifyListeners();
  }

  void setHasTelemedicineExperience(bool value) {
    _profile = _profile.copyWith(hasTelemedicineExperience: value);
    notifyListeners();
  }

  void setConsultationFeesRange(String value) {
    _profile = _profile.copyWith(consultationFeesRange: value);
    _clearValidationError('consultationFeesRange');
    notifyListeners();
  }

  void setConsultationDays(List<String> value) {
    _profile = _profile.copyWith(consultationDays: value);
    _clearValidationError('consultationDays');
    notifyListeners();
  }

  void setConsultationTypes(List<String> value) {
    _profile = _profile.copyWith(consultationTypes: value);
    _clearValidationError('consultationTypes');
    notifyListeners();
  }

  void setInsurancePartners(List<String> value) {
    _profile = _profile.copyWith(insurancePartners: value);
    notifyListeners();
  }

  void setAddress(String value) {
    _profile = _profile.copyWith(address: value);
    _clearValidationError('address');
    notifyListeners();
  }

  void setState(String value) {
    _profile = _profile.copyWith(state: value);
    _availableCities = StateCityDataProvider.getCities(value);
    if (_availableCities.isNotEmpty && (_profile.city.isEmpty || !_availableCities.contains(_profile.city))) {
      setCity(_availableCities.first);
    }
    _clearValidationError('state');
    notifyListeners();
  }

  void setCity(String value) {
    _profile = _profile.copyWith(city: value);
    _clearValidationError('city');
    notifyListeners();
  }

  void setPincode(String value) {
    _profile = _profile.copyWith(pincode: value);
    _clearValidationError('pincode');
    notifyListeners();
  }

  void setNearbyLandmark(String value) {
    _profile = _profile.copyWith(nearbyLandmark: value);
    _clearValidationError('nearbyLandmark');
    notifyListeners();
  }

  void setFloor(String value) {
    _profile = _profile.copyWith(floor: value);
    _clearValidationError('floor');
    notifyListeners();
  }

  void setLocation(String value) {
    _profile = _profile.copyWith(location: value);
    _clearValidationError('location');
    notifyListeners();
  }

  void setHasLiftAccess(bool value) {
    _profile = _profile.copyWith(hasLiftAccess: value);
    notifyListeners();
  }

  void setHasWheelchairAccess(bool value) {
    _profile = _profile.copyWith(hasWheelchairAccess: value);
    notifyListeners();
  }

  void setHasParking(bool value) {
    _profile = _profile.copyWith(hasParking: value);
    notifyListeners();
  }

  void setOtherFacilities(List<String> value) {
    _profile = _profile.copyWith(otherFacilities: value);
    notifyListeners();
  }

  void addClinicPhotoFile(File file, String fileName) {
    _clinicPhotoFiles.add({
      'file': file,
      'name': fileName
    });
    notifyListeners();
  }

  // Clear a specific validation error when field is updated
  void _clearValidationError(String field) {
    if (_validationErrors.containsKey(field)) {
      _validationErrors.remove(field);
    }
  }

  // Time slots management
  void addTimeSlot(String startTime, String endTime) {
    print("🕒 VM: Adding time slot $startTime - $endTime");
    _timeSlots.add({
      'start': startTime,
      'end': endTime,
    });
    _clearValidationError('consultationTimeSlots');
    print("🕒 VM: Time slots count after adding: ${_timeSlots.length}");
    notifyListeners();
  }

  void removeTimeSlot(int index) {
    print("🕒 VM: Removing time slot at index $index");
    _timeSlots.removeAt(index);
    print("🕒 VM: Time slots count after removing: ${_timeSlots.length}");
    notifyListeners();
  }

  void clearTimeSlots() {
    print("🕒 VM: Clearing all time slots");
    _timeSlots.clear();
    notifyListeners();
  }

  // Validate the entire profile
  bool validateProfile() {
    // Update consultation time slots before validation
    print("🕒 VM: Validating profile. Current time slots: ${_timeSlots.length}");
    
    // Copy time slots to profile
    _profile = _profile.copyWith(consultationTimeSlots: _timeSlots);
    print("🕒 VM: Updated profile.consultationTimeSlots, now contains: ${_profile.consultationTimeSlots.length} slots");
    
    _validationErrors = _service.validateProfile(_profile);
    
    if (_validationErrors.isNotEmpty) {
      print("🕒 VM: Validation errors found: ${_validationErrors.keys}");
    } else {
      print("🕒 VM: Validation successful, no errors found");
    }
    
    notifyListeners();
    return _validationErrors.isEmpty;
  }

  // Upload files to Firebase Storage and update profile with URLs
  Future<bool> _uploadFilesToStorage() async {
    try {
      _isLoading = true;
      notifyListeners();

      // Upload profile picture if available
      if (_profilePictureFile != null) {
        final String url = await _storageService.uploadFile(
          _profilePictureFile!,
          fileType: 'profile_pictures'
        );
        _profile = _profile.copyWith(profilePicture: url);
      }

      // Upload medical license if available
      if (_medicalLicenseFile != null) {
        final String url = await _storageService.uploadFile(
          _medicalLicenseFile!,
          fileType: 'medical_licenses'
        );
        _profile = _profile.copyWith(medicalLicenseFile: [
          {'name': _medicalLicenseName, 'url': url}
        ]);
      }

      // Upload clinic photos if available
      if (_clinicPhotoFiles.isNotEmpty) {
        List<Map<String, String>> uploadedPhotos = [];
        
        for (var photoData in _clinicPhotoFiles) {
          final File file = photoData['file'];
          final String name = photoData['name'];
          
          final String url = await _storageService.uploadFile(
            file,
            fileType: 'clinic_photos'
          );
          
          uploadedPhotos.add({
            'url': url,
            'name': name
          });
        }
        
        _clinicPhotos.addAll(uploadedPhotos);
        _profile = _profile.copyWith(clinicPhotos: _clinicPhotos);
      }

      return true;
    } catch (e) {
      print('Error uploading files: $e');
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
        _error = 'Please fix the errors before submitting';
        notifyListeners();
        return false;
      }

      _isLoading = true;
      _error = null;
      _isSubmitSuccess = false;
      notifyListeners();

      // Update consultation time slots
      _profile = _profile.copyWith(consultationTimeSlots: _timeSlots);

      // Upload files to Firebase Storage
      bool filesUploaded = await _uploadFilesToStorage();
      if (!filesUploaded) {
        _isLoading = false;
        _error = 'Failed to upload files, please try again';
        notifyListeners();
        return false;
      }

      // Create Vendor model
      final vendor = Vendor(
        vendorRole: 2, // Doctor/Clinic vendor role
        phoneNumber: _profile.phoneNumber,
        email: _profile.email,
        password: _profile.password,
      );

      // Submit the profile using the service
      final result = await _service.submitDoctorClinicProfile(_profile, vendor);
      
      _isLoading = false;
      _isSubmitSuccess = result;
      
      if (!result) {
        _error = 'Failed to submit profile, please try again';
      }
      
      notifyListeners();
      return result;
    } catch (e) {
      _isLoading = false;
      _error = e.toString();
      _isSubmitSuccess = false;
      notifyListeners();
      return false;
    }
  }

  // Reset form
  void resetForm() {
    _profile = DoctorClinicProfile(
      doctorName: '',
      gender: 'Male',
      email: '',
      password: '',
      confirmPassword: '',
      phoneNumber: '',
      profilePicture: '',
      medicalLicenseFile: [],
      licenseNumber: '',
      educationalQualifications: [],
      specializations: [],
      experienceYears: 0,
      languageProficiency: [],
      hasTelemedicineExperience: false,
      consultationFeesRange: '',
      consultationTimeSlots: [],
      consultationDays: [],
      consultationTypes: [],
      insurancePartners: [],
      address: '',
      state: '',
      city: '',
      pincode: '',
      nearbyLandmark: '',
      floor: '',
      hasLiftAccess: false,
      hasWheelchairAccess: false,
      hasParking: false,
      otherFacilities: [],
      clinicPhotos: [],
      location: '',
    );
    _timeSlots.clear();
    _profilePictureFile = null;
    _profilePictureName = '';
    _medicalLicenseFile = null;
    _medicalLicenseName = '';
    _clinicPhotoFiles.clear();
    _clinicPhotos.clear();
    _availableCities = [];
    _error = null;
    _isSubmitSuccess = false;
    _validationErrors = {};
    notifyListeners();
  }

  // File handling methods
  Future<void> pickProfilePicture() async {
    try {
      final result = await FilePicker.platform.pickFiles(
        type: FileType.image,
        allowMultiple: false,
      );
      
      if (result != null && result.files.isNotEmpty) {
        final file = File(result.files.first.path!);
        final fileName = result.files.first.name;
        setProfilePicture(file, fileName);
      }
    } catch (e) {
      _error = 'Failed to pick profile picture: $e';
      notifyListeners();
    }
  }

  Future<void> pickMedicalLicense() async {
    try {
      final result = await FilePicker.platform.pickFiles(
        type: FileType.custom,
        allowedExtensions: ['pdf', 'jpg', 'jpeg', 'png'],
        allowMultiple: false,
      );
      
      if (result != null && result.files.isNotEmpty) {
        final file = File(result.files.first.path!);
        final fileName = result.files.first.name;
        setMedicalLicenseFile(file, fileName);
      }
    } catch (e) {
      _error = 'Failed to pick medical license: $e';
      notifyListeners();
    }
  }

  Future<void> pickClinicPhotos() async {
    try {
      final result = await FilePicker.platform.pickFiles(
        type: FileType.image,
        allowMultiple: true,
      );
      
      if (result != null && result.files.isNotEmpty) {
        for (var fileInfo in result.files) {
          final file = File(fileInfo.path!);
          final fileName = fileInfo.name;
          addClinicPhotoFile(file, fileName);
        }
      }
    } catch (e) {
      _error = 'Failed to pick clinic photos: $e';
      notifyListeners();
    }
  }

  void removeClinicPhotoFile(int index) {
    if (index >= 0 && index < _clinicPhotoFiles.length) {
      _clinicPhotoFiles.removeAt(index);
      notifyListeners();
    }
  }
} 