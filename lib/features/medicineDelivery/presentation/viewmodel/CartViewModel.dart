import 'package:flutter/material.dart';
import 'package:vedika_healthcare/core/auth/data/models/UserModel.dart';
import 'package:vedika_healthcare/core/auth/data/services/StorageService.dart';
import 'package:vedika_healthcare/core/constants/apiConstants.dart';
import 'package:vedika_healthcare/features/Vendor/MedicalStoreVendor/data/models/CartModel.dart';
import 'package:vedika_healthcare/features/Vendor/MedicalStoreVendor/data/models/MedicineOrderModel.dart';
import 'package:vedika_healthcare/features/Vendor/MedicalStoreVendor/data/models/MedicineProduct.dart';
import 'package:vedika_healthcare/features/medicineDelivery/data/services/MedicineOrderDeliveryRazorPayService.dart';
import 'package:vedika_healthcare/features/medicineDelivery/data/services/userCartService.dart';

class CartViewModel extends ChangeNotifier {
  final UserCartService _cartService;
  double _subtotal = 0.0;
  double _deliveryCharge = 0.0;
  double _total = 0.0;

  double get subtotal => _subtotal;
  double get deliveryCharge => _deliveryCharge;
  double get total => _total;

  List<CartModel> _cartItems = []; // Add this list to store cart items

  CartViewModel(this._cartService);

  // **🔹 Fetch Orders and Cart Items by User ID**
  Future<List<CartModel>> fetchOrdersAndCartItems() async {
    String? userId = await StorageService.getUserId();

    try {
      List<MedicineOrderModel> orders = await _cartService.fetchOrdersByUserId(userId!);
      debugPrint('Response from fetchOrdersByUserId: $orders');

      List<CartModel> allCartItems = [];
      for (var order in orders) {
        List<CartModel> cartItems = await fetchCartItemsByOrderId(order.orderId);
        allCartItems.addAll(cartItems);
      }

      // Calculate the subtotal and total after fetching the cart items
      _calculateSubtotal(allCartItems);

      debugPrint("Fetched cart items from orders: $allCartItems");
      return allCartItems;
    } catch (e) {
      debugPrint("Error fetching orders and cart items: $e");
      return [];
    }
  }

  // **🔹 Fetch Cart Items by Order ID**
  Future<List<CartModel>> fetchCartItemsByOrderId(String orderId) async {
    try {
      _cartItems = await _cartService.fetchCartItemsByOrderId(orderId);
      debugPrint("Fetched cart items by order ID: $_cartItems");
      return _cartItems;
    } catch (e) {
      debugPrint("Error fetching cart items by order ID: $e");
      return [];
    }
  }

  // **🔹 Fetch Product Details by Cart ID**
  Future<List<MedicineProduct>> fetchProductByCartId(String cartId) async {
    try {
      List<MedicineProduct> products = await _cartService.fetchProductByCartId(cartId);
      debugPrint("Fetched products by cart ID: $products");
      return products;
    } catch (e) {
      debugPrint("Error fetching products by cart ID: $e");
      return [];
    }
  }

  // **🔹 Add Medicine to Cart**
  Future<String> addToCart(CartModel cartItem) async {
    try {
      final result = await _cartService.addToCart(cartItem);
      debugPrint("Add to cart result: $result");
      // Only call notifyListeners if there was a successful change
      notifyListeners();
      return result;
    } catch (e) {
      debugPrint("Error adding to cart: $e");
      return "❌ Error adding to cart.";
    }
  }

  // **🔹 Update Quantity**
  Future<String> updateQuantity(String productId, int quantity) async {
    try {
      final cartItems = await _cartService.getUserCart("vendorId"); // Replace with actual vendorId
      CartModel updatedItem = cartItems.firstWhere((item) => item.productId == productId);
      updatedItem.quantity = quantity;

      // Update the item in the cart
      await _cartService.addToCart(updatedItem);
      debugPrint("Updated cart item: $updatedItem");

      // Recalculate subtotal only if the quantity changed
      _calculateSubtotal(cartItems);
      return "✅ Quantity updated successfully.";
    } catch (e) {
      debugPrint("Error updating quantity: $e");
      return "❌ Error updating quantity.";
    }
  }

  // **🔹 Remove Item from Cart**
  Future<String> removeFromCart(String cartId) async {
    try {
      final result = await _cartService.deleteCartItem(cartId);
      debugPrint("Removed item from cart: $result");
      notifyListeners();
      return result;
    } catch (e) {
      debugPrint("Error removing item from cart: $e");
      return "❌ Error removing item from cart.";
    }
  }

  // **🔹 Process Order**
  Future<String> processOrder(List<CartModel> cartItems, String vendorId, UserModel user, String prescriptionId, double totalAmount) async {
    try {
      final order = MedicineOrderModel(
        orderId:" ",
        prescriptionId: prescriptionId,
        userId: user.userId,
        vendorId: vendorId,
        orderStatus: 'Pending',
        createdAt: DateTime.now(),
        totalAmount: totalAmount,
        user: user,
        orderItems: cartItems,
      );

      final result = await _cartService.processOrder(order);
      debugPrint("Order processed: $result");
      return result;
    } catch (e) {
      debugPrint("Error processing order: $e");
      return "❌ Error processing order.";
    }
  }

  // **🔹 Set Delivery Charge**
  setDeliveryCharge(double charge) {
    if (_deliveryCharge != charge) { // Check if charge has changed
      _deliveryCharge = charge;
      _calculateTotal();
      notifyListeners(); // Only notify if the charge has changed
    }
  }

  // **🔹 Calculate Subtotal**
  void _calculateSubtotal(List<CartModel> cartItems) {
    double newSubtotal = 0.0;
    // Calculate the subtotal by summing the price * quantity for each cart item
    for (var item in cartItems) {
      newSubtotal += item.price * item.quantity; // Assuming 'price' and 'quantity' are available in CartModel
    }

    // Only update subtotal and recalculate total if the value has actually changed
    if (_subtotal != newSubtotal) {
      _subtotal = newSubtotal;
      _calculateTotal();
    }
  }

  // **🔹 Calculate Total**
  void _calculateTotal() {
    double newTotal = _subtotal + _deliveryCharge;
    // Only update total if it has changed
    if (_total != newTotal) {
      _total = newTotal;
      notifyListeners(); // Notify listeners only when there's a change
    }
  }

  // Handle the payment process
  Future<void> handlePayment(double totalAmount) async {
    final razorPayService = MedicineOrderDeliveryRazorPayService();
    razorPayService.openPaymentGateway(
      totalAmount * 100, // Convert to paise
      ApiConstants.razorpayApiKey,
      'Medicine Order Delivery',
      'Payment for your medicine delivery order',
    );
  }

  // Getter for the total item count (just the number of cart items)
  int get totalItemCount {
    print("_cartItems ${_cartItems.length}");
    return _cartItems.length; // Simply count the number of items in the cart
  }
}
