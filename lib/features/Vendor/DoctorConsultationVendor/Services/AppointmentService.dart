import 'package:dio/dio.dart';
import 'package:vedika_healthcare/core/auth/data/services/StorageService.dart';
import 'package:vedika_healthcare/core/constants/ApiEndpoints.dart';
import 'package:vedika_healthcare/features/Vendor/DoctorConsultationVendor/Models/ClinicAppointment.dart';
import 'package:vedika_healthcare/features/Vendor/Registration/Services/VendorLoginService.dart';
import 'package:vedika_healthcare/core/auth/data/models/UserModel.dart';
import 'package:vedika_healthcare/features/Vendor/DoctorConsultationVendor/Models/DoctorClinicProfile.dart';

class AppointmentService {
  final Dio _dio = Dio();
  final VendorLoginService _vendorLoginService = VendorLoginService();
  
  // Get vendor ID from secure storage
  Future<String?> _getVendorId() async {
    return await _vendorLoginService.getVendorId();
  }

  /// Fetch pending appointments for a vendor
  Future<List<ClinicAppointment>> fetchPendingAppointments() async {
    try {
      // Get the vendor ID
      final String? vendorId = await _getVendorId();

      if (vendorId == null) {
        throw Exception('Vendor ID not found');
      }
      
      // Make API call to fetch pending appointments
      final String url = '${ApiEndpoints.getPendingClinicAppointmentsByVendor}/$vendorId/pending';

      final response = await _dio.get(url);

      if (response.statusCode == 200) {
        // Extract appointments from 'appointments' field instead of 'data'
        final List<dynamic> appointmentsData = response.data['appointments'] ?? [];

        final appointments = appointmentsData.map((json) => ClinicAppointment.fromJson(json)).toList();
        
        int onlineCount = 0;
        int offlineCount = 0;
        
        for (var appointment in appointments) {
          if (appointment.isOnline) {
            onlineCount++;
          } else {
            offlineCount++;
          }
        }
        

        return appointments;
      } else {
        print('[AppointmentService] Error response: ${response.statusCode} - ${response.data}');
        throw Exception('Failed to fetch pending appointments: ${response.statusCode}');
      }
    } catch (e) {
      print('[AppointmentService] Error fetching pending appointments: $e');
      throw Exception('Failed to fetch pending appointments: $e');
    }
  }

  /// Fetch completed appointments for a vendor
  Future<List<ClinicAppointment>> fetchCompletedAppointments() async {
    try {
      // Get the vendor ID
      final String? vendorId = await _getVendorId();
      print('[AppointmentService] Fetching completed appointments for vendorId: $vendorId');
      
      if (vendorId == null) {
        throw Exception('Vendor ID not found');
      }
      
      // Make API call to fetch completed appointments
      final String url = '${ApiEndpoints.getCompletedClinicAppointmentsByVendor}/$vendorId/completed';
      print('[AppointmentService] Making GET request to: $url');
      
      final response = await _dio.get(url);

      print('[AppointmentService] Response status code: ${response.statusCode}');
      print('[AppointmentService] Response data: ${response.data}');

      if (response.statusCode == 200) {
        // Extract appointments from 'appointments' field instead of 'data'
        final List<dynamic> appointmentsData = response.data['appointments'] ?? [];
        print('[AppointmentService] Raw appointments data: $appointmentsData');
        
        final appointments = appointmentsData.map((json) => ClinicAppointment.fromJson(json)).toList();
        
        print('[AppointmentService] Fetched ${appointments.length} completed appointments');
        print('[AppointmentService] Appointment types breakdown:');
        int onlineCount = 0;
        int offlineCount = 0;
        
        for (var appointment in appointments) {
          if (appointment.isOnline) {
            onlineCount++;
          } else {
            offlineCount++;
          }
          print('[AppointmentService] - ID: ${appointment.clinicAppointmentId}, isOnline: ${appointment.isOnline}, status: ${appointment.status}, date: ${appointment.date}, time: ${appointment.time}');
        }
        
        print('[AppointmentService] Online appointments: $onlineCount, Offline appointments: $offlineCount');
        
        return appointments;
      } else {
        print('[AppointmentService] Error response: ${response.statusCode} - ${response.data}');
        throw Exception('Failed to fetch completed appointments: ${response.statusCode}');
      }
    } catch (e) {
      print('[AppointmentService] Error fetching completed appointments: $e');
      throw Exception('Failed to fetch completed appointments: $e');
    }
  }

  /// Fetch all appointments for a vendor
  Future<List<ClinicAppointment>> fetchAppointments() async {
    try {
      print('[AppointmentService] Fetching all appointments (pending + completed)');
      
      // Get pending and completed appointments
      final List<ClinicAppointment> pendingAppointments = await fetchPendingAppointments();
      final List<ClinicAppointment> completedAppointments = await fetchCompletedAppointments();
      
      // Combine the lists
      final List<ClinicAppointment> allAppointments = [...pendingAppointments, ...completedAppointments];
      
      print('[AppointmentService] Total appointments fetched: ${allAppointments.length}');
      print('[AppointmentService] - Pending: ${pendingAppointments.length}');
      print('[AppointmentService] - Completed: ${completedAppointments.length}');
      
      return allAppointments;
    } catch (e) {
      print('[AppointmentService] Error fetching all appointments: $e');
      throw Exception('Failed to fetch all appointments: $e');
    }
  }

