import 'package:flutter/material.dart';

class HospitalVendorColorPalette {
  // Primary Colors - Modern Healthcare Blue
  static const Color primaryBlue = Color(0xFF2B6CB0);
  static const Color primaryBlueLight = Color(0xFF4299E1);
  static const Color primaryBlueDark = Color(0xFF2C5282);

  // Secondary Colors - Professional Teal
  static const Color secondaryTeal = Color(0xFF319795);
  static const Color secondaryTealLight = Color(0xFF4FD1C5);
  static const Color secondaryTealDark = Color(0xFF285E61);

  // Accent Colors - Modern Purples
  static const Color accentPurple = Color(0xFF6B46C1);
  static const Color accentPurpleLight = Color(0xFF9F7AEA);
  static const Color accentPink = Color(0xFFD53F8C);

  // Neutral Colors - Modern Grayscale
  static const Color neutralWhite = Color(0xFFFFFFFF);
  static const Color neutralGrey50 = Color(0xFFF7FAFC);
  static const Color neutralGrey100 = Color(0xFFEDF2F7);
  static const Color neutralGrey200 = Color(0xFFE2E8F0);
  static const Color neutralGrey300 = Color(0xFFCBD5E0);
  static const Color neutralGrey400 = Color(0xFFA0AEC0);
  static const Color neutralGrey500 = Color(0xFF718096);
  static const Color neutralGrey600 = Color(0xFF4A5568);
  static const Color neutralGrey700 = Color(0xFF2D3748);
  static const Color neutralGrey800 = Color(0xFF1A202C);
  static const Color neutralGrey900 = Color(0xFF171923);
  static const Color neutralBlack = Color(0xFF000000);

  // Status Colors - Modern Healthcare
  static const Color successGreen = Color(0xFF38A169);
  static const Color warningYellow = Color(0xFFD69E2E);
  static const Color errorRed = Color(0xFFE53E3E);
  static const Color infoBlue = Color(0xFF3182CE);

  // Gradient Colors - Modern Healthcare Gradients
  static const LinearGradient primaryGradient = LinearGradient(
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
    colors: [primaryBlue, primaryBlueLight],
  );

  static const LinearGradient secondaryGradient = LinearGradient(
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
    colors: [secondaryTeal, secondaryTealLight],
  );

  static const LinearGradient accentGradient = LinearGradient(
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
    colors: [accentPurple, accentPurpleLight],
  );

  // Text Colors - Modern Typography
  static const Color textPrimary = neutralGrey900;
  static const Color textSecondary = neutralGrey700;
  static const Color textTertiary = neutralGrey500;
  static const Color textInverse = neutralWhite;

  // Background Colors - Modern Surfaces
  static const Color backgroundPrimary = neutralWhite;
  static const Color backgroundSecondary = neutralGrey50;
  static const Color backgroundTertiary = neutralGrey100;

  // Border Colors - Modern Edges
  static const Color borderLight = neutralGrey200;
  static const Color borderMedium = neutralGrey300;
  static const Color borderDark = neutralGrey400;

  // Shadow Colors - Modern Elevation
  static const Color shadowLight = Color(0x1A000000);
  static const Color shadowMedium = Color(0x33000000);
  static const Color shadowDark = Color(0x4D000000);

  // Overlay Colors - Modern Overlays
  static const Color overlayLight = Color(0x0A000000);
  static const Color overlayMedium = Color(0x1A000000);
  static const Color overlayDark = Color(0x33000000);
} 