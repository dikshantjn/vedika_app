import 'package:flutter/material.dart';
import 'package:socket_io_client/socket_io_client.dart' as IO;
import 'package:vedika_healthcare/core/constants/ApiEndpoints.dart';
import 'package:vedika_healthcare/features/Vendor/Registration/Services/VendorLoginService.dart';
import 'package:vedika_healthcare/features/Vendor/HospitalVendor/Services/HospitalVendorService.dart';
import 'dart:convert';

class ProcessAppointmentViewModel extends ChangeNotifier {
  // Per-booking loading states
  Map<String, bool> _loadingStates = {};
  Map<String, bool> _paymentCompletedStates = {};
  Map<String, bool> _processingStates = {};
  Map<String, bool> _notifyingPaymentStates = {};
  String? _error;
  IO.Socket? _socket;
  String? _currentBookingId;
  final HospitalVendorService _hospitalService = HospitalVendorService();

  // Getter methods for current booking
  bool get isLoading => _currentBookingId != null ? _loadingStates[_currentBookingId!] ?? false : false;
  bool get isPaymentCompleted => _currentBookingId != null ? _paymentCompletedStates[_currentBookingId!] ?? false : false;
  bool get isProcessing => _currentBookingId != null ? _processingStates[_currentBookingId!] ?? false : false;
  bool get isNotifyingPayment => _currentBookingId != null ? _notifyingPaymentStates[_currentBookingId!] ?? false : false;
  String? get error => _error;

  ProcessAppointmentViewModel() {
    initSocketConnection();
  }

  void initSocketConnection() async {
    debugPrint("🚀 Initializing socket connection for process appointment...");
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
        debugPrint('✅ Socket connected for process appointment');
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
        debugPrint('🔄 Process appointment update received: $data');
        await _handleBedBookingUpdate(data);
      });

      // Connect to the socket
      _socket!.connect();
      debugPrint('🔄 Attempting to connect socket for process appointment...');
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
      final paymentStatus = bookingData['paymentStatus'];
      
      if (bookingId != null && status != null) {
        if (status == 'completed' && paymentStatus == 'paid') {
          _paymentCompletedStates[bookingId] = true;
          _notifyingPaymentStates[bookingId] = false;
          _loadingStates[bookingId] = false;
          notifyListeners();
        }
      }
    } catch (e) {
      debugPrint('❌ Error handling bed booking update: $e');
    }
  }

  void setCurrentBookingId(String bookingId) {
    _currentBookingId = bookingId;
  }

  // Helper methods to get loading states for specific booking IDs
  bool isLoadingForBooking(String bookingId) {
    return _loadingStates[bookingId] ?? false;
  }

  bool isPaymentCompletedForBooking(String bookingId) {
    return _paymentCompletedStates[bookingId] ?? false;
  }

  bool isProcessingForBooking(String bookingId) {
    return _processingStates[bookingId] ?? false;
  }

  bool isNotifyingPaymentForBooking(String bookingId) {
    return _notifyingPaymentStates[bookingId] ?? false;
  }

  Future<void> acceptAppointment(String bookingId) async {
    try {
      _loadingStates[bookingId] = true;
      _error = null;
      notifyListeners();

      // Call the API to accept the appointment
      await _hospitalService.acceptAppointment(bookingId);
      
    } catch (e) {
      _error = 'Failed to accept appointment. Please try again.';
    } finally {
      _loadingStates[bookingId] = false;
      notifyListeners();
    }
  }

  Future<void> notifyPayment(String appointmentId) async {
    try {
      _loadingStates[appointmentId] = true;
      _notifyingPaymentStates[appointmentId] = true;
      _error = null;
      notifyListeners();

      // Call the API to notify user about payment
      await _hospitalService.notifyUserPayment(appointmentId);
      
      // Don't set _isPaymentCompleted here - wait for socket event
      // The socket event will update the UI when payment is actually completed
      
    } catch (e) {
      _error = 'Failed to notify payment. Please try again.';
      _notifyingPaymentStates[appointmentId] = false;
    } finally {
      _loadingStates[appointmentId] = false;
      notifyListeners();
    }
  }

  Future<void> completeAppointment(String appointmentId) async {
    try {
      _processingStates[appointmentId] = true;
      _error = null;
      notifyListeners();

      // Simulate API call
      await Future.delayed(const Duration(seconds: 2));

      // TODO: Update appointment status to completed
    } catch (e) {
      _error = 'Failed to complete appointment. Please try again.';
    } finally {
      _processingStates[appointmentId] = false;
      notifyListeners();
    }
  }

  void resetState() {
    _loadingStates.clear();
    _paymentCompletedStates.clear();
    _processingStates.clear();
    _notifyingPaymentStates.clear();
    _error = null;
    notifyListeners();
  }

  @override
  void dispose() {
    if (_socket != null) {
      _socket!.disconnect();
      _socket!.dispose();
    }
    super.dispose();
  }
} 