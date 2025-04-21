import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:logger/logger.dart';
import 'package:vedika_healthcare/features/Vendor/DoctorConsultationVendor/Models/DoctorClinicProfile.dart';

class DoctorClinicService {
  final Logger _logger = Logger(
    printer: PrettyPrinter(
      methodCount: 0,
      errorMethodCount: 5,
      lineLength: 50,
      colors: true,
      printEmojis: true,
      printTime: true,
    ),
  );

  /// Submit a doctor clinic profile to the server
  /// Returns a Future<bool> indicating success or failure
  Future<bool> submitDoctorClinicProfile(DoctorClinicProfile profile) async {
    try {
      // Log the profile data being submitted
      _logger.i('📝 Submitting doctor clinic profile data:');
      final profileJson = _formatJson(profile.toJson());
      _logger.i(profileJson);

      // Simulate API call with a delay
      await Future.delayed(const Duration(seconds: 2));

      // In a real implementation, this would be an API call
      // final response = await _dio.post(
      //   ApiEndpoints.submitDoctorProfile,
      //   data: profile.toJson(),
      // );

      // Log success
      _logger.i('✅ Doctor clinic profile submitted successfully!');
      
      return true;
    } catch (e) {
      // Log error
      _logger.e('❌ Error submitting doctor clinic profile: $e');
      return false;
    }
  }

  /// Format JSON for prettier logging
  String _formatJson(Map<String, dynamic> json) {
    const JsonEncoder encoder = JsonEncoder.withIndent('  ');
    return encoder.convert(json);
  }

  /// Validate the doctor clinic profile data
  /// Returns a Map<String, String> of field names and error messages
  Map<String, String> validateProfile(DoctorClinicProfile profile) {
    final Map<String, String> errors = {};

    // Basic information validation
    if (profile.doctorName.isEmpty) errors['doctorName'] = 'Doctor name is required';
    if (profile.email.isEmpty) errors['email'] = 'Email is required';
    if (!_isValidEmail(profile.email)) errors['email'] = 'Invalid email format';
    if (profile.password.isEmpty) errors['password'] = 'Password is required';
    if (profile.password.length < 6) errors['password'] = 'Password must be at least 6 characters';
    if (profile.confirmPassword != profile.password) errors['confirmPassword'] = 'Passwords do not match';
    if (profile.phoneNumber.isEmpty) errors['phoneNumber'] = 'Phone number is required';
    if (profile.licenseNumber.isEmpty) errors['licenseNumber'] = 'License number is required';
    
    // Professional details validation
    if (profile.experienceYears <= 0) errors['experienceYears'] = 'Experience years should be greater than 0';
    if (profile.educationalQualifications.isEmpty) errors['educationalQualifications'] = 'At least one qualification is required';
    if (profile.specializations.isEmpty) errors['specializations'] = 'At least one specialization is required';
    
    // Consultation details validation
    if (profile.consultationFeesRange.isEmpty) errors['consultationFeesRange'] = 'Consultation fees range is required';
    if (profile.consultationTypes.isEmpty) errors['consultationTypes'] = 'At least one consultation type is required';
    if (profile.consultationDays.isEmpty) errors['consultationDays'] = 'At least one consultation day is required';
    if (profile.consultationTimeSlots.isEmpty) errors['consultationTimeSlots'] = 'At least one time slot is required';
    
    // Location validation
    if (profile.address.isEmpty) errors['address'] = 'Address is required';
    if (profile.state.isEmpty) errors['state'] = 'State is required';
    if (profile.city.isEmpty) errors['city'] = 'City is required';
    if (profile.pincode.isEmpty) errors['pincode'] = 'Pincode is required';
    if (profile.pincode.length != 6 || !RegExp(r'^[0-9]+$').hasMatch(profile.pincode)) {
      errors['pincode'] = 'Pincode must be 6 digits';
    }
    
    if (errors.isNotEmpty) {
      _logger.w('⚠️ Validation errors found: ${errors.length}');
      _logger.w(errors);
    } else {
      _logger.i('✓ All validation passed');
    }
    
    return errors;
  }

  bool _isValidEmail(String email) {
    return RegExp(r'^[\w-\.]+@([\w-]+\.)+[\w-]{2,4}$').hasMatch(email);
  }
} 