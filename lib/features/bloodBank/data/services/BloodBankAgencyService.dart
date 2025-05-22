import 'package:dio/dio.dart';
import 'package:logger/logger.dart';
import 'package:vedika_healthcare/core/constants/ApiEndpoints.dart';
import 'package:vedika_healthcare/features/Vendor/BloodBankAgencyVendor/data/model/BloodBankAgency.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:vedika_healthcare/core/auth/data/repositories/AuthRepository.dart';
import 'package:vedika_healthcare/core/auth/data/services/StorageService.dart';
import 'dart:io';
import 'package:path/path.dart' as path;
import 'package:vedika_healthcare/features/Vendor/BloodBankAgencyVendor/data/model/BloodBankBooking.dart';

class BloodBankAgencyService {
  final Dio _dio = Dio();
  final _logger = Logger();
  final FirebaseStorage _storage = FirebaseStorage.instance;
  final AuthRepository _authRepository = AuthRepository();
  
  // Default search radius in kilometers
  static const double DEFAULT_SEARCH_RADIUS = 5.0;
  
  // Placeholder user ID since Firebase Auth is not set up
  static const String PLACEHOLDER_USER_ID = 'placeholder_user_id';
  
  // Constructor to set up Dio with auth token
  BloodBankAgencyService() {
    _setupDioWithAuthToken();
  }
  
  // Set up Dio with auth token
  Future<void> _setupDioWithAuthToken() async {
    try {
      final String? token = await _authRepository.getToken();
      if (token != null) {
        _dio.options.headers['Authorization'] = 'Bearer $token';
      }
    } catch (e) {
      _logger.e('Error setting up Dio with auth token: $e');
    }
  }
  
  // Get all active blood bank agencies
  Future<List<BloodBankAgency>> getActiveBloodBankAgencies() async {
    try {
      _logger.i('Fetching active blood bank agencies');
      
      // Ensure token is set
      await _setupDioWithAuthToken();
      
      final response = await _dio.get('${ApiEndpoints.getAllBloodBankAgencies}');
      
      _logger.i('Response received: ${response.data}');
      
      if (response.statusCode == 200) {
        if (response.data is List) {
          final List<dynamic> data = response.data;
          return data.map((json) => BloodBankAgency.fromJson(json)).toList();
        } else if (response.data is Map<String, dynamic> && response.data['data'] is List) {
          final List<dynamic> data = response.data['data'];
          return data.map((json) => BloodBankAgency.fromJson(json)).toList();
        } else {
          throw Exception('Invalid response format: ${response.data}');
        }
      } else {
        throw Exception('Failed to fetch blood bank agencies: ${response.statusMessage}');
      }
    } catch (e) {
      _logger.e('Error in getActiveBloodBankAgencies: $e');
      throw Exception('Error fetching blood bank agencies: $e');
    }
  }

  // Get blood bank agency by ID
  Future<BloodBankAgency?> getBloodBankAgencyById(String id) async {
    try {
      _logger.i('Fetching blood bank agency with ID: $id');
      
      // Ensure token is set
      await _setupDioWithAuthToken();
      
      final response = await _dio.get('${ApiEndpoints.getActiveAmbulanceRequests}/blood-bank-agencies/$id');
      
      if (response.statusCode == 200) {
        return BloodBankAgency.fromJson(response.data);
      } else {
        throw Exception('Failed to fetch blood bank agency: ${response.statusMessage}');
      }
    } catch (e) {
      _logger.e('Error getting blood bank agency: $e');
      rethrow;
    }
  }

  // Upload prescription to Firebase Storage
  Future<String> uploadPrescription(File file) async {
    try {
      // Get user ID from storage service
      final String? userId = await StorageService.getUserId();
      final String actualUserId = userId ?? 'anonymous';
      
      final String fileName = path.basename(file.path);
      final String timestamp = DateTime.now().millisecondsSinceEpoch.toString();
      final String storagePath = 'BloodBank_Prescriptions/$actualUserId/$timestamp-$fileName';
      
      final Reference ref = _storage.ref().child(storagePath);
      final UploadTask uploadTask = ref.putFile(file);
      
      final TaskSnapshot snapshot = await uploadTask;
      final String downloadUrl = await snapshot.ref.getDownloadURL();
      
      return downloadUrl;
    } catch (e) {
      _logger.e('Error uploading prescription: $e');
      rethrow;
    }
  }

