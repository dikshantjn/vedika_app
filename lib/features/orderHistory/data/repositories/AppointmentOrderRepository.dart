// Repository: AppointmentOrderRepository.dart
import 'package:vedika_healthcare/features/orderHistory/data/models/AppointmentOrder.dart';

class AppointmentOrderRepository {
  List<AppointmentOrder> fetchAppointments() {
    return [
      AppointmentOrder(
        orderNumber: 'APT12345',
        date: 'Feb 20, 2024',
        status: 'Confirmed',
        doctor: 'Dr. John Doe',
        specialty: 'Cardiology',
        total: '\₹50.00',
      ),
      AppointmentOrder(
        orderNumber: 'APT12346',
        date: 'Feb 22, 2024',
        status: 'Pending',
        doctor: 'Dr. Smith',
        specialty: 'Dermatology',
        total: '\₹40.00',
      ),
    ];
  }
}