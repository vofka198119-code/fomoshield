// ---------------------------------------------------------------------------
// FOMO Shield — Design Tokens (Design Bible Part 1)
// ---------------------------------------------------------------------------
// Полная цветовая система, типографика, радиусы, тени и анимации.
// Все цвета — ТОЛЬКО через этот класс, никогда напрямую.
// ---------------------------------------------------------------------------

import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'app_theme.dart';
import 'theme_v2.dart';
import 'typography_helpers.dart';

/// Design Tokens for FOMO Shield Dashboard.
///
/// ### Правила
/// - Никаких цветов напрямую — только через геттеры этого класса
/// - Никакого чистого белого, чёрного, Material Blue
/// - Всегда кремовая палитра #F6F1E7
/// - Карточки никогда не касаются друг друга (gap 24px)
abstract final class FomoShieldTheme {
  // ══════════════════════════════════════════════
  //  BACKGROUND
  // ══════════════════════════════════════════════
  static const Color background = Color(0xFFF6F1E7); // --bg
  static const Color card = Color(0xFFFFFDF9); // --bg-card
  static const Color backgroundSecondary = Color(0xFFEFE8DA); // --bg-secondary

  // ══════════════════════════════════════════════
  //  TEXT
  // ══════════════════════════════════════════════
  static const Color text = Color(0xFF2B2A28); // --text
  static const Color textLight = Color(0xFF726B63); // --text-light
  static const Color textMuted = Color(0xFF9B958C); // --text-muted

  // ══════════════════════════════════════════════
  //  BRAND
  // ══════════════════════════════════════════════
  static const Color primary = Color(0xFF355C7D); // --primary
  static const Color primaryDark = Color(0xFF24415B); // --primary-dark
  static const Color shield = Color(0xFF3F7CFF); // --shield

  // ══════════════════════════════════════════════
  //  MARKET PHASES
  // ══════════════════════════════════════════════
  static const Color bull = Color(0xFF43B97F); // --bull
  static const Color bear = Color(0xFFC94D4D); // --bear
  static const Color sideways = Color(0xFFD7AE42); // --sideways
  static const Color recovery = Color(0xFF7ACB7A); // --recovery
  static const Color volatility = Color(0xFFE88D2D); // --volatility
  static const Color blackSwan = Color(0xFF463D55); // --blackSwan
  static const Color crash = Color(0xFF962D2D); // --crash

  /// Get color for a specific market phase.
  static Color phaseColor(String phase) => switch (phase.toLowerCase()) {
        'bull' => bull,
        'bear' => bear,
        'sideways' => sideways,
        'recovery' => recovery,
        'volatility' => volatility,
        'blackswan' || 'black_swan' => blackSwan,
        'crash' => crash,
        _ => textLight,
      };

  // ══════════════════════════════════════════════
  //  EXPLAINABLE FACTORS (Bible Part 9)
  // ══════════════════════════════════════════════
  static const Color factorMarket = Color(0xFF6FA7D6); // Market — Blue
  static const Color factorSector = Color(0xFF77C88A); // Sector — Green
  static const Color factorCompany = Color(0xFFF0B04F); // Company — Orange
  static const Color factorNews = Color(0xFF8A76D6); // News — Purple
  static const Color factorHype = Color(0xFFE0724A); // Hype — Deep orange
  static const Color factorNoise = Color(0xFFBFB9AE); // Noise — Grey

  static Color factorColor(String name) => switch (name.toLowerCase()) {
        'market' || 'marketpct' => factorMarket,
        'sector' || 'sectorpct' => factorSector,
        'company' || 'companypct' => factorCompany,
        'news' || 'newspct' => factorNews,
        'hype' || 'hypepct' => factorHype,
        'noise' || 'noisepct' => factorNoise,
        _ => textLight,
      };

  // ══════════════════════════════════════════════
  //  PSYCHOLOGY (4 Sub-Indices)
  // ══════════════════════════════════════════════
  static const Color discipline = Color(0xFF3C8D60); // --discipline
  static const Color patience = Color(0xFF5078E1); // --patience
  static const Color panic = Color(0xFFC74D4D); // --panic
  static const Color strategy = Color(0xFFE0A42F); // --strategy

  /// Get color for a psychology sub-index by name.
  static Color psychologyColor(String index) => switch (index.toLowerCase()) {
        'panicresistance' || 'panic_resistance' || 'panic resistance' => panic,
        'discipline' => discipline,
        'patience' => patience,
        'strategyadherence' || 'strategy_adherence' || 'strategy adherence' =>
          strategy,
        _ => textLight,
      };

