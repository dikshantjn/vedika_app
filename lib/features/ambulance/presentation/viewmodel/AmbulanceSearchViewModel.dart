import 'dart:math';
import 'package:awesome_dialog/awesome_dialog.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:location/location.dart';
import 'package:logger/web.dart';
import 'package:provider/provider.dart';
import 'package:vedika_healthcare/core/auth/data/services/StorageService.dart';
import 'package:vedika_healthcare/features/Vendor/AmbulanceAgencyVendor/data/modals/AmbulanceAgency.dart';
import 'package:vedika_healthcare/features/ambulance/data/services/AmbulanceService.dart';
import 'package:vedika_healthcare/features/ambulance/data/services/EmergiencyAmbulanceService.dart';
import 'package:vedika_healthcare/features/ambulance/presentation/widgets/AmbulanceDetailsBottomSheet.dart';
import 'package:vedika_healthcare/features/ambulance/presentation/widgets/AmbulancePaymentDialog.dart';
import 'package:vedika_healthcare/shared/services/LocationProvider.dart';

class AmbulanceSearchViewModel extends ChangeNotifier {
  GoogleMapController? mapController;
  LatLng? currentPosition;
  final Set<Marker> markers = {};
  List<AmbulanceAgency> ambulances = [];
  bool isLocationEnabled = false;
  bool mounted = true; // Manually track mounting state
  bool _isDialogShowing = false;
  EmergiencyAmbulanceService _service = EmergiencyAmbulanceService();

  final logger = Logger();

  var isLoading = false.obs;
  var availableAgencies = <AmbulanceAgency>[].obs;
  var errorMessage = ''.obs;

  double chargePerKM = 50;
  double baseFare = 200;
  double nearbyDistance = 15.0;

  final BuildContext context;

  AmbulanceSearchViewModel(this.context) {
    _checkLocationEnabled();
  }

  Future<void> _checkLocationEnabled() async {
    Location location = Location();
    bool serviceEnabled = await location.serviceEnabled();

    if (!serviceEnabled) {
      serviceEnabled = await location.requestService();
      if (!serviceEnabled) {
        isLocationEnabled = false;
        if (mounted) notifyListeners();

        // Delay showing dialog slightly to avoid race condition with system prompt
        Future.delayed(Duration(milliseconds: 300), () {
          if (!_isDialogShowing) _showLocationDialog();
        });

        return;
      }
    }

    LocationData? userLocation = await location.getLocation();
    if (userLocation.latitude != null && userLocation.longitude != null) {
      isLocationEnabled = true;
      if (mounted) notifyListeners();
      initialize();
    } else {
      isLocationEnabled = false;
      if (mounted) notifyListeners();
      if (!_isDialogShowing) _showLocationDialog();
    }
  }



  Future<void> initialize() async {
    await getUserLocation();
    fetchAvailableAgencies();
  }

  Future<void> getUserLocation() async {
    var locationProvider = Provider.of<LocationProvider>(context, listen: false);
    await locationProvider.loadSavedLocation();

    if (locationProvider.latitude != null && locationProvider.longitude != null) {
      currentPosition = LatLng(locationProvider.latitude!, locationProvider.longitude!);

      // Ensure the user marker updates
      _addUserMarker();

      // Move the camera to the user's location
      if (mapController != null) {
        mapController!.animateCamera(CameraUpdate.newLatLngZoom(currentPosition!, 15));
      }

      // Fetch nearby ambulances
      fetchAvailableAgencies();
    } else {
      _showLocationDialog();
    }
  }

  void _addUserMarker() {
    if (currentPosition == null) return;

    markers.removeWhere((marker) => marker.markerId.value == "user_location");

    markers.add(
      Marker(
        markerId: const MarkerId("user_location"),
        position: currentPosition!,
        infoWindow: const InfoWindow(title: "Your Location"),
        icon: BitmapDescriptor.defaultMarkerWithHue(BitmapDescriptor.hueBlue),
      ),
    );

    notifyListeners();
  }




