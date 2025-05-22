import 'dart:math';
import 'dart:convert';
import 'package:awesome_dialog/awesome_dialog.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:location/location.dart';
import 'package:logger/web.dart';
import 'package:provider/provider.dart';
import 'package:socket_io_client/socket_io_client.dart' as IO;
import 'package:vedika_healthcare/core/auth/data/services/StorageService.dart';
import 'package:vedika_healthcare/core/constants/ApiEndpoints.dart';
import 'package:vedika_healthcare/features/TrackOrder/data/Services/TrackOrderService.dart';
import 'package:vedika_healthcare/features/Vendor/AmbulanceAgencyVendor/data/modals/AmbulanceAgency.dart';
import 'package:vedika_healthcare/features/ambulance/data/models/AmbulanceBooking.dart';
import 'package:vedika_healthcare/features/ambulance/data/services/AmbulanceService.dart';
import 'package:vedika_healthcare/features/ambulance/data/services/EmergiencyAmbulanceService.dart';
import 'package:vedika_healthcare/features/ambulance/presentation/widgets/AmbulanceDetailsBottomSheet.dart';
import 'package:vedika_healthcare/shared/services/LocationProvider.dart';

class AmbulanceSearchViewModel extends ChangeNotifier {
  GoogleMapController? mapController;
  LatLng? currentPosition;
  final Set<Marker> markers = {};
  List<AmbulanceAgency> ambulances = [];
  bool isLocationEnabled = false;
  bool _mounted = true; // Track if view model is mounted
  bool _isDialogShowing = false;
  EmergiencyAmbulanceService _service = EmergiencyAmbulanceService();
  final TrackOrderService _trackOrderService = TrackOrderService();
  final logger = Logger();
  IO.Socket? _socket;

  var isLoading = false.obs;
  var availableAgencies = <AmbulanceAgency>[].obs;
  var errorMessage = ''.obs;

  double chargePerKM = 50;
  double baseFare = 200;
  double nearbyDistance = 15.0;

  List<AmbulanceBooking> _ambulanceBookings = [];
  List<AmbulanceBooking> get ambulanceBookings => _ambulanceBookings;

  bool _isLoading = false;
  final BuildContext context;

  bool _isBookingInProgress = false;

  AmbulanceSearchViewModel(this.context) {
    _checkLocationEnabled();
    initSocketConnection();
  }

  @override
  void dispose() {
    _mounted = false; // Mark as disposed
    if (_socket != null) {
      _socket!.disconnect();
      _socket!.dispose();
    }
    mapController?.dispose();
    super.dispose();
  }

  // Helper method to safely notify listeners
  void _safeNotifyListeners() {
    if (_mounted) {
      notifyListeners();
    }
  }

  void initSocketConnection() async {
    debugPrint("🚀 Initializing socket connection for ambulance bookings...");
    try {
      String? userId = await StorageService.getUserId();
      if (userId == null) {
        debugPrint("❌ User ID not found for socket registration");
        return;
      }

      // Close existing socket if any
      _socket?.disconnect();
      _socket?.dispose();

      _socket = IO.io(ApiEndpoints.socketUrl, <String, dynamic>{
        'transports': ['websocket', 'polling'],
        'autoConnect': true,
        'reconnection': true,
        'reconnectionAttempts': 10,
        'reconnectionDelay': 1000,
        'reconnectionDelayMax': 5000,
        'timeout': 20000,
        'forceNew': true,
        'upgrade': true,
        'rememberUpgrade': true,
        'path': '/socket.io/',
        'query': {'userId': userId},
      });

      // Set up event listeners
      _socket!.onConnect((_) {
        debugPrint('✅ Socket connected for ambulance bookings');
        _socket!.emit('register', userId);
      });

      _socket!.onConnectError((data) {
        debugPrint('❌ Socket connection error: $data');
        _attemptReconnect();
      });

      _socket!.onError((data) {
        debugPrint('❌ Socket error: $data');
      });

      _socket!.onDisconnect((_) {
        debugPrint('❌ Socket disconnected');
        _attemptReconnect();
      });

      

      // Add new event listener for ambulanceBookingUpdated
      _socket!.on('ambulanceBookingUpdated', (data) async {
        debugPrint('🔄 Ambulance booking update received: $data');
        await _handleAmbulanceStatusUpdate(data);
      });

      // Add ping/pong handlers
      _socket!.on('ping', (_) {
        _socket!.emit('pong');
      });

      // Connect to the socket
      _socket!.connect();
      debugPrint('🔄 Attempting to connect socket for ambulance bookings...');
    } catch (e) {
      debugPrint("❌ Socket connection error: $e");
      _attemptReconnect();
    }
  }

