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

        // **🔹 Extract Vendor ID from JWT Token**
        String vendorId = _extractVendorIdFromToken(token);

        // **🔹 Store Token & Vendor ID Securely**
        await _storage.write(key: _tokenKey, value: token);
        await _storage.write(key: _vendorIdKey, value: vendorId);

        return {
          'success': true,
          'message': data['message'],
          'token': token,
          'vendorId': vendorId,
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

  /// **🔹 Logout Vendor & Clear Storage**
  Future<void> logoutVendor() async {
    await _storage.delete(key: _tokenKey); // Remove JWT token
    await _storage.delete(key: _vendorIdKey); // Remove Vendor ID
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

  /// **🔹 Handle Dio Errors**
  Map<String, dynamic> _handleDioError(DioException e) {
    if (e.response != null) {
      return {'success': false, 'message': e.response?.data['message'] ?? 'Server error'};
    } else {
      return {'success': false, 'message': 'Network error: ${e.message}'};
    }
  }
}
