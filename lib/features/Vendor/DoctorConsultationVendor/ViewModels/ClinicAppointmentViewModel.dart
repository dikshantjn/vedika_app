import 'package:flutter/foundation.dart';
import '../Models/ClinicAppointment.dart';
import '../Services/AppointmentService.dart';
import 'package:vedika_healthcare/core/auth/data/models/UserModel.dart';
import 'package:vedika_healthcare/features/Vendor/DoctorConsultationVendor/Models/DoctorClinicProfile.dart';

enum AppointmentFilter { upcoming, completed, cancelled, all }
enum AppointmentSortOrder { newest, oldest }

class ClinicAppointmentViewModel extends ChangeNotifier {
  final AppointmentService _appointmentService = AppointmentService();
  
  List<ClinicAppointment> _appointments = [];
  List<ClinicAppointment> _filteredAppointments = [];
  
  bool _isLoading = false;
  String? _errorMessage;
  AppointmentFilter _currentFilter = AppointmentFilter.all; // Changed to show all appointments by default
  AppointmentSortOrder _sortOrder = AppointmentSortOrder.newest;
  String _searchQuery = '';
  DateTime? _selectedDate;

  // Getters
  List<ClinicAppointment> get appointments => _filteredAppointments;
  bool get isLoading => _isLoading;
  String? get errorMessage => _errorMessage;
  AppointmentFilter get currentFilter => _currentFilter;
  AppointmentSortOrder get sortOrder => _sortOrder;
  String get searchQuery => _searchQuery;
  DateTime? get selectedDate => _selectedDate;

  // Initialize view model
  Future<void> initialize() async {
    await fetchAppointments();
  }

  // Fetch appointments from service
  Future<void> fetchAppointments() async {
    _setLoading(true);
    _errorMessage = null;
    
    try {
      // Use the appointmentService to fetch data
      _appointments = await _appointmentService.fetchAppointments();
      
      // Debug output to verify appointments are loaded
      print('Loaded ${_appointments.length} appointments');
      for (var appointment in _appointments) {
        print('  - ID: ${appointment.clinicAppointmentId}, isOnline: ${appointment.isOnline}, status: ${appointment.status}');
      }
      
      _applyFilters();
      _setLoading(false);
    } catch (e) {
      _setLoading(false);
      _errorMessage = 'Failed to load appointments: ${e.toString()}';
      print('Error loading appointments: $e');
      notifyListeners();
    }
  }

  // Apply filters to the appointments list
  void _applyFilters() {
    var filtered = List<ClinicAppointment>.from(_appointments);
    
    // Apply status filter
    if (_currentFilter != AppointmentFilter.all) {
      filtered = filtered.where((appointment) {
        switch (_currentFilter) {
          case AppointmentFilter.upcoming:
            return appointment.status == 'pending' || appointment.status == 'confirmed';
          case AppointmentFilter.completed:
            return appointment.status == 'completed';
          case AppointmentFilter.cancelled:
            return appointment.status == 'cancelled';
          default:
            return true;
        }
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
    // Debug output after filtering
    print('Filtered to ${_filteredAppointments.length} appointments');
    for (var appointment in _filteredAppointments) {
      print('  - ID: ${appointment.clinicAppointmentId}, isOnline: ${appointment.isOnline}');
    }
    
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
  Future<void> updateAppointmentStatus(String appointmentId, String newStatus) async {
    _setLoading(true);
    
    try {
      // Call API to update appointment status
      final success = await _appointmentService.updateAppointmentStatus(appointmentId, newStatus);
      
      if (success) {
        // Update local state - fetch fresh appointments instead of manual update
        await fetchAppointments();
      } else {
        _errorMessage = 'Failed to update appointment status';
        notifyListeners();
      }
      
      _setLoading(false);
    } catch (e) {
      _setLoading(false);
      _errorMessage = 'Failed to update appointment: ${e.toString()}';
      notifyListeners();
    }
  }
  
  // Generate meeting URL for online appointments
  Future<String?> generateMeetingUrl(String appointmentId) async {
    _setLoading(true);
    
    try {
      final meetingUrl = await _appointmentService.generateMeetingUrl(appointmentId);
      
      if (meetingUrl != null) {
        // Update local state - fetch fresh appointments
        await fetchAppointments();
      }
      
      _setLoading(false);
      return meetingUrl;
    } catch (e) {
      _setLoading(false);
      _errorMessage = 'Failed to generate meeting URL: ${e.toString()}';
      notifyListeners();
      return null;
    }
  }

  // Helper to set loading state
  void _setLoading(bool loading) {
    _isLoading = loading;
    notifyListeners();
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