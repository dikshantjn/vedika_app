import 'dart:async';
import 'dart:math';
import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:vedika_healthcare/core/auth/data/repositories/AuthRepository.dart';
import 'package:vedika_healthcare/core/auth/data/services/StorageService.dart';
import 'package:vedika_healthcare/features/Vendor/BloodBankAgencyVendor/data/model/BloodBankBooking.dart';
import 'package:vedika_healthcare/features/bloodBank/data/services/BloodBankAgencyService.dart';
import 'package:vedika_healthcare/features/bloodBank/presentation/widgets/BloodBankDetailsBottomSheet.dart';
import 'package:vedika_healthcare/features/bloodBank/presentation/widgets/BloodRequestDetailsBottomSheet.dart';
import 'package:vedika_healthcare/features/bloodBank/presentation/widgets/BloodTypeSelectionDialog.dart';
import 'package:vedika_healthcare/features/Vendor/BloodBankAgencyVendor/data/model/BloodBankAgency.dart';
import 'package:awesome_dialog/awesome_dialog.dart';
import 'package:location/location.dart';
import 'package:logger/logger.dart';

class BloodBankViewModel extends ChangeNotifier {
  final BuildContext context;
  final Logger _logger = Logger();
  LatLng? _currentPosition;
  bool _isLoadingLocation = true;
  bool _isBloodTypeSelected = false;
  List<BloodBankAgency> _bloodBankAgencies = [];
  List<String> _selectedBloodTypes = [];
  Set<Marker> _markers = {};
  bool _isLoadingAgencies = false;
  String? _errorMessage;
  String _selectedCity = 'All Cities';
  GoogleMapController? _mapController;
  bool _isSidePanelOpen = false;
  bool _isMapReady = false;
  bool _isInitialized = false;

  // City coordinates mapping
  final Map<String, LatLng> _cityCoordinates = {
    'Mumbai': LatLng(19.0760, 72.8777),
    'Delhi': LatLng(28.7041, 77.1025),
    'Bangalore': LatLng(12.9716, 77.5946),
    'Hyderabad': LatLng(17.3850, 78.4867),
    'Chennai': LatLng(13.0827, 80.2707),
    'Kolkata': LatLng(22.5726, 88.3639),
    'Pune': LatLng(18.5204, 73.8567),
    'Ahmedabad': LatLng(23.0225, 72.5714),
    'Jaipur': LatLng(26.9124, 75.7873),
    'Lucknow': LatLng(26.8467, 80.9462),
  };

  final List<String> _cities = [
    'All Cities',
    'Mumbai',
    'Delhi',
    'Bangalore',
    'Hyderabad',
    'Chennai',
    'Kolkata',
    'Pune',
    'Ahmedabad',
    'Jaipur',
    'Lucknow'
  ];

  List<BloodBankBooking> _bookings = [];
  bool _isLoadingBookings = false;
  String? _bookingError;

  // Service for fetching blood bank agencies
  final BloodBankAgencyService _agencyService = BloodBankAgencyService();
  final AuthRepository _authRepository = AuthRepository();

  BloodBankViewModel(this.context) {
    debugPrint("BloodBankViewModel constructor called");
    _initialize();
  }

  Future<void> _initialize() async {
    _logger.i("Starting initialization of BloodBankViewModel");
    try {
      // First check for existing bookings
      _logger.d("Checking for existing bookings");
      await fetchBookingsForVendor();
      
      // Then enable location
      _logger.d("Enabling location services");
      await ensureLocationEnabled();
      
      // Show appropriate UI based on bookings
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (!context.mounted) {
          _logger.e("Context is not mounted, cannot show UI");
          return;
        }
        
        if (_bookings.isNotEmpty) {
          _logger.i("Found ${_bookings.length} active bookings, showing details bottom sheet");
          _showBookingDetailsBottomSheet(_bookings.first);
        } else {
          _logger.i("No active bookings found, showing blood type selection dialog");
          _showBloodTypeSelectionDialog();
        }
      });
      
