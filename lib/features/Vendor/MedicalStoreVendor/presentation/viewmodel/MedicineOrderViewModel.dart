import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:socket_io_client/socket_io_client.dart' as IO;
import 'package:vedika_healthcare/core/constants/ApiEndpoints.dart';
import 'package:vedika_healthcare/core/auth/data/models/UserModel.dart';
import 'package:vedika_healthcare/features/Vendor/MedicalStoreVendor/data/models/CartModel.dart';
import 'package:vedika_healthcare/features/Vendor/MedicalStoreVendor/data/models/MedicineOrderModel.dart';
import 'package:vedika_healthcare/features/Vendor/MedicalStoreVendor/data/models/MedicineProduct.dart';
import 'package:vedika_healthcare/features/Vendor/MedicalStoreVendor/data/models/PrescriptionRequestModel.dart';
import 'package:vedika_healthcare/features/Vendor/MedicalStoreVendor/data/services/MedicineProductService.dart';
import 'package:vedika_healthcare/features/Vendor/MedicalStoreVendor/data/services/OrderCartService.dart';
import 'package:vedika_healthcare/features/Vendor/MedicalStoreVendor/data/services/PrescriptionRequestService.dart';
import 'package:vedika_healthcare/features/Vendor/MedicalStoreVendor/data/services/OrderService.dart';
import 'package:vedika_healthcare/features/Vendor/Registration/Services/VendorLoginService.dart';
import 'dart:convert';

import 'package:vedika_healthcare/features/orderHistory/data/reports/invoice_pdf.dart';

class MedicineOrderViewModel extends ChangeNotifier {
  final PrescriptionRequestService _prescriptionService = PrescriptionRequestService();
  final OrderService _orderService = OrderService();
  final MedicineProductService _medicineService = MedicineProductService();
  final VendorLoginService _loginService = VendorLoginService();
  final OrderCartService _cartService = OrderCartService();
  IO.Socket? _socket;
  bool mounted = true;

  List<MedicineOrderModel> _orders = [];
  List<PrescriptionRequestModel> _prescriptionRequests = [];
  List<MedicineProduct> _medicineSuggestions = [];
  List<CartModel> _cart = [];

  bool _isLoading = false;
  bool _isProcessingOrder = false;
  bool _isLoadingPrescriptions = false;
  bool _isLoadingOrders = false;
  List<MedicineOrderModel> get orders => _orders;
  List<PrescriptionRequestModel> get prescriptionRequests => _prescriptionRequests;
  List<MedicineProduct> get medicineSuggestions => _medicineSuggestions;
  List<CartModel> get cart => _cart;

  bool get isLoading => _isLoading;
  bool get isProcessingOrder => _isProcessingOrder;
  List<CartModel> _fetchedCartItems = [];

  List<CartModel> get fetchedCartItems => _fetchedCartItems;

  bool get isLoadingRequests => _isLoadingPrescriptions;
  bool get isLoadingOrders => _isLoadingOrders;

  bool isAccepting = false;
  String acceptMessage = "";

  String _orderStatus = "Loading...";
  String get orderStatus => _orderStatus;
  bool isOrderAccepted = false;

  // Self delivery related variables
  bool _isEnablingSelfDelivery = false;
  bool get isEnablingSelfDelivery => _isEnablingSelfDelivery;
  bool _isSelfDeliveryEnabled = false;
  bool get isSelfDeliveryEnabled => _isSelfDeliveryEnabled;

  bool _disposed = false;

  // Add callbacks
  Function(String)? onOrderUpdate;
  Function(String)? onOrderStatusUpdate;
  Function()? onOrdersListUpdate;  // New callback for orders list updates

  bool _isGeneratingInvoice = false;
  String _generatingInvoiceForOrderId = '';  // Add this line to track specific order
  bool get isGeneratingInvoice => _isGeneratingInvoice;
  bool isGeneratingInvoiceForOrder(String orderId) => _isGeneratingInvoice && _generatingInvoiceForOrderId == orderId;

  MedicineOrderViewModel() {
    initSocketConnection();
  }

