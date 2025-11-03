import 'package:dio/dio.dart';
import 'package:vedika_healthcare/core/constants/ApiEndpoints.dart';
import 'package:vedika_healthcare/features/Vendor/MedicalStoreVendor/data/models/NewOrders/Prescription.dart';
import 'package:vedika_healthcare/features/Vendor/MedicalStoreVendor/data/models/NewOrders/Order.dart';
import 'package:vedika_healthcare/features/DeliveryAddress/data/modal/DeliveryAddressModel.dart';

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
  Future<Map<String, dynamic>> acceptPrescription(String prescriptionId, String vendorId, String vendorNote, String userId, {String? addressId}) async {
    try {
      final response = await _dio.post(
        '${ApiEndpoints.acceptPrescription}/$prescriptionId/accept',
        data: {
          'vendorId': vendorId,
          'note': vendorNote,
          'userId':userId,
          if (addressId != null) 'addressId': addressId,
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

  Future<DeliveryAddressModel> getDeliveryAddressById(String addressId) async {
    try {
      final response = await _dio.get(
        '${ApiEndpoints.getDeliveryAddressById}/$addressId',
        options: Options(
          headers: {
            'Content-Type': 'application/json',
          },
        ),
      );

      if (response.statusCode == 200) {
        final Map<String, dynamic> responseData = response.data;
        final Map<String, dynamic> data = responseData['data'];
        return DeliveryAddressModel.fromJson(data);
      } else {
        throw Exception('Failed to fetch address: ${response.statusCode}');
      }
    } on DioException catch (e) {
      throw Exception('Error fetching address: ${e.message}');
    } catch (e) {
      throw Exception('Error fetching address: $e');
    }
  }

  // Reject prescription
  Future<Map<String, dynamic>> rejectPrescription(String prescriptionId, String vendorId, String reason) async {
    try {
      final response = await _dio.post(
        '${ApiEndpoints.rejectPrescription}/$prescriptionId/reject',
        data: {
          'vendorId': vendorId,
          'reason': reason,
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

  // Update order billing (medicines, discount, delivery charge, total)
  Future<Map<String, dynamic>> updateOrderBilling(
    String orderId,
    List<Map<String, dynamic>> medicines,
    double discountPercent,
    double deliveryCharge,
    double totalAmount,
  ) async {
    try {
      print('🔍 [NewOrdersService] Updating order billing: $orderId');
      
      final response = await _dio.patch(
        '${ApiEndpoints.updateOrderPayment}/$orderId/payment',
        data: {
          'medicines': medicines,
          'discountPercent': discountPercent,
          'deliveryCharge': deliveryCharge,
          'totalAmount': totalAmount,
        },
        options: Options(
          headers: {
            'Content-Type': 'application/json',
          },
        ),
      );

      if (response.statusCode == 200) {
        print('✅ [NewOrdersService] Order billing updated successfully');
        return response.data;
      } else {
        print('❌ [NewOrdersService] Failed to update order billing: ${response.statusCode}');
        throw Exception('Failed to update order billing: ${response.statusCode}');
      }
    } on DioException catch (e) {
      print('❌ [NewOrdersService] DioException: ${e.message}');
      throw Exception('Error updating order billing: ${e.message}');
    } catch (e) {
      print('❌ [NewOrdersService] General error: $e');
      throw Exception('Error updating order billing: $e');
    }
  }

  // Add medicines and billing details to order
  Future<Map<String, dynamic>> addOrderMedicines(
    String orderId,
    List<Map<String, dynamic>> medicines,
    double subtotal,
    double discountPercent, // Discount as percentage
    double gstPercent, // GST as percentage
    double deliveryCharges,
    double platformFee,
    double totalAmount,
  ) async {
    try {
      print('🔍 [NewOrdersService] Adding medicines to order: $orderId');
      
      final response = await _dio.put(
        '${ApiEndpoints.addOrderMedicines}/$orderId/add-medicines',
        data: {
          'medicines': medicines,
          'subtotal': subtotal,
          'discount': discountPercent, // Send discount as percentage
          'gst': gstPercent, // Send GST as percentage
          'deliveryCharges': deliveryCharges,
          'platformFee': platformFee,
          'totalAmount': totalAmount,
        },
        options: Options(
          headers: {
            'Content-Type': 'application/json',
          },
        ),
      );

      if (response.statusCode == 200 || response.statusCode == 201) {
        print('✅ [NewOrdersService] Medicines added successfully');
        return response.data;
      } else {
        print('❌ [NewOrdersService] Failed to add medicines: ${response.statusCode}');
        throw Exception('Failed to add medicines: ${response.statusCode}');
      }
    } on DioException catch (e) {
      print('❌ [NewOrdersService] DioException: ${e.message}');
      throw Exception('Error adding medicines: ${e.message}');
    } catch (e) {
      print('❌ [NewOrdersService] General error: $e');
      throw Exception('Error adding medicines: $e');
    }
  }

  // Get order details with medicines and billing
  Future<Map<String, dynamic>> getOrderDetails(String orderId) async {
    try {
      print('🔍 [NewOrdersService] Fetching order details: $orderId');
      
      final response = await _dio.get(
        '${ApiEndpoints.getOrderDetails}/$orderId/details',
        options: Options(
          headers: {
            'Content-Type': 'application/json',
          },
        ),
      );

      if (response.statusCode == 200) {
        print('✅ [NewOrdersService] Order details fetched successfully');
        return response.data;
      } else {
        print('❌ [NewOrdersService] Failed to fetch order details: ${response.statusCode}');
        throw Exception('Failed to fetch order details: ${response.statusCode}');
      }
    } on DioException catch (e) {
      print('❌ [NewOrdersService] DioException: ${e.message}');
      throw Exception('Error fetching order details: ${e.message}');
    } catch (e) {
      print('❌ [NewOrdersService] General error: $e');
      throw Exception('Error fetching order details: $e');
    }
  }

  // Delete medicine from order
  Future<Map<String, dynamic>> deleteOrderMedicine(String orderId, String orderMedicineId) async {
    try {
      print('🔍 [NewOrdersService] Deleting medicine: $orderMedicineId from order: $orderId');
      
      final response = await _dio.delete(
        '${ApiEndpoints.deleteOrderMedicine}/$orderId/$orderMedicineId',
        options: Options(
          headers: {
            'Content-Type': 'application/json',
          },
        ),
      );

      if (response.statusCode == 200) {
        print('✅ [NewOrdersService] Medicine deleted successfully');
        return response.data;
      } else {
        print('❌ [NewOrdersService] Failed to delete medicine: ${response.statusCode}');
        throw Exception('Failed to delete medicine: ${response.statusCode}');
      }
    } on DioException catch (e) {
      print('❌ [NewOrdersService] DioException: ${e.message}');
      throw Exception('Error deleting medicine: ${e.message}');
    } catch (e) {
      print('❌ [NewOrdersService] General error: $e');
      throw Exception('Error deleting medicine: $e');
    }
  }
}
