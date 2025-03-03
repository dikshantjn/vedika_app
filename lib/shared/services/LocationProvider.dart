import 'package:flutter/material.dart';
import 'package:geolocator/geolocator.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';

class LocationProvider with ChangeNotifier {
  double? latitude;
  double? longitude;
  bool isLocationLoaded = false;

  LocationProvider() {
    print("Initializing LocationProvider...");
    initializeLocation();
  }

  /// **Initialize Location**
  Future<void> initializeLocation() async {
    if (!await isLocationServiceEnabled()) {
      print("⚠️ Location services are disabled.");
      return;
    }

    if (!await requestLocationPermission()) {
      print("⚠️ Location permission not granted.");
      return;
    }

    await loadSavedLocation(); // Now gets fresh location instead of saved data
  }

  /// **Check if Location Services are Enabled**
  Future<bool> isLocationServiceEnabled() async {
    bool enabled = await Geolocator.isLocationServiceEnabled();
    print("🔄 Location services enabled: $enabled");
    return enabled;
  }

  /// **Request Location Permission**
  Future<bool> requestLocationPermission() async {
    LocationPermission permission = await Geolocator.checkPermission();

    if (permission == LocationPermission.always || permission == LocationPermission.whileInUse) {
      print("✅ Location permission already granted.");
      return true;
    }

    print("⚠️ Requesting location permission...");
    permission = await Geolocator.requestPermission();

    bool granted = (permission == LocationPermission.always || permission == LocationPermission.whileInUse);
    print(granted ? "✅ Permission granted." : "❌ Permission denied.");
    return granted;
  }

  /// **Fetch Fresh Location and Update Values**
  Future<void> fetchLocation() async {
    try {
      if (!await requestLocationPermission()) {
        print("❌ Location permission denied.");
        return;
      }

      if (!await isLocationServiceEnabled()) {
        print("❌ Location services are disabled.");
        return;
      }

      Position? position = await Geolocator.getLastKnownPosition();
      if (position == null) {
        print("⚠️ No last known location. Fetching new location...");
        position = await Geolocator.getCurrentPosition(desiredAccuracy: LocationAccuracy.high);
      }

      if (position != null) {
        latitude = position.latitude;
        longitude = position.longitude;
        isLocationLoaded = true;
        notifyListeners();
        print("✅ Fresh location retrieved: ($latitude, $longitude)");
      } else {
        print("❌ Unable to fetch location.");
      }
    } catch (e) {
      print("❌ Error getting location: $e");
    }
  }

  /// **Get Fresh Location Instead of Saved One**
  Future<void> loadSavedLocation() async {
    print("🔄 Fetching fresh location instead of saved location...");
    await fetchLocation();
  }

  /// **Get Current Location**
  LatLng? getCurrentLocation() {
    if (latitude != null && longitude != null) {
      return LatLng(latitude!, longitude!);
    }
    return null;
  }
}
