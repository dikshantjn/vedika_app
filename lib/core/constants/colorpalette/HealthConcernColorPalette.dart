import 'package:flutter/material.dart';

class HealthConcernColorPalette {
  // Primary Colors
  static const Color primaryGreen = Color(0xFFE8F5E9);
  static const Color primaryBlue = Color(0xFFE3F2FD);
  static const Color primaryYellow = Color(0xFFFFF8E1);
  static const Color primaryPink = Color(0xFFFCE4EC);
  static const Color primaryMint = Color(0xFFE0F2F1);

  // Gradient Colors
  static const List<Color> greenGradient = [
    Color(0xFFE8F5E9),
    Color(0xFFC8E6C9),
    Color(0xFFA5D6A7),
  ];

  static const List<Color> blueGradient = [
    Color(0xFFE3F2FD),
    Color(0xFFBBDEFB),
    Color(0xFF90CAF9),
  ];

  static const List<Color> yellowGradient = [
    Color(0xFFFFF8E1),
    Color(0xFFFFECB3),
    Color(0xFFFFE082),
  ];

  static const List<Color> pinkGradient = [
    Color(0xFFFCE4EC),
    Color(0xFFF8BBD0),
    Color(0xFFF48FB1),
  ];

  static const List<Color> mintGradient = [
    Color(0xFFE0F2F1),
    Color(0xFFB2DFDB),
    Color(0xFF80CBC4),
  ];

  // Text Colors
  static const Color textDark = Color(0xFF424242);
  static const Color textLight = Color(0xFF757575);

  // Border Colors
  static const Color borderColor = Color(0xFFE0E0E0);

  // Get gradient based on index
  static List<Color> getGradientForIndex(int index) {
    switch (index % 5) {
      case 0:
        return greenGradient;
      case 1:
        return blueGradient;
      case 2:
        return yellowGradient;
      case 3:
        return pinkGradient;
      case 4:
        return mintGradient;
      default:
        return greenGradient;
    }
  }
}
