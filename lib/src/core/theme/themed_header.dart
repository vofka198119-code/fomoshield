import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'app_palette.dart';

// ---------------------------------------------------------------------------
// Themed header text/icon — the canonical treatment for EVERY widget
// title, card/window header, and icon across the app once a theme defines
// [AppPalette.titleGradient]/[titleShadow] (decision confirmed on the Home
// AppBar title + notification bell, Luxury Gold theme, 2026-08-23):
// a metallic gradient sheen (lighter highlight at the top, fading to the
// base accent) plus a soft shadow simulating a top-left light source.
//
// Any screen/widget adding a title or icon under a theme that supports
// this should go through [themedHeaderText]/[themedHeaderIcon] instead of
// hand-rolling its own ShaderMask — that's what makes rolling this out to
// the rest of the app (molecule 3+) a drop-in swap instead of re-deriving
// the effect per widget. For a theme that doesn't define titleGradient
// (e.g. Standard), these are a no-op: plain solid-color text/icon, exactly
// as before this existed.
// ---------------------------------------------------------------------------

/// Wraps [child] in the theme's metallic gold ShaderMask (same recipe
/// [themedHeaderText]/[themedHeaderIcon] use), or returns it unchanged
/// when the palette doesn't define one. [child] must already be colored
/// white (or near-white) — `BlendMode.modulate` multiplies the gradient
/// through whatever color is underneath, so anything darker mutes it.
Widget themedGoldGradient(Widget child, AppPalette palette) {
  if (palette.titleGradient == null) return child;
  return ShaderMask(
    blendMode: BlendMode.modulate,
    shaderCallback: (bounds) => palette.titleGradient!.createShader(bounds),
    child: child,
  );
}

Widget themedHeaderText(
  String text,
  AppPalette palette,
  TextStyle baseStyle, {
  TextOverflow? overflow,
  int? maxLines,
}) {
  return themedGoldGradient(
    Text(
      text,
      overflow: overflow,
      maxLines: maxLines,
      style: baseStyle.copyWith(
        color: palette.titleGradient != null
            ? Colors.white
            : palette.accentPrimary,
        shadows: palette.titleShadow != null ? [palette.titleShadow!] : null,
      ),
    ),
    palette,
  );
}

// ---------------------------------------------------------------------------
// Themed back button — the canonical AppBar `leading` for every screen.
// The root ThemeData's AppBarTheme.foregroundColor is a fixed near-black
// (ThemeV2.textPrimary) regardless of theme variant — invisible against
// Luxury Gold's dark background if an AppBar omits `leading` and falls
// back to Flutter's auto-generated back button. Use this everywhere an
// AppBar needs a back arrow instead of leaving `leading` unset or
// hand-rolling the IconButton per screen.
// ---------------------------------------------------------------------------

Widget themedBackButton(
  BuildContext context,
  AppPalette palette, {
  VoidCallback? onPressed,
}) {
  return IconButton(
    icon: Icon(Icons.arrow_back_rounded, color: palette.accentPrimary),
    onPressed: onPressed ?? () => context.pop(),
  );
}

Widget themedHeaderIcon(IconData icon, AppPalette palette, {double size = 24}) {
  return themedGoldGradient(
    Icon(
      icon,
      size: size,
      color: palette.titleGradient != null
          ? Colors.white
          : palette.accentPrimary,
      shadows: palette.titleShadow != null ? [palette.titleShadow!] : null,
    ),
    palette,
  );
}

// ---------------------------------------------------------------------------
// Themed price text — the canonical treatment for EVERY neutral price
// figure app-wide (a $ value with no up/down meaning of its own — an
// index price, a holding's market value, a portfolio balance): flat
// [AppPalette.textHeader] — the SAME color/role as a company/instrument
// name (see Watchlist's tile). REVISED 2026-08-25: this used to be a gold
// ShaderMask sheen (matching header titles); user asked to drop the gold
// and make every sum read as plain cream/textHeader instead, everywhere,
// including on an unconditionally-dark panel — don't re-add the gradient.
//
// Do NOT use this for a price/percent/amount that already carries its own
// up-down color (P&L, change $, change %, any gain/loss figure) — those
// keep [ThemeV2.success]/[ThemeV2.loss] (or the palette equivalent)
// untouched; the green/red signal is the point there, not this treatment.
// ---------------------------------------------------------------------------

Widget themedPriceText(
  String text,
  AppPalette palette,
  TextStyle baseStyle, {
  // Color used only when the palette has NO titleGradient (Standard
  // theme, or a future theme that doesn't opt in) — under a theme that
  // does (Luxury Gold), textHeader always wins regardless of this, since
  // Luxury's textHeader (warm champagne) reads fine on any of its
  // surfaces, dark-always-panel included. Defaults to
  // [AppPalette.textHeader], correct for the common case (text sitting on
  // a card that's light under Standard). A caller whose text sits on an
  // unconditionally-dark panel in BOTH themes (e.g. Shield Signal's price
  // cell) MUST override this to that panel's own correct Standard-theme
  // color (e.g. white) — see this file's "always-dark panel" pattern note
  // in the Luxury Gold project memory.
  Color? fallbackColor,
}) {
  final color = palette.titleGradient != null
      ? palette.textHeader
      : (fallbackColor ?? palette.textHeader);
  return Text(text, style: baseStyle.copyWith(color: color));
}
