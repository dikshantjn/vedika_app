import 'package:dio/dio.dart';
import 'package:flutter/foundation.dart';
import 'package:vedika_healthcare/core/constants/ApiEndpoints.dart';

class PrescriptionService {
  final Dio _dio = Dio();

  /// Uploads the prescription to the backend
  Future<Map<String, dynamic>> uploadPrescription({
    required String prescriptionUrl,
    required String userId,
    required double latitude,
    required double longitude,
  }) async {
    try {
      Map<String, dynamic> requestData = {
        'userId': userId,
        'prescriptionUrl': prescriptionUrl,
        'userLocation': {
          'latitude': latitude,
          'longitude': longitude,
        }
      };

      Response response = await _dio.post(
        ApiEndpoints.uploadPrescription,
        data: requestData,
        options: Options(headers: {'Content-Type': 'application/json'}),
      );

      print("Response : $response");
      if (response.statusCode == 200) {
        return {'success': true, 'message': 'Prescription uploaded successfully', 'data': response.data};
      } else {
        return {'success': false, 'message': 'Failed to upload prescription', 'error': response.data};
      }
    } catch (e) {
      return {'success': false, 'message': 'An error occurred while uploading the prescription', 'error': e.toString()};
    }
  }

  Future<String?> checkPrescriptionAcceptance(String userId) async {
    try {
      Response response = await _dio.post(
        ApiEndpoints.checkPrescriptionAcceptanceStatus,
        data: {'userId': userId},
        options: Options(headers: {'Content-Type': 'application/json'}),
      );

      if (response.statusCode == 200 && response.data['success'] == true) {
        return response.data['acceptedBy']; // Store Name or ID (Accepted Vendor)
      } else {
        return null; // Still pending or not found
      }
    } catch (e) {
      debugPrint('Error checking prescription acceptance: $e');
      return null;
    }
  }

  /// Search for more vendors with an increased radius
  Future<Map<String, dynamic>> searchMoreVendors({
    required String prescriptionId,
    required double latitude,
    required double longitude,
    required double searchRadius,
  }) async {
    try {
      Map<String, dynamic> requestData = {
        'userLocation': {
          'latitude': latitude,
          'longitude': longitude,
        },
        'searchRadius': searchRadius,
      };

      Response response = await _dio.post(
        '${ApiEndpoints.searchMoreVendors}/$prescriptionId/search-more-vendors',
        data: requestData,
        options: Options(headers: {'Content-Type': 'application/json'}),
      );

      if (response.statusCode == 200) {
        return {
          'success': true,
          'message': response.data['message'],
          'newVendors': response.data['newVendors'],
          'moreVendorsAvailable': response.data['moreVendorsAvailable'],
        };
      } else {
        return {
          'success': false,
          'message': 'Failed to search for more vendors',
          'error': response.data,
        };
      }
    } catch (e) {
      return {
        'success': false,
        'message': 'An error occurred while searching for more vendors',
        'error': e.toString(),
      };
    }
  }
}
