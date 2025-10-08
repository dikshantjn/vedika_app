import 'dart:typed_data';
import 'package:dio/dio.dart';
import 'package:vedika_healthcare/core/constants/ApiEndpoints.dart';
import 'package:vedika_healthcare/features/ambulance/data/models/AmbulanceBooking.dart';

class AmbulanceOrderRepository {

  final Dio _dio = Dio();

  /// Dio method to fetch completed bookings by user ID
  Future<List<AmbulanceBooking>> fetchCompletedOrdersByUser(String userId) async {
    try {
      final response = await _dio.get("${ApiEndpoints.getCompletedRequestsByUserEndpoint}/$userId");

      if (response.statusCode == 200 && response.data['success'] == true) {
        final List data = response.data['data'];

        return data.map((json) => AmbulanceBooking.fromJson(json)).toList();
      } else {
        throw Exception(response.data['message'] ?? "Failed to fetch completed orders");
      }
    } catch (e) {
      print("Error fetching completed orders: $e");
      rethrow;
    }
  }

  /// Dio method to fetch ambulance invoice bytes
  Future<Uint8List> fetchAmbulanceInvoiceBytes(String bookingId) async {
    try {
      final response = await _dio.get(
        "${ApiEndpoints.getAmbulanceInvoice}/$bookingId",
        options: Options(
          responseType: ResponseType.bytes,
          headers: {
            'Accept': 'application/pdf',
          },
        ),
      );

      if (response.statusCode == 200) {
        return Uint8List.fromList(response.data);
      } else {
        throw Exception("Failed to fetch ambulance invoice: ${response.statusCode}");
      }
    } catch (e) {
      print("Error fetching ambulance invoice: $e");
      rethrow;
    }
  }
}
