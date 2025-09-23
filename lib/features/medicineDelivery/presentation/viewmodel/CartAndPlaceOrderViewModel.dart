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
import 'package:vedika_healthcare/features/home/data/models/ProductCart.dart';
import 'package:vedika_healthcare/features/home/data/services/ProductCartService.dart';
import 'package:vedika_healthcare/features/home/data/services/ProductService.dart';
import 'package:vedika_healthcare/features/home/data/services/ProductOrderService.dart';
import 'package:vedika_healthcare/features/Vendor/ProductPartner/data/models/VendorProduct.dart';
import 'package:uuid/uuid.dart';
import 'dart:convert';

class CartAndPlaceOrderViewModel extends ChangeNotifier {
  final UserCartService _userCartService;
  final ProductCartService _productCartService;
  final ProductService _productService;
  final ProductOrderService _productOrderService;
  double _subtotal = 0.0;
  double _deliveryCharge = 0.0;
  double _total = 0.0;
  double _discount = 0.0;
  bool _isCouponApplied = false;
  double _platformFee = 10.0;
  bool _isLoading = false;
  String _addressId = '';
  int _totalItemCount = 0;
  IO.Socket? _socket;
  bool mounted = true;
  
  // Add flag to track if cart data has already been fetched
  bool _hasInitialized = false;
  DateTime? _lastFetchTime;
  static const Duration _cacheValidDuration = Duration(minutes: 5); // Cache valid for 5 minutes

  // Add callback for cart count updates
  Function()? onCartCountUpdate;

  // Add list to store product cart items
  List<ProductCart> _productCartItems = [];
  List<ProductCart> get productCartItems => _productCartItems;

  // Store product details
  List<VendorProduct> _productDetails = [];
  List<VendorProduct> get productDetails => _productDetails;

  double get subtotal => _subtotal;
  double get deliveryCharge => _deliveryCharge;
  double get discount => _discount;
  double get total => _total;
  bool get isCouponApplied => _isCouponApplied;
  bool get isLoading => _isLoading;
  String get addressId => _addressId;
  int get totalItemCount => _totalItemCount;

  // 🛒 **Global Lists to Store Data**
  List<CartModel> _cartItems = [];
  List<MedicineOrderModel> _orders = [];
  Map<String, List<MedicineProduct>> _medicineProductDetails = {};

  // **Getters to Access Data Globally**
  List<MedicineOrderModel> get orders => _orders;
  List<CartModel> get cartItems => _cartItems;
  Map<String, List<MedicineProduct>> get medicineProductDetails => _medicineProductDetails;

  // **🔹 Check if cart is empty**
  bool get isCartEmpty => _cartItems.isEmpty && _productCartItems.isEmpty;

  // **🔹 Check if there are any items (medicine or products)**
  bool get hasAnyItems => _cartItems.isNotEmpty || _productCartItems.isNotEmpty;

  // **🔹 Get total cart count (medicine + products)**
  int get totalCartCount => _cartItems.length + _productCartItems.length;

  // **🔹 Check if cart is loading**
  bool get isCartLoading => _isLoading;

  // **🔹 Check if cart has been initialized**
  bool get hasInitialized => _hasInitialized;

  // **🔹 Check if cache is still valid**
  bool get isCacheValid {
    if (_lastFetchTime == null) return false;
    return DateTime.now().difference(_lastFetchTime!) < _cacheValidDuration;
  }

  // **🔹 Get cart summary for debugging**
  String get cartSummary {
    return 'Cart Summary: ${_cartItems.length} medicine items, ${_productCartItems.length} product items, Total: $_totalItemCount';
  }

  CartAndPlaceOrderViewModel(this._userCartService, this._productCartService)
      : _productService = ProductService(),
        _productOrderService = ProductOrderService();

  Function(String)? _onPaymentSuccess;
  Function(String)? _onPaymentError;

  void setOnPaymentSuccess(Function(String)? callback) {
    _onPaymentSuccess = callback;
  }

  void setOnPaymentError(Function(String)? callback) {
    _onPaymentError = callback;
  }

  final MedicineOrderDeliveryRazorPayService _razorPayService =
  MedicineOrderDeliveryRazorPayService();

  void setAddressId(String addressId) {
    if (_addressId != addressId) {
      _addressId = addressId;
      notifyListeners(); // Notify UI of the change
    }
  }

