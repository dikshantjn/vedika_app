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
}
