import 'dart:convert';
import 'package:dio/dio.dart';
import 'package:vedika_healthcare/core/constants/ApiEndpoints.dart';
import 'package:vedika_healthcare/features/userProfile/data/models/PersonalProfile.dart';

class UserProfileService {
  final Dio _dio = Dio(
    BaseOptions(
      connectTimeout: Duration(seconds: 10),
      receiveTimeout: Duration(seconds: 10),
      headers: {
        "Content-Type": "application/json",
      },
    ),
  );

  // Get User Profile by userId
  Future<PersonalProfile?> getUserProfile(String userId) async {
    try {
      print("Fetching user profile for userId: $userId");
      final String url = "${ApiEndpoints.getUserProfile}/$userId";
      print("GET Request URL: $url");

      final response = await _dio.get(url);

      print("Response Status Code: ${response.statusCode}");
      print("Response Data: ${response.data}");

      if (response.statusCode == 200 && response.data != null) {
        return PersonalProfile.fromJson(response.data);
      }
    } catch (e) {
      print("Error fetching user profile: $e");
    }
    return null;
  }

  // Save User Profile (Create or Update)
  Future<bool> saveUserProfile(PersonalProfile profile) async {
    try {
      print("Saving user profile...");
      final String url = ApiEndpoints.saveUserProfile;
      print("POST Request URL: $url");
      print("Request Body: ${json.encode(profile.toJson())}");

      final response = await _dio.post(
        url,
        data: json.encode(profile.toJson()),
      );

      print("Response Status Code: ${response.statusCode}");
      print("Response Data: ${response.data}");

      return response.statusCode == 200;
    } catch (e) {
      print("Error saving user profile: $e");
      return false;
    }
  }

  // Edit User Profile
  Future<bool> editUserProfile(String userId, PersonalProfile profile) async {
    try {
      print("Editing user profile for userId: $userId");
      final String url = "${ApiEndpoints.editUserProfile}/$userId";
      print("PUT Request URL: $url");
      print("Request Body: ${json.encode(profile.toJson())}");

      final response = await _dio.put(
        url,
        data: json.encode(profile.toJson()),
      );

      print("Response Status Code: ${response.statusCode}");
      print("Response Data: ${response.data}");

      return response.statusCode == 200;
    } catch (e) {
      print("Error editing user profile: $e");
      return false;
    }
  }
}
