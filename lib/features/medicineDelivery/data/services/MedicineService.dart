

import 'package:vedika_healthcare/features/medicineDelivery/data/models/MedicalStore.dart';
import 'package:vedika_healthcare/features/medicineDelivery/data/repositories/MedicalStoreRepository.dart';

class MedicineService {
  final MedicalStoreRepository _repository = MedicalStoreRepository();

  // Fetch Nearby Medical Stores
  Future<List<MedicalStore>> fetchNearbyStores(double latitude, double longitude) {
    return _repository.getNearbyStores(latitude, longitude);
  }

  // Notify Store About Order
  Future<bool> sendOrderToStore(String orderId) {
    return _repository.sendOrderNotification(orderId);
  }
}
