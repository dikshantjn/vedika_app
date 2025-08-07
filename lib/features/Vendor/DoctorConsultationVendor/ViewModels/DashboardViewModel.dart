import 'package:flutter/material.dart';
import 'package:vedika_healthcare/core/auth/data/services/StorageService.dart';
import 'package:vedika_healthcare/features/Vendor/DoctorConsultationVendor/Models/ClinicAppointment.dart';
import 'package:vedika_healthcare/features/Vendor/DoctorConsultationVendor/Services/AppointmentService.dart';
import 'package:vedika_healthcare/features/Vendor/DoctorConsultationVendor/Services/DoctorClinicService.dart';
import 'package:vedika_healthcare/features/Vendor/DoctorConsultationVendor/Services/DoctorVendorAnalysisService.dart';
import 'package:vedika_healthcare/features/Vendor/Registration/Services/VendorLoginService.dart';
import 'package:vedika_healthcare/features/Vendor/Service/VendorService.dart';

class DashboardViewModel extends ChangeNotifier {
  final AppointmentService _appointmentService = AppointmentService();
  final DoctorClinicService _doctorClinicService = DoctorClinicService();
  final VendorService _vendorService = VendorService();
  final VendorLoginService _loginService = VendorLoginService();
  final DoctorVendorAnalysisService _analysisService = DoctorVendorAnalysisService();
  
  bool _isLoading = true;
  String? _errorMessage;
  String? _vendorId;
  bool _isActive = false;
  bool _isOnline = false; // Default to offline until we know the status
  String _selectedTimeFilter = 'Today';
  
  // Dashboard data
  List<ClinicAppointment> _upcomingAppointments = [];
  int _totalPatients = 0;
  int _totalAppointments = 0;
  double _completionRate = 0.0;
  double _rating = 4.5;
  int _reviewCount = 32;
  int _todayAppointments = 0;
  
  // Analytics data
  List<Map<String, dynamic>> _analyticsData = [
    {'month': 'Jan', 'patients': 30, 'appointments': 45},
    {'month': 'Feb', 'patients': 50, 'appointments': 60},
    {'month': 'Mar', 'patients': 40, 'appointments': 55},
    {'month': 'Apr', 'patients': 70, 'appointments': 85},
    {'month': 'May', 'patients': 55, 'appointments': 65},
    {'month': 'Jun', 'patients': 80, 'appointments': 95},
  ];
  
  // Comprehensive analytics data
  Map<String, dynamic> _comprehensiveAnalytics = {};
  
  // Getters
  bool get isLoading => _isLoading;
  String? get errorMessage => _errorMessage;
  bool get isActive => _isActive;
  bool get isOnline => _isOnline;
  String get selectedTimeFilter => _selectedTimeFilter;
  List<String> get timeFilters => _analysisService.getTimeFilters();
  List<ClinicAppointment> get upcomingAppointments => _upcomingAppointments;
  int get totalPatients => _totalPatients;
  int get totalAppointments => _totalAppointments;
  double get completionRate => _completionRate;
  double get rating => _rating;
  int get reviewCount => _reviewCount;
  int get todayAppointments => _todayAppointments;
  List<Map<String, dynamic>> get analyticsData => _analyticsData;
  Map<String, dynamic> get comprehensiveAnalytics => _comprehensiveAnalytics;
  
  // Initialize and fetch dashboard data
  Future<void> initialize() async {
    await fetchDashboardData();
  }
  
  void init() {
    fetchVendorOnlineStatus();
    fetchDashboardData();
  }
  
  // Fetch the vendor's current online status
  Future<void> fetchVendorOnlineStatus() async {
    try {
      // Get vendor ID from storage
      final vendorId = await _loginService.getVendorId();
      if (vendorId != null) {
        _vendorId = vendorId;
        // Get current online status
        final status = await _vendorService.getVendorStatus(vendorId);
        _isOnline = status;
        _isActive = status; // Keep these in sync
        notifyListeners();
      }
    } catch (e) {
      print('Error fetching vendor online status: $e');
      _isOnline = false; // Default to offline on error
      _isActive = false;
      notifyListeners();
    }
  }
  