  void initSocketConnection() async {
    debugPrint("🚀 Initializing socket connection for medicine orders...");
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
        debugPrint('✅ Socket connected for medicine orders');
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

      // Add event listener for MedicineOrderUpdate
      _socket!.on('MedicineOrderUpdate', (data) async {
        debugPrint('🔄 Medicine order update received: $data');
        await _handleMedicineOrderUpdate(data);
      });

      // Add ping/pong handlers
      _socket!.on('ping', (_) {
        _socket!.emit('pong');
      });

      // Connect to the socket
      _socket!.connect();
      debugPrint('🔄 Attempting to connect socket for medicine orders...');
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

  Future<void> _handleMedicineOrderUpdate(dynamic data) async {
    try {
      debugPrint('💊 Processing medicine order update: $data');
      
      // Parse the data if it's a string
      Map<String, dynamic> orderData = data is String ? json.decode(data) : data;
      debugPrint('💊 Parsed data: $orderData');
      
      final prescriptionId = orderData['prescriptionId'];
      final userId = orderData['userId'];
      final distance = orderData['distance'];
      
      if (prescriptionId != null) {
        debugPrint('✅ New medicine order update received, refreshing data...');
        
        // Refresh both orders and prescription requests
        await Future.wait([
          fetchOrders(),
          fetchPrescriptionRequests(),
        ]);
        
        // Notify the screen to refresh cart items
        if (onOrderUpdate != null) {
          onOrderUpdate!(prescriptionId);
        }

        // Fetch and notify order status update
        if (onOrderStatusUpdate != null) {
          await fetchOrderStatus(prescriptionId);
          onOrderStatusUpdate!(prescriptionId);
        }
        
        debugPrint('✅ Refreshed orders and prescription requests after update');
      } else {
        debugPrint('❌ Missing prescriptionId in data: $orderData');
      }
    } catch (e, stackTrace) {
      debugPrint('❌ Error handling medicine order update: $e');
      debugPrint('❌ Stack trace: $stackTrace');
    }
  }

  @override
  void dispose() {
    _disposed = true;
    if (_socket != null) {
      _socket!.disconnect();
      _socket!.dispose();
    }
    super.dispose();
  }

  // Helper method to safely notify listeners
  void _safeNotifyListeners() {
    if (!_disposed) {
      notifyListeners();
    }
  }

  void _setProcessingOrder(bool value) {
    if (_disposed) return;
    _isProcessingOrder = value;
    _safeNotifyListeners();
  }

  /// **🔹 Fetch Prescription Requests**
  Future<void> fetchPrescriptionRequests() async {
    if (_disposed) return;
    
    String? vendorId = await _loginService.getVendorId();

    _isLoadingPrescriptions = true;
    _safeNotifyListeners();

    try {
      _prescriptionRequests = await _prescriptionService.fetchPrescriptionRequests(vendorId);
    } catch (e) {
      debugPrint("Error fetching prescription requests: $e");
      _prescriptionRequests = [];
    } finally {
      if (!_disposed) {
        _isLoadingPrescriptions = false;
        _safeNotifyListeners();
      }
    }
  }

  Future<void> fetchOrders() async {
    if (_disposed) return;
    
    _isLoadingOrders = true;
    _safeNotifyListeners();

    try {
      String? vendorId = await _loginService.getVendorId();
      _orders = await _orderService.getOrders(vendorId!);
    } catch (e) {
      debugPrint("Error fetching orders: $e");
      _orders = [];
    } finally {
      if (!_disposed) {
        _isLoadingOrders = false;
        _safeNotifyListeners();
      }
    }
  }

  /// **🔹 Accept Prescription**
  Future<void> acceptPrescription(String prescriptionId) async {
    if (_disposed) return;
    
    _setProcessingOrder(true);
    try {
      String? vendorId = await _loginService.getVendorId();
      if (vendorId?.isEmpty ?? true) throw Exception("Vendor ID not found.");

      bool success = await _prescriptionService.acceptPrescription(prescriptionId, vendorId!);

      if (success) {
        bool statusUpdated = await _orderService.updatePrescriptionStatus(prescriptionId);

        if (statusUpdated) {
          print("✅ Prescription status updated successfully!");
        } else {
          print("❌ Failed to update prescription status.");
        }

        if (!_disposed) {
          await fetchOrders();
        }
      }
    } catch (e) {
      debugPrint("Error accepting prescription: $e");
    } finally {
      if (!_disposed) {
        _setProcessingOrder(false);
      }
    }
  }

  /// **🔹 Fetch Prescription URL**
  Future<String?> fetchPrescriptionUrl(String prescriptionId) async {
    try {
      return await _prescriptionService.fetchPrescriptionUrl(prescriptionId);
    } catch (e) {
      debugPrint("Error fetching prescription URL: $e");
      return null;
    }
  }

  /// **🔹 Search Medicines**
  Future<void> searchMedicines(String query) async {
    if (_disposed) return;
    
    if (query.isEmpty) {
      _medicineSuggestions = [];
      _safeNotifyListeners();
      return;
    }

    try {
      String? vendorId = await _loginService.getVendorId();
      if (vendorId != null) {
        _medicineSuggestions = await _medicineService.getMedicineSuggestions(vendorId, query);
      }
    } catch (e) {
      debugPrint("Error searching medicines: $e");
    } finally {
      if (!_disposed) {
        _safeNotifyListeners();
      }
    }
  }

  /// **🔹 Clear Medicine Search Results**
  void clearSearchResults() {
    if (_disposed) return;
    _medicineSuggestions = [];
    _safeNotifyListeners();
  }

  void clearCarts() {
    if (_disposed) return;
    _cart = [];
    _safeNotifyListeners();
  }

  /// **🔹 Add Medicine to Temporary Cart**
  void addMedicineToLocalCart(MedicineProduct medicine, int quantity, String orderId, BuildContext context) {
    if (_disposed) return;
    
    if (quantity <= 0) {
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text("❌ Quantity should be greater than zero")));
      return;
    }