  // ══════════════════════════════════════════════
  //  GUARDIAN COLORS
  // ══════════════════════════════════════════════
  static const Color guardianBody = Color(0xFF4E6D8D); // --guardian-body
  static const Color guardianFace = Color(0xFFF4F1E7); // --guardian-face
  static const Color guardianShadow = Color(0xFF27415D); // --guardian-shadow
  static const Color guardianEye = Color(0xFF6EE7FF); // --guardian-eye
  static const Color guardianGlow = Color(0xFFA6D8FF); // --guardian-glow

  // ══════════════════════════════════════════════
  //  P&L INDICATORS
  // ══════════════════════════════════════════════
  static const Color positive = Color(0xFF37B86B); // --positive
  static const Color negative = Color(0xFFD04E4E); // --negative

  // ══════════════════════════════════════════════
  //  BORDERS & SHADOWS
  // ══════════════════════════════════════════════
  static const Color border = Color(0xFFE8E1D5); // --border

  static const List<BoxShadow> shadowSoft = [
    BoxShadow(
      color: Color.fromRGBO(0, 0, 0, 0.03),
      blurRadius: 6,
      offset: Offset(0, 2),
    ),
    BoxShadow(
      color: Color.fromRGBO(0, 0, 0, 0.07),
      blurRadius: 24,
      offset: Offset(0, 10),
    ),
  ];

  static const List<BoxShadow> shadowMedium = [
    BoxShadow(
      color: Color.fromRGBO(0, 0, 0, 0.10),
      blurRadius: 30,
      offset: Offset(0, 12),
    ),
  ];

  static const List<BoxShadow> shadowHeavy = [
    BoxShadow(
      color: Color.fromRGBO(0, 0, 0, 0.18),
      blurRadius: 50,
      offset: Offset(0, 18),
    ),
  ];

  // ══════════════════════════════════════════════
  //  RADIUS
  // ══════════════════════════════════════════════
  static const double radiusXs = 8;
  static const double radiusSm = 14;
  static const double radius = 22; // --radius (default card)
  static const double radiusXl = 34;

  /// Card border radius (default 22).
  static BorderRadius get cardRadius => BorderRadius.circular(radius);

  /// Small card / badge border radius (14).
  static BorderRadius get cardRadiusSm => BorderRadius.circular(radiusSm);

  /// Extra-large border radius (34).
  static BorderRadius get cardRadiusXl => BorderRadius.circular(radiusXl);

  // ══════════════════════════════════════════════
  //  SPACING
  // ══════════════════════════════════════════════
  static const double space4 = 4;
  static const double space8 = 8;
  static const double space12 = 12;
  static const double space16 = 16;
  static const double space20 = 20;
  static const double space24 = 24;
  static const double space32 = 32;
  static const double space40 = 40;

  /// Gap between cards (24px).
  static const double cardGap = 24;

  /// Padding inside cards (24px).
  static const double cardPadding = 22;

  // ══════════════════════════════════════════════
  //  ANIMATION DURATIONS
  // ══════════════════════════════════════════════
  static const Duration animFast = Duration(milliseconds: 180); // --fast
  static const Duration animNormal = Duration(milliseconds: 320); // --normal
  static const Duration animSlow = Duration(milliseconds: 650); // --slow
  static const Duration animBreath = Duration(milliseconds: 5500); // --breath: 5.5s
  static const Duration animPulse = Duration(milliseconds: 2600); // --pulse
  static const Duration animBlink = Duration(seconds: 5); // --blink
  static const Duration animCardAppear = Duration(milliseconds: 450); // cardAppear
  static const Duration animSuccessRise = Duration(milliseconds: 800); // successRise
  static const Duration animFearGlow = Duration(milliseconds: 1200); // fearGlow
  static const Duration animChartGrow = Duration(milliseconds: 600); // chartGrow
  static const Duration animValueFlash = Duration(milliseconds: 400); // valueFlash

  // ══════════════════════════════════════════════
  //  TYPOGRAPHY
  // ══════════════════════════════════════════════

  // Font sizes
  static const double fsTitle = 34; // --fs-title
  static const double fsH1 = 28; // --fs-h1
  static const double fsH2 = 22; // --fs-h2
  static const double fsCard = 18; // --fs-card
  static const double fsBody = 15; // --fs-body
  static const double fsSmall = 13; // --fs-small
  static const double fsCaption = 11; // --fs-caption

