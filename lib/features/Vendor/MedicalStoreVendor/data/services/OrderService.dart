import 'package:dio/dio.dart';
import 'package:vedika_healthcare/core/constants/ApiEndpoints.dart';
import 'package:vedika_healthcare/features/Vendor/MedicalStoreVendor/data/models/MedicineOrderModel.dart';

class OrderService {
  final Dio _dio = Dio(); // Initialize Dio instance

  // Method to get all orders
  Future<List<MedicineOrderModel>> getOrders() async {
    try {
      final response = await _dio.get(ApiEndpoints.getOrders);

      if (response.statusCode == 200) {
        // Map the response data to a list of MedicineOrderModel instances
        List<dynamic> data = response.data['orders'];
        print("Response data: ${response.data}");

        return data.map((order) => MedicineOrderModel.fromJson(order)).toList();
      } else {
        throw Exception('Failed to load orders');
      }
    } catch (e) {
      print("Error fetching orders: $e");
      throw Exception("Error fetching orders");
    }
  }
}
