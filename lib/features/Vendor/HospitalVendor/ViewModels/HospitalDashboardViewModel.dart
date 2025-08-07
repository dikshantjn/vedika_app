import 'package:flutter/material.dart';
import 'package:vedika_healthcare/features/Vendor/HospitalVendor/Models/HospitalProfile.dart';
import 'package:vedika_healthcare/features/Vendor/HospitalVendor/Services/HospitalVendorService.dart';
import 'package:vedika_healthcare/features/Vendor/HospitalVendor/Services/HospitalAnalysisService.dart';
import 'package:vedika_healthcare/features/Vendor/Registration/Services/VendorLoginService.dart';
import 'package:vedika_healthcare/features/Vendor/Service/VendorService.dart';

class HospitalDashboardViewModel extends ChangeNotifier {
  final HospitalVendorService _hospitalService = HospitalVendorService();
  final VendorLoginService _loginService = VendorLoginService();
  final VendorService _vendorService = VendorService();
  String? _vendorId;

  Future<String?> getVendorId() async {
    return await _loginService.getVendorId();
  }
  int _currentIndex = 0;
  int get currentIndex => _currentIndex;
  
  bool _isLoading = false;
  bool get isLoading => _isLoading;
  
  String? _error;
  String? get error => _error;
  
  bool _isActive = false;
  bool get isActive => _isActive;
  
  HospitalProfile? _hospitalProfile;
  HospitalProfile? get hospitalProfile => _hospitalProfile;
  
  // Dynamic Data from Analysis Service
  Map<String, dynamic> _currentStats = {};
  Map<String, dynamic> get currentStats => _currentStats;
  
  List<Map<String, dynamic>> _currentRequests = [];
  List<Map<String, dynamic>> get currentRequests => _currentRequests;
  
  Map<String, dynamic> _currentFootfall = {};
  Map<String, dynamic> get currentFootfall => _currentFootfall;
  
  Map<String, dynamic> _currentDemographics = {};
  Map<String, dynamic> get currentDemographics => _currentDemographics;
  
  Map<String, dynamic> _currentBedAnalytics = {};
  Map<String, dynamic> get currentBedAnalytics => _currentBedAnalytics;
  
  Map<String, dynamic> _currentInsights = {};
  Map<String, dynamic> get currentInsights => _currentInsights;
  
  // Time Period for Analytics
  String _selectedTimePeriod = 'week';
  String get selectedTimePeriod => _selectedTimePeriod;

  void updateCurrentIndex(int index) {
    _currentIndex = index;
    notifyListeners();
  }

  void updateTimePeriod(String period) {
    _selectedTimePeriod = period;
    _loadDataForTimePeriod(period);
    notifyListeners();
  }

  void _loadDataForTimePeriod(String timePeriod) {
    _currentStats = HospitalAnalysisService.getStats(timePeriod);
    _currentRequests = HospitalAnalysisService.getRequests(timePeriod);
    _currentFootfall = HospitalAnalysisService.getFootfallData(timePeriod);
    _currentDemographics = HospitalAnalysisService.getDemographicsData(timePeriod);
    _currentBedAnalytics = HospitalAnalysisService.getBedAnalyticsData(timePeriod);
    _currentInsights = HospitalAnalysisService.getInsightsData(timePeriod);
  }

  Future<void> fetchDashboardData() async {
    _isLoading = true;
    notifyListeners();
    
    // Get vendor ID from storage
    _vendorId = await getVendorId();
    print("🔹 Fetching Dashboard Data - Vendor ID: $_vendorId");
    
    if (_vendorId == null) {
      print("❌ Error: Vendor ID is null");
      _error = 'Vendor ID not found';
      _isLoading = false;
      notifyListeners();
      return;
    }

    try {
      // Get current vendor status
      print("🔹 Fetching Current Vendor Status...");
      _isActive = await _vendorService.getVendorStatus(_vendorId!);
      print("✅ Current Vendor Status: $_isActive");
      
      print("🔹 Fetching Hospital Profile...");
      // Fetch hospital profile
      _hospitalProfile = await _hospitalService.getHospitalProfile(_vendorId!);
      print("✅ Hospital Profile Fetched: ${_hospitalProfile?.name}");
      print("✅ Hospital Profile Data: ${_hospitalProfile?.toJson()}");
      
      // Load initial data for the selected time period
      _loadDataForTimePeriod(_selectedTimePeriod);
      
      _error = null;
      print("✅ Dashboard Data Loaded Successfully");
    } catch (e, stackTrace) {
      print("❌ Error fetching dashboard data: $e");
      print("❌ Stack Trace: $stackTrace");
      _error = 'Failed to load dashboard data. Please try again.';
    } finally {
      _isLoading = false;
      notifyListeners();
      print("🔹 Dashboard Loading State: $_isLoading");
      print("🔹 Hospital Profile State: ${_hospitalProfile?.name ?? 'null'}");
      print("🔹 Current Vendor Status: $_isActive");
    }
  }

