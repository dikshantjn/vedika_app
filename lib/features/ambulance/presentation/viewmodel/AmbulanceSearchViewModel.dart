import 'dart:math';
import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:location/location.dart';
import 'package:provider/provider.dart';
import 'package:vedika_healthcare/features/ambulance/data/models/Ambulance.dart';
import 'package:vedika_healthcare/features/ambulance/data/repositories/ambulance_data.dart';
import 'package:vedika_healthcare/features/ambulance/data/services/AmbulanceRequestNotificationService.dart';
import 'package:vedika_healthcare/features/ambulance/data/services/AmbulanceService.dart';
import 'package:vedika_healthcare/features/ambulance/presentation/view/EnableLocationPage.dart';
import 'package:vedika_healthcare/features/ambulance/presentation/widgets/AmbulanceDetailsBottomSheet.dart';
import 'package:vedika_healthcare/features/ambulance/presentation/widgets/AmbulancePaymentDialog.dart';
import 'package:vedika_healthcare/shared/services/LocationProvider.dart';

class AmbulanceSearchViewModel extends ChangeNotifier {
  GoogleMapController? mapController;
  LatLng? currentPosition;
  final Set<Marker> markers = {};
  List<Ambulance> ambulances = [];
  bool isLocationEnabled = false;
  bool mounted = true; // Manually track mounting state


  double chargePerKM = 50;
  double baseFare = 200;
  double nearbyDistance = 5.0;

  final BuildContext context;

  AmbulanceSearchViewModel(this.context) {
    _checkLocationEnabled();
  }

  Future<void> _checkLocationEnabled() async {
    Location location = Location();
    bool serviceEnabled = await location.serviceEnabled();

    if (!serviceEnabled) {
      serviceEnabled = await location.requestService();
      if (!serviceEnabled) {
        if (!context.mounted) return; // Check if widget is still in the tree
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(builder: (context) => EnableLocationPage(fromSource: "ambulance",)),
        );
        isLocationEnabled = false;
        if (mounted) notifyListeners(); // Prevent calling after dispose
        return;
      }
    }

