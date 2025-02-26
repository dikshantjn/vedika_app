import 'package:flutter/material.dart';
import 'package:geolocator/geolocator.dart';
import 'package:shared_preferences/shared_preferences.dart';

class LocationProvider with ChangeNotifier {
  double? latitude;
  double? longitude;
  bool isLocationLoaded = false;

  LocationProvider() {
    print("Initializing LocationProvider...");
    initializeLocation();
  }

  /// **Initialize Location (Check Saved First)**
  Future<void> initializeLocation() async {
    if (!await isLocationServiceEnabled()) {
      print("⚠️ Location services are disabled.");
      return;
    }

    if (!await requestLocationPermission()) {
      print("⚠️ Location permission not granted.");
      return;
    }

    await loadSavedLocation();
    if (!isLocationLoaded) {
      await fetchAndSaveLocation();
    }
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

  /// **Fetch and Save Location with Retry Mechanism**
  Future<void> fetchAndSaveLocation() async {
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
      if (position != null) {
        print("✅ Using last known location: ${position.latitude}, ${position.longitude}");
      } else {
        print("⚠️ No last known location. Fetching new location...");
        position = await _getCurrentLocationWithRetry();
      }

      if (position != null) {
        latitude = position.latitude;
        longitude = position.longitude;

        await _saveLocation(latitude!, longitude!);

        isLocationLoaded = true;
        notifyListeners();
        print("✅ Location retrieved: ($latitude, $longitude)");
      } else {
        print("❌ Unable to fetch location.");
      }
    } catch (e) {
      print("❌ Error getting location: $e");
    }
  }

  Future<Position?> _getCurrentLocationWithRetry({int maxRetries = 2}) async {
    for (int attempt = 1; attempt <= maxRetries; attempt++) {
      try {
        print("🔄 Attempt $attempt: Fetching current location...");
        DateTime startTime = DateTime.now();

        Position position = await Geolocator.getCurrentPosition(
          desiredAccuracy: LocationAccuracy.high,
        ).timeout(
          Duration(seconds: 10),
          onTimeout: () {
            print("⚠️ Attempt $attempt: Location retrieval timed out.");
            return Position(
              latitude: 0.0,
              longitude: 0.0,
              accuracy: 0.0,
              altitude: 0.0,
              altitudeAccuracy: 0.0,
              heading: 0.0,
              headingAccuracy: 0.0,
              speed: 0.0,
              speedAccuracy: 0.0,
              timestamp: DateTime.now(),
            );
          },
        );

        print("✅ Attempt $attempt: Location fetched in ${DateTime.now().difference(startTime).inSeconds} seconds.");
        return position;
      } catch (e) {
        print("❌ Attempt $attempt: Error fetching location: $e");
        if (attempt == maxRetries) {
          print("⚠️ Giving up after $maxRetries attempts.");
          return Position(
            latitude: 0.0,
            longitude: 0.0,
            accuracy: 0.0,
            altitude: 0.0,
            altitudeAccuracy: 0.0,
            heading: 0.0,
            headingAccuracy: 0.0,
            speed: 0.0,
            speedAccuracy: 0.0,
            timestamp: DateTime.now(),
          );
        }
      }
    }
    return null;
  }


  /// **Save Location to SharedPreferences**
  Future<void> _saveLocation(double lat, double lng) async {
    try {
      SharedPreferences prefs = await SharedPreferences.getInstance();
      await prefs.setDouble("latitude", lat);
      await prefs.setDouble("longitude", lng);
      print("✅ Location saved to preferences: ($lat, $lng)");
    } catch (e) {
      print("❌ Error saving location: $e");
    }
  }

  /// **Load Saved Location**
  Future<void> loadSavedLocation() async {
    try {
      SharedPreferences prefs = await SharedPreferences.getInstance();
      latitude = prefs.getDouble("latitude");
      longitude = prefs.getDouble("longitude");

      if (latitude != null && longitude != null) {
        isLocationLoaded = true;
        notifyListeners();
        print("✅ Loaded saved location: ($latitude, $longitude)");
      } else {
        print("⚠️ No saved location found. Fetching new location...");
        await fetchAndSaveLocation();
      }
    } catch (e) {
      print("❌ Error loading location: $e");
    }
  }
}
