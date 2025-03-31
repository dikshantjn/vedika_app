import 'package:dio/dio.dart';
import 'package:vedika_healthcare/core/constants/ApiEndpoints.dart';
import 'package:vedika_healthcare/features/Vendor/MedicalStoreVendor/data/models/CartModel.dart';
import 'package:vedika_healthcare/features/Vendor/MedicalStoreVendor/data/models/MedicineOrderModel.dart';

class TrackOrderService {
  final Dio _dio = Dio();

  // Fetch trackable orders for a specific user
  Future<List<MedicineOrderModel>> fetchUserOrders(String userId) async {
    try {
      final response = await _dio.get('${ApiEndpoints.trackOrder}/track-orders/$userId');

      if (response.statusCode == 200 && response.data['success']) {
        List<dynamic> ordersJson = response.data['orders'];
        return ordersJson.map((json) => MedicineOrderModel.fromJson(json)).toList();
      } else {
        throw Exception('Failed to load orders');
      }
    } catch (e) {
      print('Error fetching orders: $e');
      throw Exception('Failed to load orders');
    }
  }

  // **🔹 Fetch Cart Items by Order ID**
  Future<List<CartModel>> fetchCartItemsByOrderId(String orderId) async {
    try {
      final response = await _dio.get(
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
}
