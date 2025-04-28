import 'package:dio/dio.dart';
import 'package:logger/logger.dart';
import 'package:vedika_healthcare/core/constants/ApiEndpoints.dart';
import 'package:vedika_healthcare/features/Vendor/LabTest/data/models/DiagnosticCenter.dart';
import 'package:vedika_healthcare/features/Vendor/LabTest/data/models/LabTestBooking.dart';

class LabTestService {
  final Dio _dio = Dio();
  final Logger _logger = Logger();
  
  // Get all diagnostic centers
  Future<List<DiagnosticCenter>> getAllDiagnosticCenters() async {
    try {
      _logger.i('Fetching all diagnostic centers from ${ApiEndpoints.getAllLabDiagnosticCenters}');
      
      final response = await _dio.get(
        ApiEndpoints.getAllLabDiagnosticCenters,
        options: Options(
          validateStatus: (status) {
            return status! < 500; // Accept all status codes less than 500
          },
        ),
      );

      _logger.i('Response status code: ${response.statusCode}');
      _logger.i('Response data type: ${response.data.runtimeType}');
      
      if (response.statusCode == 200) {
        _logger.i('Diagnostic centers fetched successfully');
        
        if (response.data == null) {
          _logger.e('Response data is null');
          return [];
        }
        
        // Log data structure for debugging
        _logger.i('Response data structure: ${response.data is Map ? 'Map' : response.data is List ? 'List' : 'Other'}');
        
        // Extract the list of diagnostic centers
        var centers = response.data;
        
        // If the data is wrapped in a container object, extract it
        if (centers is Map<String, dynamic>) {
          _logger.i('Response data is a Map with keys: ${centers.keys.join(', ')}');
          
          if (centers.containsKey('diagnosticCenters')) {
            centers = centers['diagnosticCenters'];
            _logger.i('Extracted diagnosticCenters from response');
          } else if (centers.containsKey('data')) {
            centers = centers['data'];
            _logger.i('Extracted data from response');
          } else if (centers.containsKey('centers')) {
            centers = centers['centers'];
            _logger.i('Extracted centers from response');
          }
        }
        
        if (centers is List) {
          _logger.i('Processing ${centers.length} centers from API');
          final result = centers.map((center) {
            try {
              return DiagnosticCenter.fromJson(center);
            } catch (e) {
              _logger.e('Error parsing center: $e');
              return null;
            }
          }).whereType<DiagnosticCenter>().toList();
          
          _logger.i('Successfully parsed ${result.length} centers');
          return result;
        } else {
          _logger.e('Invalid data format for diagnostic centers: ${centers.runtimeType}');
          return [];
        }
      } else {
        _logger.e('Failed to get diagnostic centers: ${response.statusCode}');
        _logger.e('Error message: ${response.data['message'] ?? 'Unknown error'}');
        return [];
      }
    } catch (e, stackTrace) {
      _logger.e('Error getting diagnostic centers: $e');
      _logger.e('Stack trace: $stackTrace');
      return [];
    }
  }
  
  // Create a new lab test booking
  Future<Map<String, dynamic>> createLabTestBooking(LabTestBooking booking) async {
    try {
      _logger.i('Creating lab test booking at ${ApiEndpoints.createLabTestBooking}');
      _logger.i('Booking details: ${booking.toJson()}');

      // Log critical fields for debugging
      _logger.i('Critical fields check:');
      _logger.i('- vendorId: ${booking.vendorId}');
      _logger.i('- userId: ${booking.userId}');
      _logger.i('- selectedTests: ${booking.selectedTests}');
      _logger.i('- bookingDate: ${booking.bookingDate}');
      _logger.i('- bookingTime: ${booking.bookingTime}');
      
      final requestData = booking.toJson();
      
      final response = await _dio.post(
        ApiEndpoints.createLabTestBooking,
        data: requestData,
        options: Options(
          validateStatus: (status) {
            return status! < 500; // Accept all status codes less than 500
          },
        ),
      );

      _logger.i('Response status code: ${response.statusCode}');
      
      if (response.statusCode == 200 || response.statusCode == 201) {
        _logger.i('Lab test booking created successfully');
        _logger.i('Response data: ${response.data}');
        
        return {
          'success': true,
          'data': response.data,
          'message': response.data['message'] ?? 'Booking created successfully',
        };
      } else {
        _logger.e('Failed to create lab test booking: ${response.statusCode}');
        _logger.e('Error message: ${response.data['message'] ?? 'Unknown error'}');
        _logger.e('Full response: ${response.data}');
        
        return {
          'success': false,
          'message': response.data['message'] ?? 'Failed to create booking',
        };
      }
    } catch (e, stackTrace) {
      _logger.e('Error creating lab test booking: $e');
      _logger.e('Stack trace: $stackTrace');
      
      return {
        'success': false,
        'message': 'Error: ${e.toString()}',
      };
    }
  }
} 