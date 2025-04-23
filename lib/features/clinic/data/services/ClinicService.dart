import 'package:dio/dio.dart';
import 'package:vedika_healthcare/core/constants/ApiEndpoints.dart';
import 'package:vedika_healthcare/features/Vendor/DoctorConsultationVendor/Models/DoctorClinicProfile.dart';

class ClinicService {
  final Dio _dio;

  ClinicService() : _dio = Dio() {
    // Configure Dio
    _dio.options.connectTimeout = Duration(seconds: 10);
    _dio.options.receiveTimeout = Duration(seconds: 10);
    _dio.options.headers = {
      'Content-Type': 'application/json',
      'Accept': 'application/json',
    };
    
    // Add interceptor for logging
    _dio.interceptors.add(LogInterceptor(
      requestBody: true,
      responseBody: true,
      error: true,
    ));
  }

  // Fetch active online clinics
  Future<List<DoctorClinicProfile>> getActiveOnlineClinics() async {
    print('🔍 Calling getActiveOnlineClinics API: ${ApiEndpoints.getActiveOnlineClinics}');
    try {
      final response = await _dio.get(
        ApiEndpoints.getActiveOnlineClinics,
        options: Options(
          validateStatus: (status) => status! < 500,
        ),
      );
      
      print('✅ API Response Status: ${response.statusCode}');
      print('✅ API Response Data Type: ${response.data.runtimeType}');
      
      // Debugging raw response structure
      if (response.data is Map && response.data.containsKey('clinics')) {
        final List<dynamic> data = response.data['clinics'] ?? [];
        print('✅ Data length: ${data.length}');
        
        // Debug consultationTypes field
        for (int i = 0; i < data.length && i < 3; i++) {
          final doctor = data[i];
          print('👨‍⚕️ Doctor ${i+1} consultationTypes raw data:');
          print('  - Type: ${doctor['consultationTypes'].runtimeType}');
          print('  - Raw value: ${doctor['consultationTypes']}');
        }

        return data.map((json) => DoctorClinicProfile.fromJson(json)).toList();
      } 
      // Check for the 'data' key in the response (our original expectation)
      else if (response.data is Map && response.data.containsKey('data')) {
        final List<dynamic> data = response.data['data'] ?? [];
        print('✅ Data length: ${data.length}');
        return data.map((json) => DoctorClinicProfile.fromJson(json)).toList();
      }
      // If neither key is present but response is a list
      else if (response.data is List) {
        final List<dynamic> data = response.data;
        print('✅ Data length: ${data.length}');
        return data.map((json) => DoctorClinicProfile.fromJson(json)).toList();
      } 
      // If none of the above, try one last approach
      else {
        print('⚠️ Unexpected data structure. Attempting further adaptations...');
        // Print all top-level keys to help diagnose
        if (response.data is Map) {
          print('Available keys in response: ${(response.data as Map).keys.toList()}');
          // Try to find any list in the response
          for (var key in (response.data as Map).keys) {
            if (response.data[key] is List && (response.data[key] as List).isNotEmpty) {
              final List<dynamic> data = response.data[key];
              print('✅ Found data in key "$key" with length: ${data.length}');
              return data.map((json) => DoctorClinicProfile.fromJson(json)).toList();
            }
          }
        }
        print('❌ Could not parse response data: ${response.data}');
        throw Exception('Unexpected data format');
      }
    } on DioException catch (e) {
      print('❌ Dio Exception in getActiveOnlineClinics:');
      print('  - Type: ${e.type}');
      print('  - Message: ${e.message}');
      print('  - Response: ${e.response?.statusCode}');
      
      if (e.type == DioExceptionType.connectionTimeout || 
          e.type == DioExceptionType.receiveTimeout ||
          e.type == DioExceptionType.connectionError) {
        throw Exception('Connection timeout. Please check your internet connection.');
      }
      throw Exception('Error fetching online clinics: ${e.message}');
    } catch (e) {
      print('❌ Exception in getActiveOnlineClinics: $e');
      throw Exception('Error fetching online clinics: $e');
    }
  }