      _isInitialized = true;
      _logger.i("Initialization completed successfully");
    } catch (e) {
      _logger.e("Error during initialization", error: e);
      _errorMessage = "Failed to initialize: ${e.toString()}";
      notifyListeners();
    }
  }

  // Public method to manually trigger the dialog
  void showBloodTypeDialog() {
    debugPrint("showBloodTypeDialog called");
    _showBloodTypeSelectionDialog();
  }

  // Getters
  bool get isSidePanelOpen => _isSidePanelOpen;
  String get selectedCity => _selectedCity;
  List<String> get cities => _cities;
  LatLng? get currentPosition => _currentPosition;
  bool get isLoadingLocation => _isLoadingLocation;
  List<BloodBankAgency> get bloodBankAgencies => _bloodBankAgencies;
  Set<Marker> get markers => _markers;
  bool get isLoadingAgencies => _isLoadingAgencies;
  String? get errorMessage => _errorMessage;
  GoogleMapController? get mapController => _mapController;
  bool get isMapReady => _isMapReady;

  // Toggle side panel
  void toggleSidePanel() {
    _isSidePanelOpen = !_isSidePanelOpen;
    notifyListeners();
  }

  // Set selected city and update map
  void setSelectedCity(String city) {
    _selectedCity = city;
    notifyListeners();
    _updateMapForSelectedCity();
  }

  // Optimized map controller setter
  void setMapController(GoogleMapController controller) {
    if (_mapController != null) {
      _mapController!.dispose();
    }
    _mapController = controller;
    _isMapReady = true;
    notifyListeners();
  }

  // Optimized location check
  Future<void> ensureLocationEnabled() async {
    if (_currentPosition != null) {
      _isLoadingLocation = false;
      notifyListeners();
      return;
    }

    try {
      Location location = Location();
      bool serviceEnabled = await location.serviceEnabled();

      if (!serviceEnabled) {
        serviceEnabled = await location.requestService();
        if (!serviceEnabled) {
          _handleLocationError();
          return;
        }
      }

      PermissionStatus permissionStatus = await location.hasPermission();
      if (permissionStatus == PermissionStatus.denied) {
        permissionStatus = await location.requestPermission();
        if (permissionStatus != PermissionStatus.granted) {
          _handleLocationError();
          return;
        }
      }

      LocationData userLocation = await location.getLocation();
      if (userLocation.latitude != null && userLocation.longitude != null) {
        _isLoadingLocation = false;
        _currentPosition = LatLng(userLocation.latitude!, userLocation.longitude!);
        notifyListeners();

        // Fetch agencies after getting location
        _fetchBloodBankAgencies();
      } else {
        _handleLocationError();
      }
    } catch (e) {
      debugPrint("Error getting location: $e");
      _handleLocationError();
    }
  }

  // Optimized map update for selected city
  Future<void> _updateMapForSelectedCity() async {
    if (_mapController == null || !_isMapReady) return;

    _markers.clear();
    
    if (_selectedCity == 'All Cities') {
      _addBloodBankAgencyMarkers();
      return;
    }

    final cityLocation = _cityCoordinates[_selectedCity];
    if (cityLocation == null) return;

    try {
      _markers.add(
        Marker(
          markerId: MarkerId("city_center"),
          position: cityLocation,
          infoWindow: InfoWindow(title: _selectedCity),
          icon: BitmapDescriptor.defaultMarkerWithHue(BitmapDescriptor.hueGreen),
        ),
      );

      final cityAgencies = _bloodBankAgencies.where((agency) => 
        agency.city.toLowerCase() == _selectedCity.toLowerCase()
      ).toList();
      
      for (var agency in cityAgencies) {
        final locationParts = agency.googleMapsLocation.split(',');
        if (locationParts.length == 2) {
          try {
            final latitude = double.parse(locationParts[0].trim());
            final longitude = double.parse(locationParts[1].trim());
            
            final location = LatLng(latitude, longitude);
            
            _markers.add(
              Marker(
                markerId: MarkerId(agency.generatedId ?? agency.vendorId ?? 'agency_${agency.agencyName}'),
                position: location,
                infoWindow: InfoWindow(
                  title: agency.agencyName,
                  snippet: '${agency.completeAddress}, ${agency.city}',
                ),
                icon: BitmapDescriptor.defaultMarkerWithHue(BitmapDescriptor.hueRed),
                onTap: () => _showBloodBankAgencyDetails(agency),
              ),
            );
          } catch (e) {
            debugPrint("Error parsing location for agency ${agency.agencyName}: $e");
          }
        }
      }

      await _mapController!.animateCamera(
        CameraUpdate.newCameraPosition(
          CameraPosition(
            target: cityLocation,
            zoom: 12,
          ),
        ),
      );
    } catch (e) {
      debugPrint("Error updating map for selected city: $e");
    }

    notifyListeners();
  }

  // Optimized blood bank agency markers
  void _addBloodBankAgencyMarkers() {
    _markers.clear();
    
    if (_currentPosition != null) {
      _markers.add(
        Marker(
          markerId: MarkerId("user_location"),
          position: _currentPosition!,
          infoWindow: InfoWindow(title: "Your Location"),
          icon: BitmapDescriptor.defaultMarkerWithHue(BitmapDescriptor.hueBlue),
        ),
      );
    }
    
    for (var agency in _bloodBankAgencies) {
      final locationParts = agency.googleMapsLocation.split(',');
      if (locationParts.length == 2) {
        try {
          final latitude = double.parse(locationParts[0].trim());
          final longitude = double.parse(locationParts[1].trim());
          
          final location = LatLng(latitude, longitude);
          
          bool shouldAddMarker = true;
          if (_currentPosition != null) {
            final distance = _calculateDistance(_currentPosition!, location);
            shouldAddMarker = distance <= 5.0;
          }
          
          if (shouldAddMarker) {
            _markers.add(
              Marker(
                markerId: MarkerId(agency.generatedId ?? agency.vendorId ?? 'agency_${agency.agencyName}'),
                position: location,
                infoWindow: InfoWindow(
                  title: agency.agencyName,
                  snippet: '${agency.completeAddress}, ${agency.city}',
                ),
                icon: BitmapDescriptor.defaultMarkerWithHue(BitmapDescriptor.hueRed),
                onTap: () => _showBloodBankAgencyDetails(agency),
              ),
            );
          }
        } catch (e) {
          debugPrint("Error parsing location for agency ${agency.agencyName}: $e");
        }
      }
    }
    notifyListeners();
  }

  @override
  void dispose() {
    if (_mapController != null) {
      _mapController!.dispose();
      _mapController = null;
    }
    super.dispose();
  }

  Future<void> _handleLocationError() async {
    _isLoadingLocation = false;
    // Set default location to Pune
    _currentPosition = _cityCoordinates['Pune'];
    notifyListeners();
    
    // Fetch agencies for Pune
    await _fetchBloodBankAgencies();
    
    if (!_isDialogShowing) _showLocationDialog();
  }

  bool _isDialogShowing = false;

  void _showLocationDialog() {
    if (_isDialogShowing) return;

    _isDialogShowing = true;
    AwesomeDialog(
      context: context,
      dialogType: DialogType.warning,
      animType: AnimType.bottomSlide,
      title: 'Location Required',
      desc: 'Please enable location to find blood banks near you.',
      btnOkText: "Enable Location",
      btnOkOnPress: () {
        _isDialogShowing = false;
        ensureLocationEnabled();
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

  // Fetch blood bank agencies from API
  Future<void> _fetchBloodBankAgencies() async {
    try {
      _isLoadingAgencies = true;
      _errorMessage = null;
      notifyListeners();
      
      _bloodBankAgencies = await _agencyService.getActiveBloodBankAgencies();
      debugPrint("Fetched ${_bloodBankAgencies.length} blood bank agencies");
      
      _addBloodBankAgencyMarkers();
      
      _isLoadingAgencies = false;
      notifyListeners();
    } catch (e) {
      debugPrint("Error fetching blood bank agencies: $e");
      _errorMessage = "Error fetching blood bank agencies: $e";
      _isLoadingAgencies = false;
      notifyListeners();
    }
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

  BloodBankAgency? _getNearestBloodBankAgency() {
    if (_bloodBankAgencies.isEmpty) return null;

    BloodBankAgency? nearestAgency;
    double minDistance = double.infinity;

    for (var agency in _bloodBankAgencies) {
      // Parse location from agency's Google Maps location string
      final locationParts = agency.googleMapsLocation.split(',');
      if (locationParts.length == 2) {
        try {
          final latitude = double.parse(locationParts[0].trim());
          final longitude = double.parse(locationParts[1].trim());
          
          final location = LatLng(latitude, longitude);
          
          // Calculate distance from user
          final distance = _calculateDistance(_currentPosition!, location);
          
          if (distance < minDistance) {
            minDistance = distance;
            nearestAgency = agency;
          }
        } catch (e) {
          debugPrint("Error parsing location for agency ${agency.agencyName}: $e");
        }
      }
    }

    return nearestAgency;
  }

  void _showBloodBankAgencyDetails(BloodBankAgency agency) {
    // Parse the Google Maps location string to get latitude and longitude
    final locationParts = agency.googleMapsLocation.split(',');
    if (locationParts.length == 2) {
      try {
        final latitude = double.parse(locationParts[0].trim());
        final longitude = double.parse(locationParts[1].trim());
        
        final location = LatLng(latitude, longitude);
        
        showModalBottomSheet(
          context: context,
          isScrollControlled: true,
          backgroundColor: Colors.transparent,
          enableDrag: false,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
          ),
          builder: (context) => Stack(
            clipBehavior: Clip.none,
            children: [
              IntrinsicHeight(
                child: BloodBankDetailsBottomSheet(
                  agency: agency,
                  location: location,
                  onGetDirections: _openGoogleMaps,
                ),
              ),
              // Close button outside the bottom sheet
              Positioned(
                right: 16,
                top: -50,
                child: GestureDetector(
                  onTap: () => Navigator.pop(context),
                  child: Container(
                    width: 40,
                    height: 40,
                    decoration: BoxDecoration(
                      color: Colors.white,
                      shape: BoxShape.circle,
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withOpacity(0.2),
                          blurRadius: 6,
                          spreadRadius: 1,
                        ),
                      ],
                    ),
                    child: Icon(Icons.close, size: 24, color: Colors.black87),
                  ),
                ),
              ),
            ],
          ),
        );
      } catch (e) {
        debugPrint("Error parsing location for agency ${agency.agencyName}: $e");
      }
    }
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
    debugPrint("_showBloodTypeSelectionDialog started");
    if (!context.mounted) {
      debugPrint("Context is not mounted in _showBloodTypeSelectionDialog");
      return;
    }

    debugPrint("Showing blood type selection bottom sheet...");
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      enableDrag: true,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (BuildContext context) {
        debugPrint("Building BloodTypeSelectionDialog with selected types: $_selectedBloodTypes");
        return Stack(
          clipBehavior: Clip.none,
          children: [
            IntrinsicHeight(
              child: BloodTypeSelectionDialog(
                selectedBloodTypes: _selectedBloodTypes,
                onBloodTypesSelected: (List<String> selectedTypes) {
                  debugPrint("Blood types selected: $selectedTypes");
                  _selectedBloodTypes = selectedTypes;
                  _isBloodTypeSelected = true;
                  notifyListeners();
                  _addBloodBankAgencyMarkers();
                },
                onRequestConfirm: () {
                  debugPrint("Request confirmed, attempting to accept blood request");
                  _attemptToAcceptBloodRequest();
                },
              ),
            ),
            // Close button outside the bottom sheet
            Positioned(
              right: 16,
              top: -50,
              child: GestureDetector(
                onTap: () => Navigator.pop(context),
                child: Container(
                  width: 40,
                  height: 40,
                  decoration: BoxDecoration(
                    color: Colors.white,
                    shape: BoxShape.circle,
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withOpacity(0.2),
                        blurRadius: 6,
                        spreadRadius: 1,
                      ),
                    ],
                  ),
                  child: Icon(Icons.close, size: 24, color: Colors.black87),
                ),
              ),
            ),
          ],
        );
      },
    ).then((_) {
      debugPrint("Bottom sheet closed");
    });
  }

  void _attemptToAcceptBloodRequest() async {
    debugPrint("Attempting to accept blood request...");

    if (!_isBloodTypeSelected) {
      debugPrint("Blood type not selected, showing error");
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text("Please select blood type(s) first"),
          backgroundColor: Colors.red,
        ),
      );
      return;
    }

    BloodBankAgency? nearestAgency = _getNearestBloodBankAgency();
    if (nearestAgency == null) {
      debugPrint("No nearest blood bank agency found, showing error");
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text("No blood bank found nearby"),
          backgroundColor: Colors.red,
        ),
      );
      return;
    }

    debugPrint("Nearest Blood Bank Agency: ${nearestAgency.agencyName}");

    try {
      bool requestSent = await _sendRequestToVendor(nearestAgency);
      debugPrint("Blood request sent: $requestSent");

      if (requestSent) {
        // Close the bottom sheet first
        Navigator.pop(context);
        
        // Show success dialog
        AwesomeDialog(
          context: context,
          dialogType: DialogType.success,
          animType: AnimType.bottomSlide,
          title: 'Request Sent Successfully',
          desc: 'Your blood request has been sent. We will notify you once they respond.',
          btnOkText: "OK",
          btnOkOnPress: () {
            // _listenForVendorResponse(nearestAgency);
          },
          customHeader: Align(
            alignment: Alignment.topCenter,
            child: Container(
              margin: const EdgeInsets.only(top: 16),
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: Colors.green.shade100,
              ),
              padding: const EdgeInsets.all(16),
              child: const Icon(
                Icons.check_circle_outline,
                size: 40,
                color: Colors.green,
              ),
            ),
          ),
        ).show();
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text("Failed to send request to blood bank"),
            backgroundColor: Colors.red,
          ),
        );
      }
    } catch (e) {
      debugPrint("Error sending request: $e");
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text("Error: ${e.toString()}"),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

  Future<bool> _sendRequestToVendor(BloodBankAgency agency) async {
    debugPrint("Sending request to vendor: ${agency.agencyName}");
    try {
      // TODO: Implement actual API call to send request
      await Future.delayed(Duration(seconds: 1));
      return true;
    } catch (e) {
      debugPrint("Error in _sendRequestToVendor: $e");
      return false;
    }
  }

  void _listenForVendorResponse(BloodBankAgency agency) {
    debugPrint("Listening for vendor response from: ${agency.agencyName}");

    _checkVendorResponse(agency).then((isAccepted) {
      debugPrint("Vendor response received: $isAccepted");

      if (isAccepted) {
        debugPrint("Vendor accepted the request");
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text("Request accepted by ${agency.agencyName}"),
            backgroundColor: Colors.green,
          ),
        );
      } else {
        debugPrint("Vendor rejected the request");
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text("Request rejected by ${agency.agencyName}"),
            backgroundColor: Colors.red,
          ),
        );
      }
    }).catchError((error) {
      debugPrint("Error checking vendor response: $error");
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text("Error: ${error.toString()}"),
          backgroundColor: Colors.red,
        ),
      );
    });
  }

  Future<bool> _checkVendorResponse(BloodBankAgency agency) async {
    debugPrint("Checking vendor response from: ${agency.agencyName}");
    try {
      // TODO: Implement actual API call to check response
      await Future.delayed(Duration(seconds: 1));
      return Random().nextBool();
    } catch (e) {
      debugPrint("Error in _checkVendorResponse: $e");
      return false;
    }
  }

  Future<void> fetchBookingsForVendor() async {
    _logger.d("Fetching bookings for vendor");
    String? token = await _authRepository.getToken();
    String? userId = await StorageService.getUserId();

    _isLoadingBookings = true;
    _bookingError = null;
    notifyListeners();

    try {
      _bookings = await _agencyService.getBookings(userId!, token!);
      _logger.i("Successfully fetched ${_bookings.length} bookings");
      
      // Filter out completed bookings
      final activeBookings = _bookings.where((booking) => 
        booking.status.toLowerCase() != 'completed'
      ).toList();
      
      _logger.d("Found ${activeBookings.length} active bookings");
      
      // Don't show bottom sheet here, it will be shown in _initialize if needed
    } catch (e) {
      _logger.e("Error fetching bookings", error: e);
      _bookingError = e.toString();
    } finally {
      _isLoadingBookings = false;
      notifyListeners();
    }
  }

  void _showBookingDetailsBottomSheet(BloodBankBooking booking) {
    _logger.d("Showing booking details bottom sheet for booking ID: ${booking.bookingId}");
    if (!context.mounted) {
      _logger.e("Context is not mounted, cannot show bottom sheet");
      return;
    }

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      enableDrag: false,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (context) => Stack(
        clipBehavior: Clip.none,
        children: [
          IntrinsicHeight(
            child: BloodRequestDetailsBottomSheet(
              booking: booking,
              onCallBloodBank: () {
                final phoneNumber = booking.agency?.phoneNumber;
                if (phoneNumber != null && phoneNumber.isNotEmpty) {
                  launchUrl(Uri.parse('tel:$phoneNumber'));
                } else {
                  _logger.w("Phone number not available for booking ${booking.bookingId}");
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(content: Text("Phone number is not available")),
                  );
                }
              },
              onRefresh: () async {
                _logger.d("Refreshing bookings");
                await fetchBookingsForVendor();
              },
            ),
          ),
          Positioned(
            right: 16,
            top: -50,
            child: GestureDetector(
              onTap: () => Navigator.pop(context),
              child: Container(
                width: 40,
                height: 40,
                decoration: BoxDecoration(
                  color: Colors.white,
                  shape: BoxShape.circle,
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.2),
                      blurRadius: 6,
                      spreadRadius: 1,
                    ),
                  ],
                ),
                child: Icon(Icons.close, size: 24, color: Colors.black87),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
