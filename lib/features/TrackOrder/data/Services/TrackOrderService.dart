import 'package:dio/dio.dart';
import 'package:vedika_healthcare/core/constants/ApiEndpoints.dart';
import 'package:vedika_healthcare/features/Vendor/BloodBankAgencyVendor/data/model/BloodBankBooking.dart';
import 'package:vedika_healthcare/features/Vendor/MedicalStoreVendor/data/models/CartModel.dart';
import 'package:vedika_healthcare/features/Vendor/MedicalStoreVendor/data/models/MedicineOrderModel.dart';
import 'package:vedika_healthcare/features/ambulance/data/models/AmbulanceBooking.dart';
import 'package:vedika_healthcare/features/Vendor/ProductPartner/data/models/ProductOrder.dart';
import 'package:flutter/foundation.dart';

class TrackOrderService {
  final Dio _dio = Dio();

  // 🔹 Fetch medicine orders
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

  // 🔹 Fetch Cart Items by Order ID
  Future<List<CartModel>> fetchCartItemsByOrderId(String orderId) async {
    try {
      final response = await _dio.get('${ApiEndpoints.getCartItemByOrderId}/$orderId');
      print('Response: ${response.data}');
      if (response.statusCode == 200) {
        List<dynamic> cartItemsData = response.data['cartItems'] ?? [];
        return cartItemsData.map((item) => CartModel.fromJson(item)).toList();
      } else {
        return [];
      }
    } catch (e) {
      print('Error fetching cart items by order ID: $e');
      return [];
    }
  }

  Future<List<AmbulanceBooking>> fetchActiveAmbulanceBookings(String userId) async {
    try {
      final response = await _dio.get('${ApiEndpoints.getActiveAmbulanceRequests}/$userId');

      print("Response Data: ${response.data}");

      if (response.statusCode == 200 && response.data['success']) {
        List<dynamic> bookingData = response.data['data'];

        return bookingData.map((json) {
          print("Agency Data: ${json['agency']}"); // Debugging the agency field
          return AmbulanceBooking.fromJson(json);
        }).toList();
      } else {
        throw Exception('Failed to load ambulance bookings');
      }
    } catch (e) {
      print('Error fetching ambulance bookings: $e');
      throw Exception('Failed to load ambulance bookings');
    }
  }

  // 🔹 Fetch blood bank bookings
  Future<List<BloodBankBooking>> getBookings(String userId, String token) async {
    try {
      print('Fetching blood bank bookings for user: $userId');

      // Make the API call
      final response = await _dio.get(
        '${ApiEndpoints.getBloodBankBookingsByUserId}/$userId',
        options: Options(
          headers: {
            'Authorization': 'Bearer $token',
            'Content-Type': 'application/json',
          },
        ),
      );

      print('API Response: ${response.data}');

      // Check if the request was successful
      if (response.statusCode == 200) {
        // Check if the response is a map with a data field
        if (response.data is Map<String, dynamic>) {
          final Map<String, dynamic> responseMap = response.data;

          // Check if there's a data field that contains the list
          if (responseMap.containsKey('data') && responseMap['data'] != null) {
            if (responseMap['data'] is List) {
              final List<dynamic> data = responseMap['data'];
              print('Found ${data.length} blood bank bookings');
              return data.map((json) => BloodBankBooking.fromJson(json)).toList();
            } else {
              print('Data field is not a list: ${responseMap['data'].runtimeType}');
              throw Exception('Invalid response format: data field is not a list');
            }
          } else {
            print('Response does not contain a data field or data is null');
            throw Exception('Invalid response format: missing data field or data is null');
          }
        } else if (response.data is List) {
          // Direct list response
          final List<dynamic> data = response.data;
          print('Found ${data.length} blood bank bookings');
          return data.map((json) => BloodBankBooking.fromJson(json)).toList();
        } else {
          print('Unexpected response format: ${response.data.runtimeType}');
          throw Exception('Invalid response format: expected List or Map with data field');
        }
      } else {
        print('API request failed with status code: ${response.statusCode}');
        throw Exception('Failed to load blood bank bookings: ${response.statusCode}');
      }
    } catch (e) {
      print('Error fetching blood bank bookings: $e');
      throw Exception('Failed to fetch blood bank bookings: $e');
    }
  }

  // 🔹 Fetch product orders
  Future<List<ProductOrder>> fetchProductOrders(String userId) async {
    try {
      debugPrint('🛍️ Fetching product orders for user: $userId');
      final response = await _dio.get('${ApiEndpoints.getProductOrdersByUserId}/$userId');
      debugPrint('📦 API Response: ${response.data}');
      
      if (response.statusCode == 200 && response.data['orders'] != null) {
        List<dynamic> ordersJson = response.data['orders'];
        debugPrint('📦 Found ${ordersJson.length} product orders');
        return ordersJson.map((json) => ProductOrder.fromJson(json)).toList();
      } else {
        debugPrint('❌ No orders found or invalid response format');
        throw Exception('Failed to load product orders');
      }
    } catch (e) {
      debugPrint('❌ Error fetching product orders: $e');
      throw Exception('Failed to load product orders');
    }
  }
}
