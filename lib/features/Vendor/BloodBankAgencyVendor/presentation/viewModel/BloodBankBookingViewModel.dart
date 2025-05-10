import 'package:flutter/material.dart';
import 'package:vedika_healthcare/features/Vendor/Registration/Services/VendorLoginService.dart';
import '../../data/model/BloodBankBooking.dart';
import '../../data/services/BloodBankBookingService.dart';
import '../../../../../core/auth/data/models/UserModel.dart';
import 'package:socket_io_client/socket_io_client.dart' as IO;
import 'package:vedika_healthcare/core/constants/ApiEndpoints.dart';
import 'dart:convert';

class BloodBankBookingViewModel extends ChangeNotifier {
  final BloodBankBookingService _service = BloodBankBookingService();
  final VendorLoginService _loginService = VendorLoginService();
  IO.Socket? _socket;
  bool mounted = true;

  List<BloodBankBooking> _bookings = [];
  bool _isLoading = false;
  String? _error;

  // Getters
  List<BloodBankBooking> get bookings => _bookings;
  bool get isLoading => _isLoading;
  String? get error => _error;

  // Filtered getters
  List<BloodBankBooking> get confirmedBookings => 
      _bookings.where((booking) => 
        booking.status.toUpperCase() != 'CANCELLED' && 
        booking.status.toUpperCase() != 'COMPLETED'
      ).toList();
  
  List<BloodBankBooking> get completedBookings =>
      _bookings.where((booking) => booking.status.toUpperCase() == 'COMPLETED').toList();
  
  List<BloodBankBooking> get cancelledBookings =>
      _bookings.where((booking) => booking.status.toUpperCase() == 'CANCELLED').toList();

  // Statistics getters
  double get totalRevenue =>
      completedBookings.fold(0, (sum, booking) => sum + booking.totalAmount);

  int get totalCompletedBookings => completedBookings.length;

  double get averageBookingValue =>
      totalCompletedBookings > 0 ? totalRevenue / totalCompletedBookings : 0;

  BloodBankBookingViewModel() {
    initSocketConnection();
  }

