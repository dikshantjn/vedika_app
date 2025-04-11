import 'package:dio/dio.dart';
import 'package:vedika_healthcare/features/Vendor/BloodBankAgencyVendor/data/model/BloodBankRequest.dart';

class BloodBankRequestService {
  final Dio _dio;
  final String baseUrl;

  BloodBankRequestService({
    required this.baseUrl,
    Dio? dio,
  }) : _dio = dio ?? Dio(BaseOptions(baseUrl: baseUrl));

  Future<List<BloodBankRequest>> getRequests(String vendorId) async {
    try {
      final response = await _dio.get('/requests', queryParameters: {
        'vendorId': vendorId,
      });
      
      return (response.data as List)
          .map((json) => BloodBankRequest.fromJson(json))
          .toList();
    } catch (e) {
      throw Exception('Failed to fetch blood bank requests');
    }
  }

  Future<BloodBankRequest> acceptRequest(String requestId, String vendorId) async {
    try {
      final response = await _dio.post(
        '/requests/$requestId/accept',
        data: {'vendorId': vendorId},
      );
      
      return BloodBankRequest.fromJson(response.data);
    } catch (e) {
      throw Exception('Failed to accept blood bank request');
    }
  }

  Future<BloodBankRequest> processRequest(String requestId, String vendorId) async {
    try {
      final response = await _dio.post(
        '/requests/$requestId/process',
        data: {'vendorId': vendorId},
      );
      
      return BloodBankRequest.fromJson(response.data);
    } catch (e) {
      throw Exception('Failed to process blood bank request');
    }
  }

  Future<List<String>> getPrescriptionUrls(String requestId) async {
    try {
      final response = await _dio.get('/requests/$requestId/prescriptions');
      return List<String>.from(response.data);
    } catch (e) {
      throw Exception('Failed to fetch prescription URLs');
    }
  }
} 