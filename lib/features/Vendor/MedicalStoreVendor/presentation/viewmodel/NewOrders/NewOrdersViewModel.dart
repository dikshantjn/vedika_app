import 'package:flutter/material.dart';
import 'package:vedika_healthcare/core/auth/data/services/StorageService.dart';
import 'package:vedika_healthcare/features/Vendor/MedicalStoreVendor/data/models/NewOrders/Prescription.dart';
import 'package:vedika_healthcare/features/Vendor/MedicalStoreVendor/data/models/NewOrders/Order.dart';
import 'package:vedika_healthcare/features/Vendor/MedicalStoreVendor/data/services/NewOrders/NewOrdersService.dart';
import 'package:vedika_healthcare/features/Vendor/Registration/Services/VendorLoginService.dart';

class NewOrdersViewModel extends ChangeNotifier {
  final NewOrdersService _service = NewOrdersService();
  final VendorLoginService _loginService = VendorLoginService();
  
  List<Prescription> _prescriptions = [];
  List<Order> _orders = [];
  bool _isLoading = false;
  String? _errorMessage;
  String _selectedTab = 'prescriptions'; // 'prescriptions' or 'orders'
  
  // Getters
  List<Prescription> get prescriptions => _prescriptions;
  List<Order> get orders => _orders;
  bool get isLoading => _isLoading;
  String? get errorMessage => _errorMessage;
  String get selectedTab => _selectedTab;

  // Initialize data
  Future<void> initialize() async {
    try {
      _setLoading(true);
      _clearError();
      
      final vendorId = await _loginService.getVendorId();
      if (vendorId == null || vendorId.isEmpty) {
        _setError('Vendor ID not found. Please login again.');
        return;
      }
      
      await Future.wait([
        _loadPrescriptions(vendorId),
        _loadOrders(vendorId),
      ]);
    } catch (e) {
      _setError('Failed to initialize: $e');
    } finally {
      _setLoading(false);
    }
  }

  // Load prescriptions
  Future<void> _loadPrescriptions(String vendorId) async {
    try {
      _prescriptions = await _service.getPrescriptions(vendorId);
      notifyListeners();
    } catch (e) {
      // For development, use mock data if API fails
      notifyListeners();
    }
  }

  // Load orders
  Future<void> _loadOrders(String vendorId) async {
    try {
      _orders = await _service.getOrders(vendorId);
      notifyListeners();
    } catch (e) {
      notifyListeners();
    }
  }

  // Accept prescription
  Future<Map<String, dynamic>?> acceptPrescription(String prescriptionId, String vendorNote,String userId) async {
    try {
      _setLoading(true);
      _clearError();
      
      final vendorId = await _loginService.getVendorId();

      if (vendorId == null || vendorId.isEmpty) {
        _setError('Vendor ID not found. Please login again.');
        return null;
      }


      final response = await _service.acceptPrescription(prescriptionId, vendorId, vendorNote,userId);
      
      if (response['success'] == true) {
        // Update local prescription status
        final index = _prescriptions.indexWhere((p) => p.prescriptionId == prescriptionId);
        if (index != -1) {
          _prescriptions[index] = _prescriptions[index].copyWith(
            status: 'verified',
            vendorNote: vendorNote,
            updatedAt: DateTime.now(),
          );
          notifyListeners();
        }
        return response;
      } else {
        _setError('Failed to accept prescription');
        return null;
      }
    } catch (e) {
      _setError('Error accepting prescription: $e');
      return null;
    } finally {
      _setLoading(false);
    }
  }

