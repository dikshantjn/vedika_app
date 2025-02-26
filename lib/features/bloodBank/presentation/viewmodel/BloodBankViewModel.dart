import 'dart:async';
import 'dart:math';
import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:provider/provider.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:vedika_healthcare/core/navigation/AppRoutes.dart';
import 'package:vedika_healthcare/features/bloodBank/data/models/BloodBank.dart';
import 'package:vedika_healthcare/features/bloodBank/data/repositories/blood_bank_data.dart';
import 'package:vedika_healthcare/features/bloodBank/presentation/widgets/BloodBankDetailsBottomSheet.dart';
import 'package:vedika_healthcare/features/bloodBank/presentation/widgets/BloodRequestConfirmationDialog.dart';
import 'package:vedika_healthcare/features/bloodBank/presentation/widgets/BloodTypeSelectionDialog.dart';
import 'package:vedika_healthcare/shared/services/LocationProvider.dart';

class BloodBankViewModel extends ChangeNotifier {
  final BuildContext context;
  late LatLng _currentPosition;
  bool _isLoadingLocation = true;
  bool _isBloodTypeSelected = false;
  bool _isBloodBankDataLoaded = false;
  List<BloodBank> _bloodBanks = [];
  List<String> _selectedBloodTypes = [];
  Set<Marker> _markers = {};

  // Added missing map controller
  late GoogleMapController _mapController;

  BloodBankViewModel(this.context);

  LatLng get currentPosition => _currentPosition;
  bool get isLoadingLocation => _isLoadingLocation;
  List<BloodBank> get bloodBanks => _bloodBanks;
  Set<Marker> get markers => _markers;

  // Getter and setter for map controller
  GoogleMapController get mapController => _mapController;

  void setMapController(GoogleMapController controller) {
    _mapController = controller;
    notifyListeners();
  }

  Future<void> ensureLocationEnabled() async {
    // Log that we're starting the location check
    debugPrint("Starting location check...");

    var locationProvider = Provider.of<LocationProvider>(context, listen: false);

    // Check if location service is enabled
    bool serviceEnabled = await locationProvider.isLocationServiceEnabled();
    debugPrint("Location service enabled: $serviceEnabled");

    // Request location permission
    bool permissionGranted = await locationProvider.requestLocationPermission();
    debugPrint("Location permission granted: $permissionGranted");

    if (!serviceEnabled || !permissionGranted) {
      // If location service is not enabled or permission is denied, navigate to the settings page
      debugPrint("Service not enabled or permission not granted, navigating to settings...");
      WidgetsBinding.instance.addPostFrameCallback((_) {
        Navigator.pushReplacementNamed(context, AppRoutes.enableBloodBankLocation);
      });
      return;
    }

    // Fetch and save the location
    debugPrint("Fetching and saving location...");
    locationProvider.fetchAndSaveLocation().then((_) {
      if (locationProvider.latitude != null && locationProvider.longitude != null) {
        debugPrint("Location fetched: (${locationProvider.latitude}, ${locationProvider.longitude})");

        _currentPosition = LatLng(locationProvider.latitude!, locationProvider.longitude!);
        _isLoadingLocation = false;

        // Log that we're fetching the blood banks now
        debugPrint("Fetching blood banks...");
        _fetchBloodBanks();

        // Show the blood type selection dialog
        WidgetsBinding.instance.addPostFrameCallback((_) {
          debugPrint("Showing blood type selection dialog...");
          _showBloodTypeSelectionDialog();
        });
      } else {
        debugPrint("Location is null. Could not fetch location.");
      }

      notifyListeners();
    }).catchError((error) {
      // Log any error during the location fetch process
      debugPrint("Error fetching location: $error");
    });
  }

  void _fetchBloodBanks() {
    List<BloodBank> allBanks = getBloodBanks(context);

    print("User Location: $_currentPosition");
    print("Total Blood Banks fetched: ${allBanks.length}");

    for (var bank in allBanks) {
      double distance = _calculateDistance(_currentPosition, bank.location);

      print("Bank: ${bank.name}");
      print("   Location: ${bank.location.latitude}, ${bank.location.longitude}");
      print("   Distance: $distance km");
    }

    _bloodBanks = allBanks.where((bank) {
      double distance = _calculateDistance(_currentPosition, bank.location);
      return distance <= 5.0;
    }).toList();

    print("Filtered Blood Banks within 5 km: ${_bloodBanks.length}");

    _isBloodBankDataLoaded = true;
    _addBloodBankMarkers();
    notifyListeners();
  }


  double _calculateDistance(LatLng start, LatLng end) {
    const double earthRadius = 6371;
    double dLat = (end.latitude - start.latitude) * pi / 180;
    double dLon = (end.longitude - start.longitude) * pi / 180;

    double a = sin(dLat / 2) * sin(dLat / 2) +
        cos(start.latitude * pi / 180) * cos(end.latitude * pi / 180) *
            sin(dLon / 2) * sin(dLon / 2);
    double c = 2 * atan2(sqrt(a), sqrt(1 - a));

    return earthRadius * c;
  }

