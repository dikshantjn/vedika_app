import 'package:dio/dio.dart';
import 'package:vedika_healthcare/core/constants/ApiEndpoints.dart';
import 'package:vedika_healthcare/features/userProfile/data/models/MedicalProfile.dart';

class MedicalProfileService {
  final Dio _dio = Dio();

  // Constructor to add custom validateStatus
  MedicalProfileService() {
    _dio.options = BaseOptions(
      validateStatus: (status) {
        // Allow 404 status code to be handled without throwing an error
        return status! < 500; // It will only throw an error for status codes >= 500
      },
    );
  }

  Future<MedicalProfile> createMedicalProfile(MedicalProfile medicalProfile, String userId) async {
    try {
      print("Creating medical profile with data: ${medicalProfile.toJson()}");

      // Updated API endpoint with userId in the URL
      String url = 'http://192.168.1.41:5000/api/medical-profile/';

      Response response = await _dio.post(
        url,  // Now the URL includes userId as a parameter
        data: medicalProfile.toJson(), // Body data remains the same
      );

      print("Response Status Code for Create: ${response.statusCode}");
      print("Response Data for Create: ${response.data}");

      if (response.statusCode == 201) {
        print("Successfully created medical profile.");
        return MedicalProfile.fromJson(response.data); // Convert JSON to object
      } else {
        print("Failed to create medical profile. Status Code: ${response.statusCode}");
        throw Exception("Failed to create medical profile. Status Code: ${response.statusCode}");
      }
    } catch (e) {
      print("Error creating medical profile: $e");
      throw Exception("Failed to create medical profile: $e");
    }
  }


  // ✅ Get Medical Profile
  Future<MedicalProfile> getMedicalProfile(String userId) async {
    try {
      print("Fetching medical profile for userId: $userId");
      Response response = await _dio.get("${ApiEndpoints.medicalProfile}/$userId");

      // Debugging: print the status code and response data for inspection
      print("Response Status Code for Get: ${response.statusCode}");
      print("Response Data for Get: ${response.data}");

      // Check if the response is 404 or data is null
      if (response.statusCode == 404 || response.data == null) {
        print("Medical profile not found, returning default 'NA' values.");

        // Return default "NA" values if no profile is found
        return MedicalProfile(
          medicalProfileId: "sdfv",
          userId: userId,
          isDiabetic: false,
          allergies: ['NA'],
          eyePower: 0,
          currentMedication: ['NA'],
          pastMedication: ['NA'],
          chronicConditions: ['NA'],
          injuries: ['NA'],
          surgeries: ['NA'],
        );
      }

      // If profile is found, parse it into a MedicalProfile object
      print("Medical profile found, parsing data.");
      return MedicalProfile.fromJson(response.data);

    } catch (e) {
      // Debugging: print the error to understand what's failing
      print("Error fetching medical profile: $e");
      throw Exception("Failed to fetch medical profile: $e");
    }
  }

  // ✅ Update Medical Profile
  Future<MedicalProfile> updateMedicalProfile(String userId, MedicalProfile updatedProfile) async {
    try {
      print("Updating medical profile for userId: $userId with data: ${updatedProfile.toJson()}");

      // First, attempt to get the medical profile
      Response getResponse = await _dio.get("${ApiEndpoints.medicalProfile}/$userId");
      print("Response Status Code for Get: ${getResponse.statusCode}");
      print("Response Data for Get: ${getResponse.data}");

      if (getResponse.statusCode == 404) {
        // If the profile is not found (404), create a new profile
        print("Profile not found, creating new medical profile.");
        return createMedicalProfile(updatedProfile,userId);
      }

      // If profile exists, update it
      Response response = await _dio.put(
        "${ApiEndpoints.medicalProfile}/$userId",
        data: updatedProfile.toJson(), // Convert object to JSON
      );
      print("Response Status Code for Update: ${response.statusCode}");
      print("Response Data for Update: ${response.data}");

      if (response.statusCode == 200) {
        print("Successfully updated medical profile.");
        return MedicalProfile.fromJson(response.data); // Convert JSON to object
      } else {
        print("Failed to update medical profile. Status Code: ${response.statusCode}");
        throw Exception("Failed to update medical profile. Status Code: ${response.statusCode}");
      }
    } catch (e) {
      print("Error updating medical profile: $e");
      throw Exception("Failed to update medical profile: $e");
    }
  }

  // ✅ Delete Medical Profile
  Future<bool> deleteMedicalProfile(String userId) async {
    try {
      print("Deleting medical profile for userId: $userId");
      Response response = await _dio.delete("${ApiEndpoints.medicalProfile}/$userId");

      print("Response Status Code for Delete: ${response.statusCode}");
      print("Response Data for Delete: ${response.data}");

      if (response.statusCode == 200) {
        print("Successfully deleted medical profile.");
        return true; // Return true on successful deletion
      } else {
        print("Failed to delete medical profile. Status Code: ${response.statusCode}");
        throw Exception("Failed to delete medical profile. Status Code: ${response.statusCode}");
      }
    } catch (e) {
      print("Error deleting medical profile: $e");
      throw Exception("Failed to delete medical profile: $e");
    }
  }
}
