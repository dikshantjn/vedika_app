import 'package:dio/dio.dart';
import 'package:vedika_healthcare/core/constants/ApiEndpoints.dart';
import 'package:vedika_healthcare/features/ambulance/data/models/AmbulanceBooking.dart';

class AmbulanceBookingHistoryService {
  // ✅ Get Completed Requests by Vendor
  static Future<List<AmbulanceBooking>> getCompletedRequestsByVendor(String vendorId) async {
    try {
      final response = await Dio().get('${ApiEndpoints.getCompletedRequestsByVendorEndpoint}/$vendorId');

      if (response.statusCode == 200 && response.data['success']) {
        List<dynamic> rawList = response.data['data'];
        return rawList.map((e) => AmbulanceBooking.fromJson(e)).toList();
      } else {
        throw Exception(response.data['message'] ?? 'Failed to fetch bookings');
      }
    } catch (e) {
      throw Exception("Error fetching vendor completed requests: $e");
    }
  }
}