  BloodBank? _getNearestBloodBank() {
    if (_bloodBanks.isEmpty) return null;

    BloodBank? nearestBank;
    double minDistance = double.infinity;

    for (var bank in _bloodBanks) {
      bool hasSelectedBlood = _selectedBloodTypes.any((selectedType) =>
          bank.availableBlood.any((blood) => blood.group == selectedType && blood.units > 0));

      if (hasSelectedBlood) {
        double distance = _calculateDistance(_currentPosition, bank.location);
        if (distance < minDistance) {
          minDistance = distance;
          nearestBank = bank;
        }
      }
    }

    return nearestBank;
  }


  void _addBloodBankMarkers() {
    _markers.clear();

    _markers.add(
      Marker(
        markerId: MarkerId("user_location"),
        position: _currentPosition,
        infoWindow: InfoWindow(title: "Your Location"),
        icon: BitmapDescriptor.defaultMarkerWithHue(BitmapDescriptor.hueBlue),
      ),
    );

    for (var bank in _bloodBanks) {
      bool hasSelectedBlood = _selectedBloodTypes.isEmpty ||
          _selectedBloodTypes.any((selectedType) =>
              bank.availableBlood.any((blood) => blood.group == selectedType && blood.units > 0));

      if (hasSelectedBlood) {
        _markers.add(
          Marker(
            markerId: MarkerId(bank.id),
            position: bank.location,
            infoWindow: InfoWindow(title: bank.name),
            icon: BitmapDescriptor.defaultMarkerWithHue(BitmapDescriptor.hueRed),
            onTap: () => _showBloodBankDetails(bank),
          ),
        );
      }
    }
    notifyListeners();
  }

  void _showBloodBankDetails(BloodBank bloodBank) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(16)),
      ),
      backgroundColor: Colors.grey.shade100,
      builder: (context) => BloodBankDetailsBottomSheet(
        bloodBank: bloodBank,
        onGetDirections: _openGoogleMaps,
      ),
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

  void _showBloodTypeSelectionDialog() {
    showDialog(
      context: context,
      builder: (BuildContext context) => BloodTypeSelectionDialog(
        selectedBloodTypes: _selectedBloodTypes,
        onBloodTypesSelected: (List<String> selectedTypes) {
          _selectedBloodTypes = selectedTypes;
          _isBloodTypeSelected = true;
          notifyListeners();
          _addBloodBankMarkers();
        },
        onRequestConfirm: _attemptToAcceptBloodRequest, // Call this after confirmation
      ),
    );
  }


  void _attemptToAcceptBloodRequest() async {
    debugPrint("Attempting to accept blood request...");

    if (!_isBloodTypeSelected || !_isBloodBankDataLoaded) {
      debugPrint("Blood type not selected or blood bank data not loaded.");
      return;
    }

    BloodBank? nearestBank = _getNearestBloodBank();
    if (nearestBank == null) {
      debugPrint("No nearest blood bank found.");
      return;
    }

    debugPrint("Nearest Blood Bank: ${nearestBank.name}");

    bool hasSelectedBlood = _selectedBloodTypes.any((selectedType) =>
        nearestBank.availableBlood.any((blood) => blood.group == selectedType && blood.units > 0));

    if (!hasSelectedBlood) {
      debugPrint("Nearest bank does not have the selected blood type.");
      return;
    }

    bool requestSent = await _sendRequestToVendor(nearestBank);
    debugPrint("Blood request sent: $requestSent");

    if (requestSent) {
      _listenForVendorResponse(nearestBank);
    }
  }

  Future<bool> _sendRequestToVendor(BloodBank bloodBank) async {
    await Future.delayed(Duration(seconds: 1));
    return true;
  }

  void _listenForVendorResponse(BloodBank bloodBank) {
    debugPrint("Listening for vendor response...");

    Timer.periodic(Duration(seconds: 2), (timer) async {
      bool isAccepted = await _checkVendorResponse(bloodBank);
      debugPrint("Vendor response received: $isAccepted");

      if (isAccepted) {
        timer.cancel();
        debugPrint("Vendor accepted the request. Showing confirmation dialog.");
        _showBloodRequestConfirmationDialog(bloodBank);
      }
    });
  }


  Future<bool> _checkVendorResponse(BloodBank bloodBank) async {
    await Future.delayed(Duration(seconds: 1));
    return Random().nextBool();
  }

  void _showBloodRequestConfirmationDialog(BloodBank bloodBank) {
    if (!context.mounted) {
      debugPrint("Context is no longer mounted. Cannot show dialog.");
      return;
    }

    debugPrint("Showing Blood Request Confirmation Dialog for ${bloodBank.name}");

    showDialog(
      context: context,
      builder: (context) => BloodRequestConfirmationDialog(bloodBank: bloodBank),
    );
  }
}
