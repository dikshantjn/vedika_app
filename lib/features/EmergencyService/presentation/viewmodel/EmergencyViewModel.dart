import 'dart:async';
import 'package:location/location.dart';
import 'package:flutter/material.dart';
import 'package:vedika_healthcare/features/ambulance/presentation/view/EnableLocationPage.dart';

class EmergencyViewModel extends ChangeNotifier {
  bool isLoading = false;
  bool isLocationEnabled = false;
  bool showOptions = false;

  // Method to check if location services are enabled
  Future<void> checkLocationEnabled(BuildContext context) async {
    isLoading = true;
    notifyListeners(); // Notify the view to update UI

    Location location = Location();

    // First, request permission to access the location
    PermissionStatus permissionStatus = await location.hasPermission();
    if (permissionStatus == PermissionStatus.denied) {
      permissionStatus = await location.requestPermission();
      if (permissionStatus != PermissionStatus.granted) {
        isLocationEnabled = false;
        isLoading = false;
        notifyListeners();
        // Show message to the user that permission is denied
        return;
      }
    }

    // Check if location service is enabled
    bool serviceEnabled = await location.serviceEnabled();
    if (!serviceEnabled) {
      serviceEnabled = await location.requestService();
      if (!serviceEnabled) {
        isLocationEnabled = false;
        isLoading = false;
        notifyListeners();

        // If service is not enabled, navigate to the enable location page
        if (!context.mounted) return; // Check if the widget is still in the tree
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
      if (locationData.latitude != null && locationData.longitude != null) {
        isLocationEnabled = true;
        showOptions = true;
      } else {
        isLocationEnabled = false;
        showOptions = false;
      }
    } on TimeoutException catch (_) {
      isLocationEnabled = false;
      showOptions = false;
    } catch (e) {
      isLocationEnabled = false;
      showOptions = false;
    }

    isLoading = false;
    notifyListeners(); // Notify the view after processing
  }
}
