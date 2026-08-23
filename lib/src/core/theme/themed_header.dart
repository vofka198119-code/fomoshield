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

Widget themedHeaderText(
  String text,
  AppPalette palette,
  TextStyle baseStyle,
) {
  final child = Text(
    text,
    style: baseStyle.copyWith(
      color: palette.titleGradient != null
          ? Colors.white
          : palette.accentPrimary,
      shadows: palette.titleShadow != null ? [palette.titleShadow!] : null,
    ),
  );
  if (palette.titleGradient == null) return child;
  return ShaderMask(
    blendMode: BlendMode.modulate,
    shaderCallback: (bounds) => palette.titleGradient!.createShader(bounds),
    child: child,
  );
}

Widget themedHeaderIcon(
  IconData icon,
  AppPalette palette, {
  double size = 24,
}) {
  final child = Icon(
    icon,
    size: size,
    color: palette.titleGradient != null
        ? Colors.white
        : palette.accentPrimary,
    shadows: palette.titleShadow != null ? [palette.titleShadow!] : null,
  );
  if (palette.titleGradient == null) return child;
  return ShaderMask(
    blendMode: BlendMode.modulate,
    shaderCallback: (bounds) => palette.titleGradient!.createShader(bounds),
    child: child,
  );
}
