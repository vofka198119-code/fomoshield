import 'package:flutter/material.dart';
import 'reference/graphite_colors.dart';

// ---------------------------------------------------------------------------
// Graphite — admin-only preview theme (matte near-black + graphite widget
// gradients + white/steel metallic accents). Replaces the earlier "Light
// Lime" placeholder entirely (2026-09-06, full redesign per explicit user
// spec, not an evolution of it — old lime palette abandoned, not tuned).
// First pass, not yet device-confirmed — same molecule-by-molecule caveat
// every other admin theme's first pass carried before its own polish pass.
// ---------------------------------------------------------------------------

abstract final class GraphiteTheme {
  GraphiteTheme._();

  static const background = grTarBlack;

  /// Screen backdrop — vertical, light top to dark ("tar") bottom, same
  /// shared direction convention every admin theme's backdrop uses.
  static const backgroundGradient = LinearGradient(
    begin: Alignment.topCenter,
    end: Alignment.bottomCenter,
    colors: [grBackgroundLight, grTarBlack],
  );

  static const card = grGraphiteBottom;

  /// Widget card background — EVERY widget without exception per spec: a
  /// graphite gradient a couple tones lighter than the tar-black backdrop
  /// at the bottom, a bit lighter again at the top ("низ на пару тонов
  /// светлее от фона, сверху чуть светлее"). Drives [AppPalette.cardGradient]
  /// AND (reused, same as Black & White/Midnight Sea) [AppPalette
  /// .windowGradient]/[AppPalette.buttonGradient] — one consistent graphite
  /// fill for outer cards, inner "instrument panel" windows, and buttons
  /// alike.
  static const cardGradient = LinearGradient(
    begin: Alignment.topCenter,
    end: Alignment.bottomCenter,
    colors: [grGraphiteTop, grGraphiteBottom],
  );

  static const borderStroke = grSteel;

  /// Widget border ring — white-steel gradient per spec ("окантовка
  /// виджитов градиент бело-стальной"): a brief white glint right at the
  /// top edge (stop 0 → 0.12, same short-band technique Black & White/
  /// Midnight Sea use), falling into steel, ending on a deeper steel base
  /// so the glint doesn't wash out over the whole border.
  static const borderGradient = LinearGradient(
    begin: Alignment.topCenter,
    end: Alignment.bottomCenter,
    colors: [grWhite, grSteel, grSteelDark],
    stops: [0.0, 0.12, 1.0],
  );

  /// Header/title text + icon sheen — a real white→steel gradient (not a
  /// flat white-on-white signal flag like Midnight Sea's), so every title/
  /// icon that runs through `themedGoldGradient`'s ShaderMask gets a visible
  /// metallic sheen instead of plain white. Being non-null still does
  /// double duty as this app's "dark-card theme, render white" flag (~15
  /// call sites — verdict/encyclopedia/search/order-entry/notifications
  /// body text, themedHeaderIcon's back/menu/bell/edit icons) — see
  /// AppPalette.midnightSea's titleGradient doc comment for the full list
  /// this flag drives. The old Light Lime placeholder this theme replaces
  /// never set it (staying null broke that exact flag, e.g. the
  /// Encyclopedia body-text contrast bug found in the 2026-09-05 audit) —
  /// this genuinely dark theme sets it for real instead.
  static const titleGradient = LinearGradient(
    begin: Alignment.topCenter,
    end: Alignment.bottomCenter,
    colors: [grWhite, grSteel],
  );

  static const accentPrimary = grWhite;
  static const accentSecondary = grSteel;

  /// All text white per spec ("тексты все белые") — both header and body,
  /// no muted-gray secondary tone.
  static const textHeader = grWhite;
  static const textBody = grWhite;

  static const onWindow = grWhite;
  static const onButton = grWhite;
  static const disclaimerColor = grWhite;

  /// Card-lift shadow — steel-tinted glow, same recipe as every other dark
  /// theme's cardGlow (accent-colored, not a dark drop shadow — a black
  /// shadow reads as zero contrast against an already-near-black card).
  static BoxShadow cardGlow({double opacity = 0.2}) => BoxShadow(
    color: grSteel.withValues(alpha: opacity),
    offset: const Offset(0, 3),
    blurRadius: 4,
  );

  /// Market Clock dial face — same shape (light-center radial) as every
  /// other theme's dial face, this theme's own graphite tones.
  static const dialFaceGradient = RadialGradient(
    center: Alignment(0, -0.16),
    radius: 0.9,
    colors: [grGraphiteTop, grGraphiteBottom],
  );

  /// Market Clock dial ring AND clock hands (reused for both — see
  /// market_clock_dial.dart's [MarketClockDial]) — white-steel gradient per
  /// spec ("часы и циферблат все белое... стрелки [и] кнопки в часах
  /// бело-стальной градиент").
  static const dialRingGradient = LinearGradient(
    begin: Alignment.topCenter,
    end: Alignment.bottomCenter,
    colors: [grWhite, grSteel],
  );
}
