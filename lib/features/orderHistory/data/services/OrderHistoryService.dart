import 'package:dio/dio.dart';
import 'package:vedika_healthcare/core/constants/ApiEndpoints.dart';
import 'package:vedika_healthcare/features/Vendor/ProductPartner/data/models/ProductOrder.dart';

class OrderHistoryService {
  final Dio _dio = Dio();

  Future<List<ProductOrder>> fetchDeliveredProductOrders(String userId) async {
    try {
      final response = await _dio.get('${ApiEndpoints.getDeliveredProductOrdersByUserId}/$userId/delivered');
      
      if (response.statusCode == 200) {
        List<dynamic> ordersJson = response.data['orders'];
        return ordersJson.map((json) => ProductOrder.fromJson(json)).toList();
      } else {
        throw Exception('Failed to load delivered orders');
      }
    } catch (e) {
      print('Error fetching delivered orders: $e');
      throw Exception('Failed to load delivered orders');
    }
  }
} 