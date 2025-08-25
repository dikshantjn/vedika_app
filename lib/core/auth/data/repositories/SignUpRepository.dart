import 'package:dio/dio.dart';
import 'package:vedika_healthcare/core/auth/data/models/UserModel.dart';
import 'package:vedika_healthcare/core/auth/data/repositories/AuthRepository.dart';
import 'package:vedika_healthcare/core/constants/ApiEndpoints.dart';

class SignUpRepository {
  final AuthRepository _authRepository;
  final Dio _dio = Dio();

  SignUpRepository(this._authRepository);

  /// Register User if not exists
  Future<UserModel?> registerUser(String phoneNumber, String idToken) async {
    try {
      final response = await _dio.post(
        ApiEndpoints.signUp,
        options: Options(
          headers: {
            "Content-Type": "application/json",
            "Authorization": "Bearer $idToken",
          },
        ),
        data: {
          "phone_number": phoneNumber,
        },
      );


      if (response.statusCode == 200 || response.statusCode == 201) {
        final responseData = response.data;
        final user = UserModel.fromJson(responseData['user']);
        await _authRepository.saveToken(idToken);
        print("✅ User Registered: ${user.userId}");
        return user;
      } else {
        print("⚠️ API Error: ${response.statusCode} - ${response.data}");
        return null;
      }
    } catch (e) {
      print("❌ Signup Error: $e");
      return null;
    }
  }

  /// Only Update Platform
  Future<bool> updatePlatform(String phoneNumber, String platform) async {
    try {
      final response = await _dio.post(
        ApiEndpoints.updatePlatform,
        data: {
          "phone_number": phoneNumber,
          "platform": platform,
        },
        options: Options(
          headers: {
            "Content-Type": "application/json",
          },
        ),
      );

      if (response.statusCode == 200) {
        print("✅ Platform updated successfully.");
        return true;
      } else {
        print("⚠️ Failed to update platform: ${response.statusCode} - ${response.data}");
        return false;
      }
    } catch (e) {
      print("❌ Platform update error: $e");
      return false;
    }
  }
}
