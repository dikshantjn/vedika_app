import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:intl/intl.dart';
import 'package:socket_io_client/socket_io_client.dart' as IO;
import 'package:vedika_healthcare/core/auth/data/services/StorageService.dart';
import 'package:vedika_healthcare/core/constants/ApiEndpoints.dart';
import 'package:vedika_healthcare/features/clinic/data/services/ClinicService.dart';

class BookClinicAppointmentViewModel extends ChangeNotifier {
  final ClinicService _clinicService = ClinicService();

  // State
  bool _isLoading = false;
  String? _error;
  TimeSlotsResponse? _timeSlotsResponse;
  String? _selectedTimeSlot;
  IO.Socket? _socket;
  bool _mounted = true;
  bool _needsTimeSlotRefresh = false;
  bool _noSlotsAvailable = false;
  String? _currentUserId;

  BookClinicAppointmentViewModel() {
    _initializeCurrentUserId();
    initSocketConnection();
  }

  Future<void> _initializeCurrentUserId() async {
    _currentUserId = await StorageService.getUserId();
  }

  // Getters
  bool get isLoading => _isLoading;
  String? get error => _error;
  TimeSlotsResponse? get timeSlotsResponse => _timeSlotsResponse;
  String? get selectedTimeSlot => _selectedTimeSlot;
  bool get needsTimeSlotRefresh => _needsTimeSlotRefresh;
  bool get noSlotsAvailable => _noSlotsAvailable;
  String? get currentUserId => _currentUserId;

  // Get all time slots (available + booked) sorted
  List<String> get allTimeSlots {
    if (_timeSlotsResponse == null) return [];

    final allSlots = [
      ..._timeSlotsResponse!.availableSlots,
      ..._timeSlotsResponse!.bookedSlots.map((bookedSlot) => bookedSlot.time),
    ];

    // Sort time slots chronologically
    allSlots.sort((a, b) => _compareTimeSlots(a, b));
    return allSlots;
  }

  // Check if a time slot is booked
  bool isTimeSlotBooked(String timeSlot) {
    return _timeSlotsResponse?.bookedSlots.any((bookedSlot) => bookedSlot.time == timeSlot) ?? false;
  }

  // Check if a time slot is available
  bool isTimeSlotAvailable(String timeSlot) {
    return _timeSlotsResponse?.availableSlots.contains(timeSlot) ?? false;
  }

  // Check if a booked time slot belongs to the current user
  bool isTimeSlotBookedByCurrentUser(String timeSlot) {
    if (_timeSlotsResponse == null || _currentUserId == null) return false;
    return _timeSlotsResponse!.bookedSlots.any((bookedSlot) =>
        bookedSlot.time == timeSlot && bookedSlot.userId == _currentUserId);
  }

  // Check if a booked time slot belongs to another user
  bool isTimeSlotBookedByOtherUser(String timeSlot) {
    if (_timeSlotsResponse == null || _currentUserId == null) return false;
    return _timeSlotsResponse!.bookedSlots.any((bookedSlot) =>
        bookedSlot.time == timeSlot && bookedSlot.userId != _currentUserId);
  }

  // Compare time slots for sorting
  int _compareTimeSlots(String a, String b) {
    try {
      final timeA = DateFormat('HH:mm').parse(a);
      final timeB = DateFormat('HH:mm').parse(b);
      return timeA.compareTo(timeB);
    } catch (e) {
      // Fallback to string comparison if parsing fails
      return a.compareTo(b);
    }
  }

