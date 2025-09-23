import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:vedika_healthcare/core/constants/ApiEndpoints.dart';
import 'package:vedika_healthcare/features/Vendor/LabTest/data/models/LabTestBooking.dart';
import 'package:logger/logger.dart';

class LabTestOrderService {
  final Logger _logger = Logger();

  Future<List<LabTestBooking>> getCompletedLabTestOrders(String userId) async {
    try {

      final response = await http.get(
        Uri.parse('${ApiEndpoints.getCompletedLabTestBookingsByUserId}/$userId'),
      );

      if (response.statusCode == 200) {
        final Map<String, dynamic> responseData = json.decode(response.body);

        if (responseData['success'] == true && responseData['data'] != null) {
          final List<dynamic> bookingsData = responseData['data'];

          return bookingsData.map((bookingData) {
            final Map<String, dynamic> bookingDetails = bookingData['bookingDetails'];
            final Map<String, dynamic> diagnosticCenterDetails = bookingData['diagnosticCenterDetails'];
            final Map<String, dynamic> userDetails = bookingData['userDetails'];
            
            // Combine all details into a single map for LabTestBooking.fromJson
            final Map<String, dynamic> combinedData = {
              ...bookingDetails,
              'diagnosticCenter': diagnosticCenterDetails,
              'user': userDetails,
            };
            
            return LabTestBooking.fromJson(combinedData);
          }).toList();
        } else {
          throw Exception(responseData['message'] ?? 'Failed to load completed lab test orders');
        }
      } else {
        _logger.e('Failed to load completed lab test orders. Status code: ${response.statusCode}');
        _logger.e('Response body: ${response.body}');
        throw Exception('Failed to load completed lab test orders');
      }
    } catch (e, stackTrace) {
      _logger.e('Error fetching completed lab test orders', error: e, stackTrace: stackTrace);
      throw Exception('Error fetching completed lab test orders: $e');
    }
  }
} 