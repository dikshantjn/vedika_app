import 'dart:convert';
import 'dart:io';
import 'package:dio/dio.dart';
import 'package:vedika_healthcare/core/constants/ApiEndpoints.dart';
import 'package:vedika_healthcare/features/Vendor/Registration/Models/VendorMedicalStoreProfile.dart';

class MedicineDeliveryService {
  final Dio _dio = Dio();
  
  // Get medical stores list
  Future<List<VendorMedicalStoreProfile>> getMedicalStores({
    String? searchQuery,
    String? medicineType,
  }) async {
    try {
      final response = await _dio.get(
        ApiEndpoints.getMedicalStores,
        options: Options(
          headers: {
            'Content-Type': 'application/json',
          },
        ),
      );

      if (response.statusCode == 200) {
        final Map<String, dynamic> responseData = response.data;
        
        if (responseData['success'] == true && responseData['data'] != null) {
          final List<dynamic> data = responseData['data'];
          return data.map((json) => VendorMedicalStoreProfile.fromJson(json)).toList();
        } else {
          throw Exception('API response indicates failure');
        }
      } else {
        throw Exception('Failed to load medical stores: ${response.statusCode}');
      }
    } on DioException catch (e) {
      throw Exception('Error fetching medical stores: ${e.message}');
    } catch (e) {
      throw Exception('Error fetching medical stores: $e');
    }
  }

  // Get medical store details by ID
  Future<VendorMedicalStoreProfile?> getMedicalStoreDetails(String vendorId) async {
    try {
      final stores = await getMedicalStores();
      return stores.firstWhere((store) => store.vendorId == vendorId);
    } catch (e) {
      return null;
    }
  }

  // Search medical stores by medicine
  Future<List<VendorMedicalStoreProfile>> searchStoresByMedicine(String medicineName) async {
    try {
      final allStores = await getMedicalStores();
      return allStores.where((store) {
        // Handle both string and list formats from API
        if (store.availableMedicines.isEmpty) return false;
        
        return store.availableMedicines.any((medicine) => 
          medicine.toLowerCase().contains(medicineName.toLowerCase())
        );
      }).toList();
    } catch (e) {
      throw Exception('Error searching stores: $e');
    }
  }

  // Get nearby medical stores (filter by location if needed)
  Future<List<VendorMedicalStoreProfile>> getNearbyStores({
    double? latitude,
    double? longitude,
    double radius = 10.0, // Default 10km radius
  }) async {
    try {
      final allStores = await getMedicalStores();
      // For now, return all stores. You can implement distance calculation later
      return allStores;
    } catch (e) {
      throw Exception('Error fetching nearby stores: $e');
    }
  }

  // Mock data for development/testing (fallback)
  List<VendorMedicalStoreProfile> getMockMedicalStores() {
    return [];
  }

  // Upload prescription files
  Future<Map<String, dynamic>> uploadPrescription({
    required String vendorId,
    required String userId,
    required List<File> files,
    required String quantityPreference,
    required String skipNotes,
    String? authToken,
  }) async {
    try {
      // Create FormData for multipart/form-data request
      FormData formData = FormData.fromMap({
        'vendorId': vendorId,
        'userId': userId,
        'quantityPreference': quantityPreference,
        'skipNotes': skipNotes,
      });

      // Add files to FormData - use 'files' as the key for each file
      for (int i = 0; i < files.length; i++) {
        formData.files.add(
          MapEntry(
            'files',
            await MultipartFile.fromFile(
              files[i].path,
              filename: files[i].path.split('/').last,
            ),
          ),
        );
      }

      // Add authorization header if provided
      Map<String, String> headers = {};
      
      if (authToken != null) {
        headers['Authorization'] = 'Bearer $authToken';
      }

      final response = await _dio.post(
        ApiEndpoints.sendPrescription,
        data: formData,
        options: Options(
          headers: headers,
        ),
      );

      if (response.statusCode == 201) {
        final Map<String, dynamic> responseData = response.data;
        return {
          'success': true,
          'data': responseData['data'],
          'message': responseData['message'],
        };
      } else {
        throw Exception('Failed to upload prescription: ${response.statusCode}');
      }
    } on DioException catch (e) {
      throw Exception('Error uploading prescription: ${e.message}');
    } catch (e) {
      throw Exception('Error uploading prescription: $e');
    }
  }
}
