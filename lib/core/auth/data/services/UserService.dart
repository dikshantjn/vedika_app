import 'package:dio/dio.dart';
import 'dart:convert';
import 'package:vedika_healthcare/core/auth/data/models/UserModel.dart';
import 'package:vedika_healthcare/core/constants/ApiEndpoints.dart';
import 'package:vedika_healthcare/core/auth/data/repositories/AuthRepository.dart';

class UserService {
  final Dio _dio = Dio();
  final AuthRepository _authRepository = AuthRepository();

  // Function to get user by ID
  Future<UserModel?> getUserById(String userId) async {
    try {
      final response = await _dio.get('${ApiEndpoints.getUserProfile}/$userId');

      if (response.statusCode == 200 && response.data != null) {
        return UserModel.fromJson(response.data);
      } else {
        print('Error fetching user: ${response.statusCode}');
        return null;
      }
    } catch (error) {
      print('Error getting user by ID: $error');
      return null;
    }
  }

  // Function to update user profile
  Future<bool> updateUserProfile(String userId, UserModel userModel) async {
    try {
      // Get the JWT token
      final token = await _authRepository.getToken();
      if (token == null) {
        print('No authentication token found');
        return false;
      }

      // Include userId in the request body
      final Map<String, dynamic> requestData = {
        ...userModel.toJson(),
        'userId': userId,
      };

      // Debug logs removed for cleaner output

      // Try the edit endpoint instead
      final response = await _dio.put(  // Changed to PUT method as it's more appropriate for edits
        '${ApiEndpoints.editUserProfile}/$userId',  // Append userId to URL as it might be expected in path
        data: requestData,
        options: Options(
          headers: {
            'Authorization': 'Bearer $token',
            'Content-Type': 'application/json',
          },
                  validateStatus: (status) {
          return status! < 500;  // Accept any status code below 500 to see the actual response
        },
        ),
      );


      if (response.statusCode == 200) {
        return true;
      } else {
        return false;
      }
    } catch (error) {
      throw error; // Propagate error to handle it in the UI
    }
  }

  // Function to fetch user data using centralized API
  Future<UserModel?> getUserDetails(String userId) async {
    final url = '${ApiEndpoints.getUserProfile}/$userId'; // Use centralized API

    try {
      final response = await _dio.get(url);

      if (response.statusCode == 200) {
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

  // Function to update user coordinates
  Future<bool> updateUserCoordinates(String userId, String coordinates) async {
    try {
      final response = await _dio.put(
        '${ApiEndpoints.updateUserCoordinates}/$userId',
        data: {
          'locationCoordinates': coordinates
        },
      );

      if (response.statusCode == 200) {
        return true;
      } else {
        return false;
      }
    } catch (error) {
      return false;
    }
  }
}
