import 'dart:convert';

import 'package:dio/dio.dart';
import 'package:vedika_healthcare/core/constants/ApiEndpoints.dart';
import 'package:vedika_healthcare/features/Vendor/AmbulanceAgencyVendor/data/modals/AmbulanceAgency.dart';
import 'package:vedika_healthcare/features/Vendor/Registration/Models/Vendor.dart';

class AmbulanceAgencyService {
  final Dio _dio = Dio();

  Future<Response> registerAgencyWithVendor({
    required Vendor vendor,
    required AmbulanceAgency agency,
  }) async {
    // Optional validations
    if (vendor.phoneNumber == null || vendor.email == null || vendor.password == null) {
      throw Exception('Vendor information is incomplete');
    }

    if (agency.agencyName.isEmpty || agency.address.isEmpty || agency.ownerName.isEmpty) {
      throw Exception('Ambulance agency details are incomplete');
    }

    try {
      final data = {
        'vendor': vendor.toJson(),
        'ambulanceAgency': agency.toJson(),
      };

      print("🚑 Register Agency Request: ${jsonEncode(data)}");

      final response = await _dio.post(
        ApiEndpoints.registerAmbulanceAgency,
        options: Options(headers: {'Content-Type': 'application/json'}),
        data: jsonEncode(data),
      );

      print("✅ Agency Register Response: ${response.statusCode}, ${response.data}");
      return response;
    } on DioException catch (e) {
      print("❌ Dio Error: ${e.response?.data ?? e.message}");
      throw Exception("Failed to register agency: ${e.response?.data ?? e.message}");
    } catch (e) {
      print("❌ Unexpected Error: $e");
      throw Exception("Unexpected error: $e");
    }
  }
}