  // Toggle online status through the API
  Future<void> toggleOnlineStatus() async {
    try {
      if (_vendorId == null) {
        _vendorId = await _loginService.getVendorId();
        if (_vendorId == null) {
          throw Exception('Vendor ID not found');
        }
      }
      
      // Toggle status through the API
      final newStatus = await _vendorService.toggleVendorStatus(_vendorId!);
      
      // Update local state with the returned status
      _isOnline = newStatus;
      _isActive = newStatus;
      notifyListeners();
    } catch (e) {
      print('Error toggling online status: $e');
      // Don't change the status if there was an error
    }
  }
  
  // Set the online status directly
  void setOnlineStatus(bool status) {
    _isOnline = status;
    _isActive = status;
    notifyListeners();
  }
  
  void setTimeFilter(String filter) {
    if (_selectedTimeFilter != filter) {
      _selectedTimeFilter = filter;
      fetchDashboardData();
    }
  }
  
  // Fetch all dashboard data
  Future<void> fetchDashboardData() async {
    _setLoading(true);
    
    try {
      // Get vendor ID from storage if we don't have it yet
      if (_vendorId == null) {
        _vendorId = await _loginService.getVendorId();
        if (_vendorId == null) {
          _errorMessage = 'Vendor ID not found';
          _setLoading(false);
          return;
        }
      }
      
      // Get vendor status if we haven't already
      if (!_isOnline) {
        _isActive = await _vendorService.getVendorStatus(_vendorId!);
        _isOnline = _isActive;
      }
      
      // Fetch upcoming appointments
      await fetchUpcomingAppointments();
      
      // Fetch stats data
      await fetchStatsData();
      
      // Fetch analytics data
      await fetchAnalyticsData();
      
      // Fetch comprehensive analytics
      await fetchComprehensiveAnalytics();
      
      // Update today appointments count
      _todayAppointments = _upcomingAppointments.where((appointment) {
        final now = DateTime.now();
        return appointment.date.year == now.year && 
               appointment.date.month == now.month && 
               appointment.date.day == now.day;
      }).length;
      
      _setLoading(false);
    } catch (e) {
      _errorMessage = 'Failed to load dashboard data: ${e.toString()}';
      _setLoading(false);
    }
  }
  
  // Fetch upcoming appointments
  Future<void> fetchUpcomingAppointments() async {
    try {
      _upcomingAppointments = await _appointmentService.getUpcomingAppointments();
      notifyListeners();
    } catch (e) {
      print('Error fetching upcoming appointments: $e');
      _errorMessage = 'Failed to load upcoming appointments';
    }
  }
  
  // Fetch stats data
  Future<void> fetchStatsData() async {
    try {
      if (_vendorId == null) return;
      
      // In a real app, these would be API calls to get actual data
      _totalPatients = await _doctorClinicService.getTotalPatients(_vendorId!);
      _totalAppointments = await _doctorClinicService.getTotalAppointments(_vendorId!);
      _completionRate = await _doctorClinicService.getCompletionRate(_vendorId!);
      _rating = await _doctorClinicService.getDoctorRating(_vendorId!);
      _reviewCount = await _doctorClinicService.getReviewCount(_vendorId!);
      
      notifyListeners();
    } catch (e) {
      print('Error fetching stats data: $e');
      _errorMessage = 'Failed to load stats data';
    }
  }
  
  // Fetch analytics data
  Future<void> fetchAnalyticsData() async {
    try {
      if (_vendorId == null) return;
      
      // Get basic analytics from the analysis service
      _analyticsData = await _analysisService.getBasicAnalytics();
      
      notifyListeners();
    } catch (e) {
      print('Error fetching analytics data: $e');
      _errorMessage = 'Failed to load analytics data';
    }
  }
  
  // Fetch comprehensive analytics data
  Future<void> fetchComprehensiveAnalytics() async {
    try {
      if (_vendorId == null) return;
      
      // Get comprehensive analytics for the selected time filter
      _comprehensiveAnalytics = await _analysisService.getAnalyticsData(_selectedTimeFilter);
      
      notifyListeners();
    } catch (e) {
      print('Error fetching comprehensive analytics: $e');
      _errorMessage = 'Failed to load comprehensive analytics';
    }
  }
  
  // Helper to set loading state
  void _setLoading(bool loading) {
    _isLoading = loading;
    notifyListeners();
  }
} 