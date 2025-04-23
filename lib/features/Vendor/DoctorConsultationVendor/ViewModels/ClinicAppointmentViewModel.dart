import 'package:flutter/foundation.dart';
import '../Models/ClinicAppointment.dart';
import '../Services/AppointmentService.dart';
import 'package:vedika_healthcare/core/auth/data/models/UserModel.dart';
import 'package:vedika_healthcare/features/Vendor/DoctorConsultationVendor/Models/DoctorClinicProfile.dart';

enum AppointmentFilter { upcoming, completed, cancelled, all }
enum AppointmentSortOrder { newest, oldest }
enum ClinicAppointmentFetchState { initial, loading, loaded, error }

class ClinicAppointmentViewModel extends ChangeNotifier {
  final AppointmentService _appointmentService = AppointmentService();
  
  List<ClinicAppointment> _appointments = [];
  List<ClinicAppointment> _filteredAppointments = [];
  
  ClinicAppointmentFetchState _fetchState = ClinicAppointmentFetchState.initial;
  String? _errorMessage;
  AppointmentFilter _currentFilter = AppointmentFilter.all; // Changed to show all appointments by default
  AppointmentSortOrder _sortOrder = AppointmentSortOrder.newest;
  String _searchQuery = '';
  DateTime? _selectedDate;

  // Getters
  List<ClinicAppointment> get appointments => _filteredAppointments;
  ClinicAppointmentFetchState get fetchState => _fetchState;
  String get errorMessage => _errorMessage ?? '';
  AppointmentFilter get currentFilter => _currentFilter;
  AppointmentSortOrder get sortOrder => _sortOrder;
  String get searchQuery => _searchQuery;
  DateTime? get selectedDate => _selectedDate;

  // Initialize view model
  Future<void> initialize() async {
    print('[ClinicAppointmentViewModel] Initializing...');
    await fetchUserClinicAppointments();
  }

  // Fetch appointments from service
  Future<void> fetchUserClinicAppointments() async {
    print('[ClinicAppointmentViewModel] fetchUserClinicAppointments() called');
    _fetchState = ClinicAppointmentFetchState.loading;
    _errorMessage = null;
    notifyListeners();
    
    try {
      // Use the appointmentService to fetch data
      print('[ClinicAppointmentViewModel] Calling appointmentService.fetchPendingAppointments()');
      _appointments = await _appointmentService.fetchPendingAppointments();
      
      // Debug output to verify appointments are loaded
      print('[ClinicAppointmentViewModel] Loaded ${_appointments.length} appointments from service');
      for (var appointment in _appointments) {
        print('[ClinicAppointmentViewModel] - ID: ${appointment.clinicAppointmentId}, isOnline: ${appointment.isOnline}, status: ${appointment.status}');
      }
      
      _applyFilters();
      _fetchState = ClinicAppointmentFetchState.loaded;
      notifyListeners();
    } catch (e) {
      print('[ClinicAppointmentViewModel] Error in fetchUserClinicAppointments: $e');
      _fetchState = ClinicAppointmentFetchState.error;
      _errorMessage = 'Failed to load appointments: ${e.toString()}';
      print('[ClinicAppointmentViewModel] Error loading appointments: $e');
      notifyListeners();
    }
  }

  // Apply filters to the appointments list
  void _applyFilters() {
    print('[ClinicAppointmentViewModel] _applyFilters() called');
    print('[ClinicAppointmentViewModel] Current filter: $_currentFilter');
    print('[ClinicAppointmentViewModel] Before filtering: ${_appointments.length} appointments');
    
    var filtered = List<ClinicAppointment>.from(_appointments);
    
    // Apply status filter
    if (_currentFilter != AppointmentFilter.all) {
      print('[ClinicAppointmentViewModel] Applying status filter: $_currentFilter');
      filtered = filtered.where((appointment) {
        final bool shouldInclude = switch (_currentFilter) {
          AppointmentFilter.upcoming => appointment.status == 'pending' || appointment.status == 'confirmed',
          AppointmentFilter.completed => appointment.status == 'completed',
          AppointmentFilter.cancelled => appointment.status == 'cancelled',
          AppointmentFilter.all => true,
        };
        
        print('[ClinicAppointmentViewModel] - ID: ${appointment.clinicAppointmentId}, status: ${appointment.status}, include: $shouldInclude');
        return shouldInclude;
      }).toList();
    }
    
    // Apply date filter
    if (_selectedDate != null) {
      print('[ClinicAppointmentViewModel] Applying date filter: $_selectedDate');
      filtered = filtered.where((appointment) {
        final bool matchesDate = appointment.date.year == _selectedDate!.year &&
               appointment.date.month == _selectedDate!.month &&
               appointment.date.day == _selectedDate!.day;
               
        print('[ClinicAppointmentViewModel] - ID: ${appointment.clinicAppointmentId}, date: ${appointment.date}, matches: $matchesDate');
        return matchesDate;
      }).toList();
    }
    
    // Apply search query
    if (_searchQuery.isNotEmpty) {
      print('[ClinicAppointmentViewModel] Applying search query: $_searchQuery');
      final query = _searchQuery.toLowerCase();
      filtered = filtered.where((appointment) {
        final patientName = appointment.user?.name?.toLowerCase() ?? '';
        final patientId = appointment.userId.toLowerCase();
        final appointmentId = appointment.clinicAppointmentId.toLowerCase();
        
        final bool matchesSearch = patientName.contains(query) || 
               patientId.contains(query) || 
               appointmentId.contains(query);
               
        print('[ClinicAppointmentViewModel] - ID: ${appointment.clinicAppointmentId}, patient: ${appointment.user?.name}, matches: $matchesSearch');
        return matchesSearch;
      }).toList();
    }
    
    // Apply sorting
    print('[ClinicAppointmentViewModel] Applying sorting: $_sortOrder');
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
    // Debug output after filtering
    print('[ClinicAppointmentViewModel] After filtering: ${_filteredAppointments.length} appointments');
    print('[ClinicAppointmentViewModel] Filtered appointments breakdown:');
    int onlineCount = 0;
    int offlineCount = 0;
    
    for (var appointment in _filteredAppointments) {
      if (appointment.isOnline) {
        onlineCount++;
      } else {
        offlineCount++;
      }
      print('[ClinicAppointmentViewModel] - ID: ${appointment.clinicAppointmentId}, isOnline: ${appointment.isOnline}, status: ${appointment.status}');
    }
    
    print('[ClinicAppointmentViewModel] Online appointments: $onlineCount, Offline appointments: $offlineCount');
    
    notifyListeners();
  }

