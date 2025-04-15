import 'dart:async';
import 'dart:math';
import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:provider/provider.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:vedika_healthcare/core/auth/data/repositories/AuthRepository.dart';
import 'package:vedika_healthcare/core/auth/data/services/StorageService.dart';
import 'package:vedika_healthcare/core/navigation/AppRoutes.dart';
import 'package:vedika_healthcare/features/Vendor/BloodBankAgencyVendor/data/model/BloodBankBooking.dart';
import 'package:vedika_healthcare/features/bloodBank/data/services/BloodBankAgencyService.dart';
import 'package:vedika_healthcare/features/bloodBank/presentation/widgets/BloodBankDetailsBottomSheet.dart';
import 'package:vedika_healthcare/features/bloodBank/presentation/widgets/BloodRequestDetailsBottomSheet.dart';
import 'package:vedika_healthcare/features/bloodBank/presentation/widgets/BloodTypeSelectionDialog.dart';
import 'package:vedika_healthcare/features/Vendor/BloodBankAgencyVendor/data/model/BloodBankAgency.dart';
import 'package:vedika_healthcare/shared/services/LocationProvider.dart';

class BloodBankViewModel extends ChangeNotifier {
  final BuildContext context;
  late LatLng _currentPosition;
  bool _isLoadingLocation = true;
  bool _isBloodTypeSelected = false;
  List<BloodBankAgency> _bloodBankAgencies = [];
  List<String> _selectedBloodTypes = [];
  Set<Marker> _markers = {};
  bool _isLoadingAgencies = false;
  String? _errorMessage;

  List<BloodBankBooking> _bookings = [];
  bool _isLoadingBookings = false;
  String? _bookingError;

  List<BloodBankBooking> get bookings => _bookings;
  bool get isLoadingBookings => _isLoadingBookings;
  String? get bookingError => _bookingError;

  // Added missing map controller
  late GoogleMapController _mapController;
  
  // Service for fetching blood bank agencies
  final BloodBankAgencyService _agencyService = BloodBankAgencyService();
  final AuthRepository _authRepository = AuthRepository();

  BloodBankViewModel(this.context);

  LatLng get currentPosition => _currentPosition;
  bool get isLoadingLocation => _isLoadingLocation;
  List<BloodBankAgency> get bloodBankAgencies => _bloodBankAgencies;
  Set<Marker> get markers => _markers;
  bool get isLoadingAgencies => _isLoadingAgencies;
  String? get errorMessage => _errorMessage;

  // Getter and setter for map controller
  GoogleMapController get mapController => _mapController;

  void setMapController(GoogleMapController controller) {
    _mapController = controller;
    notifyListeners();
  }

