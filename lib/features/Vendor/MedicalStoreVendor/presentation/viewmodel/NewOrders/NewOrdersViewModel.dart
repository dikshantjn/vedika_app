import 'package:flutter/material.dart';
import 'package:socket_io_client/socket_io_client.dart' as IO;
import 'package:vedika_healthcare/core/constants/ApiEndpoints.dart';
import 'package:vedika_healthcare/core/auth/data/services/StorageService.dart';
import 'package:vedika_healthcare/features/Vendor/MedicalStoreVendor/data/models/NewOrders/Prescription.dart';
import 'package:vedika_healthcare/features/Vendor/MedicalStoreVendor/data/models/NewOrders/Order.dart';
import 'package:vedika_healthcare/features/Vendor/MedicalStoreVendor/data/services/NewOrders/NewOrdersService.dart';
import 'package:vedika_healthcare/features/Vendor/Registration/Services/VendorLoginService.dart';
import 'dart:convert';

class NewOrdersViewModel extends ChangeNotifier {
  final NewOrdersService _service = NewOrdersService();
  final VendorLoginService _loginService = VendorLoginService();
  IO.Socket? _socket;
  bool _disposed = false;

  List<Prescription> _prescriptions = [];
  List<Order> _orders = [];
  List<Order> _filteredOrders = [];
  bool _isLoading = false;
  String? _errorMessage;
  String _selectedTab = 'prescriptions'; // 'prescriptions' or 'orders'

  // Search and filter properties
  String _searchQuery = '';
  String? _selectedStatusFilter;
  String? _selectedDateFilter;
  String? _selectedAmountFilter;

  // Constructor
  NewOrdersViewModel() {
    initSocketConnection();
  }

  // Socket connection initialization
  void initSocketConnection() async {
    debugPrint("🚀 Initializing socket connection for new orders...");
    try {
      String? vendorId = await _loginService.getVendorId();
      if (vendorId == null) {
        debugPrint("❌ Vendor ID not found for socket registration");
        return;
      }

      // Close existing socket if any
      _socket?.disconnect();
      _socket?.dispose();

      _socket = IO.io(ApiEndpoints.socketUrl, <String, dynamic>{
        'transports': ['websocket', 'polling'],
        'autoConnect': true,
        'reconnection': true,
        'reconnectionAttempts': 10,
        'reconnectionDelay': 1000,
        'reconnectionDelayMax': 5000,
        'timeout': 20000,
        'forceNew': true,
        'upgrade': true,
        'rememberUpgrade': true,
        'path': '/socket.io/',
        'query': {'vendorId': vendorId},
      });

      // Set up event listeners
      _socket!.onConnect((_) {
        debugPrint('✅ Socket connected for new orders');
        _socket!.emit('registerVendor', vendorId);
      });

      _socket!.onConnectError((data) {
        debugPrint('❌ Socket connection error: $data');
        _attemptReconnect();
      });

      _socket!.onError((data) {
        debugPrint('❌ Socket error: $data');
      });

      _socket!.onDisconnect((_) {
        debugPrint('❌ Socket disconnected');
        _attemptReconnect();
      });

      // Add event listener for orderStatusUpdated
      _socket!.on('orderStatusUpdated', (data) async {
        debugPrint('🔄 Order status update received: $data');
        await _handleOrderStatusUpdate(data);
      });

      // Add ping/pong handlers
      _socket!.on('ping', (_) {
        _socket!.emit('pong');
      });

      // Connect to the socket
      _socket!.connect();
      debugPrint('🔄 Attempting to connect socket for new orders...');
    } catch (e) {
      debugPrint("❌ Socket connection error: $e");
      _attemptReconnect();
    }
  }

  void _attemptReconnect() {
    Future.delayed(Duration(seconds: 2), () {
      if (_socket != null && !_socket!.connected) {
        debugPrint('🔄 Attempting to reconnect...');
        _socket!.connect();
      }
    });
  }

  Future<void> _handleOrderStatusUpdate(dynamic data) async {
    try {
      debugPrint('📋 Processing order status update: $data');

      // Parse the data if it's a string
      Map<String, dynamic> updateData = data is String ? json.decode(data) : data;
      debugPrint('📋 Parsed data: $updateData');

      final orderId = updateData['orderId'];
      final prescriptionId = updateData['prescriptionId'];
      final newStatus = updateData['status'];

      if (orderId != null || prescriptionId != null) {
        debugPrint('✅ Order status update received, refreshing data...');

        // Refresh both orders and prescriptions
        await Future.wait([
          refresh(),
        ]);

        debugPrint('✅ Refreshed orders and prescriptions after status update');
      } else {
        debugPrint('❌ Missing orderId or prescriptionId in data: $updateData');
      }
    } catch (e, stackTrace) {
      debugPrint('❌ Error handling order status update: $e');
      debugPrint('❌ Stack trace: $stackTrace');
    }
  }

  // Getters
  List<Prescription> get prescriptions => _prescriptions;
  List<Order> get orders => _orders;
  List<Order> get filteredOrders => _filteredOrders.isEmpty && _searchQuery.isEmpty && _selectedStatusFilter == null && _selectedDateFilter == null && _selectedAmountFilter == null ? _orders : _filteredOrders;
  bool get isLoading => _isLoading;
  String? get errorMessage => _errorMessage;
  String get selectedTab => _selectedTab;

