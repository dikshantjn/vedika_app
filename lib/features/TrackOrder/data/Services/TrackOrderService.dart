import 'package:dio/dio.dart';
import 'package:vedika_healthcare/core/constants/ApiEndpoints.dart';
import 'package:vedika_healthcare/features/Vendor/MedicalStoreVendor/data/models/CartModel.dart';
import 'package:vedika_healthcare/features/Vendor/MedicalStoreVendor/data/models/MedicineOrderModel.dart';
import 'package:vedika_healthcare/features/ambulance/data/models/AmbulanceBooking.dart';

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

}
