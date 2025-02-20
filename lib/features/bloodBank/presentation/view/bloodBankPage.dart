import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:geolocator/geolocator.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:vedika_healthcare/core/constants/colorpalette/ColorPalette.dart';
import 'package:vedika_healthcare/core/navigation/AppRoutes.dart';
import 'package:vedika_healthcare/shared/widgets/DrawerMenu.dart';

class BloodBankMapScreen extends StatefulWidget {
  @override
  _BloodBankMapState createState() => _BloodBankMapState();
}

class _BloodBankMapState extends State<BloodBankMapScreen> {
  late GoogleMapController _mapController;
  LatLng _currentPosition = LatLng(20.5937, 78.9629);
  final Set<Marker> _markers = {};
  Map<String, dynamic>? _selectedBloodBank;
  bool _isLoading = true;
  String googleApiKey = "YOUR_GOOGLE_PLACES_API_KEY"; // Replace with your API Key

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
    LocationPermission permission = await Geolocator.checkPermission();

    if (permission == LocationPermission.denied) {
      permission = await Geolocator.requestPermission();
      if (permission == LocationPermission.denied || permission == LocationPermission.deniedForever) {
        _showLocationDeniedDialog();
        return;
      }
    }

    if (!mounted) return; // Prevents state updates after async calls

    // Step 1: **Get last known location first**
    Position? lastKnownPosition;
    try {
      lastKnownPosition = await Geolocator.getLastKnownPosition();
    } catch (e) {
      print("Error getting last known location: $e");
    }

    if (lastKnownPosition != null) {
      setState(() {
        _currentPosition = LatLng(lastKnownPosition!.latitude, lastKnownPosition!.longitude);
      });

      _mapController.animateCamera(
        CameraUpdate.newLatLngZoom(_currentPosition, 15),
      );

      _addBloodBankMarkers();
    } else {
      print("No last known location found!");
    }


    // Step 2: **Try getting the current precise location**
    try {
      Position position = await Geolocator.getCurrentPosition(
        desiredAccuracy: LocationAccuracy.bestForNavigation,
        timeLimit: Duration(seconds: 10),
      );

      if (!mounted) return;

      // Validate new location
      double distance = lastKnownPosition != null
          ? Geolocator.distanceBetween(
          lastKnownPosition.latitude, lastKnownPosition.longitude,
          position.latitude, position.longitude)
          : 0;

      if (distance > 1000 && lastKnownPosition != null) {
        print("Ignoring incorrect far location, using last known.");
      } else {
        setState(() {
          _currentPosition = LatLng(position.latitude, position.longitude);
        });

        _mapController.animateCamera(
          CameraUpdate.newLatLngZoom(_currentPosition, 15),
        );

        _addBloodBankMarkers();
      }
    } catch (e) {
      print("Error getting current location: $e");
    }
  }




// Show dialog if location is denied
  void _showLocationDeniedDialog() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text("Location Access Denied"),
        content: Text("This app requires location access to show nearby blood banks. You can enable it from settings."),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text("Close"),
          ),
          TextButton(
            onPressed: () => Geolocator.openAppSettings(),
            child: Text("Open Settings"),
          ),
        ],
      ),
    );
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
                    icon: Icon(Icons.directions, color: Colors.white,),
                    label: Text("Get Directions"),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: ColorPalette.primaryColor,
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
      appBar: AppBar(title: Text("Blood Banks Nearby"),
      backgroundColor: ColorPalette.primaryColor,
        centerTitle: true,
        foregroundColor: Colors.white,
      ),
      drawer: DrawerMenu(), // Added Drawer
      body: _currentPosition == null
          ? Center(child: CircularProgressIndicator()) // Show loading indicator
          : Column(
        children: [
          // Google Map - Takes 80% of the screen height
          Expanded(
            flex: 4,
            child: GoogleMap(
              onMapCreated: (GoogleMapController controller) {
                _mapController = controller;
              },
              initialCameraPosition: CameraPosition(target: _currentPosition!, zoom: 14),
              markers: _markers,
              myLocationEnabled: true,
              compassEnabled: true,
              zoomControlsEnabled: true,
            ),
          ),

          // Bottom Card Section - Takes 20% of the screen height, spans full width
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
                  "Are you a blood donor?",
                  style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                ),
                SizedBox(height: 8),
                Text(
                  "Help save lives by registering as a donor today!",
                  textAlign: TextAlign.center,
                  style: TextStyle(fontSize: 14, color: Colors.black54),
                ),
                SizedBox(height: 12),
                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton(
                    onPressed: () {
                      Navigator.pushNamed(context, AppRoutes.donorRegistration);
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: ColorPalette.bloodBankColor,
                      foregroundColor: Colors.white,
                      padding: EdgeInsets.symmetric(vertical: 14),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(8),
                      ),
                    ),
                    child: Text("Register as a Donor", style: TextStyle(fontSize: 16)),
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
