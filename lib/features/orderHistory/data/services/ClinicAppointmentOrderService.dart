import 'package:dio/dio.dart';
import 'package:vedika_healthcare/core/auth/data/services/StorageService.dart';
import 'package:vedika_healthcare/core/constants/ApiEndpoints.dart';
import 'package:vedika_healthcare/features/Vendor/DoctorConsultationVendor/Models/ClinicAppointment.dart';

class ClinicAppointmentOrderService {
  final Dio _dio;

  ClinicAppointmentOrderService() : _dio = Dio() {
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

  // Get all clinic appointments for the current user
  Future<List<ClinicAppointment>> getUserClinicAppointments() async {
    try {
      // Fetch the user ID from local storage
      final String? userId = await StorageService.getUserId();
      if (userId == null) {
        throw Exception('User ID not found. Please login again.');
      }

      print('🔍 Fetching clinic appointments for user: $userId');
      
      final response = await _dio.get(
        '${ApiEndpoints.getClinicAppointmentsByUserId}/$userId',
        options: Options(
          validateStatus: (status) => status! < 500,
        ),
      );
      
      print('✅ API Response Status: ${response.statusCode}');
      
      if (response.statusCode == 200) {
        final List<dynamic> appointmentsData = response.data is List 
            ? response.data 
            : response.data['appointments'] ?? response.data['data'] ?? [];
            
        print('✅ Fetched ${appointmentsData.length} clinic appointments');
        
        return appointmentsData
            .map((json) => ClinicAppointment.fromJson(json))
            .toList();
      } else {
        print('❌ API Error: Failed to load clinic appointments: ${response.statusCode}');
        print('❌ Response data: ${response.data}');
        throw Exception('Failed to load clinic appointments: ${response.statusCode}');
      }
    } on DioException catch (e) {
      print('❌ Dio Exception in getUserClinicAppointments:');
      print('  - Type: ${e.type}');
      print('  - Message: ${e.message}');
      print('  - Response: ${e.response?.statusCode} - ${e.response?.data}');
      
      if (e.type == DioExceptionType.connectionTimeout || 
          e.type == DioExceptionType.receiveTimeout ||
          e.type == DioExceptionType.connectionError) {
        throw Exception('Connection timeout. Please check your internet connection.');
      }
      throw Exception('Error fetching clinic appointments: ${e.message}');
    } catch (e) {
      print('❌ Exception in getUserClinicAppointments: $e');
      throw Exception('Error fetching clinic appointments: $e');
    }
  }

  // Cancel a clinic appointment
  Future<bool> cancelClinicAppointment(String appointmentId) async {
    try {
      print('🔄 Cancelling clinic appointment: $appointmentId');
      
      final response = await _dio.put(
        '${ApiEndpoints.createClinicAppointment}/$appointmentId/cancel',
        options: Options(
          validateStatus: (status) => status! < 500,
        ),
      );
      
      print('✅ API Response Status: ${response.statusCode}');
      
      if (response.statusCode == 200) {
        print('✅ Successfully cancelled clinic appointment');
        return true;
      } else {
        print('❌ API Error: Failed to cancel appointment: ${response.statusCode}');
        print('❌ Response data: ${response.data}');
        throw Exception('Failed to cancel appointment: ${response.statusCode}');
      }
    } on DioException catch (e) {
      print('❌ Dio Exception in cancelClinicAppointment:');
      print('  - Type: ${e.type}');
      print('  - Message: ${e.message}');
      print('  - Response: ${e.response?.statusCode} - ${e.response?.data}');
      
      throw Exception('Error cancelling appointment: ${e.message}');
    } catch (e) {
      print('❌ Exception in cancelClinicAppointment: $e');
      throw Exception('Error cancelling appointment: $e');
    }
  }
} 