  Future<void> fetchOrdersAndCartItems({bool forceRefresh = false}) async {
    // Check if we already have data and cache is valid
    if (!forceRefresh && _hasInitialized && isCacheValid && _cartItems.isNotEmpty) {
      return;
    }

    // Check if we're already loading
    if (_isLoading) {
      return;
    }

    _isLoading = true;
    notifyListeners();

    try {
      String? userId = await StorageService.getUserId();
      if (userId == null) {
        _isLoading = false;
        notifyListeners();
        return;
      }

      // Fetch existing product items
      final existingItems = await _userCartService.getUserCart(userId);
      _cartItems = existingItems;

      // Fetch medicine orders
      final medicineOrders = await _userCartService.fetchOrdersByUserId(userId);
      _orders = medicineOrders;

      // Fetch product cart items
      final productItems = await _productCartService.getProductCartItems();
      _productCartItems = productItems;

      // Handle case where there are no cart items or orders
      if (_cartItems.isEmpty && _orders.isEmpty && _productCartItems.isEmpty) {
        _totalItemCount = 0;
        _subtotal = 0.0;
        _calculateSubtotal(_cartItems);
        _hasInitialized = true;
        _lastFetchTime = DateTime.now();
        _isLoading = false;
        notifyListeners();
        return;
      }

      // Fetch product details for each cart item
      _productDetails = [];
      for (var cartItem in _productCartItems) {
        if (cartItem.productId != null && cartItem.productId!.isNotEmpty) {
          try {
            final product = await _productService.getProductById(cartItem.productId!);
            if (product != null) {
              _productDetails.add(product);
            } else {
              debugPrint('⚠️ No product details found for product ID: ${cartItem.productId}');
            }
          } catch (e) {
            debugPrint('❌ Error fetching product details for ID ${cartItem.productId}: $e');
          }
        } else {
          debugPrint('⚠️ Cart item has null or empty product ID');
        }
      }

      // Update total item count
      _totalItemCount = _cartItems.length + _productCartItems.length;
      // debugPrint("📊 Total items in cart: $_totalItemCount");
      // debugPrint("📊 Medicine cart items: ${_cartItems.length}");
      // debugPrint("📊 Product cart items: ${_productCartItems.length}");
      //
      // Calculate subtotal
      _calculateSubtotal(_cartItems);

      // Print cart items for debugging
      if (_cartItems.isNotEmpty) {
        for (var item in _cartItems) {
        }
      } else {
        // debugPrint("🛒 No medicine cart items found");
      }

      // Mark as initialized and update cache time
      _hasInitialized = true;
      _lastFetchTime = DateTime.now();

    } catch (e, stackTrace) {
      debugPrint("❌ Error fetching cart items: $e");
      debugPrint("❌ Stack trace: $stackTrace");
      
      // Set default values on error
      _cartItems = [];
      _orders = [];
      _productCartItems = [];
      _totalItemCount = 0;
      _subtotal = 0.0;
    } finally {
      _isLoading = false;
      notifyListeners();
      // debugPrint("✅ Finished fetching orders and cart items");
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
      List<CartModel> fetchedItems = await _userCartService.fetchCartItemsByOrderId(orderId);
      return fetchedItems;
    } catch (e) {
      debugPrint("❌ Error fetching cart items: $e");
      return [];
    }
  }

  Future<List<MedicineProduct>> fetchProductByCartId(String cartId) async {
    if (_medicineProductDetails.containsKey(cartId)) {
      return _medicineProductDetails[cartId]!;
    }

    try {
      List<MedicineProduct> products = await _userCartService.fetchProductByCartId(cartId);
      _medicineProductDetails[cartId] = products;
      notifyListeners();
      return products;
    } catch (e) {
      debugPrint("❌ Error fetching products by cart ID: $e");
      return []; // Return an empty list in case of an error
    }
  }

  // **🔹 Get Products for a Specific Cart ID**
  List<MedicineProduct> getProductDetails(String cartId) {
    return _medicineProductDetails[cartId] ?? [];
  }

