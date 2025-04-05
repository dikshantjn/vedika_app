import 'package:flutter/material.dart';

class AmbulanceAgencyColorPalette {
  // Primary Colors
  static const Color primaryRed = Color(0xFFE53935); // Vibrant emergency red
  static const Color primaryDark = Color(0xFF1A237E); // Deep navy blue
  static const Color primaryLight = Color(0xFFE3F2FD); // Light sky blue

  // Secondary Colors
  static const Color secondaryBlue = Color(0xFF1976D2); // Trustworthy blue
  static const Color secondaryTeal = Color(0xFF00897B); // Calming teal
  static const Color secondaryAmber = Color(0xFFFFA000); // Attention amber

  // Background & Surface
  static const Color backgroundWhite = Color(0xFFFAFAFA); // Off-white background
  static const Color surfaceGray = Color(0xFFEEEEEE); // Light gray surface
  static const Color cardWhite = Color(0xFFFFFFFF); // Pure white for cards

  // Text & Icons
  static const Color textPrimary = Color(0xFF212121); // Dark gray for primary text
  static const Color textSecondary = Color(0xFF757575); // Medium gray for secondary text
  static const Color textOnDark = Color(0xFFFFFFFF); // White text on dark backgrounds
  static const Color iconActive = Color(0xFFFFFFFF); // Red for active icons
  static const Color iconInactive = Color(0xFF0B0B0B); // Gray for inactive icons

  // Status Colors
  static const Color successGreen = Color(0xFF43A047); // Success green
  static const Color warningOrange = Color(0xFFFB8C00); // Warning orange
  static const Color errorRed = Color(0xFFE53935); // Error red
  static const Color infoBlue = Color(0xFF1E88E5); // Info blue

  // Accent Colors
  static const Color accentPurple = Color(0xFF8E24AA); // For special highlights
  static const Color accentCyan = Color(0xFF00ACC1); // For interactive elements

  // Gradient Options
  static const Gradient emergencyGradient = LinearGradient(
    colors: [Color(0xFFE53935), Color(0xFFD81B60)],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );

  static const Gradient professionalGradient = LinearGradient(
    colors: [Color(0xFF1A237E), Color(0xFF283593)],
    begin: Alignment.topCenter,
    end: Alignment.bottomCenter,
  );
}
