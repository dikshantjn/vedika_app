// ViewModel: AppointmentOrderViewModel.dart
import 'package:vedika_healthcare/features/orderHistory/data/models/AppointmentOrder.dart';
import 'package:vedika_healthcare/features/orderHistory/data/repositories/AppointmentOrderRepository.dart';

class AppointmentOrderViewModel {
  final AppointmentOrderRepository _repository = AppointmentOrderRepository();

  List<AppointmentOrder> get orders => _repository.fetchAppointments();
}