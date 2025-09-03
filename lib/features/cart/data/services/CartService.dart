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
      print('🔄 [CartService] Starting API call to get pending payment orders...');
      print('📍 [CartService] URL: ${ApiEndpoints.getPendingPaymentOrders}/$userId/pending-payments');
      print('👤 [CartService] User ID: $userId');
      print('🔑 [CartService] Auth Token: ${authToken != null ? 'Present' : 'Not provided'}');
      
      final response = await _dio.get(
        '${ApiEndpoints.getPendingPaymentOrders}/$userId/pending-payments',
        options: Options(
          headers: {
            if (authToken != null) 'Authorization': 'Bearer $authToken',
          },
        ),
      );

      print('✅ [CartService] API Response received');
      print('📊 [CartService] Status Code: ${response.statusCode}');
      print('📄 [CartService] Response Headers: ${response.headers}');
      print('📝 [CartService] Response Data: ${response.data}');

      if (response.statusCode == 200) {
        final responseData = response.data;
        print('🎯 [CartService] Parsing response data...');
        print('📊 [CartService] Response success: ${responseData['success']}');
        print('📊 [CartService] Response count: ${responseData['count']}');
        print('📊 [CartService] Response data length: ${responseData['data']?.length ?? 'null'}');
        
        final result = {
          'success': true,
          'data': responseData['data'] ?? [],
          'count': responseData['count'] ?? 0,
          'message': responseData['message'] ?? 'Pending payment orders retrieved successfully',
        };
        
        print('✅ [CartService] Successfully parsed response');
        print('📊 [CartService] Final result: $result');
        
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

  // Place medicine order after payment
  Future<Map<String, dynamic>> placeMedicineOrder({
    required String orderId,
    required String addressId,
    required String paymentId,
    String? authToken,
  }) async {
    try {
      print('🔄 [CartService] Starting API call to place medicine order...');
      print('📍 [CartService] URL: ${ApiEndpoints.placeMedicineOrder}');
      print('📦 [CartService] Order ID: $orderId');
      print('🏠 [CartService] Address ID: $addressId');
      print('💳 [CartService] Payment ID: $paymentId');
      print('🔑 [CartService] Auth Token: ${authToken != null ? 'Present' : 'Not provided'}');

      final response = await _dio.post(
        ApiEndpoints.placeMedicineOrder,
        data: {
          'orderId': orderId,
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

      print('✅ [CartService] API Response received');
      print('📊 [CartService] Status Code: ${response.statusCode}');
      print('📄 [CartService] Response Headers: ${response.headers}');
      print('📝 [CartService] Response Data: ${response.data}');

      if (response.statusCode == 200) {
        final responseData = response.data;
        print('🎯 [CartService] Parsing response data...');
        print('📊 [CartService] Response success: ${responseData['success']}');
        print('📊 [CartService] Response message: ${responseData['message']}');

        final result = {
          'success': true,
          'data': responseData['data'] ?? {},
          'message': responseData['message'] ?? 'Order placed successfully',
        };

        print('✅ [CartService] Successfully parsed response');
        print('📊 [CartService] Final result: $result');

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
      print('🔄 [CartService] Starting API call to get medicine cart count...');
      print('📍 [CartService] URL: ${ApiEndpoints.getMedicineCartCount}/$userId');
      print('👤 [CartService] User ID: $userId');
      print('🔑 [CartService] Auth Token: ${authToken != null ? 'Present' : 'Not provided'}');

      final response = await _dio.get(
        '${ApiEndpoints.getMedicineCartCount}/$userId',
        options: Options(
          headers: {
            if (authToken != null) 'Authorization': 'Bearer $authToken',
          },
        ),
      );

      print('✅ [CartService] API Response received');
      print('📊 [CartService] Status Code: ${response.statusCode}');
      print('📄 [CartService] Response Headers: ${response.headers}');
      print('📝 [CartService] Response Data: ${response.data}');

      if (response.statusCode == 200) {
        final responseData = response.data;
        print('🎯 [CartService] Parsing response data...');
        print('📊 [CartService] Response success: ${responseData['success']}');
        print('📊 [CartService] Response cart count: ${responseData['medicineCartCount']}');

        final result = {
          'success': true,
          'medicineCartCount': responseData['medicineCartCount'] ?? 0,
          'message': responseData['message'] ?? 'Cart count retrieved successfully',
        };

        print('✅ [CartService] Successfully parsed response');
        print('📊 [CartService] Final result: $result');

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

  // Mock data methods for development
  List<Map<String, dynamic>> getMockCartItems() {
    return [
      {
        'id': '1',
        'name': 'Vitamin D3 1000IU',
        'price': 299.0,
        'quantity': 2,
        'image': 'https://via.placeholder.com/80x80',
        'brand': 'HealthVit',
      },
      {
        'id': '2',
        'name': 'Omega-3 Fish Oil Capsules',
        'price': 450.0,
        'quantity': 1,
        'image': 'https://via.placeholder.com/80x80',
        'brand': 'NutriLife',
      },
    ];
  }

  List<Map<String, dynamic>> getMockMedicineOrders() {
    return [
      {
        'orderId': 'MED-001-2024',
        'medicalStoreName': 'HealthCare Pharmacy',
        'amount': 450.0,
        'note': 'Skip paracetamol if fever not present',
        'status': 'pending',
        'orderDate': '2024-01-15',
        'storePhone': '+91 98765 43210',
        'prescriptionFiles': 2,
      },
      {
        'orderId': 'MED-002-2024',
        'medicalStoreName': 'MedPlus Store',
        'amount': 320.0,
        'note': 'Full course treatment',
        'status': 'confirmed',
        'orderDate': '2024-01-14',
        'storePhone': '+91 98765 43211',
        'prescriptionFiles': 1,
      },
    ];
  }
}
