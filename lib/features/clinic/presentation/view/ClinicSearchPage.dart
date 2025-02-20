import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:provider/provider.dart';
import 'package:vedika_healthcare/features/clinic/data/models/Clinic.dart';
import 'package:vedika_healthcare/features/clinic/data/repositories/ClinicData.dart';
import 'package:vedika_healthcare/features/clinic/presentation/widgets/DraggableClinicList.dart';
import 'package:vedika_healthcare/shared/services/LocationProvider.dart';

const String apiKey = "AIzaSyAPbU5HX04forjDEfpkrhofAyna0cUfboI";

class ClinicSearchPage extends StatefulWidget {
  @override
  _ClinicSearchPageState createState() => _ClinicSearchPageState();
}

class _ClinicSearchPageState extends State<ClinicSearchPage> {
  GoogleMapController? _mapController;
  Set<Marker> _markers = {};
  List<Clinic> _clinics = [];
  bool _isLoading = true;
  LatLng? _currentPosition;
  List<bool> _expandedItems = [];
  TextEditingController _searchController = TextEditingController();
  List<Clinic> _filteredClinics = [];

  void _moveCameraToClinic(double lat, double lng) {
    _mapController?.animateCamera(
      CameraUpdate.newLatLngZoom(LatLng(lat, lng), 14.0),
    );
  }

  @override
  void initState() {
    super.initState();
    _loadUserLocation();
    _filteredClinics = List.from(_clinics);
    _expandedItems = List<bool>.generate(_clinics.length, (index) => false);
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

      _fetchNearbyClinics();
      _addUserLocationMarker(); // Add user location marker after getting the position
    }
  }

  void _fetchNearbyClinics() {
    if (_currentPosition == null) return;

    setState(() {
      // Create an instance of ClinicData to access the method
      var clinicData = ClinicData();

      // Fetch clinics using ClinicData and map them to Clinic objects
      List<Clinic> clinics = clinicData.getClinics(context); // Fetch clinics as List<Clinic>

      _clinics = clinics; // Set clinics to the fetched clinics
      _filteredClinics = List.from(_clinics);  // Set the filtered list initially to all clinics
      _expandedItems = List<bool>.filled(_clinics.length, false);  // Ensure the expanded state is correct

      // Set markers on the map
      _markers = _clinics.map((clinic) {
        return Marker(
          markerId: MarkerId(clinic.id),
          position: LatLng(clinic.lat, clinic.lng),
          infoWindow: InfoWindow(title: clinic.name),
          onTap: () {
            setState(() {
              _filteredClinics = [clinic];  // Show only the clicked clinic
              _expandedItems = [true];
            });
            _moveCameraToClinic(clinic.lat, clinic.lng);
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
          icon: BitmapDescriptor.defaultMarkerWithHue(BitmapDescriptor.hueAzure), // Blue marker
        ),
      );
    });
  }

  void _filterClinics(String query) {
    setState(() {
      if (query.isEmpty) {
        _filteredClinics = List.from(_clinics);
      } else {
        _filteredClinics = _clinics.where((clinic) {
          bool matches = clinic.name.toLowerCase().contains(query.toLowerCase()) ||
              clinic.address.toLowerCase().contains(query.toLowerCase()) ||
              clinic.doctors.any((doctor) => doctor.name.toLowerCase().contains(query.toLowerCase()));
          return matches;
        }).toList();
      }
      _expandedItems = List.generate(_filteredClinics.length, (index) => false);
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
                      _filterClinics(_searchController.text);
                    },
                    child: Icon(Icons.search, color: Colors.black54),
                  ),
                  SizedBox(width: 10),
                  Expanded(
                    child: TextField(
                      controller: _searchController,
                      onChanged: (value) {
                        _filterClinics(value);
                      },
                      decoration: InputDecoration(
                        hintText: "Search clinics...",
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
          DraggableClinicList(
            clinics: _filteredClinics.isNotEmpty ? _filteredClinics : _clinics,
            expandedItems: _expandedItems,
            onClinicTap: (index, lat, lng) {
              setState(() {
                _expandedItems[index] = !_expandedItems[index];
                _moveCameraToClinic(lat, lng);
              });
            },
          ),
        ],
      ),
    );
  }
}
