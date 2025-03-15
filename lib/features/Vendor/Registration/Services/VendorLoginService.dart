import 'package:dio/dio.dart';
import 'package:vedika_healthcare/core/constants/ApiEndpoints.dart';

class VendorLoginService {
  final Dio _dio = Dio();  // Create an instance of Dio

  // Function to perform the vendor login
  Future<Map<String, dynamic>> loginVendor(String email, String password, int roleNumber) async {
    try {
      // Prepare request body with role and role number
      Map<String, dynamic> body = {
        'email': email,
        'password': password,
        'role': roleNumber,         // Add the role to the request body
      };

      // Send POST request to the login API
      Response response = await _dio.post(ApiEndpoints.loginVendor, data: body);

      // Debugging: Print the response to understand the structure
      print("Response: ${response.data}");

      // Check if the response status is 200
      if (response.statusCode == 200) {
        // Successful login
        return {
          'message': response.data['message'],
          'token': response.data['token'],
          'vendor': response.data['vendor'],
        };
      } else {
        // If API response is not 200, return the message
        return {
          'message': response.data['message'] ?? 'Error logging in vendor',
        };
      }
    } on DioError catch (e) {
      // If an error occurs during the request, handle it here
      if (e.response != null) {
        // Handle server-side errors
        print('DioError: ${e.response?.data}');
        return {
          'message': e.response?.data['message'] ?? 'Error logging in: ${e.message}',
        };
      } else {
        // Handle network issues or other request-related errors
        return {
          'message': 'Network or connection error: ${e.message}',
        };
      }
    } catch (e) {
      // Catch any other unknown errors
      print('Unknown Error: ${e.toString()}');
      return {
        'message': 'An unexpected error occurred: ${e.toString()}',
      };
    }
  }
}
