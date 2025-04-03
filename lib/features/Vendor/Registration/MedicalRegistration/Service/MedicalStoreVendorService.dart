import 'dart:convert';
import 'package:dio/dio.dart';
import 'package:vedika_healthcare/core/constants/ApiEndpoints.dart';
import 'package:vedika_healthcare/features/Vendor/Registration/Models/VendorMedicalStoreProfile.dart';
import 'package:vedika_healthcare/features/Vendor/Registration/Models/Vendor.dart';

class MedicalStoreVendorService {
  final Dio _dio = Dio();

  /// **Register Vendor and Medical Store**
  Future<Response> registerVendor({
    required Vendor vendor,
    required VendorMedicalStoreProfile medicalStore,
  }) async {
    if (vendor.phoneNumber == null || vendor.email == null || vendor.password == null) {
      throw Exception('Vendor information is incomplete');
    }

    if (medicalStore.name.isEmpty || medicalStore.address.isEmpty || medicalStore.ownerName.isEmpty) {
      throw Exception('Medical store details are incomplete');
    }

    try {
      final data = {
        'vendor': vendor.toJson(),
        'medicalStore': medicalStore.toJson(),
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

  /// **Update Medical Store**
  Future<Response> updateMedicalStore({
    required VendorMedicalStoreProfile medicalStore,
  }) async {
    if (medicalStore.vendorId == null || medicalStore.name.isEmpty || medicalStore.address.isEmpty) {
      throw Exception('Vendor ID or medical store details are incomplete');
    }

    try {
      final data = jsonEncode(medicalStore.toJson());

      print("🔹 Update Request Data: $data");

      final response = await _dio.put(
        ApiEndpoints.updateMedicalStore,
        options: Options(headers: {'Content-Type': 'application/json'}),
        data: data,
      );

      print("✅ Update Response: ${response.statusCode}, Data: ${response.data}");
      return response;
    } on DioException catch (e) {
      return _handleDioError(e);
    }
  }

  Future<VendorMedicalStoreProfile?> fetchVendorProfile(String token) async {
    try {
      final response = await _dio.get(
        ApiEndpoints.getVendorProfile,
        options: Options(headers: {
          'Authorization': 'Bearer $token',
          'Content-Type': 'application/json',
        }),
      );

      if (response.statusCode == 200) {
        print("✅ Fetch Profile Response: ${response.data}");

        final data = response.data;

        // ✅ Extract the nested "vendorProfile" before parsing
        if (data != null && data.containsKey('vendorProfile') && data['vendorProfile'] != null) {
          return VendorMedicalStoreProfile.fromJson(data['vendorProfile']);
        } else {
          throw Exception("Vendor Profile data is missing");
        }
      } else {
        throw Exception('Failed to fetch vendor profile');
      }
    } on DioException catch (e) {
      _handleDioError(e);
      return null;
    }
  }


  /// **Handle Dio Errors**
  Response _handleDioError(DioException e) {
    if (e.response != null) {
      print("❌ Error Response: ${e.response?.data}, Status Code: ${e.response?.statusCode}");
      return e.response!;
    } else {
      print("❌ Network Error: ${e.message}");
      throw Exception('Network error: ${e.message}');
    }
  }

  /// **Fetch Vendor Details by vendorId**
  Future<VendorMedicalStoreProfile?> fetchVendorById(String vendorId) async {
    try {
      final response = await _dio.get(
        '${ApiEndpoints.getMedicalStoreVendorById}/$vendorId',
        options: Options(headers: {
          'Content-Type': 'application/json',
        }),
      );

      if (response.statusCode == 200) {
        print("✅ Fetch Vendor Response: ${response.data}");

        final data = response.data;
        if (data != null) {
          return VendorMedicalStoreProfile.fromJson(data);
        } else {
          throw Exception("Vendor data is missing");
        }
      } else {
        throw Exception('Failed to fetch vendor details');
      }
    } on DioException catch (e) {
      _handleDioError(e);
      return null;
    }
  }
}
