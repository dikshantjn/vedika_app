import 'package:flutter/material.dart';
import 'package:dio/dio.dart';
import 'package:socket_io_client/socket_io_client.dart' as IO;
import 'package:vedika_healthcare/core/constants/ApiEndpoints.dart';
import 'package:vedika_healthcare/features/Vendor/Registration/Services/VendorLoginService.dart';
import '../../data/services/ProductPartnerOrderService.dart';
import '../../data/models/ProductOrder.dart';
import 'dart:convert';

class ProductPartnerOrdersViewModel extends ChangeNotifier {
  final ProductPartnerOrderService _orderService;
  final VendorLoginService _loginService = VendorLoginService();
  IO.Socket? _socket;

  List<ProductOrder> _orders = [];
  List<ProductOrder> _deliveredOrders = [];
  bool _isLoading = false;
  String? _error;

  ProductPartnerOrdersViewModel(this._orderService) {
    initSocketConnection();
  }

  List<ProductOrder> get orders => _orders;
  List<ProductOrder> get deliveredOrders => _deliveredOrders;
  bool get isLoading => _isLoading;
  String? get error => _error;

  void initSocketConnection() async {
    debugPrint("🚀 Initializing socket connection for product partner orders...");
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
        debugPrint('✅ Socket connected for product partner orders');
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

      // Add event listener for ProductPartnerOrderUpdate
      _socket!.on('ProductPartnerOrderUpdate', (data) async {
        debugPrint('🔄 Product order update received: $data');
        await _handleOrderUpdate(data);
      });

      // Connect to the socket
      _socket!.connect();
      debugPrint('🔄 Attempting to connect socket for product partner orders...');
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

  Future<void> _handleOrderUpdate(dynamic data) async {
    try {
      debugPrint('📦 Processing product order update: $data');
      
      // Parse the data if it's a string
      Map<String, dynamic> orderData = data is String ? json.decode(data) : data;
      debugPrint('📦 Parsed data: $orderData');
      
      // Refresh all orders when any update is received
      String? vendorId = await _loginService.getVendorId();
      if (vendorId != null) {
        await fetchOrders(vendorId);
        await fetchDeliveredOrders(vendorId);
      }
      debugPrint('✅ Refreshed orders after update');
      
    } catch (e) {
      debugPrint('❌ Error handling product order update: $e');
    }
  }

  Future<void> fetchOrders(String vendorId) async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      _orders = await _orderService.getPendingOrdersByVendorId(vendorId);
    } catch (e) {
      _error = e.toString();
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<void> fetchConfirmedOrders(String vendorId) async {
    try {
      final confirmedOrders = await _orderService.getConfirmedOrdersByVendorId(vendorId);
      _orders.addAll(confirmedOrders);
      notifyListeners();
    } catch (e) {
      _error = e.toString();
      notifyListeners();
    }
  }

  Future<void> fetchDeliveredOrders(String vendorId) async {
    try {
      _deliveredOrders = await _orderService.getDeliveredOrdersByVendorId(vendorId);
      notifyListeners();
    } catch (e) {
      _error = e.toString();
      notifyListeners();
    }
  }

  Future<void> updateOrderStatus(String orderId, String status) async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      final updatedOrder = await _orderService.updateOrderStatus(orderId, status);
      
      // Update the order in the appropriate list
      if (status == 'delivered') {
        // Remove from orders list and add to delivered orders
        _orders.removeWhere((order) => order.orderId == orderId);
        _deliveredOrders.add(updatedOrder);
      } else {
        // Update in orders list
        final index = _orders.indexWhere((order) => order.orderId == orderId);
        if (index != -1) {
          _orders[index] = updatedOrder;
        }
      }
    } catch (e) {
      _error = e.toString();
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  @override
  void dispose() {
    if (_socket != null) {
      _socket!.disconnect();
      _socket!.dispose();
    }
    super.dispose();
  }
} 