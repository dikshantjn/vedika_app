import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:provider/provider.dart';
import 'package:vedika_healthcare/features/hospital/data/repository/HospitalData.dart';
import 'package:vedika_healthcare/features/hospital/presentation/widgets/DraggableHospitalList.dart';
import 'package:vedika_healthcare/shared/services/LocationProvider.dart';

const String apiKey = "AIzaSyAPbU5HX04forjDEfpkrhofAyna0cUfboI";

class HospitalSearchPage extends StatefulWidget {
  @override
  _HospitalSearchPageState createState() => _HospitalSearchPageState();
}

class _HospitalSearchPageState extends State<HospitalSearchPage> {
  GoogleMapController? _mapController;
  Set<Marker> _markers = {};
  List<Map<String, dynamic>> _hospitals = [];
  bool _isLoading = true;
  LatLng? _currentPosition;
  List<bool> _expandedItems = [];
  TextEditingController _searchController = TextEditingController();
  List<Map<String, dynamic>> _filteredHospitals = [];

  void _moveCameraToHospital(double lat, double lng) {
    _mapController?.animateCamera(
      CameraUpdate.newLatLngZoom(LatLng(lat, lng), 14.0),
    );
  }

  @override
  void initState() {
    super.initState();
    _loadUserLocation();
    _filteredHospitals = List.from(_hospitals);
    _expandedItems = List<bool>.generate(_hospitals.length, (index) => false);
  }

  void _loadUserLocation() async {
    var locationProvider = Provider.of<LocationProvider>(context, listen: false);

    await locationProvider.loadSavedLocation();
    if (locationProvider.latitude != null && locationProvider.longitude != null) {
      setState(() {
        _currentPosition = LatLng(locationProvider.latitude!, locationProvider.longitude!);
        _isLoading = false;
      });

      if (_mapController != null) {
        _mapController!.animateCamera(CameraUpdate.newLatLngZoom(_currentPosition!, 14));
      }

      _fetchNearbyHospitals();
      _addUserLocationMarker(); // Add the user location marker after getting the position
    }
  }

  // Fetch Nearby Hospitals (Static Data for Now)
  void _fetchNearbyHospitals() {
    if (_currentPosition == null) return;

    setState(() {
      _hospitals = HospitalData.getHospitals(context);
      _filteredHospitals = List.from(_hospitals);
      _expandedItems = List<bool>.filled(_hospitals.length, false);

      _markers = _hospitals.map((hospital) {
        return Marker(
          markerId: MarkerId(hospital["id"]),
          position: LatLng(hospital["lat"], hospital["lng"]),
          infoWindow: InfoWindow(title: hospital["name"]),
          onTap: () {
            setState(() {
              _filteredHospitals = [hospital];
              _expandedItems = [true];
            });
            _moveCameraToHospital(hospital["lat"], hospital["lng"]);
          },
        );
      }).toSet();
    });
  }

  // Add Marker for User Location
  void _addUserLocationMarker() {
    if (_currentPosition == null) return;

    setState(() {
      _markers.add(
        Marker(
          markerId: MarkerId("userLocation"),
          position: _currentPosition!,
          infoWindow: InfoWindow(title: "Your Location"),
          icon: BitmapDescriptor.defaultMarkerWithHue(BitmapDescriptor.hueAzure), // Change the marker color to blue
        ),
      );
    });
  }

  void _filterHospitals(String query) {
    setState(() {
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
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        children: [
          // Google Map
          Positioned.fill(
            child: _isLoading || _currentPosition == null
                ? Center(child: CircularProgressIndicator())
                : GoogleMap(
              initialCameraPosition: CameraPosition(
                target: _currentPosition!,
                zoom: 14,
              ),
              markers: _markers,
              onMapCreated: (controller) {
                _mapController = controller;
              },
              myLocationEnabled: true,
              myLocationButtonEnabled: false,
            ),
          ),
          // Search Bar with TextField and IconButton
          Positioned(
            top: 40,
            left: 15,
            right: 15,
            child: Container(
              padding: EdgeInsets.symmetric(horizontal: 15),
              height: 50,
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(30),
                boxShadow: [BoxShadow(color: Colors.black26, blurRadius: 5)],
              ),
              child: Row(
                children: [
                  GestureDetector(
                    onTap: () {
                      _filterHospitals(_searchController.text);
                    },
                    child: Icon(Icons.search, color: Colors.black54),
                  ),
                  SizedBox(width: 10),
                  Expanded(
                    child: TextField(
                      controller: _searchController,
                      onChanged: (value) {
                        _filterHospitals(value);
                      },
                      decoration: InputDecoration(
                        hintText: "Search hospitals...",
                        border: InputBorder.none,
                        hintStyle: TextStyle(color: Colors.black54),
                      ),
                      style: TextStyle(color: Colors.black),
                    ),
                  ),
                ],
              ),
            ),
          ),
          DraggableHospitalList(
            hospitals: _filteredHospitals.isNotEmpty ? _filteredHospitals : _hospitals,
            expandedItems: _expandedItems,
            onHospitalTap: (index, lat, lng) {
              setState(() {
                _expandedItems[index] = !_expandedItems[index];
                _moveCameraToHospital(lat, lng);
              });
            },
          ),
        ],
      ),
    );
  }
}