  // Set filter
  void setFilter(AppointmentFilter filter) {
    print('[ClinicAppointmentViewModel] setFilter() called with: $filter (previous: $_currentFilter)');
    if (_currentFilter != filter) {
      _currentFilter = filter;
      _applyFilters();
    }
  }

  // Set sort order
  void setSortOrder(AppointmentSortOrder order) {
    print('[ClinicAppointmentViewModel] setSortOrder() called with: $order (previous: $_sortOrder)');
    if (_sortOrder != order) {
      _sortOrder = order;
      _applyFilters();
    }
  }

  // Set search query
  void setSearchQuery(String query) {
    print('[ClinicAppointmentViewModel] setSearchQuery() called with: $query');
    _searchQuery = query;
    _applyFilters();
  }

  // Set selected date
  void setSelectedDate(DateTime? date) {
    print('[ClinicAppointmentViewModel] setSelectedDate() called with: $date');
    _selectedDate = date;
    _applyFilters();
  }

  // Clear date filter
  void clearDateFilter() {
    print('[ClinicAppointmentViewModel] clearDateFilter() called');
    _selectedDate = null;
    _applyFilters();
  }

  // Update appointment status
  Future<bool> updateAppointmentStatus(String appointmentId, String newStatus) async {
    print('[ClinicAppointmentViewModel] updateAppointmentStatus() called with ID: $appointmentId, status: $newStatus');
    _fetchState = ClinicAppointmentFetchState.loading;
    notifyListeners();
    
    try {
      // Call API to update appointment status
      final success = await _appointmentService.updateAppointmentStatus(appointmentId, newStatus);
      
      if (success) {
        print('[ClinicAppointmentViewModel] Status updated successfully, refreshing appointments');
        // Update local state - fetch fresh appointments instead of manual update
        await fetchUserClinicAppointments();
      } else {
        print('[ClinicAppointmentViewModel] Failed to update status');
        _errorMessage = 'Failed to update appointment status';
        notifyListeners();
      }
      
      _fetchState = ClinicAppointmentFetchState.loaded;
      notifyListeners();
      return success;
    } catch (e) {
      print('[ClinicAppointmentViewModel] Error updating status: $e');
      _fetchState = ClinicAppointmentFetchState.error;
      _errorMessage = 'Failed to update appointment: ${e.toString()}';
      notifyListeners();
      return false;
    }
  }
  
  // Cancel an appointment
  Future<bool> cancelAppointment(String appointmentId) async {
    print('[ClinicAppointmentViewModel] cancelAppointment() called with ID: $appointmentId');
    return await updateAppointmentStatus(appointmentId, 'cancelled');
  }
  
  // Generate meeting URL for online appointments
  Future<String?> generateMeetingUrl(String appointmentId) async {
    print('[ClinicAppointmentViewModel] generateMeetingUrl() called with ID: $appointmentId');
    try {
      final meetingUrl = await _appointmentService.generateMeetingUrl(appointmentId);
      
      if (meetingUrl != null) {
        print('[ClinicAppointmentViewModel] Meeting URL generated successfully: $meetingUrl');
        // Update local state - fetch fresh appointments
        await fetchUserClinicAppointments();
      } else {
        print('[ClinicAppointmentViewModel] Failed to generate meeting URL');
      }
      
      return meetingUrl;
    } catch (e) {
      print('[ClinicAppointmentViewModel] Error generating meeting URL: $e');
      _errorMessage = 'Failed to generate meeting URL: ${e.toString()}';
      notifyListeners();
      return null;
    }
  }

  // Refresh appointments
  Future<void> refreshAppointments() async {
    print('[ClinicAppointmentViewModel] refreshAppointments() called');
    await fetchUserClinicAppointments();
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