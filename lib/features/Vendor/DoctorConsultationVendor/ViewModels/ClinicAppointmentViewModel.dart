import 'package:flutter/foundation.dart';
import 'package:vedika_healthcare/features/Vendor/Registration/Services/VendorLoginService.dart';
import '../Models/ClinicAppointment.dart';
import '../Services/AppointmentService.dart';
import 'package:vedika_healthcare/core/auth/data/models/UserModel.dart';
import 'package:vedika_healthcare/features/Vendor/DoctorConsultationVendor/Models/DoctorClinicProfile.dart';
import 'package:vedika_healthcare/features/Vendor/DoctorConsultationVendor/Services/DoctorClinicService.dart';
import 'package:flutter/material.dart';
import 'package:vedika_healthcare/core/constants/colorpalette/DoctorConsultationColorPalette.dart';
import 'package:vedika_healthcare/core/constants/ApiEndpoints.dart';
import 'package:socket_io_client/socket_io_client.dart' as IO;
import 'dart:convert';

enum AppointmentFilter { upcoming, completed, cancelled, all }
enum AppointmentSortOrder { newest, oldest }
enum ClinicAppointmentFetchState { initial, loading, loaded, error }

class ClinicAppointmentViewModel extends ChangeNotifier {
  final AppointmentService _appointmentService = AppointmentService();
  final DoctorClinicService _doctorClinicService = DoctorClinicService();
  IO.Socket? _socket;
  bool mounted = true;
  
  List<ClinicAppointment> _appointments = [];
  List<ClinicAppointment> _filteredAppointments = [];
  DoctorClinicProfile? _doctorProfile;
  
  ClinicAppointmentFetchState _fetchState = ClinicAppointmentFetchState.initial;
  String? _errorMessage;
  AppointmentFilter _currentFilter = AppointmentFilter.all;
  AppointmentSortOrder _sortOrder = AppointmentSortOrder.newest;
  String _searchQuery = '';
  DateTime? _selectedDate;

  // Health records state
  Map<String, dynamic>? _healthRecords;
  bool _isLoadingHealthRecords = false;

  // Getters
  List<ClinicAppointment> get appointments => _filteredAppointments;
  ClinicAppointmentFetchState get fetchState => _fetchState;
  String get errorMessage => _errorMessage ?? '';
  AppointmentFilter get currentFilter => _currentFilter;
  AppointmentSortOrder get sortOrder => _sortOrder;
  String get searchQuery => _searchQuery;
  DateTime? get selectedDate => _selectedDate;
  DoctorClinicProfile? get doctorProfile => _doctorProfile;
  Map<String, dynamic>? get healthRecords => _healthRecords;
  bool get isLoadingHealthRecords => _isLoadingHealthRecords;

  ClinicAppointmentViewModel() {
    initSocketConnection();
  }

