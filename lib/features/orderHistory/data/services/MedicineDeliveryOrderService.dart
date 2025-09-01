import 'package:dio/dio.dart';
import 'package:vedika_healthcare/core/constants/ApiEndpoints.dart';
import 'package:vedika_healthcare/features/Vendor/MedicalStoreVendor/data/models/NewOrders/Order.dart';
import 'dart:io';
import 'package:path_provider/path_provider.dart';
import 'package:share_plus/share_plus.dart';

class MedicineDeliveryOrderService {
  final Dio _dio = Dio();

  // Fetch delivered medicine delivery orders for a userId from the backend API
  Future<List<Order>> getDeliveredOrdersByUser(String userId) async {
    try {
      final response = await _dio.get(
        '${ApiEndpoints.getDeliveredMedicineOrders}/$userId', // API endpoint to fetch delivered orders
      );

      if (response.statusCode == 200 && response.data['success']) {
        // Parsing the JSON response to a list of Order
        List<dynamic> data = response.data['data'];
        return data.map((order) => Order.fromJson(order)).toList();
      } else {
        throw Exception('Failed to fetch delivered orders');
      }
    } catch (e) {
      print('Error fetching delivered medicine orders: $e');
      return [];
    }
  }

  // Download medicine delivery invoice from the backend API
  Future<void> downloadMedicineDeliveryInvoice(String orderId) async {
    try {
      final response = await _dio.get(
        '${ApiEndpoints.downloadMedicineDeliveryInvoice}/$orderId',
        options: Options(
          responseType: ResponseType.bytes,
          headers: {
            'Accept': 'application/pdf',
          },
        ),
      );

      if (response.statusCode == 200) {
        // Get the temporary directory
        final directory = await getTemporaryDirectory();
        final filePath = '${directory.path}/medicine_delivery_invoice_$orderId.pdf';

        // Write the PDF bytes to a file
        final file = File(filePath);
        await file.writeAsBytes(response.data);

        // Share the file
        await Share.shareXFiles(
          [XFile(filePath)],
          text: 'Medicine Delivery Invoice - Order #$orderId',
        );

        print('Medicine delivery invoice downloaded and shared successfully');
      } else {
        throw Exception('Failed to download invoice');
      }
    } catch (e) {
      print('Error downloading medicine delivery invoice: $e');
      throw Exception('Failed to download invoice: $e');
    }
  }
}
