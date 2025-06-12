import 'dart:convert';
import 'dart:io';
import 'package:dio/dio.dart';
import 'package:vedika_healthcare/core/constants/apiConstants.dart';

class GoogleVisionService {
  final Dio _dio = Dio();
  final String _apiKey = ApiConstants.googleVisionApiKey;
  final String _apiEndpoint = ApiConstants.googleVisionApiEndpoint;

  Future<String?> extractTextFromImage(File imageFile) async {
    try {
      // Read the image file and convert to base64
      List<int> imageBytes = await imageFile.readAsBytes();
      String base64Image = base64Encode(imageBytes);

      // Prepare the request body
      Map<String, dynamic> requestBody = {
        "requests": [
          {
            "image": {
              "content": base64Image
            },
            "features": [
              {
                "type": "TEXT_DETECTION",
                "maxResults": 1
              }
            ]
          }
        ]
      };

      // Make the API request
      Response response = await _dio.post(
        '$_apiEndpoint?key=$_apiKey',
        data: requestBody,
        options: Options(
          headers: {'Content-Type': 'application/json'},
        ),
      );

      if (response.statusCode == 200) {
        // Extract text from response
        var responses = response.data['responses'] as List;
        if (responses.isNotEmpty) {
          var textAnnotations = responses[0]['textAnnotations'] as List;
          if (textAnnotations.isNotEmpty) {
            // The first annotation contains the full text
            return textAnnotations[0]['description'] as String;
          }
        }
      }
      return null;
    } catch (e) {
      print('Error extracting text from image: $e');
      return null;
    }
  }
} 