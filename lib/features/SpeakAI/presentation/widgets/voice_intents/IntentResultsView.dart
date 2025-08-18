import 'package:flutter/material.dart';
import 'IntentHeader.dart';
import 'IntentWidgetFactory.dart';

class IntentResultsView extends StatelessWidget {
  final String userText;
  final bool isListening;
  final VoidCallback onMicTap;
  final VoidCallback onClose;
  final String intent;
  final List<dynamic> results;
  final List<dynamic> suggestions;
  final String summary;
  final bool isMedicalAdvice;
  final Future<void> Function(dynamic resultItem, Map action) onActionPressed;

  const IntentResultsView({
    super.key,
    required this.userText,
    required this.isListening,
    required this.onMicTap,
    required this.onClose,
    required this.intent,
    required this.results,
    required this.suggestions,
    required this.summary,
    required this.isMedicalAdvice,
    required this.onActionPressed,
  });

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      physics: const BouncingScrollPhysics(),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          IntentHeader(
            userText: userText,
            isListening: isListening,
            onMicTap: onMicTap,
            onClose: onClose,
          ),
          const SizedBox(height: 8),
          IntentWidgetFactory.build(
            intent: intent,
            results: results,
            suggestions: suggestions,
            summary: summary,
            isMedicalAdvice: isMedicalAdvice,
            onActionPressed: onActionPressed,
          ),
        ],
      ),
    );
  }
}


