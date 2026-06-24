import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class AppTheme {
  AppTheme._();

  // F.O.M.O. Shield palette
  static const Color background = Color(0xFF0B1018);
  static const Color card = Color(0xFF141B26);
  static const Color cardDark = Color(0xFF1A2235);
  static const Color accentBlue = Color(0xFF00B4D8);
  static const Color dangerRed = Color(0xFFFF4D6A);
  static const Color textDim = Color(0xFF6B7A99);

  // Shields colors
  static const Color shieldGreen = Color(0xFF2ECC71);
  static const Color shieldYellow = Color(0xFFF1C40F);
  static const Color shieldRed = Color(0xFFE74C3C);

  static ThemeData get darkTheme {
    final colorScheme = ColorScheme.dark(
      primary: accentBlue,
      secondary: accentBlue,
      surface: background,
      error: dangerRed,
      onPrimary: Colors.white,
      onSecondary: Colors.white,
      onSurface: Colors.white,
      onError: Colors.white,
    );

    return ThemeData(
      useMaterial3: true,
      brightness: Brightness.dark,
      colorScheme: colorScheme,
      scaffoldBackgroundColor: background,
      textTheme: GoogleFonts.interTextTheme(ThemeData.dark().textTheme).copyWith(
        bodyLarge: GoogleFonts.inter(color: Colors.white, fontSize: 16),
        bodyMedium: GoogleFonts.inter(color: Colors.white70, fontSize: 14),
        bodySmall: GoogleFonts.inter(color: textDim, fontSize: 12),
        titleLarge: GoogleFonts.inter(color: Colors.white, fontSize: 22, fontWeight: FontWeight.w700),
        titleMedium: GoogleFonts.inter(color: Colors.white, fontSize: 18, fontWeight: FontWeight.w600),
        titleSmall: GoogleFonts.inter(color: Colors.white, fontSize: 14, fontWeight: FontWeight.w500),
      ),
      appBarTheme: AppBarTheme(
        centerTitle: true,
        elevation: 0,
        backgroundColor: background,
        foregroundColor: Colors.white,
        titleTextStyle: GoogleFonts.inter(
          fontSize: 18,
          fontWeight: FontWeight.w600,
          color: Colors.white,
        ),
      ),
      cardTheme: CardThemeData(
        color: card,
        elevation: 0,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12),
        ),
      ),
      bottomNavigationBarTheme: const BottomNavigationBarThemeData(
        type: BottomNavigationBarType.fixed,
        backgroundColor: cardDark,
        selectedItemColor: accentBlue,
        unselectedItemColor: textDim,
        elevation: 0,
      ),
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          backgroundColor: accentBlue,
          foregroundColor: Colors.white,
          minimumSize: const Size(double.infinity, 52),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
          textStyle: GoogleFonts.inter(
            fontSize: 16,
            fontWeight: FontWeight.w600,
          ),
        ),
      ),
      outlinedButtonTheme: OutlinedButtonThemeData(
        style: OutlinedButton.styleFrom(
          foregroundColor: accentBlue,
          side: const BorderSide(color: accentBlue),
          minimumSize: const Size(double.infinity, 52),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
        ),
      ),
      dividerTheme: DividerThemeData(
        color: Colors.white.withValues(alpha: 0.06),
        thickness: 1,
      ),
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: card,
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide.none,
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: accentBlue, width: 2),
        ),
        contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
        hintStyle: GoogleFonts.inter(color: textDim, fontSize: 14),
      ),
    );
  }
}

