import 'package:dio/dio.dart';
import 'package:flutter/foundation.dart';
import 'package:vedika_healthcare/core/constants/ApiEndpoints.dart';
import 'package:vedika_healthcare/core/auth/data/services/StorageService.dart';

class ProductOrderService {
  final Dio _dio = Dio();

  Future<Map<String, dynamic>> placeProductOrder() async {
    try {
      debugPrint("🛍️ Starting product order placement...");
      
      String? userId = await StorageService.getUserId();
      if (userId == null) {
        throw Exception('User ID not found');
      }
      debugPrint("👤 User ID: $userId");
      
      final requestBody = {
        'userId': userId,
      };
      debugPrint("📦 Request body: $requestBody");

      debugPrint("📡 Making API call to: ${ApiEndpoints.placeProductOrder}");
      final response = await _dio.post(
        ApiEndpoints.placeProductOrder,
        data: requestBody,
      );

      debugPrint("📥 Response status code: ${response.statusCode}");
      debugPrint("📥 Response data: ${response.data}");

      if (response.statusCode == 201) {
        debugPrint("✅ Product order placed successfully");
        return response.data;
      } else {
        debugPrint("❌ Failed to place product order. Status: ${response.statusCode}");
        debugPrint("❌ Error response: ${response.data}");
        throw Exception('Failed to place product order: ${response.data}');
      }
    } on DioException catch (e) {
      debugPrint("❌ DioException placing product order:");
      debugPrint("❌ Error type: ${e.type}");
      debugPrint("❌ Error message: ${e.message}");
      if (e.response != null) {
        debugPrint("❌ Error response: ${e.response?.data}");
        debugPrint("❌ Error status code: ${e.response?.statusCode}");
      }
      throw Exception('Error placing product order: ${e.message}');
    } catch (e, stackTrace) {
      debugPrint("❌ Unexpected error placing product order:");
      debugPrint("❌ Error: $e");
      debugPrint("❌ Stack trace: $stackTrace");
      throw Exception('Error placing product order: $e');
    }
  }
} 