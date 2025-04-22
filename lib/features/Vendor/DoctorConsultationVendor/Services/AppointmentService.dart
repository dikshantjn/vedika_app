import 'package:dio/dio.dart';
import 'package:vedika_healthcare/core/auth/data/services/StorageService.dart';
import 'package:vedika_healthcare/core/constants/ApiEndpoints.dart';
import 'package:vedika_healthcare/features/Vendor/DoctorConsultationVendor/Models/ClinicAppointment.dart';
import 'package:vedika_healthcare/features/Vendor/Registration/Services/VendorLoginService.dart';
import 'package:vedika_healthcare/core/auth/data/models/UserModel.dart';
import 'package:vedika_healthcare/features/Vendor/DoctorConsultationVendor/Models/DoctorClinicProfile.dart';

class AppointmentService {
  final Dio _dio = Dio();
  
  // Mock data for development and testing
  List<ClinicAppointment> _mockAppointments = [];
  
  AppointmentService() {
    _initializeMockData();
  }
  
  void _initializeMockData() {
    // Create mock users
    final user1 = UserModel(
      userId: 'user123',
      name: 'John Smith',
      phoneNumber: '+919876543210',
      emailId: 'john.smith@example.com',
      photo: 'https://randomuser.me/api/portraits/men/35.jpg',
      gender: 'Male',
      dateOfBirth: DateTime(1985, 5, 12),
      createdAt: DateTime.now().subtract(const Duration(days: 120)),
      status: true,
    );
    
    final user2 = UserModel(
      userId: 'user456',
      name: 'Sarah Johnson',
      phoneNumber: '+918765432109',
      emailId: 'sarah.j@example.com',
      gender: 'Female',
      dateOfBirth: DateTime(1992, 8, 24),
      createdAt: DateTime.now().subtract(const Duration(days: 90)),
      status: true,
    );
    
    final user3 = UserModel(
      userId: 'user789',
      name: 'Rajesh Kumar',
      phoneNumber: '+917654321098',
      emailId: 'rajesh.k@example.com',
      photo: 'https://randomuser.me/api/portraits/men/62.jpg',
      gender: 'Male',
      bloodGroup: 'O+',
      dateOfBirth: DateTime(1978, 3, 15),
      createdAt: DateTime.now().subtract(const Duration(days: 60)),
      status: true,
    );
    
    // Create mock appointments
    final now = DateTime.now();
    
    _mockAppointments = [
      // Online appointments
      ClinicAppointment(
        clinicAppointmentId: 'appt1001',
        userId: user1.userId,
        doctorId: 'doc123',
        vendorId: 'vendor456',
        date: now.add(const Duration(days: 2)),
        time: '10:30',
        status: 'confirmed',
        paymentStatus: 'paid',
        userResponseStatus: 'accepted',
        paidAmount: 800.0,
        isOnline: true,
        meetingUrl: 'https://meet.vedika.com/appt1001',
        user: user1,
      ),
      
      ClinicAppointment(
        clinicAppointmentId: 'appt1002',
        userId: user2.userId,
        doctorId: 'doc123',
        vendorId: 'vendor456',
        date: now.add(const Duration(days: 1)),
        time: '14:15',
        status: 'pending',
        paymentStatus: 'paid',
        userResponseStatus: 'pending',
        paidAmount: 750.0,
        isOnline: true,
        user: user2,
      ),
      
      ClinicAppointment(
        clinicAppointmentId: 'appt1003',
        userId: user3.userId,
        doctorId: 'doc123',
        vendorId: 'vendor456',
        date: now.subtract(const Duration(days: 3)),
        time: '16:45',
        status: 'completed',
        paymentStatus: 'paid',
        userResponseStatus: 'accepted',
        paidAmount: 800.0,
        isOnline: true,
        user: user3,
      ),
      
      // Offline appointments
      ClinicAppointment(
        clinicAppointmentId: 'appt2001',
        userId: user1.userId,
        doctorId: 'doc123',
        vendorId: 'vendor456',
        date: now.add(const Duration(days: 5)),
        time: '11:00',
        status: 'confirmed',
        paymentStatus: 'paid',
        userResponseStatus: 'accepted',
        paidAmount: 1200.0,
        isOnline: false,
        user: user1,
      ),
      
      ClinicAppointment(
        clinicAppointmentId: 'appt2002',
        userId: user2.userId,
        doctorId: 'doc123',
        vendorId: 'vendor456',
        date: now.subtract(const Duration(days: 2)),
        time: '09:30',
        status: 'cancelled',
        paymentStatus: 'refunded',
        userResponseStatus: 'declined',
        paidAmount: 1000.0,
        isOnline: false,
        user: user2,
      ),
      
      ClinicAppointment(
        clinicAppointmentId: 'appt2003',
        userId: user3.userId,
        doctorId: 'doc123',
        vendorId: 'vendor456',
        date: now.add(const Duration(days: 3)),
        time: '17:30',
        status: 'confirmed',
        paymentStatus: 'paid',
        userResponseStatus: 'accepted',
        paidAmount: 1200.0,
        isOnline: false,
        user: user3,
      ),
    ];

    print('MOCK DATA INITIALIZED: ${_mockAppointments.length} appointments created');
    for (var appointment in _mockAppointments) {
      print('  - ID: ${appointment.clinicAppointmentId}, Online: ${appointment.isOnline}, Status: ${appointment.status}');
    }
  }

