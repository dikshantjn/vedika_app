import 'dart:io';
import 'package:dio/dio.dart';
import 'package:logger/logger.dart';
import 'package:vedika_healthcare/core/constants/ApiEndpoints.dart';
import 'package:vedika_healthcare/features/Vendor/LabTest/data/models/DiagnosticCenter.dart';
import 'package:vedika_healthcare/features/Vendor/LabTest/data/services/LabTestStorageService.dart';
import 'package:vedika_healthcare/features/Vendor/DoctorConsultationVendor/Models/Vendor.dart';
import 'package:vedika_healthcare/features/Vendor/LabTest/data/models/LabTestBooking.dart';
import 'package:vedika_healthcare/core/auth/data/models/UserModel.dart';

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

  // Get lab profile by vendorId
  Future<DiagnosticCenter> getLabProfile(String vendorId) async {
    try {
      _logger.i('Fetching lab profile for vendor ID: $vendorId');
      
      final response = await _dio.get(
        '${ApiEndpoints.getLabProfile}/$vendorId',
        options: Options(
          validateStatus: (status) {
            return status! < 500; // Accept all status codes less than 500
          },
        ),
      );

      _logger.i('Response status code: ${response.statusCode}');
      _logger.i('Response data: ${response.data}');
      
      if (response.statusCode == 200) {
        _logger.i('Lab profile fetched successfully');
        
        if (response.data == null) {
          _logger.e('Response data is null');
          throw Exception('Lab profile data is null');
        }

        // Check if the API returns the diagnostic center directly or nested in another field
        var diagnosticCenterData = response.data;
        
        // If the data is wrapped in a container object, extract it
        if (diagnosticCenterData is Map<String, dynamic> && 
            (diagnosticCenterData.containsKey('diagnosticCenter') || 
             diagnosticCenterData.containsKey('data'))) {
          
          diagnosticCenterData = diagnosticCenterData['diagnosticCenter'] ?? 
                                diagnosticCenterData['data'] ?? 
                                diagnosticCenterData;
          
          _logger.i('Extracted diagnostic center data: $diagnosticCenterData');
        }
        
        // Ensure vendorId is set in the data
        if (diagnosticCenterData is Map<String, dynamic> && !diagnosticCenterData.containsKey('vendorId')) {
          diagnosticCenterData['vendorId'] = vendorId;
        }
        
        return DiagnosticCenter.fromJson(diagnosticCenterData);
      } else {
        _logger.e('Failed to get lab profile: ${response.statusCode}');
        throw Exception('Failed to get lab profile: ${response.data['message'] ?? 'Unknown error'}');
      }
    } catch (e) {
      _logger.e('Error getting lab profile: $e');
      throw Exception('Error getting lab profile: $e');
    }
  }

  // Update lab profile
  Future<bool> updateLabProfile(DiagnosticCenter center) async {
    try {
      _logger.i('Updating lab profile for vendor ID: ${center.vendorId}');
      _logger.i('Update data: ${center.toJson()}');
      
      // Ensure vendorId is included in the request body
      if (center.vendorId == null || center.vendorId!.isEmpty) {
        throw Exception('Vendor ID is required for profile update');
      }

      final response = await _dio.put(
        ApiEndpoints.updateLabProfile,
        data: center.toJson(),
        options: Options(
          validateStatus: (status) {
            return status! < 500; // Accept all status codes less than 500
          },
        ),
      );

      if (response.statusCode == 200) {
        _logger.i('Lab profile updated successfully');
        return true;
      } else {
        _logger.e('Failed to update lab profile: ${response.statusCode}');
        throw Exception('Failed to update lab profile: ${response.data['message'] ?? 'Unknown error'}');
      }
    } catch (e) {
      _logger.e('Error updating lab profile: $e');
      throw Exception('Error updating lab profile: $e');
    }
  }

  // Create lab test booking
  Future<Map<String, dynamic>> createLabTestBooking(LabTestBooking booking) async {
    try {
      _logger.i('Creating lab test booking: ${booking.toJson()}');
      
      final response = await _dio.post(
        ApiEndpoints.createLabTestBooking,
        data: booking.toJson(),
        options: Options(
          validateStatus: (status) {
            return status! < 500; // Accept all status codes less than 500
          },
        ),
      );

      if (response.statusCode == 200 || response.statusCode == 201) {
        _logger.i('Lab test booking created successfully');
        return {
          'success': true,
          'message': 'Booking created successfully',
          'data': response.data['data']
        };
      } else {
        _logger.e('Failed to create lab test booking: ${response.statusCode}');
        return {
          'success': false,
          'message': response.data['message'] ?? 'Failed to create booking'
        };
      }
    } catch (e) {
      _logger.e('Error creating lab test booking: $e');
      return {
        'success': false,
        'message': 'Error creating booking: $e'
      };
    }
  }

  // Get pending bookings by vendor ID
  Future<List<LabTestBooking>> getPendingBookingsByVendorId(String vendorId) async {
    try {
      _logger.i('Fetching pending bookings for vendor ID: $vendorId');
      
      final response = await _dio.get(
        '${ApiEndpoints.getPendingBookingsByVendorId}/$vendorId',
        options: Options(
          validateStatus: (status) {
            return status! < 500; // Accept all status codes less than 500
          },
        ),
      );

      _logger.i('Response status code: ${response.statusCode}');
      
      if (response.statusCode == 200) {
        _logger.i('Pending bookings fetched successfully');
        
        if (response.data == null || response.data['data'] == null) {
          _logger.e('Response data is null or empty');
          return [];
        }

        final List<dynamic> bookingsData = response.data['data'];
        _logger.i('Number of pending bookings: ${bookingsData.length}');
        
        List<LabTestBooking> bookings = [];
        for (var item in bookingsData) {
          try {
            // Extract data from the response
            Map<String, dynamic> bookingDetails = item['bookingDetails'];
            Map<String, dynamic> diagnosticCenterData = item['diagnosticCenterDetails'];
            Map<String, dynamic> userData = item['userDetails'];
            
            // Create combined booking object with all the data
            Map<String, dynamic> completeBookingData = {
              ...bookingDetails,
              'diagnosticCenter': diagnosticCenterData,
              'user': userData,
            };
            
            // Create booking using fromJson constructor
            LabTestBooking booking = LabTestBooking.fromJson(completeBookingData);
            bookings.add(booking);
            
            _logger.i('Successfully parsed booking: ${booking.bookingId}');
          } catch (e) {
            _logger.e('Error parsing booking: $e');
            // Continue with next booking
          }
        }
        
        _logger.i('Successfully parsed ${bookings.length} bookings');
        return bookings;
      } else {
        _logger.e('Failed to get pending bookings: ${response.statusCode}');
        throw Exception('Failed to get pending bookings: ${response.data['message'] ?? 'Unknown error'}');
      }
    } catch (e) {
      _logger.e('Error getting pending bookings: $e');
      throw Exception('Error getting pending bookings: $e');
    }
  }

  // Get accepted bookings by vendor ID
  Future<List<LabTestBooking>> getAcceptedBookingsByVendorId(String vendorId) async {
    try {
      _logger.i('Fetching accepted bookings for vendor ID: $vendorId');
      
      final response = await _dio.get(
        '${ApiEndpoints.getAcceptedBookingsByVendorId}/$vendorId',
        options: Options(
          validateStatus: (status) {
            return status! < 500; // Accept all status codes less than 500
          },
        ),
      );

      _logger.i('Response status code: ${response.statusCode}');
      
      if (response.statusCode == 200) {
        _logger.i('Accepted bookings fetched successfully');
        
        if (response.data == null || response.data['data'] == null) {
          _logger.e('Response data is null or empty');
          return [];
        }

        final List<dynamic> bookingsData = response.data['data'];
        _logger.i('Number of accepted bookings: ${bookingsData.length}');
        
        List<LabTestBooking> bookings = [];
        for (var item in bookingsData) {
          try {
            // Extract data from the response
            Map<String, dynamic> bookingDetails = item['bookingDetails'];
            Map<String, dynamic> diagnosticCenterData = item['diagnosticCenterDetails'];
            Map<String, dynamic> userData = item['userDetails'];
            
            // Create combined booking object with all the data
            Map<String, dynamic> completeBookingData = {
              ...bookingDetails,
              'diagnosticCenter': diagnosticCenterData,
              'user': userData,
            };
            
            // Create booking using fromJson constructor
            LabTestBooking booking = LabTestBooking.fromJson(completeBookingData);
            bookings.add(booking);
            
            _logger.i('Successfully parsed booking: ${booking.bookingId}');
          } catch (e) {
            _logger.e('Error parsing booking: $e');
            // Continue with next booking
          }
        }
        
        _logger.i('Successfully parsed ${bookings.length} bookings');
        return bookings;
      } else {
        _logger.e('Failed to get accepted bookings: ${response.statusCode}');
        throw Exception('Failed to get accepted bookings: ${response.data['message'] ?? 'Unknown error'}');
      }
    } catch (e) {
      _logger.e('Error getting accepted bookings: $e');
      throw Exception('Error getting accepted bookings: $e');
    }
  }

  // Get completed bookings by vendor ID
  Future<List<LabTestBooking>> getCompletedBookingsByVendorId(String vendorId) async {
    try {
      _logger.i('Fetching completed bookings for vendor ID: $vendorId');
      
      final response = await _dio.get(
        '${ApiEndpoints.getCompletedBookingsByVendorId}/$vendorId',
        options: Options(
          validateStatus: (status) {
            return status! < 500; // Accept all status codes less than 500
          },
        ),
      );

      _logger.i('Response status code: ${response.statusCode}');
      
      if (response.statusCode == 200) {
        _logger.i('Completed bookings fetched successfully');
        
        if (response.data == null || response.data['data'] == null) {
          _logger.e('Response data is null or empty');
          return [];
        }

        final List<dynamic> bookingsData = response.data['data'];
        _logger.i('Number of completed bookings: ${bookingsData.length}');
        
        List<LabTestBooking> bookings = [];
        for (var item in bookingsData) {
          try {
            // Extract data from the response
            Map<String, dynamic> bookingDetails = item['bookingDetails'];
            Map<String, dynamic> diagnosticCenterData = item['diagnosticCenterDetails'];
            Map<String, dynamic> userData = item['userDetails'];
            
            // Create combined booking object with all the data
            Map<String, dynamic> completeBookingData = {
              ...bookingDetails,
              'diagnosticCenter': diagnosticCenterData,
              'user': userData,
            };
            
            // Create booking using fromJson constructor
            LabTestBooking booking = LabTestBooking.fromJson(completeBookingData);
            bookings.add(booking);
            
            _logger.i('Successfully parsed booking: ${booking.bookingId}');
          } catch (e) {
            _logger.e('Error parsing booking: $e');
            // Continue with next booking
          }
        }
        
        _logger.i('Successfully parsed ${bookings.length} bookings');
        return bookings;
      } else {
        _logger.e('Failed to get completed bookings: ${response.statusCode}');
        throw Exception('Failed to get completed bookings: ${response.data['message'] ?? 'Unknown error'}');
      }
    } catch (e) {
      _logger.e('Error getting completed bookings: $e');
      throw Exception('Error getting completed bookings: $e');
    }
  }

  // Accept a lab test booking
  Future<Map<String, dynamic>> acceptBooking(String bookingId) async {
    try {
      _logger.i('Accepting booking with ID: $bookingId');
      
      final response = await _dio.patch(
        '${ApiEndpoints.acceptLabTestBooking}/$bookingId',
        options: Options(
          validateStatus: (status) {
            return status! < 500; // Accept all status codes less than 500
          },
        ),
      );

      _logger.i('Response status code: ${response.statusCode}');
      
      if (response.statusCode == 200) {
        _logger.i('Booking accepted successfully');
        return {
          'success': true,
          'message': response.data['message'] ?? 'Booking accepted successfully',
          'data': response.data['data']
        };
      } else {
        _logger.e('Failed to accept booking: ${response.statusCode}');
        return {
          'success': false,
          'message': response.data['message'] ?? 'Failed to accept booking'
        };
      }
    } catch (e) {
      _logger.e('Error accepting booking: $e');
      return {
        'success': false,
        'message': 'Error accepting booking: $e'
      };
    }
  }

  // Update lab test booking status
  Future<Map<String, dynamic>> updateBookingStatus(String bookingId, String status) async {
    try {
      _logger.i('Updating booking status for ID: $bookingId to: $status');
      
      final response = await _dio.patch(
        '${ApiEndpoints.updateLabTestBookingStatus}/$bookingId',
        data: {
          'bookingStatus': status
        },
        options: Options(
          validateStatus: (status) {
            return status! < 500; // Accept all status codes less than 500
          },
        ),
      );

      _logger.i('Response status code: ${response.statusCode}');
      
      if (response.statusCode == 200) {
        _logger.i('Booking status updated successfully');
        return {
          'success': true,
          'message': response.data['message'] ?? 'Booking status updated successfully',
          'data': response.data['data']
        };
      } else {
        _logger.e('Failed to update booking status: ${response.statusCode}');
        return {
          'success': false,
          'message': response.data['message'] ?? 'Failed to update booking status'
        };
      }
    } catch (e) {
      _logger.e('Error updating booking status: $e');
      return {
        'success': false,
        'message': 'Error updating booking status: $e'
      };
    }
  }

  // Update lab test report URLs
  Future<Map<String, dynamic>> updateReportUrls(String bookingId, Map<String, String> reportUrls) async {
    try {
      _logger.i('Updating report URLs for booking ID: $bookingId');
      _logger.i('Report URLs: $reportUrls');
      
      final response = await _dio.patch(
        '${ApiEndpoints.updateLabTestReportUrls}/$bookingId',
        data: {
          'reportsUrls': reportUrls
        },
        options: Options(
          validateStatus: (status) {
            return status! < 500; // Accept all status codes less than 500
          },
        ),
      );

      _logger.i('Response status code: ${response.statusCode}');
      
      if (response.statusCode == 200) {
        _logger.i('Report URLs updated successfully');
        return {
          'success': true,
          'message': response.data['message'] ?? 'Report URLs updated successfully',
          'data': response.data['data']
        };
      } else {
        _logger.e('Failed to update report URLs: ${response.statusCode}');
        return {
          'success': false,
          'message': response.data['message'] ?? 'Failed to update report URLs'
        };
      }
    } catch (e) {
      _logger.e('Error updating report URLs: $e');
      return {
        'success': false,
        'message': 'Error updating report URLs: $e'
      };
    }
  }
} 