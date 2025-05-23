import 'dart:async';
import 'package:location/location.dart';
import 'package:flutter/material.dart';
import 'package:vedika_healthcare/features/ambulance/presentation/view/EnableLocationPage.dart';

class EmergencyViewModel extends ChangeNotifier {
  bool isLoading = false;
  bool isLocationEnabled = false;
  bool showOptions = false;
  bool _mounted = true;

  @override
  void dispose() {
    _mounted = false;
    super.dispose();
  }

  // Helper method to safely notify listeners
  void _safeNotifyListeners() {
    if (_mounted) {
      notifyListeners();
    }
  }

  // Method to check if location services are enabled
  Future<void> checkLocationEnabled(BuildContext context) async {
    if (!_mounted) return;
    
    isLoading = true;
    _safeNotifyListeners();

    Location location = Location();

    try {
      // First, request permission to access the location
      PermissionStatus permissionStatus = await location.hasPermission();
      if (permissionStatus == PermissionStatus.denied) {
        permissionStatus = await location.requestPermission();
        if (permissionStatus != PermissionStatus.granted) {
          if (!_mounted) return;
          isLocationEnabled = false;
          isLoading = false;
          _safeNotifyListeners();
          return;
        }
      }

      // Check if location service is enabled
      bool serviceEnabled = await location.serviceEnabled();
      if (!serviceEnabled) {
        serviceEnabled = await location.requestService();
        if (!serviceEnabled) {
          if (!_mounted) return;
          isLocationEnabled = false;
          isLoading = false;
          _safeNotifyListeners();

          // If service is not enabled, navigate to the enable location page
          if (!context.mounted) return;
          Navigator.pushReplacement(
            context,
            MaterialPageRoute(builder: (context) => EnableLocationPage(fromSource: "emergency")),
          );
          return;
        }
      }

      // Attempt to fetch the location with a timeout
      try {
        final locationData = await location.getLocation().timeout(const Duration(seconds: 10));
        if (!_mounted) return;
        if (locationData.latitude != null && locationData.longitude != null) {
          isLocationEnabled = true;
          showOptions = true;
        } else {
          isLocationEnabled = false;
          showOptions = false;
        }
      } on TimeoutException catch (_) {
        if (!_mounted) return;
        isLocationEnabled = false;
        showOptions = false;
      } catch (e) {
        if (!_mounted) return;
        isLocationEnabled = false;
        showOptions = false;
      }

      if (!_mounted) return;
      isLoading = false;
      _safeNotifyListeners();
    } catch (e) {
      if (!_mounted) return;
      isLoading = false;
      isLocationEnabled = false;
      showOptions = false;
      _safeNotifyListeners();
    }
  }
}