  /// Brand title: 28px, w800, -1px letter-spacing.
  static TextStyle brandTitle([Color? color]) => GoogleFonts.inter(
        fontSize: fsH1,
        fontWeight: FontWeight.w800,
        letterSpacing: -1,
        color: color ?? text,
      );

  /// Card title: 13px, w700, uppercase.
  static TextStyle cardTitle([Color? color]) => GoogleFonts.inter(
        fontSize: 13,
        fontWeight: FontWeight.w700,
        letterSpacing: 1.2,
        color: color ?? ThemeV2.primary,
      );

  /// Portfolio value: 42px, w800, -2px letter-spacing.
  static TextStyle portfolioValue([Color? color]) => interNums(
        fontSize: 42,
        fontWeight: FontWeight.w800,
        letterSpacing: -2,
        height: 1.0,
        color: color ?? text,
      );

  /// Portfolio profit: 19px, w700.
  static TextStyle portfolioProfit([Color? color]) => interNums(
        fontSize: 19,
        fontWeight: FontWeight.w700,
        color: color ?? positive,
      );

  /// Market phase label: 18px, w800, uppercase, 1px letter-spacing.
  static TextStyle marketPhase([Color? color]) => GoogleFonts.inter(
        fontSize: 18,
        fontWeight: FontWeight.w800,
        letterSpacing: 1,
        color: color ?? text,
      );

  /// Market temperature: 14px, w500.
  static TextStyle marketTemperature([Color? color]) => GoogleFonts.inter(
        fontSize: 14,
        fontWeight: FontWeight.w500,
        color: color ?? textLight,
      );

  /// Guardian message: 18px, w600, height 1.6, centered.
  static TextStyle guardianMessage([Color? color]) => GoogleFonts.inter(
        fontSize: 18,
        fontWeight: FontWeight.w600,
        height: 1.6,
        color: color ?? text,
      );

  /// Shield value (FS Score number): 48px, w900, -2px letter-spacing.
  static TextStyle shieldValue([Color? color]) => interNums(
        fontSize: 48,
        fontWeight: FontWeight.w900,
        letterSpacing: -2,
        color: color ?? text,
      );

  /// Shield text: 16px, w600.
  static TextStyle shieldText([Color? color]) => GoogleFonts.inter(
        fontSize: 16,
        fontWeight: FontWeight.w600,
        color: color ?? textLight,
      );

  /// Psychology item: 15px, w600.
  static TextStyle psychologyItem([Color? color]) => interNums(
        fontSize: 15,
        fontWeight: FontWeight.w600,
        color: color ?? text,
      );

  /// Holding symbol: 20px, w800.
  static TextStyle holdingSymbol([Color? color]) => GoogleFonts.inter(
        fontSize: 20,
        fontWeight: FontWeight.w800,
        color: color ?? text,
      );

  /// Holding company name: 14px.
  static TextStyle holdingCompany([Color? color]) => GoogleFonts.inter(
        fontSize: 14,
        color: color ?? textLight,
      );

  /// Holding value: 20px, w700.
  static TextStyle holdingValue([Color? color]) => interNums(
        fontSize: 20,
        fontWeight: FontWeight.w700,
        color: color ?? text,
      );

  /// Holding percent: 15px, w700.
  static TextStyle holdingPercent([Color? color]) => interNums(
        fontSize: 15,
        fontWeight: FontWeight.w700,
        color: color ?? text,
      );

  /// Timeline date: 12px, w600.
  static TextStyle timelineDate([Color? color]) => interNums(
        fontSize: 12,
        fontWeight: FontWeight.w600,
        color: color ?? textLight,
      );

  /// Timeline title: 16px, w700.
  static TextStyle timelineTitle([Color? color]) => GoogleFonts.inter(
        fontSize: 16,
        fontWeight: FontWeight.w700,
        color: color ?? text,
      );

  /// Timeline text: 14px.
  static TextStyle timelineText([Color? color]) => GoogleFonts.inter(
        fontSize: 14,
        color: color ?? textLight,
      );

  /// Verdict text: 17px, w500, height 1.8.
  static TextStyle verdictText([Color? color]) => GoogleFonts.inter(
        fontSize: 17,
        fontWeight: FontWeight.w500,
        height: 1.8,
        color: color ?? text,
      );

