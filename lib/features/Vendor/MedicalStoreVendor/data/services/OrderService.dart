import 'package:dio/dio.dart';
import 'package:vedika_healthcare/core/constants/ApiEndpoints.dart';
import 'package:vedika_healthcare/features/Vendor/MedicalStoreVendor/data/models/MedicineOrderModel.dart';

class OrderService {
  final Dio _dio = Dio(); // Initialize Dio instance

  // 📌 Method to get all orders
  Future<List<MedicineOrderModel>> getOrders(String vendorId) async {
    try {
      final response = await _dio.get('${ApiEndpoints.getOrders}/$vendorId');

      if (response.statusCode == 200) {
        List<dynamic> data = response.data['orders'];
        return data.map((order) => MedicineOrderModel.fromJson(order)).toList();
      } else if (response.statusCode == 404) {
        // No orders found
        return [];
      } else {
        throw Exception('Failed to load orders');
      }
    } catch (e) {
      print("Error fetching orders: $e");
      throw Exception("Error fetching orders");
    }
  }

  // 📌 Method to place an order
  Future<bool> placeOrder(MedicineOrderModel order) async {
    try {
      final response = await _dio.post(
        ApiEndpoints.placeOrder,
        data: order.toJson(), // Convert MedicineOrderModel to JSON
        options: Options(headers: {"Content-Type": "application/json"}),
      );

      if (response.statusCode == 201 || response.statusCode == 200) {
        return true; // Order placed successfully
      } else {
        return false; // Failed to place order
      }
    } catch (e) {
      print("Error placing order: $e");
      return false;
    }
  }

  // ✅ Method to Accept an Order
  Future<bool> acceptOrder(int orderId, String vendorId) async {
    try {
      final response = await _dio.put(
        '${ApiEndpoints.acceptOrder}/$orderId/accept',
        data: {"vendorId": vendorId},  // Sending vendorId in request body
        options: Options(headers: {"Content-Type": "application/json"}),
      );

      // Check the response status
      if (response.statusCode == 200) {
        print("Order accepted successfully: ${response.data}");
        return true; // Order accepted successfully
      } else {
        print("Failed to accept the order: ${response.data}");
        return false; // Something went wrong
      }
    } catch (e) {
      if (e is DioException) {
        if (e.response != null) {
          // Log detailed error response for debugging
          print("Error response data: ${e.response?.data}");
          print("Error status code: ${e.response?.statusCode}");
        } else {
          print("Error message: ${e.message}");
        }
      } else {
        print("Error accepting order: $e");
      }
      return false;
    }
  }

  // ✅ Method to Get Order Status
  Future<String> getOrderStatus(int orderId, String vendorId) async {
    try {
      final response = await _dio.get(
        '${ApiEndpoints.getOrderStatus}/$orderId/$vendorId/status',  // Fetching status using orderId and vendorId
        options: Options(headers: {"Content-Type": "application/json"}),
      );

      // Check the response status
      if (response.statusCode == 200) {
        print("Order status fetched successfully: ${response.data}");
        return response.data['orderStatus'];  // Assuming 'orderStatus' is in the response
      } else {
        print("Failed to fetch order status: ${response.data}");
        return 'Error';  // Return 'Error' if status code is not 200
      }
    } catch (e) {
      if (e is DioException) {
        if (e.response != null) {
          // Log detailed error response for debugging
          print("Error response data: ${e.response?.data}");
          print("Error status code: ${e.response?.statusCode}");
        } else {
          print("Error message: ${e.message}");
        }
      } else {
        print("Error fetching order status: $e");
      }
      return 'Error';  // Return 'Error' in case of exception
    }
  }


}
