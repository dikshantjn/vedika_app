import 'package:google_maps_flutter/google_maps_flutter.dart';

class BloodBank {
  final String id; // Unique ID for the blood bank
  final String name;
  final LatLng location;
  final String address;
  final String contact;
  final List<BloodUnit> availableBlood;

  BloodBank({
    required this.id,
    required this.name,
    required this.location,
    required this.address,
    required this.contact,
    required this.availableBlood,
  });

  /// Convert JSON to `BloodBank` (for API integration)
  factory BloodBank.fromJson(Map<String, dynamic> json, LatLng userLocation) {
    return BloodBank(
      id: json["id"] ?? "", // Ensure a valid ID is assigned
      name: json["name"],
      location: LatLng(
        userLocation.latitude + (json["latOffset"] ?? 0.0),
        userLocation.longitude + (json["lngOffset"] ?? 0.0),
      ),
      address: json["address"],
      contact: json["contact"],
      availableBlood: (json["availableBlood"] as List)
          .map((blood) => BloodUnit.fromJson(blood))
          .toList(),
    );
  }

  /// Convert `BloodBank` to JSON (for future API requests if needed)
  Map<String, dynamic> toJson() {
    return {
      "id": id,
      "name": name,
      "location": {
        "latitude": location.latitude,
        "longitude": location.longitude,
      },
      "address": address,
      "contact": contact,
      "availableBlood": availableBlood.map((blood) => blood.toJson()).toList(),
    };
  }
}

/// Model for Available Blood Stock
class BloodUnit {
  final String group;
  final int units;

  BloodUnit({
    required this.group,
    required this.units,
  });

  factory BloodUnit.fromJson(Map<String, dynamic> json) {
    return BloodUnit(
      group: json["group"],
      units: int.parse(json["units"].toString()),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      "group": group,
      "units": units,
    };
  }
}
