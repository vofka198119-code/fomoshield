// ---------------------------------------------------------------------------
// FINSCANCO UI RECONSTRUCTION V2 — Global Design System
// ---------------------------------------------------------------------------
// Chapter 1: Global Theme (Steps 1–40)
//
// RULES:
//   - No Color(...), Colors.*, or magic numbers in any screen
//   - All values come from this file only
//   - Max 7 core colors in the entire app (Steps 7–15)
//   - Typography: 6 sizes only (Steps 16–23)
//   - Border radius: 3 sizes only (Steps 24–27)
//   - Single shadow system (Steps 28–29)
//   - Spacing: 8 values from grid (Steps 30–34)
//   - Icons: Material Symbols Rounded only (Steps 35–37)
//   - Buttons: height 48, radius 18, elevation 0 (Steps 38–39)
// ---------------------------------------------------------------------------

import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'typography_helpers.dart';

/// FINSCANCO Design Tokens v2.0
///
/// Single source of truth for all visual properties.
/// Every screen, widget, and component MUST reference this class.
abstract final class ThemeV2 {
  ThemeV2._();

  // ══════════════════════════════════════════════
  //  COLOR SYSTEM (7 core colors — Steps 7–15)
  // ══════════════════════════════════════════════

  /// Primary brand color — used for headers, buttons, icons, highlights.
  /// Step 7
  static const Color primary = Color(0xFF215C42);

  /// Success — profit, positive change, growth.
  /// Step 8
  static const Color success = Color(0xFF2DBE63);

  /// Loss — loss, negative change, decline.
  /// Step 9
  static const Color loss = Color(0xFFC64545);

  /// Background — single app-wide background.
  /// Step 10
  static const Color background = Color(0xFFF5F1E8);

  /// Subtle gradient from background to a slightly deeper warm tone.
  /// No new colors — derived from the core palette.
  static const LinearGradient backgroundGradient = LinearGradient(
    begin: Alignment.topCenter,
    end: Alignment.bottomCenter,
    colors: [
      Color(0xFFF5F1E8), // background — светлый верх
      Color(0xFFE7DECC), // чуть глубже — тёплый беж низ
    ],
  );

  /// Surface — all cards.
  /// Step 11
  static const Color surface = Color(0xFFFFFFFF);

  /// Secondary text — muted, grey.
  /// Step 12
  static const Color textSecondary = Color(0xFF8B8B8B);

  /// Primary text — near-black.
  /// Step 13
  static const Color textPrimary = Color(0xFF202020);

  /// Divider — thin separators between cards and rows.
  /// Step 14
  static const Color divider = Color(0xFFECECEC);

  // ══════════════════════════════════════════════
  //  EXTENDED PALETTE (semantic, derived from core)
  // ══════════════════════════════════════════════

  /// Warning / neutral — for sideways market, pending states.
  static const Color warning = Color(0xFFD7AE42);

  /// Success background — 10% opacity overlay.
  static Color get successBg => success.withValues(alpha: 0.10);

  /// Loss background — 10% opacity overlay.
  static Color get lossBg => loss.withValues(alpha: 0.10);

  /// Primary background — 10% opacity overlay.
  static Color get primaryBg => primary.withValues(alpha: 0.10);

  // ══════════════════════════════════════════════
  //  TYPOGRAPHY (6 sizes — Steps 16–23)
  // ══════════════════════════════════════════════

  /// Display XL — 42 / Weight 800
  /// USE ONLY FOR: stock price
  /// Step 16
  static TextStyle get displayXL => GoogleFonts.inter(
    fontSize: 42,
    fontWeight: FontWeight.w800,
    color: textPrimary,
    fontFeatures: const [FontFeature.tabularFigures()],
  );

  /// Display L — 34 / Weight 700
  /// USE ONLY FOR: portfolio value
  /// Step 17
  static TextStyle get displayL => GoogleFonts.inter(
    fontSize: 34,
    fontWeight: FontWeight.w700,
    color: textPrimary,
    fontFeatures: const [FontFeature.tabularFigures()],
  );

  /// Title — 22 / Weight 700
  /// USE ONLY FOR: company name
  /// Step 18
  static TextStyle get title => GoogleFonts.inter(
    fontSize: 22,
    fontWeight: FontWeight.w700,
    color: textPrimary,
  );

  /// Section — 18 / Weight 700
  /// USE ONLY FOR: block titles
  /// Step 19
  static TextStyle get section => GoogleFonts.inter(
    fontSize: 18,
    fontWeight: FontWeight.w700,
    color: textPrimary,
  );

  /// Body — 16 / Weight 500
  /// Step 20
  static TextStyle get body => GoogleFonts.inter(
    fontSize: 16,
    fontWeight: FontWeight.w500,
    color: textPrimary,
  );

  /// Caption — 13 / Weight 400
  /// Step 21
  static TextStyle get caption => GoogleFonts.inter(
    fontSize: 13,
    fontWeight: FontWeight.w400,
    color: textSecondary,
  );

  /// Small — 11 / Weight 400
  /// Step 22
  static TextStyle get small => GoogleFonts.inter(
    fontSize: 11,
    fontWeight: FontWeight.w400,
    color: textSecondary,
  );

  // ══════════════════════════════════════════════
  //  BORDER RADIUS (3 sizes — Steps 24–27)
  // ══════════════════════════════════════════════

  /// Small radius — 12
  /// Step 24
  static const double radiusSmall = 12;

  /// Medium radius — 18
  /// Step 25
  static const double radiusMedium = 18;

  /// Large radius — 24 (ALL cards)
  /// Step 26–27
  static const double radiusLarge = 24;

