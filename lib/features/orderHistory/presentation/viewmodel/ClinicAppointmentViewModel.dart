import 'package:flutter/material.dart';
import 'package:vedika_healthcare/core/auth/data/models/UserModel.dart';
import 'package:vedika_healthcare/core/auth/data/services/StorageService.dart';
import 'package:vedika_healthcare/features/Vendor/DoctorConsultationVendor/Models/ClinicAppointment.dart';
import 'package:vedika_healthcare/features/orderHistory/data/services/ClinicAppointmentOrderService.dart';
import 'package:vedika_healthcare/core/constants/ApiEndpoints.dart';
import 'package:socket_io_client/socket_io_client.dart' as IO;
import 'dart:convert';

enum ClinicAppointmentFetchState { initial, loading, loaded, error }

class ClinicAppointmentViewModel extends ChangeNotifier {
  final ClinicAppointmentOrderService _service = ClinicAppointmentOrderService();

  IO.Socket? _socket;
  bool _mounted = true;
  
  List<ClinicAppointment> _appointments = [];
  List<ClinicAppointment> get appointments => _appointments;
  
  String _errorMessage = '';
  String get errorMessage => _errorMessage;
  
  ClinicAppointmentFetchState _fetchState = ClinicAppointmentFetchState.initial;
  ClinicAppointmentFetchState get fetchState => _fetchState;
  
  bool _isActionInProgress = false;
  bool get isActionInProgress => _isActionInProgress;

  ClinicAppointmentViewModel() {
    // Initialize socket connection after a short delay to avoid build phase issues
    Future.delayed(Duration.zero, () {
      initSocketConnection();
    });
  }

  @override
  void dispose() {
    _mounted = false;
    if (_socket != null) {
      _socket!.disconnect();
      _socket!.dispose();
    }
    super.dispose();
  }

  // Helper method to safely notify listeners
  void _safeNotifyListeners() {
    if (_mounted) {
      Future.microtask(() {
        if (_mounted) {
          notifyListeners();
        }
      });
    }
  }

