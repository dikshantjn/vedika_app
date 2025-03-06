import 'dart:convert';
import 'package:dio/dio.dart';
import 'package:vedika_healthcare/core/auth/data/models/UserModel.dart'; // Import the UserModel

class UserService {
  static const String baseUrl = 'http://192.168.1.41:5000/api/user';
  final Dio _dio = Dio();

  // Function to fetch user data and return a UserModel
  Future<UserModel?> getUserDetails(String userId) async {
    final url = '$baseUrl/$userId';

    try {
      // Sending GET request with Dio
      final response = await _dio.get(url);

      // Check if the response is successful (status code 200)
      if (response.statusCode == 200) {
        // Parse the JSON response and return a UserModel
        return UserModel.fromJson(response.data);
      } else {
        print('Error fetching user details: ${response.statusCode}');
        return null;
      }
    } catch (error) {
      print('Error: $error');
      return null;
    }
  }
}
