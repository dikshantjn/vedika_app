import 'package:dio/dio.dart';
import 'package:logger/logger.dart';
import '../../../../../core/constants/ApiEndpoints.dart';
import '../models/ProductOrder.dart';
import '../models/ProductOrderItem.dart';

class ProductPartnerOrderService {
  final Dio _dio;
  final Logger _logger = Logger(
    printer: PrettyPrinter(
      methodCount: 0,
      errorMethodCount: 8,
      lineLength: 120,
      colors: true,
      printEmojis: true,
      printTime: true,
    ),
  );

  ProductPartnerOrderService(this._dio);

  Future<List<ProductOrder>> getPendingOrdersByVendorId(String vendorId) async {
    try {
      _logger.i('Fetching pending orders for vendor: $vendorId');
      
      final response = await _dio.get(
        '${ApiEndpoints.getPendingOrdersByVendorId}/$vendorId',
      );

      _logger.i('Response status code: ${response.statusCode}');
      _logger.i('Response data: ${response.data}');

      if (response.statusCode == 200) {
        final List<dynamic> ordersData = response.data['pendingOrders'];
        _logger.i('Found ${ordersData.length} pending orders');
        
        return ordersData.map((orderData) {
          _logger.i('Processing order: ${orderData['orderId']}');
          _logger.i('User data: ${orderData['User']}');
          
          return ProductOrder.fromJson(orderData);
        }).toList();
      } else {
        _logger.e('Failed to fetch pending orders: ${response.statusMessage}');
        throw Exception('Failed to fetch pending orders');
      }
    } on DioException catch (e) {
      _logger.e('Dio error fetching pending orders: ${e.message}');
      if (e.response != null) {
        _logger.e('Error response: ${e.response?.data}');
      }
      if (e.response?.statusCode == 404) {
        throw Exception('No pending orders found');
      }
      throw Exception('Error fetching pending orders: ${e.message}');
    } catch (e) {
      _logger.e('Error fetching pending orders: $e');
      throw Exception('Error fetching pending orders: $e');
    }
  }

  Future<ProductOrder> updateOrderStatus(String orderId, String status) async {
    try {
      _logger.i('Updating order status for order: $orderId to: $status');
      
      final response = await _dio.put(
        '${ApiEndpoints.updateProductOrderStatus}/$orderId/status',
        data: {'status': status},
      );

      _logger.i('Response status code: ${response.statusCode}');
      _logger.i('Response data: ${response.data}');

      if (response.statusCode == 200) {
        return ProductOrder.fromJson(response.data['updatedOrder']);
      } else {
        _logger.e('Failed to update order status: ${response.statusMessage}');
        throw Exception('Failed to update order status');
      }
    } on DioException catch (e) {
      _logger.e('Dio error updating order status: ${e.message}');
      if (e.response != null) {
        _logger.e('Error response: ${e.response?.data}');
      }
      throw Exception('Error updating order status: ${e.message}');
    } catch (e) {
      _logger.e('Error updating order status: $e');
      throw Exception('Error updating order status: $e');
    }
  }
} 