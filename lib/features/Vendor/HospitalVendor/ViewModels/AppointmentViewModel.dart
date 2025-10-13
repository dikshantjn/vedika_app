import 'package:flutter/material.dart';
import 'package:vedika_healthcare/core/constants/ApiEndpoints.dart';
import 'package:vedika_healthcare/features/Vendor/Registration/Services/VendorLoginService.dart';
import 'package:vedika_healthcare/features/hospital/presentation/models/BedBooking.dart';
import 'package:vedika_healthcare/features/Vendor/HospitalVendor/Services/HospitalVendorService.dart';
import 'package:dio/dio.dart';
import 'package:socket_io_client/socket_io_client.dart' as IO;
import 'dart:convert';

class AppointmentViewModel extends ChangeNotifier {
  List<BedBooking> _appointments = [];
  List<BedBooking> _completedAppointments = [];
  bool _isLoading = false;
  String? _error;
  IO.Socket? _socket;
  bool mounted = true;
  
  // Per-booking loading states
  Map<String, bool> _acceptingStates = {};
  Map<String, bool> _notifyingStates = {};

  List<BedBooking> get appointments => _appointments;
  List<BedBooking> get completedAppointments => _completedAppointments;
  bool get isLoading => _isLoading;
  String? get error => _error;

  // Helper methods to get loading states for specific booking IDs
  bool isAcceptingBooking(String bookingId) {
    return _acceptingStates[bookingId] ?? false;
  }

  bool isNotifyingBooking(String bookingId) {
    return _notifyingStates[bookingId] ?? false;
  }

  final Dio _dio = Dio();
  final HospitalVendorService _hospitalService = HospitalVendorService();

  AppointmentViewModel() {
    initSocketConnection();
  }

  void initSocketConnection() async {
    debugPrint("🚀 Initializing socket connection for vendor bed bookings...");
    try {
      String? vendorId = await VendorLoginService().getVendorId();
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
        debugPrint('✅ Socket connected for vendor bed bookings');
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

      // Add event listener for vendorBedBookingUpdated
      _socket!.on('vendorBedBookingUpdated', (data) async {
        debugPrint('🔄 Vendor bed booking update received: $data');
        await _handleBedBookingUpdate(data);
      });

      // Add ping/pong handlers
      _socket!.on('ping', (_) {
        _socket!.emit('pong');
      });

      // Connect to the socket
      _socket!.connect();
      debugPrint('🔄 Attempting to connect socket for vendor bed bookings...');
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
      debugPrint('🏥 Processing vendor bed booking update: $data');
      
      // Parse the data if it's a string
      Map<String, dynamic> bookingData = data is String ? json.decode(data) : data;
      debugPrint('🏥 Parsed data: $bookingData');
      
      final bookingId = bookingData['bookingId'];
      final status = bookingData['status'];
      final paymentStatus = bookingData['paymentStatus'];
      
      if (bookingId != null && status != null) {
        // If payment is completed, refresh the appointments list
        if (status == 'completed' && paymentStatus == 'paid') {
          debugPrint('✅ Payment completed, refreshing appointments...');
          await fetchAppointments();
        } else {
          // For other status updates, also refresh to keep the list updated
          await fetchAppointments();
        }
        debugPrint('✅ Refreshed appointments after update');
      } else {
        debugPrint('❌ Missing bookingId or status in data: $bookingData');
      }
    } catch (e, stackTrace) {
      debugPrint('❌ Error handling vendor bed booking update: $e');
      debugPrint('❌ Stack trace: $stackTrace');
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

  Future<void> fetchAppointments() async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      String? vendorId = await VendorLoginService().getVendorId();
      if (vendorId != null) {
        _appointments = await _hospitalService.getHospitalBookingsByVendor(vendorId);
        _completedAppointments = await _hospitalService.getCompletedBookingsByVendor(vendorId);
      } else {
        _error = 'Vendor ID not found';
      }
    } catch (e) {
      _error = 'Failed to fetch bookings: $e';
    }

    _isLoading = false;
    notifyListeners();
  }

  Future<void> acceptAppointment(String bookingId) async {
    try {
      _acceptingStates[bookingId] = true;
      notifyListeners();
      
      await _hospitalService.acceptAppointment(bookingId);
      await fetchAppointments();
    } catch (e) {
      _error = 'Failed to accept booking: $e';
      notifyListeners();
    } finally {
      _acceptingStates[bookingId] = false;
      notifyListeners();
    }
  }

  Future<void> notifyUserPayment(String bookingId) async {
    try {
      _notifyingStates[bookingId] = true;
      notifyListeners();
      
      await _hospitalService.notifyUserPayment(bookingId);
      await fetchAppointments();
    } catch (e) {
      _error = 'Failed to notify user: $e';
      notifyListeners();
    } finally {
      _notifyingStates[bookingId] = false;
      notifyListeners();
    }
  }
} 