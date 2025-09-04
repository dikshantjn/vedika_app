import 'dart:convert';
import 'package:logger/logger.dart';
import 'package:vedika_healthcare/core/constants/ApiEndpoints.dart';
import 'package:vedika_healthcare/features/Vendor/DoctorConsultationVendor/Models/DoctorClinicTimeslotModel.dart';
import 'package:vedika_healthcare/features/Vendor/Registration/Services/VendorLoginService.dart';
import 'package:dio/dio.dart';

class DoctorClinicTimeslotService {
  final Logger _logger = Logger(
    printer: PrettyPrinter(
      methodCount: 0,
      errorMethodCount: 5,
      lineLength: 50,
      colors: true,
      printEmojis: true,
      printTime: true,
    ),
  );

  final VendorLoginService _loginService = VendorLoginService();
  final Dio _dio = Dio();

  // Constructor to initialize Dio with options
  DoctorClinicTimeslotService() {
    _dio.options = BaseOptions(
      connectTimeout: const Duration(seconds: 30),
      receiveTimeout: const Duration(seconds: 30),
      headers: {
        'Content-Type': 'application/json',
        'Accept': 'application/json',
      },
    );
  }



  // Get vendor timeSlotID from secure storage
  Future<String?> getVendorId() async {
    return await _loginService.getVendorId();
  }

  /// Create a new timeslot
  Future<bool> createTimeslot(DoctorClinicTimeslotModel timeslot) async {
    try {
      _logger.i('📝 Creating timeslot for vendor: ${timeslot.vendorId}');

      // Create timeslot with generated slots
      final newTimeslot = timeslot.copyWith(
        generatedSlots: timeslot.generateTimeSlots(),
        createdAt: DateTime.now(),
        updatedAt: DateTime.now(),
      );

      final requestData = newTimeslot.toJson();

      final response = await _dio.post(
        ApiEndpoints.createClinicTimeslot,
        data: requestData,
      );

      if (response.statusCode == 200 || response.statusCode == 201) {
        _logger.i('✅ Timeslot created successfully!');
        return true;
      } else {
        _logger.e('❌ Failed to create timeslot. Status code: ${response.statusCode}');
        return false;
      }
    } catch (e) {
      _logger.e('❌ Error creating timeslot: $e');

      if (e is DioException) {
        if (e.response != null) {
          _logger.e('Response data: ${e.response?.data}');
          _logger.e('Response status code: ${e.response?.statusCode}');
        }
      }

      return false;
    }
  }

  /// Get all timeslots for a vendor
  Future<List<DoctorClinicTimeslotModel>> getTimeslots(String vendorId) async {
    try {
      _logger.i('📝 Fetching timeslots for vendor: $vendorId');

      final response = await _dio.get(
        '${ApiEndpoints.getClinicTimeslotsByVendor}/$vendorId',
      );

      if (response.statusCode == 200) {
        _logger.i('✅ Timeslots fetched successfully!');

        if (response.data != null && response.data is List) {
          final timeslotsData = response.data as List;
          final timeslots = timeslotsData
              .map((slot) => DoctorClinicTimeslotModel.fromJson(slot))
              .toList();

          _logger.i('Found ${timeslots.length} timeslots for vendor $vendorId');
          return timeslots;
        }

        _logger.i('No timeslots found for vendor $vendorId');
        return [];
      } else {
        _logger.e('❌ Failed to fetch timeslots. Status code: ${response.statusCode}');
        return [];
      }
    } catch (e) {
      _logger.e('❌ Error fetching timeslots: $e');

      if (e is DioException) {
        if (e.response != null) {
          _logger.e('Response data: ${e.response?.data}');
          _logger.e('Response status code: ${e.response?.statusCode}');
        }
      }

      return [];
    }
  }



  /// Update an existing timeslot
  Future<bool> updateTimeslot(String timeSlotID, DoctorClinicTimeslotModel timeslot) async {
    try {
      _logger.i('📝 Updating timeslot: $timeSlotID');

      final requestData = timeslot.copyWith(
        timeSlotID: timeSlotID,
        generatedSlots: timeslot.generateTimeSlots(),
        updatedAt: DateTime.now(),
      ).toJson();
      _logger.i('📝 Update payload: $requestData');

      final response = await _dio.put(
        '${ApiEndpoints.updateClinicTimeslot}/$timeSlotID',
        data: requestData,
      );

      if (response.statusCode == 200 || response.statusCode == 201) {
        _logger.i('✅ Timeslot updated successfully!');
        return true;
      } else {
        _logger.e('❌ Failed to update timeslot. Status code: ${response.statusCode}');
        return false;
      }
    } catch (e) {
      _logger.e('❌ Error updating timeslot: $e');

      if (e is DioException) {
        if (e.response != null) {
          _logger.e('Response data: ${e.response?.data}');
          _logger.e('Response status code: ${e.response?.statusCode}');
        }
      }

      return false;
    }
  }

