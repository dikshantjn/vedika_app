import 'package:flutter/material.dart';
import 'package:geolocator/geolocator.dart';
import 'package:shared_preferences/shared_preferences.dart';

class LocationProvider with ChangeNotifier {
  double? latitude;
  double? longitude;
  bool isLocationLoaded = false; // New flag to track loading state

  Future<void> fetchAndSaveLocation() async {
    try {
      LocationPermission permission = await Geolocator.checkPermission();
      if (permission == LocationPermission.denied) {
        permission = await Geolocator.requestPermission();
        if (permission == LocationPermission.deniedForever) return;
      }

      Position? position;
      try {
        position = await Geolocator.getCurrentPosition(
            desiredAccuracy: LocationAccuracy.best);
      } catch (e) {
        print("Error fetching current location: $e");
      }

      if (position != null) {
        latitude = position.latitude;
        longitude = position.longitude;

        // Save to SharedPreferences only if values are not null
        SharedPreferences prefs = await SharedPreferences.getInstance();
        await prefs.setDouble("latitude", latitude!);
        await prefs.setDouble("longitude", longitude!);

        isLocationLoaded = true;
        notifyListeners();
      } else {
        print("Location retrieval failed: Position is null.");
      }
    } catch (e) {
      print("Error getting location: $e");
    }
  }

  Future<void> loadSavedLocation() async {
    try {
      SharedPreferences prefs = await SharedPreferences.getInstance();
      latitude = prefs.getDouble("latitude");
      longitude = prefs.getDouble("longitude");

      if (latitude != null && longitude != null) {
        isLocationLoaded = true;
      } else {
        print("No saved location found.");
      }

      notifyListeners();
    } catch (e) {
      print("Error loading location: $e");
    }
  }
}