  // **🔹 Remove Item from Cart and Update State**
  Future<void> removeFromCart(String cartId) async {
    try {
      // debugPrint('🗑️ Removing item from cart: $cartId');
      
      // First remove from backend
      await _userCartService.deleteCartItem(cartId);
      
      // Then remove from local state
      _cartItems.removeWhere((item) => item.cartId == cartId);
      
      // Update totals and count
      _calculateSubtotal(_cartItems);
      _updateTotalItemCount();
      
      // Clear cache to ensure fresh data on next fetch
      clearCartCache();
      
      // Notify listeners to update UI
      notifyListeners();
      
    } catch (e) {
      debugPrint("❌ Error removing item from cart: $e");
      // Even if there's an error, try to remove from local state
      _cartItems.removeWhere((item) => item.cartId == cartId);
      _calculateSubtotal(_cartItems);
      _updateTotalItemCount();
      clearCartCache();
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

    if (cartItems.isEmpty) {
      _subtotal = 0.0;
      calculateTotal();
      return;
    }
    
    double newSubtotal = 0.0;
    for (var item in cartItems) {
      double itemTotal = item.price * item.quantity;
      newSubtotal += itemTotal;
      debugPrint("- ${item.name}: ${item.quantity} x ${item.price} = $itemTotal");
    }

    if (_subtotal != newSubtotal) {
      _subtotal = newSubtotal;
      calculateTotal();
    } else {
    }
  }

  void calculateTotal() {
    double newTotal = _subtotal - _discount + _deliveryCharge + _platformFee;

    if (newTotal <= 0) {

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

  @override
  void dispose() {
    if (_socket != null) {
      _socket!.disconnect();
      _socket!.dispose();
    }
    _razorPayService.dispose();
    super.dispose();
  }

  Future<void> handlePayment(double totalAmount) async {

    if (totalAmount <= 0) {
      if (_onPaymentError != null) {
        _onPaymentError!("Invalid payment amount");
      }
      return;
    }

    try {
      if (ApiConstants.razorpayApiKey.isEmpty) {
        if (_onPaymentError != null) {
          _onPaymentError!("Payment gateway configuration error");
        }
        return;
      }

      // ✅ Ensure amount is converted to integer before passing to Razorpay
      double roundedAmount = totalAmount.roundToDouble();

      // Determine payment title based on cart items
      String paymentTitle;
      if (_cartItems.isNotEmpty && _productCartItems.isNotEmpty) {
        paymentTitle = 'Medicine & Product Order';
      } else if (_cartItems.isNotEmpty) {
        paymentTitle = 'Medicine Order';
      } else if (_productCartItems.isNotEmpty) {
        paymentTitle = 'Product Order';
      } else {
        paymentTitle = 'Order Payment';
      }

      // Set up Razorpay event handlers
      _razorPayService.onPaymentSuccess = (PaymentSuccessResponse response) {
        _handlePaymentSuccess(response);
      };
      
      _razorPayService.onPaymentError = (PaymentFailureResponse response) {
        if (_onPaymentError != null) {
          _onPaymentError!(response.message ?? "Payment failed");
        }
        _handlePaymentFailure(response);
      };

      // Open payment gateway with appropriate title
      _razorPayService.openPaymentGateway(
        roundedAmount,
        ApiConstants.razorpayApiKey,
        paymentTitle,
        'Payment for your $paymentTitle',
      );

      debugPrint("✅ Payment gateway opened successfully");
    } catch (e, stackTrace) {
      debugPrint("❌ Error in handlePayment:");
      debugPrint(e.toString());
      debugPrint(stackTrace.toString());
      if (_onPaymentError != null) {
        _onPaymentError!(e.toString());
      }
    }
  }

  void _handlePaymentSuccess(PaymentSuccessResponse response) async {

    try {
      String transactionId = response.paymentId!;
      String paymentMethod = "Razorpay";
      String paymentStatus = "Paid";



      // Calculate per-order charges
      int orderCount = _orders.length;
      double perOrderDeliveryCharge = orderCount > 0 ? (_deliveryCharge / orderCount) : 0.0;
      double perOrderPlatformFee = orderCount > 0 ? (_platformFee / orderCount) : 0.0;
      double perOrderDiscount = orderCount > 0 ? (_discount / orderCount) : 0.0;

      // Group cart items by orderId for subtotal calculation
      Map<String, List<CartModel>> itemsByOrder = {};
      for (var item in _cartItems) {
        itemsByOrder.putIfAbsent(item.orderId, () => []).add(item);
      }

      // Handle medicine orders
      for (var order in _orders) {
        try {

          // Calculate subtotal for this order
          double orderSubtotal = 0.0;
          if (itemsByOrder.containsKey(order.orderId)) {
            for (var item in itemsByOrder[order.orderId]!) {
              orderSubtotal += item.price * item.quantity;
            }
          }

          double orderTotal = orderSubtotal + perOrderDeliveryCharge + perOrderPlatformFee - perOrderDiscount;

          // Update order with payment details while preserving original data
          final updatedOrder = order.copyWith(
            addressId: order.addressId,
            appliedCoupon: _isCouponApplied ? "TEST10" : "",
            discountAmount: perOrderDiscount,
            subtotal: orderSubtotal,
            totalAmount: orderTotal,
            deliveryCharge: perOrderDeliveryCharge,
            platformFee: perOrderPlatformFee,
            trackingId: order.trackingId,
            orderStatus: "PaymentConfirmed",
            paymentMethod: paymentMethod,
            transactionId: transactionId,
            paymentStatus: paymentStatus,
            estimatedDeliveryDate: DateTime.now().add(const Duration(days: 3)),
            updatedAt: DateTime.now(),
          );

          // Update order in backend
          final success = await _userCartService.updateOrder(updatedOrder);

          if (!success) {
            debugPrint("❌ Failed to update order: ${order.orderId}");
          }
        } catch (e, stackTrace) {
          debugPrint("Stack trace: $stackTrace");
        }
      }

      // Clear medicine orders and cart items after successful payment
      _orders.clear();
      _cartItems.clear();
      _calculateSubtotal(_cartItems); // Recalculate subtotal with empty cart
      _totalItemCount = 0; // Reset total item count

      // Handle product orders if there are any product cart items
      if (_productCartItems.isNotEmpty) {
        try {
          // Call placeProductOrder to create the order
          final orderResponse = await _productOrderService.placeProductOrder();

          // Clear the product cart after successful order placement
          _productCartItems.clear();
          _totalItemCount = 0; // Reset total count since both carts are empty
          notifyListeners();

        } catch (e) {
          debugPrint("❌ Error placing product order: $e");
          throw Exception("Failed to place product order: $e");
        }
      }

      // Trigger the callback after everything is done
      if (_onPaymentSuccess != null) {
        debugPrint("📞 Calling external payment success callback");
        _onPaymentSuccess!(transactionId);
      }

      // Notify about cart count update
      if (onCartCountUpdate != null) {
        onCartCountUpdate!();
      }

    } catch (e, stackTrace) {
      debugPrint("❌ Error in payment success handler:");
      debugPrint("❌ Error: $e");
      debugPrint("❌ Stack trace: $stackTrace");
      if (_onPaymentError != null) {
        _onPaymentError!(e.toString());
      }
    }

    notifyListeners();
  }

  void _handlePaymentFailure(PaymentFailureResponse response) {
    debugPrint("❌ Payment Failed: ${response.code}");
    debugPrint("💬 Reason: ${response.message}");

    notifyListeners();
  }

  void initSocketConnection() async {
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
        _socket!.emit('register', userId);

        // Fetch cart items immediately after connection
        fetchOrdersAndCartItems();
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
        // Clear cache when cart updates are received
        clearCartCache();
        await _handleCartUpdate(data);
      });

      // Add event listener for medicine order updates
      _socket!.on('MedicineOrderUpdate', (data) async {
        debugPrint('💊 Medicine order update received: $data');
        // Clear cache when order updates are received
        clearCartCache();
        await _handleMedicineOrderUpdate(data);
      });

      // Add event listener for order status updates
      _socket!.on('orderStatusUpdated', (data) async {
        debugPrint('📦 Order status update received: $data');
        // Clear cache when order status updates are received
        clearCartCache();
        await _handleOrderStatusUpdate(data);
      });

      // Add ping/pong handlers
      _socket!.on('ping', (_) {
        debugPrint('📡 Received ping');
        _socket!.emit('pong');
        debugPrint('📡 Sent pong');
      });

      // Connect to the socket
      _socket!.connect();
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

      // Parse the data if it's a string
      Map<String, dynamic> cartData = data is String ? json.decode(data) : data;

      final orderId = cartData['orderId'];
      final newCartItems = cartData['cartItems'];

      if (orderId != null && newCartItems != null) {

        // Convert new items to CartModel objects
        List<CartModel> parsedNewItems = (newCartItems as List).map((item) {
          return CartModel.fromJson(item);
        }).toList();
        

        // Replace the entire cart items list with the new items
        _cartItems = parsedNewItems;
        
        // Update total item count based on unique items
        _totalItemCount = _cartItems.length;

        // Recalculate totals
        _calculateSubtotal(_cartItems);
        
        // Notify about cart count update
        if (onCartCountUpdate != null) {
          onCartCountUpdate!();
        }
        
        // Notify listeners to update UI
        if (mounted) {
          notifyListeners();
        }
        
        for (var item in _cartItems) {
          debugPrint("- ${item.name} (Quantity: ${item.quantity}, Price: ${item.price})");
        }
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

      // Parse the data if it's a string
      Map<String, dynamic> orderData = data is String ? json.decode(data) : data;

      // Refresh cart data
      await fetchOrdersAndCartItems();
      
      // Notify about cart count update
      if (onCartCountUpdate != null) {
        onCartCountUpdate!();
      }
      
    } catch (e, stackTrace) {
      debugPrint('❌ Error handling medicine order update: $e');
      debugPrint('❌ Stack trace: $stackTrace');
    }
  }

  Future<void> _handleOrderStatusUpdate(dynamic data) async {
    try {

      // Parse the data if it's a string
      Map<String, dynamic> orderData = data is String ? json.decode(data) : data;

      // Refresh cart data to get latest state
      await fetchOrdersAndCartItems();
      
      // Notify about cart count update
      if (onCartCountUpdate != null) {
        onCartCountUpdate!();
      }
      
    } catch (e, stackTrace) {
      debugPrint('❌ Error handling order status update: $e');
      debugPrint('❌ Stack trace: $stackTrace');
    }
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
      _totalItemCount = _cartItems.length; // Update total item count

      // Calculate new subtotal
      _calculateSubtotal(_cartItems);
      calculateTotal();
      
      notifyListeners();

      // TODO: Implement API call to save cart item
      // await _cartRepository.addToCart(cartItem);
    } catch (e) {
      debugPrint('❌ Error adding product to cart: $e');
      rethrow;
    }
  }