  void _showLocationDialog() {
    if (_isDialogShowing) return;

    _isDialogShowing = true;
    AwesomeDialog(
      context: context,
      dialogType: DialogType.warning,
      animType: AnimType.bottomSlide,
      title: 'Location Required',
      desc: 'Please enable location to use this feature.',
      btnOkText: "Enable Location",
      btnOkOnPress: () {
        _isDialogShowing = false;
        _checkLocationEnabled();
      },
      btnCancelText: "Go Back",
      btnCancelOnPress: () {
        _isDialogShowing = false;
        Navigator.pop(context);
      },
      customHeader: Align(
        alignment: Alignment.topCenter,
        child: Container(
          margin: const EdgeInsets.only(top: 16),
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            color: Colors.orange.shade100,
          ),
          padding: const EdgeInsets.all(16),
          child: const Icon(
            Icons.wrong_location_outlined,
            size: 40,
            color: Colors.redAccent,
          ),
        ),
      ),
    ).show();
  }


  void _addAmbulanceMarkers() {
    markers.clear();

    if (currentPosition != null) {
      markers.add(
        Marker(
          markerId: const MarkerId("user_location"),
          position: currentPosition!,
          infoWindow: const InfoWindow(title: "Your Location"),
          icon: BitmapDescriptor.defaultMarkerWithHue(BitmapDescriptor.hueBlue),
        ),
      );
    }

    for (var ambulance in ambulances) {
      if (ambulance.preciseLocation.isEmpty || !ambulance.preciseLocation.contains(',')) {
        continue; // Skip if invalid
      }

      List<String> latLngParts = ambulance.preciseLocation.split(',');
      double lat = double.tryParse(latLngParts[0].trim()) ?? 0.0;
      double lng = double.tryParse(latLngParts[1].trim()) ?? 0.0;

      markers.add(
        Marker(
          markerId: MarkerId(ambulance.vendorId),
          position: LatLng(lat, lng),
          infoWindow: InfoWindow(title: ambulance.agencyName),
          icon: BitmapDescriptor.defaultMarkerWithHue(BitmapDescriptor.hueRose),
          onTap: () => _showAmbulanceDetails(ambulance),
        ),
      );
    }

    notifyListeners();
  }

  void _showAmbulanceDetails(AmbulanceAgency ambulance) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(16)),
      ),
      backgroundColor: Colors.grey.shade100,
      builder: (context) => AmbulanceDetailsBottomSheet(ambulance: ambulance),
    );
  }

  AmbulanceAgency? _findNearestAmbulance() {
    if (currentPosition == null) return null;

    AmbulanceAgency? nearestAmbulance;
    double minDistance = double.infinity;

    for (AmbulanceAgency ambulance in ambulances) {
      if (ambulance.preciseLocation.isEmpty || !ambulance.preciseLocation.contains(',')) {
        continue; // Skip if invalid
      }

      List<String> latLngParts = ambulance.preciseLocation.split(',');
      double ambulanceLat = double.tryParse(latLngParts[0].trim()) ?? 0.0;
      double ambulanceLng = double.tryParse(latLngParts[1].trim()) ?? 0.0;

      double distance = _calculateDistance(
        currentPosition!.latitude,
        currentPosition!.longitude,
        ambulanceLat,
        ambulanceLng,
      );

      if (distance <= nearbyDistance && distance < minDistance) {
        minDistance = distance;
        nearestAmbulance = ambulance;
      }
    }

    if (nearestAmbulance != null) {
      _createBookingWithNearestAmbulance(nearestAmbulance);
    }

    return nearestAmbulance;
  }

  Future<void> _createBookingWithNearestAmbulance(AmbulanceAgency ambulance) async {
    try {
      String? userId = await StorageService.getUserId();

      final vendorId = ambulance.vendorId ?? '';

      if (vendorId.isEmpty) {
        print('⚠️ Vendor ID missing in selected ambulance');
        return;
      }

      final booking = await _service.createBooking(
        userId: userId!,
        vendorId: vendorId,
      );

      if (booking != null) {
        print("✅ Booking confirmed: ${booking.requestId}");
        // Optionally update state/UI or navigate to tracker
      } else {
        print("❌ Booking failed");
      }
    } catch (e) {
      print("🔥 Error creating booking: $e");
    }
  }


  double _calculateDistance(double lat1, double lon1, double lat2, double lon2) {
    const R = 6371;
    double dLat = (lat2 - lat1) * pi / 180;
    double dLon = (lon2 - lon1) * pi / 180;
    double a = sin(dLat / 2) * sin(dLat / 2) +
        cos(lat1 * pi / 180) * cos(lat2 * pi / 180) * sin(dLon / 2) * sin(dLon / 2);
    double c = 2 * atan2(sqrt(a), sqrt(1 - a));
    return R * c;
  }

  void callNearestAmbulance() async {
    if (currentPosition == null) {
      _showLocationDialog();
      return;
    }

    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => const Center(child: CircularProgressIndicator()),
    );

    try {
      AmbulanceAgency? nearestAmbulance = _findNearestAmbulance();
      Navigator.pop(context);

      if (nearestAmbulance == null) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text("No ambulance available nearby.")),
        );
        return;
      }

      bool accepted = await AmbulanceService().triggerAmbulanceEmergency(nearestAmbulance.contactNumber);
      if (accepted) {
        List<String> latLngParts = nearestAmbulance.preciseLocation.split(',');
        double ambulanceLat = double.parse(latLngParts[0]);
        double ambulanceLng = double.parse(latLngParts[1]);

        double totalDistance = _calculateDistance(
          currentPosition!.latitude,
          currentPosition!.longitude,
          ambulanceLat,
          ambulanceLng,
        );

        // Show confirmation message directly (without payment dialog)
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text("Payment Successful! Booking Confirmed.")),
        );
      }
    } catch (e) {
      Navigator.pop(context);
      print("Error: $e");
    }
  }



  Future<void> fetchAvailableAgencies() async {
    try {
      isLoading.value = true;
      errorMessage.value = '';

      final result = await _service.fetchAmbulances();

      availableAgencies.value = result;
      ambulances = result; // 🔥 Add this line to update the list used for markers

      logger.i('Fetched ${result.length} ambulance agencies');
      for (var agency in result) {
        logger.d({
          'Agency Name': agency.agencyName,
          'Vendor ID': agency.vendorId,
          'Location': agency.preciseLocation,
          'Contact': agency.contactNumber,
        });
      }

      _addAmbulanceMarkers(); // This now has data to work with
    } catch (e, stackTrace) {
      errorMessage.value = 'Failed to fetch agencies';
      logger.e("Error fetching available ambulances", error: e, stackTrace: stackTrace);
    } finally {
      isLoading.value = false;
    }
  }

  // You can also expose a refresh method
  void refreshAgencies() {
    fetchAvailableAgencies();
  }
}
