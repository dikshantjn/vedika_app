import 'package:dio/dio.dart';
import 'package:vedika_healthcare/core/constants/ApiEndpoints.dart';
import 'package:vedika_healthcare/features/Vendor/MedicalStoreVendor/data/models/NewOrders/Prescription.dart';
import 'package:vedika_healthcare/features/Vendor/MedicalStoreVendor/data/models/NewOrders/Order.dart';

class NewOrdersService {
  final Dio _dio = Dio();

  // Get prescriptions for a vendor
  Future<List<Prescription>> getPrescriptions(String vendorId) async {
    try {
      print('🔍 [NewOrdersService] Fetching prescriptions for vendor: $vendorId');
      
      final response = await _dio.get(
        '${ApiEndpoints.getPendingPrescriptions}/$vendorId',
        options: Options(
          headers: {
            'Content-Type': 'application/json',
          },
        ),
      );

      if (response.statusCode == 200) {
        final Map<String, dynamic> responseData = response.data;
        print('📊 [NewOrdersService] Response received: ${response.statusCode}');
        print('📊 [NewOrdersService] Response data: $responseData');
        
        if (responseData['success'] == true && responseData['data'] != null) {
          final List<dynamic> data = responseData['data'];
          print('📊 [NewOrdersService] Found ${data.length} prescriptions');
          
          final List<Prescription> prescriptions = [];
          for (int i = 0; i < data.length; i++) {
            try {
              print('🔍 [NewOrdersService] Parsing prescription $i: ${data[i]}');
              final prescription = Prescription.fromJson(data[i]);
              print('✅ [NewOrdersService] Successfully parsed prescription: ${prescription.userName} - ${prescription.userPhone}');
              prescriptions.add(prescription);
            } catch (e) {
              print('❌ [NewOrdersService] Error parsing prescription $i: $e');
              print('📊 [NewOrdersService] Raw data: ${data[i]}');
            }
          }
          
          return prescriptions;
        } else {
          throw Exception('API response indicates failure');
        }
      } else {
        throw Exception('Failed to load prescriptions: ${response.statusCode}');
      }
    } on DioException catch (e) {
      print('❌ [NewOrdersService] DioException: ${e.message}');
      throw Exception('Error fetching prescriptions: ${e.message}');
    } catch (e) {
      print('❌ [NewOrdersService] General error: $e');
      throw Exception('Error fetching prescriptions: $e');
    }
  }

  // Get orders for a vendor
  Future<List<Order>> getOrders(String vendorId) async {
    try {
      print('🔍 [NewOrdersService] Fetching orders for vendor: $vendorId');
      
      final response = await _dio.get(
        '${ApiEndpoints.getOrdersByVendor}/$vendorId',
        options: Options(
          headers: {
            'Content-Type': 'application/json',
          },
        ),
      );

      if (response.statusCode == 200) {
        final Map<String, dynamic> responseData = response.data;
        print('📊 [NewOrdersService] Response received: ${response.statusCode}');
        print('📊 [NewOrdersService] Response data: $responseData');
        
        if (responseData['success'] == true && responseData['data'] != null) {
          final List<dynamic> data = responseData['data'];
          print('📊 [NewOrdersService] Found ${data.length} orders');
          
          final List<Order> orders = [];
          for (int i = 0; i < data.length; i++) {
            try {
              print('🔍 [NewOrdersService] Parsing order $i: ${data[i]}');
              final order = Order.fromJson(data[i]);
              print('✅ [NewOrdersService] Successfully parsed order: ${order.user?.name} - ${order.user?.phoneNumber}');
              orders.add(order);
            } catch (e) {
              print('❌ [NewOrdersService] Error parsing order $i: $e');
              print('📊 [NewOrdersService] Raw data: ${data[i]}');
            }
          }
          
          return orders;
        } else {
          throw Exception('API response indicates failure');
        }
      } else {
        throw Exception('Failed to load orders: ${response.statusCode}');
      }
    } on DioException catch (e) {
      print('❌ [NewOrdersService] DioException: ${e.message}');
      throw Exception('Error fetching orders: ${e.message}');
    } catch (e) {
      print('❌ [NewOrdersService] General error: $e');
      throw Exception('Error fetching orders: $e');
    }
  }

