import 'package:flutter/material.dart';
import '../../data/model/BloodBankRequest.dart';
import '../../data/services/BloodBankRequestService.dart';
import '../../../../../core/auth/data/models/UserModel.dart';

class BloodBankRequestViewModel extends ChangeNotifier {
  final BloodBankRequestService _service = BloodBankRequestService();
  List<BloodBankRequest> _requests = [];
  bool _isLoading = false;
  String? _error;

  // Getters
  List<BloodBankRequest> get requests => _requests;
  bool get isLoading => _isLoading;
  String? get error => _error;

  // Filtered getters
  List<BloodBankRequest> get pendingRequests => 
      _requests.where((request) => request.status == 'pending').toList();
  
  List<BloodBankRequest> get expiredRequests =>
      _requests.where((request) => request.status == 'expired').toList();
  
  List<BloodBankRequest> get acceptedRequests =>
      _requests.where((request) => request.status == 'accepted').toList();

  Future<void> loadRequests(String vendorId) async {
    try {
      _isLoading = true;
      _error = null;
      notifyListeners();

      _requests = await _service.getRequests(vendorId);
    } catch (e) {
      _error = 'Failed to load requests';
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<void> acceptRequest(String requestId, String vendorId) async {
    try {
      _isLoading = true;
      _error = null;
      notifyListeners();

      await _service.updateRequestStatus(requestId, 'accepted');
      await loadRequests(vendorId); // Reload the requests to get updated data
    } catch (e) {
      _error = 'Failed to accept request';
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<void> processRequest(String requestId, String vendorId) async {
    try {
      _isLoading = true;
      _error = null;
      notifyListeners();

      await _service.updateRequestStatus(requestId, 'processed');
      await loadRequests(vendorId); // Reload the requests to get updated data
    } catch (e) {
      _error = 'Failed to process request';
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<List<String>> getPrescriptionUrls(String requestId) async {
    try {
      final request = _requests.firstWhere((r) => r.requestId == requestId);
      return request.prescriptionUrls;
    } catch (e) {
      _error = 'Failed to load prescription URLs';
      notifyListeners();
      return [];
    }
  }

  // Get user details for a request
  UserModel? getUserDetails(String requestId) {
    try {
      final request = _requests.firstWhere((r) => r.requestId == requestId);
      return request.user;
    } catch (e) {
      return null;
    }
  }
} 