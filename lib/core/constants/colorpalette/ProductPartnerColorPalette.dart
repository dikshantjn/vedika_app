import 'package:flutter/material.dart';

class ProductPartnerColorPalette {
  // Primary Colors - Unified App Teal Theme
  static const Color primary = Color(0xFF38A3A5);
  static const Color primaryLight = Color(0xFF5FC2C4);
  static const Color primaryDark = Color(0xFF2B7F80);

  // Secondary Colors - Complementary Teal Accents
  static const Color secondary = Color(0xFF7CD6D0);
  static const Color secondaryLight = Color(0xFF9BDDDD);
  static const Color secondaryDark = Color(0xFF2E8C8E);

  // Status Colors - Softer, Modern Tones
  static const Color success = Color(0xFF27AE60);
  static const Color warning = Color(0xFFFFB547);
  static const Color error = Color(0xFFFF5C5C);
  static const Color info = Color(0xFF38A3A5);

  // Background Colors - Clean, Light Theme
  static const Color background = Color(0xFFFFFFFF);
  static const Color surface = Color(0xFFFFFFFF);
  static const Color cardBackground = Color(0xFFF8F9FF);

  // Text Colors - Modern Gray Scale
  static const Color textPrimary = Color(0xFF1A1D1F);
  static const Color textSecondary = Color(0xFF6C7072);
  static const Color textHint = Color(0xFF9A9FA3);

  // Border Colors - Subtle Lines
  static const Color border = Color(0xFFE8ECEF);
  static const Color divider = Color(0xFFF1F3F5);

  // Chart Colors - Vibrant but Professional
  static const List<Color> chartColors = [
    Color(0xFF38A3A5),
    Color(0xFF5FC2C4),
    Color(0xFF9BDDDD),
    Color(0xFF27AE60),
    Color(0xFFFFB547),
    Color(0xFFFF5C5C),
  ];

  // Overview Box Colors - Soft, Modern Gradients
  static const Color productsBox = Color(0xFFF0F3FF);
  static const Color revenueBox = Color(0xFFF0FFF5);
  static const Color ordersBox = Color(0xFFFFF8F0);
  static const Color inventoryBox = Color(0xFFF0F9FF);

  // Quick Action Colors
  static const Color quickActionBg = Color(0xFFF8F9FF);
  static const Color quickActionBorder = Color(0xFFE8ECEF);
  static const Color quickActionHover = Color(0xFFF0F3FF);

  // Shadow
  static List<BoxShadow> cardShadow = [
    BoxShadow(
      color: const Color(0xFF38A3A5).withOpacity(0.08),
      blurRadius: 10,
      offset: const Offset(0, 4),
    ),
  ];

  // Border Radius
  static const double borderRadius = 16.0;
  static const double cardBorderRadius = 12.0;
  static const double buttonBorderRadius = 8.0;

  // Spacing
  static const double spacing = 16.0;
  static const double smallSpacing = 8.0;
  static const double largeSpacing = 24.0;
} 