  void _attemptReconnect() {
    Future.delayed(Duration(seconds: 2), () {
      if (_socket != null && !_socket!.connected) {
        debugPrint('🔄 Attempting to reconnect...');
        _socket!.connect();
      }
    });
  }

  Future<void> _handleAmbulanceStatusUpdate(dynamic data) async {
    try {
      debugPrint('🚑 Processing ambulance status update: $data');
      
      // Parse the data if it's a string
      Map<String, dynamic> bookingData = data is String ? json.decode(data) : data;
      debugPrint('🚑 Parsed data: $bookingData');
      
      final requestId = bookingData['requestId'];
      final status = bookingData['status'];
      final totalAmount = bookingData['totalAmount'];
      final vehicleType = bookingData['vehicleType'];
      
      if (requestId != null && status != null) {
        // Find and update the booking in the list
        final bookingIndex = _ambulanceBookings.indexWhere((booking) => booking.requestId == requestId);
        
        if (bookingIndex != -1) {
          debugPrint('🚑 Found booking at index: $bookingIndex');
          
          // Convert totalAmount to double if it exists
          double? parsedTotalAmount;
          if (totalAmount != null) {
            if (totalAmount is String) {
              parsedTotalAmount = double.tryParse(totalAmount);
            } else if (totalAmount is num) {
              parsedTotalAmount = totalAmount.toDouble();
            }
            debugPrint('🚑 Parsed total amount: $parsedTotalAmount');
          }
          
          // Update the booking with all received data
          _ambulanceBookings[bookingIndex] = _ambulanceBookings[bookingIndex].copyWith(
            status: status,
            totalAmount: parsedTotalAmount ?? _ambulanceBookings[bookingIndex].totalAmount,
            vehicleType: vehicleType ?? _ambulanceBookings[bookingIndex].vehicleType,
          );
          
          // If status is WaitingForPayment, refresh the bookings to get latest data
          if (status == "WaitingForPayment") {
            debugPrint('🔄 Refreshing bookings for WaitingForPayment status');
            // First update the current booking
            _safeNotifyListeners();
            
            // Then fetch fresh data
            await fetchActiveAmbulanceBookings();
            
            // Force another UI update after fetching
            _safeNotifyListeners();
          } else {
            // For other status updates, just notify listeners
            _safeNotifyListeners();
          }
          
          debugPrint('✅ Booking $requestId status updated to: $status');
        } else {
          debugPrint('❌ Booking not found with ID: $requestId');
          
          // If booking not found, refresh bookings
          await fetchActiveAmbulanceBookings();
          _safeNotifyListeners();
        }
      } else {
        debugPrint('❌ Missing requestId or status in data: $bookingData');
      }
    } catch (e, stackTrace) {
      debugPrint('❌ Error handling ambulance status update: $e');
      debugPrint('❌ Stack trace: $stackTrace');
      // Even if there's an error, try to refresh the data
      await fetchActiveAmbulanceBookings();
      _safeNotifyListeners();
      }
  }

  Future<void> _checkLocationEnabled() async {
    if (!_mounted) return; // Don't proceed if disposed

    Location location = Location();
    bool serviceEnabled = await location.serviceEnabled();

    if (!serviceEnabled) {
      serviceEnabled = await location.requestService();
      if (!serviceEnabled) {
        isLocationEnabled = false;
        if (_mounted) _safeNotifyListeners();

        // Delay showing dialog slightly to avoid race condition with system prompt
        Future.delayed(Duration(milliseconds: 300), () {
          if (!_isDialogShowing && _mounted) _showLocationDialog();
        });

        return;
      }
    }

    LocationData? userLocation = await location.getLocation();
    if (userLocation.latitude != null && userLocation.longitude != null) {
      isLocationEnabled = true;
      if (_mounted) _safeNotifyListeners();
      initialize();
    } else {
      isLocationEnabled = false;
      if (_mounted) _safeNotifyListeners();
      if (!_isDialogShowing && _mounted) _showLocationDialog();
    }
  }

