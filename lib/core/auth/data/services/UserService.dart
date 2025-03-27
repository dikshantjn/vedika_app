import 'package:dio/dio.dart';
import 'package:vedika_healthcare/core/auth/data/models/UserModel.dart';
import 'package:vedika_healthcare/core/constants/ApiEndpoints.dart';

class UserService {
  final Dio _dio = Dio();

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
}