  // Socket Management
  void initSocketConnection() async {
    debugPrint("🚀 Initializing socket connection for clinic appointments...");
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
        debugPrint('✅ Socket connected for clinic appointments');
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

      // Listen for clinic appointment updates
      _socket!.on('ClinicAppointmentUpdate', (data) async {
        debugPrint('🏥 Clinic appointment update received: $data');
        await _handleClinicAppointmentUpdate(data);
      });

      // Add ping/pong handlers
      _socket!.on('ping', (_) {
        _socket!.emit('pong');
      });

      // Connect to the socket
      _socket!.connect();
      debugPrint('🔄 Attempting to connect socket for clinic appointments...');
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

  Future<void> _handleClinicAppointmentUpdate(dynamic data) async {
    try {
      debugPrint('🏥 Processing clinic appointment update: $data');

      // Parse the data if it's a string
      Map<String, dynamic> appointmentData = data is String ? json.decode(data) : data;
      debugPrint('🏥 Parsed data: $appointmentData');

      final appointmentId = appointmentData['appointmentId'];
      final date = appointmentData['date'];
      final time = appointmentData['time'];
      final status = appointmentData['status'];

      if (appointmentId != null && date != null) {
        debugPrint('🏥 Appointment $appointmentId updated to status: $status');

        // Set flag to indicate that time slots need to be refreshed
        _needsTimeSlotRefresh = true;
        debugPrint('🏥 Time slots refresh needed due to appointment update');

        // Notify listeners to trigger UI update
        notifyListeners();
      } else {
        debugPrint('🏥 Missing appointmentId or date in data: $appointmentData');
      }
    } catch (e, stackTrace) {
      debugPrint('❌ Error handling clinic appointment update: $e');
      debugPrint('❌ Stack trace: $stackTrace');
    }
  }

  // Public method to refresh current time slots
  Future<void> refreshTimeSlots() async {
    if (_timeSlotsResponse != null && !_isLoading) {
      debugPrint('🏥 Refreshing time slots...');
      await _refreshCurrentTimeSlots();
    }
  }

  // Internal method to refresh current time slots
  Future<void> _refreshCurrentTimeSlots() async {
    // We don't have direct access to vendorId and date here, so we'll just notify listeners
    // The UI should handle refreshing the time slots when it receives the notification
    notifyListeners();
  }

  // Actions
  void selectTimeSlot(String timeSlot) {
    if (isTimeSlotAvailable(timeSlot)) {
      _selectedTimeSlot = timeSlot;
      notifyListeners();
    }
  }

  void clearSelectedTimeSlot() {
    _selectedTimeSlot = null;
    notifyListeners();
  }

  // Clear selected time slot after successful booking (without notifying)
  void clearAfterBooking() {
    _selectedTimeSlot = null;
    // Don't notify listeners as time slots will be refreshed
  }

  // Load time slots for a specific date and vendor
  Future<void> loadTimeSlots({
    required String vendorId,
    required DateTime date,
  }) async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      final dateString = DateFormat('yyyy-MM-dd').format(date);
      _timeSlotsResponse = await _clinicService.getTimeSlotsByVendorAndDate(
        vendorId: vendorId,
        date: dateString,
      );

      // Clear selected time slot only if it's booked by someone else
      if (_selectedTimeSlot != null && isTimeSlotBookedByOtherUser(_selectedTimeSlot!)) {
        _selectedTimeSlot = null;
      }

      // Clear the refresh flag and no slots flag since we have data
      _needsTimeSlotRefresh = false;
      _noSlotsAvailable = false;

    } catch (e) {
      final errorMessage = e.toString();

      // Check if it's a 404 error (no slots available for this date)
      if (errorMessage.contains('404')) {
        debugPrint('🏥 No time slots available for this date (404)');
        _timeSlotsResponse = null;
        _noSlotsAvailable = true;
        _error = null; // Clear error since this is expected behavior
      } else {
        // For other errors, set the error message
        _error = errorMessage;
        _timeSlotsResponse = null;
        _noSlotsAvailable = false;
      }
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  // Clear all data
  void clearData() {
    _timeSlotsResponse = null;
    _selectedTimeSlot = null;
    _error = null;
    _isLoading = false;
    _needsTimeSlotRefresh = false;
    _noSlotsAvailable = false;
    // Don't clear _currentUserId as it's set once and doesn't change
    notifyListeners();
  }

  // Clear refresh flag
  void clearRefreshFlag() {
    _needsTimeSlotRefresh = false;
  }

  @override
  void dispose() {
    _mounted = false; // Mark as disposed
    if (_socket != null) {
      _socket!.disconnect();
      _socket!.dispose();
    }
    super.dispose();
  }

  // Check if form is complete for appointment booking
  bool get isFormComplete {
    return _selectedTimeSlot != null && isTimeSlotAvailable(_selectedTimeSlot!);
  }
}
