import 'package:flutter/material.dart';

class DoctorConsultationColorPalette {
  // Primary Colors
  static const Color primaryBlue = Color(0xFF328E6E); // Dark Green
  static const Color primaryBlueLight = Color(0xFF67AE6E); // Medium Green
  static const Color primaryBlueDark = Color(0xFF1F6E53); // Darker Green

  // Secondary Colors
  static const Color secondaryTeal = Color(0xFF90C67C); // Light Green
  static const Color secondaryTealLight = Color(0xFFE1EEBC); // Very Light Green/Yellow
  static const Color secondaryTealDark = Color(0xFF729C62); // Medium-Dark Green

  // Background Colors
  static const Color backgroundPrimary = Color(0xFFF8FBF4); // Very Light Green tint
  static const Color backgroundSecondary = Color(0xFFFFFFFF); // White
  static const Color backgroundCard = Color(0xFFF3F9E9); // Very Light Green/Yellow tint

  // Text Colors
  static const Color textPrimary = Color(0xFF2C3E30); // Dark Green-Gray for text
  static const Color textSecondary = Color(0xFF5D6E60); // Medium Green-Gray
  static const Color textHint = Color(0xFF8FA492); // Light Green-Gray
  static const Color textWhite = Color(0xFFFFFFFF); // White

  // Border Colors
  static const Color borderLight = Color(0xFFD5E8C0); // Light Green border
  static const Color borderMedium = Color(0xFFBBD6A7); // Medium Green border
  static const Color borderDark = Color(0xFF90C67C); // Same as secondaryTeal

  // Status Colors
  static const Color successGreen = Color(0xFF67AE6E); // Same as primaryBlueLight
  static const Color errorRed = Color(0xFFE57373); // Soft Red that matches palette
  static const Color warningYellow = Color(0xFFFFD54F); // Soft Yellow that matches palette
  static const Color infoBlue = Color(0xFF328E6E); // Same as primaryBlue

  // Progress Indicator Colors
  static const Color progressActive = primaryBlue;
  static const Color progressInactive = Color(0xFFE1EEBC); // Very Light Green/Yellow
  static const Color progressBackground = Color(0xFFF8FBF4); // Very Light Green tint

  // Button Colors
  static const Color buttonPrimary = primaryBlue;
  static const Color buttonSecondary = secondaryTeal;
  static const Color buttonDisabled = Color(0xFFCCDDBF); // Light Green-Gray

  // Shadow Colors
  static const Color shadowLight = Color(0x1A328E6E); // Light shadow with primary color
  static const Color shadowMedium = Color(0x33328E6E); // Medium shadow with primary color
  static const Color shadowDark = Color(0x4D328E6E); // Dark shadow with primary color

  // Gradient Colors
  static const LinearGradient primaryGradient = LinearGradient(
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
    colors: [primaryBlue, primaryBlueDark],
  );

  static const LinearGradient secondaryGradient = LinearGradient(
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
    colors: [secondaryTeal, secondaryTealDark],
  );
}
