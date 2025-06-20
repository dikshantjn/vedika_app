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


  // ✅ Method to Accept an Order
  Future<bool> acceptOrder(String orderId, String vendorId) async {
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
  Future<String> getOrderStatus(String orderId, String vendorId) async {
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

// Add this method in your OrderService class
  Future<bool> updateOrderStatus(String orderId, String newStatus) async {
    try {
      final response = await _dio.put(
        '${ApiEndpoints.updateOrderStatus}/$orderId/status',  // Fetching status using orderId and vendorId
        data: {
          "newStatus": newStatus,  // Only send the new status as required by your backend
        },
        options: Options(headers: {"Content-Type": "application/json"}),
      );

      if (response.statusCode == 200) {
        print("Order status updated successfully: ${response.data}");
        return true; // Status updated successfully
      } else {
        print("Failed to update order status: ${response.data}");
        return false; // Failed to update status
      }
    } catch (e) {
      if (e is DioException) {
        if (e.response != null) {
          print("Error response data: ${e.response?.data}");
          print("Error status code: ${e.response?.statusCode}");
        } else {
          print("Error message: ${e.message}");
        }
      } else {
        print("Error updating order status: $e");
      }
      return false; // Return false if an error occurred
    }
  }

// ✅ Method to update Prescription Status
  Future<bool> updatePrescriptionStatus(String prescriptionId) async {
    try {
      final response = await _dio.put(
        '${ApiEndpoints.updatePrescriptionStatus}/$prescriptionId/prescriptionStatus',
        data: {
          "newStatus": "PrescriptionVerified",  // Updating status to PrescriptionVerified
        },
        options: Options(headers: {"Content-Type": "application/json"}),
      );

      if (response.statusCode == 200) {
        print("Prescription status updated successfully: ${response.data}");
        return true; // Status updated successfully
      } else {
        print("Failed to update prescription status: ${response.data}");
        return false; // Failed to update status
      }
    } catch (e) {
      if (e is DioException) {
        if (e.response != null) {
          print("Error response data: ${e.response?.data}");
          print("Error status code: ${e.response?.statusCode}");
        } else {
          print("Error message: ${e.message}");
        }
      } else {
        print("Error updating prescription status: $e");
      }
      return false; // Return false if an error occurred
    }
  }

  // ✅ Method to enable self delivery
  Future<bool> enableSelfDelivery(String orderId) async {
    try {
      final response = await _dio.patch(
        '${ApiEndpoints.enableSelfDelivery}/$orderId/self-delivery',
        options: Options(headers: {"Content-Type": "application/json"}),
      );

      if (response.statusCode == 200) {
        print("Self delivery enabled successfully: ${response.data}");
        return true; // Self delivery enabled successfully
      } else {
        print("Failed to enable self delivery: ${response.data}");
        return false; // Failed to enable self delivery
      }
    } catch (e) {
      if (e is DioException) {
        if (e.response != null) {
          print("Error response data: ${e.response?.data}");
          print("Error status code: ${e.response?.statusCode}");
        } else {
          print("Error message: ${e.message}");
        }
      } else {
        print("Error enabling self delivery: $e");
      }
      return false; // Return false if an error occurred
    }
  }

  // ✅ Method to get self delivery status
  Future<bool> getSelfDeliveryStatus(String orderId) async {
    try {
      final response = await _dio.get(
        '${ApiEndpoints.getSelfDeliveryStatus}/$orderId/self-delivery',
        options: Options(headers: {"Content-Type": "application/json"}),
      );
      if (response.statusCode == 200) {
        // The response is { orderId: ..., selfDelivery: true/false }
        print("self delivery status: ${response.data}");

        return response.data['selfDelivery'] == true;
      } else {
        print("Failed to get self delivery status: \\${response.data}");
        return false;
      }
    } catch (e) {
      print("Error getting self delivery status: $e");
      return false;
    }
  }

  // ✅ Method to fetch invoice data
  Future<MedicineOrderModel> fetchInvoiceData(String orderId) async {
    try {
      final response = await _dio.get('${ApiEndpoints.generateMedicineOrderInvoice}/$orderId');

      if (response.statusCode == 200) {
        final data = response.data;
        if (data['success'] == true) {
          final orderData = data['order'];
          print("📦 Original carts data: ${orderData['carts']}");
          
          // First, map the carts array to CartModel structure
          final List<Map<String, dynamic>> cartItems = List<Map<String, dynamic>>.from(orderData['carts'].map((cart) {
            // Keep the exact structure and keys from the API response
            return {
              'cartId': cart['cartId'],
              'orderId': cart['orderId'],
              'productId': cart['productId'],
              'name': cart['name'],
              'price': cart['price'],
              'quantity': cart['quantity'],
              'MedicineProduct': cart['MedicineProduct'],  // Keep exact key casing
              'isProduct': false,
              'createdAt': cart['createdAt'],
              'updatedAt': cart['updatedAt']
            };
          }));

          print("📝 All mapped cart items: $cartItems");

          // Create the final order data structure
          final Map<String, dynamic> mappedOrderData = {
            'orderId': orderData['orderId'],
            'prescriptionId': orderData['prescriptionId'],
            'userId': orderData['userId'],
            'vendorId': orderData['vendorId'],
            'addressId': orderData['addressId'],
            'appliedCoupon': orderData['appliedCoupon'],
            'discountAmount': orderData['discountAmount'] ?? 0.0,
            'subtotal': orderData['subtotal'] ?? 0.0,
            'totalAmount': orderData['totalAmount'] ?? 0.0,
            'deliveryCharge': orderData['deliveryCharge'] ?? 0.0,
            'platformFee': orderData['platformFee'] ?? 0.0,
            'orderStatus': orderData['orderStatus'],
            'paymentMethod': orderData['paymentMethod'],
            'transactionId': orderData['transactionId'],
            'paymentStatus': orderData['paymentStatus'],
            'deliveryStatus': orderData['deliveryStatus'],
            'estimatedDeliveryDate': orderData['estimatedDeliveryDate'],
            'trackingId': orderData['trackingId'],
            'selfDelivery': orderData['selfDelivery'] ?? false,
            'createdAt': orderData['createdAt'],
            'updatedAt': orderData['updatedAt'],
            'User': orderData['user'],
            'Carts': cartItems  // This matches the key expected in MedicineOrderModel.fromJson
          };

          print("📋 Final mapped order data structure: $mappedOrderData");

          final orderModel = MedicineOrderModel.fromJson(mappedOrderData);
          print("🔍 Final order model items count: ${orderModel.orderItems.length}");
          if (orderModel.orderItems.isNotEmpty) {
            print("🔍 First order item details: ${orderModel.orderItems.first.toJson()}");
            print("🔍 First order item medicine product: ${orderModel.orderItems.first.medicineProduct?.toJson()}");
          }

          return orderModel;
        } else {
          throw Exception('Failed to fetch invoice data');
        }
      } else {
        throw Exception('Failed to fetch invoice data');
      }
    } catch (e) {
      print("❌ Error fetching invoice data: $e");
      throw Exception("Error fetching invoice data");
    }
  }
}
