import 'dart:io';
import 'package:dio/dio.dart';
import 'package:logger/logger.dart';
import 'package:vedika_healthcare/core/constants/ApiEndpoints.dart';
import 'package:vedika_healthcare/features/Vendor/LabTest/data/models/DiagnosticCenter.dart';
import 'package:vedika_healthcare/features/Vendor/LabTest/data/services/LabTestStorageService.dart';
import 'package:vedika_healthcare/features/Vendor/DoctorConsultationVendor/Models/Vendor.dart';

class LabTestService {
  final Dio _dio = Dio();
  final Logger _logger = Logger();
  final LabTestStorageService _storageService = LabTestStorageService();

  // Upload a single file
  Future<String> uploadFile(File file) async {
    try {
      _logger.i('Uploading file: ${file.path}');
      final String url = await _storageService.uploadFile(
        file,
        fileType: 'documents'
      );
      _logger.i('File uploaded successfully: $url');
      return url;
    } catch (e) {
      _logger.e('Error uploading file: $e');
      throw Exception('Failed to upload file: $e');
    }
  }

  // Upload multiple files
  Future<List<String>> uploadMultipleFiles(List<File> files) async {
    try {
      _logger.i('Uploading ${files.length} files');
      final List<String> urls = await _storageService.uploadMultipleFiles(
        files,
        fileType: 'documents'
      );
      _logger.i('Files uploaded successfully: $urls');
      return urls;
    } catch (e) {
      _logger.e('Error uploading files: $e');
      throw Exception('Failed to upload files: $e');
    }
  }

  // Register diagnostic center
  Future<bool> registerDiagnosticCenter(DiagnosticCenter center, Vendor vendor) async {
    try {
      _logger.i('Registering diagnostic center: ${center.toJson()}');
      _logger.i('With vendor data: ${vendor.toJson()}');
      
      // Prepare the request body according to API requirements
      final requestBody = {
        'vendor': {
          'email': vendor.email,
          'phoneNumber': vendor.phoneNumber,
          'password': vendor.password,
          'vendorRole': vendor.vendorRole,
        },
        'diagnosticCenter': {
          'name': center.name,
          'gstNumber': center.gstNumber,
          'panNumber': center.panNumber,
          'ownerName': center.ownerName,
          'regulatoryComplianceUrl': center.regulatoryComplianceUrl,
          'qualityAssuranceUrl': center.qualityAssuranceUrl,
          'sampleCollectionMethod': center.sampleCollectionMethod,
          'testTypes': center.testTypes,
          'businessTimings': center.businessTimings,
          'businessDays': center.businessDays,
          'homeCollectionGeoLimit': center.homeCollectionGeoLimit,
          'emergencyHandlingFastTrack': center.emergencyHandlingFastTrack,
          'address': center.address,
          'state': center.state,
          'city': center.city,
          'pincode': center.pincode,
          'nearbyLandmark': center.nearbyLandmark,
          'floor': center.floor,
          'parkingAvailable': center.parkingAvailable,
          'wheelchairAccess': center.wheelchairAccess,
          'liftAccess': center.liftAccess,
          'ambulanceServiceAvailable': center.ambulanceServiceAvailable,
          'mainContactNumber': center.mainContactNumber,
          'emergencyContactNumber': center.emergencyContactNumber,
          'email': center.email,
          'website': center.website,
          'languagesSpoken': center.languagesSpoken,
          'centerPhotosUrl': center.centerPhotosUrl,
          'googleMapsLocationUrl': center.googleMapsLocationUrl,
          'password': center.password,
          'filesAndImages': center.filesAndImages,
          'location': center.location,
        }
      };

      _logger.i('Sending request body: $requestBody');
      
      final response = await _dio.post(
        ApiEndpoints.registerDiagnosticCenter,
        data: requestBody,
        options: Options(
          validateStatus: (status) {
            return status! < 500; // Accept all status codes less than 500
          },
        ),
      );

      if (response.statusCode == 200 || response.statusCode == 201) {
        _logger.i('Diagnostic center registered successfully with status code: ${response.statusCode}');
        return true;
      } else if (response.statusCode == 409) {
        String errorMessage = 'Registration failed: ';
        if (response.data != null && response.data['message'] != null) {
          errorMessage += response.data['message'];
        } else {
          errorMessage += 'Email or phone number is already registered';
        }
        _logger.e(errorMessage);
        throw Exception(errorMessage);
      } else {
        String errorMessage = 'Failed to register diagnostic center';
        if (response.data != null && response.data['message'] != null) {
          errorMessage += ': ${response.data['message']}';
        }
        _logger.e(errorMessage);
        throw Exception(errorMessage);
      }
    } catch (e) {
      if (e is DioException) {
        if (e.response?.statusCode == 409) {
          String errorMessage = 'Registration failed: ';
          if (e.response?.data != null && e.response?.data['message'] != null) {
            errorMessage += e.response?.data['message'];
          } else {
            errorMessage += 'Email or phone number is already registered';
          }
          _logger.e(errorMessage);
          throw Exception(errorMessage);
        }
      }
      _logger.e('Error registering diagnostic center: $e');
      throw Exception('Error registering diagnostic center: $e');
    }
  }

