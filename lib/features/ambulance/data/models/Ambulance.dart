import 'package:google_maps_flutter/google_maps_flutter.dart';

class Ambulance {
  final String id;
  final String name;
  final LatLng location;
  final String contact;
  final List<String> services;
  final String availability;

  Ambulance({
    required this.id,
    required this.name,
    required this.location,
    required this.contact,
    required this.services,
    required this.availability,
  });
}
