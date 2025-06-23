import 'package:awesome_snackbar_content/awesome_snackbar_content.dart';
import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:logger/web.dart';
import 'package:socket_io_client/socket_io_client.dart' as IO;
import 'package:vedika_healthcare/core/constants/ApiEndpoints.dart';
import 'package:vedika_healthcare/features/Vendor/AmbulanceAgencyVendor/data/services/AmbulanceBookingService.dart';
import 'package:vedika_healthcare/features/Vendor/Registration/Services/VendorLoginService.dart';
import 'package:vedika_healthcare/features/ambulance/data/models/AmbulanceBooking.dart';
import 'dart:convert';

class AmbulanceBookingRequestViewModel extends ChangeNotifier {
  final AmbulanceBookingService _bookingService = AmbulanceBookingService();
  final VendorLoginService _loginService = VendorLoginService();
  IO.Socket? _socket;

  List<AmbulanceBooking> bookingRequests = [];
  bool isLoading = false;
  String errorMessage = '';

  final Logger _logger = Logger();

  // 👇 For toast status
  bool _isAccepted = false;
  bool get isAccepted => _isAccepted;

  // Add new controllers for bypass fields
  final TextEditingController bypassReasonController = TextEditingController();
  final TextEditingController bypassApprovedByController = TextEditingController();
  bool isPaymentBypassed = false;

  AmbulanceBookingRequestViewModel() {
    initSocketConnection();
  }

