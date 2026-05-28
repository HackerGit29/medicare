import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class AppTheme {
  // Backgrounds
  static const Color bgApp = Color(0xFFC8D9E0);
  static const Color bgPrimary = Color(0xFFFFFFFF);
  static const Color bgSecondary = Color(0xFFF0F6F8);
  static const Color bgTertiary = Color(0xFFE8F2F5);

  // Brand / Accent Colors
  static const Color accentTeal = Color(0xFF1A3A4A);
  static const Color accentPink = Color(0xFFF0B8C8);
  static const Color accentPurple = Color(0xFFC8A8D8);
  static const Color accentSage = Color(0xFFA8C8A8);
  static const Color accentCoral = Color(0xFFE8C0A8);
  static const Color accentBlue = Color(0xFFA8C8E0);
  static const Color accentMint = Color(0xFFB8E0D0);
  static const Color accentGold = Color(0xFFF5C842);
  static const Color accentDot = Color(0xFFE8506A);

  // Text Colors
  static const Color textPrimary = Color(0xFF1A2530);
  static const Color textSecondary = Color(0xFF4A5A68);
  static const Color textMuted = Color(0xFF8A9AAA);
  static const Color textInverse = Color(0xFFFFFFFF);
  static const Color textAccent = Color(0xFF1A3A4A);

  // Interactive
  static const Color interactive = Color(0xFF1A3A4A);
  static const Color interactiveHover = Color(0xFF2A4A5A);
  static const Color borderSubtle = Color(0x141A3A4A); 
  static const Color shadowCardColor = Color(0x141A3A4A);

  // Radius
  static const double radiusXs = 6.0;
  static const double radiusSm = 10.0;
  static const double radiusMd = 14.0;
  static const double radiusLg = 20.0;
  static const double radiusXl = 24.0;
  static const double radius2xl = 32.0;

  static ThemeData get lightTheme {
    return ThemeData(
      useMaterial3: true,
      scaffoldBackgroundColor: bgApp,
      colorScheme: const ColorScheme.light(
        primary: accentTeal,
        secondary: accentPink,
        surface: bgPrimary,
        error: accentDot,
        onPrimary: textInverse,
        onSecondary: textPrimary,
        onSurface: textPrimary,
      ),
      textTheme: TextTheme(
        displayLarge: GoogleFonts.dmSerifDisplay(
          fontSize: 28,
          fontWeight: FontWeight.w700,
          color: textPrimary,
          height: 1.1,
          letterSpacing: -0.02,
        ),
        displayMedium: GoogleFonts.dmSans(
          fontSize: 24,
          fontWeight: FontWeight.w700,
          color: textPrimary,
          height: 1.3,
          letterSpacing: -0.02,
        ),
        titleLarge: GoogleFonts.dmSans(
          fontSize: 20,
          fontWeight: FontWeight.w700,
          color: textPrimary,
          height: 1.3,
        ),
        titleMedium: GoogleFonts.dmSans(
          fontSize: 17,
          fontWeight: FontWeight.w700,
          color: textPrimary,
          height: 1.3,
        ),
        bodyLarge: GoogleFonts.dmSans(
          fontSize: 15,
          color: textPrimary,
          height: 1.5,
        ),
        bodyMedium: GoogleFonts.dmSans(
          fontSize: 14,
          color: textSecondary,
          height: 1.5,
        ),
        bodySmall: GoogleFonts.dmSans(
          fontSize: 12,
          color: textMuted,
          height: 1.5,
        ),
        labelSmall: GoogleFonts.dmSans(
          fontSize: 10,
          color: textMuted,
          height: 1.5,
          letterSpacing: 0.03,
        ),
      ),
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          backgroundColor: interactive,
          foregroundColor: textInverse,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(9999),
          ),
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
          textStyle: GoogleFonts.dmSans(
            fontSize: 13,
            fontWeight: FontWeight.w600,
          ),
        ),
      ),
      cardTheme: CardTheme(
        color: bgPrimary,
        elevation: 2,
        shadowColor: shadowCardColor,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(radiusMd),
        ),
      ),
    );
  }
}
