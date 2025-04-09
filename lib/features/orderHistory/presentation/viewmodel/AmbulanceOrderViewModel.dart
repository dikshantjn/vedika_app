import 'package:vedika_healthcare/features/orderHistory/data/models/AmbulanceOrder.dart';
import 'package:vedika_healthcare/features/orderHistory/data/repositories/AmbulanceOrderRepository.dart';

class AmbulanceOrderViewModel {
  final AmbulanceOrderRepository _repository = AmbulanceOrderRepository();

  List<AmbulanceOrder> get orders => _repository.getOrders();
}
