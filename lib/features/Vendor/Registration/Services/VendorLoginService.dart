import 'package:dio/dio.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:vedika_healthcare/core/constants/ApiEndpoints.dart';

class VendorLoginService {
  final Dio _dio = Dio();
  final FlutterSecureStorage _storage = const FlutterSecureStorage(); // Secure Storage

  static const String _tokenKey = "vendor_jwt_token"; // Key for storing token

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

        // **🔹 Store Token Securely**
        await _storage.write(key: _tokenKey, value: token);

        return {
          'success': true,
          'message': data['message'],
          'token': token,
          'vendor': data['vendor'],
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

  /// **🔹 Logout Vendor & Clear Token**
  Future<void> logoutVendor() async {
    await _storage.delete(key: _tokenKey); // Remove JWT token
  }

  /// **🔹 Check if Vendor is Logged In**
  Future<bool> isVendorLoggedIn() async {
    String? token = await _storage.read(key: _tokenKey);
    return token != null;
  }

  /// **🔹 Get JWT Token**
  Future<String?> getVendorToken() async {
    return await _storage.read(key: _tokenKey);
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