  void initSocketConnection() async {
    if (!_mounted) return;
    
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

      // Add event listener for ClinicAppointmentUpdate
      _socket!.on('ClinicAppointmentUpdate', (data) async {
        debugPrint('🔄 Clinic appointment update received: $data');
        await _handleAppointmentUpdate(data);
      });

      // Add ping/pong handlers
      _socket!.on('ping', (_) {
        _socket!.emit('pong');
      });

      // Connect to the socket
      _socket!.connect();
    } catch (e) {
      debugPrint("❌ Socket connection error: $e");
      _attemptReconnect();
    }
  }

  void _attemptReconnect() {
    if (!_mounted) return;
    
    Future.delayed(Duration(seconds: 2), () {
      if (_socket != null && !_socket!.connected && _mounted) {
        debugPrint('🔄 Attempting to reconnect...');
        _socket!.connect();
      }
    });
  }

  Future<void> _handleAppointmentUpdate(dynamic data) async {
    if (!_mounted) return;
    
    try {
      debugPrint('🏥 Processing clinic appointment update: $data');
      
      // Parse the data if it's a string
      Map<String, dynamic> appointmentData = data is String ? json.decode(data) : data;
      debugPrint('🏥 Parsed data: $appointmentData');
      
      final appointmentId = appointmentData['appointmentId'];
      final status = appointmentData['status'];
      
      debugPrint('🏥 Received update - ID: $appointmentId, Status: $status');
      
      if (appointmentId != null && status != null) {
        // Find and update the appointment in the list
        final appointmentIndex = _appointments.indexWhere((appointment) => 
          appointment.clinicAppointmentId == appointmentId);
        
        if (appointmentIndex != -1) {
          debugPrint('🏥 Found appointment at index: $appointmentIndex');
          
          // Update the appointment status
          _appointments[appointmentIndex] = _appointments[appointmentIndex].copyWith(
            status: status,
          );
          
          // For specific statuses, refresh the entire appointments list
          if (status == 'meetingUrlGenerated' || status == 'completed') {
            debugPrint('🔄 Refreshing appointments for status: $status');
            await _safeFetchAppointments();
          } else {
            _safeNotifyListeners();
          }
          
          debugPrint('✅ Appointment $appointmentId status updated to: $status');
        } else {
          debugPrint('❌ Appointment not found with ID: $appointmentId');
          
          // If appointment not found, refresh appointments
          await _safeFetchAppointments();
        }
      } else {
        debugPrint('❌ Missing appointmentId or status in data: $appointmentData');
      }
    } catch (e, stackTrace) {
      debugPrint('❌ Error handling clinic appointment update: $e');
      debugPrint('❌ Stack trace: $stackTrace');
      // Even if there's an error, try to refresh the data
      await _safeFetchAppointments();
    }
  }

  // Safe fetch appointments method
  Future<void> _safeFetchAppointments() async {
    if (!_mounted) return;
    
    try {
      final appointments = await _service.getUserClinicAppointments();
      if (_mounted) {
        _appointments = appointments;
        _fetchState = ClinicAppointmentFetchState.loaded;
        _safeNotifyListeners();
      }
    } catch (e) {
      if (_mounted) {
        _errorMessage = e.toString();
        _fetchState = ClinicAppointmentFetchState.error;
        _safeNotifyListeners();
      }
    }
  }
  
  // Filter appointments by status
  List<ClinicAppointment> getAppointmentsByStatus(String status) {
    return _appointments.where((appointment) => 
      appointment.status.toLowerCase() == status.toLowerCase()).toList();
  }
  
  // Get upcoming appointments (pending, confirmed)
  List<ClinicAppointment> get upcomingAppointments {
    return _appointments.where((appointment) => 
      appointment.status.toLowerCase() == 'pending' || 
      appointment.status.toLowerCase() == 'confirmed').toList();
  }
  
  // Get completed appointments
  List<ClinicAppointment> get completedAppointments {
    return _appointments.where((appointment) => 
      appointment.status.toLowerCase() == 'completed').toList();
  }
  
  // Get cancelled appointments
  List<ClinicAppointment> get cancelledAppointments {
    return _appointments.where((appointment) => 
      appointment.status.toLowerCase() == 'cancelled').toList();
  }
  
  // Fetch all clinic appointments for the current user
  Future<void> fetchUserClinicAppointments() async {
    if (_fetchState == ClinicAppointmentFetchState.loading || !_mounted) return;
    
    _fetchState = ClinicAppointmentFetchState.loading;
    _errorMessage = '';
    _safeNotifyListeners();
    
    await _safeFetchAppointments();
  }
  
  // Cancel a clinic appointment
  Future<bool> cancelAppointment(String appointmentId) async {
    if (_isActionInProgress) return false;
    
    _isActionInProgress = true;
    notifyListeners();
    
    try {
      final result = await _service.cancelClinicAppointment(appointmentId);
      
      if (result) {
        // Update local list after successful cancellation
        await fetchUserClinicAppointments();
        return true;
      }
      
      return false;
    } catch (e) {
      _errorMessage = e.toString();
      print('Error cancelling appointment: $e');
      return false;
    } finally {
      _isActionInProgress = false;
      notifyListeners();
    }
  }

  // Cancel an appointment with reason
  Future<Map<String, dynamic>> cancelAppointmentWithReason({
    required String appointmentId,
    required String cancelReason,
  }) async {
    if (_isActionInProgress) {
      return {
        'success': false,
        'message': 'Another action is in progress. Please wait.',
      };
    }
    
    _isActionInProgress = true;
    notifyListeners();
    
    try {
      print('[ClinicAppointmentViewModel] Cancelling appointment with reason: ID=$appointmentId, reason=$cancelReason');
      
      final result = await _service.cancelAppointmentWithReason(
        appointmentId: appointmentId,
        cancelReason: cancelReason,
      );
      
      if (result['success']) {
        print('[ClinicAppointmentViewModel] Success - refreshing appointments...');
        // Update local list after successful cancellation
        await fetchUserClinicAppointments();
        return {
          'success': true,
          'message': result['message'],
        };
      } else {
        print('[ClinicAppointmentViewModel] Failed - setting error message');
        return {
          'success': false,
          'message': result['message'],
        };
      }
    } catch (e) {
      print('[ClinicAppointmentViewModel] Exception occurred: $e');
      return {
        'success': false,
        'message': 'Failed to cancel appointment: ${e.toString()}',
      };
    } finally {
      _isActionInProgress = false;
      notifyListeners();
    }
  }

  // Reschedule a clinic appointment
  Future<Map<String, dynamic>> rescheduleAppointment({
    required String appointmentId,
    required String date,
    required String time,
  }) async {
    if (_isActionInProgress) {
      return {
        'success': false,
        'message': 'Another action is in progress. Please wait.',
      };
    }
    
    _isActionInProgress = true;
    notifyListeners();
    
    try {
      final result = await _service.rescheduleClinicAppointment(
        appointmentId: appointmentId,
        date: date,
        time: time,
      );
      
      if (result['success']) {
        // Update local list after successful rescheduling
        await fetchUserClinicAppointments();
      }
      
      return result;
    } catch (e) {
      _errorMessage = e.toString();
      print('Error rescheduling appointment: $e');
      return {
        'success': false,
        'message': 'Error rescheduling appointment: $e',
      };
    } finally {
      _isActionInProgress = false;
      notifyListeners();
    }
  }

  // Update appointment attendance status
  Future<Map<String, dynamic>> updateAppointmentAttendance({
    required String appointmentId,
    required String status, // "no_call" or "no_show"
  }) async {
    if (_isActionInProgress) {
      return {
        'success': false,
        'message': 'Another action is in progress. Please wait.',
      };
    }
    
    _isActionInProgress = true;
    notifyListeners();
    
    try {
      final result = await _service.updateAppointmentAttendance(
        appointmentId: appointmentId,
        status: status,
      );
      
      if (result['success']) {
        // Update local list after successful attendance update
        await fetchUserClinicAppointments();
      }
      
      return result;
    } catch (e) {
      _errorMessage = e.toString();
      print('Error updating attendance: $e');
      return {
        'success': false,
        'message': 'Error updating attendance: $e',
      };
    } finally {
      _isActionInProgress = false;
      notifyListeners();
    }
  }
  
  // Refresh appointments data
  Future<void> refreshAppointments() async {
    return fetchUserClinicAppointments();
  }
  
  // Get current user from appointments (if available)
  UserModel? getCurrentUser() {
    if (_appointments.isNotEmpty && _appointments.first.user != null) {
      return _appointments.first.user;
    }
    return null;
  }
} 