import 'dart:convert';
import 'package:dio/dio.dart';
import 'package:vedika_healthcare/core/constants/ApiEndpoints.dart';
import 'package:vedika_healthcare/features/Vendor/HospitalVendor/Models/HospitalProfile.dart';

class HospitalVendorService {
  final Dio _dio = Dio();

  Future<Response> registerHospital(HospitalProfile hospital) async {
    try {
      final data = {
        'vendor': {
          'vendorRole': 4, // Hospital vendor role
          'phoneNumber': hospital.contactNumber,
          'email': hospital.email,
        },
        'hospitalProfile': hospital.toJson(),
      };

      print("🔹 Register Request Data: ${jsonEncode(data)}");

      final response = await _dio.post(
        ApiEndpoints.registerVendor,
        options: Options(headers: {'Content-Type': 'application/json'}),
        data: jsonEncode(data),
      );

      print("✅ Register Response: ${response.statusCode}, Data: ${response.data}");
      return response;
    } on DioException catch (e) {
      return _handleDioError(e);
    }
  }

  Future<Response> updateHospitalProfile(HospitalProfile hospital) async {
    try {
      final data = hospital.toJson();

      print("🔹 Update Request Data: ${jsonEncode(data)}");

      final response = await _dio.put(
        "ApiEndpoints.updateHospitalProfile",
        options: Options(headers: {'Content-Type': 'application/json'}),
        data: jsonEncode(data),
      );

      print("✅ Update Response: ${response.statusCode}, Data: ${response.data}");
      return response;
    } on DioException catch (e) {
      return _handleDioError(e);
    }
  }

  Future<HospitalProfile?> fetchHospitalProfile(String token) async {
    try {
      final response = await _dio.get(
       " ApiEndpoints.getHospitalProfile",
        options: Options(headers: {
          'Authorization': 'Bearer $token',
          'Content-Type': 'application/json',
        }),
      );

      if (response.statusCode == 200) {
        print("✅ Fetch Profile Response: ${response.data}");
        final data = response.data;
        if (data != null && data.containsKey('hospitalProfile')) {
          return HospitalProfile.fromJson(data['hospitalProfile']);
        } else {
          throw Exception("Hospital Profile data is missing");
        }
      } else {
        throw Exception('Failed to fetch hospital profile');
      }
    } on DioException catch (e) {
      _handleDioError(e);
      return null;
    }
  }

  Response _handleDioError(DioException e) {
    if (e.response != null) {
      print("❌ Error Response: ${e.response?.data}, Status Code: ${e.response?.statusCode}");
      return e.response!;
    } else {
      print("❌ Network Error: ${e.message}");
      throw Exception('Network error: ${e.message}');
    }
  }
} 