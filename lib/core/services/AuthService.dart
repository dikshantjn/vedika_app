import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:vedika_healthcare/core/models/UserModal.dart';


class AuthService {
  Future<String?> signUp(UserModel user) async {
    try {
      final response = await http.post(
        Uri.parse("https://api.example.com/signup"),
        headers: {"Content-Type": "application/json"},
        body: jsonEncode(user.toJson()),
      );

      if (response.statusCode == 201) {
        return "Signup Successful";
      } else {
        return jsonDecode(response.body)['message'] ?? "Signup Failed";
      }
    } catch (e) {
      return "Error: $e";
    }
  }
}
