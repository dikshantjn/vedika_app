import 'dart:typed_data';
import 'package:dio/dio.dart';
import 'package:vedika_healthcare/core/constants/ApiEndpoints.dart';
import 'package:vedika_healthcare/features/Vendor/LabTest/data/models/LabTestBooking.dart';

class LabTestOrderService {
  final Dio _dio = Dio();

  // Fetch completed lab test orders for a user
  Future<List<LabTestBooking>> getCompletedLabTestOrders(String userId) async {
    try {
      final response = await _dio.get(
        '${ApiEndpoints.getCompletedLabTestBookingsByUserId}/$userId',
        options: Options(
          headers: {
            'Content-Type': 'application/json',
          },
        ),
      );

      if (response.statusCode == 200) {
        final data = response.data;
        if (data != null && data.containsKey('data')) {
          final bookings = data['data'] as List;
          return bookings.map((booking) {
            // Transform the nested structure to flat structure expected by LabTestBooking
            final bookingDetails = booking['bookingDetails'] as Map<String, dynamic>;
            final diagnosticCenterDetails = booking['diagnosticCenterDetails'] as Map<String, dynamic>;
            final userDetails = booking['userDetails'] as Map<String, dynamic>;
            
            // Create a flat structure by combining all details
            final flatBooking = {
              ...bookingDetails,
              'user': userDetails,
              'diagnosticCenter': diagnosticCenterDetails,
            };
            
            return LabTestBooking.fromJson(flatBooking);
          }).toList();
        } else {
          print("❌ Fetch Error: Completed lab test bookings data is missing");
          throw Exception("Completed lab test bookings data is missing");
        }
      } else {
        print("❌ Fetch Error: ${response.statusCode} - ${response.data}");
        throw Exception('Failed to fetch completed lab test bookings: ${response.data}');
      }
    } on DioException catch (e) {
      print("❌ Fetch DioException: ${e.message}");
      print("❌ Fetch Error Response: ${e.response?.data}");
      rethrow;
    } catch (e) {
      print("❌ Fetch Exception: $e");
      rethrow;
    }
  }

  // Fetch lab test invoice bytes (for preview in viewer)
  Future<Uint8List> fetchLabTestInvoiceBytes(String bookingId) async {
    try {
      final response = await _dio.get(
        '${ApiEndpoints.getLabTestInvoice}/$bookingId',
        options: Options(
          responseType: ResponseType.bytes,
          headers: const {
            'Accept': 'application/pdf',
          },
        ),
      );

      if (response.statusCode == 200) {
        final data = response.data;
        if (data is List<int>) {
          return Uint8List.fromList(data);
        }
        if (data is Uint8List) {
          return data;
        }
        throw Exception('Unexpected response type for PDF');
      } else {
        throw Exception('Failed to fetch lab test invoice');
      }
    } catch (e) {
      print('Error fetching lab test invoice bytes: $e');
      rethrow;
    }
  }
}