import 'package:flutter/material.dart';

class PlanVisuals {
  static const Map<String, String> _emojiByType = {
    'Silver': '🥈',
    'Gold': '🥇',
    'Platinum': '💎',
  };

  static const Map<String, int> _primaryByType = {
    'Silver': 0xFF7D7D7D,
    'Gold': 0xFFDAA520,
    'Platinum': 0xFF777698,
  };

  static const Map<String, int> _secondaryByType = {
    'Silver': 0xFF5A5A5A,
    'Gold': 0xFFB8860B,
    'Platinum': 0xFF4B4B63,
  };

  static const Map<String, int> _gradientStartByType = {
    'Silver': 0xFFB0B0B0,
    'Gold': 0xFFFFE082,
    'Platinum': 0xFFA6A6C6,
  };

  static const Map<String, int> _gradientEndByType = {
    'Silver': 0xFF7D7D7D,
    'Gold': 0xFFDAA520,
    'Platinum': 0xFF777698,
  };

  static String emoji(String type) {
    return _emojiByType[type] ?? '⭐';
  }

  static Color primaryColor(String type) {
    return Color(_primaryByType[type] ?? 0xFF6B73FF);
  }

  static Color secondaryColor(String type) {
    return Color(_secondaryByType[type] ?? 0xFF9B59B6);
  }

  static Color gradientStart(String type) {
    return Color(_gradientStartByType[type] ?? 0xFF6B73FF);
  }

  static Color gradientEnd(String type) {
    return Color(_gradientEndByType[type] ?? 0xFF6B73FF);
  }
}


