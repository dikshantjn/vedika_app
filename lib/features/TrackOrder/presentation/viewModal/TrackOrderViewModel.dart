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

  /// **✅ Initialize WebSocket Connection**
  void initWebSocket() async {
    String? userId = await StorageService.getUserId();
    if (userId == null) return;

    try {
      _channel = IOWebSocketChannel.connect("ws://192.168.1.44:5000/orders/$userId");

      _channel!.stream.listen(
            (message) {
          debugPrint("🔹 WebSocket Message Received: $message");

          Map<String, dynamic> data = jsonDecode(message);
          String eventType = data['eventType']; // Example: "orderUpdated"
          String orderId = data['orderId']; // Order that changed

          if (eventType == "orderUpdated") {
            _updateOrderStatus(orderId, data['newStatus']);
          }
        },
        onError: (error) {
          debugPrint("❌ WebSocket Error: $error");
        },
        onDone: () {
          debugPrint("🔴 WebSocket Disconnected.");
        },
      );
    } catch (e) {
      debugPrint("❌ WebSocket Connection Failed: $e");
    }
  }

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
    } catch (e) {
      _error = 'No Order Found';
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

  /// **✅ Update Order Status in the List**
  void _updateOrderStatus(String orderId, String newStatus) {
    for (var order in _orders) {
      if (order.orderId == orderId) {
        order.orderStatus = newStatus; // Update status
        break;
      }
    }
    notifyListeners(); // 🔄 Refresh UI
  }

  /// **Format Delivery Date**
  String formatDeliveryDate(DateTime? dateTime) {
    if (dateTime == null) return "Calculating...";
    try {
      return DateFormat("EEE, dd MMM yyyy • hh:mm a").format(dateTime);
    } catch (e) {
      return "Invalid Date";
    }
  }

  /// **Dispose WebSocket when not needed**
  @override
  void dispose() {
    _channel?.sink.close();
    super.dispose();
  }
}
