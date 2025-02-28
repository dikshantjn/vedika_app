import 'package:flutter/material.dart';
import 'package:vedika_healthcare/features/medicineDelivery/data/models/MedicalStore/MedicalStore.dart';
import 'package:vedika_healthcare/features/medicineDelivery/data/models/MedicalStore/MedicineProduct.dart';
import 'package:vedika_healthcare/features/medicineDelivery/data/repositories/MedicalStore/MedicalStoreRepository.dart';

class MedicineOrderService {
  final MedicalStoreRepository _repository;

  MedicineOrderService(BuildContext context) : _repository = MedicalStoreRepository(context);

  // Fetch Nearby Medical Stores
  Future<List<MedicalStore>> fetchNearbyStores() async {
    try {
      return await _repository.getNearbyStores();
    } catch (e) {
      debugPrint("Error fetching nearby stores: $e");
      return [];
    }
  }

  // Fetch a Specific Medical Store by ID
  Future<MedicalStore?> fetchStoreById(String storeId) async {
    try {
      return await _repository.getStoreById(storeId);
    } catch (e) {
      debugPrint("Error fetching store by ID: $e");
      return null;
    }
  }

  // Fetch Medicines of a Specific Store
  Future<List<MedicineProduct>> fetchStoreMedicines(String storeId) async {
    try {
      return await _repository.getStoreMedicines(storeId);
    } catch (e) {
      debugPrint("Error fetching medicines: $e");
      return [];
    }
  }
}