    LocationData? userLocation = await location.getLocation();
    if (userLocation.latitude != null && userLocation.longitude != null) {
      isLocationEnabled = true;
      if (mounted) notifyListeners(); // Ensure it's still active
      initialize();
    } else {
      isLocationEnabled = false;
      if (mounted) notifyListeners(); // Ensure it's still active
      _showLocationDialog();
    }
  }


  Future<void> initialize() async {
    await getUserLocation();
    _fetchAmbulances();
  }

  Future<void> getUserLocation() async {
    var locationProvider = Provider.of<LocationProvider>(context, listen: false);
    await locationProvider.loadSavedLocation();

    if (locationProvider.latitude != null && locationProvider.longitude != null) {
      currentPosition = LatLng(locationProvider.latitude!, locationProvider.longitude!);

      // Ensure the user marker updates
      _addUserMarker();

      // Move the camera to the user's location
      if (mapController != null) {
        mapController!.animateCamera(CameraUpdate.newLatLngZoom(currentPosition!, 15));
      }

      // Fetch nearby ambulances
      _fetchAmbulances();
    } else {
      _showLocationDialog();
    }
  }

  void _addUserMarker() {
    if (currentPosition == null) return;

    markers.removeWhere((marker) => marker.markerId.value == "user_location");

    markers.add(
      Marker(
        markerId: const MarkerId("user_location"),
        position: currentPosition!,
        infoWindow: const InfoWindow(title: "Your Location"),
        icon: BitmapDescriptor.defaultMarkerWithHue(BitmapDescriptor.hueBlue),
      ),
    );

    notifyListeners();
  }



  void _showLocationDialog() {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => AlertDialog(
        title: const Text("Location Required"),
        content: const Text("Please enable location to use this feature."),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text("OK"),
          ),
        ],
      ),
    );
  }

  Future<void> _fetchAmbulances() async {
    if (currentPosition == null) return;

    List<Ambulance> fetchedAmbulances = getAmbulances(context);
    List<Ambulance> nearbyAmbulances = [];

    for (Ambulance ambulance in fetchedAmbulances) {
      double distance = _calculateDistance(
        currentPosition!.latitude,
        currentPosition!.longitude,
        ambulance.location.latitude,
        ambulance.location.longitude,
      );

      if (distance <= nearbyDistance) {
        nearbyAmbulances.add(ambulance);
      }
    }

    ambulances = nearbyAmbulances;

    if (mounted) notifyListeners(); // Ensure ViewModel is still active
    _addAmbulanceMarkers();
  }


  void _addAmbulanceMarkers() {
    markers.clear();

    if (currentPosition != null) {
      markers.add(
        Marker(
          markerId: const MarkerId("user_location"),
          position: currentPosition!,
          infoWindow: const InfoWindow(title: "Your Location"),
          icon: BitmapDescriptor.defaultMarkerWithHue(BitmapDescriptor.hueBlue),
        ),
      );
    }

    for (var ambulance in ambulances) {
      markers.add(
        Marker(
          markerId: MarkerId(ambulance.id),
          position: ambulance.location,
          infoWindow: InfoWindow(title: ambulance.name),
          icon: BitmapDescriptor.defaultMarkerWithHue(BitmapDescriptor.hueRose),
          onTap: () => _showAmbulanceDetails(ambulance),
        ),
      );
    }
    notifyListeners();
  }

  void _showAmbulanceDetails(Ambulance ambulance) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(16)),
      ),
      backgroundColor: Colors.grey.shade100,
      builder: (context) => AmbulanceDetailsBottomSheet(ambulance: ambulance),
    );
  }

  Ambulance? _findNearestAmbulance() {
    if (currentPosition == null) return null;
    Ambulance? nearestAmbulance;
    double minDistance = double.infinity;

    for (Ambulance ambulance in ambulances) {
      double distance = _calculateDistance(
        currentPosition!.latitude,
        currentPosition!.longitude,
        ambulance.location.latitude,
        ambulance.location.longitude,
      );

      if (distance <= nearbyDistance && distance < minDistance) {
        minDistance = distance;
        nearestAmbulance = ambulance;
      }
    }
    return nearestAmbulance;
  }

  double _calculateDistance(double lat1, double lon1, double lat2, double lon2) {
    const R = 6371;
    double dLat = (lat2 - lat1) * pi / 180;
    double dLon = (lon2 - lon1) * pi / 180;
    double a = sin(dLat / 2) * sin(dLat / 2) +
        cos(lat1 * pi / 180) * cos(lat2 * pi / 180) * sin(dLon / 2) * sin(dLon / 2);
    double c = 2 * atan2(sqrt(a), sqrt(1 - a));
    return R * c;
  }

  void callNearestAmbulance() async {
    if (currentPosition == null) {
      _showLocationDialog();
      return;
    }

    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => const Center(child: CircularProgressIndicator()),
    );

    try {
      Ambulance? nearestAmbulance = _findNearestAmbulance();
      Navigator.pop(context);

      if (nearestAmbulance == null) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text("No ambulance available nearby.")),
        );
        return;
      }

      bool accepted = await AmbulanceService().triggerAmbulanceEmergency(nearestAmbulance.contact);
      if (accepted) {
        double totalDistance = _calculateDistance(
          currentPosition!.latitude,
          currentPosition!.longitude,
          nearestAmbulance.location.latitude,
          nearestAmbulance.location.longitude,
        );

        double totalAmount = baseFare + (totalDistance * chargePerKM);
        await AmbulanceRequestNotificationService.showAmbulanceRequestNotification(
          ambulanceName: nearestAmbulance.name,
          contact: nearestAmbulance.contact,
          totalDistance: totalDistance,
          baseFare: baseFare,
          distanceCharge: totalDistance * chargePerKM,
          totalAmount: totalAmount,
        );

        showDialog(
          context: context,
          builder: (context) => AmbulancePaymentDialog(
            providerName: nearestAmbulance.name,
            baseFare: baseFare,
            distanceCharge: totalDistance * chargePerKM,
            totalAmount: totalAmount,
            totalDistance: totalDistance,
            onPaymentSuccess: () {
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text("Payment Successful! Booking Confirmed.")),
              );
            },
          ),
        );
      }
    } catch (e) {
      Navigator.pop(context);
      print("Error: $e");
    }
  }
}
