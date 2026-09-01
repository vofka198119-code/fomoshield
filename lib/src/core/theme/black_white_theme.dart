import 'package:flutter/material.dart';
import 'reference/black_white_colors.dart';

// ---------------------------------------------------------------------------
// Black & White — admin-only preview theme (grayscale + our own red/green
// indicator colors, kept unchanged). PLACEHOLDER — only [background] is a
// deliberate first pass; everything else here is a stopgap so the theme is
// selectable and usable while the real values get tuned against the Home
// screen, same molecule-by-molecule process as Luxury Gold.
// ---------------------------------------------------------------------------

abstract final class BlackWhiteTheme {
  BlackWhiteTheme._();

  static const background = bwBlack;

  /// Screen backdrop — vertical, light top ("Pearl White") to dark bottom
  /// ("Slate"). REVISED (2026-09-01, was diagonal Silver Grey → Slate) —
  /// shared direction convention across Black & White / Light Lime /
  /// Midnight Sea; Light Lime is the locked-in reference for this
  /// convention.
  static const backgroundGradient = LinearGradient(
    begin: Alignment.topCenter,
    end: Alignment.bottomCenter,
    colors: [bwGradientLight, bwGradientDark],
  );

  /// Ambient top-right glow — soft off-white, matches the grayscale
  /// identity (no color introduced).
  static const backgroundGlow = bwWhite;

  static const card = bwCharcoal;
  static const borderStroke = bwSlate;
  static const accentPrimary = bwWhite;
  static const accentSecondary = bwSilver;
  static const textHeader = bwHeaderText;
  static const textBody = bwBodyText;
}