  /// Delete a timeslot
  Future<bool> deleteTimeslot(String timeSlotID) async {
    try {
      _logger.i('📝 Deleting timeslot: $timeSlotID');

      final response = await _dio.delete(
        '${ApiEndpoints.deleteClinicTimeslot}/$timeSlotID',
      );

      if (response.statusCode == 200 || response.statusCode == 204) {
        _logger.i('✅ Timeslot deleted successfully!');
        return true;
      } else {
        _logger.e('❌ Failed to delete timeslot. Status code: ${response.statusCode}');
        return false;
      }
    } catch (e) {
      _logger.e('❌ Error deleting timeslot: $e');

      if (e is DioException) {
        if (e.response != null) {
          _logger.e('Response data: ${e.response?.data}');
          _logger.e('Response status code: ${e.response?.statusCode}');
        }
      }

      return false;
    }
  }

  /// Delete specific slots from a timeslot
  Future<Map<String, dynamic>?> deleteSpecificSlots(String timeSlotID, List<String> slotsToDelete) async {
    try {
      _logger.i('📝 Deleting specific slots from timeslot: $timeSlotID');
      _logger.i('📝 Slots to delete: $slotsToDelete');

      final response = await _dio.patch(
        '${ApiEndpoints.updateClinicTimeslot}/$timeSlotID/delete-slots',
        data: {
          'slotsToDelete': slotsToDelete,
        },
      );

      if (response.statusCode == 200) {
        _logger.i('✅ Specific slots deleted successfully!');
        return response.data;
      } else {
        _logger.e('❌ Failed to delete specific slots. Status code: ${response.statusCode}');
        return null;
      }
    } catch (e) {
      _logger.e('❌ Error deleting specific slots: $e');

      if (e is DioException) {
        if (e.response != null) {
          _logger.e('Response data: ${e.response?.data}');
          _logger.e('Response status code: ${e.response?.statusCode}');
        }
      }

      return null;
    }
  }

  /// Toggle timeslot active status
  Future<bool> toggleTimeslotStatus(String timeSlotID, bool isActive) async {
    try {
      _logger.i('📝 Toggling timeslot status: $timeSlotID to ${isActive ? 'active' : 'inactive'}');

      final response = await _dio.patch(
        '${ApiEndpoints.updateClinicTimeslot}/$timeSlotID/toggle-status',
        data: {'isActive': isActive},
      );

      if (response.statusCode == 200) {
        _logger.i('✅ Timeslot status updated successfully!');
        return true;
      } else {
        _logger.e('❌ Failed to update timeslot status. Status code: ${response.statusCode}');
        return false;
      }
    } catch (e) {
      _logger.e('❌ Error toggling timeslot status: $e');

      if (e is DioException) {
        if (e.response != null) {
          _logger.e('Response data: ${e.response?.data}');
          _logger.e('Response status code: ${e.response?.statusCode}');
        }
      }

      return false;
    }
  }

  /// Get timeslots for a specific day
  Future<List<DoctorClinicTimeslotModel>> getTimeslotsByDay(String vendorId, String day) async {
    try {
      _logger.i('📝 Fetching timeslots for vendor: $vendorId on day: $day');

      final response = await _dio.get(
        '${ApiEndpoints.getClinicTimeslotsByVendor}/$vendorId?day=$day',
      );

      if (response.statusCode == 200) {
        if (response.data != null && response.data is List) {
          final timeslotsData = response.data as List;
          final timeslots = timeslotsData
              .map((slot) => DoctorClinicTimeslotModel.fromJson(slot))
              .toList();

          _logger.i('✅ Timeslots fetched successfully! Found ${timeslots.length} timeslots for $day');
          return timeslots;
        }

        _logger.i('No timeslots found for vendor $vendorId on $day');
        return [];
      } else {
        _logger.e('❌ Failed to fetch timeslots. Status code: ${response.statusCode}');
        return [];
      }
    } catch (e) {
      _logger.e('❌ Error fetching timeslots by day: $e');

      if (e is DioException) {
        if (e.response != null) {
          _logger.e('Response data: ${e.response?.data}');
          _logger.e('Response status code: ${e.response?.statusCode}');
        }
      }

      return [];
    }
  }

  /// Validate timeslot data
  Map<String, String> validateTimeslot(DoctorClinicTimeslotModel timeslot) {
    return timeslot.validate();
  }



  /// Get current doctor's timeslots (convenience method)
  Future<List<DoctorClinicTimeslotModel>> getCurrentDoctorTimeslots() async {
    try {
      _logger.i('📝 Fetching timeslots for current doctor');

      final String? vendorId = await getVendorId();

      if (vendorId == null) {
        _logger.e('❌ No vendor ID found in storage');
        return [];
      }

      return await getTimeslots(vendorId);
    } catch (e) {
      _logger.e('❌ Error fetching current doctor timeslots: $e');
      return [];
    }
  }
}
