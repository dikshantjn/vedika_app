import 'dart:convert';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:http/http.dart' as http;

class VendorAuthService {
  static const String _baseUrl = "https://yourapi.com"; // Replace with your API URL
  static const _storage = FlutterSecureStorage();
  static const String _keyToken = "vendor_jwt_token";

  /// **🔹 Login Vendor**
  static Future<Map<String, dynamic>> login(String email, String password) async {
    try {
      final response = await http.post(
        Uri.parse("$_baseUrl/vendor/login"),
        headers: {"Content-Type": "application/json"},
        body: jsonEncode({"email": email, "password": password}),
      );

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        await _storage.write(key: _keyToken, value: data['token']); // Store JWT
        return {"success": true, "message": "Login Successful", "token": data['token']};
      } else {
        return {"success": false, "message": "Invalid credentials"};
      }
    } catch (e) {
      return {"success": false, "message": "Error: $e"};
    }
  }

  /// **🔹 Get JWT Token**
  static Future<String?> getToken() async {
    return await _storage.read(key: _keyToken);
  }

  /// **🔹 Check if Vendor is Logged In**
  static Future<bool> isLoggedIn() async {
    String? token = await getToken();
    return token != null;
  }
}
