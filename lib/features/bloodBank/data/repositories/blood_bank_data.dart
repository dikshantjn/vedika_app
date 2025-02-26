import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:provider/provider.dart';
import 'package:vedika_healthcare/features/bloodBank/data/models/BloodBank.dart';
import 'package:vedika_healthcare/shared/services/LocationProvider.dart';

List<BloodBank> getBloodBanks(BuildContext context) {
  final locationProvider = Provider.of<LocationProvider>(context, listen: false);

  if (!locationProvider.isLocationLoaded) {
    return []; // Return an empty list if the location isn't available yet
  }

  LatLng userLocation = LatLng(locationProvider.latitude!, locationProvider.longitude!);

  return [
    BloodBank(
      id: "bb_001",
      name: "Red Cross Blood Bank",
      location: LatLng(userLocation.latitude + 0.005, userLocation.longitude + 0.005),
      address: "123 Red Street, Nearby",
      contact: "+91 9370320066",
      availableBlood: [
        BloodUnit(group: "A+", units: 5),
        BloodUnit(group: "O-", units: 2),
        BloodUnit(group: "B+", units: 7),
        BloodUnit(group: "AB-", units: 1),
      ],
    ),
    BloodBank(
      id: "bb_002",
      name: "LifeSaver Blood Bank",
      location: LatLng(userLocation.latitude - 0.004, userLocation.longitude + 0.006),
      address: "45 Green Road, Nearby",
      contact: "+91 9370320066",
      availableBlood: [
        BloodUnit(group: "A-", units: 4),
        BloodUnit(group: "O+", units: 6),
        BloodUnit(group: "B-", units: 3),
        BloodUnit(group: "AB+", units: 5),
      ],
    ),
    BloodBank(
      id: "bb_003",
      name: "Hope Blood Bank",
      location: LatLng(userLocation.latitude + 0.003, userLocation.longitude - 0.005),
      address: "78 White Avenue, Nearby",
      contact: "+91 9370320066",
      availableBlood: [
        BloodUnit(group: "A+", units: 3),
        BloodUnit(group: "O+", units: 8),
        BloodUnit(group: "B+", units: 6),
        BloodUnit(group: "AB+", units: 2),
      ],
    ),
    BloodBank(
      id: "bb_004",
      name: "City Blood Bank",
      location: LatLng(userLocation.latitude + 0.002, userLocation.longitude - 0.003),
      address: "12 Blue Street, Downtown",
      contact: "+91 9370320066",
      availableBlood: [
        BloodUnit(group: "O+", units: 10),
        BloodUnit(group: "B+", units: 2),
        BloodUnit(group: "A-", units: 4),
      ],
    ),
    BloodBank(
      id: "bb_005",
      name: "Universal Blood Center",
      location: LatLng(userLocation.latitude - 0.006, userLocation.longitude + 0.002),
      address: "99 Green Park, Sector 5",
      contact: "+91 9370320066",
      availableBlood: [
        BloodUnit(group: "AB+", units: 6),
        BloodUnit(group: "O-", units: 3),
      ],
    ),
    BloodBank(
      id: "bb_006",
      name: "Safe Blood Bank",
      location: LatLng(userLocation.latitude + 0.001, userLocation.longitude + 0.004),
      address: "222 Health Road, West End",
      contact: "+91 9370320066",
      availableBlood: [
        BloodUnit(group: "A+", units: 7),
        BloodUnit(group: "B-", units: 1),
      ],
    ),
    BloodBank(
      id: "bb_007",
      name: "Pure Life Blood Center",
      location: LatLng(userLocation.latitude - 0.003, userLocation.longitude - 0.004),
      address: "567 Charity Lane, East Town",
      contact: "+91 9370320066",
      availableBlood: [
        BloodUnit(group: "A-", units: 5),
        BloodUnit(group: "AB-", units: 2),
      ],
    ),
    BloodBank(
      id: "bb_008",
      name: "Vital Blood Bank",
      location: LatLng(userLocation.latitude + 0.004, userLocation.longitude + 0.003),
      address: "789 Hospital Street, Midtown",
      contact: "+91 9370320066",
      availableBlood: [
        BloodUnit(group: "O+", units: 12),
        BloodUnit(group: "B+", units: 9),
      ],
    ),
    BloodBank(
      id: "bb_009",
      name: "Rapid Response Blood Bank",
      location: LatLng(userLocation.latitude - 0.005, userLocation.longitude - 0.006),
      address: "321 Emergency Lane, South City",
      contact: "+91 9370320066",
      availableBlood: [
        BloodUnit(group: "A+", units: 8),
        BloodUnit(group: "O-", units: 4),
      ],
    ),
    BloodBank(
      id: "bb_010",
      name: "Guardian Blood Bank",
      location: LatLng(userLocation.latitude + 0.006, userLocation.longitude - 0.002),
      address: "555 Protection Avenue, North City",
      contact: "+91 9370320066",
      availableBlood: [
        BloodUnit(group: "B-", units: 3),
        BloodUnit(group: "AB+", units: 6),
      ],
    ),
  ];
}