  // Add product to product cart
  Future<void> addToProductCart(VendorProduct product) async {
    try {

      // Check if product already exists in cart
      final existingItemIndex = _productCartItems.indexWhere(
        (item) => item.productId == product.productId,
      );

      if (existingItemIndex != -1) {
        // Update quantity if product exists
        final existingItem = _productCartItems[existingItemIndex];
        if (existingItem.cartId == null) {
          debugPrint("❌ Error: Cart ID is null for existing item");
          throw Exception("Cart ID is null for existing item");
        }
        
        final updatedItem = await _productCartService.updateCartItemQuantity(
          existingItem.cartId!,
          (existingItem.quantity ?? 0) + 1,
        );
        _productCartItems[existingItemIndex] = updatedItem;
      } else {
        // Add new product to cart
        final newItem = ProductCart(
          cartId: const Uuid().v4(),
          userId: await StorageService.getUserId(),
          productId: product.productId,
          quantity: 1,
          addedAt: DateTime.now(),
          imageUrl: product.images.isNotEmpty ? product.images.first : null,
          productName: product.name,
          price: product.price,
        );
        final addedItem = await _productCartService.addToCart(cartItem: newItem);
        _productCartItems.add(addedItem);
      }

      // Update total item count
      _totalItemCount = _cartItems.length + _productCartItems.length;

      // Clear cache to ensure fresh data on next fetch
      clearCartCache();
      
      notifyListeners();
    } catch (e) {
      debugPrint('❌ Error adding product to cart: $e');
      rethrow;
    }
  }

