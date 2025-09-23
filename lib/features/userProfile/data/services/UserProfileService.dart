import 'dart:convert';
import 'dart:io';
import 'package:dio/dio.dart';
import 'package:firebase_storage/firebase_storage.dart';
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
  final FirebaseStorage _storage = FirebaseStorage.instance;

  // Upload profile picture to Firebase Storage
  Future<String?> uploadProfilePicture(File imageFile, String userId) async {
    try {
      final String fileName = 'profile_${DateTime.now().millisecondsSinceEpoch}.jpg';
      final String storagePath = 'user_profiles/$userId/$fileName';
      
      final Reference ref = _storage.ref().child(storagePath);
      final UploadTask uploadTask = ref.putFile(imageFile);
      
      final TaskSnapshot snapshot = await uploadTask;
      final String downloadUrl = await snapshot.ref.getDownloadURL();
      
      return downloadUrl;
    } catch (e) {
      print("Error uploading profile picture: $e");
      return null;
    }
  }

  // Get User Profile by userId
  Future<PersonalProfile?> getUserProfile(String userId) async {
    try {
      final String url = "${ApiEndpoints.getUserProfile}/$userId";

      final response = await _dio.get(url);


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
      // Debug print removed
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
