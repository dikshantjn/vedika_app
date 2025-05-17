import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:intl/intl.dart';
import 'package:vedika_healthcare/core/auth/data/repositories/AuthRepository.dart';
import 'package:vedika_healthcare/core/auth/data/services/StorageService.dart';
import 'package:vedika_healthcare/core/constants/ApiEndpoints.dart';
import 'package:vedika_healthcare/features/TrackOrder/data/Services/TrackOrderService.dart';
import 'package:vedika_healthcare/features/Vendor/BloodBankAgencyVendor/data/model/BloodBankBooking.dart';
import 'package:vedika_healthcare/features/ambulance/data/models/AmbulanceBooking.dart';
import 'package:web_socket_channel/io.dart';
import 'package:vedika_healthcare/features/Vendor/MedicalStoreVendor/data/models/MedicineOrderModel.dart';
import 'package:vedika_healthcare/features/Vendor/MedicalStoreVendor/data/models/CartModel.dart';
import 'package:vedika_healthcare/features/Vendor/ProductPartner/data/models/ProductOrder.dart';
import 'package:socket_io_client/socket_io_client.dart' as IO;
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class TrackOrderViewModel extends ChangeNotifier {
  final TrackOrderService _service = TrackOrderService(); // Service instance

  List<MedicineOrderModel> _orders = [];
  Map<String, List<CartModel>> _orderItems = {}; // ✅ Store cart items by orderId
  bool _isLoading = false;
  String? _error;
  IOWebSocketChannel? _channel; // WebSocket channel
  String? _lastStatusUpdate; // Add this to track the last status update

  List<MedicineOrderModel> get orders => _orders;
  Map<String, List<CartModel>> get orderItems => _orderItems;
  bool get isLoading => _isLoading;
  String? get error => _error;
  String? get lastStatusUpdate => _lastStatusUpdate; // Add getter for last status update

  List<AmbulanceBooking> _ambulanceBookings = [];
  List<AmbulanceBooking> get ambulanceBookings => _ambulanceBookings;

  List<BloodBankBooking> _bloodBankBookings = [];
  List<BloodBankBooking> get bloodBankBookings => _bloodBankBookings;

  IO.Socket? _socket;

  List<ProductOrder> _productOrders = [];
  List<ProductOrder> get productOrders => _productOrders;

  void _attemptReconnect() {
    Future.delayed(Duration(seconds: 2), () {
      if (_socket != null && !_socket!.connected) {
        debugPrint('🔄 Attempting to reconnect...');
        _socket!.connect();
      }
    });
  }

  void initSocketConnection() async {
    print("initSocketConnection started executing");
    try {
      String? userId = await StorageService.getUserId();
      if (userId == null) {
        debugPrint("❌ User ID not found for socket registration");
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
        'query': {'userId': userId},
      });

      // Set up event listeners before connecting
      _socket!.onConnect((_) async {
        debugPrint('✅ Socket connected');
        _socket!.emit('register', userId);
        // Fetch initial data after socket connection
        await Future.wait([
          fetchOrdersAndCartItems(),
          fetchActiveAmbulanceBookings(),
          fetchBloodBankBookings(),
          fetchProductOrders(),
        ]);
        debugPrint("📦 Initial orders fetched after socket connection");
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

      // Single event listener for all order status updates
      _socket!.on('orderStatusUpdated', (data) {
        debugPrint('📦 Order status update received: $data');
        _handleOrderStatusUpdate(data);
      });

      // Add ambulance booking status update listener
      _socket!.on('ambulanceBookingUpdated', (data) async {
        debugPrint('🚑 Ambulance booking update received: $data');
        await _handleAmbulanceStatusUpdate(data);
      });

      // Add blood bank booking status update listener
      _socket!.on('bloodBankBookingUpdated', (data) async {
        debugPrint('🩸 Blood bank booking update received: $data');
        await _handleBloodBankStatusUpdate(data);
      });

      // Add ping/pong handlers to keep connection alive
      _socket!.on('ping', (_) {
        _socket!.emit('pong');
      });

      // Connect to the socket
      _socket!.connect();
      debugPrint('🔄 Attempting to connect socket...');
    } catch (e) {
      debugPrint("❌ Socket connection error: $e");
      _attemptReconnect();
    }
  }

  // Handle order status updates
  void _handleOrderStatusUpdate(dynamic data) async {
    try {
      debugPrint('📦 Processing order status update: $data');
      
      // Parse the data if it's a string
      Map<String, dynamic> orderData = data is String ? json.decode(data) : data;
      debugPrint('📦 Parsed data: $orderData');
      
      // Get orderId and status from the data
      final orderId = orderData['orderId'];
      final prescriptionId = orderData['prescriptionId'];
      final productOrderId = orderData['productOrderId'];
      final status = orderData['newStatus'] ?? orderData['status'];
      
      debugPrint('📦 Raw orderId: $orderId (${orderId.runtimeType})');
      debugPrint('📦 Raw status: $status (${status.runtimeType})');
      debugPrint('📦 Raw productOrderId: $productOrderId (${productOrderId.runtimeType})');
      
      // Refresh all orders first
      await Future.wait([
        fetchOrdersAndCartItems(),
        fetchActiveAmbulanceBookings(),
        fetchBloodBankBookings(),
        fetchProductOrders(),
      ]);
      
      // Handle product order update
      if (productOrderId != null && status != null) {
        debugPrint('📦 Processing product order update');
        
        // Find and update the product order in the list
        final productOrderIndex = _productOrders.indexWhere((order) => order.orderId == productOrderId);
        if (productOrderIndex != -1) {
          debugPrint('📦 Found product order at index: $productOrderIndex');
          debugPrint('📦 Current status: ${_productOrders[productOrderIndex].status}');
          debugPrint('📦 New status: $status');
          
          // Update the product order status
          _productOrders[productOrderIndex] = _productOrders[productOrderIndex].copyWith(
            status: status.toLowerCase(),
          );
          
          // Store the status update message
          _lastStatusUpdate = _getProductOrderStatusMessage(status);
          
          debugPrint('✅ Product order $productOrderId status updated to: $status');
          debugPrint('✅ Updated order status: ${_productOrders[productOrderIndex].status}');
        } else {
          debugPrint('❌ Product order not found with ID: $productOrderId');
        }
      }
      // Handle regular order update
      else if ((orderId != null || prescriptionId != null) && status != null) {
        // Find and update the order in the orders list
        final orderIndex = _orders.indexWhere((order) => order.orderId == orderId);
        if (orderIndex != -1) {
          debugPrint('📦 Found order at index: $orderIndex');
          
          // Update the order status
          _orders[orderIndex] = _orders[orderIndex].copyWith(
            orderStatus: status,
            updatedAt: DateTime.now(),
          );
          
          // Store the status update message
          _lastStatusUpdate = _getStatusMessage(status, isPrescription: false);
          
          debugPrint('✅ Order $orderId status updated to: $status');
        } else if (prescriptionId != null) {
          // Handle prescription status update
          _lastStatusUpdate = _getStatusMessage(status, isPrescription: true);
          debugPrint('✅ Prescription $prescriptionId status updated to: $status');
        } else {
          debugPrint('❌ Order not found with ID: $orderId');
        }
      } else {
        debugPrint('❌ Missing orderId/prescriptionId/productOrderId or status in data: $orderData');
      }
      
      // Notify listeners only once after all updates are complete
      notifyListeners();
      
    } catch (e, stackTrace) {
      debugPrint('❌ Error handling order status update: $e');
      debugPrint('❌ Stack trace: $stackTrace');
      // Refresh all orders in case of error
      await Future.wait([
        fetchOrdersAndCartItems(),
        fetchActiveAmbulanceBookings(),
        fetchBloodBankBookings(),
        fetchProductOrders(),
      ]);
      notifyListeners();
    }
  }

  // Handle ambulance booking status updates
  Future<void> _handleAmbulanceStatusUpdate(dynamic data) async {
    try {
      debugPrint('🚑 Processing ambulance status update: $data');
      
      // Parse the data if it's a string
      Map<String, dynamic> bookingData = data is String ? json.decode(data) : data;
      debugPrint('🚑 Parsed data: $bookingData');
      
      final requestId = bookingData['requestId'];
      final status = bookingData['status'];
      
      if (requestId != null && status != null) {
        // Find and update the booking in the list
        final bookingIndex = _ambulanceBookings.indexWhere((booking) => booking.requestId == requestId);
        
        if (bookingIndex != -1) {
          debugPrint('🚑 Found booking at index: $bookingIndex');
          
          // Update the booking status
          _ambulanceBookings[bookingIndex] = _ambulanceBookings[bookingIndex].copyWith(
            status: status,
          );
          
          // Notify listeners about the update
          notifyListeners();
          
          debugPrint('✅ Ambulance booking $requestId status updated to: $status');
        } else {
          debugPrint('❌ Ambulance booking not found with ID: $requestId');
          
          // If booking not found, refresh bookings
          await fetchActiveAmbulanceBookings();
        }
      } else {
        debugPrint('❌ Missing requestId or status in data: $bookingData');
      }
    } catch (e, stackTrace) {
      debugPrint('❌ Error handling ambulance status update: $e');
      debugPrint('❌ Stack trace: $stackTrace');
    }
  }

  // Handle blood bank booking status updates
  Future<void> _handleBloodBankStatusUpdate(dynamic data) async {
    try {
      debugPrint('🩸 Processing blood bank status update: $data');
      
      // Parse the data if it's a string
      Map<String, dynamic> bookingData = data is String ? json.decode(data) : data;
      debugPrint('🩸 Parsed data: $bookingData');
      
      final requestId = bookingData['requestId'];
      final status = bookingData['status'];
      
      if (requestId != null && status != null) {
        // Find and update the booking in the list
        final bookingIndex = _bloodBankBookings.indexWhere((booking) => booking.bookingId == requestId);
        
        if (bookingIndex != -1) {
          debugPrint('🩸 Found booking at index: $bookingIndex');
          
          // Update the booking status
          _bloodBankBookings[bookingIndex] = _bloodBankBookings[bookingIndex].copyWith(
            status: status,
          );
          
          // Notify listeners about the update
          notifyListeners();
          
          debugPrint('✅ Blood bank booking $requestId status updated to: $status');
        } else {
          debugPrint('❌ Blood bank booking not found with ID: $requestId');
          
          // If booking not found, refresh bookings
          await fetchBloodBankBookings();
        }
      } else {
        debugPrint('❌ Missing requestId or status in data: $bookingData');
        debugPrint('❌ requestId is null: ${requestId == null}');
        debugPrint('❌ status is null: ${status == null}');
      }
    } catch (e, stackTrace) {
      debugPrint('❌ Error handling blood bank status update: $e');
      debugPrint('❌ Stack trace: $stackTrace');
    }
  }

  // Helper method to get user-friendly status messages
  String _getStatusMessage(String status, {bool isPrescription = false}) {
    if (isPrescription) {
      // Handle prescription status messages
      switch (status) {
        case 'Pending':
          return 'Prescription Sent';
        case 'PrescriptionVerified':
          return 'Prescription Verified';
        default:
          return status;
      }
    } else {
      // Handle order status messages
      switch (status) {
        case 'Pending':
          return 'Prescription Sent';
        case 'Accepted':
          return 'Order Confirmed';
        case 'AddedItemsInCart':
          return 'Items Added';
        case 'PaymentConfirmed':
          return 'Order Placed';
        case 'ReadyForPickup':
          return 'Order Placed';
        case 'OutForDelivery':
          return 'Out for Delivery';
        case 'Delivered':
          return 'Delivered';
        default:
          return status;
      }
    }
  }

  // Helper method to get step index for timeline
  int _getCurrentStepIndex(String orderStatus) {
    Map<String, int> statusStepMapping = {
      "Pending": 0,
      "Accepted": 1,  // This will be handled differently for prescription vs order
      "AddedItemsInCart": 2,
      "PaymentConfirmed": 3,
      "ReadyForPickup": 3,  // Same step as PaymentConfirmed
      "OutForDelivery": 4,
      "Delivered": 5,
    };
    return statusStepMapping[orderStatus] ?? 0;
  }

  // Helper method to get product order status messages
  String _getProductOrderStatusMessage(String status) {
    // Convert status to lowercase for consistent comparison
    final lowerStatus = status.toLowerCase();
    
    switch (lowerStatus) {
      case 'pending':
        return 'Order Placed';
      case 'confirmed':
        return 'Order Confirmed';
      case 'processing':
        return 'Order Processing';
      case 'shipped':
        return 'Order Shipped';
      case 'out_for_delivery':
        return 'Out for Delivery';
      case 'delivered':
        return 'Delivered';
      case 'cancelled':
        return 'Order Cancelled';
      default:
        return status;
    }
  }

  // Helper method to get step index for product order timeline
  int _getProductOrderStepIndex(String orderStatus) {
    // Convert status to lowercase for consistent comparison
    final lowerStatus = orderStatus.toLowerCase();
    
    Map<String, int> statusStepMapping = {
      "pending": 0,
      "confirmed": 1,
      "processing": 2,
      "shipped": 3,
      "out_for_delivery": 4,
      "delivered": 5,
      "cancelled": -1, // Special case for cancelled orders
    };
    return statusStepMapping[lowerStatus] ?? 0;
  }

  // Clear the last status update
  void clearLastStatusUpdate() {
    _lastStatusUpdate = null;
    notifyListeners();
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
      _orders = []; // Set empty list instead of showing error
      _error = null; // Clear any error message
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

  /// **Format Delivery Date**
  String formatDeliveryDate(DateTime? dateTime) {
    if (dateTime == null) return "Calculating...";
    try {
      return DateFormat("EEE, dd MMM yyyy • hh:mm a").format(dateTime);
    } catch (e) {
      return "Invalid Date";
    }
  }

  /// ✅ Fetch active ambulance bookings for current user
  Future<void> fetchActiveAmbulanceBookings() async {
    _isLoading = true;
    notifyListeners();

    debugPrint("📦 Starting to fetch active ambulance bookings...");

    try {
      String? userId = await StorageService.getUserId();
      debugPrint("👤 User ID: $userId");

      if (userId == null) {
        debugPrint("❌ User ID not found");
        throw Exception("User ID not found");
      }

      _ambulanceBookings = await _service.fetchActiveAmbulanceBookings(userId);
      debugPrint("✅ Ambulance bookings fetched: ${_ambulanceBookings.length}");

      for (var booking in _ambulanceBookings) {
        debugPrint("🚑 Booking ID: ${booking.requestId}, Status: ${booking.status}");
      }

      _error = null;
    } catch (e, stackTrace) {
      debugPrint("❌ Error fetching ambulance bookings: $e");
      debugPrint("🔍 Stack Trace:\n$stackTrace");

      _ambulanceBookings = [];
      _error = "No Ambulance Booking Found";
    } finally {
      _isLoading = false;
      notifyListeners();
      debugPrint("📦 Done fetching ambulance bookings.");
    }
  }

  /// ✅ Fetch blood bank bookings for current user
  Future<void> fetchBloodBankBookings() async {
    _isLoading = true;
    notifyListeners();

    debugPrint("📦 Starting to fetch blood bank bookings...");

    try {
      String? userId = await StorageService.getUserId();
      String? token = await AuthRepository().getToken();

      if (userId == null || token == null) {
        throw Exception("User ID or token not found");
      }

      _bloodBankBookings = await _service.getBookings(userId, token);
      debugPrint("✅ Blood bank bookings fetched: ${_bloodBankBookings.length}");

      for (var booking in _bloodBankBookings) {
        debugPrint("🩸 Booking ID: ${booking.bookingId}, Status: ${booking.status}");
      }

      _error = null;
    } catch (e, stackTrace) {
      debugPrint("❌ Error fetching blood bank bookings: $e");
      debugPrint("🔍 Stack Trace:\n$stackTrace");

      _bloodBankBookings = [];
      _error = "No Blood Bank Bookings Found";
    } finally {
      _isLoading = false;
      notifyListeners();
      debugPrint("📦 Done fetching blood bank bookings.");
    }
  }

  /// ✅ Fetch product orders for current user
  Future<void> fetchProductOrders() async {
    _isLoading = true;
    notifyListeners();

    debugPrint("📦 Starting to fetch product orders...");

    try {
      String? userId = await StorageService.getUserId();
      debugPrint("👤 User ID: $userId");

      if (userId == null) {
        debugPrint("❌ User ID not found");
        throw Exception("User ID not found");
      }

      _productOrders = await _service.fetchProductOrders(userId);
      debugPrint("✅ Product orders fetched: ${_productOrders.length}");

      for (var order in _productOrders) {
        debugPrint("📦 Order ID: ${order.orderId}, Status: ${order.status}");
        debugPrint("📦 Order Items: ${order.orderItems?.length ?? 0} items");
      }

      _error = null;
    } catch (e, stackTrace) {
      debugPrint("❌ Error fetching product orders: $e");
      debugPrint("🔍 Stack Trace:\n$stackTrace");

      _productOrders = [];
      _error = "No Product Orders Found";
    } finally {
      _isLoading = false;
      notifyListeners();
      debugPrint("📦 Done fetching product orders.");
    }
  }

  /// **Dispose WebSocket when not needed**
  @override
  void dispose() {
    if (_socket != null) {
      _socket!.disconnect();
      _socket!.dispose();
    }
    _channel?.sink.close();
    super.dispose();
  }
}