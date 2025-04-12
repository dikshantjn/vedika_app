import 'package:vedika_healthcare/core/constants/ApiEndpoints.dart';

import '../model/BloodBankAgency.dart';
import 'package:dio/dio.dart';

class BloodBankAgencyProfileService {
  final Dio _dio = Dio();

  // Get agency profile
  Future<BloodBankAgency> getAgencyProfile(String vendorId) async {
    try {
      final response = await _dio.get('${ApiEndpoints.bloodBankProfile}/$vendorId');
      
      if (response.statusCode == 200) {
        final Map<String, dynamic> data = response.data;
        final Map<String, dynamic> agencyData = data['agency'];
        return BloodBankAgency.fromJson(agencyData);
      } else {
        throw Exception('Failed to load agency profile: ${response.statusCode}');
      }
    } catch (e) {
      throw Exception('Error fetching agency profile: $e');
    }
  }

  // Update agency profile
  Future<BloodBankAgency> updateAgencyProfile(BloodBankAgency agency) async {
    try {
      final response = await _dio.put(
        '${ApiEndpoints.bloodBankProfile}/${agency.vendorId}',
        data: agency.toJson(),
      );
      
      if (response.statusCode == 200) {
        final Map<String, dynamic> data = response.data;
        final Map<String, dynamic> agencyData = data['agency'];
        return BloodBankAgency.fromJson(agencyData);
      } else {
        throw Exception('Failed to update agency profile: ${response.statusCode}');
      }
    } catch (e) {
      throw Exception('Error updating agency profile: $e');
    }
  }
} 