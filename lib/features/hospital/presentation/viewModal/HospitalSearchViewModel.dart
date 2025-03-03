import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:provider/provider.dart';
import 'package:vedika_healthcare/features/ambulance/presentation/view/EnableLocationPage.dart';
import 'package:vedika_healthcare/features/hospital/data/repository/HospitalData.dart';
import 'package:vedika_healthcare/shared/services/LocationProvider.dart';
import 'package:location/location.dart' as loc;


class HospitalSearchViewModel extends ChangeNotifier {
  GoogleMapController? _mapController;
  List<Map<String, dynamic>> _hospitals = [];
  List<Map<String, dynamic>> _filteredHospitals = [];
  List<bool> _expandedItems = [];
  bool _isLoading = true;
  bool _isLoadingLocation = true;
  LatLng? _currentPosition;
  TextEditingController _searchController = TextEditingController();
  Set<Marker> _markers = {};

  List<Map<String, dynamic>> get filteredHospitals => _filteredHospitals;
  List<bool> get expandedItems => _expandedItems;
  bool get isLoading => _isLoading;
  bool get isLoadingLocation => _isLoadingLocation;
  LatLng? get currentPosition => _currentPosition;
  TextEditingController get searchController => _searchController;
  Set<Marker> get markers => _markers;

  /// **Ensure Location is Enabled and Fetch Hospitals**
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
            MaterialPageRoute(builder: (context) => EnableLocationPage(fromSource: "hospital")),
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
            MaterialPageRoute(builder: (context) => EnableLocationPage(fromSource: "hospital")),
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

      await loadHospitals(context);
    } else {
      print("🔴 LocationProvider did not return a valid location.");
      _isLoadingLocation = false;
      notifyListeners();
    }
  }




  /// **Fetch Hospitals Based on User Location**
  Future<void> loadHospitals(BuildContext context) async {
    print("🔄 loadHospitals started...");

    if (_currentPosition != null) {  // ✅ Avoid duplicate location fetch
      _hospitals = await HospitalData.getHospitals(context);
      print("🏥 Retrieved ${_hospitals.length} hospitals from API.");

      _filteredHospitals = List.from(_hospitals);
      _expandedItems = List<bool>.filled(_hospitals.length, false);

      _isLoading = false;
      _isLoadingLocation = false;

      _addMarkers();
      notifyListeners(); // ✅ Notify UI to update

      print("✅ Hospitals loaded successfully.");
    } else {
      print("❌ Location data is still null.");
    }
  }



  /// **Filter Hospitals Based on Search Query**
  void filterHospitals(String query) {
    if (query.isEmpty) {
      _filteredHospitals = List.from(_hospitals);
    } else {
      _filteredHospitals = _hospitals.where((hospital) {
        return hospital["name"].toString().toLowerCase().contains(query.toLowerCase()) ||
            hospital["address"].toString().toLowerCase().contains(query.toLowerCase()) ||
            (hospital["doctors"] as List<dynamic>)
                .map((doctor) => doctor.toString().toLowerCase())
                .any((doctor) => doctor.contains(query.toLowerCase()));
      }).toList();
    }
    _expandedItems = List.generate(_filteredHospitals.length, (index) => false);
    notifyListeners();
  }

  /// **Toggle Expanded Item Status**
  void toggleExpansion(int index) {
    _expandedItems[index] = !_expandedItems[index];
    notifyListeners();
  }

  /// **Move Camera to Selected Hospital**
  void moveCameraToHospital(double lat, double lng) {
    _mapController?.animateCamera(CameraUpdate.newLatLngZoom(LatLng(lat, lng), 14.0));
  }

  /// **Initialize Google Map Controller**
  void onMapCreated(GoogleMapController controller) {
    _mapController = controller;
    notifyListeners();
  }

  /// **Add Markers for Hospitals and User Location**
  void _addMarkers() {
    print("📍 Adding markers...");
    _markers.clear();
    _markers.addAll(_hospitals.map((hospital) {
      return Marker(
        markerId: MarkerId(hospital["id"]),
        position: LatLng(hospital["lat"], hospital["lng"]),
        infoWindow: InfoWindow(title: hospital["name"]),
        onTap: () {
          filterHospitals(hospital["name"]);
          moveCameraToHospital(hospital["lat"], hospital["lng"]);
        },
      );
    }));

    if (_currentPosition != null) {
      _markers.add(
        Marker(
          markerId: MarkerId("userLocation"),
          position: _currentPosition!,
          infoWindow: InfoWindow(title: "Your Location"),
          icon: BitmapDescriptor.defaultMarkerWithHue(BitmapDescriptor.hueAzure),
        ),
      );
    }
    notifyListeners();
    print("✅ Markers added: ${_markers.length}");
  }


  /// **Handle Hospital Tap**
  void onHospitalTap(int index, double lat, double lng) {
    if (index >= 0 && index < _filteredHospitals.length) {
      toggleExpansion(index);
      moveCameraToHospital(lat, lng);
    }
  }
}
