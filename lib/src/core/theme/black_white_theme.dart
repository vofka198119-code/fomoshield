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

  /// Card/button fill gradient — a subtle vertical lift instead of flat
  /// [bwCardWhite]: white top → light-graphite ([bwCardGradientBottom],
  /// lightened one tone same day per user polish request — see its own
  /// doc comment) bottom, kept light enough that near-black text
  /// ([textHeader]/[onButton]) stays comfortably readable at the bottom
  /// edge. Drives both [AppPalette.cardGradient] (every white card) and
  /// [AppPalette.buttonGradient] (CTA buttons — see [onButton]).
  static const cardGradient = LinearGradient(
    begin: Alignment.topCenter,
    end: Alignment.bottomCenter,
    colors: [bwCardWhite, bwCardGradientBottom],
  );

  /// Text/icon color for content on [cardGradient] when used as a button
  /// fill (see [AppPalette.onButton]) — near-black, same reasoning as
  /// [accentPrimary]/[textHeader] on the white outer card.
  static const onButton = bwBlack;

  /// Disclaimer/fine-print text (see [AppPalette.disclaimerColor]) —
  /// near-black, since the shared muted-gray-at-50%-alpha treatment every
  /// other theme uses read too faint against this theme's white cards.
  static const disclaimerColor = bwBlack;

  /// Card-lift shadow — graphite-tinted (this theme's own [bwSlate]),
  /// unlike Luxury Gold/Midnight Sea's accent-colored glow: those themes
  /// have DARK cards, where a dark shadow reads as zero contrast, so they
  /// use their accent color instead. Black & White's cards are light, so a
  /// graphite drop shadow is the normal "card lift" look — same offset/
  /// blur recipe as every other theme's cardGlow.
  static BoxShadow cardGlow({double opacity = 0.25}) => BoxShadow(
    color: bwSlate.withValues(alpha: opacity),
    offset: const Offset(0, 3),
    blurRadius: 4,
  );

  static const borderStroke = bwSlate;

  /// Gradient card/window/button border ring — ADDED (2026-09-05), same
  /// "themedBorder gradient ring" treatment Luxury Gold pioneered, this
  /// theme's own graphite tones per explicit request: steel top
  /// ([bwSteel]) → dark graphite bottom ([bwCharcoal]), plus a brief
  /// [bwSilver] glint layered right at the top edge (stop 0 → 0.12, same
  /// technique as Midnight Sea's [MidnightSeaTheme.borderGradient] — a
  /// short highlight band, not a wash over the whole border). REVISED
  /// same day: the glint was [bwWhite] and the base [bwSilver] itself —
  /// both too close to the near-white card/background, so the ring
  /// blended in and read as invisible; darkened one step each ([bwSilver]
  /// glint, [bwSteel] base) to stay a visible ring. Wired into
  /// [AppPalette.borderGradient], which `themedBorder()`/`CardFrame` both
  /// already consume — applies to every card, window, and CTA button
  /// app-wide with zero further plumbing.
  static const borderGradient = LinearGradient(
    begin: Alignment.topCenter,
    end: Alignment.bottomCenter,
    colors: [bwSilver, bwSteel, bwCharcoal],
    stops: [0.0, 0.12, 1.0],
  );

  /// Header/title text + icons sitting on the (now white) outer card —
  /// near-black, LOCKED IN (2026-09-02) per explicit request over
  /// [bwSlate] for max black-and-white contrast. NOT the color used inside
  /// [windowGradient] panels — see [onWindow] for that.
  static const accentPrimary = bwBlack;
  static const accentSecondary = bwSlate;
  static const textHeader = bwBlack;
  static const textBody = bwSlate;

  /// Inner "window"/panel background (stat tiles, price cells, mood/
  /// explanation boxes — the ones Standard renders dark green via
  /// `darkCardGradient()`/`darkCardDecoration()`). REVISED (2026-09-05):
  /// unified with the outer card — same [cardGradient] (white top → light
  /// graphite bottom) instead of a separate dark radial, per explicit
  /// request to bring every "window" to one consistent light style. Was
  /// `RadialGradient([bwCharcoal, bwBlack])` (2026-09-02); before that, a
  /// vertical light-glint→black attempt broke Market Clock's title text
  /// (see git history) — moot now that this is fully light, but the
  /// lesson stands for [onWindow]: anything that assumed a DARK window
  /// and hardcoded a light color unconditionally (not gated on
  /// [onWindow]) needs auditing, since the window is light now too.
  static const windowGradient = cardGradient;

  /// Text/icon color for content sitting on [windowGradient] — REVISED
  /// (2026-09-05): near-black, now that [windowGradient] itself is light
  /// (was [bwWhite], back when this was a dark radial panel). See
  /// [AppPalette.onWindow]'s doc comment for why this theme sets it
  /// explicitly rather than relying on the null fallback.
  static const onWindow = bwBlack;
}
