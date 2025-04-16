import 'dart:convert';
import 'package:dio/dio.dart';
import 'package:logger/logger.dart';
import 'package:vedika_healthcare/core/constants/ApiEndpoints.dart';
import '../model/BloodBankBooking.dart';
import '../../../../../core/auth/data/models/UserModel.dart';

class BloodBankBookingService {
  final Dio _dio = Dio();
  final Logger _logger = Logger();
  
  // Get bookings for a specific vendor
  Future<List<BloodBankBooking>> getBookings(String vendorId, String token) async {
    try {
      _logger.i('Fetching blood bank bookings for vendor: $vendorId');
      
      // Make the API call
      final response = await _dio.get(
        '${ApiEndpoints.getBloodBankBookingsByVendorId}/$vendorId',
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
  
  // Get completed bookings for a specific vendor
  Future<List<BloodBankBooking>> getCompletedBookings(String vendorId, String token) async {
    try {
      _logger.i('Fetching completed blood bank bookings for vendor: $vendorId');
      
      // Make the API call
      final response = await _dio.get(
        '${ApiEndpoints.getBloodBankBookingsByVendorId}/$vendorId',
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
              _logger.i('Found ${data.length} completed blood bank bookings');
              
              // Process each booking
              return data.map((json) {
                // Ensure user data is properly formatted
                if (json.containsKey('user') && json['user'] != null) {
                  final userData = json['user'];
                  
                  // Create a user model using the empty constructor
                  final user = UserModel.empty();
                  
                  // Update the user data in the JSON
                  json['user'] = user.toJson();
                } else {
                  // If user data is null or not present, set it to an empty user
                  json['user'] = UserModel.empty().toJson();
                }
                
                // Create a booking from the JSON
                return BloodBankBooking.fromJson(json);
              }).toList();
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
          _logger.i('Found ${data.length} completed blood bank bookings');
          return data.map((json) => BloodBankBooking.fromJson(json)).toList();
        } else {
          _logger.e('Unexpected response format: ${response.data.runtimeType}');
          throw Exception('Invalid response format: expected List or Map with data field');
        }
      } else {
        _logger.e('API request failed with status code: ${response.statusCode}');
        throw Exception('Failed to load completed blood bank bookings: ${response.statusCode}');
      }
    } catch (e) {
      _logger.e('Error fetching completed blood bank bookings: $e');
      throw Exception('Failed to fetch completed blood bank bookings: $e');
    }
  }


  // Update booking status
  Future<void> updateBookingStatus(String bookingId, String status, String token) async {
    try {
      _logger.i('Updating blood bank booking status: $bookingId to $status');
      
      // Make the API call
      final response = await _dio.put(
        '${ApiEndpoints.updateBookingStatusAsWaitingForPickup}/$bookingId/status/waiting-for-pickup',
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
        throw Exception('Failed to update booking status: ${response.statusCode}');
      }
      
      _logger.i('Successfully updated blood bank booking status');
    } catch (e) {
      _logger.e('Error updating booking status: $e');
      throw Exception('Failed to update booking status: $e');
    }
  }

  // Notify user about booking
  Future<void> notifyUser(
    String bookingId,
    String token, {
    String? notes,
    double? totalAmount,
    double? discount,
    int? units,
    double? pricePerUnit,
    String? deliveryType,
  }) async {
    try {
      _logger.i('Notifying user about booking payment: $bookingId');
      
      final response = await _dio.post(
        '${ApiEndpoints.BloodBlankBookingwaitingforPaytmentStatus}/$bookingId/payment',
        options: Options(
          headers: {
            'Authorization': 'Bearer $token',
            'Content-Type': 'application/json',
          },
        ),
        data: {
          if (notes != null && notes.isNotEmpty) 'notes': notes,
          if (totalAmount != null) 'totalAmount': totalAmount,
          if (discount != null) 'discount': discount,
          if (units != null) 'units': units,
          if (pricePerUnit != null) 'pricePerUnit': pricePerUnit,
          if (deliveryType != null) 'deliveryType': deliveryType,
        },
      );
      
      _logger.i('Payment notification response: ${response.data}');
      
      if (response.statusCode != 200) {
        throw Exception('Failed to notify user about payment: ${response.statusMessage}');
      }
    } catch (e) {
      _logger.e('Error notifying user about payment: $e');
      rethrow;
    }
  }

  // Mark booking as completed
  Future<void> markBookingAsCompleted(String bookingId, String token) async {
    try {
      _logger.i('Marking booking as completed: $bookingId');
      
      final response = await _dio.patch(
        '${ApiEndpoints.BloodBankBookings}/$bookingId/complete',
        options: Options(
          headers: {
            'Authorization': 'Bearer $token',
            'Content-Type': 'application/json',
          },
        ),
      );
      
      _logger.i('Mark as completed response: ${response.data}');
      
      if (response.statusCode != 200) {
        throw Exception('Failed to mark booking as completed: ${response.statusMessage}');
      }
    } catch (e) {
      _logger.e('Error marking booking as completed: $e');
      rethrow;
    }
  }
} 