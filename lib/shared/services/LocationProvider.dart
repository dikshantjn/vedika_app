import 'package:flutter/material.dart';
import 'package:geolocator/geolocator.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:vedika_healthcare/core/auth/data/services/StorageService.dart';
import 'package:vedika_healthcare/core/auth/data/services/UserService.dart';

class LocationProvider with ChangeNotifier {
  double? latitude;
  double? longitude;
  bool isLocationLoaded = false;
  bool isInitialized = false;
  final UserService _userService = UserService();
  bool _shouldUpdateBackend = false;

  LocationProvider() {
    print("Initializing LocationProvider...");
  }

  /// **Initialize Location**
  Future<void> initializeLocation({bool updateBackend = false}) async {
    if (isInitialized && !updateBackend) return;
    
    _shouldUpdateBackend = updateBackend;
    
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

        // Update user coordinates in backend only if requested
        if (_shouldUpdateBackend) {
          await _updateUserCoordinatesInBackend();
        }
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

          // Update user coordinates in backend only if requested
          if (_shouldUpdateBackend) {
            await _updateUserCoordinatesInBackend();
          }
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
    return enabled;
  }

  /// **Request Location Permission**
  Future<bool> requestLocationPermission() async {
    LocationPermission permission = await Geolocator.checkPermission();

    if (permission == LocationPermission.always || permission == LocationPermission.whileInUse) {
      return true;
    }

    print("⚠️ Requesting location permission...");
    permission = await Geolocator.requestPermission();

    bool granted = (permission == LocationPermission.always || permission == LocationPermission.whileInUse);
    return granted;
  }

  /// **Fetch Fresh Location and Update Values**
  Future<void> fetchLocation({bool updateBackend = false}) async {
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

        // Update user coordinates in backend only if requested
        if (updateBackend) {
          await _updateUserCoordinatesInBackend();
        }
      } else {
        print("❌ Unable to fetch location.");
      }
    } catch (e) {
      print("❌ Error getting location: $e");
    }
  }

  /// **Load Saved Location**
  Future<void> loadSavedLocation({bool updateBackend = false}) async {
    await fetchLocation(updateBackend: updateBackend);
  }

  /// **Get Current Location**
  LatLng? getCurrentLocation() {
    if (latitude != null && longitude != null) {
      return LatLng(latitude!, longitude!);
    }
    return null;
  }

  /// **Update User Coordinates in Backend**
  Future<void> _updateUserCoordinatesInBackend() async {
    try {
      if (latitude == null || longitude == null) {
        print("⚠️ No coordinates available to update");
        return;
      }

      String? userId = await StorageService.getUserId();
      if (userId == null) {
        print("⚠️ User ID not found, skipping backend update");
        return;
      }

      String coordinates = "$latitude,$longitude";
      bool success = await _userService.updateUserCoordinates(userId, coordinates);
      if (success) {
      } else {
        print("❌ Failed to update user coordinates in backend");
      }
    } catch (e) {
      print("❌ Error updating user coordinates in backend: $e");
    }
  }

  /// **Update Location After Login**
  Future<void> updateLocationAfterLogin() async {
    _shouldUpdateBackend = true;
    if (isLocationLoaded) {
      // If we already have location, just update the backend
      await _updateUserCoordinatesInBackend();
    } else {
      // If we don't have location yet, fetch it and update the backend
      await fetchLocation(updateBackend: true);
    }
  }
}