  // Send blood request to nearest blood banks
  Future<Map<String, dynamic>> sendBloodRequest({
    required String customerName,
    required List<String> bloodTypes,
    required int units,
    required List<String> prescriptionUrls,
    required double latitude,
    required double longitude,
  }) async {
    try {
      // Get user ID from storage service
      final String? userId = await StorageService.getUserId();
      final String actualUserId = userId ?? 'anonymous';
      
      // Ensure token is set
      await _setupDioWithAuthToken();
      
      // Create request body
      final Map<String, dynamic> requestBody = {
        'userId': actualUserId,
        'customerName': customerName,
        'bloodType': bloodTypes.join(','), // Join blood types with comma
        'units': units,
        'prescriptionUrls': prescriptionUrls,
        'latitude': latitude,
        'longitude': longitude,
        'radius': DEFAULT_SEARCH_RADIUS,
      };

      // Log the request details
      _logger.i('Sending blood request with body: $requestBody');
      _logger.i('Blood types requested: $bloodTypes');
      _logger.i('User ID: $actualUserId');
      _logger.i('Location: $latitude, $longitude');
      _logger.i('Radius: $DEFAULT_SEARCH_RADIUS km');
      
      // Create a single request with all blood types
      final response = await _dio.post(
        '${ApiEndpoints.getNearestBloodBankAndSendRequest}',
        data: requestBody,
        options: Options(
          validateStatus: (status) => status! < 500, // Accept 400 responses
        ),
      );
      
      // Log the response
      _logger.i('Blood request response status: ${response.statusCode}');
      _logger.i('Blood request response data: ${response.data}');
      
      if (response.statusCode == 200) {
        return {
          'success': true,
          'message': 'Blood request sent successfully',
          'data': response.data,
        };
      } else {
        _logger.e('Blood request failed with status ${response.statusCode}');
        _logger.e('Error response: ${response.data}');
        return {
          'success': false,
          'message': response.data['message'] ?? 'Failed to send blood request',
          'error': response.data,
        };
      }
    } catch (e) {
      _logger.e('Error sending blood request: $e');
      _logger.e('Stack trace: ${StackTrace.current}');
      return {
        'success': false,
        'message': 'An error occurred while sending the blood request',
        'error': e.toString(),
      };
    }
  }

  // Get bookings for a specific vendor
  Future<List<BloodBankBooking>> getBookings(String userId, String token) async {
    try {
      _logger.i('Fetching blood bank bookings for user: $userId');

      // Make the API call
      final response = await _dio.get(
        '${ApiEndpoints.getBloodBankBookingsByUserId}/$userId',
        options: Options(
          headers: {
            'Authorization': 'Bearer $token',
            'Content-Type': 'application/json',
          },
        ),
      );

      _logger.d('API Response: ${response.data}');

      // Check if the request was successful
      if (response.statusCode == 200) {
        // Check if the response is a map with a data field
        if (response.data is Map<String, dynamic>) {
          final Map<String, dynamic> responseMap = response.data;

          // Check if there's a data field that contains the list
          if (responseMap.containsKey('data') && responseMap['data'] != null) {
            if (responseMap['data'] is List) {
              final List<dynamic> data = responseMap['data'];
              _logger.i('Found ${data.length} blood bank bookings');
              return data.map((json) => BloodBankBooking.fromJson(json)).toList();
            } else {
              _logger.e('Data field is not a list: ${responseMap['data'].runtimeType}');
              throw Exception('Invalid response format: data field is not a list');
            }
          } else {
            _logger.e('Response does not contain a data field or data is null');
            throw Exception('Invalid response format: missing data field or data is null');
          }
        } else if (response.data is List) {
          // Direct list response
          final List<dynamic> data = response.data;
          _logger.i('Found ${data.length} blood bank bookings');
          return data.map((json) => BloodBankBooking.fromJson(json)).toList();
        } else {
          _logger.e('Unexpected response format: ${response.data.runtimeType}');
          throw Exception('Invalid response format: expected List or Map with data field');
        }
      } else {
        _logger.e('API request failed with status code: ${response.statusCode}');
        throw Exception('Failed to load blood bank bookings: ${response.statusCode}');
      }
    } catch (e) {
      _logger.e('Error fetching blood bank bookings: $e');
      throw Exception('Failed to fetch blood bank bookings: $e');
    }
  }

  Future<void> updatePaymentDetails(String bookingId) async {
    try {
      _logger.i('Updating payment details for booking ID: $bookingId');

      // Ensure token is set
      await _setupDioWithAuthToken();

      final response = await _dio.put(
        '${ApiEndpoints.updatePaymentDetails}/$bookingId/update-payment',
      );

      if (response.statusCode == 200) {
        _logger.i('Payment details updated successfully');
      } else {
        _logger.e('Failed to update payment details: ${response.statusMessage}');
      }
    } catch (e) {
      _logger.e('Error updating payment details: $e');
      throw Exception('Failed to update payment details: $e');
    }
  }
} 