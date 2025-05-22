import 'dart:convert';
import 'package:dio/dio.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:vedika_healthcare/core/constants/ApiEndpoints.dart';
import 'package:jwt_decoder/jwt_decoder.dart'; // Package for decoding JWT

class VendorLoginService {
  final Dio _dio = Dio();
  final FlutterSecureStorage _storage = const FlutterSecureStorage(); // Secure Storage

  static const String _tokenKey = "vendor_jwt_token"; // Key for storing token
  static const String _vendorIdKey = "vendor_id"; // Key for storing vendorId
  static const String _vendorRoleKey = "vendor_role"; // Key for storing vendor role

  /// **🔹 Vendor Login & Session Management**
  Future<Map<String, dynamic>> loginVendor(String email, String password, int roleNumber) async {
    try {
      Map<String, dynamic> body = {
        'email': email,
        'password': password,
        'role': roleNumber,
      };

      Response response = await _dio.post(ApiEndpoints.loginVendor, data: body);

      if (response.statusCode == 200) {
        final data = response.data;
        final String token = data['token'];

        // **🔹 Extract Vendor ID & Role from JWT Token**
        String vendorId = _extractVendorIdFromToken(token);
        int vendorRole = _extractVendorRoleFromToken(token);  // Use integer for role
        print("_extractVendorRoleFromToken $vendorRole");
        // **🔹 Store Token, Vendor ID & Vendor Role Securely**
        await _storage.write(key: _tokenKey, value: token);
        await _storage.write(key: _vendorIdKey, value: vendorId);
        await _storage.write(key: _vendorRoleKey, value: vendorRole.toString());  // Store as String but treat as int

        return {
          'success': true,
          'message': data['message'],
          'token': token,
          'vendorId': vendorId,
          'vendorRole': vendorRole,
        };
      } else if (response.statusCode == 403) {
        // Handle vendor status not approved
        String message = response.data['message'] ?? 'Account not approved';
        String status = message.toLowerCase().contains('pending') ? 'pending' : 'not approved';
        
        return {
          'success': false,
          'message': message,
          'status': status,
        };
      } else {
        return {
          'success': false,
          'message': response.data['message'] ?? 'Login failed',
        };
      }
    } on DioException catch (e) {
      return _handleDioError(e);
    } catch (e) {
      return {'success': false, 'message': 'Unexpected error: ${e.toString()}'};
    }
  }

  /// **🔹 Extract Vendor ID from JWT Token**
  String _extractVendorIdFromToken(String token) {
    try {
      Map<String, dynamic> decodedToken = JwtDecoder.decode(token); // Decode JWT
      return decodedToken['vendorId'].toString(); // Extract vendorId
    } catch (e) {
      print("Error decoding token: $e");
      return "";
    }
  }

  /// **🔹 Extract Vendor Role from JWT Token**
  int _extractVendorRoleFromToken(String token) {
    try {
      Map<String, dynamic> decodedToken = JwtDecoder.decode(token); // Decode JWT
      return int.tryParse(decodedToken['vendorRole'].toString()) ?? 0; // Extract vendor role as int
    } catch (e) {
      print("Error decoding token: $e");
      return 0; // Default to 0 if parsing fails
    }
  }

  /// **🔹 Logout Vendor & Clear Storage**
  Future<void> logoutVendor() async {
    await _storage.delete(key: _tokenKey); // Remove JWT token
    await _storage.delete(key: _vendorIdKey); // Remove Vendor ID
    await _storage.delete(key: _vendorRoleKey); // Remove Vendor Role
  }

  /// **🔹 Check if Vendor is Logged In**
  Future<bool> isVendorLoggedIn() async {
    String? token = await _storage.read(key: _tokenKey);
    return token != null && !JwtDecoder.isExpired(token);
  }

  /// **🔹 Get JWT Token**
  Future<String?> getVendorToken() async {
    return await _storage.read(key: _tokenKey);
  }

  /// **🔹 Get Vendor ID**
  Future<String?> getVendorId() async {
    return await _storage.read(key: _vendorIdKey);
  }

  /// **🔹 Get Vendor Role**
  Future<int?> getVendorRole() async {
    String? role = await _storage.read(key: _vendorRoleKey);
    return role != null ? int.tryParse(role) : null;  // Convert string to int
  }

  /// **🔹 Handle Dio Errors**
  Map<String, dynamic> _handleDioError(DioException e) {
    if (e.response != null) {
      return {'success': false, 'message': e.response?.data['message'] ?? 'Server error'};
    } else {
      return {'success': false, 'message': 'Network error: ${e.message}'};
    }
  }
}

