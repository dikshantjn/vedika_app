import 'package:dio/dio.dart';
import 'package:vedika_healthcare/core/constants/ApiEndpoints.dart';
import 'package:vedika_healthcare/features/Vendor/BloodBankAgencyVendor/data/model/BloodInventory.dart';
import 'package:vedika_healthcare/features/Vendor/Registration/Services/VendorLoginService.dart';
import 'package:logger/logger.dart';

class BloodInventoryService {
  final Dio _dio = Dio();
  final VendorLoginService _loginService = VendorLoginService();
  final _logger = Logger();

  // Get the vendor ID from the login service
  Future<String?> getVendorId() async {
    return await _loginService.getVendorId();
  }

  // Add or update blood inventory
  Future<BloodInventory> upsertBloodInventory(BloodInventory bloodInventory) async {
    try {
      final vendorId = await getVendorId();
      if (vendorId == null) {
        throw Exception('Vendor ID not found');
      }

      // Ensure the blood inventory has the correct vendor ID
      final updatedInventory = BloodInventory(
        bloodInventoryId: bloodInventory.bloodInventoryId,
        vendorId: vendorId,
        bloodType: bloodInventory.bloodType,
        unitsAvailable: bloodInventory.unitsAvailable,
        isAvailable: bloodInventory.isAvailable,
      );

      _logger.i('Sending blood inventory data: ${updatedInventory.toJson()}');
      _logger.i('Is update operation: ${updatedInventory.bloodInventoryId != null}');
      _logger.i('Blood Inventory ID: ${updatedInventory.bloodInventoryId}');

      final response = await _dio.post(
        '${ApiEndpoints.AddBloodAvaibility}/$vendorId',
        data: updatedInventory.toJson(),
      );


      if (response.statusCode == 200 || response.statusCode == 201) {
        if (response.data is Map<String, dynamic>) {
          if (response.data['data'] != null) {
            return BloodInventory.fromJson(response.data['data']);
          } else if (response.data['message'] != null) {
            _logger.i('Operation successful: ${response.data['message']}');
            // If we have a success message but no data, return the original inventory
            return updatedInventory;
          } else {
            throw Exception('Invalid response format: ${response.data}');
          }
        } else {
          throw Exception('Invalid response format: ${response.data}');
        }
      } else {
        throw Exception('Failed to save blood inventory: ${response.statusMessage}');
      }
    } catch (e) {
      _logger.e('Error in upsertBloodInventory: $e');
      throw Exception('Error saving blood inventory: $e');
    }
  }

  // Get all blood inventory for the current vendor
  Future<List<BloodInventory>> getBloodInventory() async {
    try {
      final vendorId = await getVendorId();
      if (vendorId == null) {
        throw Exception('Vendor ID not found');
      }

      _logger.i('Fetching blood inventory for vendor: $vendorId');

      final response = await _dio.get(
        '${ApiEndpoints.getBloodAvaibility}/$vendorId',
      );

      _logger.i('Response received: ${response.data}');

      if (response.statusCode == 200) {
        if (response.data is Map<String, dynamic>) {
          if (response.data['inventory'] is List) {
            final List<dynamic> inventory = response.data['inventory'];
            return inventory.map((json) => BloodInventory.fromJson(json)).toList();
          } else if (response.data['inventory'] is Map<String, dynamic>) {
            // Handle single item response
            return [BloodInventory.fromJson(response.data['inventory'])];
          } else {
            throw Exception('Invalid response format: ${response.data}');
          }
        } else if (response.data is List) {
          final List<dynamic> data = response.data;
          return data.map((json) => BloodInventory.fromJson(json)).toList();
        } else {
          throw Exception('Invalid response format: ${response.data}');
        }
      } else {
        throw Exception('Failed to fetch blood inventory: ${response.statusMessage}');
      }
    } catch (e) {
      _logger.e('Error in getBloodInventory: $e');
      throw Exception('Error fetching blood inventory: $e');
    }
  }

  // Delete blood inventory
  Future<void> deleteBloodInventory(String bloodInventoryId) async {
    try {
      final vendorId = await getVendorId();
      if (vendorId == null) {
        throw Exception('Vendor ID not found');
      }

      _logger.i('Deleting blood inventory for bloodInventoryId: $bloodInventoryId');

      final response = await _dio.delete(
        '${ApiEndpoints.deleteBloodAvaibility}/$bloodInventoryId',
      );

      _logger.i('Delete response: ${response.data}');

      if (response.statusCode != 200 && response.statusCode != 204) {
        throw Exception('Failed to delete blood inventory: ${response.statusMessage}');
      }
    } catch (e) {
      _logger.e('Error in deleteBloodInventory: $e');
      throw Exception('Error deleting blood inventory: $e');
    }
  }
} 