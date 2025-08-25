import 'package:dio/dio.dart';
import 'package:flutter/foundation.dart';
import 'package:vedika_healthcare/core/constants/ApiEndpoints.dart';
import 'package:vedika_healthcare/features/Vendor/ProductPartner/data/models/ProductOrder.dart';

class OrderHistoryService {
  final Dio _dio = Dio();

  Future<List<ProductOrder>> fetchDeliveredProductOrders(String userId) async {
    try {
      final String url = '${ApiEndpoints.getDeliveredProductOrdersByUserId}/$userId/delivered';

      final response = await _dio.get(url);

      
      if (response.statusCode == 200) {
        if (!response.data.containsKey('orders')) {
          debugPrint('❌ Response missing "orders" key. Response structure: ${response.data.keys}');
          throw Exception('Invalid response format: missing orders key');
        }

        List<dynamic> ordersJson = response.data['orders'];

        List<ProductOrder> orders = [];
        for (var i = 0; i < ordersJson.length; i++) {
          try {

            // Check for required fields
            final requiredFields = ['orderId', 'userId', 'totalAmount', 'status', 'placedAt'];
            for (var field in requiredFields) {
              if (ordersJson[i][field] == null) {
                debugPrint('⚠️ Warning: Required field "$field" is null in order ${i + 1}');
              }
            }

            // Check user data specifically
            if (ordersJson[i]['user'] == null) {
              debugPrint('⚠️ Warning: User data is null in order ${i + 1}');
            }


            final order = ProductOrder.fromJson(ordersJson[i]);
            orders.add(order);
          } catch (parseError, stackTrace) {
            debugPrint('❌ Error parsing order ${i + 1}: $parseError');
            debugPrint('📍 Stack trace: $stackTrace');
            debugPrint('🔍 Problematic JSON: ${ordersJson[i]}');
            rethrow;
          }
        }

        return orders;
      } else {
        debugPrint('❌ API returned non-200 status code: ${response.statusCode}');
        debugPrint('❌ Response data: ${response.data}');
        throw Exception('Failed to load delivered orders: ${response.statusCode}');
      }
    } catch (e, stackTrace) {
      debugPrint('❌ Error fetching delivered orders: $e');
      debugPrint('📍 Stack trace: $stackTrace');
      throw Exception('Failed to load delivered orders: $e');
    }
  }
} 