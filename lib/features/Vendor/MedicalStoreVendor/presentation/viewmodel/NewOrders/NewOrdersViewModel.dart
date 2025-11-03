import 'package:flutter/material.dart';
import 'package:socket_io_client/socket_io_client.dart' as IO;
import 'package:vedika_healthcare/core/constants/ApiEndpoints.dart';
import 'package:vedika_healthcare/core/auth/data/services/StorageService.dart';
import 'package:vedika_healthcare/features/Vendor/MedicalStoreVendor/data/models/NewOrders/Prescription.dart';
import 'package:vedika_healthcare/features/Vendor/MedicalStoreVendor/data/models/NewOrders/Order.dart';
import 'package:vedika_healthcare/features/Vendor/MedicalStoreVendor/data/models/NewOrders/OrderMedicine.dart';
import 'package:vedika_healthcare/features/Vendor/MedicalStoreVendor/data/services/NewOrders/NewOrdersService.dart';
import 'package:vedika_healthcare/features/Vendor/Registration/Services/VendorLoginService.dart';
import 'package:vedika_healthcare/features/Vendor/MedicalStoreVendor/presentation/viewmodel/MeidicalStoreVendorDashboardViewModel.dart';
import 'dart:convert';

// Helper function to parse double from response (handles string/number)
double _parseDoubleFromResponse(dynamic value) {
  if (value == null) return 0.0;
  if (value is double) return value;
  if (value is int) return value.toDouble();
  if (value is String) return double.tryParse(value) ?? 0.0;
  return 0.0;
}

class NewOrdersViewModel extends ChangeNotifier {
  final NewOrdersService _service = NewOrdersService();
  final VendorLoginService _loginService = VendorLoginService();
  IO.Socket? _socket;
  bool _disposed = false;
  
  // Reference to dashboard viewModel for updating prescription count
  MedicalStoreVendorDashboardViewModel? _dashboardViewModel;

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

