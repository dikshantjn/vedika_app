import 'dart:math';
import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:provider/provider.dart';
import 'package:vedika_healthcare/features/medicineDelivery/data/models/MedicalStore/MedicalStore.dart';
import 'package:vedika_healthcare/features/medicineDelivery/data/models/MedicalStore/MedicineProduct.dart';
import 'package:vedika_healthcare/features/medicineDelivery/data/repositories/MedicalStore/MedicineRepository.dart';
import 'package:vedika_healthcare/shared/services/LocationProvider.dart';

class MedicalStoreRepository {
  final BuildContext context;
  final MedicineRepository medicineRepository = MedicineRepository(); // Initialize Medicine Repository

  MedicalStoreRepository(this.context);

  // Fetch Nearby Medical Stores
  Future<List<MedicalStore>> getNearbyStores() async {
    final locationProvider = Provider.of<LocationProvider>(context, listen: false);

    if (!locationProvider.isLocationLoaded) {
      return []; // Return an empty list if location isn't available yet
    }

    LatLng userLocation = LatLng(locationProvider.latitude!, locationProvider.longitude!);

    await Future.delayed(Duration(milliseconds: 500)); // Simulating network delay

    List<MedicalStore> medicalStores = _generateMedicalStores(userLocation.latitude, userLocation.longitude);

    // Filter stores within 5 km radius
    return medicalStores.where((store) {
      double distance = _calculateDistance(userLocation.latitude, userLocation.longitude, store.latitude, store.longitude);
      return distance <= 5.0; // 5 km radius filter
    }).toList();
  }

  // Fetch Store by ID
  Future<MedicalStore?> getStoreById(String id) async {
    final locationProvider = Provider.of<LocationProvider>(context, listen: false);

    if (!locationProvider.isLocationLoaded) {
      return null;
    }

    LatLng userLocation = LatLng(locationProvider.latitude!, locationProvider.longitude!);

    await Future.delayed(Duration(milliseconds: 300)); // Simulating database lookup
    List<MedicalStore> stores = _generateMedicalStores(userLocation.latitude, userLocation.longitude);

    var matchingStores = stores.where((store) => store.id == id);
    return matchingStores.isNotEmpty ? matchingStores.first : null;
  }

  // Fetch Medicines of a Specific Store
  Future<List<MedicineProduct>> getStoreMedicines(String storeId) async {
    MedicalStore? store = await getStoreById(storeId);
    return store?.medicines ?? [];
  }

  // Add Medicine to a Store
  Future<void> addMedicineToStore(String storeId, MedicineProduct medicine) async {
    MedicalStore? store = await getStoreById(storeId);
    if (store != null) {
      store.medicines.add(medicine);
      print("Medicine ${medicine.name} added to store ${store.name}");
    }
  }

  // Generate random offsets to simulate nearby medical stores
  List<MedicalStore> _generateMedicalStores(double userLat, double userLng) {
    final Random random = Random();
    List<MedicineProduct> allMedicines = medicineRepository.getMedicines(); // Get available medicines

    return List.generate(5, (index) {
      double latOffset = (random.nextDouble() - 0.5) / 100; // ±0.005 variation
      double lngOffset = (random.nextDouble() - 0.5) / 100;

      return MedicalStore(
        id: "ms_00${index + 1}",
        name: ["Apollo Pharmacy", "MedPlus Store", "HealthKart Pharmacy", "Wellness Medicos", "City Pharmacy"][index],
        address: ["123 Health Street", "45 Wellness Avenue", "78 Care Road", "99 Vital Street", "222 Life Road"][index],
        latitude: userLat + latOffset,
        longitude: userLng + lngOffset,
        contact: "+91 98${random.nextInt(99999999)}", // Generate random number
        medicines: allMedicines.sublist(0, (allMedicines.length)), // Assign random medicines to store
      );
    });
  }

  // Helper: Calculate Distance using Haversine Formula
  double _calculateDistance(double lat1, double lon1, double lat2, double lon2) {
    const double radius = 6371; // Earth's radius in km
    double dLat = _toRadians(lat2 - lat1);
    double dLon = _toRadians(lon2 - lon1);
    double a = pow(sin(dLat / 2), 2) +
        cos(_toRadians(lat1)) * cos(_toRadians(lat2)) * pow(sin(dLon / 2), 2);
    double c = 2 * atan2(sqrt(a), sqrt(1 - a));
    return radius * c; // Distance in km
  }

  // Helper: Convert Degrees to Radians
  double _toRadians(double degree) => degree * (pi / 180);
}
