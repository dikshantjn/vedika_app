import 'dart:convert';

import 'package:dio/dio.dart';
import 'package:flutter/cupertino.dart';
import 'package:vedika_healthcare/core/constants/ApiEndpoints.dart';
import 'package:vedika_healthcare/core/constants/apiConstants.dart';
import 'package:vedika_healthcare/features/Vendor/MedicalStoreVendor/data/models/CartModel.dart';
import 'package:vedika_healthcare/features/Vendor/MedicalStoreVendor/data/models/MedicineOrderModel.dart';
import 'package:vedika_healthcare/features/Vendor/MedicalStoreVendor/data/models/MedicineProduct.dart';

class UserCartService {
  final Dio dio = Dio();

  Future<List<CartModel>> getUserCart(String userId) async {
    try {
      final response = await dio.get(
        '${ApiEndpoints.getCartItemsByUserId}/$userId', // Make sure the endpoint is correct
      );

      // Print the full response data
      print('Response: ${response.data}');  // This will print the response data

      // Check if the request is successful
      if (response.statusCode == 200) {
        // Extract the cart items from the response
        List<dynamic> cartItemsData = response.data['allCartItems'] ?? [];

        // Map the raw data to a list of CartModel
        List<CartModel> cartItems = cartItemsData.map((item) {
          return CartModel.fromJson(item);  // Convert each item to CartModel
        }).toList();

        return cartItems;
      } else {
        // Return an empty list if the status code is not 200
        return [];
      }
    } catch (e) {
      // Handle any error during the request and return an empty list
      print('Error fetching cart items: $e');
      return [];
    }
  }


  // **🔹 Add Medicine to Cart**
  Future<String> addToCart(CartModel cartItem) async {
    try {
      final response = await dio.post(
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

  // **🔹 Delete Cart Item**
  Future<String> deleteCartItem(String cartId) async {
    print("cartId :$cartId");
    try {
      final response = await dio.delete(
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

  // **🔹 Process Order (Move Cart to Orders)**
  Future<String> processOrder(MedicineOrderModel order) async {
    try {
      final response = await dio.post(
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

  Future<List<MedicineOrderModel>> fetchOrdersByUserId(String userId) async {
    try {
      final response = await dio.get(
        '${ApiEndpoints.fetchOrdersByUserId}/$userId/AddedItemsInCart', // Fetch orders by userId and status 'Pending'
      );

      // Print the full response data
      print('fetchOrdersByUserId Response: ${response.data}'); // This will print the response data

      // Check if the request is successful
      if (response.statusCode == 200) {
        // Access the 'pendingOrders' key in the response data
        List<dynamic> ordersData = response.data['pendingOrders'] ?? [];

        // Map the raw data to a list of MedicineOrderModel
        List<MedicineOrderModel> orders = ordersData.map((item) {
          return MedicineOrderModel.fromJson(item); // Convert each item to MedicineOrderModel
        }).toList();

        return orders;
      } else {
        // Return an empty list if the status code is not 200
        return [];
      }
    } catch (e) {
      // Handle any error during the request and return an empty list
      print('Error fetching orders: $e');
      return [];
    }
  }


  // **🔹 Fetch Cart Items by Order ID**
  Future<List<CartModel>> fetchCartItemsByOrderId(String orderId) async {
    try {
      final response = await dio.get(
        '${ApiEndpoints.getCartItemByOrderId}/$orderId', // Endpoint to fetch cart items by orderId
      );

      // Print the full response data
      print('Response: ${response.data}');  // This will print the response data

      // Check if the request is successful
      if (response.statusCode == 200) {
        // Extract the cart items from the response
        List<dynamic> cartItemsData = response.data['cartItems'] ?? [];

        // Map the raw data to a list of CartModel
        List<CartModel> cartItems = cartItemsData.map((item) {
          return CartModel.fromJson(item);  // Convert each item to CartModel
        }).toList();

        return cartItems;
      } else {
        // Return an empty list if the status code is not 200
        return [];
      }
    } catch (e) {
      // Handle any error during the request and return an empty list
      print('Error fetching cart items by order ID: $e');
      return [];
    }
  }

  // **🔹 Fetch Product Details by Cart ID**
  Future<List<MedicineProduct>> fetchProductByCartId(String cartId) async {
    try {
      final response = await dio.get(
        '${ApiEndpoints.fetchProductByCartId}/$cartId/product', // Fetch products by cartId
      );

      // Print the full response data for debugging
      debugPrint('Response: ${response.data}'); // Logs the full response

      // Check if the request is successful (status code 200)
      if (response.statusCode == 200) {
        // Extract cartItem from the response
        Map<String, dynamic> cartItemData = response.data['cartItem'];

        // Extract the MedicineProduct from cartItem
        Map<String, dynamic> medicineProductData = cartItemData['MedicineProduct'];

        // Map the raw data to a MedicineProduct object
        MedicineProduct product = MedicineProduct.fromJson(medicineProductData);

        // Return a list containing the single product (since it's not a list)
        return [product];  // Wrap in a list as the method expects a list
      } else {
        // Return an empty list if the status code is not 200
        debugPrint('Failed to fetch products, status code: ${response.statusCode}');
        return [];
      }
    } catch (e) {
      // Handle any errors during the request and return an empty list
      debugPrint('Error fetching products by cartId: $e');
      return [];  // Return empty list on error
    }
  }

  Future<bool> updateOrder(MedicineOrderModel order) async {
    try {
      String url = '${ApiEndpoints.placedOrderWithPayment}/${order.orderId}'; // Build URL with orderId

      // Prepare the data from the MedicineOrderModel to send to the backend
      Response response = await dio.put(
        url,
        data: {
          "addressId": order.addressId,
          "appliedCoupon": order.appliedCoupon,
          "discountAmount": order.discountAmount,
          "subtotal": order.subtotal,
          "totalAmount": order.totalAmount,
          "orderStatus": order.orderStatus,
          "paymentMethod": order.paymentMethod,
          "transactionId": order.transactionId,
          "paymentStatus": order.paymentStatus,
          "estimatedDeliveryDate": order.estimatedDeliveryDate?.toIso8601String(),
          "trackingId": order.trackingId,
          "updatedAt": DateTime.now().toIso8601String(),
        },
      );

      if (response.statusCode == 200) {
        return true; // Order updated successfully
      } else {
        debugPrint("❌ Failed to update order: ${response.data}");
        return false; // Failed to update
      }
    } catch (e) {
      debugPrint("❌ Error updating order: $e");
      return false; // Handle error
    }
  }
}

