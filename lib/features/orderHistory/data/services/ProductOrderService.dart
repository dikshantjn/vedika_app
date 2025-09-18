import 'dart:typed_data';

import 'package:dio/dio.dart';
import 'package:vedika_healthcare/core/constants/ApiEndpoints.dart';

class ProductOrderService {
  final Dio _dio = Dio();

  Future<Uint8List> fetchProductOrderInvoiceBytes(String orderId) async {
    try {
      final response = await _dio.get(
        '${ApiEndpoints.getProductOrderInvoice}/$orderId/invoice',
        options: Options(
          responseType: ResponseType.bytes,
          headers: const {
            'Accept': 'application/pdf',
          },
        ),
      );

      if (response.statusCode == 200) {
        final data = response.data;
        if (data is List<int>) {
          return Uint8List.fromList(data);
        }
        if (data is Uint8List) {
          return data;
        }
        throw Exception('Unexpected response type for PDF');
      } else {
        throw Exception('Failed to fetch product order invoice');
      }
    } catch (e) {
      rethrow;
    }
  }
}


