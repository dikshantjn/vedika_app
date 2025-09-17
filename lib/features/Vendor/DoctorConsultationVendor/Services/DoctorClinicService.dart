import 'dart:convert';
import 'package:logger/logger.dart';
import 'package:vedika_healthcare/core/auth/data/services/StorageService.dart';
import 'package:vedika_healthcare/core/constants/ApiEndpoints.dart';
import 'package:vedika_healthcare/features/Vendor/DoctorConsultationVendor/Models/DoctorClinicProfile.dart';
import 'package:vedika_healthcare/features/Vendor/DoctorConsultationVendor/Models/Vendor.dart';
import 'package:vedika_healthcare/features/Vendor/DoctorConsultationVendor/Models/DoctorClinicProfileFixed.dart';
import 'package:vedika_healthcare/features/Vendor/Registration/Services/VendorLoginService.dart';
import 'package:dio/dio.dart';


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

  final Dio _dio = Dio();
  final StorageService _storageService = StorageService();
  final VendorLoginService _vendorLoginService = VendorLoginService();

  // Constructor to initialize Dio with options
  DoctorClinicService() {
    _dio.options = BaseOptions(
      connectTimeout: const Duration(seconds: 30),
      receiveTimeout: const Duration(seconds: 30),
      headers: {
        'Content-Type': 'application/json',
        'Accept': 'application/json',
      },
    );
  }

  // Get vendor ID from secure storage
  Future<String?> _getVendorId() async {
    return await _vendorLoginService.getVendorId();
  }

  /// Submit a doctor clinic profile to the server
  /// Returns a Future<bool> indicating success or failure
  Future<bool> submitDoctorClinicProfile(DoctorClinicProfile profile, Vendor vendor) async {
    try {
      // Log the profile data being submitted
      _logger.i('📝 Submitting doctor clinic profile data:');
      final profileJson = _formatJson(profile.toJson());
      _logger.i(profileJson);
      
      // Prepare the request payload with both vendor and clinic data
      final Map<String, dynamic> requestData = {
        'vendor': vendor.toJson(),
        'clinic': profile.toJson(),
      };
      
      _logger.i('📝 Complete request payload:');
      _logger.i(_formatJson(requestData));

      // Make the actual API call
      final response = await _dio.post(
        ApiEndpoints.registerClinic,
        data: requestData,
      );
      
      // Check if the response was successful
      if (response.statusCode == 200 || response.statusCode == 201) {
        _logger.i('✅ Doctor clinic profile submitted successfully!');
        
        // Store vendor ID if returned
        if (response.data != null && response.data['vendor'] != null) {
          final vendorId = response.data['vendor']['vendorId'];
          final generatedId = response.data['vendor']['generatedId'];

          
          _logger.i('✅ Stored vendor ID: $vendorId and generated ID: $generatedId');
        }
        
        return true;
      } else {
        _logger.e('❌ Failed to submit profile. Status code: ${response.statusCode}');
        return false;
      }
    } catch (e) {
      // Log error
      _logger.e('❌ Error submitting doctor clinic profile: $e');
      
      // Provide more specific error messages from the API response if available
      if (e is DioException) {
        if (e.response != null) {
          _logger.e('Response data: ${e.response?.data}');
          _logger.e('Response status code: ${e.response?.statusCode}');
        }
        
        if (e.type == DioExceptionType.connectionTimeout) {
          _logger.e('Connection timeout. Please check your internet connection.');
        } else if (e.type == DioExceptionType.receiveTimeout) {
          _logger.e('Receive timeout. Server took too long to respond.');
        } else if (e.type == DioExceptionType.connectionError) {
          _logger.e('Connection error. Please check your internet connection.');
        }
      }
      
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
    if (profile.phoneNumber.isEmpty) errors['phoneNumber'] = 'Contact number is required';
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
  
  /// Get total number of patients for a doctor
  Future<int> getTotalPatients(String vendorId) async {
    try {
      // In a real implementation, this would be an API call
      // final response = await _dio.get(
      //   '${ApiEndpoints.baseUrl}/doctors/$vendorId/patients/count',
      // );
      // return response.data['totalPatients'];
      
      // For now, return mock data
      await Future.delayed(const Duration(milliseconds: 500));
      return 185;
    } catch (e) {
      _logger.e('Error fetching total patients: $e');
      return 0;
    }
  }
  
  /// Get total number of appointments for a doctor
  Future<int> getTotalAppointments(String vendorId) async {
    try {
      // In a real implementation, this would be an API call
      // final response = await _dio.get(
      //   '${ApiEndpoints.baseUrl}/doctors/$vendorId/appointments/count',
      // );
      // return response.data['totalAppointments'];
      
      // For now, return mock data
      await Future.delayed(const Duration(milliseconds: 500));
      return 27;
    } catch (e) {
      _logger.e('Error fetching total appointments: $e');
      return 0;
    }
  }
  
  /// Get completion rate (percentage of completed appointments)
  Future<double> getCompletionRate(String vendorId) async {
    try {
      // In a real implementation, this would be an API call
      // final response = await _dio.get(
      //   '${ApiEndpoints.baseUrl}/doctors/$vendorId/completion-rate',
      // );
      // return response.data['completionRate'];
      
      // For now, return mock data
      await Future.delayed(const Duration(milliseconds: 500));
      return 92.0;
    } catch (e) {
      _logger.e('Error fetching completion rate: $e');
      return 0.0;
    }
  }
  
  /// Get doctor rating
  Future<double> getDoctorRating(String vendorId) async {
    try {
      // In a real implementation, this would be an API call
      // final response = await _dio.get(
      //   '${ApiEndpoints.baseUrl}/doctors/$vendorId/rating',
      // );
      // return response.data['rating'];
      
      // For now, return mock data
      await Future.delayed(const Duration(milliseconds: 500));
      return 4.7;
    } catch (e) {
      _logger.e('Error fetching doctor rating: $e');
      return 0.0;
    }
  }
  
  /// Get review count
  Future<int> getReviewCount(String vendorId) async {
    try {
      // In a real implementation, this would be an API call
      // final response = await _dio.get(
      //   '${ApiEndpoints.baseUrl}/doctors/$vendorId/reviews/count',
      // );
      // return response.data['reviewCount'];
      
      // For now, return mock data
      await Future.delayed(const Duration(milliseconds: 500));
      return 32;
    } catch (e) {
      _logger.e('Error fetching review count: $e');
      return 0;
    }
  }
  
  /// Get clinic profile by vendor ID
  Future<DoctorClinicProfile?> getClinicProfile(String vendorId) async {
    try {
      _logger.i('📝 Fetching clinic profile for vendorId: $vendorId');
      
      final response = await _dio.get(
        '${ApiEndpoints.getClinicProfile}/$vendorId',
      );
      
      if (response.statusCode == 200) {
        _logger.i('✅ Clinic profile fetched successfully!');
        
        // Convert response data to DoctorClinicProfile object
        if (response.data != null && response.data['clinic'] != null) {
          final clinicData = response.data['clinic'];
          return DoctorClinicProfileFixed.fromJson(clinicData);
        } else if (response.data != null) {
          // Some APIs might return the clinic data directly without nesting
          return DoctorClinicProfileFixed.fromJson(response.data);
        }
      }
      
      _logger.e('❌ Failed to fetch clinic profile. Status code: ${response.statusCode}');
      return null;
    } catch (e) {
      _logger.e('❌ Error fetching clinic profile: $e');
      
      if (e is DioException) {
        if (e.response != null) {
          _logger.e('Response data: ${e.response?.data}');
          _logger.e('Response status code: ${e.response?.statusCode}');
        }
      }
      
      return null;
    }
  }
  
  /// Update clinic profile
  Future<bool> updateClinicProfile(
    String vendorId, 
    DoctorClinicProfile profile, 
    {List<Map<String, dynamic>>? formattedTimeSlots}
  ) async {
    try {
      _logger.i('📝 Updating clinic profile for vendorId: $vendorId');
      final profileJson = _formatJson(profile.toJson());
      _logger.i(profileJson);
      
      // Create a clean version of the profile data for the API
      final Map<String, dynamic> cleanedData = profile.toJson();
      
      // Add formatted time slots if provided
      if (formattedTimeSlots != null) {
        cleanedData['formattedTimeSlots'] = formattedTimeSlots;
      }
      
      // Log profile picture to ensure it's included
      if (profile.profilePicture.isNotEmpty) {
        _logger.i('📝 Profile picture URL included: ${profile.profilePicture}');
      }
      
      final response = await _dio.put(
        '${ApiEndpoints.updateClinicProfile}/$vendorId',
        data: cleanedData,
      );
      
      if (response.statusCode == 200 || response.statusCode == 201) {
        _logger.i('✅ Clinic profile updated successfully!');
        return true;
      } else {
        _logger.e('❌ Failed to update clinic profile. Status code: ${response.statusCode}');
        return false;
      }
    } catch (e) {
      _logger.e('❌ Error updating clinic profile: $e');
      
      if (e is DioException) {
        if (e.response != null) {
          _logger.e('Response data: ${e.response?.data}');
          _logger.e('Response status code: ${e.response?.statusCode}');
        }
        
        if (e.type == DioExceptionType.connectionTimeout) {
          _logger.e('Connection timeout. Please check your internet connection.');
        } else if (e.type == DioExceptionType.receiveTimeout) {
          _logger.e('Receive timeout. Server took too long to respond.');
        } else if (e.type == DioExceptionType.connectionError) {
          _logger.e('Connection error. Please check your internet connection.');
        }
      }
      
      return false;
    }
  }

  // Get the profile of the currently logged in doctor
  Future<DoctorClinicProfile?> getCurrentDoctorProfile() async {
    try {
      _logger.i('📝 Fetching profile for current doctor');
      
      // Get vendor ID from storage
      final String? vendorId = await _getVendorId();
      
      if (vendorId == null) {
        _logger.e('❌ No vendor ID found in storage');
        return null;
      }
      
      // Get the profile using the vendorId
      return await getClinicProfile(vendorId);
    } catch (e) {
      _logger.e('❌ Error fetching current doctor profile: $e');
      return null;
    }
  }

  /// Fetch health records for a specific appointment
  Future<Map<String, dynamic>?> getHealthRecordsByAppointmentId(String appointmentId) async {
    try {
      _logger.i('📝 Fetching health records for appointment: $appointmentId');
      
      final response = await _dio.get(
        '${ApiEndpoints.getHealthRecordsByAppointmentId}/$appointmentId',
      );
      
      if (response.statusCode == 200) {
        _logger.i('✅ Health records fetched successfully!');
        return response.data;
      }
      
      _logger.e('❌ Failed to fetch health records. Status code: ${response.statusCode}');
      return null;
    } catch (e) {
      _logger.e('❌ Error fetching health records: $e');
      
      if (e is DioException) {
        if (e.response != null) {
          _logger.e('Response data: ${e.response?.data}');
          _logger.e('Response status code: ${e.response?.statusCode}');
        }
      }
      
      return null;
    }
  }
}