  Future<void> initialize() async {
    if (!_mounted) return; // Don't proceed if disposed
    await getUserLocation();
    fetchAvailableAgencies();
    await fetchActiveAmbulanceBookings();
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

    _safeNotifyListeners();
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

    _safeNotifyListeners();
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

    return nearestAmbulance;  // Just return the nearest ambulance without creating booking
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

  Future<bool> callNearestAmbulance() async {
    if (currentPosition == null) {
      _showLocationDialog();
      return false;
    }

    // Prevent duplicate bookings
    if (_isBookingInProgress) {
      return false;
    }

    try {
      _isBookingInProgress = true;  // Set flag before starting booking process

      AmbulanceAgency? nearestAmbulance = _findNearestAmbulance();

      if (nearestAmbulance == null) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text("No ambulance available nearby.")),
        );
        return false;
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

        // Create booking with the nearest ambulance
        await _createBookingWithNearestAmbulance(nearestAmbulance);
        
        // Fetch the latest bookings to update the UI
        await fetchActiveAmbulanceBookings();
        
        // Ensure state is updated
        _safeNotifyListeners();

        return true;
      }
      return false;
    } catch (e) {
      print("Error: $e");
      return false;
    } finally {
      _isBookingInProgress = false;  // Reset flag after booking process completes
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

  /// ✅ Fetch active ambulance bookings for current user
  Future<void> fetchActiveAmbulanceBookings() async {
    if (!_mounted) return; // Don't proceed if disposed

    _isLoading = true;
    _safeNotifyListeners();

    debugPrint("📦 Starting to fetch active ambulance bookings...");

    try {
      String? userId = await StorageService.getUserId();
      debugPrint("👤 User ID: $userId");

      if (userId == null) {
        debugPrint("❌ User ID not found");
        throw Exception("User ID not found");
      }

      _ambulanceBookings = await _trackOrderService.fetchActiveAmbulanceBookings(userId);
      debugPrint("✅ Ambulance bookings fetched: ${_ambulanceBookings.length}");

      for (var booking in _ambulanceBookings) {
        debugPrint("🚑 Booking ID: ${booking.requestId}, Status: ${booking.status}");
      }

    } catch (e, stackTrace) {
      debugPrint("❌ Error fetching ambulance bookings: $e");
      debugPrint("🔍 Stack Trace:\n$stackTrace");

      if (_mounted) {
      _ambulanceBookings = [];
      errorMessage = "No Ambulance Booking Found".obs;
      }
    } finally {
      if (_mounted) {
      _isLoading = false;
        _safeNotifyListeners();
      }
      debugPrint("📦 Done fetching ambulance bookings.");
    }
  }

  List<String> getSteps(String status) {
    List<String> steps = [
      "Booking Requested",
      "Agency Accepted",
      "Waiting For Payment",  // This step will dynamically change
      "On the Way",
      "Patient Picked Up",
      "Reached Hospital",
    ];
// If status is paymentCompleted, update the step in the timeline
    if (status == "paymentCompleted") {
      steps[2] = "Payment Completed";  // Modify step 2 if status is "PaymentCompleted"
    }

    return steps;
  }

  int getCurrentStepIndex(String status) {
    final Map<String, int> statusMap = {
      "pending": 0,
      "accepted": 1,
      "WaitingForPayment": 2, // Both 'WaitingForPayment' and 'paymentCompleted' will point to the same step
      "paymentCompleted": 2,   // Both statuses will point to index 2
      "OnTheWay": 3,
      "PickedUp": 4,
      "Completed": 5,
    };

    return statusMap[status] ?? 0;  // Default to index 0 if the status is unrecognized
  }

  // You can also expose a refresh method
  void refreshAgencies() {
    fetchAvailableAgencies();
  }

  void clearBookings() {
    _ambulanceBookings = [];
    _safeNotifyListeners();
  }
}
