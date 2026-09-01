import 'package:flutter/material.dart';
import 'reference/light_lime_colors.dart';

// ---------------------------------------------------------------------------
// Light Lime — admin-only preview theme (off-white + lime green accent).
// PLACEHOLDER — only [background] is a deliberate first pass; everything
// else here is a stopgap so the theme is selectable and usable while the
// real values get tuned against the Home screen, same molecule-by-molecule
// process as Luxury Gold.
// ---------------------------------------------------------------------------

abstract final class LightLimeTheme {
  LightLimeTheme._();

  static const background = llCream;

  /// Screen backdrop — vertical, light top ("Pearl White") to dark bottom
  /// ("Pistachio Green"). LOCKED IN (2026-09-01) — the reference gradient:
  /// this is the exact look the other two admin themes' backdrops now
  /// follow (vertical, light-top/dark-bottom), just with their own colors.
  static const backgroundGradient = LinearGradient(
    begin: Alignment.topCenter,
    end: Alignment.bottomCenter,
    colors: [llGradientLight, llGradientDark],
  );

  static const card = llCard;
  static const borderStroke = llBorder;
  static const accentPrimary = llLime;
  static const accentSecondary = llLimeBright;
  static const textHeader = llHeaderText;
  static const textBody = llBodyText;
}
