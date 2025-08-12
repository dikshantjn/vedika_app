import 'package:flutter/material.dart';
import 'package:vedika_healthcare/features/Vendor/BloodBankAgencyVendor/data/model/BloodBankAgency.dart';
import 'package:vedika_healthcare/features/Vendor/BloodBankAgencyVendor/data/services/BloodBankAgencyProfileService.dart';
import 'package:vedika_healthcare/features/Vendor/BloodBankAgencyVendor/data/services/BloodBankRequestService.dart';
import 'package:vedika_healthcare/features/Vendor/BloodBankAgencyVendor/data/model/BloodBankRequest.dart';
import 'package:logger/logger.dart';
import 'package:vedika_healthcare/features/Vendor/Registration/Services/VendorLoginService.dart';
import 'package:vedika_healthcare/features/Vendor/BloodBankAgencyVendor/data/services/BloodBankAnalyticsService.dart';

class VendorBloodBankDashBoardViewModel extends ChangeNotifier {
  final Logger logger = Logger();
  final BloodBankAgencyProfileService _profileService = BloodBankAgencyProfileService();
  final BloodBankRequestService _requestService = BloodBankRequestService();
  final VendorLoginService _loginService = VendorLoginService(); // Vendor Login Service

  // Dashboard data
  BloodBankAgency? _agencyDetails;
  List<BloodBankRequest> _recentRequests = [];
  bool _isLoading = false;
  int _totalRequests = 0;
  int _pendingRequests = 0;
  int _completedRequests = 0;
  String? _errorMessage;

  // Time filter
  String _selectedTimeFilter = 'Month';
  final List<String> _timeFilters = const ['Day', 'Week', 'Month', 'Year'];

  // Getters
  BloodBankAgency? get agencyDetails => _agencyDetails;
  List<BloodBankRequest> get recentRequests => _recentRequests;
  bool get isLoading => _isLoading;
  int get totalRequests => _totalRequests;
  int get pendingRequests => _pendingRequests;
  int get completedRequests => _completedRequests;
  String? get errorMessage => _errorMessage;
  String get selectedTimeFilter => _selectedTimeFilter;
  List<String> get timeFilters => _timeFilters;

  // Initialize dashboard
  Future<void> initializeDashboard() async {
    if (_isLoading) return; // Prevent multiple simultaneous calls
    String? token = await _loginService.getVendorToken();
    String? vendorId = await _loginService.getVendorId();
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    try {
      // Get agency profile
      try {
        _agencyDetails = await _profileService.getAgencyProfile(vendorId!); // TODO: Replace with actual vendor ID
      } catch (e) {
        logger.w('Failed to fetch agency profile: $e');
        // Continue with default values if profile fetch fails
      }
      
      // Get recent requests
      try {
        _recentRequests = await _requestService.getRequests(vendorId!, token!); // TODO: Replace with actual token
      } catch (e) {
        logger.w('Failed to fetch recent requests: $e');
        _errorMessage = 'Failed to load recent requests';
      }
      
      // Calculate statistics
      _totalRequests = _recentRequests.length;
      _pendingRequests = _recentRequests.where((request) => request.status.toLowerCase() == 'pending').length;
      _completedRequests = _recentRequests.where((request) => request.status.toLowerCase() == 'completed').length;
      
      // Fetch analytics mock
      _analytics = await BloodBankAnalyticsService.getAnalytics(_selectedTimeFilter);
      
    } catch (e) {
      logger.e('Error initializing dashboard: $e');
      _errorMessage = 'Failed to load dashboard data';
    } finally {
      _isLoading = false;
      if (!_isDisposed) {
        notifyListeners();
      }
    }
  }

  // Refresh dashboard data
  Future<void> refreshDashboard() async {
    await initializeDashboard();
  }

  // Get statistics
  Map<String, dynamic> getStatistics() {
    return {
      'totalRequests': _totalRequests,
      'pendingRequests': _pendingRequests,
      'completedRequests': _completedRequests,
    };
  }

  // Analytics map
  Map<String, dynamic> _analytics = {};
  Map<String, dynamic> get analytics => _analytics;

  Future<void> setTimeFilter(String filter) async {
    _selectedTimeFilter = filter;
    notifyListeners();
    try {
      _analytics = await BloodBankAnalyticsService.getAnalytics(filter);
    } catch (e) {
      logger.w('Failed to fetch analytics for $filter: $e');
    }
    notifyListeners();
  }

  bool _isDisposed = false;

  @override
  void dispose() {
    _isDisposed = true;
    super.dispose();
  }
} 