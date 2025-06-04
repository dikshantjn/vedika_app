import 'dart:convert';
import 'dart:io';
import 'package:dio/dio.dart';
import 'package:vedika_healthcare/core/constants/ApiEndpoints.dart';
import 'package:vedika_healthcare/core/constants/apiConstants.dart';
import 'package:vedika_healthcare/features/Vendor/ProductPartner/data/models/VendorProduct.dart';

class ScannerService {
  final Dio _dio = Dio();

  Future<String> _extractTextFromImage(String imagePath) async {
    try {
      // Read the image file and convert to base64
      final File imageFile = File(imagePath);
      final List<int> imageBytes = await imageFile.readAsBytes();
      final String base64Image = base64Encode(imageBytes);

      // Prepare the request body for Google Vision API
      final Map<String, dynamic> requestBody = {
        'requests': [
          {
            'image': {
              'content': base64Image,
            },
            'features': [
              {
                'type': 'TEXT_DETECTION',
                'maxResults': 1,
              },
            ],
          },
        ],
      };

      // Make request to Google Vision API
      final response = await _dio.post(
        '${ApiConstants.googleVisionApiEndpoint}?key=${ApiConstants.googleVisionApiKey}',
        data: requestBody,
      );

      if (response.statusCode == 200) {
        final List<dynamic> textAnnotations = response.data['responses'][0]['textAnnotations'];
        if (textAnnotations.isNotEmpty) {
          // The first annotation contains the full text
          final String extractedText = textAnnotations[0]['description'] as String;
          // Join all lines with spaces and remove extra whitespace
          final String singleLineText = extractedText.split('\n').join(' ').replaceAll(RegExp(r'\s+'), ' ').trim();
          print(singleLineText);
          return singleLineText;
        }
        print('No text found in the image');
        return '';
      } else {
        print('Failed to extract text. Status code: ${response.statusCode}');
        throw Exception('Failed to extract text from image');
      }
    } catch (e) {
      print('Error extracting text: $e');
      throw Exception('Error extracting text from image: $e');
    }
  }

  Future<List<VendorProduct>> scanPrescription(String imagePath) async {
    try {
      // First, extract text from the image using Google Vision API
      final String extractedText = await _extractTextFromImage(imagePath);

      // Then, send the extracted text to your backend
      final response = await _dio.post(
        ApiEndpoints.scanPrescription,
        data: {
          'text': extractedText,
        },
      );

      if (response.statusCode == 200) {
        final List<dynamic> productsJson = response.data['products'];
        final products = productsJson.map((json) => VendorProduct.fromJson(json)).toList();
        print('Found ${products.length} products from scanned text');
        return products;
      } else {
        print('Failed to scan prescription. Status code: ${response.statusCode}');
        throw Exception('Failed to scan prescription');
      }
    } catch (e) {
      print('Error scanning prescription: $e');
      throw Exception('Error scanning prescription: $e');
    }
  }
} 