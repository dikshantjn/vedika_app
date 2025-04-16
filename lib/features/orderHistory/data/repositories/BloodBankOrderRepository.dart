import 'package:dio/dio.dart';
import 'package:vedika_healthcare/core/constants/ApiEndpoints.dart';
import 'package:vedika_healthcare/features/Vendor/BloodBankAgencyVendor/data/model/BloodBankBooking.dart';

class BloodBankOrderRepository {
  final Dio _dio;

  BloodBankOrderRepository({Dio? dio}) : _dio = dio ?? Dio();

  /// Fetch Blood Bank Orders
  Future<List<BloodBankBooking>> getBloodBankOrders(String userId, String token) async {
    try {
      final response = await _dio.get(
        '${ApiEndpoints.getCompletedBloodBankBookingsByUserId}/$userId/completed',
        options: Options(
          headers: {
            'Authorization': 'Bearer $token',
            'Content-Type': 'application/json',
          },
        ),
      );

      if (response.statusCode == 200) {
        final data = response.data;
        if (data['success'] == true) {
          final List<dynamic> bookings = data['data'];
          return bookings.map((booking) => BloodBankBooking.fromJson(booking)).toList();
        } else {
          throw Exception(data['message'] ?? 'Failed to fetch blood bank orders');
        }
      } else {
        throw Exception('Failed to fetch blood bank orders: ${response.statusCode}');
      }
    } on DioException catch (e) {
      if (e.response?.data != null) {
        throw Exception(e.response?.data['message'] ?? 'Error fetching blood bank orders');
      }
      throw Exception('Error fetching blood bank orders: ${e.message}');
    } catch (e) {
      throw Exception('Error fetching blood bank orders: $e');
    }
  }

  /// Place a Blood Bank Booking
  Future<void> placeBloodBankOrder(BloodBankBooking booking) async {
    // TODO: Implement when API is available
    throw UnimplementedError('Place blood bank booking not implemented yet');
  }

  /// Cancel Blood Bank Booking
  Future<void> cancelBloodBankOrder(String bookingId) async {
    // TODO: Implement when API is available
    throw UnimplementedError('Cancel blood bank booking not implemented yet');
  }
}