  /// Explainable factor bar label: 11px, w700.
  static TextStyle factorLabel([Color? color]) => GoogleFonts.inter(
        fontSize: 11,
        fontWeight: FontWeight.w700,
        letterSpacing: 0.3,
        color: color ?? textLight,
      );

  /// Explainable factor percent: 13px, w800.
  static TextStyle factorPercent([Color? color]) => interNums(
        fontSize: 13,
        fontWeight: FontWeight.w800,
        color: color ?? text,
      );

  /// Explainable description text: 13px, w500, height 1.5.
  static TextStyle factorDescription([Color? color]) => GoogleFonts.inter(
        fontSize: 13,
        fontWeight: FontWeight.w500,
        height: 1.5,
        color: color ?? textLight,
      );

  /// Analysis title: 16px, w700.
  static TextStyle analysisTitle([Color? color]) => GoogleFonts.inter(
        fontSize: 16,
        fontWeight: FontWeight.w700,
        color: color ?? text,
      );

  /// Analysis body: 14px.
  static TextStyle analysisBody([Color? color]) => GoogleFonts.inter(
        fontSize: 14,
        color: color ?? textLight,
      );

  // ══════════════════════════════════════════════
  //  METRIC LABEL
  // ══════════════════════════════════════════════
  static TextStyle metricLabel([Color? color]) => GoogleFonts.inter(
        fontSize: fsCaption,
        fontWeight: FontWeight.w700,
        letterSpacing: 0.8,
        color: color ?? textLight,
      );

  /// Large metric value (e.g. "+42" for temperature).
  static TextStyle metricValueLarge({
    Color? color,
    double size = 28,
  }) =>
      GoogleFonts.inter(
        fontSize: size,
        fontWeight: FontWeight.w800,
        letterSpacing: -0.5,
        color: color ?? text,
      );

  // ══════════════════════════════════════════════
  //  CARD DECORATION
  // ══════════════════════════════════════════════

  /// Decorative top bar gradient (Design Bible Part 7 — ::before).
  static const Color cardTopBarStart = Color(0xFF6FA7D6);
  static const Color cardTopBarEnd = Color(0xFF4E6D8D);
  static const double cardTopBarHeight = 5;

  /// Default card decoration: off-white bg, 22px radius, soft shadow, border.
  static BoxDecoration get cardDecoration => BoxDecoration(
        color: card,
        borderRadius: cardRadius,
        border: Border.all(color: border),
      );

  /// Hero card decoration: same base + min-height handled by HeroBlock widget.
  static BoxDecoration get heroCardDecoration => BoxDecoration(
        color: card,
        borderRadius: cardRadius,
        border: Border.all(color: border),
      );

  /// Dark card decoration (for Hero block / special cards).
  static BoxDecoration darkCardDecoration({
    Color bgColor = const Color(0xFF1E2022),
  }) =>
      BoxDecoration(
        color: bgColor,
        borderRadius: cardRadius,
        boxShadow: shadowSoft,
      );

  // ══════════════════════════════════════════════
  //  GRADIENT HELPERS
  // ══════════════════════════════════════════════

  /// Radial glow gradient for the Guardian aura.
  static RadialGradient guardianAuraGradient(Color glowColor) =>
      RadialGradient(
        center: const Alignment(0, 0),
        radius: 0.7,
        colors: [
          glowColor.withValues(alpha: 0.15),
          glowColor.withValues(alpha: 0.05),
          Colors.transparent,
        ],
      );

  // ══════════════════════════════════════════════
  //  SHARED STYLES
  // ══════════════════════════════════════════════

  /// Thin horizontal divider line (border color).
  static const Widget divider = Divider(
    height: 1,
    color: border,
    thickness: 1,
  );

  /// Small phase badge (pill shape).
  static BoxDecoration phaseBadge(Color phaseColor) => BoxDecoration(
        color: phaseColor.withValues(alpha: 0.12),
        borderRadius: BorderRadius.circular(999),
        border: Border.all(color: phaseColor.withValues(alpha: 0.3)),
      );

  /// Bottom metric bar decoration (dark glassmorphic strip).
  static BoxDecoration get bottomMetricBarDecoration => BoxDecoration(
        color: const Color(0xFF1E2022),
        borderRadius: BorderRadius.circular(radius),
        boxShadow: shadowSoft,
      );
}

