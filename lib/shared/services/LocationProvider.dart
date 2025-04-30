import 'package:flutter/material.dart';
import 'package:geolocator/geolocator.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:permission_handler/permission_handler.dart';

class LocationProvider with ChangeNotifier {
  double? latitude;
  double? longitude;
  bool isLocationLoaded = false;
  bool isInitialized = false;

  LocationProvider() {
    print("Initializing LocationProvider...");
  }

  /// **Initialize Location**
  Future<void> initializeLocation() async {
    if (isInitialized) return;
    
    try {
      // First check if location services are enabled
      bool serviceEnabled = await Geolocator.isLocationServiceEnabled();
      if (!serviceEnabled) {
        print("⚠️ Location services are disabled.");
        isInitialized = true;
        return;
      }

      // Check location permission
      LocationPermission permission = await Geolocator.checkPermission();
      if (permission == LocationPermission.denied) {
        permission = await Geolocator.requestPermission();
        if (permission == LocationPermission.denied) {
          print("⚠️ Location permission denied.");
          isInitialized = true;
          return;
        }
      }

      if (permission == LocationPermission.deniedForever) {
        print("⚠️ Location permission permanently denied.");
        isInitialized = true;
        return;
      }

      // Get the location
      try {
        Position position = await Geolocator.getCurrentPosition(
          desiredAccuracy: LocationAccuracy.high,
          timeLimit: const Duration(seconds: 5),
        );
        
        latitude = position.latitude;
        longitude = position.longitude;
        isLocationLoaded = true;
        notifyListeners();
        print("✅ Location initialized: ($latitude, $longitude)");
      } catch (e) {
        print("⚠️ Error getting current position: $e");
        // Try to get last known position as fallback
        Position? lastPosition = await Geolocator.getLastKnownPosition();
        if (lastPosition != null) {
          latitude = lastPosition.latitude;
          longitude = lastPosition.longitude;
          isLocationLoaded = true;
          notifyListeners();
          print("✅ Using last known position: ($latitude, $longitude)");
        }
      }
    } catch (e) {
      print("❌ Error initializing location: $e");
    } finally {
      isInitialized = true;
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
        position = await Geolocator.getCurrentPosition(
          desiredAccuracy: LocationAccuracy.high,
          timeLimit: const Duration(seconds: 5),
        );
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

  /// **Load Saved Location**
  Future<void> loadSavedLocation() async {
    print("🔄 Loading saved location...");
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
