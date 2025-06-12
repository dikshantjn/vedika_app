import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:vedika_healthcare/core/constants/ApiEndpoints.dart';
import 'package:vedika_healthcare/features/ai/data/models/AIChatResponse.dart';

class AIService {
  Future<AIChatResponse> interpretSymptoms(String spokenText) async {
    try {
      final response = await http.post(
        Uri.parse(ApiEndpoints.interpretSymptoms),
        headers: {
          'Content-Type': 'application/json',
        },
        body: jsonEncode({
          'spokenText': spokenText,
        }),
      );

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        return AIChatResponse.fromJson(data);
      } else {
        throw Exception('Failed to interpret symptoms');
      }
    } catch (e) {
      throw Exception('Error interpreting symptoms: $e');
    }
  }
} 