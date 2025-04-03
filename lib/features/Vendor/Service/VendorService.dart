import 'package:dio/dio.dart';
import 'package:vedika_healthcare/core/constants/ApiEndpoints.dart';

class VendorService {
  final Dio _dio = Dio();

  // Toggle Vendor Status (Activate/Deactivate)
  Future<bool> toggleVendorStatus(String vendorId) async {
    try {
      final response = await _dio.put(
        '${ApiEndpoints.toggleVendorStatus}/$vendorId',
        options: Options(headers: {"Content-Type": "application/json"}),
      );

      if (response.statusCode == 200) {
        return response.data['isActive']; // Returns true if active, false if inactive
      } else {
        throw Exception("Failed to toggle vendor status");
      }
    } catch (e) {
      print("Error in toggleVendorStatus: $e");
      return false;
    }
  }

  // ✅ Get Vendor's Current Active Status
  Future<bool> getVendorStatus(String vendorId) async {
    try {
      final response = await _dio.get(
        '${ApiEndpoints.getVendorStatus}/$vendorId', // API Endpoint for fetching status
        options: Options(headers: {"Content-Type": "application/json"}),
      );

      if (response.statusCode == 200) {
        return response.data['isActive']; // Expecting API to return `isActive` boolean
      } else {
        throw Exception("Failed to fetch vendor status");
      }
    } catch (e) {
      print("Error in getVendorStatus: $e");
      return false; // Default to offline in case of an error
    }
  }

}