  // Reject prescription
  Future<Map<String, dynamic>?> rejectPrescription(String prescriptionId, String vendorNote) async {
    try {
      _setLoading(true);
      _clearError();
      
      final vendorId = await _loginService.getVendorId();
      if (vendorId == null || vendorId.isEmpty) {
        _setError('Vendor ID not found. Please login again.');
        return null;
      }
      
      final response = await _service.rejectPrescription(prescriptionId, vendorId, vendorNote);
      
      if (response['success'] == true) {
        // Update local prescription status
        final index = _prescriptions.indexWhere((p) => p.prescriptionId == prescriptionId);
        if (index != -1) {
          _prescriptions[index] = _prescriptions[index].copyWith(
            status: 'rejected',
            vendorNote: vendorNote,
            updatedAt: DateTime.now(),
          );
          notifyListeners();
        }
        return response;
      } else {
        _setError('Failed to reject prescription');
        return null;
      }
    } catch (e) {
      _setError('Error rejecting prescription: $e');
      return null;
    } finally {
      _setLoading(false);
    }
  }

  // Update order payment amount
  Future<Map<String, dynamic>?> updateOrderPayment(String orderId, double totalAmount) async {
    try {
      _setLoading(true);
      _clearError();
      
      final response = await _service.updateOrderPayment(orderId, totalAmount);
      
      if (response['success'] == true) {
        // Update local order data
        final index = _orders.indexWhere((o) => o.orderId == orderId);
        if (index != -1) {
          _orders[index] = _orders[index].copyWith(
            totalAmount: totalAmount,
            status: 'waiting_for_payment',
            updatedAt: DateTime.now(),
          );
          notifyListeners();
        }
        return response;
      } else {
        _setError('Failed to update order payment');
        return null;
      }
    } catch (e) {
      _setError('Error updating order payment: $e');
      return null;
    } finally {
      _setLoading(false);
    }
  }

  // Update order note
  Future<Map<String, dynamic>?> updateOrderNote(String orderId, String note) async {
    try {
      _setLoading(true);
      _clearError();
      
      final response = await _service.updateOrderNote(orderId, note);
      
      if (response['success'] == true) {
        // Update local order data
        final index = _orders.indexWhere((o) => o.orderId == orderId);
        if (index != -1) {
          _orders[index] = _orders[index].copyWith(
            note: note,
            updatedAt: DateTime.now(),
          );
          notifyListeners();
        }
        return response;
      } else {
        _setError('Failed to update order note');
        return null;
      }
    } catch (e) {
      _setError('Error updating order note: $e');
      return null;
    } finally {
      _setLoading(false);
    }
  }

  // Update order status
  Future<Map<String, dynamic>?> updateOrderStatus(String orderId, String status) async {
    try {
      _setLoading(true);
      _clearError();
      
      final response = await _service.updateOrderStatus(orderId, status);
      
      if (response['success'] == true) {
        // Update local order data
        final index = _orders.indexWhere((o) => o.orderId == orderId);
        if (index != -1) {
          _orders[index] = _orders[index].copyWith(
            status: status,
            updatedAt: DateTime.now(),
          );
          notifyListeners();
        }
        return response;
      } else {
        _setError('Failed to update order status');
        return null;
      }
    } catch (e) {
      _setError('Error updating order status: $e');
      return null;
    } finally {
      _setLoading(false);
    }
  }

  // Change selected tab
  void changeTab(String tab) {
    _selectedTab = tab;
    notifyListeners();
  }

  // Refresh data
  Future<void> refresh() async {
    await initialize();
  }

  // Get prescriptions by status
  List<Prescription> getPrescriptionsByStatus(String status) {
    return _prescriptions.where((p) => p.status == status).toList();
  }

  // Get orders by status
  List<Order> getOrdersByStatus(String status) {
    return _orders.where((o) => o.status == status).toList();
  }

  // Get pending prescriptions count
  int get pendingPrescriptionsCount => getPrescriptionsByStatus('pending').length;

  // Get pending orders count
  int get pendingOrdersCount => getOrdersByStatus('pending').length;

  // Private methods
  void _setLoading(bool loading) {
    _isLoading = loading;
    notifyListeners();
  }

  void _setError(String error) {
    _errorMessage = error;
    notifyListeners();
  }

  void _clearError() {
    _errorMessage = null;
    notifyListeners();
  }
}
