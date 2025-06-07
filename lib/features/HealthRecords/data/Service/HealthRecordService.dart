import 'package:dio/dio.dart';
import 'package:vedika_healthcare/core/auth/data/services/StorageService.dart';
import 'package:vedika_healthcare/core/constants/ApiEndpoints.dart';
import 'package:vedika_healthcare/features/HealthRecords/data/models/HealthRecord.dart';
import 'package:vedika_healthcare/features/Vendor/DoctorConsultationVendor/Models/ClinicAppointment.dart';

class HealthRecordService {
  final Dio _dio = Dio();

  Future<List<HealthRecord>> fetchRecords() async {
    try {
      String? userId = await StorageService.getUserId();
      if (userId == null) {
        throw Exception('User ID not found');
      }

      print('📤 Fetching health records for user: $userId');
      final response = await _dio.get(
        '${ApiEndpoints.getHealthRecords}/$userId',
      );

      print('📥 Response received:');
      print('   Status Code: ${response.statusCode}');
      print('   Response Data: ${response.data}');

      if (response.statusCode == 200) {
        final List<dynamic> recordsJson = response.data['data'];
        return recordsJson.map((json) => HealthRecord.fromJson(json)).toList();
      } else {
        throw Exception('Failed to fetch health records: ${response.statusCode}');
      }
    } catch (e) {
      print('❌ Error fetching records: $e');
      if (e is DioException) {
        print('📡 API Error Details:');
        print('   Status Code: ${e.response?.statusCode}');
        print('   Response Data: ${e.response?.data}');
        print('   Error Type: ${e.type}');
        print('   Error Message: ${e.message}');
      }
      return [];
    }
  }

  Future<HealthRecord> addRecord(HealthRecord record) async {
    try {
      print('📤 Sending request to add health record:');
      print('   URL: ${ApiEndpoints.addHealthRecord}');
      print('   Request Body: ${record.toJson()}');

      final response = await _dio.post(
        ApiEndpoints.addHealthRecord,
        data: record.toJson(),
      );

      print('📥 Response received:');
      print('   Status Code: ${response.statusCode}');
      print('   Response Data: ${response.data}');

      if (response.statusCode == 200 || response.statusCode == 201) {
        return HealthRecord.fromJson(response.data['data']);
      } else {
        throw Exception('Failed to add health record: ${response.statusCode}');
      }
    } catch (e) {
      print('❌ Error adding health record: $e');
      if (e is DioException) {
        print('📡 API Error Details:');
        print('   Status Code: ${e.response?.statusCode}');
        print('   Response Data: ${e.response?.data}');
        print('   Error Type: ${e.type}');
        print('   Error Message: ${e.message}');
      }
      throw Exception('Error adding health record: $e');
    }
  }

  Future<void> deleteRecord(String healthRecordId) async {
    try {
      print('🗑️ Deleting record with healthRecordId: $healthRecordId');
      final response = await _dio.delete(
        '${ApiEndpoints.deleteHealthRecord}/$healthRecordId',
      );

      print('📥 Delete response received:');
      print('   Status Code: [32m${response.statusCode}[0m');
      print('   Response Data: ${response.data}');

      if (response.statusCode != 200) {
        throw Exception('Failed to delete health record: ${response.statusCode}');
      }
    } catch (e) {
      print('❌ Error deleting record: $e');
      if (e is DioException) {
        print('📡 API Error Details:');
        print('   Status Code: ${e.response?.statusCode}');
        print('   Response Data: ${e.response?.data}');
        print('   Error Type: ${e.type}');
        print('   Error Message: ${e.message}');
      }
      throw Exception('Error deleting record: $e');
    }
  }

  Future<HealthRecord> updateRecord(HealthRecord record) async {
    try {
      // TODO: Implement update record API
      print('📝 Update record: ${record.toJson()}');
      return record;
    } catch (e) {
      print('❌ Error updating record: $e');
      if (e is DioException) {
        print('📡 API Error Details:');
        print('   Status Code: ${e.response?.statusCode}');
        print('   Response Data: ${e.response?.data}');
        print('   Error Type: ${e.type}');
        print('   Error Message: ${e.message}');
      }
      throw Exception('Error updating record: $e');
    }
  }

  Future<List<ClinicAppointment>> getOngoingMeetings(String userId) async {
    print('🔄 Starting getOngoingMeetings API call');
    try {
      print('📤 Fetching ongoing meetings for user: $userId');
      print('   API Endpoint: ${ApiEndpoints.getOngoingMeetings}/$userId');
      
      final response = await _dio.get(
        '${ApiEndpoints.getOngoingMeetings}/$userId',
      );

      print('📥 Response received:');
      print('   Status Code: ${response.statusCode}');
      print('   Response Data: ${response.data}');

      if (response.statusCode == 200) {
        final List<dynamic> meetingsJson = response.data['data'];
        final meetings = meetingsJson.map((json) => ClinicAppointment.fromJson(json)).toList();
        print('✅ Successfully parsed ${meetings.length} meetings');
        return meetings;
      } else {
        print('❌ Failed to fetch ongoing meetings: ${response.statusCode}');
        throw Exception('Failed to fetch ongoing meetings: ${response.statusCode}');
      }
    } catch (e) {
      print('❌ Error in getOngoingMeetings: $e');
      if (e is DioException) {
        print('📡 API Error Details:');
        print('   Status Code: ${e.response?.statusCode}');
        print('   Response Data: ${e.response?.data}');
        print('   Error Type: ${e.type}');
        print('   Error Message: ${e.message}');
      }
      return [];
    }
  }

