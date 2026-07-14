import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'typography_helpers.dart';

class AppTheme {
  AppTheme._();

  // ══════════════════════════════════════════
  //  "Editorial Heritage" palette
  // ══════════════════════════════════════════

  // Backgrounds
  static const Color background = Color(0xFFF5F2EB); // warm newsprint
  static const Color card = Color(0xFFFFFFFF); // white cards
  static const Color cardDark = Color(
    0xFFF8F6F0,
  ); // subtle off-white for contrast

  // Borders & dividers
  static const Color borderSubtle = Color(0xFFE8E5DF); // тонкий разделитель

  // Background gradient (neutral editorial gradient — top lighter, bottom darker)
  static const backgroundGradient = LinearGradient(
    begin: Alignment.topCenter,
    end: Alignment.bottomCenter,
    colors: [
      Color(0xFFF9F8F4), // нейтральный светлый верх
      Color(0xFFCCC5B5), // приглушённый серо-беж низ
    ],
  );

  // Accent
  static const Color accentBlue = Color(0xFF1B365D); // Oxford Blue
  static const Color premiumGreen = Color(0xFF004225); // British Racing Green
  static const Color stressAccent = Color(
    0xFF4A5D23,
  ); // Dark Olive — Stress Test mode
  static const Color stressBg = Color(
    0xFFE8E3D0,
  ); // light olive — Stress Test background
  static const Color stressCard = Color(0xFF252A32); // slightly lighter than bg
  static const Color stressCardBorder = Color(0xFF353A44); // subtle border
  static const Color stressTextPrimary = Color(0xFFF0F2F5); // near-white
  static const Color stressTextSecondary = Color(0xFF8E95A3); // muted gray
  static const Color stressTextDim = Color(0xFF5A6070); // very dim
  static const Color stressGlowGreen = Color(
    0xFF00E676,
  ); // neon green for FS Score glow

  // Semantic
  static const Color dangerRed = Color(0xFFA62639); // burgundy crimson

  // Text
  static const Color textPrimary = Color(0xFF121212); // near-black
  static const Color textSecondary = Color(0xFF666666); // graphite
  static const Color textDim = Color(0xFF999999); // muted

  // Shields (keep as-is for P&L indicators)
  static const Color shieldGreen = Color(0xFF2ECC71);
  static const Color shieldYellow = Color(0xFFF1C40F);
  static const Color shieldRed = Color(0xFFE74C3C);

  static ThemeData get lightTheme {
    final colorScheme = ColorScheme.light(
      primary: accentBlue,
      secondary: accentBlue,
      surface: background,
      error: dangerRed,
      onPrimary: Colors.white,
      onSecondary: Colors.white,
      onSurface: textPrimary,
      onError: Colors.white,
    );

    return ThemeData(
      useMaterial3: true,
      brightness: Brightness.light,
      colorScheme: colorScheme,
      scaffoldBackgroundColor: Colors.transparent,
      textTheme: GoogleFonts.interTextTheme(ThemeData.light().textTheme)
          .copyWith(
            bodyLarge: interNums(color: textPrimary, fontSize: 16),
            bodyMedium: interNums(color: textSecondary, fontSize: 14),
            bodySmall: interNums(color: textDim, fontSize: 12),
            titleLarge: interNums(
              color: textPrimary,
              fontSize: 22,
              fontWeight: FontWeight.w700,
            ),
            titleMedium: interNums(
              color: textPrimary,
              fontSize: 18,
              fontWeight: FontWeight.w600,
            ),
            titleSmall: interNums(
              color: textPrimary,
              fontSize: 14,
              fontWeight: FontWeight.w500,
            ),
          ),
      appBarTheme: AppBarTheme(
        centerTitle: true,
        elevation: 0,
        backgroundColor: background,
        foregroundColor: textPrimary,
        titleTextStyle: GoogleFonts.inter(
          fontSize: 18,
          fontWeight: FontWeight.w600,
          color: textPrimary,
        ),
      ),
      cardTheme: CardThemeData(
        color: card,
        elevation: 1,
        shadowColor: Colors.black.withValues(alpha: 0.04),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(22)),
      ),
      bottomNavigationBarTheme: BottomNavigationBarThemeData(
        type: BottomNavigationBarType.fixed,
        backgroundColor: Colors.transparent,
        selectedItemColor: accentBlue,
        unselectedItemColor: textSecondary,
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
        color: Colors.black.withValues(alpha: 0.08),
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
        contentPadding: const EdgeInsets.symmetric(
          horizontal: 16,
          vertical: 14,
        ),
        hintStyle: GoogleFonts.inter(color: textDim, fontSize: 14),
      ),
    );
  }
}
