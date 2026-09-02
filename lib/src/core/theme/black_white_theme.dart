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

  /// Widget card background — LOCKED IN (2026-09-02): literal white, for
  /// every widget Standard renders light/off-white. Was [bwCharcoal]
  /// (dark) as a placeholder; [bwCharcoal]/[bwBlack] now serve
  /// [windowGradient] instead — the "instrument panel" widgets Standard
  /// renders dark green.
  static const card = bwCardWhite;
  static const borderStroke = bwSlate;

  /// Header/title text + icons sitting on the (now white) outer card —
  /// near-black, LOCKED IN (2026-09-02) per explicit request over
  /// [bwSlate] for max black-and-white contrast. NOT the color used inside
  /// [windowGradient] panels — see [onWindow] for that.
  static const accentPrimary = bwBlack;
  static const accentSecondary = bwSlate;
  static const textHeader = bwBlack;
  static const textBody = bwSlate;

  /// Inner "window"/panel background (stat tiles, price cells, mood/
  /// explanation boxes) — LOCKED IN (2026-09-02): the widgets Standard
  /// renders dark green (`darkCardGradient()`/`darkCardDecoration()`)
  /// become radial graphite-center-to-black-edge here, per explicit
  /// request. Same radius/structure as Luxury Gold's windowGradient
  /// (center lighter, edge darker), just this theme's own tones.
  static const windowGradient = RadialGradient(
    center: Alignment.center,
    radius: 1.1,
    colors: [bwCharcoal, bwBlack],
  );

  /// Text/icon color for content sitting on [windowGradient] — the
  /// existing off-white accent, reused here since [accentPrimary] above
  /// is now near-black (tuned for the white OUTER card instead). See
  /// [AppPalette.onWindow]'s doc comment for why this theme needs both.
  static const onWindow = bwWhite;
}
