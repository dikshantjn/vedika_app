import 'package:vedika_healthcare/features/Vendor/DoctorConsultationVendor/Models/ClinicAppointment.dart';
import 'package:vedika_healthcare/features/Vendor/DoctorConsultationVendor/Views/DoctorDashboard/widgets/upcoming_appointments_card.dart';

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