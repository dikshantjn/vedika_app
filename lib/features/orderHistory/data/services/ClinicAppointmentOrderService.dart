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

  // Cancel an appointment with reason
  Future<Map<String, dynamic>> cancelAppointmentWithReason({
    required String appointmentId,
    required String cancelReason,
  }) async {
    try {
      print('[ClinicAppointmentOrderService] Cancelling appointment: ID=$appointmentId, reason=$cancelReason');
      
      final String url = '${ApiEndpoints.cancelClinicAppointment}/$appointmentId/cancel';
      print('[ClinicAppointmentOrderService] Making PUT request to: $url');
      
      final response = await _dio.put(
        url,
        data: {
          'cancelBy': 'user',
          'cancelReason': cancelReason,
        },
        options: Options(
          validateStatus: (status) => status! < 500,
        ),
      );

      print('[ClinicAppointmentOrderService] Response status code: ${response.statusCode}');
      print('[ClinicAppointmentOrderService] Response data: ${response.data}');

      if (response.statusCode == 200) {
        print('[ClinicAppointmentOrderService] Successfully cancelled appointment');
        return {
          'success': true,
          'message': response.data['message'] ?? 'Appointment cancelled successfully',
          'appointment': response.data['appointment'],
        };
      } else {
        print('[ClinicAppointmentOrderService] Failed to cancel appointment: ${response.statusCode}');
        return {
          'success': false,
          'message': 'Failed to cancel appointment: ${response.statusCode}',
        };
      }
    } catch (e) {
      print('[ClinicAppointmentOrderService] Error cancelling appointment: $e');
      return {
        'success': false,
        'message': 'Error cancelling appointment: $e',
      };
    }
  }

  // Reschedule a clinic appointment
  Future<Map<String, dynamic>> rescheduleClinicAppointment({
    required String appointmentId,
    required String date,
    required String time,
  }) async {
    try {
      final response = await _dio.put(
        '${ApiEndpoints.rescheduleClinicAppointment}/$appointmentId/reschedule',
        data: {
          'date': date,
          'time': time,
          'by': 'user',
        },
        options: Options(
          validateStatus: (status) => status! < 500,
        ),
      );

      if (response.statusCode == 200) {
        return {
          'success': true,
          'message': response.data['message'] ?? 'Appointment rescheduled successfully',
          'appointment': response.data['appointment'],
          'bookedSlot': response.data['bookedSlot'],
        };
      } else {
        return {
          'success': false,
          'message': response.data['message'] ?? 'Failed to reschedule appointment: ${response.statusCode}',
        };
      }
    } on DioException catch (e) {
      return {
        'success': false,
        'message': 'Error rescheduling appointment: ${e.message}',
      };
    } catch (e) {
      return {
        'success': false,
        'message': 'Error rescheduling appointment: $e',
      };
    }
  }

  // Update appointment attendance status
  Future<Map<String, dynamic>> updateAppointmentAttendance({
    required String appointmentId,
    required String status, // "no_call" or "no_show"
  }) async {
    try {
      final response = await _dio.put(
        '${ApiEndpoints.updateAppointmentAttendance}/$appointmentId/attendance',
        data: {
          'role': 'user',
          'status': status,
        },
        options: Options(
          validateStatus: (status) => status! < 500,
        ),
      );

      if (response.statusCode == 200) {
        return {
          'success': true,
          'message': response.data['message'] ?? 'Attendance status updated successfully',
          'appointment': response.data['appointment'],
        };
      } else {
        return {
          'success': false,
          'message': response.data['message'] ?? 'Failed to update attendance: ${response.statusCode}',
        };
      }
    } on DioException catch (e) {
      return {
        'success': false,
        'message': 'Error updating attendance: ${e.message}',
      };
    } catch (e) {
      return {
        'success': false,
        'message': 'Error updating attendance: $e',
      };
    }
  }
} 