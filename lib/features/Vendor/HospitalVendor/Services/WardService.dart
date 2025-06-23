import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:vedika_healthcare/core/constants/ApiEndpoints.dart';
import 'package:vedika_healthcare/features/Vendor/HospitalVendor/Models/Ward.dart';

class WardService {
  Future<List<Ward>> getWards(String hospitalId) async {
    final url = '${ApiEndpoints.baseUrl}/hospitals/wards/vendor/$hospitalId';
    print('🔍 GET Request to: $url');
    
    try {
      final response = await http.get(Uri.parse(url));
      print('📥 Response Status Code: ${response.statusCode}');
      print('📥 Response Body: ${response.body}');

      if (response.statusCode == 200) {
        final List<dynamic> data = json.decode(response.body);
        return data.map((json) => Ward.fromJson(json)).toList();
      } else {
        print('❌ Error: Failed to load wards');
        print('❌ Status Code: ${response.statusCode}');
        print('❌ Response Body: ${response.body}');
        throw Exception('Failed to load wards: ${response.body}');
      }
    } catch (e) {
      print('❌ Exception occurred while getting wards:');
      print('❌ Error Details: $e');
      throw Exception('Failed to connect to server: $e');
    }
  }

  Future<Ward> addWard(Ward ward) async {
    final url = ApiEndpoints.addWard;
    final body = {
      'name': ward.name,
      'wardType': ward.wardType,
      'totalBeds': ward.totalBeds,
      'availableBeds': ward.availableBeds,
      'pricePerDay': ward.pricePerDay,
      'genderRestriction': ward.genderRestriction,
      'isAC': ward.isAC,
      'hasAttachedBathroom': ward.hasAttachedBathroom,
      'isIsolation': ward.isIsolation,
      'description': ward.description,
      'vendorId': ward.vendorId,
      'facilities': ward.facilities,
    };

    print('📤 POST Request to: $url');
    print('📤 Request Body: ${json.encode(body)}');

    try {
      final response = await http.post(
        Uri.parse(url),
        headers: {
          'Content-Type': 'application/json',
        },
        body: json.encode(body),
      );

      print('📥 Response Status Code: ${response.statusCode}');
      print('📥 Response Body: ${response.body}');

      if (response.statusCode == 200 || response.statusCode == 201) {
        final data = json.decode(response.body);
        return Ward.fromJson(data);
      } else {
        print('❌ Error: Failed to add ward');
        print('❌ Status Code: ${response.statusCode}');
        print('❌ Response Body: ${response.body}');
        throw Exception('Failed to add ward: ${response.body}');
      }
    } catch (e) {
      print('❌ Exception occurred while adding ward:');
      print('❌ Error Details: $e');
      throw Exception('Failed to add ward: $e');
    }
  }

  Future<Ward> updateWard(Ward ward) async {
    final url = '${ApiEndpoints.editWard}/${ward.wardId}';
    final body = {
      'name': ward.name,
      'wardType': ward.wardType,
      'totalBeds': ward.totalBeds,
      'availableBeds': ward.availableBeds,
      'pricePerDay': ward.pricePerDay,
      'genderRestriction': ward.genderRestriction,
      'isAC': ward.isAC,
      'hasAttachedBathroom': ward.hasAttachedBathroom,
      'isIsolation': ward.isIsolation,
      'description': ward.description,
      'vendorId': ward.vendorId,
      'facilities': ward.facilities,
    };

    print('📤 PUT Request to: $url');
    print('📤 Request Body: ${json.encode(body)}');

    try {
      final response = await http.put(
        Uri.parse(url),
        headers: {
          'Content-Type': 'application/json',
        },
        body: json.encode(body),
      );

      print('📥 Response Status Code: ${response.statusCode}');
      print('📥 Response Body: ${response.body}');

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        return Ward.fromJson(data);
      } else {
        print('❌ Error: Failed to update ward');
        print('❌ Status Code: ${response.statusCode}');
        print('❌ Response Body: ${response.body}');
        throw Exception('Failed to update ward: ${response.body}');
      }
    } catch (e) {
      print('❌ Exception occurred while updating ward:');
      print('❌ Error Details: $e');
      throw Exception('Failed to update ward: $e');
    }
  }

  Future<bool> deleteWard(String wardId) async {
    final url = '${ApiEndpoints.editWard}/$wardId';
    print('📤 DELETE Request to: $url');

    try {
      final response = await http.delete(Uri.parse(url));
      
      print('📥 Response Status Code: ${response.statusCode}');
      print('📥 Response Body: ${response.body}');

      if (response.statusCode == 200) {
        return true;
      } else {
        print('❌ Error: Failed to delete ward');
        print('❌ Status Code: ${response.statusCode}');
        print('❌ Response Body: ${response.body}');
        throw Exception('Failed to delete ward: ${response.body}');
      }
    } catch (e) {
      print('❌ Exception occurred while deleting ward:');
      print('❌ Error Details: $e');
      throw Exception('Failed to delete ward: $e');
    }
  }
} 