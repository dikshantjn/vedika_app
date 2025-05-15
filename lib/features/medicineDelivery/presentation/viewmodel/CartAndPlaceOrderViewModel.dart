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

  CartAndPlaceOrderViewModel(this._userCartService, this._productCartService)
      : _productService = ProductService(),
        _productOrderService = ProductOrderService();

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

      // Fetch product details for each cart item
      _productDetails = [];
      for (var cartItem in _productCartItems) {
        if (cartItem.productId != null && cartItem.productId!.isNotEmpty) {
          try {
            final product = await _productService.getProductById(cartItem.productId!);
            if (product != null) {
              _productDetails.add(product);
            } else {
              print('Warning: No product details found for product ID: ${cartItem.productId}');
            }
          } catch (e) {
            print('Error fetching product details for ID ${cartItem.productId}: $e');
          }
        } else {
          print('Warning: Cart item has null or empty product ID');
        }
      }

      // Update total item count
      _totalItemCount = _cartItems.length + _productCartItems.length;
      
      _calculateSubtotal(_cartItems);
    } catch (e) {
      print('Error fetching cart items: $e');
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
      debugPrint('🗑️ Removing item from cart: $cartId');
      
      // First remove from backend
      await _userCartService.deleteCartItem(cartId);
      
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

  @override
  void dispose() {
    debugPrint("🗑️ Disposing CartAndPlaceOrderViewModel");
    if (_socket != null) {
      _socket!.disconnect();
      _socket!.dispose();
    }
    _razorPayService.dispose();
    super.dispose();
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

      // Set up Razorpay event handlers
      _razorPayService.onPaymentSuccess = (PaymentSuccessResponse response) {
        debugPrint("🎯 Payment success callback triggered in view model");
        debugPrint("💰 Payment ID from callback: ${response.paymentId}");
        _handlePaymentSuccess(response);
      };
      
      _razorPayService.onPaymentError = (PaymentFailureResponse response) {
        debugPrint("❌ Payment error callback triggered in view model");
        debugPrint("💬 Error message from callback: ${response.message}");
        _handlePaymentFailure(response);
      };

      // Open payment gateway
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
    debugPrint("✅ Payment Success Handler Started");
    debugPrint("💰 Payment ID: ${response.paymentId}");
    debugPrint("🔑 Order ID: ${response.orderId}");
    debugPrint("💳 Signature: ${response.signature}");

    try {
      String transactionId = response.paymentId!;
      String paymentMethod = "Razorpay";
      String paymentStatus = "Paid";
      String appliedCoupon = _isCouponApplied ? "TEST10" : "";

      debugPrint("🔄 Processing medicine orders...");
      // Handle medicine orders
      for (var order in _orders) {
        debugPrint("📦 Processing order: ${order.orderId}");
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
        await _userCartService.updateOrder(updatedOrder);
        debugPrint("🎉 Order ${order.orderId} updated successfully.");
      }

      // Handle product orders if there are any product cart items
      if (_productCartItems.isNotEmpty) {
        debugPrint("🛍️ Found ${_productCartItems.length} product items to order");
        try {
          debugPrint("🛍️ Attempting to place product order...");
          final orderResult = await _productOrderService.placeProductOrder();
          debugPrint("✅ Product order placed successfully");
          debugPrint("📦 Order details: $orderResult");

          // Clear product cart after successful order
          _productCartItems.clear();
          _totalItemCount = 0; // Reset total item count
          _subtotal = 0.0; // Reset subtotal
          _total = 0.0; // Reset total
          debugPrint("🧹 Cart cleared. New item count: $_totalItemCount");
          notifyListeners();
        } catch (e) {
          debugPrint("❌ Error placing product order:");
          debugPrint("❌ Error: $e");
          // Don't throw here, we still want to show success for medicine orders
        }
      } else {
        debugPrint("ℹ️ No product items to order");
      }

      // Trigger the callback after everything is done
      if (_onPaymentSuccess != null) {
        debugPrint("📞 Calling external payment success callback");
        _onPaymentSuccess!(transactionId);
        debugPrint("✅ External payment success callback executed");
      }

      debugPrint("✅ Payment Success Handler Completed");
    } catch (e, stackTrace) {
      debugPrint("❌ Error in payment success handler:");
      debugPrint("❌ Error: $e");
      debugPrint("❌ Stack trace: $stackTrace");
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

  // Add product to cart
  Future<void> addProductToCart(Product product) async {
    try {
      debugPrint("🛍️ Adding product to cart: ${product.name}");
      
      final cartId = const Uuid().v4();
      final orderId = const Uuid().v4();
      
      final cartItem = CartModel.fromProduct(
        product,
        cartId: cartId,
        orderId: orderId,
      );

      _cartItems.add(cartItem);
      _totalItemCount = _cartItems.length; // Update total item count
      debugPrint("📦 Cart count updated: $_totalItemCount");
      
      // Calculate new subtotal
      _calculateSubtotal(_cartItems);
      calculateTotal();
      
      notifyListeners();
      debugPrint("✅ Product added to cart successfully");

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
      debugPrint("🛍️ Adding product to product cart: ${product.name}");
      
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
        debugPrint("📦 Updated quantity for existing product: ${updatedItem.quantity}");
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
        debugPrint("📦 Added new product to cart");
      }

      // Update total item count
      _totalItemCount = _cartItems.length + _productCartItems.length;
      debugPrint("📦 Total cart count updated: $_totalItemCount");
      
      notifyListeners();
      debugPrint("✅ Product added to cart successfully");
    } catch (e) {
      debugPrint('❌ Error adding product to cart: $e');
      rethrow;
    }
  }

  // Delete product from cart
  Future<void> deleteProductFromCart(String cartId) async {
    try {
      debugPrint("🗑️ Deleting product from cart: $cartId");
      
      // Delete from backend
      final success = await _productCartService.deleteCartItem(cartId);
      
      if (success) {
        // Remove from local state
        _productCartItems.removeWhere((item) => item.cartId == cartId);
        
        // Update total item count
        _totalItemCount = _cartItems.length + _productCartItems.length;
        debugPrint("📦 Total cart count updated: $_totalItemCount");
        
        notifyListeners();
        debugPrint("✅ Product deleted from cart successfully");
      }
    } catch (e) {
      debugPrint('❌ Error deleting product from cart: $e');
      rethrow;
    }
  }

  // Update product cart item quantity
  Future<void> updateProductCartQuantity(String cartId, int quantity) async {
    try {
      debugPrint("🔄 Updating product cart quantity. Cart ID: $cartId, New quantity: $quantity");
      
      final updatedItem = await _productCartService.updateCartItemQuantity(cartId, quantity);
      
      // Update local state
      final index = _productCartItems.indexWhere((item) => item.cartId == cartId);
      if (index != -1) {
        _productCartItems[index] = updatedItem;
        debugPrint("📦 Updated quantity for product: ${updatedItem.quantity}");
        
        notifyListeners();
        debugPrint("✅ Product quantity updated successfully");
      }
    } catch (e) {
      debugPrint('❌ Error updating product quantity: $e');
      rethrow;
    }
  }
}
