import 'dart:convert';
import 'package:dio/dio.dart';
import 'package:vedika_healthcare/core/constants/ApiEndpoints.dart';

class CartService {
  final Dio _dio = Dio();

  // Get orders waiting for payment
  Future<Map<String, dynamic>> getPendingPaymentOrders({
    required String userId,
    String? authToken,
  }) async {
    try {

      final response = await _dio.get(
        '${ApiEndpoints.getPendingPaymentOrders}/$userId/pending-payments',
        options: Options(
          headers: {
            if (authToken != null) 'Authorization': 'Bearer $authToken',
          },
        ),
      );

      if (response.statusCode == 200) {
        final responseData = response.data;

        final result = {
          'success': true,
          'data': responseData['data'] ?? [],
          'count': responseData['count'] ?? 0,
          'message': responseData['message'] ?? 'Pending payment orders retrieved successfully',
        };
        

        return result;
      } else {
        print('❌ [CartService] API returned non-200 status code');
        print('📊 [CartService] Status: ${response.statusCode}');
        print('📝 [CartService] Response: ${response.data}');
        throw Exception('Failed to get pending payment orders: ${response.statusCode}');
      }
    } on DioException catch (e) {
      print('🚨 [CartService] DioException occurred');
      print('📊 [CartService] Error type: ${e.type}');
      print('📊 [CartService] Error message: ${e.message}');
      print('📊 [CartService] Error response: ${e.response}');
      print('📊 [CartService] Error request: ${e.requestOptions}');
      print('📊 [CartService] Error stack trace: ${e.stackTrace}');
      
      if (e.response != null) {
        print('📊 [CartService] Error response status: ${e.response!.statusCode}');
        print('📊 [CartService] Error response data: ${e.response!.data}');
        print('📊 [CartService] Error response headers: ${e.response!.headers}');
      }
      
      throw Exception('Error getting pending payment orders: ${e.message}');
    } catch (e, stackTrace) {
      print('🚨 [CartService] Unexpected error occurred');
      print('📊 [CartService] Error: $e');
      print('📊 [CartService] Stack trace: $stackTrace');
      throw Exception('Error getting pending payment orders: $e');
    }
  }

  // Place one or more medicine orders after payment
  Future<Map<String, dynamic>> placeMedicineOrder({
    required List<String> orderIds,
    required String addressId,
    required String paymentId,
    String? authToken,
  }) async {
    try {

      final response = await _dio.post(
        ApiEndpoints.placeMedicineOrder,
        data: {
          'orderIds': orderIds,
          'addressId': addressId,
          'paymentId': paymentId,
        },
        options: Options(
          headers: {
            if (authToken != null) 'Authorization': 'Bearer $authToken',
            'Content-Type': 'application/json',
          },
        ),
      );

      if (response.statusCode == 200) {
        final responseData = response.data;

        final result = {
          'success': true,
          'data': responseData['data'] ?? {},
          'message': responseData['message'] ?? 'Order placed successfully',
        };


        return result;
      } else {
        print('❌ [CartService] API returned non-200 status code');
        print('📊 [CartService] Status: ${response.statusCode}');
        print('📝 [CartService] Response: ${response.data}');
        throw Exception('Failed to place medicine order: ${response.statusCode}');
      }
    } on DioException catch (e) {
      print('🚨 [CartService] DioException occurred');
      print('📊 [CartService] Error type: ${e.type}');
      print('📊 [CartService] Error message: ${e.message}');
      print('📊 [CartService] Error response: ${e.response}');
      print('📊 [CartService] Error request: ${e.requestOptions}');
      print('📊 [CartService] Error stack trace: ${e.stackTrace}');

      if (e.response != null) {
        print('📊 [CartService] Error response status: ${e.response!.statusCode}');
        print('📊 [CartService] Error response data: ${e.response!.data}');
        print('📊 [CartService] Error response headers: ${e.response!.headers}');
      }

      throw Exception('Error placing medicine order: ${e.message}');
    } catch (e, stackTrace) {
      print('🚨 [CartService] Unexpected error occurred');
      print('📊 [CartService] Error: $e');
      print('📊 [CartService] Stack trace: $stackTrace');
      throw Exception('Error placing medicine order: $e');
    }
  }

  // Get medicine cart count
  Future<Map<String, dynamic>> getMedicineCartCount({
    required String userId,
    String? authToken,
  }) async {
    try {

      final response = await _dio.get(
        '${ApiEndpoints.getMedicineCartCount}/$userId',
        options: Options(
          headers: {
            if (authToken != null) 'Authorization': 'Bearer $authToken',
          },
        ),
      );


      if (response.statusCode == 200) {
        final responseData = response.data;

        final result = {
          'success': true,
          'medicineCartCount': responseData['medicineCartCount'] ?? 0,
          'message': responseData['message'] ?? 'Cart count retrieved successfully',
        };

        return result;
      } else {
        print('❌ [CartService] API returned non-200 status code');
        print('📊 [CartService] Status: ${response.statusCode}');
        print('📝 [CartService] Response: ${response.data}');
        throw Exception('Failed to get medicine cart count: ${response.statusCode}');
      }
    } on DioException catch (e) {
      print('🚨 [CartService] DioException occurred');
      print('📊 [CartService] Error type: ${e.type}');
      print('📊 [CartService] Error message: ${e.message}');
      print('📊 [CartService] Error response: ${e.response}');
      print('📊 [CartService] Error request: ${e.requestOptions}');
      print('📊 [CartService] Error stack trace: ${e.stackTrace}');

      if (e.response != null) {
        print('📊 [CartService] Error response status: ${e.response!.statusCode}');
        print('📊 [CartService] Error response data: ${e.response!.data}');
        print('📊 [CartService] Error response headers: ${e.response!.headers}');
      }

      throw Exception('Error getting medicine cart count: ${e.message}');
    } catch (e, stackTrace) {
      print('🚨 [CartService] Unexpected error occurred');
      print('📊 [CartService] Error: $e');
      print('📊 [CartService] Stack trace: $stackTrace');
      throw Exception('Error getting medicine cart count: $e');
    }
  }
}
