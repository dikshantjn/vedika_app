import 'package:flutter/material.dart';
import 'package:razorpay_flutter/razorpay_flutter.dart';
import 'package:vedika_healthcare/core/auth/data/models/UserModel.dart';
import 'package:vedika_healthcare/core/auth/data/services/StorageService.dart';
import 'package:vedika_healthcare/core/constants/apiConstants.dart';
import 'package:vedika_healthcare/features/Vendor/MedicalStoreVendor/data/models/CartModel.dart';
import 'package:vedika_healthcare/features/Vendor/MedicalStoreVendor/data/models/MedicineOrderModel.dart';
import 'package:vedika_healthcare/features/Vendor/MedicalStoreVendor/data/models/MedicineProduct.dart';
import 'package:vedika_healthcare/features/medicineDelivery/data/services/MedicineOrderDeliveryRazorPayService.dart';
import 'package:vedika_healthcare/features/medicineDelivery/data/services/userCartService.dart';

class CartAndPlaceOrderViewModel extends ChangeNotifier {
  final UserCartService _cartService;
  double _subtotal = 0.0;
  double _deliveryCharge = 0.0;
  double _total = 0.0;
  double _discount = 0.0;
  bool _isCouponApplied = false;
  double _platformFee = 10.0;
  bool _isLoading = false;
  String _addressId = ''; // Initialize with an empty string

  double get subtotal => _subtotal;
  double get deliveryCharge => _deliveryCharge;
  double get discount => _discount;
  double get total => _total;
  bool get isCouponApplied => _isCouponApplied;
  bool get isLoading => _isLoading;
  String get addressId => _addressId;

  // 🛒 **Global Lists to Store Data**
  List<CartModel> _cartItems = []; // Add this list to store cart items
  List<MedicineOrderModel> _orders = []; // Store Orders
  Map<String, List<MedicineProduct>> _productDetails = {}; // Store Products per Cart ID

  // **Getters to Access Data Globally**
  List<MedicineOrderModel> get orders => _orders;
  List<CartModel> get cartItems => _cartItems;
  Map<String, List<MedicineProduct>> get productDetails => _productDetails;


  CartAndPlaceOrderViewModel(this._cartService) {
    _razorPayService.onPaymentSuccess = _handlePaymentSuccess;
    _razorPayService.onPaymentError = _handlePaymentFailure;
    _razorPayService.onPaymentCancelled = _handlePaymentFailure; // Treat cancellation as a failure
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
    notifyListeners(); // Notify UI to show loading

    String? userId = await StorageService.getUserId();
    print("userId fetched while booting $userId");
    if (userId == null) {
      _isLoading = false;
      notifyListeners();
      return;
    }

    try {
      _orders = await _cartService.fetchOrdersByUserId(userId);
      _cartItems.clear(); // Clear existing cart items

      for (var order in _orders) {
        List<CartModel> cartItems = await fetchCartItemsByOrderId(order.orderId);
        _cartItems.addAll(cartItems);
      }

      _calculateSubtotal(_cartItems);
    } catch (e) {
      debugPrint("❌ Error fetching orders and cart items: $e");
    } finally {
      _isLoading = false;
      notifyListeners(); // Notify UI to stop loading
    }
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
      await _cartService.deleteCartItem(cartId);
      _cartItems.removeWhere((item) => item.cartId == cartId);
      _calculateSubtotal(_cartItems);
      notifyListeners(); // ✅ Update UI
    } catch (e) {
      debugPrint("❌ Error removing item from cart: $e");
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

  // Getter for the total item count (just the number of cart items)
  int get totalItemCount {
    print("_cartItems ${_cartItems.length}");
    return _cartItems.length; // Simply count the number of items in the cart
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

  @override
  void dispose() {
    _razorPayService.clear();
    super.dispose();
  }
}
