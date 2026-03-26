import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class AppTheme {
  static const Color primaryBlue = Color(0xFF6C63FF);
  static const Color darkBackground = Color(0xFF1E1E2C);
  static const Color accentPurple = Color(0xFFB185DB);
  static const Color cardColor = Color(0xFF2A2A3D);
  static const Color textLight = Color(0xFFF0F0F0);
  static const Color textMuted = Color(0xFF9AA0A6);
  
  static const Color priorityHigh = Color(0xFFFF6B6B);
  static const Color priorityMedium = Color(0xFFFFD93D);
  static const Color priorityLow = Color(0xFF6BCB77);

  static ThemeData get darkTheme {
    return ThemeData(
      brightness: Brightness.dark,
      scaffoldBackgroundColor: darkBackground,
      primaryColor: primaryBlue,
      colorScheme: ColorScheme.dark(
        primary: primaryBlue,
        secondary: accentPurple,
        surface: cardColor,
      ),
      textTheme: GoogleFonts.interTextTheme(ThemeData.dark().textTheme).copyWith(
        displayLarge: GoogleFonts.poppins(fontSize: 32, fontWeight: FontWeight.bold, color: textLight),
        titleLarge: GoogleFonts.poppins(fontSize: 22, fontWeight: FontWeight.w600, color: textLight),
        bodyLarge: GoogleFonts.inter(fontSize: 16, color: textLight),
        bodyMedium: GoogleFonts.inter(fontSize: 14, color: textMuted),
      ),
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          backgroundColor: primaryBlue,
          foregroundColor: Colors.white,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
          padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 24),
          elevation: 5,
        ),
      ),
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: cardColor,
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide.none,
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide.none,
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: primaryBlue, width: 2),
        ),
        labelStyle: const TextStyle(color: textMuted),
        hintStyle: const TextStyle(color: textMuted),
      ),
      floatingActionButtonTheme: const FloatingActionButtonThemeData(
        backgroundColor: accentPurple,
        foregroundColor: Colors.white,
      ),
    );
  }
}
