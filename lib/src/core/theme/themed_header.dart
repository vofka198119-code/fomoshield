import 'package:flutter/material.dart';
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
  TextStyle baseStyle,
) {
  return themedGoldGradient(
    Text(
      text,
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

Widget themedHeaderIcon(
  IconData icon,
  AppPalette palette, {
  double size = 24,
}) {
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
// index price, a holding's market value, a portfolio balance) once a
// theme defines [AppPalette.titleGradient]: the same metallic gold sheen
// used on header titles. Confirmed 2026-08-23 on Shield Signal's index
// price cell as the pattern to replicate at every other plain-price call
// site in the app.
//
// Do NOT use this for a price/percent/amount that already carries its own
// up-down color (P&L, change $, change %, any gain/loss figure) — those
// keep [ThemeV2.success]/[ThemeV2.loss] (or the palette equivalent)
// untouched; the green/red signal is the point there, not gold.
// ---------------------------------------------------------------------------

Widget themedPriceText(String text, AppPalette palette, TextStyle baseStyle) {
  return themedGoldGradient(
    Text(text, style: baseStyle.copyWith(color: Colors.white)),
    palette,
  );
}
