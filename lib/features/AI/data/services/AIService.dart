import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:vedika_healthcare/core/constants/ApiEndpoints.dart';
import 'package:vedika_healthcare/features/ai/data/models/AIChatResponse.dart';

class AIService {
  Future<AIChatResponse> interpretSymptoms(String spokenText) async {
    try {
      print('📡 Calling API: ${ApiEndpoints.interpretSymptoms}');
      print('📦 Request body: {"spokenText": "$spokenText"}');
      
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
        print('✅ API Response Status: ${response.statusCode}');
        final data = jsonDecode(response.body);
        return AIChatResponse.fromJson(data);
      } else {
        print('❌ API Error: ${response.statusCode}');
        throw Exception('Failed to interpret symptoms');
      }
    } catch (e) {
      print('❌ API Exception: $e');
      throw Exception('Error interpreting symptoms: $e');
    }
  }

  Future<Map<String, dynamic>> analyzePrescription(String prescriptionText) async {
    try {
      print('📡 Calling API: ${ApiEndpoints.analyzePrescription}');
      print('📦 Request body: {"prescriptionText": "$prescriptionText"}');
      
      final response = await http.post(
        Uri.parse(ApiEndpoints.analyzePrescription),
        headers: {
          'Content-Type': 'application/json',
        },
        body: jsonEncode({
          'prescriptionText': prescriptionText,
        }),
      );

      if (response.statusCode == 200) {
        print('✅ API Response Status: ${response.statusCode}');
        return jsonDecode(response.body);
      } else {
        print('❌ API Error: ${response.statusCode}');
        throw Exception('Failed to analyze prescription');
      }
    } catch (e) {
      print('❌ API Exception: $e');
      throw Exception('Error analyzing prescription: $e');
    }
  }
} 