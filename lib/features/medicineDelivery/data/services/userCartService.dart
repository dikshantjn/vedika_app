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
        '${ApiEndpoints.getCartItemsByUserId}/$userId/AddedItemsInCart',
        options: Options(
          validateStatus: (status) {
            // Treat 404 as success since it means "no pending orders found"
            return status != null && (status == 200 || status == 201 || status == 404);
          },
        ),
      );

      debugPrint('Response Cart Items: ${response.data}');

      // Handle 404 response (no pending orders found)
      if (response.statusCode == 404) {
        debugPrint('No pending orders found for user: $userId');
        return []; // Return empty list for no orders
      }

      if (response.statusCode == 200) {
        // First get the pending orders
        List<dynamic> pendingOrders = response.data['pendingOrders'] ?? [];
        debugPrint('Found ${pendingOrders.length} pending orders');

        List<CartModel> allCartItems = [];

        // For each pending order, fetch its cart items
        for (var order in pendingOrders) {
          String orderId = order['orderId'];
          debugPrint('Fetching cart items for order: $orderId');
          
          // Fetch cart items for this order
          List<CartModel> orderCartItems = await fetchCartItemsByOrderId(orderId);
          debugPrint('Found ${orderCartItems.length} items for order $orderId');
          
          allCartItems.addAll(orderCartItems);
        }

        debugPrint('Total cart items found: ${allCartItems.length}');
        return allCartItems;
      } else {
        debugPrint('Failed to fetch cart items. Status code: ${response.statusCode}');
        return [];
      }
    } catch (e) {
      debugPrint('Error fetching cart items: $e');
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
        '${ApiEndpoints.fetchOrdersByUserId}/$userId/AddedItemsInCart',
        options: Options(
          validateStatus: (status) {
            // Treat 404 as success since it means "no pending orders found"
            return status != null && (status == 200 || status == 201 || status == 404);
          },
        ),
      );

      // Print the full response data
              // Debug print removed

      // Handle 404 response (no pending orders found)
      if (response.statusCode == 404) {
        print('No pending orders found for user: $userId');
        return []; // Return empty list for no orders
      }

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
        '${ApiEndpoints.getCartItemByOrderId}/$orderId',
        options: Options(
          validateStatus: (status) {
            // Treat 404 as success since it might mean "no cart items found for this order"
            return status != null && (status == 200 || status == 201 || status == 404);
          },
        ),
      );

      // Print the full response data
      print('Response: ${response.data}');  // This will print the response data

      // Handle 404 response (no cart items found for this order)
      if (response.statusCode == 404) {
        print('No cart items found for order: $orderId');
        return []; // Return empty list for no cart items
      }

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
        '${ApiEndpoints.fetchProductByCartId}/$cartId/product',
        options: Options(
          validateStatus: (status) {
            // Treat 404 as success since it might mean "no product found for this cart ID"
            return status != null && (status == 200 || status == 201 || status == 404);
          },
        ),
      );

      // Print the full response data for debugging
      debugPrint('Response: ${response.data}'); // Logs the full response

      // Handle 404 response (no product found for this cart ID)
      if (response.statusCode == 404) {
        debugPrint('No product found for cart ID: $cartId');
        return []; // Return empty list for no product
      }

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
      String url = '${ApiEndpoints.placedOrderWithPayment}/${order.orderId}';
      debugPrint("🔄 Updating order at URL: $url");
      debugPrint("📦 Original order data:");
      debugPrint("- Order ID: ${order.orderId}");
      debugPrint("- Address ID: ${order.addressId}");
      debugPrint("- Applied Coupon: ${order.appliedCoupon}");
      debugPrint("- Discount Amount: ${order.discountAmount}");
      debugPrint("- Subtotal: ${order.subtotal}");
      debugPrint("- Total Amount: ${order.totalAmount}");
      debugPrint("- Delivery Charge: ${order.deliveryCharge}");
      debugPrint("- Platform Fee: ${order.platformFee}");
      debugPrint("- Order Status: ${order.orderStatus}");
      debugPrint("- Payment Method: ${order.paymentMethod}");
      debugPrint("- Transaction ID: ${order.transactionId}");
      debugPrint("- Payment Status: ${order.paymentStatus}");

      // Prepare the data without null checks to preserve original values
      final Map<String, dynamic> orderData = {
        "addressId": order.addressId,
        "appliedCoupon": order.appliedCoupon,
        "discountAmount": order.discountAmount,
        "subtotal": order.subtotal,
        "totalAmount": order.totalAmount,
        "deliveryCharge": order.deliveryCharge,
        "platformFee": order.platformFee,
        "orderStatus": order.orderStatus,
        "paymentMethod": order.paymentMethod,
        "transactionId": order.transactionId,
        "paymentStatus": order.paymentStatus,
        "estimatedDeliveryDate": order.estimatedDeliveryDate?.toIso8601String(),
        "trackingId": order.trackingId,
        "updatedAt": DateTime.now().toIso8601String(),
      };

      // Remove null values to avoid sending them to the API
      orderData.removeWhere((key, value) => value == null);

      debugPrint("📦 Prepared order data for API (JSON):");
      debugPrint(jsonEncode(orderData));

      Response response = await dio.put(
        url,
        data: orderData,
        options: Options(
          headers: {
            'Content-Type': 'application/json',
            'Accept': 'application/json',
          },
          validateStatus: (status) => true,
          receiveTimeout: const Duration(seconds: 30),
          sendTimeout: const Duration(seconds: 30),
        ),
      );

      debugPrint("📦 API Response Status: ${response.statusCode}");
      debugPrint("📦 API Response Data: ${response.data}");

      if (response.statusCode == 200 || response.statusCode == 201) {
        debugPrint("✅ Order updated successfully");
        return true;
      } else {
        debugPrint("❌ Failed to update order. Status: ${response.statusCode}");
        debugPrint("❌ Error details: ${response.data}");
        return false;
      }
    } on DioException catch (e) {
      debugPrint("❌ DioException in updateOrder:");
      debugPrint("Error type: ${e.type}");
      debugPrint("Error message: ${e.message}");
      if (e.response != null) {
        debugPrint("Response status: ${e.response?.statusCode}");
        debugPrint("Response data: ${e.response?.data}");
      }
      return false;
    } catch (e, stackTrace) {
      debugPrint("❌ Error updating order:");
      debugPrint("Error: $e");
      debugPrint("Stack trace: $stackTrace");
      return false;
    }
  }
}

