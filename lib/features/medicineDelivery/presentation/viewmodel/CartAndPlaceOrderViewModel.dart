import 'package:flutter/material.dart';
import 'package:razorpay_flutter/razorpay_flutter.dart';
import 'package:socket_io_client/socket_io_client.dart' as IO;
import 'package:vedika_healthcare/core/auth/data/models/UserModel.dart';
import 'package:vedika_healthcare/core/auth/data/services/StorageService.dart';
import 'package:vedika_healthcare/core/constants/ApiEndpoints.dart';
import 'package:vedika_healthcare/core/constants/apiConstants.dart';
import 'package:vedika_healthcare/features/Vendor/MedicalStoreVendor/data/models/CartModel.dart';
import 'package:vedika_healthcare/features/Vendor/MedicalStoreVendor/data/models/MedicineOrderModel.dart';
import 'package:vedika_healthcare/features/Vendor/MedicalStoreVendor/data/models/MedicineProduct.dart';
import 'package:vedika_healthcare/features/medicineDelivery/data/services/MedicineOrderDeliveryRazorPayService.dart';
import 'package:vedika_healthcare/features/medicineDelivery/data/services/userCartService.dart';
import 'package:vedika_healthcare/features/home/data/models/Product.dart';
import 'package:uuid/uuid.dart';
import 'dart:convert';

class CartAndPlaceOrderViewModel extends ChangeNotifier {
  final UserCartService _cartService;
  double _subtotal = 0.0;
  double _deliveryCharge = 0.0;
  double _total = 0.0;
  double _discount = 0.0;
  bool _isCouponApplied = false;
  double _platformFee = 10.0;
  bool _isLoading = false;
  String _addressId = '';
  int _totalItemCount = 0; // Add this field to store the count
  IO.Socket? _socket;
  bool mounted = true;

  double get subtotal => _subtotal;
  double get deliveryCharge => _deliveryCharge;
  double get discount => _discount;
  double get total => _total;
  bool get isCouponApplied => _isCouponApplied;
  bool get isLoading => _isLoading;
  String get addressId => _addressId;
  int get totalItemCount => _totalItemCount; // Return stored count

  // 🛒 **Global Lists to Store Data**
  List<CartModel> _cartItems = [];
  List<MedicineOrderModel> _orders = [];
  Map<String, List<MedicineProduct>> _productDetails = {};

  // **Getters to Access Data Globally**
  List<MedicineOrderModel> get orders => _orders;
  List<CartModel> get cartItems => _cartItems;
  Map<String, List<MedicineProduct>> get productDetails => _productDetails;

  CartAndPlaceOrderViewModel(this._cartService) {
    _razorPayService.onPaymentSuccess = _handlePaymentSuccess;
    _razorPayService.onPaymentError = _handlePaymentFailure;
    _razorPayService.onPaymentCancelled = _handlePaymentFailure;
    initSocketConnection();
  }

  Function(String paymentId)? _onPaymentSuccess;

  void setOnPaymentSuccess(Function(String paymentId)? callback) {
    _onPaymentSuccess = callback;
  }

  final MedicineOrderDeliveryRazorPayService _razorPayService =
  MedicineOrderDeliveryRazorPayService();

  void setAddressId(String addressId) {
    if (_addressId != addressId) {
      _addressId = addressId;
      notifyListeners(); // Notify UI of the change
    }
  }

