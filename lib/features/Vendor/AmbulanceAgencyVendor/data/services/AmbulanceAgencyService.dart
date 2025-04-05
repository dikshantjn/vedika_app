import 'dart:convert';
import 'package:dio/dio.dart';
import 'package:vedika_healthcare/core/constants/ApiEndpoints.dart';
import 'package:vedika_healthcare/features/Vendor/AmbulanceAgencyVendor/data/modals/AmbulanceAgency.dart';
import 'package:vedika_healthcare/features/Vendor/Registration/Models/Vendor.dart';

class AmbulanceAgencyService {
  final Dio _dio = Dio();

  // 🚑 Register Agency
  Future<Response> registerAgencyWithVendor({
    required Vendor vendor,
    required AmbulanceAgency agency,
  }) async {
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

  // 📄 Get Agency Profile
  Future<AmbulanceAgency> getAgencyProfile(String vendorId) async {
    try {
      final response = await _dio.get("${ApiEndpoints.getAmbulanceAgencyProfile}/$vendorId");

      if (response.statusCode == 200 && response.data['success'] == true) {
        final data = response.data['data'];
        print("✅ Get Agency Profile: $data");

        return AmbulanceAgency.fromJson(data); // Make sure you have a `fromJson` method
      } else {
        throw Exception("Failed to load agency profile");
      }
    } on DioException catch (e) {
      print("❌ Dio Error: ${e.response?.data ?? e.message}");
      throw Exception("Failed to fetch agency profile: ${e.response?.data ?? e.message}");
    } catch (e) {
      print("❌ Unexpected Error: $e");
      throw Exception("Unexpected error: $e");
    }
  }

  // 🔁 Update Media Files (officePhotos or trainingCertifications)
  Future<void> updateMediaItem({
    required String vendorId,
    required String fileType, // 'officePhotos' or 'trainingCertifications'
    required String oldName,
    required Map<String, String> newItem, // { name, url }
  }) async {
    try {
      final response = await _dio.put(
        "${ApiEndpoints.updateMediaItem}/$vendorId/media",
        options: Options(headers: {'Content-Type': 'application/json'}),
        data: jsonEncode({
          'fileType': fileType,
          'oldName': oldName,
          'newItem': newItem,
        }),
      );

      if (response.statusCode == 200 && response.data['success'] == true) {
        print("✅ Media item updated successfully.");
      } else {
        throw Exception("⚠️ Failed to update media item: ${response.data}");
      }
    } on DioException catch (e) {
      print("❌ Dio Error (updateMediaItem): ${e.response?.data ?? e.message}");
      throw Exception("Failed to update media item: ${e.response?.data ?? e.message}");
    }
  }


  Future<void> deleteMediaItem({
    required String vendorId,
    required String fileType, // 'officePhotos' or 'trainingCertifications'
    required String name, // name of the file to delete
  }) async {
    try {
      final response = await _dio.delete(
        "${ApiEndpoints.deleteMediaItem}/$vendorId/media",
        options: Options(headers: {'Content-Type': 'application/json'}),
        data: jsonEncode({
          'fileType': fileType,
          'name': name,
        }),
      );

      if (response.statusCode == 200 && response.data['success'] == true) {
        print("✅ Media item deleted successfully.");
      } else {
        throw Exception("⚠️ Failed to delete media item: ${response.data}");
      }
    } on DioException catch (e) {
      print("❌ Dio Error (deleteMediaItem): ${e.response?.data ?? e.message}");
      throw Exception("Failed to delete media item: ${e.response?.data ?? e.message}");
    }
  }

  // 🔽 Add Media Item (officePhotos or trainingCertifications)
  Future<void> addMediaItem({
    required String vendorId,
    required String fileType, // 'officePhotos' or 'trainingCertifications'
    required Map<String, String> newItem, // { name, url }
  }) async {
    try {
      final response = await _dio.post(
        "${ApiEndpoints.addMediaItem}/$vendorId/media/addItems",
        options: Options(headers: {'Content-Type': 'application/json'}),
        data: jsonEncode({
          'fileType': fileType,
          'newItem': newItem,
        }),
      );

      if (response.statusCode == 200 && response.data['success'] == true) {
        print("✅ Media item added successfully.");
      } else {
        throw Exception("⚠️ Failed to add media item: ${response.data}");
      }
    } on DioException catch (e) {
      print("❌ Dio Error (addMediaItem): ${e.response?.data ?? e.message}");
      throw Exception("Failed to add media item: ${e.response?.data ?? e.message}");
    } catch (e) {
      print("❌ Unexpected Error (addMediaItem): $e");
      throw Exception("Unexpected error: $e");
    }
  }

  // 🛠️ Update Agency Profile
  Future<void> updateAgencyProfile({
    required String vendorId,
    required AmbulanceAgency updatedAgency,
  }) async {
    try {
      final data = updatedAgency.toJson();

      // Send PUT request to update the profile
      final response = await _dio.put(
        "${ApiEndpoints.updateAgencyProfile}/$vendorId/updateProfile",
        options: Options(headers: {'Content-Type': 'application/json'}),
        data: jsonEncode(data),
      );

      if (response.statusCode == 200 && response.data['success'] == true) {
        print("✅ Agency Profile Updated Successfully: ${response.data['message']}");
      } else {
        throw Exception("⚠️ Failed to update agency profile: ${response.data}");
      }
    } on DioException catch (e) {
      print("❌ Dio Error (updateAgencyProfile): ${e.response?.data ?? e.message}");
      throw Exception("Failed to update agency profile: ${e.response?.data ?? e.message}");
    } catch (e) {
      print("❌ Unexpected Error (updateAgencyProfile): $e");
      throw Exception("Unexpected error: $e");
    }
  }
}
