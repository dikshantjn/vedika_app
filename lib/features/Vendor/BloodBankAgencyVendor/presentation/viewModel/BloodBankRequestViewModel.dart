import 'package:flutter/material.dart';
import 'package:vedika_healthcare/features/Vendor/BloodBankAgencyVendor/data/model/BloodBankRequest.dart';

class BloodBankRequestViewModel extends ChangeNotifier {
  List<BloodBankRequest> _requests = [
    BloodBankRequest(
      requestId: '1',
      userId: 'user1',
      customerName: 'John Doe',
      bloodType: 'A+',
      units: 2,
      deliveryFees: 100.0,
      gst: 18.0,
      discount: 0.0,
      totalAmount: 118.0,
      prescriptionUrls: ['https://example.com/prescription1.jpg'],
      requestedVendors: ['vendor1', 'vendor2'],
      status: 'Pending',
      createdAt: DateTime.now(),
    ),
    BloodBankRequest(
      requestId: '2',
      userId: 'user2',
      customerName: 'Jane Smith',
      bloodType: 'B+',
      units: 1,
      deliveryFees: 100.0,
      gst: 18.0,
      discount: 0.0,
      totalAmount: 118.0,
      prescriptionUrls: ['https://example.com/prescription2.jpg'],
      requestedVendors: ['vendor1', 'vendor2'],
      status: 'Accepted',
      createdAt: DateTime.now(),
    ),
    BloodBankRequest(
      requestId: '3',
      userId: 'user3',
      customerName: 'Mike Johnson',
      bloodType: 'O+',
      units: 3,
      deliveryFees: 150.0,
      gst: 27.0,
      discount: 50.0,
      totalAmount: 127.0,
      prescriptionUrls: ['https://example.com/prescription3.jpg'],
      requestedVendors: ['vendor1', 'vendor2'],
      status: 'Processed',
      createdAt: DateTime.now(),
    ),
  ];
  bool _isLoading = false;
  String? _error;

  // Getters
  List<BloodBankRequest> get requests => _requests;
  bool get isLoading => _isLoading;
  String? get error => _error;

  Future<void> loadRequests(String vendorId) async {
    try {
      _isLoading = true;
      _error = null;
      notifyListeners();

      // Simulate API call delay
      await Future.delayed(const Duration(milliseconds: 500));
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

      // Simulate API call delay
      await Future.delayed(const Duration(milliseconds: 500));

      final index = _requests.indexWhere((r) => r.requestId == requestId);
      if (index != -1) {
        _requests[index] = _requests[index].copyWith(
          status: 'Accepted',
        );
      }
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

      // Simulate API call delay
      await Future.delayed(const Duration(milliseconds: 500));

      final index = _requests.indexWhere((r) => r.requestId == requestId);
      if (index != -1) {
        _requests[index] = _requests[index].copyWith(
          status: 'Processed',
        );
      }
    } catch (e) {
      _error = 'Failed to process request';
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<List<String>> getPrescriptionUrls(String requestId) async {
    try {
      // Simulate API call delay
      await Future.delayed(const Duration(milliseconds: 500));

      final request = _requests.firstWhere((r) => r.requestId == requestId);
      return request.prescriptionUrls;
    } catch (e) {
      _error = 'Failed to load prescription URLs';
      notifyListeners();
      return [];
    }
  }
} 