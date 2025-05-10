import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:provider/provider.dart';
import 'package:socket_io_client/socket_io_client.dart' as IO;
import 'package:vedika_healthcare/core/auth/data/services/StorageService.dart';
import 'package:vedika_healthcare/features/ambulance/presentation/view/EnableLocationPage.dart';
import 'package:vedika_healthcare/features/hospital/data/service/HospitalService.dart';
import 'package:vedika_healthcare/features/Vendor/HospitalVendor/Models/HospitalProfile.dart';
import 'package:vedika_healthcare/shared/services/LocationProvider.dart';
import 'package:location/location.dart' as loc;
import 'package:vedika_healthcare/features/hospital/presentation/models/BedBooking.dart';
import 'package:vedika_healthcare/features/hospital/presentation/widgets/OngoingBookingBottomSheet.dart';
import 'package:vedika_healthcare/core/constants/ApiEndpoints.dart';
import 'dart:convert';

class HospitalSearchViewModel extends ChangeNotifier {
  GoogleMapController? _mapController;
  List<HospitalProfile> _hospitals = [];
  List<HospitalProfile> _filteredHospitals = [];
  List<bool> _expandedItems = [];
  bool _isLoading = true;
  bool _isLoadingLocation = true;
  LatLng? _currentPosition;
  TextEditingController _searchController = TextEditingController();
  Set<Marker> _markers = {};
  final HospitalService _hospitalService = HospitalService();
  List<BedBooking> _userBookings = [];
  bool _isLoadingBookings = false;
  BedBooking? _selectedBooking;
  IO.Socket? _socket;
  bool mounted = true;

  List<HospitalProfile> get filteredHospitals => _filteredHospitals;
  List<bool> get expandedItems => _expandedItems;
  bool get isLoading => _isLoading;
  bool get isLoadingLocation => _isLoadingLocation;
  LatLng? get currentPosition => _currentPosition;
  TextEditingController get searchController => _searchController;
  Set<Marker> get markers => _markers;
  List<BedBooking> get userBookings => _userBookings;
  bool get isLoadingBookings => _isLoadingBookings;
  BedBooking? get selectedBooking => _selectedBooking;

  HospitalSearchViewModel() {
    initSocketConnection();
  }

