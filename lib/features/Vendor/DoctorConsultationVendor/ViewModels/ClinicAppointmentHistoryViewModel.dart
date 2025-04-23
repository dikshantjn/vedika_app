import 'package:flutter/foundation.dart';
import 'package:intl/intl.dart';
import '../Models/ClinicAppointment.dart';
import '../Services/AppointmentService.dart';
import 'package:flutter/material.dart';

enum HistorySortOrder { newest, oldest, highestPaid, lowestPaid }
enum HistoryFilter { all, online, inPerson, lastWeek, lastMonth, lastYear }
enum HistoryFetchState { initial, loading, loaded, error }

class ClinicAppointmentHistoryViewModel extends ChangeNotifier {
  final AppointmentService _appointmentService = AppointmentService();
  
  List<ClinicAppointment> _allCompletedAppointments = [];
  List<ClinicAppointment> _filteredAppointments = [];
  DateTime? _startDate;
  DateTime? _endDate;
  String _searchQuery = '';
  HistoryFetchState _fetchState = HistoryFetchState.initial;
  String? _errorMessage;
  HistorySortOrder _sortOrder = HistorySortOrder.newest;
  HistoryFilter _currentFilter = HistoryFilter.all;
  
  // Getters
  List<ClinicAppointment> get appointments => _filteredAppointments;
  bool get isLoading => _fetchState == HistoryFetchState.loading;
  String? get errorMessage => _errorMessage;
  HistoryFetchState get fetchState => _fetchState;
  HistorySortOrder get sortOrder => _sortOrder;
  HistoryFilter get currentFilter => _currentFilter;
  DateTime? get startDate => _startDate;
  DateTime? get endDate => _endDate;
  String get searchQuery => _searchQuery;
  
  // Stats
  double get totalRevenue => _filteredAppointments.fold(0, (sum, appointment) => sum + appointment.paidAmount);
  int get totalAppointments => _filteredAppointments.length;
  int get onlineAppointments => _filteredAppointments.where((appointment) => appointment.isOnline).length;
  int get inPersonAppointments => _filteredAppointments.where((appointment) => !appointment.isOnline).length;
  
  // Initialize
  Future<void> initialize() async {
    await fetchCompletedAppointments();
  }
  
  // Fetch completed appointments
  Future<void> fetchCompletedAppointments() async {
    _fetchState = HistoryFetchState.loading;
    _errorMessage = null;
    notifyListeners();
    
    try {
      _allCompletedAppointments = await _appointmentService.fetchCompletedAppointments();
      _applyFilters();
      _fetchState = HistoryFetchState.loaded;
      notifyListeners();
    } catch (e) {
      _fetchState = HistoryFetchState.error;
      _errorMessage = 'Failed to load appointment history: ${e.toString()}';
      notifyListeners();
      print('Error fetching completed appointments: $e');
    }
  }
  
  // Refresh appointment data
  Future<void> refreshAppointments() async {
    await fetchCompletedAppointments();
  }
  
  // Apply filters to appointments
  void _applyFilters() {
    var filtered = List<ClinicAppointment>.from(_allCompletedAppointments);
    
    // Apply date range filter
    if (_startDate != null && _endDate != null) {
      filtered = filtered.where((appointment) {
        return appointment.date.isAfter(_startDate!) && 
               appointment.date.isBefore(_endDate!.add(const Duration(days: 1)));
      }).toList();
    }
    
    // Apply filter
    switch (_currentFilter) {
      case HistoryFilter.online:
        filtered = filtered.where((appointment) => appointment.isOnline).toList();
        break;
      case HistoryFilter.inPerson:
        filtered = filtered.where((appointment) => !appointment.isOnline).toList();
        break;
      case HistoryFilter.lastWeek:
        final weekAgo = DateTime.now().subtract(const Duration(days: 7));
        filtered = filtered.where((appointment) => appointment.date.isAfter(weekAgo)).toList();
        break;
      case HistoryFilter.lastMonth:
        final monthAgo = DateTime.now().subtract(const Duration(days: 30));
        filtered = filtered.where((appointment) => appointment.date.isAfter(monthAgo)).toList();
        break;
      case HistoryFilter.lastYear:
        final yearAgo = DateTime.now().subtract(const Duration(days: 365));
        filtered = filtered.where((appointment) => appointment.date.isAfter(yearAgo)).toList();
        break;
      case HistoryFilter.all:
      default:
        // No additional filtering
        break;
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
    switch (_sortOrder) {
      case HistorySortOrder.newest:
        filtered.sort((a, b) => b.date.compareTo(a.date));
        break;
      case HistorySortOrder.oldest:
        filtered.sort((a, b) => a.date.compareTo(b.date));
        break;
      case HistorySortOrder.highestPaid:
        filtered.sort((a, b) => b.paidAmount.compareTo(a.paidAmount));
        break;
      case HistorySortOrder.lowestPaid:
        filtered.sort((a, b) => a.paidAmount.compareTo(b.paidAmount));
        break;
    }
    
    _filteredAppointments = filtered;
    notifyListeners();
  }
  
  // Set date range
  void setDateRange(DateTime? start, DateTime? end) {
    _startDate = start;
    _endDate = end;
    _applyFilters();
  }
  
  // Set search query
  void setSearchQuery(String query) {
    _searchQuery = query;
    _applyFilters();
  }
  
  // Set sort order
  void setSortOrder(HistorySortOrder order) {
    if (_sortOrder != order) {
      _sortOrder = order;
      _applyFilters();
    }
  }
  
  // Set filter
  void setFilter(HistoryFilter filter) {
    if (_currentFilter != filter) {
      _currentFilter = filter;
      _applyFilters();
    }
  }
  
  // Reset all filters
  void resetFilters() {
    _startDate = null;
    _endDate = null;
    _searchQuery = '';
    _sortOrder = HistorySortOrder.newest;
    _currentFilter = HistoryFilter.all;
    _applyFilters();
  }
  
  // Get formatted statistics
  String getFormattedStats() {
    final totalRevenueFormatted = NumberFormat.currency(
      symbol: '₹',
      decimalDigits: 0,
      locale: 'en_IN',
    ).format(totalRevenue);
    
    return 'Total: $totalAppointments appointments • Revenue: $totalRevenueFormatted';
  }
} 