import 'dart:convert'; // for jsonEncode
import 'package:dio/dio.dart';
import 'package:vedika_healthcare/core/constants/ApiEndpoints.dart';
import 'package:vedika_healthcare/features/Vendor/Registration/Models/VendorMedicalStoreProfile.dart';
import 'package:vedika_healthcare/features/Vendor/Registration/Models/Vendor.dart';

class MedicalStoreVendorService {
  final Dio _dio = Dio();

  Future<Response> registerVendor({
    required Vendor vendor,
    required VendorMedicalStoreProfile medicalStore,
  }) async {
    // Check if the required fields are set and valid before sending
    if (vendor.phoneNumber == null || vendor.email == null || vendor.password == null) {
      throw Exception('Vendor information is incomplete');
    }

    if (medicalStore.name == null || medicalStore.address == null || medicalStore.ownerName.isEmpty) {
      throw Exception('Medical store details are incomplete');
    }

    try {
      final vendorData = vendor.toJson(); // Convert vendor to JSON
      final medicalStoreData = medicalStore.toJson(); // Convert medical store to JSON

      final data = {
        'vendor': vendorData,
        'medicalStore': medicalStoreData,
      };

      // Debug: Print the data being sent
      print("Request data: ${jsonEncode(data)}");

      final response = await _dio.post(
        ApiEndpoints.registerVendor, // Using the endpoint from ApiEndpoints class
        options: Options(
          headers: {'Content-Type': 'application/json'}, // Set the Content-Type header to application/json
        ),
        data: jsonEncode(data), // Convert combined data to JSON
      );

      // Debug: Print the response data
      print("Response status: ${response.statusCode}");
      print("Response data: ${response.data}");

      return response; // return the response
    } on DioError catch (e) {
      // Handle errors
      if (e.response != null) {
        // Debug: Print the error response data
        print("Error Response: ${e.response?.data}");
        return e.response!;
      } else {
        throw Exception('Network error: ${e.message}');
      }
    }
  }
}