  // Get diagnostic center by ID
  Future<DiagnosticCenter> getDiagnosticCenterById(String id) async {
    try {
      _logger.i('Fetching diagnostic center with ID: $id');
      
      final response = await _dio.get(
        '${ApiEndpoints.getDiagnosticCenter}/$id',
      );

      if (response.statusCode == 200) {
        _logger.i('Diagnostic center fetched successfully');
        return DiagnosticCenter.fromJson(response.data);
      } else {
        _logger.e('Failed to get diagnostic center: ${response.statusCode}');
        throw Exception('Failed to get diagnostic center');
      }
    } catch (e) {
      _logger.e('Error getting diagnostic center: $e');
      throw Exception('Error getting diagnostic center: $e');
    }
  }

  // Update diagnostic center
  Future<bool> updateDiagnosticCenter(String id, DiagnosticCenter center) async {
    try {
      _logger.i('Updating diagnostic center: ${center.toJson()}');
      
      final response = await _dio.put(
        '${ApiEndpoints.updateDiagnosticCenter}/$id',
        data: center.toJson(),
      );

      if (response.statusCode == 200) {
        _logger.i('Diagnostic center updated successfully');
        return response.data['success'] ?? false;
      } else {
        _logger.e('Failed to update diagnostic center: ${response.statusCode}');
        throw Exception('Failed to update diagnostic center');
      }
    } catch (e) {
      _logger.e('Error updating diagnostic center: $e');
      throw Exception('Error updating diagnostic center: $e');
    }
  }

  // Delete diagnostic center
  Future<bool> deleteDiagnosticCenter(String id) async {
    try {
      _logger.i('Deleting diagnostic center with ID: $id');
      
      final response = await _dio.delete(
        '${ApiEndpoints.deleteDiagnosticCenter}/$id',
      );

      if (response.statusCode == 200) {
        _logger.i('Diagnostic center deleted successfully');
        return response.data['success'] ?? false;
      } else {
        _logger.e('Failed to delete diagnostic center: ${response.statusCode}');
        throw Exception('Failed to delete diagnostic center');
      }
    } catch (e) {
      _logger.e('Error deleting diagnostic center: $e');
      throw Exception('Error deleting diagnostic center: $e');
    }
  }

  // Get all diagnostic centers
  Future<List<DiagnosticCenter>> getAllDiagnosticCenters() async {
    try {
      _logger.i('Fetching all diagnostic centers');
      
      final response = await _dio.get(
        ApiEndpoints.getAllDiagnosticCenters,
      );

      if (response.statusCode == 200) {
        List<dynamic> data = response.data;
        _logger.i('Fetched ${data.length} diagnostic centers');
        return data.map((json) => DiagnosticCenter.fromJson(json)).toList();
      } else {
        _logger.e('Failed to get diagnostic centers: ${response.statusCode}');
        throw Exception('Failed to get diagnostic centers');
      }
    } catch (e) {
      _logger.e('Error getting diagnostic centers: $e');
      throw Exception('Error getting diagnostic centers: $e');
    }
  }

  // Get diagnostic centers by city
  Future<List<DiagnosticCenter>> getDiagnosticCentersByCity(String city) async {
    try {
      _logger.i('Fetching diagnostic centers in city: $city');
      
      final response = await _dio.get(
        '${ApiEndpoints.getDiagnosticCentersByCity}/$city',
      );

      if (response.statusCode == 200) {
        List<dynamic> data = response.data;
        _logger.i('Fetched ${data.length} diagnostic centers in $city');
        return data.map((json) => DiagnosticCenter.fromJson(json)).toList();
      } else {
        _logger.e('Failed to get diagnostic centers by city: ${response.statusCode}');
        throw Exception('Failed to get diagnostic centers by city');
      }
    } catch (e) {
      _logger.e('Error getting diagnostic centers by city: $e');
      throw Exception('Error getting diagnostic centers by city: $e');
    }
  }

  // Get diagnostic centers by test type
  Future<List<DiagnosticCenter>> getDiagnosticCentersByTestType(String testType) async {
    try {
      _logger.i('Fetching diagnostic centers for test type: $testType');
      
      final response = await _dio.get(
        '${ApiEndpoints.getDiagnosticCentersByTestType}/$testType',
      );

      if (response.statusCode == 200) {
        List<dynamic> data = response.data;
        _logger.i('Fetched ${data.length} diagnostic centers for $testType');
        return data.map((json) => DiagnosticCenter.fromJson(json)).toList();
      } else {
        _logger.e('Failed to get diagnostic centers by test type: ${response.statusCode}');
        throw Exception('Failed to get diagnostic centers by test type');
      }
    } catch (e) {
      _logger.e('Error getting diagnostic centers by test type: $e');
      throw Exception('Error getting diagnostic centers by test type: $e');
    }
  }
} 