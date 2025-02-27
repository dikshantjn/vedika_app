// Model: AppointmentOrder.dart
class AppointmentOrder {
  final String orderNumber;
  final String date;
  final String status;
  final String doctor;
  final String specialty;
  final String total;

  AppointmentOrder({
    required this.orderNumber,
    required this.date,
    required this.status,
    required this.doctor,
    required this.specialty,
    required this.total,
  });
}