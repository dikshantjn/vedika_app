import 'dart:io';
import 'package:dio/dio.dart';
import '../../../../../core/constants/ApiEndpoints.dart';
import '../models/product_partner_model.dart';

class ProductPartnerProfileService {
  // Singleton instance
  static final ProductPartnerProfileService _instance = ProductPartnerProfileService._internal();
  final Dio _dio = Dio();

  factory ProductPartnerProfileService() => _instance;
  ProductPartnerProfileService._internal();

  Future<ProductPartner> getProfile(String vendorId) async {
    try {
      print('Fetching profile for vendor: $vendorId');
      final response = await _dio.get('${ApiEndpoints.getProductPartnerProfile}/$vendorId');
      
      if (response.statusCode == 200) {
        print('Response data: ${response.data}');
        if (response.data == null) {
          throw Exception('No data received from server');
        }
        
        // Ensure all required fields are present with default values
        final Map<String, dynamic> data = Map<String, dynamic>.from(response.data);
        data['vendorId'] = data['vendorId'] ?? vendorId;
        data['brandName'] = data['brandName'] ?? '';
        data['companyLegalName'] = data['companyLegalName'] ?? '';
        data['gstNumber'] = data['gstNumber'] ?? '';
        data['panCardNumber'] = data['panCardNumber'] ?? '';
        data['bankAccountNumber'] = data['bankAccountNumber'] ?? '';
        data['address'] = data['address'] ?? '';
        data['pincode'] = data['pincode'] ?? '';
        data['city'] = data['city'] ?? '';
        data['state'] = data['state'] ?? '';
        data['email'] = data['email'] ?? '';
        data['phoneNumber'] = data['phoneNumber'] ?? '';
        data['profilePicture'] = data['profilePicture'] ?? '';
        data['password'] = data['password'] ?? '';
        data['location'] = data['location'] ?? '';
        data['licenseDetails'] = data['licenseDetails'] ?? [];

        return ProductPartner.fromJson(data);
      } else {
        print('Failed to load profile. Status code: ${response.statusCode}');
        print('Response data: ${response.data}');
        throw Exception('Failed to load profile: ${response.statusCode}');
      }
    } on DioException catch (e) {
      print('DioException in getProfile: ${e.message}');
      if (e.response != null) {
        print('Error response data: ${e.response?.data}');
        throw Exception(e.response?.data['message'] ?? 'Failed to load profile: ${e.message}');
      } else {
        throw Exception('Network error occurred: ${e.message}');
      }
    } catch (e) {
      print('Unexpected error in getProfile: $e');
      throw Exception('An unexpected error occurred: $e');
    }
  }

  Future<bool> updateProfile(ProductPartner profile) async {
    try {
      print('Updating profile for vendor: ${profile.vendorId}');
      final response = await _dio.put(
        '${ApiEndpoints.getProductPartnerProfile}/${profile.vendorId}',
        data: profile.toJson(),
      );
      
      if (response.statusCode == 200) {
        print('Profile updated successfully');
        return true;
      } else {
        print('Failed to update profile. Status code: ${response.statusCode}');
        print('Response data: ${response.data}');
        return false;
      }
    } on DioException catch (e) {
      print('DioException in updateProfile: ${e.message}');
      if (e.response != null) {
        print('Error response data: ${e.response?.data}');
      }
      return false;
    } catch (e) {
      print('Unexpected error in updateProfile: $e');
      return false;
    }
  }

  Future<Map<String, dynamic>> uploadDocument(File file, String vendorId) async {
    try {
      print('Uploading document for vendor: $vendorId');
      String fileName = file.path.split('/').last;
      FormData formData = FormData.fromMap({
        "file": await MultipartFile.fromFile(
          file.path,
          filename: fileName,
        ),
        "vendorId": vendorId,
      });

      final response = await _dio.post(
        '${ApiEndpoints.getProductPartnerProfile}/upload-document',
        data: formData,
      );

      if (response.statusCode == 200) {
        print('Document uploaded successfully');
        return response.data;
      } else {
        print('Failed to upload document. Status code: ${response.statusCode}');
        print('Response data: ${response.data}');
        throw Exception('Failed to upload document: ${response.statusCode}');
      }
    } on DioException catch (e) {
      print('DioException in uploadDocument: ${e.message}');
      if (e.response != null) {
        print('Error response data: ${e.response?.data}');
        throw Exception(e.response?.data['message'] ?? 'Failed to upload document: ${e.message}');
      } else {
        throw Exception('Network error occurred: ${e.message}');
      }
    } catch (e) {
      print('Unexpected error in uploadDocument: $e');
      throw Exception('An unexpected error occurred: $e');
    }
  }

  Future<Map<String, dynamic>> getOverview(String vendorId) async {
    try {
      print('Fetching overview for vendor: $vendorId');
      final response = await _dio.get('${ApiEndpoints.getProductPartnerOverview}/$vendorId/overview');
      
      if (response.statusCode == 200) {
        print('Overview data: ${response.data}');
        if (response.data == null) {
          throw Exception('No data received from server');
        }
        return response.data;
      } else {
        print('Failed to load overview. Status code: ${response.statusCode}');
        print('Response data: ${response.data}');
        throw Exception('Failed to load overview: ${response.statusCode}');
      }
    } on DioException catch (e) {
      print('DioException in getOverview: ${e.message}');
      if (e.response != null) {
        print('Error response data: ${e.response?.data}');
        throw Exception(e.response?.data['message'] ?? 'Failed to load overview: ${e.message}');
      } else {
        throw Exception('Network error occurred: ${e.message}');
      }
    } catch (e) {
      print('Unexpected error in getOverview: $e');
      throw Exception('An unexpected error occurred: $e');
    }
  }
} 