  Future<void> ensureLocationEnabled()async {
    debugPrint("Starting location check...");

    var locationProvider = Provider.of<LocationProvider>(context, listen: false);

    bool serviceEnabled = await locationProvider.isLocationServiceEnabled();
    debugPrint("Location service enabled: $serviceEnabled");

    bool permissionGranted = await locationProvider.requestLocationPermission();
    debugPrint("Location permission granted: $permissionGranted");

    if (!serviceEnabled || !permissionGranted) {
      debugPrint("Service not enabled or permission not granted, navigating to settings...");
      WidgetsBinding.instance.addPostFrameCallback((_) {
        Navigator.pushReplacementNamed(context, AppRoutes.enableBloodBankLocation);
      });
      return;
    }

    debugPrint("Fetching and saving location...");
    await locationProvider.loadSavedLocation();

    if (locationProvider.latitude != null && locationProvider.longitude != null) {
      debugPrint("Location fetched: (${locationProvider.latitude}, ${locationProvider.longitude})");

      _currentPosition = LatLng(locationProvider.latitude!, locationProvider.longitude!);
      _isLoadingLocation = false;
      notifyListeners();

      // Fetch bookings first
      await fetchBookingsForVendor();

      // If bookings exist, we already showed the bottom sheet inside that method
      if (_bookings.isNotEmpty) {
        debugPrint("Bookings available. Skipping blood type selection dialog.");
        _fetchBloodBankAgencies(); // Still load agencies and markers
        return;
      }

      debugPrint("No bookings found. Fetching blood banks and showing blood type dialog...");
      await _fetchBloodBankAgencies();

      WidgetsBinding.instance.addPostFrameCallback((_) {
        _showBloodTypeSelectionDialog();
      });
    } else {
      debugPrint("Location is null. Could not fetch location.");
      _errorMessage = "Could not determine your location.";
      notifyListeners();
    }
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
          final distance = _calculateDistance(_currentPosition, location);
          
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

  // Add markers for blood bank agencies
  void _addBloodBankAgencyMarkers() {
    _markers.clear();
    
    // Add user location marker
    _markers.add(
      Marker(
        markerId: MarkerId("user_location"),
        position: _currentPosition,
        infoWindow: InfoWindow(title: "Your Location"),
        icon: BitmapDescriptor.defaultMarkerWithHue(BitmapDescriptor.hueBlue),
      ),
    );
    
    for (var agency in _bloodBankAgencies) {
      // Parse the Google Maps location string to get latitude and longitude
      final locationParts = agency.googleMapsLocation.split(',');
      if (locationParts.length == 2) {
        try {
          final latitude = double.parse(locationParts[0].trim());
          final longitude = double.parse(locationParts[1].trim());
          
          final location = LatLng(latitude, longitude);
          
          // Calculate distance from user
          final distance = _calculateDistance(_currentPosition, location);
          
          // Only add markers for agencies within 5km
          if (distance <= 5.0) {
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
    showDialog(
      context: context,
      builder: (BuildContext context) => BloodTypeSelectionDialog(
        selectedBloodTypes: _selectedBloodTypes,
        onBloodTypesSelected: (List<String> selectedTypes) {
          _selectedBloodTypes = selectedTypes;
          _isBloodTypeSelected = true;
          notifyListeners();
          _addBloodBankAgencyMarkers();
        },
        onRequestConfirm: _attemptToAcceptBloodRequest,
      ),
    );
  }

  void _attemptToAcceptBloodRequest() async {
    debugPrint("Attempting to accept blood request...");

    if (!_isBloodTypeSelected) {
      debugPrint("Blood type not selected.");
      return;
    }

    BloodBankAgency? nearestAgency = _getNearestBloodBankAgency();
    if (nearestAgency == null) {
      debugPrint("No nearest blood bank agency found.");
      return;
    }

    debugPrint("Nearest Blood Bank Agency: ${nearestAgency.agencyName}");

    bool requestSent = await _sendRequestToVendor(nearestAgency);
    debugPrint("Blood request sent: $requestSent");

    if (requestSent) {
      _listenForVendorResponse(nearestAgency);
    }
  }

  Future<bool> _sendRequestToVendor(BloodBankAgency agency) async {
    await Future.delayed(Duration(seconds: 1));
    return true;
  }

  // void _showBloodRequestDetailsBottomSheet(BloodBankAgency agency) {
  //   if (!context.mounted) {
  //     debugPrint("Context is no longer mounted. Cannot show bottom sheet.");
  //     return;
  //   }
  //
  //   debugPrint("Showing Blood Request Details Bottom Sheet for ${agency.agencyName}");
  //
  //   showModalBottomSheet(
  //     context: context,
  //     isScrollControlled: true,
  //     backgroundColor: Colors.transparent,
  //     enableDrag: false,
  //     shape: RoundedRectangleBorder(
  //       borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
  //     ),
  //     builder: (context) => Stack(
  //       clipBehavior: Clip.none,
  //       children: [
  //         IntrinsicHeight(
  //           child: BloodRequestDetailsBottomSheet(
  //             customerName: "Patient", // You might want to get this from somewhere
  //             bloodTypes: _selectedBloodTypes,
  //             units: 1, // You might want to get this from somewhere
  //             prescriptionUrl: "", // You might want to get this from somewhere
  //             onCallBloodBank: () {
  //               // Handle calling the blood bank
  //               final phoneNumber = agency.phoneNumber;
  //               if (phoneNumber != null) {
  //                 launchUrl(Uri.parse('tel:$phoneNumber'));
  //               }
  //             },
  //           ),
  //         ),
  //         // Close button outside the bottom sheet
  //         Positioned(
  //           right: 16,
  //           top: -50,
  //           child: GestureDetector(
  //             onTap: () => Navigator.pop(context),
  //             child: Container(
  //               width: 40,
  //               height: 40,
  //               decoration: BoxDecoration(
  //                 color: Colors.white,
  //                 shape: BoxShape.circle,
  //                 boxShadow: [
  //                   BoxShadow(
  //                     color: Colors.black.withOpacity(0.2),
  //                     blurRadius: 6,
  //                     spreadRadius: 1,
  //                   ),
  //                 ],
  //               ),
  //               child: Icon(Icons.close, size: 24, color: Colors.black87),
  //             ),
  //           ),
  //         ),
  //       ],
  //     ),
  //   );
  // }

  void _listenForVendorResponse(BloodBankAgency agency) {
    debugPrint("Listening for vendor response...");

    // Check vendor response directly without using a timer
    _checkVendorResponse(agency).then((isAccepted) {
      debugPrint("Vendor response received: $isAccepted");


        debugPrint("Vendor accepted the request. Showing bottom sheet.");
        // _showBloodRequestDetailsBottomSheet(agency);

    });
  }

  Future<void> fetchBookingsForVendor() async {
    String? token = await _authRepository.getToken();
    String? userId = await StorageService.getUserId();

    _isLoadingBookings = true;
    _bookingError = null;
    notifyListeners();

    try {
      _bookings = await _agencyService.getBookings(userId!, token!);
      debugPrint('Bookings fetched: ${_bookings.length}');
      if (_bookings.isNotEmpty) {
        _showBookingDetailsBottomSheet(_bookings.first);
      }
    } catch (e) {
      debugPrint('Error fetching bookings: $e');
      _bookingError = e.toString();
    } finally {
      _isLoadingBookings = false;
      notifyListeners();
    }
  }


  Future<bool> _checkVendorResponse(BloodBankAgency agency) async {
    await Future.delayed(Duration(seconds: 0));
    return Random().nextBool();
  }

  void _showBookingDetailsBottomSheet(BloodBankBooking booking) {
    if (!context.mounted) {
      debugPrint("Context is no longer mounted. Cannot show bottom sheet.");
      return;
    }

    debugPrint("Showing Booking Details Bottom Sheet for booking ID: ${booking.bookingId}");

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
              booking: booking, // Passing the full booking object
              onCallBloodBank: () {
                final phoneNumber = booking.user.phoneNumber; // Assuming this exists in the UserModel
                if (phoneNumber != null && phoneNumber.isNotEmpty) {
                  launchUrl(Uri.parse('tel:$phoneNumber'));
                } else {
                  // Handle the case where phone number is null or empty
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(content: Text("Phone number is not available")),
                  );
                }
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