  Future<bool> shareHealthRecords({
    required String clinicAppointmentId,
    required String userId,
    required List<String> healthRecordIds,
  }) async {
    try {
      print('📡 Sharing health records...');
      print('👤 User ID: $userId');
      print('📋 Health Record IDs: $healthRecordIds');
      print('🏥 Clinic Appointment ID: $clinicAppointmentId');

      final response = await _dio.post(
        ApiEndpoints.shareHealthRecords,
        data: {
          'clinicAppointmentId': clinicAppointmentId,
          'userId': userId,
          'healthRecordIds': healthRecordIds,
        },
      );

      print('📥 Response status: ${response.statusCode}');
      print('📦 Response data: ${response.data}');

      if (response.statusCode == 200) {
        final data = response.data;
        if (data['success'] == true) {
          print('✅ Health records shared successfully');
          return true;
        }
      }

      print('❌ Failed to share health records');
      return false;
    } catch (e) {
      print('❌ Error sharing health records: $e');
      if (e is DioException) {
        print('📡 API Error Details:');
        print('   Status Code: ${e.response?.statusCode}');
        print('   Response Data: ${e.response?.data}');
        print('   Error Type: ${e.type}');
        print('   Error Message: ${e.message}');
      }
      return false;
    }
  }

  Future<bool> checkHealthRecordPasswordSet(String userId) async {
    try {
      print('🔍 Checking if health record password is set for user: $userId');
      final response = await _dio.get(
        '${ApiEndpoints.checkHealthRecordPassword}/$userId/health-record-password/check',
      );

      print('📥 Response received:');
      print('   Status Code: ${response.statusCode}');
      print('   Response Data: ${response.data}');

      if (response.statusCode == 200) {
        final data = response.data;
        return data['healthRecordPasswordSet'] ?? false;
      } else {
        throw Exception('Failed to check health record password: ${response.statusCode}');
      }
    } catch (e) {
      print('❌ Error checking health record password: $e');
      if (e is DioException) {
        print('📡 API Error Details:');
        print('   Status Code: ${e.response?.statusCode}');
        print('   Response Data: ${e.response?.data}');
        print('   Error Type: ${e.type}');
        print('   Error Message: ${e.message}');
      }
      return false;
    }
  }

  Future<bool> setHealthRecordPassword(String userId, String newPassword) async {
    try {
      print('🔐 Setting health record password for user: $userId');
      final response = await _dio.post(
        '${ApiEndpoints.setHealthRecordPassword}/$userId/health-record-password',
        data: {
          'newPassword': newPassword,
        },
      );

      print('📥 Response received:');
      print('   Status Code: ${response.statusCode}');
      print('   Response Data: ${response.data}');

      if (response.statusCode == 200) {
        final data = response.data;
        return data['success'] ?? false;
      } else {
        throw Exception('Failed to set health record password: ${response.statusCode}');
      }
    } catch (e) {
      print('❌ Error setting health record password: $e');
      if (e is DioException) {
        print('📡 API Error Details:');
        print('   Status Code: ${e.response?.statusCode}');
        print('   Response Data: ${e.response?.data}');
        print('   Error Type: ${e.type}');
        print('   Error Message: ${e.message}');
      }
      return false;
    }
  }

  Future<bool> verifyHealthRecordPassword(String userId, String password) async {
    try {
      print('🔐 Verifying health record password for user: $userId');
      final response = await _dio.post(
        '${ApiEndpoints.verifyHealthRecordPassword}/$userId/verify-health-record-password',
        data: {
          'password': password,
        },
      );

      print('📥 Response received:');
      print('   Status Code: ${response.statusCode}');
      print('   Response Data: ${response.data}');

      if (response.statusCode == 200) {
        final data = response.data;
        return data['success'] ?? false;
      } else {
        throw Exception('Failed to verify health record password: ${response.statusCode}');
      }
    } catch (e) {
      print('❌ Error verifying health record password: $e');
      if (e is DioException) {
        print('📡 API Error Details:');
        print('   Status Code: ${e.response?.statusCode}');
        print('   Response Data: ${e.response?.data}');
        print('   Error Type: ${e.type}');
        print('   Error Message: ${e.message}');
      }
      return false;
    }
  }
} 