import 'dart:typed_data';
import 'package:dio/dio.dart';
import 'package:vedika_healthcare/core/constants/ApiEndpoints.dart';

class AmbulanceOrderService {
  final Dio _dio = Dio();

  // Fetch ambulance invoice bytes (for preview in viewer)
  Future<Uint8List> fetchAmbulanceInvoiceBytes(String bookingId) async {
    try {
      final response = await _dio.get(
        '${ApiEndpoints.getAmbulanceInvoice}/$bookingId',
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
        throw Exception('Failed to fetch ambulance invoice');
      }
    } catch (e) {
      print('Error fetching ambulance invoice bytes: $e');
      rethrow;
    }
  }
}
