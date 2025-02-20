import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:location/location.dart';
import 'package:provider/provider.dart';
import 'package:vedika_healthcare/core/constants/colorpalette/ColorPalette.dart';
import 'package:vedika_healthcare/features/ambulance/data/models/Ambulance.dart';
import 'package:vedika_healthcare/features/ambulance/data/repositories/ambulance_data.dart';
import 'package:vedika_healthcare/features/ambulance/data/services/AmbulanceRequestNotificationService.dart';
import 'package:vedika_healthcare/features/ambulance/data/services/AmbulanceService.dart';
import 'package:vedika_healthcare/features/ambulance/presentation/view/EnableLocationPage.dart';
import 'package:vedika_healthcare/features/ambulance/presentation/widgets/AmbulanceDetailsBottomSheet.dart';
import 'package:vedika_healthcare/features/ambulance/presentation/widgets/AmbulancePaymentDialog.dart';
import 'package:vedika_healthcare/shared/services/LocationProvider.dart';
import 'package:vedika_healthcare/shared/widgets/DrawerMenu.dart';
import 'dart:math';

class AmbulanceSearchPage extends StatefulWidget {
  @override
  _AmbulanceSearchPageState createState() => _AmbulanceSearchPageState();
}

class _AmbulanceSearchPageState extends State<AmbulanceSearchPage>
    with SingleTickerProviderStateMixin {
   GoogleMapController? _mapController;
  LatLng? _currentPosition;
  final Set<Marker> _markers = {};
  List<Ambulance> _ambulances = [];
  late AnimationController _animationController;
   bool _isLocationEnabled = false; // Flag to track location status


   double chargePerKM = 50;
  double baseFare = 200;
  double nearbyDistance = 5.0;

  @override
  void initState() {
    super.initState();
    _checkLocationEnabled();
    _animationController = AnimationController(duration: Duration(seconds: 1), vsync: this)
      ..repeat(reverse: true);
  }

  Future<void> _initializeMap() async {
    await _getUserLocation();
    _fetchAmbulances();
  }

   Future<void> _checkLocationEnabled() async {
     Location location = Location();

     bool serviceEnabled = await location.serviceEnabled();
     if (!serviceEnabled) {
       serviceEnabled = await location.requestService();
       if (!serviceEnabled) {
         // If user refuses to enable location, navigate to EnableLocationPage
         Navigator.pushReplacement(
           context,
           MaterialPageRoute(builder: (context) => EnableLocationPage()),
         );
         setState(() {
           _isLocationEnabled = false; // Location service is not enabled
         });
         return;
       }
     }

     // Get user location
     LocationData? userLocation = await location.getLocation();

     if (userLocation.latitude != null && userLocation.longitude != null) {
       // Proceed with map initialization and pass lat/lng
       setState(() {
         _isLocationEnabled = true; // Location service is enabled
       });
       _initializeMap();

     } else {
       setState(() {
         _isLocationEnabled = false;
       });
       _showLocationDialog();
       print("Failed to get location.");
     }
   }

   Future<void> _getUserLocation() async {
     print("Fetching user location...");
     var locationProvider = Provider.of<LocationProvider>(context, listen: false);

     // Load user location in parallel with ambulance fetching
     await Future.wait([
       locationProvider.loadSavedLocation(),
       Future.delayed(Duration(milliseconds: 100)), // Allow UI to remain responsive
     ]);

     if (locationProvider.latitude != null && locationProvider.longitude != null) {
       print("User location: ${locationProvider.latitude}, ${locationProvider.longitude}");
       _currentPosition = LatLng(locationProvider.latitude!, locationProvider.longitude!);

       // ✅ Fetch ambulances immediately after getting location
       _fetchAmbulances();

       if (_mapController != null) {
         _mapController!.animateCamera(
           CameraUpdate.newLatLngZoom(_currentPosition!, 15),
         );
       }

       // ✅ Markers are only updated after fetching ambulances
     } else {
       print("User location not available");
       _showLocationDialog();
     }
   }


   void _showLocationDialog() {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => AlertDialog(
        title: Text("Location Required"),
        content: Text("Please enable location to use this feature."),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text("OK"),
          ),
        ],
      ),
    );
  }

   Future<void> _fetchAmbulances() async {
     print("Executing _fetchAmbulances...");
     List<Ambulance> fetchedAmbulances = getAmbulances(context);
     List<Ambulance> nearbyAmbulances = [];

     if (_currentPosition == null) {
       print("User location not available.");
       return;
     }

     for (Ambulance ambulance in fetchedAmbulances) {
       double distance = _calculateDistance(
         _currentPosition!.latitude, _currentPosition!.longitude,
         ambulance.location.latitude, ambulance.location.longitude,
       );

       if (distance <= nearbyDistance) { // ✅ Only add ambulances within 3 km
         nearbyAmbulances.add(ambulance);
       }
     }

     if (nearbyAmbulances.isEmpty) {
       print("No ambulances found within 3 km.");
     } else {
       print("Ambulances within 3 km: ${nearbyAmbulances.length}");
     }

     setState(() {
       _ambulances = nearbyAmbulances; // ✅ Store only nearby ambulances
     });

     _addAmbulanceMarkers();
   }


   void _addAmbulanceMarkers() {
    print("Adding ambulance markers...");

    setState(() {
      _markers.clear();

      // Add user location marker
      if (_currentPosition != null) {
        _markers.add(
          Marker(
            markerId: MarkerId("user_location"),
            position: _currentPosition!,
            infoWindow: InfoWindow(title: "Your Location"),
            icon: BitmapDescriptor.defaultMarkerWithHue(BitmapDescriptor.hueBlue),
          ),
        );
      } else {
        print("User location not available");
      }

      // Add ambulance markers
      for (var ambulance in _ambulances) {
        print("Adding marker for ambulance: ${ambulance.name}");
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

    print("Total markers added: ${_markers.length}");
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

   Ambulance? _findNearestAmbulance() {
     if (_currentPosition == null) return null;

     Ambulance? nearestAmbulance;
     double minDistance = double.infinity;

     for (Ambulance ambulance in _ambulances) {
       double distance = _calculateDistance(
         _currentPosition!.latitude, _currentPosition!.longitude,
         ambulance.location.latitude, ambulance.location.longitude,
       );

       if (distance <= nearbyDistance && distance < minDistance) { // ✅ Filter within 3km
         minDistance = distance;
         nearestAmbulance = ambulance;
       }
     }

     return nearestAmbulance; // Return null if no ambulance is found within 3km
   }


   double _calculateDistance(
      double lat1, double lon1, double lat2, double lon2) {
    const R = 6371; // Radius of Earth in km
    double dLat = (lat2 - lat1) * pi / 180;
    double dLon = (lon2 - lon1) * pi / 180;
    double a = sin(dLat / 2) * sin(dLat / 2) +
        cos(lat1 * pi / 180) * cos(lat2 * pi / 180) *
            sin(dLon / 2) * sin(dLon / 2);
    double c = 2 * atan2(sqrt(a), sqrt(1 - a));
    return R * c; // Distance in km
  }

   void _callNearestAmbulance() async {
     if (_currentPosition == null) {
       _showLocationDialog();
       return;
     }

     // Show loading indicator
     showDialog(
       context: context,
       barrierDismissible: false,
       builder: (context) => const Center(child: CircularProgressIndicator()),
     );

     try {
       Ambulance? nearestAmbulance = _findNearestAmbulance();

       if (nearestAmbulance == null) {
         Navigator.pop(context); // Close loading
         ScaffoldMessenger.of(context).showSnackBar(
           const SnackBar(content: Text("No ambulance available nearby.")),
         );
         return;
       }

       print("Nearest Ambulance: ${nearestAmbulance.name}, Contact: ${nearestAmbulance.contact}");

       bool accepted = await AmbulanceService().triggerAmbulanceEmergency(nearestAmbulance.contact);

       Navigator.pop(context); // Close loading indicator

       if (accepted) {
         ScaffoldMessenger.of(context).showSnackBar(
           SnackBar(content: Text("Your ambulance request has been accepted by ${nearestAmbulance.name}!")),
         );

         double totalDistance = _calculateDistance(
           _currentPosition!.latitude, _currentPosition!.longitude,
           nearestAmbulance.location.latitude, nearestAmbulance.location.longitude,
         );

         double distanceCharge = totalDistance * chargePerKM;
         double totalAmount = baseFare + distanceCharge;

         // ✅ Show Notification
         await AmbulanceRequestNotificationService.showAmbulanceRequestNotification(
           ambulanceName: nearestAmbulance.name,
           contact: nearestAmbulance.contact,
           totalDistance: totalDistance,
           baseFare: baseFare,
           distanceCharge: distanceCharge,
           totalAmount: totalAmount,
         );

         // ✅ Show Ambulance Payment Dialog immediately after acceptance
         Future.delayed(const Duration(milliseconds: 500), () {
           showDialog(
             context: context,
             builder: (context) => AmbulancePaymentDialog(
               providerName: nearestAmbulance.name,
               baseFare: baseFare,
               distanceCharge: distanceCharge,
               totalAmount: totalAmount,
               totalDistance: totalDistance,
               onPaymentSuccess: () {
                 ScaffoldMessenger.of(context).showSnackBar(
                   const SnackBar(content: Text("Payment Successful! Booking Confirmed.")),
                 );
               },
             ),
           );
         });
       } else {
         ScaffoldMessenger.of(context).showSnackBar(
           const SnackBar(content: Text("No ambulance available nearby.")),
         );
       }
     } catch (e) {
       Navigator.pop(context); // Close loading on error
       print("Error calling ambulance: $e");
       ScaffoldMessenger.of(context).showSnackBar(
         const SnackBar(content: Text("Something went wrong. Please try again.")),
       );
     }
   }



   @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
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
                 print("Google Map created");
                 _mapController = controller;
                 _getUserLocation();
               },
               initialCameraPosition: CameraPosition(
                 target: LatLng(20.5937, 78.9629),
                 zoom: 14,
               ),
               markers: _markers,
               myLocationEnabled: _isLocationEnabled,
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

                 // Blinking effect on the "Call Ambulance" button
                 AnimatedBuilder(
                   animation: _animationController,
                   builder: (context, child) {
                     return Opacity(
                       opacity: _animationController.value, // Blinks based on value
                       child: child,
                     );
                   },
                   child: SizedBox(
                     width: double.infinity,
                     child: ElevatedButton(
                       onPressed: _callNearestAmbulance,
                       style: ElevatedButton.styleFrom(
                         backgroundColor: Colors.green, // Keeps the background color constant
                         foregroundColor: Colors.white, // Adjusts text and icon opacity
                         padding: EdgeInsets.symmetric(vertical: 14),
                         shape: RoundedRectangleBorder(
                           borderRadius: BorderRadius.circular(8),
                         ),
                       ),
                       child: Text("Call Ambulance", style: TextStyle(fontSize: 16)),
                     ),
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
