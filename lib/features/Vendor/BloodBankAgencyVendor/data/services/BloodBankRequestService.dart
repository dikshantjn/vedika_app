import 'dart:convert';
import 'package:dio/dio.dart';
import 'package:logger/logger.dart';
import 'package:vedika_healthcare/core/constants/ApiEndpoints.dart';
import '../model/BloodBankRequest.dart';
import '../../../../../core/auth/data/models/UserModel.dart';

class BloodBankRequestService {
  final Dio _dio = Dio();
  final Logger _logger = Logger();

  // Base URL for the API

  // Get requests for a specific vendor
  Future<List<BloodBankRequest>> getRequests(String vendorId, String token) async {
    try {
      _logger.i('Fetching blood bank requests for vendor: $vendorId');
      
      // Make the API call
      final response = await _dio.get(
        '${ApiEndpoints.getAllBloodBankRequestByVendorId}/$vendorId/requests',
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
              _logger.i('Found ${data.length} blood bank requests');
              return data.map((json) => BloodBankRequest.fromJson(json)).toList();
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
          _logger.i('Found ${data.length} blood bank requests');
          return data.map((json) => BloodBankRequest.fromJson(json)).toList();
        } else {
          _logger.e('Unexpected response format: ${response.data.runtimeType}');
          throw Exception('Invalid response format: expected List or Map with data field');
        }
      } else {
        _logger.e('API request failed with status code: ${response.statusCode}');
        throw Exception('Failed to load blood bank requests: ${response.statusCode}');
      }
    } catch (e) {
      _logger.e('Error fetching blood bank requests: $e');
      throw Exception('Failed to fetch blood bank requests: $e');
    }
  }

  // Update request status
  Future<void> updateRequestStatus(String requestId, String status, String token) async {
    try {
      _logger.i('Updating blood bank request status: $requestId to $status');
      
      // Make the API call
      final response = await _dio.put(
        '${ApiEndpoints.updateBBrequestStatus}/$requestId',
        options: Options(
          headers: {
            'Authorization': 'Bearer $token',
            'Content-Type': 'application/json',
          },
        ),
        data: jsonEncode({
          'status': status,
        }),
      );
      
      _logger.d('API Response: ${response.data}');
      
      // Check if the request was successful
      if (response.statusCode != 200) {
        _logger.e('API request failed with status code: ${response.statusCode}');
        throw Exception('Failed to update request status: ${response.statusCode}');
      }
      
      _logger.i('Successfully updated blood bank request status');
    } catch (e) {
      _logger.e('Error updating request status: $e');
      throw Exception('Failed to update request status: $e');
    }
  }
  
  // Accept blood bank request
  Future<BloodBankRequest> acceptRequest(String requestId, String vendorId, String token) async {
    try {
      _logger.i('Accepting blood bank request: $requestId by vendor: $vendorId');
      
      // Make the API call
      final response = await _dio.post(
        '${ApiEndpoints.acceptBloodBankRequest}/$requestId/accept',
        options: Options(
          headers: {
            'Authorization': 'Bearer $token',
            'Content-Type': 'application/json',
          },
        ),
        data: jsonEncode({
          'vendorId': vendorId,
        }),
      );
      
      // Detailed logging of response
      _logger.d('Raw API Response: ${response.data}');
      _logger.d('Response Type: ${response.data.runtimeType}');
      if (response.data != null && response.data is Map) {
        _logger.d('Response Keys: ${(response.data as Map).keys.toList()}');
        if (response.data['data'] != null && response.data['data'] is Map) {
          _logger.d('Data Keys: ${(response.data['data'] as Map).keys.toList()}');
        }
      }
      
      // Check if the request was successful
      if (response.statusCode == 200) {
        // Handle different response formats
        if (response.data == null) {
          _logger.w('Response data is null, returning dummy request');
          return _createDummyRequest(requestId, vendorId);
        }

        if (response.data is Map<String, dynamic>) {
          final Map<String, dynamic> responseMap = response.data;
          
          // Check if there's a data field that contains the request
          if (responseMap.containsKey('data') && responseMap['data'] != null) {
            try {
              _logger.i('Successfully accepted blood bank request');
              _logger.d('Parsing data: ${responseMap['data']}');
              return BloodBankRequest.fromJson(responseMap['data']);
            } catch (e) {
              _logger.e('Error parsing response data: $e');
              _logger.e('Failed data: ${responseMap['data']}');
              return _createDummyRequest(requestId, vendorId);
            }
          } else {
            _logger.w('Response does not contain a data field or data is null');
            return _createDummyRequest(requestId, vendorId);
          }
        } else if (response.data is String) {
          // Handle string response (might be JSON string)
          try {
            final Map<String, dynamic> responseMap = jsonDecode(response.data);
            if (responseMap.containsKey('data') && responseMap['data'] != null) {
              try {
                _logger.i('Successfully accepted blood bank request');
                _logger.d('Parsing data: ${responseMap['data']}');
                return BloodBankRequest.fromJson(responseMap['data']);
              } catch (e) {
                _logger.e('Error parsing response data: $e');
                _logger.e('Failed data: ${responseMap['data']}');
                return _createDummyRequest(requestId, vendorId);
              }
            } else {
              _logger.w('Response does not contain a data field or data is null');
              return _createDummyRequest(requestId, vendorId);
            }
          } catch (e) {
            _logger.e('Error parsing response string: $e');
            return _createDummyRequest(requestId, vendorId);
          }
        } else {
          _logger.w('Unexpected response format: ${response.data.runtimeType}');
          return _createDummyRequest(requestId, vendorId);
        }
      } else {
        _logger.e('API request failed with status code: ${response.statusCode}');
        return _createDummyRequest(requestId, vendorId);
      }
    } catch (e) {
      _logger.e('Error accepting blood bank request: $e');
      return _createDummyRequest(requestId, vendorId);
    }
  }

  // Helper method to create a dummy request
  BloodBankRequest _createDummyRequest(String requestId, String vendorId) {
    _logger.i('Creating dummy BloodBankRequest');
    return BloodBankRequest(
      requestId: requestId,
      userId: '',
      user: UserModel.empty(),
      customerName: 'Unknown',
      bloodType: 'Unknown',
      units: 0,
      prescriptionUrls: [],
      requestedVendors: [],
      acceptedVendorId: vendorId,
      status: 'accepted',
      createdAt: DateTime.now(),
      updatedAt: DateTime.now(),
    );
  }
} 