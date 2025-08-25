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
    
    // Log interceptor removed for cleaner output
  }

  // Get all clinic appointments for the current user
  Future<List<ClinicAppointment>> getUserClinicAppointments() async {
    try {
      // Fetch the user ID from local storage
      final String? userId = await StorageService.getUserId();
      if (userId == null) {
        throw Exception('User ID not found. Please login again.');
      }

      final response = await _dio.get(
        '${ApiEndpoints.getClinicAppointmentsByUserId}/$userId',
        options: Options(
          validateStatus: (status) => status! < 500,
        ),
      );
      

      if (response.statusCode == 200) {
        final List<dynamic> appointmentsData = response.data is List 
            ? response.data 
            : response.data['appointments'] ?? response.data['data'] ?? [];
            

        return appointmentsData
            .map((json) => ClinicAppointment.fromJson(json))
            .toList();
      } else {
        throw Exception('Failed to load clinic appointments: ${response.statusCode}');
      }
    } on DioException catch (e) {
      if (e.type == DioExceptionType.connectionTimeout || 
          e.type == DioExceptionType.receiveTimeout ||
          e.type == DioExceptionType.connectionError) {
        throw Exception('Connection timeout. Please check your internet connection.');
      }
      throw Exception('Error fetching clinic appointments: ${e.message}');
    } catch (e) {
      throw Exception('Error fetching clinic appointments: $e');
    }
  }

  // Cancel a clinic appointment
  Future<bool> cancelClinicAppointment(String appointmentId) async {
    try {

      final response = await _dio.put(
        '${ApiEndpoints.createClinicAppointment}/$appointmentId/cancel',
        options: Options(
          validateStatus: (status) => status! < 500,
        ),
      );
      

      if (response.statusCode == 200) {
        return true;
      } else {
        throw Exception('Failed to cancel appointment: ${response.statusCode}');
      }
    } on DioException catch (e) {
      throw Exception('Error cancelling appointment: ${e.message}');
    } catch (e) {
      throw Exception('Error cancelling appointment: $e');
    }
  }
} 