  // Set dashboard viewModel reference
  void setDashboardViewModel(MedicalStoreVendorDashboardViewModel dashboardViewModel) {
    _dashboardViewModel = dashboardViewModel;
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

      // Add event listener for new prescription requests
      _socket!.on('newPrescriptionRequest', (data) async {
        debugPrint('🆕 New prescription request received: $data');
        await _handleNewPrescriptionRequest(data);
      });

      // Add event listener for prescription count updates
      _socket!.on('updatePrescriptionCount', (data) async {
        debugPrint('🔄 updatePrescriptionCount event received in NewOrders: $data');
        await _handlePrescriptionCountUpdate(data);
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

  // Handle new prescription requests from socket
  Future<void> _handleNewPrescriptionRequest(dynamic data) async {
    try {
      debugPrint('🆕 Processing new prescription request: $data');
      
      // Refresh prescriptions list
      final vendorId = await _loginService.getVendorId();
      if (vendorId != null && vendorId.isNotEmpty) {
        await _loadPrescriptions(vendorId);
        
        // Refresh dashboard prescription count
        if (_dashboardViewModel != null) {
          await _dashboardViewModel!.refreshPrescriptionCount();
        }
        
        debugPrint('✅ Prescriptions list refreshed after new request');
      }
    } catch (e) {
      debugPrint('❌ Error handling new prescription request: $e');
    }
  }

  // Handle prescription count updates from socket
  Future<void> _handlePrescriptionCountUpdate(dynamic data) async {
    try {
      debugPrint('🔄 Processing prescription count update in NewOrders: $data');
      
      // Refresh prescriptions list
      final vendorId = await _loginService.getVendorId();
      if (vendorId != null && vendorId.isNotEmpty) {
        await _loadPrescriptions(vendorId);
      }
      
      // Refresh dashboard prescription count
      if (_dashboardViewModel != null) {
        await _dashboardViewModel!.refreshPrescriptionCount();
        debugPrint('✅ Dashboard prescription count refreshed from NewOrders');
      } else {
        debugPrint('⚠️ Dashboard viewModel not available for count update');
      }
    } catch (e) {
      debugPrint('❌ Error handling prescription count update in NewOrders: $e');
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
  Future<Map<String, dynamic>?> acceptPrescription(String prescriptionId, String vendorNote,String userId, {String? addressId}) async {
    try {
      _setLoading(true);
      _clearError();
      
      final vendorId = await _loginService.getVendorId();

      if (vendorId == null || vendorId.isEmpty) {
        _setError('Vendor ID not found. Please login again.');
        return null;
      }


      final response = await _service.acceptPrescription(prescriptionId, vendorId, vendorNote, userId, addressId: addressId);
      
      if (response['success'] == true) {
        // Remove prescription from list after successful acceptance
        _prescriptions.removeWhere((p) => p.prescriptionId == prescriptionId);

        // Refresh orders list to show any new orders created from this prescription
        final vendorId = await _loginService.getVendorId();
        if (vendorId != null && vendorId.isNotEmpty) {
          await _loadOrders(vendorId);
        }

        // Refresh dashboard prescription count
        if (_dashboardViewModel != null) {
          await _dashboardViewModel!.refreshPrescriptionCount();
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

        // Refresh dashboard prescription count
        if (_dashboardViewModel != null) {
          await _dashboardViewModel!.refreshPrescriptionCount();
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

  // Update order billing (medicines, discount, delivery charge, total)
  Future<Map<String, dynamic>?> updateOrderBilling(
    String orderId,
    List<dynamic> medicines,
    double discountPercent,
    double deliveryCharge,
    double totalAmount,
  ) async {
    try {
      _clearError();
      
      // Convert medicine items to map format
      final medicinesList = medicines.map((item) => {
        'name': item.name,
        'quantity': item.quantity,
        'price': item.price,
      }).toList();
      
      final response = await _service.updateOrderBilling(
        orderId,
        medicinesList,
        discountPercent,
        deliveryCharge,
        totalAmount,
      );
      
      if (response['success'] == true) {
        // Update local order data
        final index = _orders.indexWhere((o) => o.orderId == orderId);
        if (index != -1) {
          _orders[index] = _orders[index].copyWith(
            totalAmount: totalAmount,
            updatedAt: DateTime.now(),
          );
          // Also update filtered orders if filters are active
          _applyFilters();
          if (!_disposed) notifyListeners();
        }
        return response;
      } else {
        _setError('Failed to update order billing');
        return null;
      }
    } catch (e) {
      _setError('Error updating order billing: $e');
      return null;
    }
  }

  // Add medicines and billing details to order
  Future<Map<String, dynamic>?> addOrderMedicines(
    String orderId,
    List<dynamic> medicines,
    double subtotal,
    double discountPercent, // Discount as percentage
    double gstPercent, // GST as percentage
    double deliveryCharges,
    double platformFee,
    double totalAmount,
  ) async {
    try {
      _setLoading(true);
      _clearError();
      
      // Convert medicine items to map format (using medicineName instead of name)
      final medicinesList = medicines.map((item) => {
        'medicineName': item.name,
        'quantity': item.quantity,
        'price': item.price,
      }).toList();
      
      final response = await _service.addOrderMedicines(
        orderId,
        medicinesList,
        subtotal,
        discountPercent, // Send discount as percentage
        gstPercent, // Send GST as percentage
        deliveryCharges,
        platformFee,
        totalAmount,
      );
      
      if (response['success'] == true) {
        // Update local order data with billing details
        final index = _orders.indexWhere((o) => o.orderId == orderId);
        if (index != -1) {
          final responseData = response['data'];
          if (responseData != null) {
            // Parse medicines from response
            List<OrderMedicine>? parsedMedicines;
            if (responseData['medicines'] != null && responseData['medicines'] is List) {
              parsedMedicines = (responseData['medicines'] as List)
                  .map((item) => OrderMedicine.fromJson(item))
                  .toList();
            }
            
            // Calculate discount amount from percentage for storage
            double discountAmount = 0.0;
            if (responseData['discount'] != null) {
              // If API returns discount amount, use it; otherwise calculate from percentage
              discountAmount = _parseDoubleFromResponse(responseData['discount']);
            } else if (discountPercent > 0 && subtotal > 0) {
              discountAmount = subtotal * (discountPercent / 100);
            }
            
            _orders[index] = _orders[index].copyWith(
              subtotal: _parseDoubleFromResponse(responseData['subtotal'] ?? subtotal),
              discount: discountAmount,
              deliveryCharges: _parseDoubleFromResponse(responseData['deliveryCharges'] ?? deliveryCharges),
              gst: _parseDoubleFromResponse(responseData['gst'] ?? 0.0),
              platformFee: _parseDoubleFromResponse(responseData['platformFee'] ?? platformFee),
              totalAmount: _parseDoubleFromResponse(responseData['totalAmount'] ?? totalAmount),
              medicines: parsedMedicines,
              updatedAt: DateTime.now(),
            );
          } else {
            // Fallback if data is not in response
            // Calculate discount amount from percentage
            double discountAmount = subtotal * (discountPercent / 100);
            _orders[index] = _orders[index].copyWith(
              subtotal: subtotal,
              discount: discountAmount,
              deliveryCharges: deliveryCharges,
              totalAmount: totalAmount,
              updatedAt: DateTime.now(),
            );
          }
          // Also update filtered orders if filters are active
          _applyFilters();
          if (!_disposed) notifyListeners();
        }
        return response;
      } else {
        _setError('Failed to add medicines and billing details');
        return null;
      }
    } catch (e) {
      _setError('Error adding medicines and billing details: $e');
      return null;
    } finally {
      _setLoading(false);
    }
  }

  // Get order details with medicines and billing
  Future<Order?> getOrderDetails(String orderId) async {
    try {
      _setLoading(true);
      _clearError();
      
      final response = await _service.getOrderDetails(orderId);
      
      if (response['success'] == true && response['data'] != null) {
        final orderData = response['data'];
        final order = Order.fromJson(orderData);
        
        // Update local order if it exists
        final index = _orders.indexWhere((o) => o.orderId == orderId);
        if (index != -1) {
          _orders[index] = order;
          _applyFilters();
        }
        
        if (!_disposed) notifyListeners();
        return order;
      } else {
        _setError('Failed to fetch order details');
        return null;
      }
    } catch (e) {
      _setError('Error fetching order details: $e');
      return null;
    } finally {
      _setLoading(false);
    }
  }

  // Delete medicine from order
  Future<Map<String, dynamic>?> deleteOrderMedicine(String orderId, String orderMedicineId) async {
    try {
      _setLoading(true);
      _clearError();
      
      final response = await _service.deleteOrderMedicine(orderId, orderMedicineId);
      
      if (response['success'] == true) {
        // Update local order data with updated totals
        final index = _orders.indexWhere((o) => o.orderId == orderId);
        if (index != -1) {
          final updatedTotals = response['updatedTotals'];
          if (updatedTotals != null) {
            // Update medicines list - remove deleted medicine
            List<OrderMedicine>? medicines = _orders[index].medicines;
            if (medicines != null) {
              medicines = medicines.where((med) => med.orderMedicineId != orderMedicineId).toList();
            }
            
            _orders[index] = _orders[index].copyWith(
              subtotal: _parseDoubleFromResponse(updatedTotals['subtotal']),
              discount: _parseDoubleFromResponse(updatedTotals['discount']),
              deliveryCharges: _parseDoubleFromResponse(updatedTotals['deliveryCharges']),
              gst: _parseDoubleFromResponse(updatedTotals['gst']),
              platformFee: _parseDoubleFromResponse(updatedTotals['platformFee']),
              totalAmount: _parseDoubleFromResponse(updatedTotals['totalAmount']),
              medicines: medicines,
              updatedAt: DateTime.now(),
            );
          }
          
          // Also update filtered orders if filters are active
          _applyFilters();
          if (!_disposed) notifyListeners();
        }
        return response;
      } else {
        _setError('Failed to delete medicine');
        return null;
      }
    } catch (e) {
      _setError('Error deleting medicine: $e');
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
    // Defer notifyListeners to avoid calling during build phase
    Future.microtask(() {
      if (!_disposed) notifyListeners();
    });
  }
}
