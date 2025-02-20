import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:provider/provider.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:vedika_healthcare/core/constants/colorpalette/ColorPalette.dart';
import 'package:vedika_healthcare/core/navigation/AppRoutes.dart';
import 'package:vedika_healthcare/features/bloodBank/data/models/BloodBank.dart';
import 'package:vedika_healthcare/features/bloodBank/data/repositories/blood_bank_data.dart';
import 'package:vedika_healthcare/features/bloodBank/presentation/widgets/BloodBankDetailsBottomSheet.dart';
import 'package:vedika_healthcare/features/bloodBank/presentation/widgets/BloodTypeSelectionDialog.dart';
import 'package:vedika_healthcare/shared/services/LocationProvider.dart';
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
  List<String> _selectedBloodTypes = []; // Define this in your widget's state
  List<BloodBank> _bloodBanks = []; // Store fetched blood banks




  @override
  void initState() {
    super.initState();
    _initializeMap();
  }

  Future<void> _initializeMap() async {
    if (mounted) _addBloodBankMarkers();  // Add blood banks only after location is set
    _fetchBloodBanks();

  }


  Future<void> _getUserLocation() async {
    var locationProvider = Provider.of<LocationProvider>(context, listen: false);

    // Ensure location is loaded from provider
    await locationProvider.loadSavedLocation();

    if (locationProvider.latitude != null && locationProvider.longitude != null) {
      setState(() {
        _currentPosition = LatLng(locationProvider.latitude!, locationProvider.longitude!);
      });

      // Ensure mapController is initialized before using it
      if (_mapController != null) {
        _mapController.animateCamera(
          CameraUpdate.newLatLngZoom(_currentPosition, 15),
        );
        _showBloodTypeSelectionDialog();
      } else {
        print("Map controller is not initialized yet.");
      }

      _addBloodBankMarkers();
    } else {
      print("User location not available in provider.");
    }
  }

  void _fetchBloodBanks() {
    setState(() {
      _bloodBanks = getBloodBanks(context); // Fetch dynamic blood banks
    });

    _addBloodBankMarkers();
  }


  void _addBloodBankMarkers() {
    setState(() {
      _markers.clear();

      // Add user's location marker
      _markers.add(
        Marker(
          markerId: const MarkerId("user_location"),
          position: _currentPosition,
          infoWindow: const InfoWindow(title: "Your Location"),
          icon: BitmapDescriptor.defaultMarkerWithHue(BitmapDescriptor.hueBlue),
        ),
      );

      for (var bank in _bloodBanks) {
        // Check if at least one selected blood type is available in the bank
        bool hasSelectedBlood = _selectedBloodTypes.isEmpty || _selectedBloodTypes.any(
              (selectedType) => bank.availableBlood.any(
                (blood) => blood.group == selectedType && blood.units > 0,
          ),
        );

        if (hasSelectedBlood) {
          // Get blood bank position directly from data instead of offset calculations
          LatLng bloodBankPosition = bank.location;

          _markers.add(
            Marker(
              markerId: MarkerId(bank.id),
              position: bloodBankPosition,
              infoWindow: InfoWindow(title: bank.name),
              icon: BitmapDescriptor.defaultMarkerWithHue(BitmapDescriptor.hueRed),
              onTap: () {
                _showBloodBankDetails(bank,);
              },
            ),
          );
        }
      }
    });
  }



  void _showBloodBankDetails(BloodBank bloodBank) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(16)),
      ),
      backgroundColor: Colors.grey.shade100,
      builder: (context) {
        return BloodBankDetailsBottomSheet(
          bloodBank: bloodBank,
          onGetDirections: _openGoogleMaps, // Pass the function directly
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
                _mapController = controller; // Initialize map controller
                _getUserLocation(); // Call after map is ready
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

  void _showBloodTypeSelectionDialog() {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return BloodTypeSelectionDialog(
          selectedBloodTypes: _selectedBloodTypes, // Pass previously selected types
          onBloodTypesSelected: (List<String> selectedTypes) {
            setState(() {
              _selectedBloodTypes = selectedTypes; // Update selected types
            });
            _addBloodBankMarkers();
          },
        );
      },
    );
  }
}
