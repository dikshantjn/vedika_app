import 'package:flutter/cupertino.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:provider/provider.dart';
import 'package:vedika_healthcare/features/medicineDelivery/data/models/DeliveryPartner/DeliveryPartner.dart';
import 'package:vedika_healthcare/shared/services/LocationProvider.dart';

class DeliveryPartnerService {
  List<DeliveryPartner> getNearbyDeliveryPartners(BuildContext context) {
    final locationProvider = Provider.of<LocationProvider>(context, listen: false);

    if (!locationProvider.isLocationLoaded) {
      return []; // Return an empty list if location isn't available
    }

    LatLng userLocation = LatLng(locationProvider.latitude!, locationProvider.longitude!);

    return [
      DeliveryPartner(
        id: "dp_001",
        name: "Rajesh Kumar",
        phone: "+91 9876543210",
        latitude: userLocation.latitude + 0.003,
        longitude: userLocation.longitude + 0.004,
        rating: 4.8,
        chargesPerKm: 10.0,
      ),
      DeliveryPartner(
        id: "dp_002",
        name: "Amit Sharma",
        phone: "+91 9867543201",
        latitude: userLocation.latitude - 0.004,
        longitude: userLocation.longitude + 0.006,
        rating: 4.6,
        chargesPerKm: 9.5,
      ),
      DeliveryPartner(
        id: "dp_003",
        name: "Suresh Reddy",
        phone: "+91 9856743120",
        latitude: userLocation.latitude + 0.005,
        longitude: userLocation.longitude - 0.002,
        rating: 4.7,
        chargesPerKm: 10.5,
      ),
      DeliveryPartner(
        id: "dp_004",
        name: "Vikas Patil",
        phone: "+91 9845632107",
        latitude: userLocation.latitude - 0.002,
        longitude: userLocation.longitude + 0.003,
        rating: 4.5,
        chargesPerKm: 8.5,
      ),
      DeliveryPartner(
        id: "dp_005",
        name: "Deepak Verma",
        phone: "+91 9834521076",
        latitude: userLocation.latitude + 0.006,
        longitude: userLocation.longitude - 0.005,
        rating: 4.9,
        chargesPerKm: 11.0,
      ),
      DeliveryPartner(
        id: "dp_006",
        name: "Sanjay Mehta",
        phone: "+91 9823410765",
        latitude: userLocation.latitude - 0.005,
        longitude: userLocation.longitude + 0.002,
        rating: 4.3,
        chargesPerKm: 9.0,
      ),
      DeliveryPartner(
        id: "dp_007",
        name: "Manoj Gupta",
        phone: "+91 9812307654",
        latitude: userLocation.latitude + 0.002,
        longitude: userLocation.longitude - 0.004,
        rating: 4.6,
        chargesPerKm: 9.8,
      ),
      DeliveryPartner(
        id: "dp_008",
        name: "Rohit Sen",
        phone: "+91 9801236547",
        latitude: userLocation.latitude - 0.003,
        longitude: userLocation.longitude + 0.006,
        rating: 4.4,
        chargesPerKm: 8.7,
      ),
      DeliveryPartner(
        id: "dp_009",
        name: "Anil Choudhary",
        phone: "+91 9790123456",
        latitude: userLocation.latitude + 0.007,
        longitude: userLocation.longitude - 0.003,
        rating: 4.8,
        chargesPerKm: 10.2,
      ),
      DeliveryPartner(
        id: "dp_010",
        name: "Naresh Yadav",
        phone: "+91 9789012345",
        latitude: userLocation.latitude - 0.006,
        longitude: userLocation.longitude + 0.001,
        rating: 4.7,
        chargesPerKm: 9.2,
      ),
    ];
  }
}
