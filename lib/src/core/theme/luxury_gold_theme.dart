import 'package:flutter/material.dart';
import 'reference/luxury_gold_colors.dart';

// ---------------------------------------------------------------------------
// Luxury Gold — admin-only preview theme (dark obsidian + metallic gold).
// Maps the raw reference swatch (reference/luxury_gold_colors.dart) onto UI
// roles. Built molecule by molecule against the Home screen as the
// reference before rolling out app-wide: (1) background, (2) widget
// border, (3) header/body text, (4) widget card background. Only (1) is
// wired up so far — the rest of these tokens exist already so later passes
// just reference them instead of re-deriving hex values.
// ---------------------------------------------------------------------------

abstract final class LuxuryGoldTheme {
  LuxuryGoldTheme._();

  /// Primary background — "Dark Obsidian".
  static const background = darkObsidian;

  /// Lighter tone used at the "light end" of both [backgroundGradient]
  /// and [cardGradient] — shared so the two gradients read as the same
  /// family of light, just arranged differently (linear top→bottom for
  /// the screen, radial center→edge for cards).
  static const _lightTone = Color(0xFF1C1E22);

  /// Screen backdrop — a touch lighter at the top fading into [background],
  /// for a soft premium sheen instead of a flat fill.
  static const backgroundGradient = LinearGradient(
    begin: Alignment.topCenter,
    end: Alignment.bottomCenter,
    colors: [_lightTone, background],
  );

  /// Widget/card background — LOCKED IN (2026-08-23): same two tones and
  /// direction as [backgroundGradient] (top→bottom, light→dark), not a
  /// flat "Dark Graphite" fill or the earlier radial (center→edge)
  /// attempt. This is the outer widget card only — inner "windows"
  /// (stat tiles, panels) and buttons each get their OWN gradient
  /// (separate, not yet decided) rather than reusing this one. Molecule
  /// 4, pilot: ShieldSignalWidget/CardFrame.
  static const cardGradient = backgroundGradient;

  /// Cards/blocks — "Dark Graphite". Kept for any spot that genuinely
  /// needs a flat fill (e.g. a small chip/tag) rather than the gradient
  /// above — prefer [cardGradient] for actual card backgrounds.
  static const card = darkGraphite;

  /// Center tone for [windowGradient] — a step lighter than [_lightTone]
  /// (the card gradient's lightest end) so an inner window reads as
  /// sitting visibly above the card, not blending into it. Not part of
  /// the canonical 7-swatch reference — a UI-role-only tweak, same as
  /// [_titleHighlight].
  static const _windowCenter = Color(0xFF262B32);

  /// Inner "window"/panel background (stat tiles, mood/explanation boxes)
  /// — LOCKED IN (2026-08-23): radial, light graphite center fading to
  /// Dark Graphite ([card]) at the edge. Deliberately its own gradient,
  /// separate from [cardGradient] — nested panels are meant to read as a
  /// lighter surface floating above the card, not a repeat of the card's
  /// own background.
  static const windowGradient = RadialGradient(
    center: Alignment.center,
    radius: 1.1,
    colors: [_windowCenter, card],
  );

  /// Borders/strokes — "Bronze Stroke".
  static const borderStroke = bronzeStroke;

  /// Main accent / buttons — "Metallic Gold". Use sparingly (~10% of the
  /// screen — CTAs, active icons, key stats), per the 60/30/10 split this
  /// palette was specified with.
  static const accentGold = metallicGold;

  /// Secondary accent / gradients — "Bright Gold".
  static const accentGoldBright = brightGold;

  /// Headers / accent text — "Warm Champagne".
  static const textHeader = warmChampagne;

  /// Body text — "Muted Silver".
  static const textBody = mutedSilver;

  /// Button gradient: Bright Gold (top) → deep gold (bottom) at 135°.
  static const buttonGradient = LinearGradient(
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
    colors: [accentGoldBright, buttonGradientEnd],
  );

  /// Soft gold glow for buttons/key blocks — 20% opacity, 20px blur,
  /// centered (no offset).
  static BoxShadow glowShadow({double opacity = 0.2}) => BoxShadow(
    color: accentGold.withValues(alpha: opacity),
    blurRadius: 20,
  );

  /// Card-lift shadow — started as the exact splash screen "FOMO" wordmark
  /// recipe (`offset: Offset(2, 3), blurRadius: 4, color: Colors.black @
  /// 25%`), gold instead of black. Decision (2026-08-24): dropped the
  /// rightward component — with a widget's own right-edge padding tight
  /// enough (22px), the shadow's right side butted straight into it and
  /// got clipped by a hard edge instead of fading out. Straight-down glow
  /// avoids that regardless of how tight a card's surrounding padding is.
  static BoxShadow cardGlow({double opacity = 0.25}) => BoxShadow(
    color: accentGold.withValues(alpha: opacity),
    offset: const Offset(0, 3),
    blurRadius: 4,
  );

  /// Highlight for the very top of [titleGradient] — brighter than
  /// [accentGoldBright] itself, since the canonical 7-swatch reference
  /// doesn't have anything light enough for a true top-of-lettering
  /// glint. Not part of the canonical reference swatch — a UI-role-only
  /// tweak, tune here rather than in reference/luxury_gold_colors.dart.
  static const _titleHighlight = Color(0xFFFAE3AA);

  /// Metallic sheen for header/title text — a lighter highlight at the
  /// top fading to the base gold, mimicking light hitting embossed
  /// lettering. Pair with [titleShadow] via a ShaderMask (blend mode
  /// modulate) over a white-colored Text.
  static const titleGradient = LinearGradient(
    begin: Alignment.topCenter,
    end: Alignment.bottomCenter,
    colors: [_titleHighlight, accentGold],
  );

  /// Soft dark shadow simulating a light source from top-left — offset
  /// down-right, lifts header text off the dark background instead of
  /// letting it sit flat.
  static const titleShadow = Shadow(
    color: Color(0x73000000),
    offset: Offset(1.5, 1.5),
    blurRadius: 3,
  );

  /// Header/section divider — LOCKED IN (2026-08-23), opacity revised
  /// 2026-08-25: the same two-tone gold family as [titleGradient] (light
  /// gold → base gold), just rotated horizontal (left→right) instead of
  /// vertical, since a divider is a thin strip rather than lettering.
  /// Reuses [_titleHighlight]/[accentGold] rather than re-deriving new
  /// tones — same "border and title share one gradient definition"
  /// principle this theme has kept everywhere else. Both stops dropped to
  /// 30% opacity (was fully opaque) — applies uniformly everywhere
  /// [themedDivider] is used: header-title underlines AND inter-item list
  /// separators (e.g. between Watchlist rows) both read this same value.
  static Gradient get dividerGradient => LinearGradient(
    begin: Alignment.centerLeft,
    end: Alignment.centerRight,
    colors: [
      _titleHighlight.withValues(alpha: 0.3),
      accentGold.withValues(alpha: 0.3),
    ],
  );
}
