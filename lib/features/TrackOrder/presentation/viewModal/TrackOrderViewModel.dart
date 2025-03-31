import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:intl/intl.dart';
import 'package:vedika_healthcare/core/auth/data/services/StorageService.dart';
import 'package:vedika_healthcare/features/TrackOrder/data/Services/TrackOrderService.dart';
import 'package:web_socket_channel/io.dart';
import 'package:vedika_healthcare/features/Vendor/MedicalStoreVendor/data/models/MedicineOrderModel.dart';
import 'package:vedika_healthcare/features/Vendor/MedicalStoreVendor/data/models/CartModel.dart';

class TrackOrderViewModel extends ChangeNotifier {
  final TrackOrderService _service = TrackOrderService(); // Service instance

  List<MedicineOrderModel> _orders = [];
  Map<String, List<CartModel>> _orderItems = {}; // ✅ Store cart items by orderId
  bool _isLoading = false;
  String? _error;
  IOWebSocketChannel? _channel; // WebSocket channel

  List<MedicineOrderModel> get orders => _orders;
  Map<String, List<CartModel>> get orderItems => _orderItems;
  bool get isLoading => _isLoading;
  String? get error => _error;

  /// **✅ Fetch Orders and Cart Items**
  Future<void> fetchOrdersAndCartItems() async {
    _isLoading = true;
    notifyListeners();

    try {
      String? userId = await StorageService.getUserId();
      if (userId == null) throw Exception("User ID not found");

      _orders = await _service.fetchUserOrders(userId);
      _error = null;
      _orderItems.clear(); // Clear existing cart items

      for (var order in _orders) {
        List<CartModel> cartItems = await fetchCartItemsByOrderId(order.orderId);
        _orderItems[order.orderId] = cartItems; // ✅ Store cart items by order ID
      }

      _connectWebSocket(userId); // Connect WebSocket after fetching orders
    } catch (e) {
      _error = 'Failed to fetch orders: ${e.toString()}';
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  /// **✅ Fetch Cart Items by Order ID**
  Future<List<CartModel>> fetchCartItemsByOrderId(String orderId) async {
    try {
      return await _service.fetchCartItemsByOrderId(orderId);
    } catch (e) {
      debugPrint("❌ Error fetching cart items: $e");
      return [];
    }
  }

  /// **✅ Connect WebSocket for Real-time Updates**
  void _connectWebSocket(String userId) {
    final wsUrl = 'ws://your-server-ip:8080/track-orders/$userId';
    _channel = IOWebSocketChannel.connect(wsUrl);

    _channel!.stream.listen((message) {
      final data = json.decode(message);
      _updateOrderStatus(data['orderId'], data['status']);
    }, onError: (error) {
      print("WebSocket error: $error");
    });
  }

  /// **✅ Update Order Status in List**
  void _updateOrderStatus(String orderId, String status) {
    final index = _orders.indexWhere((o) => o.orderId == orderId);
    if (index != -1) {
      _orders[index] = _orders[index].copyWith(orderStatus: status, updatedAt: DateTime.now());
      notifyListeners();
    }
  }


  String formatDeliveryDate(DateTime? dateTime) {
    if (dateTime == null) return "Calculating...";

    try {
      return DateFormat("EEE, dd MMM yyyy • hh:mm a").format(dateTime);
    } catch (e) {
      return "Invalid Date";
    }
  }


  @override
  void dispose() {
    _channel?.sink.close();
    super.dispose();
  }
}
