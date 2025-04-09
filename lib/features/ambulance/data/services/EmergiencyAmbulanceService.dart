import 'package:dio/dio.dart';
import 'package:vedika_healthcare/core/constants/ApiEndpoints.dart';
import 'package:vedika_healthcare/features/Vendor/AmbulanceAgencyVendor/data/modals/AmbulanceAgency.dart';
import 'package:vedika_healthcare/features/ambulance/data/models/AmbulanceBooking.dart';


class EmergiencyAmbulanceService {
  final Dio _dio = Dio();

  Future<List<AmbulanceAgency>> fetchAmbulances() async {
    try {
      final response = await _dio.get(ApiEndpoints.getAmbulances);

      if (response.statusCode == 200) {
        final jsonResponse = response.data;

        // Assuming the actual list is under a 'data' field
        List<dynamic> data = jsonResponse['data'];
        print('Response data: ${response.data}');

        return data.map((json) => AmbulanceAgency.fromJson(json)).toList();

      } else {
        throw Exception("Failed to fetch ambulances");
      }
    } catch (e) {
      throw Exception("Error: $e");
    }
  }

  Future<AmbulanceBooking?> createBooking({
    required String userId,
    required String vendorId,
  }) async {
    try {
      final response = await _dio.post(
        ApiEndpoints.createAmbulanceBooking,
        data: {
          "userId": userId,
          "vendorId": vendorId,
        },
      );

      if (response.statusCode == 201 && response.data['success'] == true) {
        print("🚑 Booking created: ${response.data['data']}");
        return AmbulanceBooking.fromJson(response.data['data']);
      } else {
        print("❌ Booking failed: ${response.data['message']}");
        return null;
      }
    } catch (e) {
      print("🔥 Booking error: $e");
      return null;
    }
  }



}
