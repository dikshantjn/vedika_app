import 'dart:typed_data';
import 'package:dio/dio.dart';
import 'package:vedika_healthcare/core/constants/ApiEndpoints.dart';

class BloodBankOrderService {
  final Dio _dio = Dio();

  // Fetch blood bank invoice bytes (for preview in viewer)
  Future<Uint8List> fetchBloodBankInvoiceBytes(String bookingId) async {
    try {
      final response = await _dio.get(
        '${ApiEndpoints.getBloodBankInvoice}/$bookingId',
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
        throw Exception('Failed to fetch blood bank invoice');
      }
    } catch (e) {
      print('Error fetching blood bank invoice bytes: $e');
      rethrow;
    }
  }
}