  void initSocketConnection() async {
    debugPrint("🚀 Initializing socket connection for blood bank bookings...");
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
        debugPrint('✅ Socket connected for blood bank bookings');
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

      // Add event listener for vendorBloodBankBookingUpdated
      _socket!.on('vendorBloodBankBookingUpdated', (data) async {
        debugPrint('🔄 Blood bank booking update received: $data');
        await _handleBloodBankBookingUpdate(data);
      });

      // Add ping/pong handlers
      _socket!.on('ping', (_) {
        _socket!.emit('pong');
      });

      // Connect to the socket
      _socket!.connect();
      debugPrint('🔄 Attempting to connect socket for blood bank bookings...');
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

  Future<void> _handleBloodBankBookingUpdate(dynamic data) async {
    try {
      debugPrint('🩸 Processing blood bank booking update: $data');
      
      // Parse the data if it's a string
      Map<String, dynamic> bookingData = data is String ? json.decode(data) : data;
      debugPrint('🩸 Parsed data: $bookingData');
      
      final bookingId = bookingData['bookingId'];
      final status = bookingData['status'];
      final paymentStatus = bookingData['paymentStatus'];
      final totalAmount = bookingData['totalAmount'];
      
      if (bookingId != null && status != null) {
        // Find and update the booking in the list
        final bookingIndex = _bookings.indexWhere((booking) => booking.bookingId == bookingId);
        
        if (bookingIndex != -1) {
          debugPrint('🩸 Found booking at index: $bookingIndex');
          
          // Update the booking with all received data
          _bookings[bookingIndex] = _bookings[bookingIndex].copyWith(
            status: status,
            paymentStatus: paymentStatus,
            totalAmount: totalAmount?.toDouble() ?? _bookings[bookingIndex].totalAmount,
          );
          
          // If payment is completed, refresh the bookings list
          if (status == "PaymentCompleted" && paymentStatus == "PAID") {
            debugPrint('✅ Payment completed, refreshing bookings...');
            // First notify listeners to update UI immediately
            if (mounted) {
              notifyListeners();
            }
            // Then fetch fresh data
            await loadBookings();
            // Notify again after fresh data
            if (mounted) {
              notifyListeners();
            }
          } else {
            // For other status updates, just notify listeners
            if (mounted) {
              notifyListeners();
            }
          }
          
          debugPrint('✅ Booking $bookingId status updated to: $status');
        } else {
          debugPrint('❌ Booking not found with ID: $bookingId');
          
          // If booking not found, refresh bookings
          await loadBookings();
          if (mounted) {
            notifyListeners();
          }
        }
      } else {
        debugPrint('❌ Missing bookingId or status in data: $bookingData');
      }
    } catch (e, stackTrace) {
      debugPrint('❌ Error handling blood bank booking update: $e');
      debugPrint('❌ Stack trace: $stackTrace');
      // Even if there's an error, try to refresh the data
      await loadBookings();
      if (mounted) {
        notifyListeners();
      }
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

  Future<void> loadBookings() async {
    String? token = await _loginService.getVendorToken();
    String? vendorId = await _loginService.getVendorId();

    try {
      _isLoading = true;
      _error = null;
      notifyListeners();

      _bookings = await _service.getBookings(vendorId!, token!);
    } catch (e) {
      _error = 'Failed to load bookings';
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<void> processBooking(String bookingId) async {
    String? token = await _loginService.getVendorToken();
    String? vendorId = await _loginService.getVendorId();

    try {
      _isLoading = true;
      _error = null;
      notifyListeners();

      await _service.updateBookingStatus(bookingId, 'completed', token!);
      await loadBookings(); // Reload the bookings to get updated data
    } catch (e) {
      _error = 'Failed to process booking';
      throw e;
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<void> notifyUser(
    String bookingId, {
    String? notes,
    double? totalAmount,
    double? discount,
    int? units,
    double? pricePerUnit,
    String? deliveryType,
  }) async {
    try {
      _isLoading = true;
      notifyListeners();

      final vendorToken = await _loginService.getVendorToken();
      if (vendorToken == null) {
        throw Exception('Vendor token not found');
      }

      await _service.notifyUser(
        bookingId,
        vendorToken,
        notes: notes,
        totalAmount: totalAmount,
        discount: discount,
        units: units,
        pricePerUnit: pricePerUnit,
        deliveryType: deliveryType,
      );

      // Reload bookings after notifying user
      await loadBookings();
    } catch (e) {
      _error = e.toString();
      notifyListeners();
      rethrow;
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<void> updateBookingStatus(String bookingId, String status) async {
    try {
      _isLoading = true;
      notifyListeners();

      final vendorToken = await _loginService.getVendorToken();
      if (vendorToken == null) {
        throw Exception('Vendor token not found');
      }

      if (status.toUpperCase() == 'COMPLETED') {
        // Use the new endpoint for completed status
        await _service.markBookingAsCompleted(bookingId, vendorToken);
      } else {
        // Use the existing endpoint for other statuses
        await _service.updateBookingStatus(bookingId, status, vendorToken);
      }

      // Reload bookings after updating status
      await loadBookings();
    } catch (e) {
      _error = e.toString();
      notifyListeners();
      rethrow;
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  // Get user details for a booking
  UserModel? getUserDetails(String bookingId) {
    try {
      final booking = _bookings.firstWhere((b) => b.bookingId == bookingId);
      return booking.user;
    } catch (e) {
      return null;
    }
  }

  // Get booking by ID
  BloodBankBooking? getBookingById(String bookingId) {
    try {
      return _bookings.firstWhere((b) => b.bookingId == bookingId);
    } catch (e) {
      return null;
    }
  }
  
  // Get blood request details for a booking
  Map<String, dynamic>? getBloodRequestDetailsForBooking(String bookingId) {
    try {
      final booking = _bookings.firstWhere((b) => b.bookingId == bookingId);
      if (booking.bloodRequest != null) {
        return {
          'bloodTypes': booking.bloodType,
          'units': booking.bloodRequest!.units,
        };
      }
      return null;
    } catch (e) {
      return null;
    }
  }
} 