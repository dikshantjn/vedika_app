import 'package:flutter/material.dart';
import 'package:vedika_healthcare/features/ai/data/services/AIService.dart';
import 'package:vedika_healthcare/features/ai/data/models/AIChatResponse.dart';

class AIViewModel extends ChangeNotifier {
  final AIService _aiService = AIService();
  bool _isLoading = false;
  List<Map<String, dynamic>> _chatHistory = [];
  AIChatResponse? _lastResponse;

  bool get isLoading => _isLoading;
  List<Map<String, dynamic>> get chatHistory => _chatHistory;
  AIChatResponse? get lastResponse => _lastResponse;

  Future<void> interpretSymptoms(String text) async {
    try {
      _isLoading = true;
      notifyListeners();

      // Add user message to chat history
      _chatHistory.add({
        'type': 'user',
        'message': text,
        'timestamp': DateTime.now(),
      });

      final response = await _aiService.interpretSymptoms(text);
      _lastResponse = response;

      // Add AI response to chat history
      _chatHistory.add({
        'type': 'ai',
        'response': response,
        'timestamp': DateTime.now(),
      });

      _isLoading = false;
      notifyListeners();
    } catch (e) {
      _isLoading = false;
      notifyListeners();
      rethrow;
    }
  }

  void clearChat() {
    _chatHistory.clear();
    _lastResponse = null;
    notifyListeners();
  }
} 