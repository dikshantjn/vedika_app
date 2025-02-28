import 'package:flutter/material.dart';
import 'package:vedika_healthcare/features/medicineDelivery/data/models/MedicalStore/MedicineProduct.dart';
import 'package:vedika_healthcare/features/medicineDelivery/data/services/CartService.dart';

class CartViewModel extends ChangeNotifier {
  final CartService _cartService;

  CartViewModel(this._cartService);

  /// Returns the list of items in the cart
  List<MedicineProduct> get cartItems {
    debugPrint("Fetching cart items: ${_cartService.getCartItems()}");
    return _cartService.getCartItems();
  }

  /// Returns the subtotal amount (excluding delivery charges)
  double get subtotal {
    double subtotal = _cartService.getSubtotal();
    debugPrint("Subtotal: $subtotal");
    return subtotal;
  }

  /// Returns the current delivery charge
  double get deliveryCharge {
    double charge = _cartService.getDeliveryCharge();
    debugPrint("Delivery Charge: $charge");
    return charge;
  }

  /// Returns the total amount including delivery charge
  double get total {
    double total = _cartService.getTotal();
    debugPrint("Total amount: $total");
    return total;
  }

  /// Sets the delivery charge dynamically based on distance
  void setDeliveryCharge(double charge) {
    debugPrint("Setting Delivery Charge: $charge");
    _cartService.setDeliveryCharge(charge);
    notifyListeners();
  }

  /// Adds a product to the cart
  void addToCart(MedicineProduct product) {
    debugPrint("Adding to cart: ${product.id}, ${product.name}");
    _cartService.addToCart(product);
    debugPrint("Cart after addition: ${_cartService.getCartItems()}");
    notifyListeners();
  }

  /// Marks an item as removed (sets quantity to 0 but keeps the item in the list)
  void removeFromCart(String productId) {
    debugPrint("Marking item as removed: $productId");
    _cartService.updateQuantity(productId, 0);
    notifyListeners();
  }

  /// Permanently removes an item from the cart
  void removeItemPermanently(String medicineId) {
    debugPrint("Removing item permanently: $medicineId");
    _cartService.removeItemPermanently(medicineId);
    debugPrint("Cart after permanent removal: ${_cartService.getCartItems()}");
    notifyListeners();
  }

  /// Updates the quantity of an existing product in the cart
  void updateQuantity(String productId, int quantity) {
    debugPrint("Updating quantity for: $productId, New Quantity: $quantity");
    _cartService.updateQuantity(productId, quantity);
    debugPrint("Cart after update: ${_cartService.getCartItems()}");
    notifyListeners();
  }

  /// Clears all items from the cart
  void clearCart() {
    debugPrint("Clearing cart...");
    _cartService.clearCart();
    debugPrint("Cart after clearing: ${_cartService.getCartItems()}");
    notifyListeners();
  }
}
