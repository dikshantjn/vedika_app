import 'package:dio/dio.dart';
import 'package:vedika_healthcare/core/constants/ApiEndpoints.dart';
import 'package:vedika_healthcare/features/Vendor/BloodBankAgencyVendor/data/model/BloodBankAgency.dart';
import 'package:vedika_healthcare/features/Vendor/Registration/Models/Vendor.dart';

class BloodBankRegistrationService {
  final Dio _dio = Dio();

  BloodBankRegistrationService() {
    _dio.options = BaseOptions(
      baseUrl: ApiEndpoints.baseUrl,
      connectTimeout: const Duration(seconds: 10),
      receiveTimeout: const Duration(seconds: 10),
      headers: {"Content-Type": "application/json"},
    );
  }

  Future<Map<String, dynamic>> registerBloodBank({
    required BloodBankAgency agency,
    required Vendor vendor,
  }) async {
    try {
      final response = await _dio.post(
        ApiEndpoints.bloodBankRegistration,
        data: {
          'vendor': vendor.toJson(),
          'bloodBankAgency': agency.toJson(),
        },
      );

      if (response.statusCode == 201) {
        print("Response Data: ${response.data}");
        return response.data;
      } else {
        throw Exception('Failed to register blood bank: ${response.data['message']}');
      }
    } on DioError catch (e) {
      throw Exception('Failed to register blood bank: ${e.response?.data['message'] ?? e.message}');
    }
  }
} 