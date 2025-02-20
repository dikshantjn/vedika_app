import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:provider/provider.dart';
import 'package:vedika_healthcare/shared/services/LocationProvider.dart';
import '../models/Ambulance.dart';

List<Ambulance> getAmbulances(BuildContext context) {
  final locationProvider = Provider.of<LocationProvider>(context, listen: false);

  if (!locationProvider.isLocationLoaded) {
    return []; // Return an empty list if location isn't available
  }

  LatLng userLocation = LatLng(locationProvider.latitude!, locationProvider.longitude!);

  return [
    Ambulance(
      id: "amb_001",
      name: "City Ambulance Service",
      location: LatLng(userLocation.latitude + 0.003, userLocation.longitude + 0.002),
      contact: "+91 9370320066",
      services: ["ICU", "Basic Life Support", "Emergency Response"],
      availability: "24/7",
    ),
    Ambulance(
      id: "amb_002",
      name: "Metro Emergency Ambulance",
      location: LatLng(userLocation.latitude - 0.002, userLocation.longitude + 0.004),
      contact: "+91 9370320066",
      services: ["Ventilator Support", "Trauma Care"],
      availability: "24/7",
    ),
    Ambulance(
      id: "amb_003",
      name: "Rapid Response Ambulance",
      location: LatLng(userLocation.latitude + 0.004, userLocation.longitude - 0.003),
      contact: "+91 9345678901",
      services: ["Cardiac Support", "Emergency Response"],
      availability: "Available",
    ),
    Ambulance(
      id: "amb_004",
      name: "LifeLine Ambulance",
      location: LatLng(userLocation.latitude - 0.003, userLocation.longitude - 0.002),
      contact: "+91 9370320066",
      services: ["Pediatric Care", "Advanced Life Support"],
      availability: "24/7",
    ),
    Ambulance(
      id: "amb_005",
      name: "Guardian Ambulance Service",
      location: LatLng(userLocation.latitude + 0.002, userLocation.longitude + 0.005),
      contact: "+91 9370320066",
      services: ["Neonatal Transport", "Air Ambulance"],
      availability: "Available",
    ),
  ];
}