  /// Fetch all appointments for a vendor
  Future<List<ClinicAppointment>> fetchAppointments() async {
    try {
      // For development, return mock data
      print('FETCHING APPOINTMENTS: returning ${_mockAppointments.length} mock appointments');
      return Future.delayed(const Duration(milliseconds: 800), () => _mockAppointments);
      
      // Uncomment below for actual API implementation
      /*
      // Get the vendor ID from storage
      final String? vendorId = await VendorLoginService().getVendorId();

      if (vendorId == null) {
        throw Exception('Vendor ID not found');
      }

      // Make API call to fetch appointments
      final response = await _dio.get(
        '${ApiEndpoints.baseUrl}/appointments/vendor/$vendorId',
      );

      if (response.statusCode == 200) {
        final List<dynamic> data = response.data['data'] ?? [];
        return data.map((json) => ClinicAppointment.fromJson(json)).toList();
      } else {
        throw Exception('Failed to fetch appointments: ${response.statusCode}');
      }
      */
    } catch (e) {
      print('Error fetching appointments: $e');
      throw Exception('Failed to fetch appointments: $e');
    }
  }

  /// Update appointment status
  Future<bool> updateAppointmentStatus(String appointmentId, String newStatus) async {
    try {
      // For development, update mock data
      final index = _mockAppointments.indexWhere(
        (appointment) => appointment.clinicAppointmentId == appointmentId
      );
      
      if (index != -1) {
        // Create a new appointment with updated status
        final updatedAppointment = ClinicAppointment(
          clinicAppointmentId: _mockAppointments[index].clinicAppointmentId,
          userId: _mockAppointments[index].userId,
          doctorId: _mockAppointments[index].doctorId,
          vendorId: _mockAppointments[index].vendorId,
          date: _mockAppointments[index].date,
          time: _mockAppointments[index].time,
          status: newStatus,
          paymentStatus: _mockAppointments[index].paymentStatus,
          adminUpdatedAt: DateTime.now(),
          userResponseStatus: _mockAppointments[index].userResponseStatus,
          paidAmount: _mockAppointments[index].paidAmount,
          isOnline: _mockAppointments[index].isOnline,
          meetingUrl: _mockAppointments[index].meetingUrl,
          user: _mockAppointments[index].user,
          doctor: _mockAppointments[index].doctor,
        );
        
        // Replace the old appointment with the updated one
        _mockAppointments[index] = updatedAppointment;
        return true;
      }
      
      return false;
      
      // Uncomment below for actual API implementation
      /*
      final response = await _dio.put(
        '${ApiEndpoints.baseUrl}/appointments/$appointmentId/status',
        data: {
          'status': newStatus,
        },
      );

      return response.statusCode == 200;
      */
    } catch (e) {
      print('Error updating appointment status: $e');
      return false;
    }
  }