  void initSocketConnection() async {
    debugPrint("🚀 Initializing socket connection for ambulance bookings...");
    try {
      String? vendorId = await _loginService.getVendorId();
      if (vendorId == null) {
        debugPrint("❌ Vendor ID not found for socket registration");
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
        'query': {'vendorId': vendorId},
      });

      // Set up event listeners
      _socket!.onConnect((_) {
        debugPrint('✅ Socket connected for ambulance bookings');
        _socket!.emit('registerVendor', vendorId);
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

      // Add event listener for vendorAmbulanceBookingUpdated
      _socket!.on('vendorAmbulanceBookingUpdated', (data) async {
        debugPrint('🔄 Ambulance booking update received: $data');
        await _handleAmbulanceBookingUpdate(data);
      });

      // Add event listener for paymentCompleted
      _socket!.on('paymentCompleted', (data) async {
        debugPrint('💰 Payment completed event received: $data');
        await _handlePaymentCompleted(data);
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

  Future<void> _handleAmbulanceBookingUpdate(dynamic data) async {
    try {
      debugPrint('🚑 Processing ambulance booking update: $data');
      
      // Parse the data if it's a string
      Map<String, dynamic> bookingData = data is String ? json.decode(data) : data;
      debugPrint('🚑 Parsed data: $bookingData');
      
      // Refresh the bookings list when any update is received
      await fetchPendingBookings();
      debugPrint('✅ Refreshed bookings after update');
      
    } catch (e) {
      debugPrint('❌ Error handling ambulance booking update: $e');
    }
  }

  Future<void> _handlePaymentCompleted(dynamic data) async {
    try {
      debugPrint('💰 Processing payment completed event: $data');
      
      // Parse the data if it's a string
      Map<String, dynamic> paymentData = data is String ? json.decode(data) : data;
      debugPrint('💰 Parsed payment data: $paymentData');
      
      // Update the booking status in the local list
      final requestId = paymentData['requestId'];
      if (requestId != null) {
        final index = bookingRequests.indexWhere((b) => b.requestId == requestId);
        if (index != -1) {
          bookingRequests[index] = bookingRequests[index].copyWith(status: 'paymentCompleted');
          debugPrint('✅ Updated booking status to paymentCompleted for requestId: $requestId');
        }
      }
      
      // Refresh the bookings list
      await fetchPendingBookings();
      debugPrint('✅ Refreshed bookings after payment completion');
      
      // Notify listeners to update UI
      notifyListeners();
      
    } catch (e) {
      debugPrint('❌ Error handling payment completed event: $e');
    }
  }

  // ----------------------------
  // 👇 Service Details Fields
  // ----------------------------

  final TextEditingController pickupLocationController = TextEditingController();
  final TextEditingController dropLocationController = TextEditingController();
  final TextEditingController totalDistanceController = TextEditingController();
  final TextEditingController costPerKmController = TextEditingController();
  final TextEditingController baseChargeController = TextEditingController();

  List<String> vehicleTypes = ['Mini', 'Van', 'AC', 'ICU', 'Oxygen'];
  String? selectedVehicleType;

  void setSelectedVehicleType(String type) {
    debugPrint('🔍 setSelectedVehicleType - Setting vehicle type to: $type');
    if (vehicleTypes.contains(type)) {
      selectedVehicleType = type;
      notifyListeners();
    } else {
      debugPrint('❌ setSelectedVehicleType - Invalid vehicle type: $type');
    }
  }

  void prefillServiceDetails({
    required String pickup,
    required String drop,
    required double distance,
    required double costPerKm,
    required double baseCharge,
    required String vehicleType,
  }) {
    debugPrint('🔍 prefillServiceDetails - Prefilling with vehicle type: $vehicleType');
    pickupLocationController.text = pickup;
    dropLocationController.text = drop;
    totalDistanceController.text = distance.toString();
    costPerKmController.text = costPerKm.toString();
    baseChargeController.text = baseCharge.toString();
    selectedVehicleType = vehicleType;
    notifyListeners();
  }

  // ----------------------------
  // 👇 Booking Requests
  // ----------------------------

  Future<void> fetchPendingBookings() async {
    String? vendorId = await _loginService.getVendorId();

    isLoading = true;
    notifyListeners();

    _logger.i("Fetching pending bookings for vendorId: $vendorId");

    try {
      bookingRequests = await _bookingService.getPendingBookings(vendorId!);
      _logger.d("Fetched bookings: ${bookingRequests.map((b) => b.toJson()).toList()}");
      errorMessage = '';
    } catch (e, stackTrace) {
      errorMessage = e.toString();
      _logger.e("Error fetching bookings", error: e, stackTrace: stackTrace);
    }

    isLoading = false;
    notifyListeners();
  }

  Future<bool> toggleRequestStatus(String requestId) async {
    try {
      isLoading = true;
      notifyListeners();

      final updatedStatus = await _bookingService.acceptBookingRequest(requestId);

      final index = bookingRequests.indexWhere((b) => b.requestId == requestId);
      if (index != -1) {
        bookingRequests[index] = bookingRequests[index].copyWith(status: updatedStatus);
      }

      isLoading = false;
      notifyListeners();
      return true;
    } catch (e) {
      isLoading = false;
      errorMessage = e.toString();
      notifyListeners();
      return false;
    }
  }

  Future<void> fetchVehicleTypes() async {
    try {
      isLoading = true;
      notifyListeners();

      final types = await _bookingService.getVehicleTypes();
      vehicleTypes = types;

      // Initialize selectedVehicleType if it's not set or not in the list
      if (selectedVehicleType == null || !vehicleTypes.contains(selectedVehicleType)) {
        selectedVehicleType = vehicleTypes.isNotEmpty ? vehicleTypes.first : null;
        debugPrint('🔍 fetchVehicleTypes - Initialized selectedVehicleType to: $selectedVehicleType');
      }

      _logger.i("Fetched vehicle types: $vehicleTypes");
      errorMessage = '';
    } catch (e, stackTrace) {
      errorMessage = e.toString();
      _logger.e("Error fetching vehicle types", error: e, stackTrace: stackTrace);
    } finally {
      isLoading = false;
      notifyListeners();
    }
  }

  void setPaymentBypassed(bool value) {
    isPaymentBypassed = value;
    notifyListeners();
  }

  Future<bool> addOrUpdateServiceDetails(String requestId) async {
    // Validate bypass data if payment is bypassed
    if (isPaymentBypassed) {
      if (bypassReasonController.text.trim().isEmpty) {
        debugPrint('❌ addOrUpdateServiceDetails - Bypass reason is required');
        return false;
      }
      if (bypassApprovedByController.text.trim().isEmpty) {
        debugPrint('❌ addOrUpdateServiceDetails - Bypass approver is required');
        return false;
      }
    }

    final pickup = pickupLocationController.text;
    final drop = dropLocationController.text;
    final distance = double.tryParse(totalDistanceController.text) ?? 0.0;
    final costPerKm = double.tryParse(costPerKmController.text) ?? 0.0;
    final baseCharge = double.tryParse(baseChargeController.text) ?? 0.0;
    final vehicleType = selectedVehicleType ?? '';
    final bypassReason = isPaymentBypassed ? bypassReasonController.text.trim() : null;
    final bypassApprovedBy = isPaymentBypassed ? bypassApprovedByController.text.trim() : null;

    final totalAmount = isPaymentBypassed ? 0.0 : (distance * costPerKm) + baseCharge;

    debugPrint('🔍 addOrUpdateServiceDetails - Starting update for requestId: $requestId');
    debugPrint('🔍 addOrUpdateServiceDetails - Input data:');
    debugPrint('  pickup: $pickup');
    debugPrint('  drop: $drop');
    debugPrint('  distance: $distance');
    debugPrint('  costPerKm: $costPerKm');
    debugPrint('  baseCharge: $baseCharge');
    debugPrint('  vehicleType: $vehicleType');
    debugPrint('  totalAmount: $totalAmount');
    debugPrint('  isPaymentBypassed: $isPaymentBypassed');
    debugPrint('  bypassReason: $bypassReason');
    debugPrint('  bypassApprovedBy: $bypassApprovedBy');

    try {
      final updatedBooking = await _bookingService.updateServiceDetails(
        requestId: requestId,
        pickupLocation: pickup,
        dropLocation: drop,
        totalDistance: distance,
        costPerKm: costPerKm,
        baseCharge: baseCharge,
        vehicleType: vehicleType,
        totalAmount: totalAmount,
        isPaymentBypassed: isPaymentBypassed,
        bypassReason: bypassReason,
        bypassApprovedBy: bypassApprovedBy,
      );

      debugPrint('🔍 addOrUpdateServiceDetails - API call successful');
      debugPrint('🔍 addOrUpdateServiceDetails - Updated booking data: ${updatedBooking.toString()}');

      // Update the local booking data
      final index = bookingRequests.indexWhere((b) => b.requestId == requestId);
      if (index != -1) {
        bookingRequests[index] = updatedBooking;
        debugPrint('🔍 addOrUpdateServiceDetails - Local booking data updated at index: $index');
        notifyListeners();
      } else {
        debugPrint('❌ addOrUpdateServiceDetails - Booking not found in local list');
      }

      return true;
    } catch (e, stackTrace) {
      debugPrint('❌ addOrUpdateServiceDetails - Error: $e');
      debugPrint('❌ addOrUpdateServiceDetails - Stack trace: $stackTrace');
      return false;
    }
  }


  Future<void> updateBookingStatus(String requestId, String status) async {
    try {
      // Handle different status updates using a switch case
      switch (status) {
        case 'OnTheWay':
          await _bookingService.updateBookingStatusOnTheWay(requestId);
          break;
        case 'PickedUp':
          await _bookingService.updateBookingStatusPickedUp(requestId);
          break;
        case 'Completed':
          await _bookingService.updateBookingStatusCompleted(requestId);
          break;
        default:
          throw Exception('Unknown status: $status');
      }

      // Update the status locally after successful API call
      final booking = bookingRequests.firstWhere((b) => b.requestId == requestId);
      booking.status = status;
      notifyListeners();

      // Optionally, display success message using SnackBar or other UI elements
      Fluttertoast.showToast(msg: 'Booking status updated to: $status');
    } catch (e) {
      // Handle any errors
      print("Error updating status: $e");
      Fluttertoast.showToast(msg: 'Failed to update status');
    }
  }


  @override
  void dispose() {
    if (_socket != null) {
      _socket!.disconnect();
      _socket!.dispose();
    }
    pickupLocationController.dispose();
    dropLocationController.dispose();
    totalDistanceController.dispose();
    costPerKmController.dispose();
    baseChargeController.dispose();
    bypassReasonController.dispose();
    bypassApprovedByController.dispose();
    super.dispose();
  }
}
