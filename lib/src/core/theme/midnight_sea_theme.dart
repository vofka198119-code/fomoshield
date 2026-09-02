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
  /// convention (even 2-stop spread, same as here — the tightened-stops
  /// attempt was reverted).
  static const backgroundGradient = LinearGradient(
    begin: Alignment.topCenter,
    end: Alignment.bottomCenter,
    colors: [msGradientLight, msGradientDark],
  );

  /// Widget card background — REVISED (2026-09-01, was horizontal
  /// left→right), first molecule: vertical, light top ("#35577D") to
  /// dark bottom ("#141E30"). Text/border are untouched by this — still
  /// the flat placeholders below.
  static const cardGradient = LinearGradient(
    begin: Alignment.topCenter,
    end: Alignment.bottomCenter,
    colors: [msCardGradientTop, msCardGradientBottom],
  );

  /// Widget border — LOCKED IN (2026-09-01): vertical, light top
  /// ("#4EA4CC") to dark bottom ("#4E6A9C"), grey-blue tones. A brief
  /// pale-blue highlight is layered right at the top edge (stop 0 → 0.12)
  /// to read as a metallic glint, then falls straight into the normal
  /// top→bottom blend — deliberately a short band, not a wash over the
  /// whole border.
  static const borderGradient = LinearGradient(
    begin: Alignment.topCenter,
    end: Alignment.bottomCenter,
    colors: [msBorderHighlight, msBorderGradientTop, msBorderGradientBottom],
    stops: [0.0, 0.12, 1.0],
  );

  /// Card-lift "shadow" — REVISED (2026-09-01, was a dark "#06141B" drop
  /// shadow): a dark color reads as no contrast at all against an
  /// already-dark card/background, same reason Luxury Gold's cardGlow
  /// isn't a dark shadow either — it's a soft glow in the theme's own
  /// accent (teal) instead.
  static BoxShadow cardGlow({double opacity = 0.25}) => BoxShadow(
    color: accentPrimary.withValues(alpha: opacity),
    offset: const Offset(0, 3),
    blurRadius: 4,
  );

  static const card = msDeepBlue;
  static const borderStroke = msSlateBlue;
  static const accentPrimary = msTeal;
  static const accentSecondary = msAqua;
  static const textHeader = msHeaderText;
  static const textBody = msBodyText;

  /// Market Clock dial face — same radial shape (light center, dark edge)
  /// as MarketClockDial's own default green instrument-panel gradient,
  /// swapped to this theme's card tones (see [cardGradient]'s doc comment
  /// for why those two specific colors). A 3-stop version with
  /// [msBorderHighlight] centered here (matching [borderGradient]'s
  /// metallic glint) was tried first — on a RADIAL gradient a bright
  /// center stop reads as a distinct glowing disc behind the hands, not a
  /// directional highlight, so it was dropped (confirmed on-device
  /// 2026-09-02).
  static const dialFaceGradient = RadialGradient(
    center: Alignment(0, -0.16),
    radius: 0.9,
    colors: [msCardGradientTop, msCardGradientBottom],
  );

  /// Market Clock dial ring — vertical, top ([msAqua], a couple shades
  /// lighter) to bottom ([msTeal], the base accent) — same top-lit
  /// convention as [borderGradient], applied to the ring's own stroke
  /// shader instead of a straight edge.
  static const dialRingGradient = LinearGradient(
    begin: Alignment.topCenter,
    end: Alignment.bottomCenter,
    colors: [msAqua, msTeal],
  );

  /// Inner "window"/button fill app-wide — radial, light center to dark
  /// edge, same shape as [cardGradient]'s own light-top/dark-bottom idea
  /// but radial and in its own teal-tinted tones so windows/buttons read
  /// as a distinct layer from the outer card. See [AppPalette.windowGradient]
  /// / [AppPalette.buttonGradient]'s doc comments for the full list of
  /// call sites this drives (Portfolio/Shield Signal CTA buttons, every
  /// widget's inner stat/mood window, themedAddWidgetsButton,
  /// themedDarkCtaButtonShell, etc.).
  static const windowGradient = RadialGradient(
    center: Alignment(0, -0.3),
    radius: 1.2,
    colors: [msWindowGradientLight, msWindowGradientDark],
  );
}