  void initSocketConnection() async {
    debugPrint("🚀 Initializing socket connection for bed bookings...");
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
        debugPrint('✅ Socket connected for bed bookings');
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

      // Add event listener for bedBookingUpdated
      _socket!.on('bedBookingUpdated', (data) async {
        debugPrint('🔄 Bed booking update received: $data');
        await _handleBedBookingUpdate(data);
      });

      // Add ping/pong handlers
      _socket!.on('ping', (_) {
        _socket!.emit('pong');
      });

      // Connect to the socket
      _socket!.connect();
      debugPrint('🔄 Attempting to connect socket for bed bookings...');
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

  Future<void> _handleBedBookingUpdate(dynamic data) async {
    try {
      debugPrint('🏥 Processing bed booking update: $data');
      
      // Parse the data if it's a string
      Map<String, dynamic> bookingData = data is String ? json.decode(data) : data;
      debugPrint('🏥 Parsed data: $bookingData');
      
      final bookingId = bookingData['bookingId'];
      final status = bookingData['status'];
      
      if (bookingId != null && status != null) {
        // Find and update the booking in the list
        final bookingIndex = _userBookings.indexWhere((booking) => booking.bedBookingId == bookingId);
        
        if (bookingIndex != -1) {
          debugPrint('🏥 Found booking at index: $bookingIndex');
          
          // Update the booking with new status
          _userBookings[bookingIndex] = _userBookings[bookingIndex].copyWith(
            status: status,
            // If status is completed, update payment status as well
            paymentStatus: status == 'completed' ? 'completed' : _userBookings[bookingIndex].paymentStatus,
          );
          
          // If this is the currently selected booking, update it
          if (_selectedBooking?.bedBookingId == bookingId) {
            _selectedBooking = _userBookings[bookingIndex];
            debugPrint('✅ Updated selected booking status to: $status');
            // Notify the bottom sheet to update
            notifyListeners();
          }
          
          debugPrint('✅ Booking $bookingId status updated to: $status');
        } else {
          debugPrint('❌ Booking not found with ID: $bookingId');
          
          // If booking not found, refresh bookings without showing bottom sheet
          await _refreshBookings();
        }
      } else {
        debugPrint('❌ Missing bookingId or status in data: $bookingData');
      }
    } catch (e, stackTrace) {
      debugPrint('❌ Error handling bed booking update: $e');
      debugPrint('❌ Stack trace: $stackTrace');
    }
  }

  // New method to refresh bookings without context
  Future<void> _refreshBookings() async {
    try {
      _isLoadingBookings = true;
      notifyListeners();
      
      String? userId = await StorageService.getUserId();
      if (userId != null) {
        _userBookings = await _hospitalService.getUserOngoingBookings(userId);
      }
      
      _isLoadingBookings = false;
      notifyListeners();
    } catch (e) {
      debugPrint('❌ Error refreshing bookings: $e');
      _isLoadingBookings = false;
      notifyListeners();
    }
  }

  @override
  void dispose() {
    if (_socket != null) {
      _socket!.disconnect();
      _socket!.dispose();
    }
    super.dispose();
  }

  /// **Ensure Location is Enabled and Fetch Hospitals**
  Future<void> ensureLocationEnabled(BuildContext context) async {
    var locationProvider = Provider.of<LocationProvider>(context, listen: false);
    loc.Location location = loc.Location();

    bool serviceEnabled = await location.serviceEnabled();
    if (!serviceEnabled) {
      serviceEnabled = await location.requestService();
      if (!serviceEnabled) {
        print("🔴 User refused to enable location services.");
        WidgetsBinding.instance.addPostFrameCallback((_) {
          Navigator.pushReplacement(
            context,
            MaterialPageRoute(builder: (context) => EnableLocationPage(fromSource: "hospital")),
          );
        });
        return;
      }
    }

    loc.PermissionStatus permissionGranted = await location.hasPermission();
    if (permissionGranted == loc.PermissionStatus.denied) {
      permissionGranted = await location.requestPermission();
      if (permissionGranted != loc.PermissionStatus.granted) {
        print("🔴 User denied location permission.");
        WidgetsBinding.instance.addPostFrameCallback((_) {
          Navigator.pushReplacement(
            context,
            MaterialPageRoute(builder: (context) => EnableLocationPage(fromSource: "hospital")),
          );
        });
        return;
      }
    }

    print("✅ Location service enabled and permission granted.");

    // Load saved location
    await locationProvider.loadSavedLocation();
    if (locationProvider.latitude != null && locationProvider.longitude != null) {
      _currentPosition = LatLng(locationProvider.latitude!, locationProvider.longitude!);
      print("✅ Updated Position: $_currentPosition");

      _isLoadingLocation = false;
      notifyListeners();

      await loadHospitals(context);
    } else {
      print("🔴 LocationProvider did not return a valid location.");
      _isLoadingLocation = false;
      notifyListeners();
    }
  }

  /// **Fetch Hospitals Based on User Location**
  Future<void> loadHospitals(BuildContext context) async {
    print("🔄 loadHospitals started...");

    if (_currentPosition != null) {
      try {
        _hospitals = await _hospitalService.getAllHospitals();
        print("🏥 Retrieved ${_hospitals.length} hospitals from API.");

        _filteredHospitals = List.from(_hospitals);
        _expandedItems = List<bool>.filled(_hospitals.length, false);

        _isLoading = false;
        _isLoadingLocation = false;

        _addMarkers();
        notifyListeners();

        print("✅ Hospitals loaded successfully.");
      } catch (e) {
        print("❌ Error loading hospitals: $e");
        _isLoading = false;
        _isLoadingLocation = false;
        notifyListeners();
      }
    } else {
      print("❌ Location data is still null.");
    }
  }

  /// **Filter Hospitals Based on Search Query**
  void filterHospitals(String query) {
    if (query.isEmpty) {
      _filteredHospitals = List.from(_hospitals);
    } else {
      _filteredHospitals = _hospitals.where((hospital) {
        return hospital.name.toLowerCase().contains(query.toLowerCase()) ||
            hospital.address.toLowerCase().contains(query.toLowerCase()) ||
            hospital.specialityTypes.any((speciality) => 
                speciality.toLowerCase().contains(query.toLowerCase()));
      }).toList();
    }
    _expandedItems = List.generate(_filteredHospitals.length, (index) => false);
    notifyListeners();
  }

  /// **Toggle Expanded Item Status**
  void toggleExpansion(int index) {
    _expandedItems[index] = !_expandedItems[index];
    notifyListeners();
  }

  /// **Move Camera to Selected Hospital**
  void moveCameraToHospital(double lat, double lng) {
    _mapController?.animateCamera(CameraUpdate.newLatLngZoom(LatLng(lat, lng), 14.0));
  }

  /// **Initialize Google Map Controller**
  void onMapCreated(GoogleMapController controller) {
    _mapController = controller;
    notifyListeners();
  }

  /// **Add Markers for Hospitals and User Location**
  void _addMarkers() {
    print("📍 Adding markers...");
    _markers.clear();
    _markers.addAll(_hospitals.map((hospital) {
      // Parse location string to get lat and lng
      final locationParts = hospital.location.split(',');
      final lat = double.tryParse(locationParts[0]) ?? 0.0;
      final lng = double.tryParse(locationParts[1]) ?? 0.0;

      return Marker(
        markerId: MarkerId(hospital.vendorId ?? hospital.generatedId ?? ''),
        position: LatLng(lat, lng),
        infoWindow: InfoWindow(title: hospital.name),
        onTap: () {
          filterHospitals(hospital.name);
          moveCameraToHospital(lat, lng);
        },
      );
    }));

    if (_currentPosition != null) {
      _markers.add(
        Marker(
          markerId: MarkerId("userLocation"),
          position: _currentPosition!,
          infoWindow: InfoWindow(title: "Your Location"),
          icon: BitmapDescriptor.defaultMarkerWithHue(BitmapDescriptor.hueAzure),
        ),
      );
    }
    notifyListeners();
    print("✅ Markers added: ${_markers.length}");
  }

  /// **Handle Hospital Tap**
  void onHospitalTap(int index, double lat, double lng) {
    if (index >= 0 && index < _filteredHospitals.length) {
      toggleExpansion(index);
      moveCameraToHospital(lat, lng);
    }
  }

  Future<void> loadUserBookings(BuildContext context, {bool showBottomSheet = false}) async {
    try {
      _isLoadingBookings = true;
      notifyListeners();
      String? userId = await StorageService.getUserId();
      _userBookings = await _hospitalService.getUserOngoingBookings(userId!);
      
      // Only show booking details if explicitly requested and there are bookings
      if (showBottomSheet && _userBookings.isNotEmpty) {
        WidgetsBinding.instance.addPostFrameCallback((_) {
          showBookingDetails(context, _userBookings.first);
        });
      }
      
      _isLoadingBookings = false;
      notifyListeners();
    } catch (e) {
      print("❌ Error loading user bookings: $e");
      _isLoadingBookings = false;
      notifyListeners();
    }
  }

  // New method for initial loading that shows bottom sheet
  Future<void> loadInitialBookings(BuildContext context) async {
    await loadUserBookings(context, showBottomSheet: true);
  }

  void showBookingDetails(BuildContext context, BedBooking booking) {
    _selectedBooking = booking;
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => Container(
        decoration: const BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
        ),
        child: OngoingBookingBottomSheet(booking: booking),
      ),
    );
  }

  void hideBookingDetails() {
    _selectedBooking = null;
    notifyListeners();
  }
}
