
import 'dart:math';

import 'package:vedika_healthcare/features/medicineDelivery/data/models/MedicalStore.dart';

class MedicalStoreRepository {
  // Sample List of Nearby Medical Stores
  final List<MedicalStore> _medicalStores = [
    MedicalStore(
      id: "1",
      name: "Apollo Pharmacy",
      address: "123 Main Street, City A",
      latitude: 28.7041,
      longitude: 77.1025,
      contact: "+91 9876543210",
    ),
    MedicalStore(
      id: "2",
      name: "MedPlus",
      address: "456 Market Road, City B",
      latitude: 28.7055,
      longitude: 77.1010,
      contact: "+91 8765432109",
    ),
    MedicalStore(
      id: "3",
      name: "HealthKart Pharmacy",
      address: "789 Tower Street, City C",
      latitude: 28.7060,
      longitude: 77.1030,
      contact: "+91 7654321098",
    ),
  ];

  // Fetch Nearby Medical Stores (Mock Data)
  Future<List<MedicalStore>> getNearbyStores(double latitude, double longitude) async {
    // Filter stores within a small radius for simulation
    return _medicalStores.where((store) {
      double distance = _calculateDistance(latitude, longitude, store.latitude, store.longitude);
      return distance <= 5.0; // 5 km radius filter
    }).toList();
  }

  // Simulate Order Notification (No API Call)
  Future<bool> sendOrderNotification(String orderId) async {
    print("Order notification sent to store for Order ID: $orderId");
    return true; // Simulate a successful order notification
  }

  // Helper function to calculate distance between two coordinates (Haversine Formula)
  double _calculateDistance(double lat1, double lon1, double lat2, double lon2) {
    const double radius = 6371; // Earth's radius in km
    double dLat = _toRadians(lat2 - lat1);
    double dLon = _toRadians(lon2 - lon1);
    double a = (sin(dLat / 2) * sin(dLat / 2)) +
        cos(_toRadians(lat1)) * cos(_toRadians(lat2)) *
            (sin(dLon / 2) * sin(dLon / 2));
    double c = 2 * atan2(sqrt(a), sqrt(1 - a));
    return radius * c; // Distance in km
  }

  double _toRadians(double degree) {
    return degree * (3.141592653589793 / 180);
  }
}
