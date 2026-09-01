import 'package:flutter/material.dart';
import 'reference/midnight_sea_colors.dart';

// ---------------------------------------------------------------------------
// Midnight Sea — admin-only preview theme (deep navy + teal accent).
// PLACEHOLDER — only [background] is a deliberate first pass; everything
// else here is a stopgap so the theme is selectable and usable while the
// real values get tuned against the Home screen, same molecule-by-molecule
// process as Luxury Gold.
// ---------------------------------------------------------------------------

abstract final class MidnightSeaTheme {
  MidnightSeaTheme._();

  static const background = msNavy;

  /// Screen backdrop — vertical, light top ("Navy") to dark bottom
  /// ("Obsidian"). REVISED (2026-09-01, was diagonal Sapphire → Obsidian)
  /// — shared direction convention across Black & White / Light Lime /
  /// Midnight Sea; Light Lime is the locked-in reference for this
  /// convention.
  static const backgroundGradient = LinearGradient(
    begin: Alignment.topCenter,
    end: Alignment.bottomCenter,
    colors: [msGradientLight, msGradientDark],
  );

  /// Ambient top-right glow — bright aqua, echoes the accent.
  static const backgroundGlow = msAqua;

  static const card = msDeepBlue;
  static const borderStroke = msSlateBlue;
  static const accentPrimary = msTeal;
  static const accentSecondary = msAqua;
  static const textHeader = msHeaderText;
  static const textBody = msBodyText;
}
