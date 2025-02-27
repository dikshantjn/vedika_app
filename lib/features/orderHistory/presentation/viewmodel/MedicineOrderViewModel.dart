import 'package:vedika_healthcare/features/orderHistory/data/models/MedicineOrder.dart';
import 'package:vedika_healthcare/features/orderHistory/data/repositories/MedicineOrderRepository.dart';

class MedicineOrderViewModel {
  final MedicineOrderRepository _repository = MedicineOrderRepository();

  List<MedicineOrder> get orders => _repository.getOrders();
}
