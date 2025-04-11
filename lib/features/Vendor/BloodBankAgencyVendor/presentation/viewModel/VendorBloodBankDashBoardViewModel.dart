import 'package:flutter/material.dart';
import 'package:vedika_healthcare/features/Vendor/BloodBankAgencyVendor/data/model/BloodBankAgency.dart';
import 'package:vedika_healthcare/features/Vendor/BloodBankAgencyVendor/data/services/BloodBankRegistrationService.dart';
import 'package:logger/logger.dart';

class VendorBloodBankDashBoardViewModel extends ChangeNotifier {
  final Logger logger = Logger();
  final BloodBankRegistrationService _bloodBankService = BloodBankRegistrationService();

  // Dashboard data
  BloodBankAgency? _agencyDetails;
  bool _isLoading = false;
  int _totalRequests = 0;
  int _pendingRequests = 0;
  int _completedRequests = 0;

  // Getters
  BloodBankAgency? get agencyDetails => _agencyDetails;
  bool get isLoading => _isLoading;
  int get totalRequests => _totalRequests;
  int get pendingRequests => _pendingRequests;
  int get completedRequests => _completedRequests;

  // Initialize dashboard
  Future<void> initializeDashboard() async {
    _isLoading = true;
    notifyListeners();

    try {
      // TODO: Replace with actual API call to fetch agency details
      // _agencyDetails = await _bloodBankService.getAgencyDetails();
      
      // Mock data for now
      _totalRequests = 25;
      _pendingRequests = 8;
      _completedRequests = 17;
      
      _isLoading = false;
      notifyListeners();
    } catch (e) {
      logger.e('Error initializing dashboard: $e');
      _isLoading = false;
      notifyListeners();
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
} 