import 'package:flutter/material.dart';

class BannerColorPalette {
  // Primary Banner Colors
  static const Color primaryBlue = Color(0xFF2196F3);      // Material Blue
  static const Color primaryTeal = Color(0xFF00BCD4);      // Material Teal
  static const Color primaryPurple = Color(0xFF9C27B0);    // Material Purple
  static const Color primaryGreen = Color(0xFF4CAF50);     // Material Green
  static const Color primaryCoral = Color(0xFFFF5722);     // Material Deep Orange
  static const Color primaryIndigo = Color(0xFF3F51B5);    // Material Indigo

  // Unique Gradient Colors for each banner type
  static const List<Color> offerGradient = [
    Color(0xFF1976D2),    // Deep Blue
    Color(0xFF2196F3),    // Bright Blue
    Color(0xFF64B5F6),    // Light Blue
  ];

  static const List<Color> healthDaysGradient = [
    Color(0xFF2E7D32),    // Deep Green
    Color(0xFF43A047),    // Forest Green
    Color(0xFF81C784),    // Light Green
  ];

  static const List<Color> discountGradient = [
    Color(0xFFC62828),    // Deep Red
    Color(0xFFE53935),    // Bright Red
    Color(0xFFEF9A9A),    // Light Red
  ];

  static const List<Color> promotionGradient = [
    Color(0xFF6A1B9A),    // Deep Purple
    Color(0xFF8E24AA),    // Bright Purple
    Color(0xFFCE93D8),    // Light Purple
  ];

  static const List<Color> eventGradient = [
    Color(0xFFF57F17),    // Deep Amber
    Color(0xFFFFB300),    // Bright Amber
    Color(0xFFFFE082),    // Light Amber
  ];

  static const List<Color> newsGradient = [
    Color(0xFF00695C),    // Deep Teal
    Color(0xFF00897B),    // Bright Teal
    Color(0xFF80CBC4),    // Light Teal
  ];

  // Text Colors
  static const Color lightText = Colors.white;
  static const Color darkText = Color(0xFF212121);

  // Overlay Colors
  static const Color lightOverlay = Color(0x33FFFFFF);
  static const Color darkOverlay = Color(0x66000000);

  // Badge Colors
  static const Color badgeBackground = Color(0x33FFFFFF);
  static const Color badgeText = Colors.white;

  // Button Colors
  static const Color buttonBackground = Color(0x33FFFFFF);
  static const Color buttonText = Colors.white;

  // Get gradient based on banner type
  static List<Color> getGradientForType(String type) {
    switch (type.toLowerCase()) {
      case "offer":
        return offerGradient;
      case "health_days":
        return healthDaysGradient;
      case "discount":
        return discountGradient;
      case "promotion":
        return promotionGradient;
      case "event":
        return eventGradient;
      case "news":
        return newsGradient;
      default:
        return offerGradient;
    }
  }

  // Get text color based on background color
  static Color getTextColor(Color backgroundColor) {
    return backgroundColor.computeLuminance() > 0.5 ? darkText : lightText;
  }
} 