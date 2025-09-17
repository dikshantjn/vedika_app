import 'package:dio/dio.dart';
import 'package:flutter/foundation.dart';
import 'package:vedika_healthcare/core/constants/ApiEndpoints.dart';
import 'package:vedika_healthcare/core/auth/data/services/StorageService.dart';

class ProductOrderPlacementService {
  final Dio _dio;

  ProductOrderPlacementService(this._dio);

  Future<Map<String, dynamic>> placeProductOrder() async {
    try {
      final String? userId = await StorageService.getUserId();
      if (userId == null) {
        throw Exception('User ID not found');
      }
      final requestBody = {'userId': userId};

      final response = await _dio.post(
        ApiEndpoints.placeProductOrder,
        data: requestBody,
      );

      if (response.statusCode == 201) {
        return response.data as Map<String, dynamic>;
      }
      throw Exception('Failed to place product order: ${response.data}');
    } on DioException catch (e) {
      rethrow;
    }
  }
}


