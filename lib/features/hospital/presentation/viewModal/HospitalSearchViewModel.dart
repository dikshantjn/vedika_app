import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:provider/provider.dart';
import 'package:vedika_healthcare/features/hospital/data/repository/HospitalData.dart';
import 'package:vedika_healthcare/shared/services/LocationProvider.dart';

class HospitalSearchViewModel extends ChangeNotifier {
  List<Map<String, dynamic>> _hospitals = [];
  List<Map<String, dynamic>> _filteredHospitals = [];
  List<bool> _expandedItems = [];
  bool _isLoading = true;
  LatLng? _currentPosition;
  TextEditingController _searchController = TextEditingController();

  List<Map<String, dynamic>> get filteredHospitals => _filteredHospitals;
  List<bool> get expandedItems => _expandedItems;
  bool get isLoading => _isLoading;
  LatLng? get currentPosition => _currentPosition;
  TextEditingController get searchController => _searchController;

  // Getter for _hospitals
  List<Map<String, dynamic>> get hospitals => _hospitals;

  // Fetch Hospitals based on context and location
  Future<void> loadHospitals(BuildContext context) async {
    var locationProvider = Provider.of<LocationProvider>(context, listen: false);

    await locationProvider.loadSavedLocation();

    if (locationProvider.latitude != null && locationProvider.longitude != null) {
      _currentPosition = LatLng(locationProvider.latitude!, locationProvider.longitude!);
      _hospitals = await HospitalData.getHospitals(context);
      _filteredHospitals = List.from(_hospitals);
      _expandedItems = List<bool>.filled(_hospitals.length, false);
      _isLoading = false;
      notifyListeners();
    }
  }

  // Filter Hospitals based on the search query
  void filterHospitals(String query) {
    if (query.isEmpty) {
      _filteredHospitals = List.from(_hospitals);
    } else {
      _filteredHospitals = _hospitals.where((hospital) {
        bool matches = hospital["name"].toString().toLowerCase().contains(query.toLowerCase()) ||
            hospital["address"].toString().toLowerCase().contains(query.toLowerCase()) ||
            (hospital["doctors"] as List<dynamic>)
                .map((doctor) => doctor.toString().toLowerCase())
                .any((doctor) => doctor.contains(query.toLowerCase()));
        return matches;
      }).toList();
    }
    _expandedItems = List.generate(_filteredHospitals.length, (index) => false);
    notifyListeners();
  }

  // Toggle expanded item status
  void toggleExpansion(int index) {
    _expandedItems[index] = !_expandedItems[index];
    notifyListeners();
  }

  // Get markers based on hospital data
  Set<Marker> getMarkers() {
    return _hospitals.map((hospital) {
      return Marker(
        markerId: MarkerId(hospital["id"]),
        position: LatLng(hospital["lat"], hospital["lng"]),
        infoWindow: InfoWindow(title: hospital["name"]),
        onTap: () {
          // Handle marker tap
        },
      );
    }).toSet();
  }

  // Get user location marker
  Marker getUserLocationMarker(LatLng userPosition) {
    return Marker(
      markerId: MarkerId("userLocation"),
      position: userPosition,
      infoWindow: InfoWindow(title: "Your Location"),
      icon: BitmapDescriptor.defaultMarkerWithHue(BitmapDescriptor.hueAzure),
    );
  }
}