  Future<void> fetchOrdersAndCartItems() async {
    _isLoading = true;
    notifyListeners();

    String? userId = await StorageService.getUserId();
    print("userId fetched while booting $userId");
    if (userId == null) {
      _isLoading = false;
      notifyListeners();
      return;
    }

    try {
      // Store existing product items
      final productItems = _cartItems.where((item) => item.isProduct).toList();
      
      // Fetch medicine orders
      _orders = await _cartService.fetchOrdersByUserId(userId);
      _cartItems.clear();

      // Add medicine items to cart
      for (var order in _orders) {
        List<CartModel> cartItems = await fetchCartItemsByOrderId(order.orderId);
        _cartItems.addAll(cartItems);
      }

      // Add back product items
      _cartItems.addAll(productItems);
      
      // Update total item count once
      _totalItemCount = _cartItems.length;
      
      _calculateSubtotal(_cartItems);
    } catch (e) {
      debugPrint("❌ Error fetching orders and cart items: $e");
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  // Update total item count when cart items change
  void _updateTotalItemCount() {
    _totalItemCount = _cartItems.length; // Count unique items only
    notifyListeners();
  }

  // **🔹 Fetch and Store Cart Items by Order ID**
  Future<List<CartModel>> fetchCartItemsByOrderId(String orderId) async {
    try {
      List<CartModel> fetchedItems = await _cartService.fetchCartItemsByOrderId(orderId);
      return fetchedItems;
    } catch (e) {
      debugPrint("❌ Error fetching cart items: $e");
      return [];
    }
  }

  Future<List<MedicineProduct>> fetchProductByCartId(String cartId) async {
    if (_productDetails.containsKey(cartId)) {
      return _productDetails[cartId]!;
    }

    try {
      List<MedicineProduct> products = await _cartService.fetchProductByCartId(cartId);
      _productDetails[cartId] = products;
      notifyListeners();
      return products;
    } catch (e) {
      debugPrint("❌ Error fetching products by cart ID: $e");
      return []; // Return an empty list in case of an error
    }
  }

  // **🔹 Get Products for a Specific Cart ID**
  List<MedicineProduct> getProductDetails(String cartId) {
    return _productDetails[cartId] ?? [];
  }

  // **🔹 Remove Item from Cart and Update State**
  Future<void> removeFromCart(String cartId) async {
    try {
      debugPrint('🗑️ Removing item from cart: $cartId');
      
      // First remove from backend
      await _cartService.deleteCartItem(cartId);
      
      // Then remove from local state
      _cartItems.removeWhere((item) => item.cartId == cartId);
      
      // Update totals and count
      _calculateSubtotal(_cartItems);
      _updateTotalItemCount();
      
      // Notify listeners to update UI
      notifyListeners();
      
      debugPrint('✅ Item removed successfully. Remaining items: ${_cartItems.length}');
    } catch (e) {
      debugPrint("❌ Error removing item from cart: $e");
      // Even if there's an error, try to remove from local state
      _cartItems.removeWhere((item) => item.cartId == cartId);
      _calculateSubtotal(_cartItems);
      _updateTotalItemCount();
      notifyListeners();
    }
  }

  // **🔹 Set Delivery Charge**
  setDeliveryCharge(double charge) {
    if (_deliveryCharge != charge) { // Check if charge has changed
      _deliveryCharge = charge;
      calculateTotal();
      notifyListeners(); // Only notify if the charge has changed
    }
  }

  void applyCoupon(String couponCode) {
    debugPrint("🎟️ Attempting to apply coupon: $couponCode");

    if (couponCode.isEmpty) {
      debugPrint("❌ Empty coupon code");
      return;
    }

    if (_isCouponApplied) {
      debugPrint("⚠️ Coupon already applied");
      return;
    }

    // Simulate coupon validation
    if (couponCode == "TEST10") {
      _isCouponApplied = true;
      _discount = _subtotal * 0.1; // 10% discount
      debugPrint("✅ Coupon applied successfully. New discount: $_discount");
      calculateTotal();
      notifyListeners();
    } else {
      debugPrint("❌ Invalid coupon code");
    }
  }

  // **🔹 Remove Coupon**
  void removeCoupon() {
    if (!_isCouponApplied) return;

    _isCouponApplied = false;
    _discount = 0.0;
    calculateTotal();
    notifyListeners();
  }

  // **🔹 Calculate Subtotal**
  void _calculateSubtotal(List<CartModel> cartItems) {
    double newSubtotal = 0.0;
    for (var item in cartItems) {
      newSubtotal += item.price * item.quantity;
    }

    if (_subtotal != newSubtotal) {
      _subtotal = newSubtotal;
      calculateTotal();
    }
  }

  void calculateTotal() {
    double newTotal = _subtotal - _discount + _deliveryCharge + _platformFee;
    debugPrint("🛒 Subtotal: $_subtotal");
    debugPrint("💰 Discount: $_discount");
    debugPrint("🚚 Delivery Charge: $_deliveryCharge");
    debugPrint("⚙️ Platform Fee: $_platformFee");
    debugPrint("🔢 Calculated Total: $newTotal");

    if (newTotal <= 0) {
      debugPrint("❌ Invalid Total! Setting to Minimum 1.");
      newTotal = 1; // Ensure total is always positive
    }

    if (_total != newTotal) {
      _total = newTotal;
      notifyListeners();
    }
  }

  void setDiscount(double discount) {
    if (_discount != discount) {
      _discount = discount;
      calculateTotal();
      notifyListeners();
    }
  }

  void setPlatformFee(double fee) {
    if (_platformFee != fee) {
      _platformFee = fee;
      calculateTotal();
      notifyListeners();
    }
  }

  Future<void> handlePayment(double totalAmount) async {
    debugPrint("📲 Initiating Razorpay Payment...");
    debugPrint("💳 Payment Amount: $totalAmount");

    if (totalAmount <= 0) {
      debugPrint("❌ Invalid payment amount: $totalAmount");
      return;
    }

    try {
      debugPrint("🔑 Using Razorpay Key: ${ApiConstants.razorpayApiKey}");
      if (ApiConstants.razorpayApiKey.isEmpty) {
        debugPrint("❌ Razorpay API Key is empty!");
        return;
      }

      // ✅ Ensure amount is converted to integer before passing to Razorpay
      double roundedAmount = totalAmount.roundToDouble();

      _razorPayService.openPaymentGateway(
        roundedAmount,
        ApiConstants.razorpayApiKey,
        'Medicine Order Delivery',
        'Payment for your medicine delivery order',
      );

      debugPrint("✅ Payment gateway opened successfully");
    } catch (e, stackTrace) {
      debugPrint("❌ Error in handlePayment:");
      debugPrint(e.toString());
      debugPrint(stackTrace.toString());
    }
  }

  void _handlePaymentSuccess(PaymentSuccessResponse response) async {
    debugPrint("✅ Payment Successful: ${response.paymentId}");

    try {
      String transactionId = response.paymentId!;
      String paymentMethod = "Razorpay";
      String paymentStatus = "Paid";
      String appliedCoupon = _isCouponApplied ? "TEST10" : "";

      for (var order in _orders) {
        // 🔹 **Calculate Subtotal for Each Order**
        double orderSubtotal = 0.0;
        List<CartModel> orderCartItems = _cartItems.where((item) => item.orderId == order.orderId).toList();

        for (var item in orderCartItems) {
          orderSubtotal += item.price * item.quantity;
        }

        // 🔹 **Calculate Discount for Each Order**
        double orderDiscount = _isCouponApplied ? orderSubtotal * 0.1 : 0.0; // Example: 10% discount

        // 🔹 **Calculate Final Total**
        double orderTotal = orderSubtotal - orderDiscount + _deliveryCharge + _platformFee;
        if (orderTotal <= 0) orderTotal = 1; // Ensure valid total

        // 🔹 **Create Updated Order Model**
        MedicineOrderModel updatedOrder = MedicineOrderModel(
          orderId: order.orderId,
          prescriptionId: order.prescriptionId,
          userId: order.userId,
          vendorId: order.vendorId,
          totalAmount: orderTotal,
          addressId: addressId,
          appliedCoupon: appliedCoupon,
          discountAmount: orderDiscount,
          subtotal: orderSubtotal,
          paymentMethod: paymentMethod,
          transactionId: transactionId,
          paymentStatus: paymentStatus,
          orderStatus: "PaymentConfirmed",
          deliveryStatus: "Pending",
          estimatedDeliveryDate: null,
          trackingId: null,
          createdAt: order.createdAt,
          updatedAt: DateTime.now(),
          user: UserModel.empty(),
          orderItems: orderCartItems,
        );

        // 🔹 **Update Each Order in Database**
        await _cartService.updateOrder(updatedOrder);
        debugPrint("🎉 Order ${order.orderId} updated successfully.");

        // Trigger the callback after everything is done
        if (_onPaymentSuccess != null) {
          _onPaymentSuccess!(transactionId);
        }
      }
    } catch (e) {
      debugPrint("❌ Error updating orders: $e");
    }

    notifyListeners();
  }

  // **Handle Payment Failure (including Cancellation)**
  void _handlePaymentFailure(PaymentFailureResponse response) {
    debugPrint("❌ Payment Failed: ${response.code}");
    debugPrint("💬 Reason: ${response.message}");

    notifyListeners();
  }

  void initSocketConnection() async {
    debugPrint("🚀 Initializing socket connection for cart updates...");
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

      // Set up event listeners
      _socket!.onConnect((_) {
        debugPrint('✅ Socket connected for cart updates');
        _socket!.emit('register', userId);
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

      // Add event listener for cart updates
      _socket!.on('UserCart', (data) async {
        debugPrint('🛒 Cart update received: $data');
        await _handleCartUpdate(data);
      });

      // Add event listener for medicine order updates
      _socket!.on('MedicineOrderUpdate', (data) async {
        debugPrint('💊 Medicine order update received: $data');
        await _handleMedicineOrderUpdate(data);
      });

      // Add ping/pong handlers
      _socket!.on('ping', (_) {
        _socket!.emit('pong');
      });

      // Connect to the socket
      _socket!.connect();
      debugPrint('🔄 Attempting to connect socket for cart updates...');
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

  Future<void> _handleCartUpdate(dynamic data) async {
    try {
      debugPrint('🛒 Processing cart update: $data');
      
      // Parse the data if it's a string
      Map<String, dynamic> cartData = data is String ? json.decode(data) : data;
      debugPrint('🛒 Parsed data: $cartData');
      
      final orderId = cartData['orderId'];
      final newCartItems = cartData['cartItems'];
      final totalItems = cartData['totalItems'];
      
      if (orderId != null && newCartItems != null) {
        // Convert new items to CartModel objects
        List<CartModel> parsedNewItems = (newCartItems as List).map((item) => CartModel.fromJson(item)).toList();
        
        // Replace the entire cart items list with the new items
        // This ensures we have the exact state from the backend
        _cartItems = parsedNewItems;
        
        // Update total item count based on unique items
        _totalItemCount = _cartItems.length;
        
        // Recalculate totals
        _calculateSubtotal(_cartItems);
        
        // Notify listeners to update UI
        if (mounted) {
          notifyListeners();
        }
        
        debugPrint('✅ Cart updated successfully. Total items: $_totalItemCount');
        debugPrint('🛒 Current cart items: ${_cartItems.length}');
      } else {
        debugPrint('❌ Missing orderId or cartItems in data: $cartData');
      }
    } catch (e, stackTrace) {
      debugPrint('❌ Error handling cart update: $e');
      debugPrint('❌ Stack trace: $stackTrace');
    }
  }

  Future<void> _handleMedicineOrderUpdate(dynamic data) async {
    try {
      debugPrint('💊 Processing medicine order update: $data');
      
      // Parse the data if it's a string
      Map<String, dynamic> orderData = data is String ? json.decode(data) : data;
      debugPrint('💊 Parsed data: $orderData');
      
      // Refresh cart data
      await fetchOrdersAndCartItems();
      
      debugPrint('✅ Cart refreshed after medicine order update');
    } catch (e, stackTrace) {
      debugPrint('❌ Error handling medicine order update: $e');
      debugPrint('❌ Stack trace: $stackTrace');
    }
  }

  @override
  void dispose() {
    if (_socket != null) {
      _socket!.disconnect();
      _socket!.dispose();
    }
    _razorPayService.clear();
    super.dispose();
  }

  // Add product to cart
  Future<void> addProductToCart(Product product) async {
    try {
      final cartId = const Uuid().v4();
      final orderId = const Uuid().v4();
      
      final cartItem = CartModel.fromProduct(
        product,
        cartId: cartId,
        orderId: orderId,
      );

      _cartItems.add(cartItem);
      _updateTotalItemCount(); // Update count when item is added
      calculateTotal();
      notifyListeners();

      // TODO: Implement API call to save cart item
      // await _cartRepository.addToCart(cartItem);
    } catch (e) {
      debugPrint('Error adding product to cart: $e');
      rethrow;
    }
  }
}
