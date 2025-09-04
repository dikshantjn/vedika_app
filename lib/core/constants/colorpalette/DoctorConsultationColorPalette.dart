import 'package:flutter/material.dart';

class DoctorConsultationColorPalette {
  // Primary Colors
  static const Color primaryColor = Color(0xFF38A3A5);  // Teal primary
  static const Color primaryBlue = primaryColor; // Alias for backward compatibility
  static const Color primaryBlueLight = Color(0xFF5BB8BA); // Lighter Teal
  static const Color primaryBlueDark = Color(0xFF2E8284); // Darker Teal

  // Secondary Colors
  static const Color secondaryTeal = Color(0xFF7CC9CB); // Light Teal
  static const Color secondaryTealLight = Color(0xFFE8F8F9); // Very Light Teal/Blue tint
  static const Color secondaryTealDark = Color(0xFF4F9A9C); // Medium-Dark Teal

  // Background Colors
  static const Color backgroundPrimary = Color(0xFFF0F9FA); // Very Light Teal/Blue tint
  static const Color backgroundSecondary = Color(0xFFFFFFFF); // White
  static const Color backgroundCard = Color(0xFFE8F4F5); // Very Light Teal/Blue tint

  // Text Colors
  static const Color textPrimary = Color(0xFF1A4A4D); // Dark Teal-Gray for text
  static const Color textSecondary = Color(0xFF4A6B6D); // Medium Teal-Gray
  static const Color textHint = Color(0xFF7A9A9C); // Light Teal-Gray
  static const Color textWhite = Color(0xFFFFFFFF); // White

  // Border Colors
  static const Color borderLight = Color(0xFFB8E0E2); // Light Teal border
  static const Color borderMedium = Color(0xFF8FCFD1); // Medium Teal border
  static const Color borderDark = Color(0xFF7CC9CB); // Same as secondaryTeal

  // Status Colors
  static const Color successGreen = Color(0xFF5BB8BA); // Same as primaryBlueLight
  static const Color errorRed = Color(0xFFE57373); // Soft Red that matches palette
  static const Color warningYellow = Color(0xFFFFD54F); // Soft Yellow that matches palette
  static const Color infoBlue = Color(0xFF38A3A5); // Same as primaryColor

  // Progress Indicator Colors
  static const Color progressActive = primaryColor;
  static const Color progressInactive = Color(0xFFE8F8F9); // Very Light Teal/Blue
  static const Color progressBackground = Color(0xFFF0F9FA); // Very Light Teal/Blue tint

  // Button Colors
  static const Color buttonPrimary = primaryColor;
  static const Color buttonSecondary = secondaryTeal;
  static const Color buttonDisabled = Color(0xFFB8D7D9); // Light Teal-Gray

  // Shadow Colors
  static const Color shadowLight = Color(0x1A38A3A5); // Light shadow with primary color
  static const Color shadowMedium = Color(0x3338A3A5); // Medium shadow with primary color
  static const Color shadowDark = Color(0x4D38A3A5); // Dark shadow with primary color

  // Gradient Colors
  static const LinearGradient primaryGradient = LinearGradient(
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
    colors: [primaryColor, primaryBlueDark],
  );

  static const LinearGradient secondaryGradient = LinearGradient(
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
    colors: [secondaryTeal, secondaryTealDark],
  );
}
