import 'dart:convert';
import 'package:dio/dio.dart';
import 'package:vedika_healthcare/core/constants/ApiEndpoints.dart';
import 'package:vedika_healthcare/features/Vendor/MedicalStoreVendor/data/models/CartModel.dart';
import 'package:vedika_healthcare/features/Vendor/MedicalStoreVendor/data/models/MedicineOrderModel.dart';
import 'package:vedika_healthcare/features/medicineDelivery/data/models/MedicalStore/MedicineProduct.dart';

class OrderCartService {
  final Dio _dio = Dio(); // Initialize Dio instance

  // **🔹 Add Medicine to Cart**
  Future<String> addToCart(CartModel cartItem) async {
    try {
      final response = await _dio.post(
        ApiEndpoints.addToCart, // Using the endpoint constant
        data: jsonEncode(cartItem.toJson()), // Serialize cartItem to JSON
        options: Options(headers: {'Content-Type': 'application/json'}),
      );

      if (response.statusCode == 201 || response.statusCode == 200) {
        return "✅ Medicine added to cart successfully";
      } else {
        return "❌ Failed to add to cart: ${response.data}";
      }
    } catch (e) {
      return "❌ Error adding to cart: $e";
    }
  }

  // **🔹 Fetch Cart Items**
  Future<List<CartModel>> fetchCart(String vendorId) async {
    try {
      final response = await _dio.get(
        '${ApiEndpoints.fetchCart}?vendorId=$vendorId', // Using the endpoint constant
        options: Options(headers: {'Content-Type': 'application/json'}),
      );

      if (response.statusCode == 200) {
        List<dynamic> data = response.data;
        return data.map((item) => CartModel.fromJson(item)).toList();
      } else {
        throw Exception("❌ Failed to fetch cart: ${response.data}");
      }
    } catch (e) {
      return Future.error("❌ Error fetching cart: $e");
    }
  }

  // **🔹 Process Order (Move Cart to Orders)**
  Future<String> processOrder(MedicineOrderModel order) async {
    try {
      final response = await _dio.post(
        ApiEndpoints.placeOrder, // Using the endpoint constant
        data: jsonEncode(order.toJson()), // Serialize the order into JSON
        options: Options(headers: {'Content-Type': 'application/json'}),
      );

      if (response.statusCode == 200) {
        final result = response.data;
        if (result['success']) {
          return "✅ Order placed successfully";
        } else {
          return "❌ Failed to place order: ${result['message'] ?? 'Unknown error'}";
        }
      } else {
        return "❌ Failed to process order: ${response.data}";
      }
    } catch (e) {
      return "❌ Error processing order: $e";
    }
  }

  // **🔹 Clear Cart After Order**
  Future<String> clearCart(String vendorId) async {
    try {
      final response = await _dio.delete(
        '${ApiEndpoints.clearCart}?vendorId=$vendorId', // Using the endpoint constant
        options: Options(headers: {'Content-Type': 'application/json'}),
      );

      if (response.statusCode == 200) {
        return "✅ Cart cleared after order placement.";
      } else {
        return "❌ Failed to clear cart: ${response.data}";
      }
    } catch (e) {
      return "❌ Error clearing cart: $e";
    }
  }

  // **🔹 Fetch Cart Items by Order ID**
  Future<List<CartModel>> fetchCartByOrderId(int orderId) async {
    try {
      final response = await _dio.get(
        '${ApiEndpoints.getCartItemByOrderId}/$orderId', // Use orderId in URL
        options: Options(headers: {'Content-Type': 'application/json'}),
      );

      if (response.statusCode == 200) {
        List<dynamic> data = response.data["cartItems"]; // Extract cart items
        return data.map((item) => CartModel.fromJson(item)).toList();
      } else {
        throw Exception("❌ Failed to fetch cart: ${response.data}");
      }
    } catch (e) {
      return Future.error("❌ Error fetching cart by orderId: $e");
    }
  }

  // **🔹 Delete Cart Item**
  Future<String> deleteCartItem(String cartId) async {
    print("cartId :$cartId");
    try {
      final response = await _dio.delete(
        '${ApiEndpoints.deleteCartItem}/$cartId', // API endpoint with cartId
        options: Options(headers: {'Content-Type': 'application/json'}),
      );

      if (response.statusCode == 200) {
        return "✅ Cart item deleted successfully.";
      } else {
        return "❌ Failed to delete cart item: ${response.data}";
      }
    } catch (e) {
      return "❌ Error deleting cart item: $e";
    }
  }

  // **🔹 Update Cart Item Quantity (Increment or Decrement)**
  Future<String> updateCartQuantity(String cartId, String type) async {
    try {
      final response = await _dio.put(
        '${ApiEndpoints.updateCartQuantity}/$cartId', // Pass cartId in URL
        data: jsonEncode({'type': type}), // Pass type (increment / decrement)
        options: Options(headers: {'Content-Type': 'application/json'}),
      );

      if (response.statusCode == 200) {
        return "✅ Cart quantity ${type == 'increment' ? 'increased' : 'decreased'} successfully.";
      } else {
        return "❌ Failed to update quantity: ${response.data}";
      }
    } catch (e) {
      return "❌ Error updating cart quantity: $e";
    }
  }


}
