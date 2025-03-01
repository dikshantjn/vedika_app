import 'dart:math';
import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:location/location.dart' as loc;
import 'package:provider/provider.dart';
import 'package:vedika_healthcare/core/navigation/AppRoutes.dart';
import 'package:vedika_healthcare/features/ambulance/presentation/view/EnableLocationPage.dart';
import 'package:vedika_healthcare/features/labTest/data/models/LabModel.dart';
import 'package:vedika_healthcare/features/labTest/data/repositories/LabRepository.dart';
import 'package:vedika_healthcare/shared/services/LocationProvider.dart';

class LabSearchViewModel extends ChangeNotifier {
  GoogleMapController? _mapController;
  LatLng? _currentPosition;
  Set<Marker> _markers = {};
  List<LabModel> _labs = [];
  List<LabModel> _filteredLabs = [];
  bool _isLoading = true;
  TextEditingController searchController = TextEditingController();

  // Track the selected lab
  LabModel? _selectedLab;

  GoogleMapController? get mapController => _mapController;
  Set<Marker> get markers => _markers;
  List<LabModel> get labs => _selectedLab != null ? [_selectedLab!] : _filteredLabs;
  bool get isLoading => _isLoading;
  LatLng? get currentPosition => _currentPosition;
  LabModel? get selectedLab => _selectedLab;

  void setMapController(GoogleMapController controller) {
    _mapController = controller;
    print("✅ MapController set in ViewModel");

    if (_currentPosition != null) {
      _mapController!.animateCamera(CameraUpdate.newLatLngZoom(_currentPosition!, 14));
      print("✅ Camera moved to user location from ViewModel");
    } else {
      print("🔴 Waiting for location update...");
    }

    notifyListeners();
  }

  Future<void> loadUserLocation(BuildContext context) async {
    try {
      _selectedLab = null; // Reset selected lab when reopening the page
      notifyListeners();

      var locationProvider = Provider.of<LocationProvider>(context, listen: false);
      loc.Location location = loc.Location();

      bool serviceEnabled = await location.serviceEnabled();
      if (!serviceEnabled) {
        serviceEnabled = await location.requestService();
        if (!serviceEnabled) {
          print("🔴 Location services disabled. Redirecting to EnableLocationPage.");
          Navigator.pushReplacement(
            context,
            MaterialPageRoute(builder: (context) => EnableLocationPage(fromSource: "labTest")),
          );
          return;
        }
      }

      loc.PermissionStatus permissionGranted = await location.hasPermission();
      if (permissionGranted == loc.PermissionStatus.denied) {
        permissionGranted = await location.requestPermission();
        if (permissionGranted != loc.PermissionStatus.granted) {
          print("🔴 Location permission denied. Redirecting to EnableLocationPage.");
          Navigator.pushReplacement(
            context,
            MaterialPageRoute(builder: (context) => EnableLocationPage(fromSource: "labTest")),
          );
          return;
        }
      }

      await locationProvider.loadSavedLocation();
      if (locationProvider.latitude != null && locationProvider.longitude != null) {
        _currentPosition = LatLng(locationProvider.latitude!, locationProvider.longitude!);
        print("✅ User location set: $_currentPosition");
      } else {
        print("🔴 Failed to get saved location!");
      }

      _isLoading = false;
      notifyListeners();
      print("✅ _isLoading set to false");

      if (_mapController != null && _currentPosition != null) {
        print("✅ Moving map to user location");
        _mapController!.animateCamera(CameraUpdate.newLatLngZoom(_currentPosition!, 14));
      } else {
        print("🔴 MapController is NULL. Waiting for it to be initialized.");
      }

      _fetchNearbyLabs(); // Fetch all nearby labs after resetting selection
      _addUserLocationMarker();
    } catch (e) {
      print("🔴 Error in loadUserLocation(): $e");
      _isLoading = false;
      notifyListeners();
    }
  }


  void _fetchNearbyLabs() {
    _labs = LabRepository.getLabs();
    _filteredLabs = _labs.where((lab) => _calculateDistance(lab.lat, lab.lng) <= 6.0).toList();
    _updateMarkers();
    notifyListeners();
  }

  double _calculateDistance(double lat, double lng) {
    const double earthRadius = 6371;
    double dLat = _degreesToRadians(lat - _currentPosition!.latitude);
    double dLng = _degreesToRadians(lng - _currentPosition!.longitude);

    double a = sin(dLat / 2) * sin(dLat / 2) +
        cos(_degreesToRadians(_currentPosition!.latitude)) *
            cos(_degreesToRadians(lat)) *
            sin(dLng / 2) *
            sin(dLng / 2);
    double c = 2 * atan2(sqrt(a), sqrt(1 - a));

    return earthRadius * c;
  }

  double _degreesToRadians(double degrees) {
    return degrees * pi / 180;
  }

  void _updateMarkers() {
    _markers.clear();

    _filteredLabs.forEach((lab) {
      _markers.add(
        Marker(
          markerId: MarkerId(lab.id),
          position: LatLng(lab.lat, lab.lng),
          infoWindow: InfoWindow(title: lab.name),
          onTap: () {
            moveCameraToLab(lab.lat, lab.lng, lab);
          },
        ),
      );
    });

    _addUserLocationMarker();
  }

  void _addUserLocationMarker() {
    if (_currentPosition == null) return;

    _markers.add(
      Marker(
        markerId: MarkerId("userLocation"),
        position: _currentPosition!,
        infoWindow: InfoWindow(title: "Your Location"),
        icon: BitmapDescriptor.defaultMarkerWithHue(BitmapDescriptor.hueAzure),
      ),
    );
    notifyListeners();
  }

  void filterLabs(String query) {
    _selectedLab = null; // Reset selected lab to show all matching results

    if (query.isEmpty) {
      _filteredLabs = _labs.where((lab) => _calculateDistance(lab.lat, lab.lng) <= 6.0).toList();
    } else {
      _filteredLabs = _labs.where((lab) {
        return lab.name.toLowerCase().contains(query.toLowerCase()) ||
            lab.tests.any((test) => test.name.toLowerCase().contains(query.toLowerCase()));  // Access test name
      }).toList();
    }

    notifyListeners();
  }



  void moveCameraToLab(double lat, double lng, LabModel lab) {
    _selectedLab = lab;
    notifyListeners();

    _mapController?.animateCamera(CameraUpdate.newLatLngZoom(LatLng(lat, lng), 14.0));
  }

  void bookLabAppointment(BuildContext context, LabModel lab) {
    Navigator.pushNamed(
      context,
      AppRoutes.bookLabTestAppointment,
      arguments: lab, // Pass the selected lab as an argument
    );
  }

}