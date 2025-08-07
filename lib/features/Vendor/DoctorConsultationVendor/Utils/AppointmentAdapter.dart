import 'package:vedika_healthcare/features/Vendor/DoctorConsultationVendor/Models/ClinicAppointment.dart';

enum AppointmentStatus {
  confirmed,
  pending,
  cancelled,
}

class AppointmentData {
  final String id;
  final String patientName;
  final int age;
  final String gender;
  final DateTime dateTime;
  final String consultationType;
  final AppointmentStatus status;

  AppointmentData({
    required this.id,
    required this.patientName,
    required this.age,
    required this.gender,
    required this.dateTime,
    required this.consultationType,
    required this.status,
  });
}

/// Utility class to convert between ClinicAppointment and AppointmentData
class AppointmentAdapter {
  /// Convert a ClinicAppointment to an AppointmentData object for UI display
  static AppointmentData fromClinicAppointment(ClinicAppointment appointment) {
    // Determine appointment status
    AppointmentStatus status;
    switch (appointment.status.toLowerCase()) {
      case 'confirmed':
        status = AppointmentStatus.confirmed;
        break;
      case 'pending':
        status = AppointmentStatus.pending;
        break;
      case 'cancelled':
        status = AppointmentStatus.cancelled;
        break;
      default:
        status = AppointmentStatus.pending;
    }

    // Parse the date and time
    final appointmentDateTime = DateTime(
      appointment.date.year,
      appointment.date.month,
      appointment.date.day,
      int.parse(appointment.time.split(':')[0]),
      int.parse(appointment.time.split(':')[1]),
    );
    
    // Extract consultation type (in-person or online)
    final consultationType = appointment.isOnline ? 'Online Consultation' : 'In-person Visit';
    
    // Extract patient information
    final patientName = appointment.user?.name ?? 'Unknown Patient';
    
    // Default age and gender - in a real app, this would come from user data
    final age = 30;
    final gender = 'Male';
    
    return AppointmentData(
      id: appointment.clinicAppointmentId,
      patientName: patientName,
      age: age,
      gender: gender,
      dateTime: appointmentDateTime,
      consultationType: consultationType,
      status: status,
    );
  }
  
  /// Convert a list of ClinicAppointments to a list of AppointmentData objects
  static List<AppointmentData> fromClinicAppointmentList(List<ClinicAppointment> appointments) {
    return appointments.map((appointment) => fromClinicAppointment(appointment)).toList();
  }
} 