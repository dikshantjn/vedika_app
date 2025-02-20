import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:geolocator/geolocator.dart';
import 'package:url_launcher/url_launcher.dart';

class BloodBankMapScreen extends StatefulWidget {
  @override
  _BloodBankMapState createState() => _BloodBankMapState();
}

class _BloodBankMapState extends State<BloodBankMapScreen> {
  late GoogleMapController _mapController;
  LatLng _currentPosition = LatLng(20.5937, 78.9629);
  final Set<Marker> _markers = {};
  Map<String, dynamic>? _selectedBloodBank;

  final List<Map<String, dynamic>> _bloodBanks = [
    {
      "name": "Red Cross Blood Bank",
      "latOffset": 0.005,
      "lngOffset": 0.005,
      "address": "123 Red Street, Nearby",
      "contact": "+91 9876543210"
    },
    {
      "name": "LifeSaver Blood Bank",
      "latOffset": -0.004,
      "lngOffset": 0.006,
      "address": "45 Green Road, Nearby",
      "contact": "+91 9765432109"
    },
    {
      "name": "Hope Blood Bank",
      "latOffset": 0.003,
      "lngOffset": -0.005,
      "address": "78 White Avenue, Nearby",
      "contact": "+91 9876123456"
    }
  ];

  @override
  void initState() {
    super.initState();
    _initializeMap();
  }

  Future<void> _initializeMap() async {
    await _getUserLocation();  // Ensure we get the user's location first
    if (mounted) _addBloodBankMarkers();  // Add blood banks only after location is set
  }


  Future<void> _getUserLocation() async {
    LocationPermission permission = await Geolocator.requestPermission();
    if (permission == LocationPermission.denied ||
        permission == LocationPermission.deniedForever) {
      return;
    }

    Position position = await Geolocator.getCurrentPosition(
        desiredAccuracy: LocationAccuracy.high);

    if (!mounted) return;

    setState(() {
      _currentPosition = LatLng(position.latitude, position.longitude);
    });

    _mapController.animateCamera(
      CameraUpdate.newLatLngZoom(_currentPosition, 14), // Move to actual location
    );

    _addUserMarker();  // Add user marker after location is updated
  }

  void _addUserMarker() {
    setState(() {
      _markers.add(
        Marker(
          markerId: MarkerId("user_location"),
          position: _currentPosition,
          infoWindow: InfoWindow(title: "Your Location"),
          icon: BitmapDescriptor.defaultMarkerWithHue(BitmapDescriptor.hueBlue),
        ),
      );
    });
  }


  void _addBloodBankMarkers() {
    setState(() {
      _markers.clear();  // Clear old markers before adding new ones

      // Re-add user location marker
      _markers.add(
        Marker(
          markerId: MarkerId("user_location"),
          position: _currentPosition,
          infoWindow: InfoWindow(title: "Your Location"),
          icon: BitmapDescriptor.defaultMarkerWithHue(BitmapDescriptor.hueBlue),
        ),
      );

      for (var bank in _bloodBanks) {
        LatLng bloodBankPosition = LatLng(
          _currentPosition.latitude + bank["latOffset"],
          _currentPosition.longitude + bank["lngOffset"],
        );

        _markers.add(
          Marker(
            markerId: MarkerId(bank["name"]),
            position: bloodBankPosition,
            infoWindow: InfoWindow(title: bank["name"]),
            icon: BitmapDescriptor.defaultMarkerWithHue(BitmapDescriptor.hueRed),
            onTap: () {
              _showBloodBankDetails(bank, bloodBankPosition);
            },
          ),
        );
      }
    });
  }


  void _showBloodBankDetails(Map<String, dynamic> bloodBank, LatLng position) {
    setState(() {
      _selectedBloodBank = bloodBank;
    });

    // Dummy blood availability data for the selected blood bank
    List<Map<String, String>> availableBlood = [
      {"group": "A+", "units": "5"},
      {"group": "A-", "units": "3"},
      {"group": "B+", "units": "7"},
      {"group": "B-", "units": "2"},
      {"group": "O+", "units": "10"},
      {"group": "O-", "units": "1"},
      {"group": "AB+", "units": "4"},
      {"group": "AB-", "units": "2"},
    ];

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(16)),
      ),
      backgroundColor: Colors.grey.shade100,
      builder: (context) {
        return Stack(
          clipBehavior: Clip.none,
          children: [
            Container(
              width: double.infinity,
              padding: EdgeInsets.all(16),
              constraints: BoxConstraints(minHeight: 350),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisSize: MainAxisSize.min,
                children: [
                  // Blood Bank Name
                  Text(
                    bloodBank["name"],
                    style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                  ),
                  SizedBox(height: 8),

                  // Address
                  Text("📍 Address: ${bloodBank["address"]}"),

                  // Contact
                  Text("📞 Contact: ${bloodBank["contact"]}"),

                  SizedBox(height: 12),

                  // Available Blood Types Section
                  Text(
                    "🩸 Available Blood Types:",
                    style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                  ),
                  SizedBox(height: 6),

                  // Blood Group List
                  Wrap(
                    spacing: 8,
                    runSpacing: 8,
                    children: availableBlood.map((blood) {
                      return Chip(
                        label: Text(
                          "${blood["group"]}: ${blood["units"]} units",
                          style: TextStyle(fontWeight: FontWeight.w600),
                        ),
                        backgroundColor: Colors.red.shade100,
                      );
                    }).toList(),
                  ),

                  SizedBox(height: 16),

                  // Get Directions Button
                  ElevatedButton.icon(
                    onPressed: () => _openGoogleMaps(position),
                    icon: Icon(Icons.directions),
                    label: Text("Get Directions"),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.red,
                      foregroundColor: Colors.white,
                    ),
                  ),
                ],
              ),
            ),

            // Close Button
            Positioned(
              top: -50,
              right: 16,
              child: GestureDetector(
                onTap: () => Navigator.pop(context),
                child: Container(
                  width: 40,
                  height: 40,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: Colors.white,
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black26,
                        blurRadius: 6,
                        spreadRadius: 1,
                      ),
                    ],
                  ),
                  child: Icon(Icons.close, size: 24, color: Colors.black54),
                ),
              ),
            ),
          ],
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
      appBar: AppBar(title: Text("Blood Banks Nearby")),
      body: GoogleMap(
        onMapCreated: (GoogleMapController controller) {
          _mapController = controller;
        },
        initialCameraPosition: CameraPosition(target: _currentPosition, zoom: 14),
        markers: _markers,
        myLocationEnabled: true,
        compassEnabled: true,
        zoomControlsEnabled: true,
      ),
    );
  }
}
