import 'package:flutter/foundation.dart';
import 'package:vedika_healthcare/features/medicineDelivery/data/models/MedicalStore/MedicineProduct.dart';

class CartService extends ChangeNotifier {
  static final CartService _instance = CartService._internal();

  factory CartService() => _instance;

  CartService._internal();

  final List<MedicineProduct> _cartItems = [];
  double _deliveryCharge = 50; // Default delivery charge

  List<MedicineProduct> getCartItems() {
    debugPrint("Fetching cart items: $_cartItems");
    return List.unmodifiable(_cartItems);
  }

  double getSubtotal() {
    double subtotal = _cartItems.fold(0, (sum, item) => sum + (item.price * item.quantity));
    debugPrint("Calculating subtotal: $subtotal");
    return subtotal;
  }

  double getDeliveryCharge() {
    debugPrint("Current Delivery Charge: $_deliveryCharge");
    return _deliveryCharge;
  }

  /// Allows setting a custom delivery charge dynamically
  void setDeliveryCharge(double charge) {
    debugPrint("Updating Delivery Charge to: $charge");
    _deliveryCharge = charge;
    notifyListeners(); // Notify UI about the update
  }

  double getTotal() {
    double total = getSubtotal() + _deliveryCharge;
    debugPrint("Calculating total amount: $total");
    return total;
  }

  void addToCart(MedicineProduct product) {
    debugPrint("Attempting to add product: ${product.name} (ID: ${product.id})");

    int index = _cartItems.indexWhere((item) => item.id == product.id);
    if (index != -1) {
      _cartItems[index] = _cartItems[index].copyWith(quantity: _cartItems[index].quantity + 1);
      debugPrint("Increased quantity of ${product.name} to ${_cartItems[index].quantity}");
    } else {
      _cartItems.add(product.copyWith(quantity: 1));
      debugPrint("Added new product: ${product.name} to cart");
    }

    notifyListeners();
  }

  void removeFromCart(String productId) {
    debugPrint("Attempting to remove product with ID: $productId");

    _cartItems.removeWhere((item) => item.id == productId);

    notifyListeners();
  }

  void updateQuantity(String productId, int quantity) {
    debugPrint("Updating quantity for product ID: $productId to $quantity");

    int index = _cartItems.indexWhere((item) => item.id == productId);
    if (index != -1) {
      _cartItems[index] = _cartItems[index].copyWith(quantity: quantity);
      debugPrint("Updated quantity for ${_cartItems[index].name} to $quantity");
    } else {
      debugPrint("Product with ID $productId not found in cart");
    }

    notifyListeners();
  }

  void removeItemPermanently(String medicineId) {
    _cartItems.removeWhere((item) => item.id == medicineId);
    notifyListeners();
  }

  void clearCart() {
    debugPrint("Clearing cart...");
    _cartItems.clear();
    notifyListeners();
  }
}
