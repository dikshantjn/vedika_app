import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:provider/provider.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:vedika_healthcare/core/constants/colorpalette/ColorPalette.dart';
import 'package:vedika_healthcare/features/ambulance/data/models/Ambulance.dart';
import 'package:vedika_healthcare/features/ambulance/data/repositories/ambulance_data.dart';
import 'package:vedika_healthcare/features/ambulance/data/services/AmbulanceService.dart';
import 'package:vedika_healthcare/features/ambulance/presentation/widgets/AmbulanceDetailsBottomSheet.dart';
import 'package:vedika_healthcare/shared/services/LocationProvider.dart';
import 'package:vedika_healthcare/shared/widgets/DrawerMenu.dart';

class AmbulanceSearchPage extends StatefulWidget {
  @override
  _AmbulanceSearchPageState createState() => _AmbulanceSearchPageState();
}

class _AmbulanceSearchPageState extends State<AmbulanceSearchPage> {
  late GoogleMapController _mapController;
  LatLng _currentPosition = LatLng(20.5937, 78.9629);
  final Set<Marker> _markers = {};
  List<Ambulance> _ambulances = [];

  @override
  void initState() {
    super.initState();
    _initializeMap();
  }

  Future<void> _initializeMap() async {
    _fetchAmbulances();
    _getUserLocation();
  }

  Future<void> _getUserLocation() async {
    var locationProvider = Provider.of<LocationProvider>(context, listen: false);
    await locationProvider.loadSavedLocation();

    if (locationProvider.latitude != null && locationProvider.longitude != null) {
      setState(() {
        _currentPosition = LatLng(locationProvider.latitude!, locationProvider.longitude!);
      });

      if (_mapController != null) {
        _mapController.animateCamera(
          CameraUpdate.newLatLngZoom(_currentPosition, 15),
        );
      }

      _addAmbulanceMarkers();
    } else {
      print("User location not available.");
    }
  }

  void _fetchAmbulances() {
    setState(() {
      _ambulances = getAmbulances(context);
    });

    _addAmbulanceMarkers();
  }

  void _addAmbulanceMarkers() {
    setState(() {
      _markers.clear();

      _markers.add(
        Marker(
          markerId: MarkerId("user_location"),
          position: _currentPosition,
          infoWindow: InfoWindow(title: "Your Location"),
          icon: BitmapDescriptor.defaultMarkerWithHue(BitmapDescriptor.hueBlue),
        ),
      );

      for (var ambulance in _ambulances) {
        _markers.add(
          Marker(
            markerId: MarkerId(ambulance.id),
            position: ambulance.location,
            infoWindow: InfoWindow(title: ambulance.name),
            icon: BitmapDescriptor.defaultMarkerWithHue(BitmapDescriptor.hueRose),
            onTap: () {
              _showAmbulanceDetails(ambulance);
            },
          ),
        );
      }
    });
  }

  void _showAmbulanceDetails(Ambulance ambulance) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(16)),
      ),
      backgroundColor: Colors.grey.shade100,
      builder: (context) {
        return AmbulanceDetailsBottomSheet(
          ambulance: ambulance,
        );
      },
    );
  }

  void _openGoogleMaps(LatLng position) async {
    final String googleMapsUrl =
        "https://www.google.com/maps/dir/?api=1&destination=${position.latitude},${position.longitude}&travelmode=driving";
    if (await canLaunchUrl(Uri.parse(googleMapsUrl))) {
      await launchUrl(Uri.parse(googleMapsUrl));
    } else {
      throw 'Could not open Google Maps.';
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("Nearby Ambulance Services"),
        backgroundColor: ColorPalette.primaryColor,
        centerTitle: true,
        foregroundColor: Colors.white,
      ),
      drawer: DrawerMenu(),
      body: Column(
        children: [
          Expanded(
            flex: 4,
            child: GoogleMap(
              onMapCreated: (GoogleMapController controller) {
                _mapController = controller;
                _getUserLocation();
              },
              initialCameraPosition: CameraPosition(target: _currentPosition, zoom: 14),
              markers: _markers,
              myLocationEnabled: true,
              compassEnabled: true,
              zoomControlsEnabled: true,
            ),
          ),
          Container(
            width: double.infinity,
            decoration: BoxDecoration(
              color: Colors.white,
              boxShadow: [
                BoxShadow(color: Colors.black26, blurRadius: 4, spreadRadius: 2),
              ],
              borderRadius: BorderRadius.vertical(top: Radius.circular(16)),
            ),
            padding: EdgeInsets.all(16),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                Text(
                  "Need an Ambulance Urgently?",
                  style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                ),
                SizedBox(height: 8),
                Text(
                  "Call an ambulance now for immediate assistance.",
                  textAlign: TextAlign.center,
                  style: TextStyle(fontSize: 14, color: Colors.black54),
                ),
                SizedBox(height: 12),
                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton(
                    onPressed: () {
                      // Call the AmbulanceService before launching the call
                      AmbulanceService().triggerAmbulanceEmergency("+919370320066"); // Static phone number
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.green,
                      foregroundColor: Colors.white,
                      padding: EdgeInsets.symmetric(vertical: 14),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(8),
                      ),
                    ),
                    child: Text("Call Ambulance", style: TextStyle(fontSize: 16)),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