  // Search and filter getters
  String get searchQuery => _searchQuery;
  String? get selectedStatusFilter => _selectedStatusFilter;
  String? get selectedDateFilter => _selectedDateFilter;
  String? get selectedAmountFilter => _selectedAmountFilter;

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
      if (!_disposed) notifyListeners();
    } catch (e) {
      // For development, use mock data if API fails
      if (!_disposed) notifyListeners();
    }
  }

  // Load orders
  Future<void> _loadOrders(String vendorId) async {
    try {
      _orders = await _service.getOrders(vendorId);
      _filteredOrders = List.from(_orders); // Initialize filtered orders
      if (!_disposed) notifyListeners();
    } catch (e) {
      if (!_disposed) notifyListeners();
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
        // Remove prescription from list after successful acceptance
        _prescriptions.removeWhere((p) => p.prescriptionId == prescriptionId);

        // Refresh orders list to show any new orders created from this prescription
        final vendorId = await _loginService.getVendorId();
        if (vendorId != null && vendorId.isNotEmpty) {
          await _loadOrders(vendorId);
        }

        if (!_disposed) notifyListeners();
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
        // Remove prescription from list after successful rejection
        _prescriptions.removeWhere((p) => p.prescriptionId == prescriptionId);

        // Refresh orders list to reflect any changes from prescription rejection
        final vendorId = await _loginService.getVendorId();
        if (vendorId != null && vendorId.isNotEmpty) {
          await _loadOrders(vendorId);
        }

        if (!_disposed) notifyListeners();
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
          // Also update filtered orders if filters are active
          _applyFilters();
          if (!_disposed) notifyListeners();
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
          // Also update filtered orders if filters are active
          _applyFilters();
          if (!_disposed) notifyListeners();
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
          // Also update filtered orders if filters are active
          _applyFilters();
          if (!_disposed) notifyListeners();
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
    if (_disposed) return;
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

  // Search and filter methods
  void searchOrders(String query) {
    _searchQuery = query.toLowerCase();
    _applyFilters();
  }

  void setStatusFilter(String? status) {
    if (_disposed) return;
    _selectedStatusFilter = status;
    notifyListeners(); // Update UI immediately
  }

  void setDateFilter(String? dateFilter) {
    if (_disposed) return;
    _selectedDateFilter = dateFilter;
    notifyListeners(); // Update UI immediately
  }

  void setAmountFilter(String? amountFilter) {
    if (_disposed) return;
    _selectedAmountFilter = amountFilter;
    notifyListeners(); // Update UI immediately
  }

  void applyFilters() {
    _applyFilters();
  }

  void clearAllFilters() {
    if (_disposed) return;
    _searchQuery = '';
    _selectedStatusFilter = null;
    _selectedDateFilter = null;
    _selectedAmountFilter = null;
    _filteredOrders = List.from(_orders);
    notifyListeners();
  }

  void clearSearch() {
    _searchQuery = '';
    _applyFilters();
  }

  void _applyFilters() {
    List<Order> filtered = List.from(_orders);

    // Apply search query
    if (_searchQuery.isNotEmpty) {
      filtered = filtered.where((order) {
        final orderId = order.orderId.toLowerCase();
        final customerName = order.user?.name?.toLowerCase() ?? '';
        final status = order.status?.toLowerCase() ?? '';

        return orderId.contains(_searchQuery) ||
               customerName.contains(_searchQuery) ||
               status.contains(_searchQuery);
      }).toList();
    }

    // Apply status filter
    if (_selectedStatusFilter != null && _selectedStatusFilter!.isNotEmpty) {
      filtered = filtered.where((order) => order.status == _selectedStatusFilter).toList();
    }

    // Apply date filter
    if (_selectedDateFilter != null && _selectedDateFilter!.isNotEmpty) {
      final now = DateTime.now();
      DateTime startDate;

      switch (_selectedDateFilter) {
        case 'today':
          startDate = DateTime(now.year, now.month, now.day);
          break;
        case 'week':
          startDate = now.subtract(Duration(days: 7));
          break;
        case 'month':
          startDate = DateTime(now.year, now.month, 1);
          break;
        default:
          startDate = DateTime(2000); // Very old date for "all time"
      }

      filtered = filtered.where((order) => order.createdAt.isAfter(startDate)).toList();
    }

    // Apply amount filter
    if (_selectedAmountFilter != null && _selectedAmountFilter!.isNotEmpty) {
      filtered = filtered.where((order) {
        final amount = order.totalAmount;
        switch (_selectedAmountFilter) {
          case 'under_500':
            return amount < 500;
          case '500_1000':
            return amount >= 500 && amount <= 1000;
          case 'above_1000':
            return amount > 1000;
          default:
            return true;
        }
      }).toList();
    }

    _filteredOrders = filtered;
    if (!_disposed) notifyListeners();
  }

  // Dispose method for socket cleanup
  @override
  void dispose() {
    _disposed = true;
    if (_socket != null) {
      _socket!.disconnect();
      _socket!.dispose();
    }
    super.dispose();
  }

  // Private methods
  void _setLoading(bool loading) {
    if (_disposed) return;
    _isLoading = loading;
    notifyListeners();
  }

  void _setError(String error) {
    if (_disposed) return;
    _errorMessage = error;
    notifyListeners();
  }

  void _clearError() {
    if (_disposed) return;
    _errorMessage = null;
    notifyListeners();
  }
}
