import 'package:flutter/material.dart';
import 'package:vedika_healthcare/features/ai/data/services/AIService.dart';
import 'package:vedika_healthcare/features/ai/data/models/AIChatResponse.dart';
import 'package:vedika_healthcare/features/medicineDelivery/presentation/view/medicineOrderScreen.dart';

class AIViewModel extends ChangeNotifier {
  final AIService _aiService = AIService();
  bool _isLoading = false;
  List<Map<String, dynamic>> _chatHistory = [];
  AIChatResponse? _lastResponse;
  String? _error;
  String? _lastQuery;
  String? _lastFilePath;
  bool _lastIsPdf = false;
  Map<String, dynamic>? _prescriptionAnalysis;
  String? _lastDisplayMessage;  // Store the original display message

  bool get isLoading => _isLoading;
  List<Map<String, dynamic>> get chatHistory => _chatHistory;
  AIChatResponse? get lastResponse => _lastResponse;
  String? get error => _error;
  String? get lastQuery => _lastQuery;
  String? get lastFilePath => _lastFilePath;
  bool get lastIsPdf => _lastIsPdf;
  Map<String, dynamic>? get prescriptionAnalysis => _prescriptionAnalysis;

  Future<void> interpretSymptoms(String text, {String? displayMessage, String? filePath, bool isPdf = false}) async {
    try {
      _error = null;
      _isLoading = true;
      _lastQuery = text;
      _lastFilePath = filePath;
      _lastIsPdf = isPdf;
      _lastDisplayMessage = displayMessage;
      
      // Add user message to chat history immediately
      _chatHistory.add({
        'type': 'user',
        'displayMessage': displayMessage ?? text,
        'filePath': filePath,
        'isPdf': isPdf,
        'timestamp': DateTime.now(),
      });
      notifyListeners(); // Notify to show user message immediately

      // If there's a file, only analyze the prescription
      if (filePath != null) {
        try {
          _prescriptionAnalysis = await _aiService.analyzePrescription(text);
          // Add prescription analysis to chat history
          _chatHistory.add({
            'type': 'ai',
            'response': AIChatResponse(
              intent: AIIntent.generalHelp,
              searchTerms: [],
              extractedSymptoms: [],
              addressSearch: [],
              reply: _prescriptionAnalysis!['analysis'],
            ),
            'timestamp': DateTime.now(),
            'isPrescriptionAnalysis': true,
          });

          // Add order medicines button message
          _chatHistory.add({
            'type': 'ai',
            'response': AIChatResponse(
              intent: AIIntent.generalHelp,
              searchTerms: [],
              extractedSymptoms: [],
              addressSearch: [],
              reply: "Would you like to order these medicines?",
            ),
            'timestamp': DateTime.now(),
            'showOrderButton': true,
            'navigationScreen': MedicineOrderScreen(),
          });

          _isLoading = false;
          notifyListeners();
          return;
        } catch (e) {
          print('Error analyzing prescription: $e');
          // Add error message to chat history
          _chatHistory.add({
            'type': 'error',
            'error': 'Connection Error',
            'message': 'Unable to analyze prescription. Please check your connection and try again.',
            'timestamp': DateTime.now(),
            'isPrescriptionError': true,
          });
          _error = 'Connection Error';
          _isLoading = false;
          notifyListeners();
          return;
        }
      }

      // If no file, proceed with normal symptom interpretation
      try {
        final response = await _aiService.interpretSymptoms(text);
        _lastResponse = response;
        _chatHistory.add({
          'type': 'ai',
          'response': response,
          'timestamp': DateTime.now(),
        });
      } catch (e) {
        _error = e.toString();
        _chatHistory.add({
          'type': 'error',
          'error': 'Error',
          'message': 'Unable to process your request. Please try again.',
          'timestamp': DateTime.now(),
        });
      }

      _isLoading = false;
      notifyListeners();
    } catch (e) {
      _isLoading = false;
      _error = e.toString();
      notifyListeners();
      rethrow;
    }
  }

  Future<void> retryLastQuery() async {
    if (_lastQuery != null) {
      // Remove the last error message if it exists
      if (_chatHistory.isNotEmpty && _chatHistory.last['type'] == 'error') {
        _chatHistory.removeLast();
      }
      // Remove the last AI response if it exists
      if (_chatHistory.isNotEmpty && _chatHistory.last['type'] == 'ai') {
        _chatHistory.removeLast();
      }
      notifyListeners();
      
      // Retry with the original query and display message
      await interpretSymptoms(
        _lastQuery!,
        displayMessage: _lastDisplayMessage,  // Use the stored display message
        filePath: _lastFilePath,
        isPdf: _lastIsPdf,
      );
    }
  }

  void clearChat() {
    _chatHistory.clear();
    _lastResponse = null;
    _error = null;
    _lastQuery = null;
    _lastFilePath = null;
    _lastIsPdf = false;
    _prescriptionAnalysis = null;
    _lastDisplayMessage = null;  // Clear the stored display message
    notifyListeners();
  }

  void stopLoading() {
    _isLoading = false;
    notifyListeners();
  }

  void editMessage(int index, String newMessage) {
    if (index >= 0 && index < _chatHistory.length) {
      final message = _chatHistory[index];
      if (message['type'] == 'user') {
        // Update the message
        _chatHistory[index] = {
          ...message,
          'displayMessage': newMessage,
        };
        
        // Remove all messages after the edited message
        _chatHistory.removeRange(index + 1, _chatHistory.length);
        
        // Make a new API call with the edited message
        interpretSymptoms(
          newMessage,
          displayMessage: newMessage,
          filePath: message['filePath'],
          isPdf: message['isPdf'] ?? false,
        );
        
        notifyListeners();
      }
    }
  }
} 