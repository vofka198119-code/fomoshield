import 'package:flutter/material.dart';
import 'theme_v2.dart';
import 'luxury_gold_theme.dart';
import 'black_white_theme.dart';
import 'light_lime_theme.dart';
import 'midnight_sea_theme.dart';
import 'theme_variant_provider.dart';

// ---------------------------------------------------------------------------
// AppPalette — one resolved set of theme tokens for whichever
// [AppThemeVariant] is active. Screens should read [resolveAppPalette]
// once and use its fields instead of branching on the variant themselves —
// adding a future theme #3 is then one new enum value in
// theme_variant_provider.dart + one new palette instance + one switch arm
// below, with zero changes needed at any call site.
// ---------------------------------------------------------------------------

class AppPalette {
  /// Full-screen backdrop override. Null means "don't override" — used by
  /// [standard], which relies on the app's existing global background
  /// gradient (painted once in main.dart) rather than a flat color.
  final Color? background;

  /// Preferred over [background] when non-null — a gradient backdrop
  /// instead of a flat fill.
  final Gradient? backgroundGradient;
  final Color card;

  /// Preferred over [card] when non-null — a gradient card fill instead
  /// of a flat color (Luxury Gold's molecule-4 decision: cards reuse the
  /// same gradient as the screen background). Not yet consumed anywhere —
  /// molecule 4 (widget card background) is still deferred.
  final Gradient? cardGradient;
  final Color border;

  /// Gradient card border (Luxury Gold reuses [titleGradient] itself, per
  /// the 2026-08-23 decision — same metallic sheen on borders as on
  /// titles). Null means "plain solid [border] color", same as before
  /// this existed.
  final Gradient? borderGradient;

  /// Main accent — buttons, active icons, key stats.
  final Color accentPrimary;

  /// Secondary accent — gradients, less prominent highlights.
  final Color accentSecondary;
  final Color textHeader;
  final Color textBody;

  /// Metallic-sheen treatment for header text/icons (e.g. the Home AppBar
  /// title + notification bell) — both null means "just paint solid
  /// [accentPrimary]", same as before this existed.
  final Gradient? titleGradient;
  final Shadow? titleShadow;

  /// Null where the theme doesn't define a button gradient/glow yet.
  final Gradient? buttonGradient;
  final BoxShadow? glowShadow;

  /// Card-lift shadow — same recipe as the splash screen's wordmark
  /// shadow, gold instead of black (see LuxuryGoldTheme.cardGlow's doc
  /// comment). Null means no extra shadow beyond whatever the card's own
  /// decoration provides.
  final BoxShadow? cardGlow;

  /// Inner "window"/panel background (stat tiles, mood/explanation boxes
  /// nested inside a widget) — deliberately separate from [cardGradient],
  /// which is the widget's own OUTER card only. Null means "no opinion" —
  /// callers fall back to whatever pre-Luxury look they already had (e.g.
  /// ShieldSignalWidget's `darkCardGradient()` stopgap), same as before
  /// this field existed.
  final Gradient? windowGradient;

  /// Header/section divider — a horizontal left-to-right gradient (light
  /// gold → dark gold for Luxury Gold), companion to [borderGradient]'s
  /// vertical version. Null means "plain flat divider," same as before
  /// this field existed.
  final Gradient? dividerGradient;

  const AppPalette({
    this.background,
    this.backgroundGradient,
    required this.card,
    this.cardGradient,
    required this.border,
    this.borderGradient,
    required this.accentPrimary,
    required this.accentSecondary,
    required this.textHeader,
    required this.textBody,
    this.titleGradient,
    this.titleShadow,
    this.buttonGradient,
    this.glowShadow,
    this.cardGlow,
    this.windowGradient,
    this.dividerGradient,
  });

  static const standard = AppPalette(
    background: null,
    card: ThemeV2.surface,
    border: ThemeV2.divider,
    accentPrimary: ThemeV2.primary,
    accentSecondary: ThemeV2.primary,
    textHeader: ThemeV2.textPrimary,
    textBody: ThemeV2.textSecondary,
  );

  static AppPalette get luxuryGold => AppPalette(
    background: LuxuryGoldTheme.background,
    backgroundGradient: LuxuryGoldTheme.backgroundGradient,
    card: LuxuryGoldTheme.card,
    cardGradient: LuxuryGoldTheme.cardGradient,
    border: LuxuryGoldTheme.borderStroke,
    borderGradient: LuxuryGoldTheme.titleGradient,
    accentPrimary: LuxuryGoldTheme.accentGold,
    accentSecondary: LuxuryGoldTheme.accentGoldBright,
    textHeader: LuxuryGoldTheme.textHeader,
    textBody: LuxuryGoldTheme.textBody,
    titleGradient: LuxuryGoldTheme.titleGradient,
    titleShadow: LuxuryGoldTheme.titleShadow,
    buttonGradient: LuxuryGoldTheme.buttonGradient,
    glowShadow: LuxuryGoldTheme.glowShadow(),
    cardGlow: LuxuryGoldTheme.cardGlow(),
    windowGradient: LuxuryGoldTheme.windowGradient,
    dividerGradient: LuxuryGoldTheme.dividerGradient,
  );

  static const blackWhite = AppPalette(
    background: BlackWhiteTheme.background,
    backgroundGradient: BlackWhiteTheme.backgroundGradient,
    card: BlackWhiteTheme.card,
    border: BlackWhiteTheme.borderStroke,
    accentPrimary: BlackWhiteTheme.accentPrimary,
    accentSecondary: BlackWhiteTheme.accentSecondary,
    textHeader: BlackWhiteTheme.textHeader,
    textBody: BlackWhiteTheme.textBody,
  );

  static const lightLime = AppPalette(
    background: LightLimeTheme.background,
    backgroundGradient: LightLimeTheme.backgroundGradient,
    card: LightLimeTheme.card,
    border: LightLimeTheme.borderStroke,
    accentPrimary: LightLimeTheme.accentPrimary,
    accentSecondary: LightLimeTheme.accentSecondary,
    textHeader: LightLimeTheme.textHeader,
    textBody: LightLimeTheme.textBody,
  );

  static AppPalette get midnightSea => AppPalette(
    background: MidnightSeaTheme.background,
    backgroundGradient: MidnightSeaTheme.backgroundGradient,
    card: MidnightSeaTheme.card,
    cardGradient: MidnightSeaTheme.cardGradient,
    border: MidnightSeaTheme.borderStroke,
    borderGradient: MidnightSeaTheme.borderGradient,
    accentPrimary: MidnightSeaTheme.accentPrimary,
    accentSecondary: MidnightSeaTheme.accentSecondary,
    textHeader: MidnightSeaTheme.textHeader,
    textBody: MidnightSeaTheme.textBody,
    cardGlow: MidnightSeaTheme.cardGlow(),
  );
}

/// The single switch point for adding a new theme — everything else
/// (screens, the theme picker) reads through this or [AppThemeVariant.values].
AppPalette resolveAppPalette(AppThemeVariant variant) => switch (variant) {
  AppThemeVariant.standard => AppPalette.standard,
  AppThemeVariant.luxuryGold => AppPalette.luxuryGold,
  AppThemeVariant.blackWhite => AppPalette.blackWhite,
  AppThemeVariant.lightLime => AppPalette.lightLime,
  AppThemeVariant.midnightSea => AppPalette.midnightSea,
};
