import 'package:dio/dio.dart';
import 'package:vedika_healthcare/core/constants/ApiEndpoints.dart';
import 'package:vedika_healthcare/features/userProfile/data/models/MedicalProfile.dart';

class MedicalProfileService {
  final Dio _dio = Dio();

  // ✅ Create Medical Profile
  Future<MedicalProfile> createMedicalProfile(MedicalProfile medicalProfile) async {
    try {
      Response response = await _dio.post(
        ApiEndpoints.medicalProfile,
        data: medicalProfile.toJson(), // Convert object to JSON
      );
      return MedicalProfile.fromJson(response.data); // Convert JSON to object
    } catch (e) {
      throw Exception("Failed to create medical profile: $e");
    }
  }

  // ✅ Get Medical Profile by userId
  Future<MedicalProfile> getMedicalProfile(String userId) async {
    try {
      Response response = await _dio.get("${ApiEndpoints.medicalProfile}/$userId");
      return MedicalProfile.fromJson(response.data); // Convert JSON to object
    } catch (e) {
      throw Exception("Failed to fetch medical profile: $e");
    }
  }

  // ✅ Update Medical Profile
  Future<MedicalProfile> updateMedicalProfile(String userId, MedicalProfile updatedProfile) async {
    try {
      Response response = await _dio.put(
        "${ApiEndpoints.medicalProfile}/$userId",
        data: updatedProfile.toJson(), // Convert object to JSON
      );
      return MedicalProfile.fromJson(response.data); // Convert JSON to object
    } catch (e) {
      throw Exception("Failed to update medical profile: $e");
    }
  }

  // ✅ Delete Medical Profile
  Future<bool> deleteMedicalProfile(String userId) async {
    try {
      await _dio.delete("${ApiEndpoints.medicalProfile}/$userId");
      return true; // Return true on successful deletion
    } catch (e) {
      throw Exception("Failed to delete medical profile: $e");
    }
  }
}