  /// Update appointment status
  Future<bool> updateAppointmentStatus(String appointmentId, String newStatus) async {
    try {
      print('[AppointmentService] Updating appointment status: ID=$appointmentId, newStatus=$newStatus');
      
      final String url = '${ApiEndpoints.createClinicAppointment}/$appointmentId/status';
      print('[AppointmentService] Making PUT request to: $url');
      
      final response = await _dio.put(
        url,
        data: {
          'status': newStatus,
        },
      );

      print('[AppointmentService] Response status code: ${response.statusCode}');
      print('[AppointmentService] Response data: ${response.data}');

      return response.statusCode == 200;
    } catch (e) {
      print('[AppointmentService] Error updating appointment status: $e');
      return false;
    }
  }

  /// Get upcoming appointments
  Future<List<ClinicAppointment>> getUpcomingAppointments() async {
    print('[AppointmentService] Getting upcoming appointments (alias for fetchPendingAppointments)');
    return await fetchPendingAppointments();
  }

  /// Get completed appointments
  Future<List<ClinicAppointment>> getCompletedAppointments() async {
    print('[AppointmentService] Getting completed appointments (alias for fetchCompletedAppointments)');
    return await fetchCompletedAppointments();
  }

  /// Get cancelled appointments
  Future<List<ClinicAppointment>> getCancelledAppointments() async {
    try {
      print('[AppointmentService] Getting cancelled appointments');
      
      final appointments = await fetchAppointments();
      final cancelledAppointments = appointments.where((appointment) => 
        appointment.status.toLowerCase() == 'cancelled'
      ).toList();
      
      print('[AppointmentService] Found ${cancelledAppointments.length} cancelled appointments');
      
      return cancelledAppointments;
    } catch (e) {
      print('[AppointmentService] Error filtering cancelled appointments: $e');
      throw Exception('Failed to get cancelled appointments: $e');
    }
  }
  
  /// Get appointment details
  Future<ClinicAppointment?> getAppointmentDetails(String appointmentId) async {
    try {

      final String url = '${ApiEndpoints.createClinicAppointment}/$appointmentId';

      final response = await _dio.get(url);

      if (response.statusCode == 200) {
        // Extract appointment from response
        final Map<String, dynamic> appointmentData = response.data['appointment'] ?? response.data;

        final appointment = ClinicAppointment.fromJson(appointmentData);
        print('[AppointmentService] Successfully fetched appointment details');
        return appointment;
      } else {
        print('[AppointmentService] Error response: ${response.statusCode} - ${response.data}');
        throw Exception('Failed to fetch appointment details: ${response.statusCode}');
      }
    } catch (e) {
      print('[AppointmentService] Error fetching appointment details: $e');
      return null;
    }
  }
  
  /// Generate meeting URL for online appointments
  Future<String?> generateMeetingUrl(String appointmentId) async {
    try {
      print('[AppointmentService] Generating meeting URL for appointment ID: $appointmentId');
      
      final String url = '${ApiEndpoints.generateMeetingUrl}/$appointmentId/generate-meeting-url';
      print('[AppointmentService] Making POST request to: $url');
      
      final response = await _dio.post(url);

      print('[AppointmentService] Response status code: ${response.statusCode}');
      print('[AppointmentService] Response data: ${response.data}');

      if (response.statusCode == 200) {
        final meetingUrl = response.data['meetingUrl'];
        print('[AppointmentService] Successfully generated meeting URL: $meetingUrl');
        return meetingUrl;
      } else {
        print('[AppointmentService] Error response: ${response.statusCode} - ${response.data}');
        throw Exception('Failed to generate meeting URL: ${response.statusCode}');
      }
    } catch (e) {
      print('[AppointmentService] Error generating meeting URL: $e');
      return null;
    }
  }

  /// Mark appointment as completed after a meeting ends
  Future<bool> completeAppointmentAfterMeeting(String appointmentId) async {
    try {
      print('[AppointmentService] Marking appointment as completed after meeting: ID=$appointmentId');
      
      final String url = '${ApiEndpoints.completeClinicAppointment}/$appointmentId';
      print('[AppointmentService] Making PUT request to: $url');
      
      final response = await _dio.put(url);

      print('[AppointmentService] Response status code: ${response.statusCode}');
      print('[AppointmentService] Response data: ${response.data}');

      if (response.statusCode == 200) {
        print('[AppointmentService] Successfully marked appointment as completed');
        return true;
      } else {
        print('[AppointmentService] Failed to mark appointment as completed: ${response.statusCode}');
        return false;
      }
    } catch (e) {
      print('[AppointmentService] Error marking appointment as completed: $e');
      return false;
    }
  }

  /// Add or update appointment note
  Future<Map<String, dynamic>?> updateAppointmentNote({
    required String appointmentId,
    required String note,
  }) async {
    try {
      final String url = '${ApiEndpoints.updateClinicAppointmentNote}/$appointmentId/note';
      final response = await _dio.put(url, data: { 'note': note });
      if (response.statusCode == 200) {
        return response.data as Map<String, dynamic>;
      }
      return null;
    } catch (e) {
      return null;
    }
  }

  /// Upload one or more files for an appointment (multipart)
  Future<Map<String, dynamic>?> uploadAppointmentFiles({
    required String appointmentId,
    required List<MultipartFile> files,
  }) async {
    try {
      final String url = '${ApiEndpoints.uploadClinicAppointmentFiles}/$appointmentId/files';
      final formData = FormData();
      formData.files.addAll(files.map((f) => MapEntry('files', f)));
      final response = await _dio.post(
        url,
        data: formData,
        options: Options(contentType: 'multipart/form-data'),
      );
      if (response.statusCode == 200) {
        return response.data as Map<String, dynamic>;
      }
      return null;
    } catch (e) {
      return null;
    }
  }
} 