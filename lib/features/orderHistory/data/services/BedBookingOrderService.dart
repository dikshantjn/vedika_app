import 'package:dio/dio.dart';
import 'package:vedika_healthcare/core/constants/ApiEndpoints.dart';
import 'package:vedika_healthcare/features/hospital/presentation/models/BedBooking.dart';

class BedBookingOrderService {
  final Dio _dio = Dio();

  Future<List<BedBooking>> getCompletedAppointmentsByUser(String userId) async {
    try {
      final response = await _dio.get(
        '${ApiEndpoints.getCompletedAppointmentsByUser}/$userId',
        options: Options(
          headers: {
            'Content-Type': 'application/json',
          },
        ),
      );

      if (response.statusCode == 200) {
        final data = response.data;
        if (data != null && data.containsKey('bookings')) {
          final bookings = data['bookings'] as List;
          return bookings.map((booking) => BedBooking.fromJson(booking)).toList();
        } else {
          print("❌ Fetch Error: Completed bookings data is missing");
          throw Exception("Completed bookings data is missing");
        }
      } else {
        print("❌ Fetch Error: ${response.statusCode} - ${response.data}");
        throw Exception('Failed to fetch completed bookings: ${response.data}');
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
} 