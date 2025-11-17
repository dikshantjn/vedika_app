import 'dart:convert';
import 'package:http/http.dart' as http;
import '../../../../core/constants/ApiEndpoints.dart';

class VideoSdkApiService {
  const VideoSdkApiService();

  Future<String> fetchAccessToken() async {
    final uri = Uri.parse(ApiEndpoints.getVideoSdkToken);
    final response = await http.get(uri);
    if (response.statusCode >= 200 && response.statusCode < 300) {
      final Map<String, dynamic> data = json.decode(response.body) as Map<String, dynamic>;
      final token = data['token'] as String?;
      if (token == null || token.isEmpty) {
        throw Exception('VideoSDK token not found in response');
      }
      return token;
    }
    throw Exception('Failed to fetch VideoSDK token: ${response.statusCode}');
  }
}