  static BorderRadius get borderRadiusSmall =>
      BorderRadius.circular(radiusSmall);
  static BorderRadius get borderRadiusMedium =>
      BorderRadius.circular(radiusMedium);
  static BorderRadius get borderRadiusLarge =>
      BorderRadius.circular(radiusLarge);

  // ══════════════════════════════════════════════
  //  SHADOW (single system — Steps 28–29)
  // ══════════════════════════════════════════════

  /// Single shadow for ALL cards.
  /// Blur 18, Offset Y 6, Opacity 0.06
  /// Step 28
  static const List<BoxShadow> cardShadow = [
    BoxShadow(
      color: Color.fromRGBO(0, 0, 0, 0.06),
      blurRadius: 18,
      offset: Offset(0, 6),
    ),
  ];

  // ══════════════════════════════════════════════
  //  SPACING (8 values — Steps 30–34)
  // ══════════════════════════════════════════════

  /// Step 30
  static const double space4 = 4;
  static const double space8 = 8;
  static const double space12 = 12;
  static const double space16 = 16;
  static const double space20 = 20;
  static const double space24 = 24;
  static const double space32 = 32;
  static const double space40 = 40;

  /// Card inner padding — 20
  /// Step 32
  static const double cardPadding = 20;

  /// Gap between cards — 16
  /// Step 33
  static const double cardGap = 16;

  /// Screen horizontal padding — 20
  /// Step 34
  static const double screenPadding = 20;

  // ══════════════════════════════════════════════
  //  ICONS (Steps 35–37)
  // ══════════════════════════════════════════════

  /// Default icon size — 22
  /// Step 36
  static const double iconSize = 22;

  /// Small icon size — 18
  /// Step 37
  static const double iconSizeSmall = 18;

  // ══════════════════════════════════════════════
  //  BUTTONS (Steps 38–39)
  // ══════════════════════════════════════════════

  /// Button height — 48
  /// Button radius — 18
  /// Elevation — 0
  /// Step 38
  static const double buttonHeight = 48;
  static const double buttonRadius = radiusMedium;

  // ══════════════════════════════════════════════
  //  ANIMATION DURATIONS
  // ══════════════════════════════════════════════

  static const Duration animFast = Duration(milliseconds: 120);
  static const Duration animNormal = Duration(milliseconds: 300);
  static const Duration animSlow = Duration(milliseconds: 600);
  static const Duration animVerySlow = Duration(milliseconds: 700);

  // ══════════════════════════════════════════════
  //  FULL ThemeData
  // ══════════════════════════════════════════════

  static ThemeData get lightTheme {
    final colorScheme = ColorScheme.light(
      primary: primary,
      secondary: primary,
      surface: surface,
      error: loss,
      onPrimary: Colors.white,
      onSecondary: Colors.white,
      onSurface: textPrimary,
      onError: Colors.white,
    );

    return ThemeData(
      useMaterial3: true,
      brightness: Brightness.light,
      colorScheme: colorScheme,
      scaffoldBackgroundColor: background,
      textTheme: GoogleFonts.interTextTheme(ThemeData.light().textTheme)
          .copyWith(
            bodyLarge: body,
            bodyMedium: caption,
            bodySmall: small,
            titleLarge: title,
            titleMedium: section,
            titleSmall: caption.copyWith(
              color: textPrimary,
              fontWeight: FontWeight.w500,
            ),
          ),
      appBarTheme: AppBarTheme(
        centerTitle: false,
        elevation: 0,
        backgroundColor: background,
        foregroundColor: textPrimary,
        titleTextStyle: section,
      ),
      cardTheme: CardThemeData(
        color: surface,
        elevation: 0,
        shadowColor: Colors.transparent,
        shape: RoundedRectangleBorder(borderRadius: borderRadiusLarge),
      ),
      bottomNavigationBarTheme: BottomNavigationBarThemeData(
        type: BottomNavigationBarType.fixed,
        backgroundColor: surface,
        selectedItemColor: primary,
        unselectedItemColor: textSecondary,
        elevation: 0,
      ),
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          backgroundColor: primary,
          foregroundColor: Colors.white,
          minimumSize: const Size(double.infinity, buttonHeight),
          elevation: 0,
          shape: RoundedRectangleBorder(borderRadius: borderRadiusMedium),
          textStyle: GoogleFonts.inter(
            fontSize: 16,
            fontWeight: FontWeight.w600,
          ),
        ),
      ),
      filledButtonTheme: FilledButtonThemeData(
        style: FilledButton.styleFrom(
          minimumSize: const Size(double.infinity, buttonHeight),
          elevation: 0,
          shape: RoundedRectangleBorder(borderRadius: borderRadiusMedium),
        ),
      ),
      outlinedButtonTheme: OutlinedButtonThemeData(
        style: OutlinedButton.styleFrom(
          foregroundColor: primary,
          side: const BorderSide(color: primary),
          minimumSize: const Size(double.infinity, buttonHeight),
          elevation: 0,
          shape: RoundedRectangleBorder(borderRadius: borderRadiusMedium),
        ),
      ),
      dividerTheme: DividerThemeData(color: divider, thickness: 1),
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: surface,
        border: OutlineInputBorder(
          borderRadius: borderRadiusMedium,
          borderSide: BorderSide.none,
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: borderRadiusMedium,
          borderSide: const BorderSide(color: primary, width: 2),
        ),
        contentPadding: const EdgeInsets.symmetric(
          horizontal: 16,
          vertical: 14,
        ),
        hintStyle: caption,
      ),
      iconTheme: const IconThemeData(size: iconSize, color: textPrimary),
    );
  }
}