  Future<void> toggleActiveStatus() async {
    try {
      print("🔄 Toggling Vendor Status...");
      
      // Get vendor ID if not already available
      if (_vendorId == null) {
        _vendorId = await getVendorId();
        if (_vendorId == null) {
          print("❌ Error: Vendor ID is null during toggle");
          return;
        }
      }

      // Call the toggle status API
      final newStatus = await _vendorService.toggleVendorStatus(_vendorId!);
      print("✅ Vendor Status Toggled: $newStatus");
      
      // Update local state
      _isActive = newStatus;
      notifyListeners();
      
      // If we have a hospital profile, update its active status
      if (_hospitalProfile != null) {
        _hospitalProfile = _hospitalProfile!.copyWith(isActive: newStatus);
      }
      
      print("✅ Local State Updated - isActive: $_isActive");
      
      // Verify the new status matches the server
      final verifiedStatus = await _vendorService.getVendorStatus(_vendorId!);
      print("✅ Verified Server Status: $verifiedStatus");
      
      if (verifiedStatus != newStatus) {
        print("⚠️ Status mismatch detected. Updating to server status.");
        _isActive = verifiedStatus;
        notifyListeners();
      }
    } catch (e) {
      print("❌ Error toggling vendor status: $e");
      // Revert the switch if the API call fails
      _isActive = !_isActive;
      notifyListeners();
    }
  }

  // Helper methods for getting specific data
  int get totalPatients => _currentStats['totalPatients'] ?? 0;
  int get totalEnquiries => _currentStats['totalInquiries'] ?? 0;
  int get totalBookings => _currentStats['totalBookings'] ?? 0;
  int get totalBedRequests => _currentStats['totalBedRequests'] ?? 0;
  int get confirmedBedBookings => _currentStats['confirmedBedBookings'] ?? 0;
  int get totalBedRevenue => _currentStats['totalBedRevenue'] ?? 0;
  String get avgTimeToConfirm => _currentStats['avgTimeToConfirm'] ?? '0 hrs';
  int get bedOccupancyRate => _currentStats['bedOccupancyRate'] ?? 0;
  
  String get peakHour => _currentFootfall['peakHour'] ?? '';
  String get peakDay => _currentFootfall['peakDay'] ?? '';
  List<int> get footfallChartData => List<int>.from(_currentFootfall['chartData'] ?? []);
  List<String> get footfallChartLabels => List<String>.from(_currentFootfall['chartLabels'] ?? []);
  
  Map<String, int> get ageGroupDistribution => Map<String, int>.from(_currentDemographics['ageGroups'] ?? {});
  Map<String, int> get healthConditions => Map<String, int>.from(_currentDemographics['healthConditions'] ?? {});
  Map<String, int> get genderDistribution => Map<String, int>.from(_currentDemographics['genderDistribution'] ?? {});
  
  Map<String, int> get bedOccupancy => Map<String, int>.from(_currentBedAnalytics['occupancy'] ?? {});
  Map<String, int> get bedDemand => Map<String, int>.from(_currentBedAnalytics['demand'] ?? {});
  Map<String, int> get bookingFunnel => Map<String, int>.from(_currentBedAnalytics['funnel'] ?? {});
  Map<String, dynamic> get bookingOutcomes => Map<String, dynamic>.from(_currentBedAnalytics['outcomes'] ?? {});
  Map<String, int> get bedRevenue => Map<String, int>.from(_currentBedAnalytics['revenue'] ?? {});
  Map<String, int> get peakBookingTimes => Map<String, int>.from(_currentBedAnalytics['peakBookingTimes'] ?? {});
  
  List<String> get topCancelReasons => List<String>.from(_currentInsights['topCancelReasons'] ?? []);
  List<String> get highDemandBeds => List<String>.from(_currentInsights['highDemandBeds'] ?? []);
  String get suggestions => _currentInsights['suggestions'] ?? '';

  // Add a method to refresh the hospital profile
  Future<void> refreshHospitalProfile() async {
    print("🔄 Refreshing Hospital Profile...");
    try {
      _vendorId = await getVendorId();
      if (_vendorId == null) {
        print("❌ Error: Vendor ID is null during refresh");
        return;
      }
      
      _hospitalProfile = await _hospitalService.getHospitalProfile(_vendorId!);
      print("✅ Hospital Profile Refreshed: ${_hospitalProfile?.name}");
      notifyListeners();
    } catch (e) {
      print("❌ Error refreshing hospital profile: $e");
    }
  }

  Future<void> updateBedAvailability(String hospitalId, int availableBeds) async {
    try {
      _isLoading = true;
      notifyListeners();

      await _hospitalService.updateBedAvailability(hospitalId, availableBeds);
      
      // Refresh the hospital data to get updated bed availability
      await fetchDashboardData();
      
      _isLoading = false;
      notifyListeners();
    } catch (e) {
      _isLoading = false;
      _error = e.toString();
      notifyListeners();
      rethrow;
    }
  }
}

 