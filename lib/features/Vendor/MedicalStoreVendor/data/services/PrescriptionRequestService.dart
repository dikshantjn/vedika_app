import 'package:dio/dio.dart';
import 'package:vedika_healthcare/core/constants/ApiEndpoints.dart';
import 'package:vedika_healthcare/features/Vendor/MedicalStoreVendor/data/models/PrescriptionRequestModel.dart';

class PrescriptionRequestService {
  final Dio _dio = Dio();

  /// **🔹 Fetch Prescription Requests by Vendor ID**
  Future<List<PrescriptionRequestModel>> fetchPrescriptionRequests(String? vendorId) async {
    try {
      if (vendorId == null || vendorId.isEmpty) {
        throw Exception("❌ Vendor ID is missing");
      }

      // Construct API URL with vendorId as path parameter
      String url = "${ApiEndpoints.getPrescritionRequests}/$vendorId";

      print("📡 Fetching Prescription Requests from: $url");

      Response response = await _dio.get(url);

      // 🔹 Print Full Response Data
      print("📥 Raw Response Data: ${response.data}");

      if (response.statusCode == 200) {
        final List<dynamic> data = response.data['prescriptions'] ?? [];

        print("✅ Prescription Requests Fetched: ${data.length}");

        // 🔹 Print each prescription JSON before conversion
        for (var i = 0; i < data.length; i++) {
          print("📝 Prescription $i: ${data[i]}");
        }

        return data.map((json) => PrescriptionRequestModel.fromJson(json)).toList();
      } else {
        throw Exception("❌ Failed to load prescription requests (Status: ${response.statusCode})");
      }
    } on DioException catch (e) {
      print("🚨 Dio Error: ${e.response?.data ?? e.message}");
      throw Exception("Network Error: Unable to fetch prescription requests");
    } catch (e) {
      print("🚨 Error fetching prescription requests: $e");
      throw Exception("Unexpected Error: Failed to fetch prescription requests");
    }
  }


  Future<bool> acceptPrescription(String prescriptionId, String vendorId) async {
    try {
      if (prescriptionId.isEmpty || vendorId.isEmpty) {
        throw Exception("❌ Prescription ID or Vendor ID is missing");
      }

      // API URL
      print("📡 Sending Accept Prescription Request to: ${ApiEndpoints.acceptPrescriptionRequest}");

      // Sending POST request
      Response response = await _dio.post(
        ApiEndpoints.acceptPrescriptionRequest,
        data: {
          "prescriptionId": prescriptionId,
          "vendorId": vendorId, // ✅ Added vendorId
        },
      );

      if (response.statusCode == 200) {
        print("✅ Prescription Accepted Successfully");
        return true;
      } else {
        throw Exception("❌ Failed to accept prescription (Status: ${response.statusCode})");
      }
    } on DioException catch (e) {
      print("🚨 Dio Error: ${e.response?.data ?? e.message}");
      throw Exception("Network Error: Unable to accept prescription");
    } catch (e) {
      print("🚨 Error accepting prescription: $e");
      throw Exception("Unexpected Error: Failed to accept prescription");
    }
  }

  /// **🔹 Fetch Prescription URL using Prescription ID**
  Future<String?> fetchPrescriptionUrl(int prescriptionId) async {
    try {
      if (prescriptionId <= 0) { // ✅ Check if prescriptionId is valid
        throw Exception("❌ Prescription ID is missing or invalid");
      }

      String url = "${ApiEndpoints.getPrescriptionUrl}/$prescriptionId"; // ✅ Construct API URL

      print("📡 Fetching Prescription URL from: $url");

      Response response = await _dio.get(url);

      if (response.statusCode == 200) {
        String? prescriptionUrl = response.data['prescription']?['prescriptionUrl']; // ✅ Corrected path

        if (prescriptionUrl == null || prescriptionUrl.isEmpty) {
          throw Exception("❌ Prescription URL not found");
        }

        print("✅ Prescription URL Fetched: $prescriptionUrl");
        return prescriptionUrl;
      } else {
        throw Exception("❌ Failed to fetch prescription URL (Status: ${response.statusCode})");
      }
    } on DioException catch (e) {
      print("🚨 Dio Error: ${e.response?.data ?? e.message}");
      throw Exception("Network Error: Unable to fetch prescription URL");
    } catch (e) {
      print("🚨 Error fetching prescription URL: $e");
      throw Exception("Unexpected Error: Failed to fetch prescription URL");
    }
  }


}