  // Accept prescription
  Future<Map<String, dynamic>> acceptPrescription(String prescriptionId, String vendorId, String vendorNote, String userId) async {
    try {
      final response = await _dio.post(
        '${ApiEndpoints.acceptPrescription}/$prescriptionId/accept',
        data: {
          'vendorId': vendorId,
          'note': vendorNote,
          'userId':userId
        },
        options: Options(
          headers: {
            'Content-Type': 'application/json',
          },
        ),
      );

      if (response.statusCode == 201) {
        return response.data;
      } else {
        throw Exception('Failed to accept prescription: ${response.statusCode}');
      }
    } on DioException catch (e) {
      throw Exception('Error accepting prescription: ${e.message}');
    } catch (e) {
      throw Exception('Error accepting prescription: $e');
    }
  }

  // Reject prescription
  Future<Map<String, dynamic>> rejectPrescription(String prescriptionId, String vendorId, String vendorNote) async {
    try {
      final response = await _dio.post(
        '${ApiEndpoints.rejectPrescription}/$prescriptionId/reject',
        data: {
          'vendorId': vendorId,
          'note': vendorNote,
        },
        options: Options(
          headers: {
            'Content-Type': 'application/json',
          },
        ),
      );

      if (response.statusCode == 200) {
        return response.data;
      } else {
        throw Exception('Failed to reject prescription: ${response.statusCode}');
      }
    } on DioException catch (e) {
      throw Exception('Error rejecting prescription: ${e.message}');
    } catch (e) {
      throw Exception('Error rejecting prescription: $e');
    }
  }

  // Update order payment amount
  Future<Map<String, dynamic>> updateOrderPayment(String orderId, double totalAmount) async {
    try {
      final response = await _dio.patch(
        '${ApiEndpoints.updateOrderPayment}/$orderId/payment',
        data: {
          'totalAmount': totalAmount,
        },
        options: Options(
          headers: {
            'Content-Type': 'application/json',
          },
        ),
      );

      if (response.statusCode == 200) {
        return response.data;
      } else {
        throw Exception('Failed to update order payment: ${response.statusCode}');
      }
    } on DioException catch (e) {
      throw Exception('Error updating order payment: ${e.message}');
    } catch (e) {
      throw Exception('Error updating order payment: $e');
    }
  }

  // Update order note
  Future<Map<String, dynamic>> updateOrderNote(String orderId, String note) async {
    try {
      final response = await _dio.patch(
        '${ApiEndpoints.updateOrderNote}/$orderId/note',
        data: {
          'note': note,
        },
        options: Options(
          headers: {
            'Content-Type': 'application/json',
          },
        ),
      );

      if (response.statusCode == 200) {
        return response.data;
      } else {
        throw Exception('Failed to update order note: ${response.statusCode}');
      }
    } on DioException catch (e) {
      throw Exception('Error updating order note: ${e.message}');
    } catch (e) {
      throw Exception('Error updating order note: $e');
    }
  }

  // Update order status
  Future<Map<String, dynamic>> updateOrderStatus(String orderId, String status) async {
    try {
      print('🔍 [NewOrdersService] Updating order status: $orderId to $status');
      
      final response = await _dio.patch(
        ApiEndpoints.updateOrderStatus,
        data: {
          'orderId': orderId,
          'status': status,
        },
        options: Options(
          headers: {
            'Content-Type': 'application/json',
          },
        ),
      );

      if (response.statusCode == 200) {
        print('✅ [NewOrdersService] Order status updated successfully');
        print('📊 [NewOrdersService] Response: ${response.data}');
        return response.data;
      } else {
        print('❌ [NewOrdersService] Failed to update order status: ${response.statusCode}');
        throw Exception('Failed to update order status: ${response.statusCode}');
      }
    } on DioException catch (e) {
      print('❌ [NewOrdersService] DioException: ${e.message}');
      throw Exception('Error updating order status: ${e.message}');
    } catch (e) {
      print('❌ [NewOrdersService] General error: $e');
      throw Exception('Error updating order status: $e');
    }
  }
}
