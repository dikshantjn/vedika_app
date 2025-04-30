import 'package:flutter/material.dart';

class CategoryColorPalette {
  static Map<String, List<Color>> categoryGradients = {
    'dental care': [
      const Color(0xFFE3F2FD), // Light blue
      const Color(0xFFBBDEFB),
    ],
    'heart care': [
      const Color(0xFFFCE4EC), // Light pink
      const Color(0xFFF8BBD0),
    ],
    'baby care': [
      const Color(0xFFE8F5E9), // Light green
      const Color(0xFFC8E6C9),
    ],
    'medicine': [
      const Color(0xFFE0F7FA), // Light cyan
      const Color(0xFFB2EBF2),
    ],
    'lab test': [
      const Color(0xFFF3E5F5), // Light purple
      const Color(0xFFE1BEE7),
    ],
    'blood bank': [
      const Color(0xFFFBE9E7), // Light orange
      const Color(0xFFFFCCBC),
    ],
    'clinic': [
      const Color(0xFFE8EAF6), // Light indigo
      const Color(0xFFC5CAE9),
    ],
    'hospital': [
      const Color(0xFFE0F2F1), // Light teal
      const Color(0xFFB2DFDB),
    ],
    'ambulance': [
      const Color(0xFFFCE4EC), // Light red
      const Color(0xFFF8BBD0),
    ],
  };

  static Color getCategoryTextColor(String category) {
    switch (category.toLowerCase()) {
      case 'dental care':
        return const Color(0xFF1976D2); // Blue
      case 'heart care':
        return const Color(0xFFC2185B); // Pink
      case 'baby care':
        return const Color(0xFF2E7D32); // Green
      case 'medicine':
        return const Color(0xFF00838F); // Cyan
      case 'lab test':
        return const Color(0xFF7B1FA2); // Purple
      case 'blood bank':
        return const Color(0xFFD84315); // Orange
      case 'clinic':
        return const Color(0xFF3949AB); // Indigo
      case 'hospital':
        return const Color(0xFF00796B); // Teal
      case 'ambulance':
        return const Color(0xFFC62828); // Red
      default:
        return const Color(0xFF1976D2); // Default blue
    }
  }

  static Color getCategoryIconColor(String category) {
    return getCategoryTextColor(category);
  }

  static Color getCategoryIconBackgroundColor(String category) {
    return getCategoryTextColor(category).withOpacity(0.1);
  }
} 