import 'dart:convert';
import 'package:dio/dio.dart';
import 'package:vedika_healthcare/core/constants/ApiEndpoints.dart';
import 'package:vedika_healthcare/features/Vendor/HospitalVendor/Models/HospitalProfile.dart';
import 'package:vedika_healthcare/features/Vendor/Registration/Models/Vendor.dart';
import 'package:http/http.dart' as http;
import 'package:vedika_healthcare/features/Vendor/HospitalVendor/Services/HospitalVendorStorageService.dart';

class HospitalVendorService {
  final Dio _dio = Dio();
  final HospitalVendorStorageService _storageService = HospitalVendorStorageService();

  Future<http.Response> registerHospital(Vendor vendor, HospitalProfile hospital) async {
    try {
      // Create the request body with both vendor and hospital data
      final Map<String, dynamic> requestBody = {
        'vendor': vendor.toJson(),
        'hospitalProfile': hospital.toJson(),
      };

      print("🔹 Register Request Data: ${jsonEncode(requestBody)}");

      final response = await http.post(
        Uri.parse(ApiEndpoints.registerHospital),
        headers: {
          'Content-Type': 'application/json',
        },
        body: jsonEncode(requestBody),
      );

      print("✅ Register Response: ${response.statusCode}, Data: ${response.body}");
      
      if (response.statusCode != 200 && response.statusCode != 201) {
        print("❌ Register Error: ${response.statusCode} - ${response.body}");
        throw Exception('Failed to register hospital: ${response.body}');
      }

      return response;
    } catch (e) {
      print("❌ Register Exception: $e");
      rethrow;
    }
  }

  Future<Response> updateHospitalProfile(HospitalProfile hospital) async {
    try {
      final data = hospital.toJson();

      print("🔹 Update Request Data: ${jsonEncode(data)}");

      final response = await _dio.put(
        ApiEndpoints.updateHospitalProfile,
        options: Options(headers: {'Content-Type': 'application/json'}),
        data: jsonEncode(data),
      );

      print("✅ Update Response: ${response.statusCode}, Data: ${response.data}");
      
      if (response.statusCode != 200 && response.statusCode != 201) {
        print("❌ Update Error: ${response.statusCode} - ${response.data}");
        throw Exception('Failed to update hospital profile: ${response.data}');
      }

      return response;
    } on DioException catch (e) {
      print("❌ Update DioException: ${e.message}");
      print("❌ Update Error Response: ${e.response?.data}");
      return _handleDioError(e);
    } catch (e) {
      print("❌ Update Exception: $e");
      rethrow;
    }
  }

  Future<HospitalProfile> getHospitalProfile() async {
    try {
      final response = await _dio.get(
        ApiEndpoints.getHospitalProfile,
        options: Options(headers: {
          'Content-Type': 'application/json',
        }),
      );

      print("✅ Fetch Profile Response: ${response.statusCode}, Data: ${response.data}");
      
      if (response.statusCode == 200) {
        final data = response.data;
        if (data != null && data.containsKey('hospitalProfile')) {
          return HospitalProfile.fromJson(data['hospitalProfile']);
        } else {
          print("❌ Fetch Error: Hospital Profile data is missing");
          throw Exception("Hospital Profile data is missing");
        }
      } else {
        print("❌ Fetch Error: ${response.statusCode} - ${response.data}");
        throw Exception('Failed to fetch hospital profile: ${response.data}');
      }
    } on DioException catch (e) {
      print("❌ Fetch DioException: ${e.message}");
      print("❌ Fetch Error Response: ${e.response?.data}");
      _handleDioError(e);
      rethrow;
    } catch (e) {
      print("❌ Fetch Exception: $e");
      rethrow;
    }
  }

  Response _handleDioError(DioException e) {
    if (e.response != null) {
      print("❌ Dio Error Response: ${e.response?.data}");
      print("❌ Dio Error Status: ${e.response?.statusCode}");
      print("❌ Dio Error Headers: ${e.response?.headers}");
      return e.response!;
    } else {
      print("❌ Dio Network Error: ${e.message}");
      print("❌ Dio Error Type: ${e.type}");
      print("❌ Dio Error Stack: ${e.stackTrace}");
      throw Exception('Network error: ${e.message}');
    }
  }
} 