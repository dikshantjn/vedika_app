import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:vedika_healthcare/features/ambulance/presentation/view/EnableLocationPage.dart';
import 'package:vedika_healthcare/features/clinic/data/models/Clinic.dart';
import 'package:vedika_healthcare/features/clinic/data/repositories/ClinicData.dart';
import 'package:vedika_healthcare/shared/services/LocationProvider.dart';
import 'package:provider/provider.dart';
import 'package:location/location.dart' as loc;

class ClinicSearchViewModel extends ChangeNotifier {
  GoogleMapController? _mapController;
  Set<Marker> _markers = {};
  List<Clinic> _clinics = [];
  bool _isLoading = true;
  bool _isLoadingLocation = true;
  LatLng? _currentPosition;
  List<bool> _expandedItems = [];
  TextEditingController searchController = TextEditingController();
  List<Clinic> _filteredClinics = [];

  GoogleMapController? get mapController => _mapController;
  Set<Marker> get markers => _markers;
  List<Clinic> get clinics => _clinics;
  bool get isLoading => _isLoading;
  bool get isLoadingLocation => _isLoadingLocation;
  LatLng? get currentPosition => _currentPosition;
  List<bool> get expandedItems => _expandedItems;
  List<Clinic> get filteredClinics => _filteredClinics;

  void onMapCreated(GoogleMapController controller) {
    _mapController = controller;
    notifyListeners();
  }


  Future<void> ensureLocationEnabled(BuildContext context) async {
    var locationProvider = Provider.of<LocationProvider>(context, listen: false);
    loc.Location location = loc.Location();

    bool serviceEnabled = await location.serviceEnabled();
    if (!serviceEnabled) {
      serviceEnabled = await location.requestService();
      if (!serviceEnabled) {
        print("🔴 User refused to enable location services.");
        WidgetsBinding.instance.addPostFrameCallback((_) {
          Navigator.pushReplacement(
            context,
            MaterialPageRoute(builder: (context) => EnableLocationPage(fromSource: "clinic")),
          );
        });
        return;
      }
    }

    loc.PermissionStatus permissionGranted = await location.hasPermission();
    if (permissionGranted == loc.PermissionStatus.denied) {
      permissionGranted = await location.requestPermission();
      if (permissionGranted != loc.PermissionStatus.granted) {
        print("🔴 User denied location permission.");
        WidgetsBinding.instance.addPostFrameCallback((_) {
          Navigator.pushReplacement(
            context,
            MaterialPageRoute(builder: (context) => EnableLocationPage(fromSource: "clinic")),
          );
        });
        return;
      }
    }

    print("✅ Location service enabled and permission granted.");

    // Load saved location
    await locationProvider.loadSavedLocation();
    if (locationProvider.latitude != null && locationProvider.longitude != null) {
      _currentPosition = LatLng(locationProvider.latitude!, locationProvider.longitude!);
      print("✅ Updated Position: $_currentPosition");

      _isLoadingLocation = false;
      notifyListeners();

      await loadUserLocation(context);
    } else {
      print("🔴 LocationProvider did not return a valid location.");
      _isLoadingLocation = false;
      notifyListeners();
    }
  }



  Future<void> loadUserLocation(BuildContext context) async {
    var locationProvider = Provider.of<LocationProvider>(context, listen: false);
    await locationProvider.loadSavedLocation();

    if (locationProvider.latitude != null && locationProvider.longitude != null) {
      _currentPosition = LatLng(locationProvider.latitude!, locationProvider.longitude!);
      _isLoading = false;
      _mapController?.animateCamera(CameraUpdate.newLatLngZoom(_currentPosition!, 14));
      _fetchNearbyClinics(context);
      _addUserLocationMarker();
      notifyListeners();
    }
  }

  void _fetchNearbyClinics(BuildContext context) {
    if (_currentPosition == null) return;
    var clinicData = ClinicData();
    _clinics = clinicData.getClinics(context);
    _filteredClinics = List.from(_clinics);
    _expandedItems = List<bool>.filled(_clinics.length, false);
    _setClinicMarkers();
    notifyListeners();
  }

  void _setClinicMarkers() {
    _markers = _clinics.map((clinic) {
      return Marker(
        markerId: MarkerId(clinic.id),
        position: LatLng(clinic.lat, clinic.lng),
        infoWindow: InfoWindow(title: clinic.name),
        onTap: () {
          _filteredClinics = [clinic];
          _expandedItems = [true];
          _moveCameraToClinic(clinic.lat, clinic.lng);
          notifyListeners();
        },
      );
    }).toSet();
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

  void _moveCameraToClinic(double lat, double lng) {
    _mapController?.animateCamera(CameraUpdate.newLatLngZoom(LatLng(lat, lng), 14.0));
    notifyListeners();
  }

  void filterClinics(String query) {
    if (query.isEmpty) {
      _filteredClinics = List.from(_clinics);
    } else {
      _filteredClinics = _clinics.where((clinic) {
        return clinic.name.toLowerCase().contains(query.toLowerCase()) ||
            clinic.address.toLowerCase().contains(query.toLowerCase()) ||
            clinic.doctors.any((doctor) => doctor.name.toLowerCase().contains(query.toLowerCase()));
      }).toList();
    }
    _expandedItems = List.generate(_filteredClinics.length, (index) => false);
    notifyListeners();
  }

  void toggleClinicExpansion(int index) {
    expandedItems[index] = !expandedItems[index];
    notifyListeners(); // Notify the UI to update
  }

}