  /// Get upcoming appointments
  Future<List<ClinicAppointment>> getUpcomingAppointments() async {
    final appointments = await fetchAppointments();
    final now = DateTime.now();
    
    return appointments.where((appointment) {
      final appointmentDateTime = DateTime(
        appointment.date.year,
        appointment.date.month,
        appointment.date.day,
        int.parse(appointment.time.split(':')[0]),
        int.parse(appointment.time.split(':')[1]),
      );
      
      return appointmentDateTime.isAfter(now) && 
             (appointment.status == 'pending' || appointment.status == 'confirmed');
    }).toList();
  }

  /// Get completed appointments
  Future<List<ClinicAppointment>> getCompletedAppointments() async {
    final appointments = await fetchAppointments();
    return appointments.where((appointment) => 
      appointment.status == 'completed'
    ).toList();
  }

  /// Get cancelled appointments
  Future<List<ClinicAppointment>> getCancelledAppointments() async {
    final appointments = await fetchAppointments();
    return appointments.where((appointment) => 
      appointment.status == 'cancelled'
    ).toList();
  }
  
  /// Get appointment details
  Future<ClinicAppointment?> getAppointmentDetails(String appointmentId) async {
    try {
      // For development, return mock data
      final appointment = _mockAppointments.firstWhere(
        (appointment) => appointment.clinicAppointmentId == appointmentId,
        orElse: () => throw Exception('Appointment not found'),
      );
      
      return Future.delayed(const Duration(milliseconds: 500), () => appointment);
      
      // Uncomment below for actual API implementation
      /*
      final response = await _dio.get(
        '${ApiEndpoints.baseUrl}/appointments/$appointmentId',
      );

      if (response.statusCode == 200) {
        return ClinicAppointment.fromJson(response.data['data']);
      } else {
        throw Exception('Failed to fetch appointment details: ${response.statusCode}');
      }
      */
    } catch (e) {
      print('Error fetching appointment details: $e');
      return null;
    }
  }
  
  /// Generate meeting URL for online appointments
  Future<String?> generateMeetingUrl(String appointmentId) async {
    try {
      // For development, simulate generating and returning a meeting URL
      final meetingUrl = 'https://meet.vedika.com/${appointmentId}?token=mock_token_${DateTime.now().millisecondsSinceEpoch}';
      
      // Update the mock appointment with the new meeting URL
      final index = _mockAppointments.indexWhere(
        (appointment) => appointment.clinicAppointmentId == appointmentId
      );
      
      if (index != -1) {
        // Create a new appointment with the updated meeting URL
        final updatedAppointment = ClinicAppointment(
          clinicAppointmentId: _mockAppointments[index].clinicAppointmentId,
          userId: _mockAppointments[index].userId,
          doctorId: _mockAppointments[index].doctorId,
          vendorId: _mockAppointments[index].vendorId,
          date: _mockAppointments[index].date,
          time: _mockAppointments[index].time,
          status: _mockAppointments[index].status,
          paymentStatus: _mockAppointments[index].paymentStatus,
          adminUpdatedAt: _mockAppointments[index].adminUpdatedAt,
          userResponseStatus: _mockAppointments[index].userResponseStatus,
          paidAmount: _mockAppointments[index].paidAmount,
          isOnline: _mockAppointments[index].isOnline,
          meetingUrl: meetingUrl,
          user: _mockAppointments[index].user,
          doctor: _mockAppointments[index].doctor,
        );
        
        // Replace the old appointment with the updated one
        _mockAppointments[index] = updatedAppointment;
      }
      
      return Future.delayed(const Duration(milliseconds: 800), () => meetingUrl);
      
      // Uncomment below for actual API implementation
      /*
      final response = await _dio.post(
        '${ApiEndpoints.baseUrl}/appointments/$appointmentId/generate-meeting',
      );

      if (response.statusCode == 200) {
        return response.data['meetingUrl'];
      } else {
        throw Exception('Failed to generate meeting URL: ${response.statusCode}');
      }
      */
    } catch (e) {
      print('Error generating meeting URL: $e');
      return null;
    }
  }
} 