  // Delete product from cart
  Future<void> deleteProductFromCart(String cartId) async {
    try {

      // Delete from backend
      final success = await _productCartService.deleteCartItem(cartId);
      
      if (success) {
        // Remove from local state
        _productCartItems.removeWhere((item) => item.cartId == cartId);
        
        // Update total item count
        _totalItemCount = _cartItems.length + _productCartItems.length;

        // Clear cache to ensure fresh data on next fetch
        clearCartCache();
        
        notifyListeners();
      }
    } catch (e) {
      debugPrint('❌ Error deleting product from cart: $e');
      rethrow;
    }
  }

  // Update product cart item quantity
  Future<void> updateProductCartQuantity(String cartId, int quantity) async {
    try {

      final updatedItem = await _productCartService.updateCartItemQuantity(cartId, quantity);
      
      // Update local state
      final index = _productCartItems.indexWhere((item) => item.cartId == cartId);
      if (index != -1) {
        _productCartItems[index] = updatedItem;

        // Clear cache to ensure fresh data on next fetch
        clearCartCache();
        notifyListeners();
      }
    } catch (e) {
      debugPrint('❌ Error updating product quantity: $e');
      rethrow;
    }
  }

  // **🔹 Force refresh cart data (clears cache)**
  Future<void> refreshCartData() async {
    debugPrint("🔄 Force refreshing cart data...");
    _hasInitialized = false;
    _lastFetchTime = null;
    await fetchOrdersAndCartItems(forceRefresh: true);
  }

  // **🔹 Clear cart cache**
  void clearCartCache() {
    debugPrint("🗑️ Clearing cart cache...");
    _hasInitialized = false;
    _lastFetchTime = null;
  }

  // **🔹 Get cache status for debugging**
  String get cacheStatus {
    if (!_hasInitialized) return "Not initialized";
    if (_lastFetchTime == null) return "No cache time";
    
    final age = DateTime.now().difference(_lastFetchTime!);
    final isValid = isCacheValid;
    return "Cache age: ${age.inMinutes}m ${age.inSeconds % 60}s, Valid: $isValid";
  }
}