  void initSocketConnection() async {
    debugPrint("🚀 Initializing socket connection for clinic appointments...");
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
        debugPrint('✅ Socket connected for clinic appointments');
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

  Future<void> _handleAppointmentUpdate(dynamic data) async {
    try {
      debugPrint('🏥 Processing clinic appointment update: $data');
      
      // Parse the data if it's a string
      Map<String, dynamic> appointmentData = data is String ? json.decode(data) : data;
      debugPrint('🏥 Parsed data: $appointmentData');
      
      final appointmentId = appointmentData['appointmentId'];
      final status = appointmentData['status'];
      
      if (appointmentId != null && status != null) {
        // Refresh appointments list for any status update
        await fetchUserClinicAppointments();
        debugPrint('✅ Refreshed appointments after update');
      } else {
        debugPrint('❌ Missing appointmentId or status in data: $appointmentData');
      }
    } catch (e, stackTrace) {
      debugPrint('❌ Error handling clinic appointment update: $e');
      debugPrint('❌ Stack trace: $stackTrace');
    }
  }

  // Initialize view model
  Future<void> initialize() async {
    print('[ClinicAppointmentViewModel] Initializing...');
    await fetchDoctorProfile();
    await fetchUserClinicAppointments();
  }

  // Fetch doctor profile information
  Future<void> fetchDoctorProfile() async {
    try {
      String? vendorId = await VendorLoginService().getVendorId();
      _doctorProfile = await _doctorClinicService.getCurrentDoctorProfile();
      notifyListeners();
    } catch (e) {
      print('[ClinicAppointmentViewModel] Error fetching doctor profile: $e');
    }
  }

  // Fetch appointments from service
  Future<void> fetchUserClinicAppointments() async {
    print('[ClinicAppointmentViewModel] fetchUserClinicAppointments() called');
    _fetchState = ClinicAppointmentFetchState.loading;
    _errorMessage = null;
    notifyListeners();
    
    try {
      _appointments = await _appointmentService.fetchPendingAppointments();
      _applyFilters();
      _fetchState = ClinicAppointmentFetchState.loaded;
      notifyListeners();
    } catch (e) {
      print('[ClinicAppointmentViewModel] Error in fetchUserClinicAppointments: $e');
      _fetchState = ClinicAppointmentFetchState.error;
      _errorMessage = 'Failed to load appointments: ${e.toString()}';
      notifyListeners();
    }
  }

  // Apply filters to the appointments list
  void _applyFilters() {
    var filtered = List<ClinicAppointment>.from(_appointments);
    
    // Apply status filter
    if (_currentFilter != AppointmentFilter.all) {
      filtered = filtered.where((appointment) {
        return switch (_currentFilter) {
          AppointmentFilter.upcoming => appointment.status == 'pending' || appointment.status == 'confirmed',
          AppointmentFilter.completed => appointment.status == 'completed',
          AppointmentFilter.cancelled => appointment.status == 'cancelled',
          AppointmentFilter.all => true,
        };
      }).toList();
    }
    
    // Apply date filter
    if (_selectedDate != null) {
      filtered = filtered.where((appointment) {
        return appointment.date.year == _selectedDate!.year &&
               appointment.date.month == _selectedDate!.month &&
               appointment.date.day == _selectedDate!.day;
      }).toList();
    }
    
    // Apply search query
    if (_searchQuery.isNotEmpty) {
      final query = _searchQuery.toLowerCase();
      filtered = filtered.where((appointment) {
        final patientName = appointment.user?.name?.toLowerCase() ?? '';
        final patientId = appointment.userId.toLowerCase();
        final appointmentId = appointment.clinicAppointmentId.toLowerCase();
        
        return patientName.contains(query) || 
               patientId.contains(query) || 
               appointmentId.contains(query);
      }).toList();
    }
    
    // Apply sorting
    filtered.sort((a, b) {
      final dateA = DateTime(
        a.date.year, 
        a.date.month, 
        a.date.day,
        int.parse(a.time.split(':')[0]),
        int.parse(a.time.split(':')[1]),
      );
      
      final dateB = DateTime(
        b.date.year, 
        b.date.month, 
        b.date.day,
        int.parse(b.time.split(':')[0]),
        int.parse(b.time.split(':')[1]),
      );
      
      return _sortOrder == AppointmentSortOrder.newest
          ? dateB.compareTo(dateA)
          : dateA.compareTo(dateB);
    });
    
    _filteredAppointments = filtered;
    notifyListeners();
  }

  // Set filter
  void setFilter(AppointmentFilter filter) {
    if (_currentFilter != filter) {
      _currentFilter = filter;
      _applyFilters();
    }
  }

  // Set sort order
  void setSortOrder(AppointmentSortOrder order) {
    if (_sortOrder != order) {
      _sortOrder = order;
      _applyFilters();
    }
  }

  // Set search query
  void setSearchQuery(String query) {
    _searchQuery = query;
    _applyFilters();
  }

  // Set selected date
  void setSelectedDate(DateTime? date) {
    _selectedDate = date;
    _applyFilters();
  }

  // Clear date filter
  void clearDateFilter() {
    _selectedDate = null;
    _applyFilters();
  }

  // Update appointment status
  Future<bool> updateAppointmentStatus(String appointmentId, String newStatus) async {
    _fetchState = ClinicAppointmentFetchState.loading;
    notifyListeners();
    
    try {
      final success = await _appointmentService.updateAppointmentStatus(appointmentId, newStatus);
      
      if (success) {
        await fetchUserClinicAppointments();
      } else {
        _errorMessage = 'Failed to update appointment status';
        notifyListeners();
      }
      
      _fetchState = ClinicAppointmentFetchState.loaded;
      notifyListeners();
      return success;
    } catch (e) {
      _fetchState = ClinicAppointmentFetchState.error;
      _errorMessage = 'Failed to update appointment: ${e.toString()}';
      notifyListeners();
      return false;
    }
  }
  
  // Cancel an appointment
  Future<bool> cancelAppointment(String appointmentId) async {
    return await updateAppointmentStatus(appointmentId, 'cancelled');
  }
  
  // Generate meeting URL for online appointments
  Future<String?> generateMeetingUrl(String appointmentId) async {
    try {
      return await _appointmentService.generateMeetingUrl(appointmentId);
    } catch (e) {
      _errorMessage = 'Failed to generate meeting URL: ${e.toString()}';
      notifyListeners();
      return null;
    }
  }

  // Launch meeting
  Future<String?> launchMeetingLink(String appointmentId) async {
    try {
      // Generate meeting URL
      final meetingUrl = await generateMeetingUrl(appointmentId);
      return meetingUrl;
    } catch (e) {
      debugPrint('Error generating meeting URL: $e');
      return null;
    }
  }

  // Mark appointment as completed after meeting ends
  Future<bool> completeAppointmentAfterMeeting(String appointmentId) async {
    try {
      final success = await _appointmentService.completeAppointmentAfterMeeting(appointmentId);
      
      if (success) {
        await fetchUserClinicAppointments();
      } else {
        _errorMessage = 'Failed to mark appointment as completed';
        notifyListeners();
      }
      
      return success;
    } catch (e) {
      _errorMessage = 'Error marking appointment as completed: ${e.toString()}';
      notifyListeners();
      return false;
    }
  }

  // Refresh appointments
  Future<void> refreshAppointments() async {
    await fetchUserClinicAppointments();
  }

  void showSnackBar(BuildContext context, String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(message)),
    );
  }

  // Fetch health records for an appointment
  Future<Map<String, dynamic>?> fetchHealthRecords(String appointmentId) async {
    _isLoadingHealthRecords = true;
    notifyListeners();

    try {
      final records = await _doctorClinicService.getHealthRecordsByAppointmentId(appointmentId);
      _healthRecords = records;
      _isLoadingHealthRecords = false;
      notifyListeners();
      return records;
    } catch (e) {
      _errorMessage = 'Failed to fetch health records: ${e.toString()}';
      _isLoadingHealthRecords = false;
      notifyListeners();
      return null;
    }
  }

  // Clear health records
  void clearHealthRecords() {
    _healthRecords = null;
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

// Extension for creating copies of ClinicAppointment
extension ClinicAppointmentExtension on ClinicAppointment {
  ClinicAppointment copyWith({
    String? clinicAppointmentId,
    String? userId,
    String? doctorId,
    String? vendorId,
    DateTime? date,
    String? time,
    String? status,
    String? paymentStatus,
    DateTime? adminUpdatedAt,
    String? userResponseStatus,
    double? paidAmount,
    bool? isOnline,
    String? meetingUrl,
    UserModel? user,
    DoctorClinicProfile? doctor,
  }) {
    return ClinicAppointment(
      clinicAppointmentId: clinicAppointmentId ?? this.clinicAppointmentId,
      userId: userId ?? this.userId,
      doctorId: doctorId ?? this.doctorId,
      vendorId: vendorId ?? this.vendorId,
      date: date ?? this.date,
      time: time ?? this.time,
      status: status ?? this.status,
      paymentStatus: paymentStatus ?? this.paymentStatus,
      adminUpdatedAt: adminUpdatedAt ?? this.adminUpdatedAt,
      userResponseStatus: userResponseStatus ?? this.userResponseStatus,
      paidAmount: paidAmount ?? this.paidAmount,
      isOnline: isOnline ?? this.isOnline,
      meetingUrl: meetingUrl ?? this.meetingUrl,
      user: user ?? this.user,
      doctor: doctor ?? this.doctor,
    );
  }
} 