  // Fetch active offline clinics
  Future<List<DoctorClinicProfile>> getActiveOfflineClinics() async {
    print('🔍 Calling getActiveOfflineClinics API: ${ApiEndpoints.getActiveOfflineClinics}');
    try {
      final response = await _dio.get(
        ApiEndpoints.getActiveOfflineClinics,
        options: Options(
          validateStatus: (status) => status! < 500,
        ),
      );
      
      print('✅ API Response Status: ${response.statusCode}');
      print('✅ API Response Data: ${response.data}');
      
      if (response.statusCode == 200) {
        // Check for the 'clinics' key in the response
        if (response.data is Map && response.data.containsKey('clinics')) {
          final List<dynamic> data = response.data['clinics'] ?? [];
          print('✅ Data length: ${data.length}');
          return data.map((json) => DoctorClinicProfile.fromJson(json)).toList();
        } 
        // Check for the 'data' key in the response (our original expectation)
        else if (response.data is Map && response.data.containsKey('data')) {
          final List<dynamic> data = response.data['data'] ?? [];
          print('✅ Data length: ${data.length}');
          return data.map((json) => DoctorClinicProfile.fromJson(json)).toList();
        }
        // If neither key is present but response is a list
        else if (response.data is List) {
          final List<dynamic> data = response.data;
          print('✅ Data length: ${data.length}');
          return data.map((json) => DoctorClinicProfile.fromJson(json)).toList();
        } 
        // If none of the above, try one last approach
        else {
          print('⚠️ Unexpected data structure. Attempting further adaptations...');
          // Print all top-level keys to help diagnose
          if (response.data is Map) {
            print('Available keys in response: ${(response.data as Map).keys.toList()}');
            // Try to find any list in the response
            for (var key in (response.data as Map).keys) {
              if (response.data[key] is List && (response.data[key] as List).isNotEmpty) {
                final List<dynamic> data = response.data[key];
                print('✅ Found data in key "$key" with length: ${data.length}');
                return data.map((json) => DoctorClinicProfile.fromJson(json)).toList();
              }
            }
          }
          print('❌ Could not parse response data: ${response.data}');
          throw Exception('Unexpected data format');
        }
      } else {
        print('❌ API Error: Failed to load offline clinics: ${response.statusCode}');
        throw Exception('Failed to load offline clinics: ${response.statusCode}');
      }
    } on DioException catch (e) {
      print('❌ Dio Exception in getActiveOfflineClinics:');
      print('  - Type: ${e.type}');
      print('  - Message: ${e.message}');
      print('  - Response: ${e.response?.statusCode}');
      
      if (e.type == DioExceptionType.connectionTimeout || 
          e.type == DioExceptionType.receiveTimeout ||
          e.type == DioExceptionType.connectionError) {
        throw Exception('Connection timeout. Please check your internet connection.');
      }
      throw Exception('Error fetching offline clinics: ${e.message}');
    } catch (e) {
      print('❌ Exception in getActiveOfflineClinics: $e');
      throw Exception('Error fetching offline clinics: $e');
    }
  }
  
  // Get clinic details by ID
  Future<DoctorClinicProfile> getClinicById(String clinicId) async {
    print('🔍 Calling getClinicById API: ${ApiEndpoints.getClinicProfile}/$clinicId');
    try {
      final response = await _dio.get(
        '${ApiEndpoints.getClinicProfile}/$clinicId',
        options: Options(
          validateStatus: (status) => status! < 500,
        ),
      );
      
      print('✅ API Response Status: ${response.statusCode}');
      
      if (response.statusCode == 200) {
        final dynamic data = response.data['data'];
        return DoctorClinicProfile.fromJson(data);
      } else {
        print('❌ API Error: Failed to load clinic details: ${response.statusCode}');
        throw Exception('Failed to load clinic details: ${response.statusCode}');
      }
    } on DioException catch (e) {
      print('❌ Dio Exception in getClinicById:');
      print('  - Type: ${e.type}');
      print('  - Message: ${e.message}');
      print('  - Response: ${e.response?.statusCode}');
      
      if (e.type == DioExceptionType.connectionTimeout || 
          e.type == DioExceptionType.receiveTimeout ||
          e.type == DioExceptionType.connectionError) {
        throw Exception('Connection timeout. Please check your internet connection.');
      }
      throw Exception('Error fetching clinic details: ${e.message}');
    } catch (e) {
      print('❌ Exception in getClinicById: $e');
      throw Exception('Error fetching clinic details: $e');
    }
  }

  // Create clinic appointment
  Future<Map<String, dynamic>> createClinicAppointment({
    required String doctorId,
    required String userId,
    required String status,
    required bool isOnline,
    required DateTime date,
    required String time,
    required double paidAmount,
    required String paymentStatus,
    required String vendorId,
    required String userResponseStatus,
    String? meetingUrl,
  }) async {
    print('🔍 Calling createClinicAppointment API: ${ApiEndpoints.createClinicAppointment}');
    try {
      final Map<String, dynamic> appointmentData = {
        "doctorId": doctorId,
        "userId": userId,
        "status": status,
        "isOnline": isOnline,
        "date": date.toIso8601String().split('T')[0], // Format as YYYY-MM-DD
        "time": time,
        "paidAmount": paidAmount,
        "paymentStatus": paymentStatus,
        "vendorId": vendorId,
        "userResponseStatus": userResponseStatus,
        "meetingUrl": meetingUrl,
      };

      print('📤 Sending appointment data: $appointmentData');
      
      final response = await _dio.post(
        ApiEndpoints.createClinicAppointment,
        data: appointmentData,
        options: Options(
          validateStatus: (status) => status! < 500,
        ),
      );
      
      print('✅ API Response Status: ${response.statusCode}');
      print('✅ API Response Data: ${response.data}');
      
      if (response.statusCode == 200 || response.statusCode == 201) {
        return {
          'success': true,
          'message': 'Appointment created successfully',
          'data': response.data['data'] ?? response.data,
        };
      } else {
        print('❌ API Error: Failed to create appointment: ${response.statusCode}');
        return {
          'success': false,
          'message': 'Failed to create appointment: ${response.statusMessage}',
        };
      }
    } on DioException catch (e) {
      print('❌ Dio Exception in createClinicAppointment:');
      print('  - Type: ${e.type}');
      print('  - Message: ${e.message}');
      print('  - Response: ${e.response?.statusCode}');
      
      return {
        'success': false,
        'message': 'Error creating appointment: ${e.message}',
      };
    } catch (e) {
      print('❌ Exception in createClinicAppointment: $e');
      return {
        'success': false,
        'message': 'Error creating appointment: $e',
      };
    }
  }
} 