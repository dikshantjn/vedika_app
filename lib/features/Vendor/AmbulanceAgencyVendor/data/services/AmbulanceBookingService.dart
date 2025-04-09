import 'package:dio/dio.dart';
import 'package:vedika_healthcare/core/constants/ApiEndpoints.dart';
import 'package:vedika_healthcare/features/ambulance/data/models/AmbulanceBooking.dart';

class AmbulanceBookingService {
  final Dio _dio = Dio();

  Future<List<AmbulanceBooking>> getPendingBookings(String vendorId) async {
    try {
      final response = await _dio.get(
        '${ApiEndpoints.getPendingAmbulanceBookings}/$vendorId',
      );

      if (response.statusCode == 200 && response.data['success']) {
        List<dynamic> data = response.data['data'];
        return data.map((json) => AmbulanceBooking.fromJson(json)).toList();
      } else {
        throw Exception(response.data['message'] ?? 'Failed to fetch bookings');
      }
    } on DioError catch (e) {
      throw Exception(e.response?.data['message'] ?? e.message);
    }
  }

  // 👇 NEW METHOD: Accept Booking Request
  Future<String> acceptBookingRequest(String requestId) async {
    try {
      final response = await _dio.patch(
          '${ApiEndpoints.acceptAmbulanceBooking}/$requestId',
      );

      if (response.statusCode == 200 && response.data['success']) {
        // Extract status from data object
        return response.data['data']['status'] ?? "Accepted";
      } else {
        throw Exception(response.data['message'] ?? 'Failed to accept booking');
      }
    } on DioError catch (e) {
      throw Exception(e.response?.data['message'] ?? e.message);
    }
  }

  Future<String> getBookingStatus(String requestId) async {
    try {
      final response = await _dio.get(
        '${ApiEndpoints.getAmbulanceBookingStatus}/$requestId',
      );

      if (response.statusCode == 200 && response.data['success']) {
        return response.data['status'] ?? "Unknown";
      } else {
        throw Exception(response.data['message'] ?? 'Failed to get booking status');
      }
    } on DioError catch (e) {
      throw Exception(e.response?.data['message'] ?? e.message);
    }
  }

  Future<List<String>> getVehicleTypes() async {
    try {
      final response = await _dio.get(ApiEndpoints.getVehicleTypes);

      if (response.statusCode == 200 && response.data['success']) {
        // FIXED: changed 'data' to 'vehicleTypes' based on your backend
        List<dynamic> types = response.data['vehicleTypes'];
        return types.cast<String>();
      } else {
        throw Exception(response.data['message'] ?? 'Failed to fetch vehicle types');
      }
    } on DioError catch (e) {
      throw Exception(e.response?.data['message'] ?? e.message);
    }
  }

  Future<void> updateServiceDetails({
    required String requestId,
    required String pickupLocation,
    required String dropLocation,
    required double totalDistance,
    required double costPerKm,
    required double baseCharge,
    required String vehicleType,
    required double totalAmount,
  }) async {
    try {
      final response = await _dio.patch(
        '${ApiEndpoints.updateAmbulanceServiceDetails}/$requestId',
        data: {
          'pickupLocation': pickupLocation,
          'dropLocation': dropLocation,
          'totalDistance': totalDistance,
          'costPerKm': costPerKm,
          'baseCharge': baseCharge,
          'vehicleType': vehicleType,
          'totalAmount': totalAmount,
        },
      );

      if (response.statusCode != 200 || response.data['success'] != true) {
        throw Exception(response.data['message'] ?? 'Failed to update service details');
      }
    } on DioError catch (e) {
      throw Exception(e.response?.data['message'] ?? e.message);
    }
  }


}