    int existingIndex = _cart.indexWhere((item) => item.productId == medicine.productId);
    if (existingIndex != -1) {
      _cart[existingIndex].quantity += quantity;
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text("✅ Quantity updated for ${medicine.name}")));
    } else {
      _cart.add(CartModel(
        cartId: '',
        productId: medicine.productId,
        name: medicine.name,
        price: medicine.price,
        quantity: quantity,
        orderId: orderId,
      ));
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text("✅ ${medicine.name} added to cart")));
    }

    _safeNotifyListeners();
  }

  /// **🔹 Add Cart Items to Database**
  Future<String> addToCartDB(String orderId) async {
    try {
      for (var item in _cart) {
        String message = await _cartService.addToCart(item);
        if (message.startsWith("❌")) return message; // Stop if there's an error
      }

      // ✅ Clear the cart after adding items
      _cart.clear();
      notifyListeners();

      // ✅ Update order status after adding items to cart
      await updateOrderStatus(orderId, "AddedItemsInCart");

      return "✅ All items added to cart successfully and order status updated";
    } catch (e) {
      debugPrint("Error adding to cart DB: $e");
      return "❌ Error adding to cart DB: $e";
    }
  }

  /// **🔹 Fetch Cart Items**
  Future<void> fetchCart() async {
    try {
      String? vendorId = await _loginService.getVendorId();
      if (vendorId?.isEmpty ?? true) throw Exception("Vendor ID not found.");

      _cart = await _cartService.fetchCart(vendorId!);
    } catch (e) {
      debugPrint("Error fetching cart: $e");
    } finally {
      notifyListeners();
    }
  }

  Future<void> fetchCartItems(String orderId) async {
    try {
      _fetchedCartItems = await _cartService.fetchCartByOrderId(orderId); // Store fetched items separately
      notifyListeners(); // Notify UI about the update
    } catch (e) {
      debugPrint("Error fetching cart: $e");
    }
  }

  /// **🔹 Delete Cart Item**
  Future<bool> deleteCartItem(String cartId) async {
    try {
      String message = await _cartService.deleteCartItem(cartId);
      debugPrint(message);

      if (message.startsWith("✅")) {
        _cart.removeWhere((item) => item.cartId == cartId); // Remove item from local list
        notifyListeners(); // Update UI
        return true; // Deletion successful
      } else {
        debugPrint("❌ Failed to delete cart item: $message");
        return false; // Deletion failed
      }
    } catch (e) {
      debugPrint("🚨 Error deleting cart item: $e");
      return false; // Exception occurred
    }
  }

  Future<void> updateCartItemQuantity(String cartId, String type, BuildContext context) async {
    _isLoading = true;
    notifyListeners();

    final result = await _cartService.updateCartQuantity(cartId, type);

    _isLoading = false;
    notifyListeners();

    if (result.startsWith("✅")) {
      // Update quantity in local list
      int index = fetchedCartItems.indexWhere((item) => item.cartId == cartId);
      if (index != -1) {
        int currentQty = fetchedCartItems[index].quantity;
        int updatedQty = type == "increment" ? currentQty + 1 : currentQty - 1;
        fetchedCartItems[index] = fetchedCartItems[index].copyWith(quantity: updatedQty);
        notifyListeners();
      }

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(result)),
      );
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(result)),
      );
    }
  }

  Future<void> acceptOrder(String orderId) async {
    if (_disposed) return;
    
    String? vendorId = await _loginService.getVendorId();

    try {
      isAccepting = true;
      acceptMessage = "";
      isOrderAccepted = false;
      _safeNotifyListeners();

      bool result = await _orderService.acceptOrder(orderId, vendorId!);

      if (result) {
        isOrderAccepted = true;
        acceptMessage = "Order Accepted Successfully";
      } else {
        acceptMessage = "Failed to Accept Order";
      }
    } catch (e) {
      acceptMessage = "Something went wrong";
      print("Error in ViewModel accepting order: $e");
    } finally {
      if (!_disposed) {
        isAccepting = false;
        _safeNotifyListeners();
      }
    }
  }

  // ✅ Method to fetch order status
  Future<void> fetchOrderStatus(String orderId) async {
    String? vendorId = await _loginService.getVendorId();

    try {
      _orderStatus = await _orderService.getOrderStatus(orderId, vendorId!);
      notifyListeners();  // Notify listeners to update the UI
    } catch (e) {
      _orderStatus = 'Error fetching status';
      notifyListeners();  // Notify listeners to update the UI
    }
  }

  // Add this method in your MedicineOrderViewModel class
  Future<void> updateOrderStatus(String orderId, String newStatus) async {
    if (_disposed) return;
    
    try {
      bool result = await _orderService.updateOrderStatus(orderId, newStatus);

      if (result) {
        _orderStatus = newStatus;
        // Fetch updated orders list
        await fetchOrders();
        // Notify about orders list update
        if (onOrdersListUpdate != null) {
          onOrdersListUpdate!();
        }
        _safeNotifyListeners();
      } else {
        throw Exception("Failed to update status");
      }
    } catch (e) {
      debugPrint("Error updating order status: $e");
    }
  }

  // ✅ Method to enable self delivery
  Future<void> enableSelfDelivery(String orderId) async {
    if (_disposed) return;
    
    try {
      _isEnablingSelfDelivery = true;
      _safeNotifyListeners();

      bool result = await _orderService.enableSelfDelivery(orderId);

      if (result) {
        _isSelfDeliveryEnabled = true;
        // Fetch updated orders list
        await fetchOrders();
        // Notify about orders list update
        if (onOrdersListUpdate != null) {
          onOrdersListUpdate!();
        }
      } else {
        throw Exception("Failed to enable self delivery");
      }
    } catch (e) {
      debugPrint("Error enabling self delivery: $e");
    } finally {
      if (!_disposed) {
        _isEnablingSelfDelivery = false;
        _safeNotifyListeners();
      }
    }
  }

  // Fetch self delivery status for an order
  Future<void> getAndSetSelfDeliveryStatus(String orderId) async {
    try {
      _isSelfDeliveryEnabled = await _orderService.getSelfDeliveryStatus(orderId);
      print("getAndSetSelfDeliveryStatus : ${_isSelfDeliveryEnabled}");
      _safeNotifyListeners();
    } catch (e) {
      debugPrint("Error fetching self delivery status: $e");
    }
  }

  // ✅ Method to generate invoice
  Future<void> generateInvoice(String orderId) async {
    if (_disposed) return;
    
    try {
      _isGeneratingInvoice = true;
      _generatingInvoiceForOrderId = orderId;  // Set the current order ID
      _safeNotifyListeners();

      // Fetch the invoice data
      final orderData = await _orderService.fetchInvoiceData(orderId);
      
      // Generate and download the PDF
      await generateAndDownloadInvoicePDF(orderData);

    } catch (e) {
      debugPrint("Error generating invoice: $e");
      rethrow; // Rethrow to handle in UI
    } finally {
      if (!_disposed) {
        _isGeneratingInvoice = false;
        _generatingInvoiceForOrderId = '';  // Clear the order ID
        _safeNotifyListeners();
      }
    }
  }
}
