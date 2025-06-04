import 'package:dio/dio.dart';
import 'package:vedika_healthcare/core/auth/data/services/StorageService.dart';
import 'package:vedika_healthcare/core/constants/ApiEndpoints.dart';
import 'package:vedika_healthcare/features/HealthRecords/data/models/HealthRecord.dart';

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
} 