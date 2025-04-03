import 'package:dio/dio.dart';
import 'package:vedika_healthcare/core/constants/ApiEndpoints.dart';
import 'package:vedika_healthcare/features/Vendor/MedicalStoreVendor/data/models/MedicineOrderModel.dart';
import 'package:vedika_healthcare/features/orderHistory/data/models/MedicineOrder.dart';

class MedicineOrderRepository {
  final Dio _dio = Dio();

  // Fetch orders for a userId from the backend API
  Future<List<MedicineOrderModel>> getOrdersByUser(String userId) async {
    try {
      final response = await _dio.get(
        '${ApiEndpoints.getOrderStatus}/$userId',  // API endpoint to fetch orders
      );

      if (response.statusCode == 200) {
        // Parsing the JSON response to a list of MedicineOrderModel
        List<dynamic> data = response.data['orders'];
        return data.map((order) => MedicineOrderModel.fromJson(order)).toList();
      } else {
        throw Exception('Failed to fetch orders');
      }
    } catch (e) {
      print('Error fetching orders: $e');
      return [];
    }
  }
}
