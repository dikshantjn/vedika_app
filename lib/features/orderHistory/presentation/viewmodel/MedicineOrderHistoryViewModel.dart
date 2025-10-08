import 'package:vedika_healthcare/core/auth/data/services/StorageService.dart';
import 'package:vedika_healthcare/features/Vendor/MedicalStoreVendor/data/models/MedicineOrderModel.dart';
import 'package:vedika_healthcare/features/orderHistory/data/repositories/MedicineOrderRepository.dart';

class MedicineOrderHistoryViewModel {
  final MedicineOrderRepository _repository = MedicineOrderRepository();

  // List of orders for the user
  List<MedicineOrderModel> _orders = [];

  // Getter for orders
  List<MedicineOrderModel> get orders => _orders;

  // Fetch the orders for the given userId
  Future<void> fetchOrdersByUser() async {
    String? userId = await StorageService.getUserId();
    _orders = await _repository.getOrdersByUser(userId!);
  }
}
