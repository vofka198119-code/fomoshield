import 'package:flutter/material.dart';
import 'theme_v2.dart';
import 'luxury_gold_theme.dart';
import 'black_white_theme.dart';
import 'graphite_theme.dart';
import 'midnight_sea_theme.dart';
import 'theme_variant_provider.dart';

// ---------------------------------------------------------------------------
// AppPalette — one resolved set of theme tokens for whichever
// [AppThemeVariant] is active. Screens should read [resolveAppPalette]
// once and use its fields instead of branching on the variant themselves —
// adding a future theme #3 is then one new enum value in
// theme_variant_provider.dart + one new palette instance + one switch arm
// below, with zero changes needed at any call site.
// ---------------------------------------------------------------------------

class AppPalette {
  /// Full-screen backdrop override. Null means "don't override" — used by
  /// [standard], which relies on the app's existing global background
  /// gradient (painted once in main.dart) rather than a flat color.
  final Color? background;

  /// Preferred over [background] when non-null — a gradient backdrop
  /// instead of a flat fill.
  final Gradient? backgroundGradient;
  final Color card;

  /// Preferred over [card] when non-null — a gradient card fill instead
  /// of a flat color (Luxury Gold's molecule-4 decision: cards reuse the
  /// same gradient as the screen background). Not yet consumed anywhere —
  /// molecule 4 (widget card background) is still deferred.
  final Gradient? cardGradient;
  final Color border;

  /// Gradient card border (Luxury Gold reuses [titleGradient] itself, per
  /// the 2026-08-23 decision — same metallic sheen on borders as on
  /// titles). Null means "plain solid [border] color", same as before
  /// this existed.
  final Gradient? borderGradient;

  /// Main accent — buttons, active icons, key stats.
  final Color accentPrimary;

  /// Secondary accent — gradients, less prominent highlights.
  final Color accentSecondary;
  final Color textHeader;
  final Color textBody;

  /// Metallic-sheen treatment for header text/icons (e.g. the Home AppBar
  /// title + notification bell) — both null means "just paint solid
  /// [accentPrimary]", same as before this existed.
  final Gradient? titleGradient;
  final Shadow? titleShadow;

  /// Null where the theme doesn't define a button gradient/glow yet.
  final Gradient? buttonGradient;
  final BoxShadow? glowShadow;

  /// Card-lift shadow — same recipe as the splash screen's wordmark
  /// shadow, gold instead of black (see LuxuryGoldTheme.cardGlow's doc
  /// comment). Null means no extra shadow beyond whatever the card's own
  /// decoration provides.
  final BoxShadow? cardGlow;

  /// Inner "window"/panel background (stat tiles, mood/explanation boxes
  /// nested inside a widget) — deliberately separate from [cardGradient],
  /// which is the widget's own OUTER card only. Null means "no opinion" —
  /// callers fall back to whatever pre-Luxury look they already had (e.g.
  /// ShieldSignalWidget's `darkCardGradient()` stopgap), same as before
  /// this field existed.
  final Gradient? windowGradient;

  /// Text/icon color for content sitting on [windowGradient]. Null means
  /// "use [accentPrimary]/[textHeader] there too" — correct for a theme
  /// where the OUTER card is also dark (Luxury Gold: gold accent reads
  /// fine on both the card and the window). Needed once a theme's outer
  /// card is LIGHT while its window stays dark (Black & White: near-black
  /// accent/header text for the white card would vanish against the dark
  /// window) — set only where that mismatch exists.
  final Color? onWindow;

  /// Header/section divider — a horizontal left-to-right gradient (light
  /// gold → dark gold for Luxury Gold), companion to [borderGradient]'s
  /// vertical version. Null means "plain flat divider," same as before
  /// this field existed.
  final Gradient? dividerGradient;

  /// Market Clock dial face gradient (MarketClockDial's own instrument-
  /// panel circle, distinct from [windowGradient] — the dial is a
  /// CustomPainter shader fill, not a BoxDecoration, and needs its own
  /// light-center/dark-edge radial rather than reusing another theme's
  /// window treatment). Null means "keep the original green radial" —
  /// MarketClockDial's pre-existing default, untouched for every theme
  /// that doesn't set this.
  final Gradient? marketClockFaceGradient;

  /// Market Clock dial ring glow + hour numerals color, paired with
  /// [marketClockFaceGradient]. Null means "keep the original brass/gold"
  /// — MarketClockDial's pre-existing default, untouched for every theme
  /// that doesn't set this.
  final Color? marketClockAccent;

  /// Market Clock dial ring's own vertical gradient (top a couple shades
  /// lighter than [marketClockAccent], bottom the accent itself) — null
  /// means "flat [marketClockAccent] (or brass/gold) ring," the default
  /// for every theme that doesn't set this.
  final Gradient? marketClockRingGradient;

  /// Market Clock hour/minute hands' own gradient — deliberately separate
  /// from [marketClockRingGradient] even though Graphite sets both to the
  /// same white-steel gradient: Midnight Sea/Black & White already set a
  /// ring gradient and are CLOSED/device-confirmed with flat hands, so
  /// reusing that field for hands too would have silently changed their
  /// already-shipped look. Null (every theme but Graphite) keeps the flat
  /// [marketClockAccent]-derived hand color MarketClockDial used before
  /// this field existed.
  final Gradient? marketClockHandGradient;

  /// Text/icon color for content inside [themedDarkCtaButtonShell] /
  /// [themedAddWidgetsButton] when they resolve to [buttonGradient] rather
  /// than [windowGradient]. Null means "use [onWindow] ?? [textHeader]
  /// there instead," exactly the behavior before this field existed —
  /// needed only for a theme like Black & White, whose CTA buttons sit on
  /// a LIGHT [buttonGradient] (needs near-black text) while its inner
  /// instrument-panel windows stay dark (needs [onWindow]'s white).
  final Color? onButton;

  /// Opacity of the decorative blurred glow behind accent-colored
  /// elements — the Market Clock dial's ring stroke, its digital-readout
  /// text, and the accent-tinted glow under filled progress bars
  /// (Market Clock's risk-metric bars, Stress Test's allocation bars).
  /// Null means "use each call site's own original opacity" (Luxury
  /// Gold's gold glow, Midnight Sea's teal glow, and Standard's brass
  /// glow are all unaffected). Only Black & White sets this, to 0.0: a
  /// colored glow looks flattering on a dark card, but a near-black glow
  /// blurred against this theme's now-light cards/bars reads as a dirty
  /// smudge, not a halo (user, 2026-09-05: "грязь сверху вылезла" for the
  /// ring, then the same complaint for the digital clock + bar glows).
  final double? glowOpacity;

  /// Disclaimer/fine-print text color (DisclaimerFooter,
  /// SimulatedTradingDisclaimer, StressTestVerdictDisclaimer, and the
  /// inline Company Card / Trade Breakdown disclaimers). Null means "keep
  /// the shared `ThemeV2.textSecondary` @ 50% alpha every theme used
  /// before this field existed" — that muted gray already reads fine on
  /// Luxury Gold/Midnight Sea's dark backdrops (2026-08-23/25 decision,
  /// left un-themed on purpose). Only Black & White sets this, to near-
  /// black — its white cards made the same muted gray read too faint.
  final Color? disclaimerColor;

  const AppPalette({
    this.background,
    this.backgroundGradient,
    required this.card,
    this.cardGradient,
    required this.border,
    this.borderGradient,
    required this.accentPrimary,
    required this.accentSecondary,
    required this.textHeader,
    required this.textBody,
    this.titleGradient,
    this.titleShadow,
    this.buttonGradient,
    this.glowShadow,
    this.cardGlow,
    this.windowGradient,
    this.onWindow,
    this.dividerGradient,
    this.marketClockFaceGradient,
    this.marketClockAccent,
    this.marketClockRingGradient,
    this.marketClockHandGradient,
    this.onButton,
    this.disclaimerColor,
    this.glowOpacity,
  });

  static const standard = AppPalette(
    background: null,
    card: ThemeV2.surface,
    border: ThemeV2.divider,
    accentPrimary: ThemeV2.primary,
    accentSecondary: ThemeV2.primary,
    textHeader: ThemeV2.textPrimary,
    textBody: ThemeV2.textSecondary,
  );

  static AppPalette get luxuryGold => AppPalette(
    background: LuxuryGoldTheme.background,
    backgroundGradient: LuxuryGoldTheme.backgroundGradient,
    card: LuxuryGoldTheme.card,
    cardGradient: LuxuryGoldTheme.cardGradient,
    border: LuxuryGoldTheme.borderStroke,
    borderGradient: LuxuryGoldTheme.titleGradient,
    accentPrimary: LuxuryGoldTheme.accentGold,
    accentSecondary: LuxuryGoldTheme.accentGoldBright,
    textHeader: LuxuryGoldTheme.textHeader,
    textBody: LuxuryGoldTheme.textBody,
    titleGradient: LuxuryGoldTheme.titleGradient,
    titleShadow: LuxuryGoldTheme.titleShadow,
    buttonGradient: LuxuryGoldTheme.buttonGradient,
    glowShadow: LuxuryGoldTheme.glowShadow(),
    cardGlow: LuxuryGoldTheme.cardGlow(),
    windowGradient: LuxuryGoldTheme.windowGradient,
    dividerGradient: LuxuryGoldTheme.dividerGradient,
  );

  static AppPalette get blackWhite => AppPalette(
    background: BlackWhiteTheme.background,
    backgroundGradient: BlackWhiteTheme.backgroundGradient,
    card: BlackWhiteTheme.card,
    cardGradient: BlackWhiteTheme.cardGradient,
    border: BlackWhiteTheme.borderStroke,
    borderGradient: BlackWhiteTheme.borderGradient,
    accentPrimary: BlackWhiteTheme.accentPrimary,
    accentSecondary: BlackWhiteTheme.accentSecondary,
    textHeader: BlackWhiteTheme.textHeader,
    textBody: BlackWhiteTheme.textBody,
    // Buttons get the same light [cardGradient] (white top → light-graphite
    // bottom) instead of the dark instrument-panel [windowGradient] — 2026-
    // 09-05 request: every button should read as white/light, not dark,
    // even though the nested "instrument panel" windows (stat tiles, mood
    // boxes) stay dark. [onButton] carries the matching near-black text.
    buttonGradient: BlackWhiteTheme.cardGradient,
    onButton: BlackWhiteTheme.onButton,
    cardGlow: BlackWhiteTheme.cardGlow(),
    windowGradient: BlackWhiteTheme.windowGradient,
    onWindow: BlackWhiteTheme.onWindow,
    disclaimerColor: BlackWhiteTheme.disclaimerColor,
    // Market Clock dial re-theme (2026-09-05, explicit request): ring +
    // hour ticks/numerals + digital-readout accents go from gold/brass to
    // this theme's own near-black; the ring's flat color is replaced by
    // marketClockRingGradient below wherever a gradient shader applies
    // (the ring stroke itself, and the risk-metric bars in
    // market_clock_timing_widget.dart, which reuse this gradient's
    // first/last colors in place of gold). Face gradient deliberately left
    // unset — it already falls back to windowGradient (this theme's light
    // card gradient), which is correct as-is.
    marketClockAccent: BlackWhiteTheme.accentPrimary,
    marketClockRingGradient: BlackWhiteTheme.borderGradient,
    glowOpacity: 0.0,
  );

  static AppPalette get graphite => AppPalette(
    background: GraphiteTheme.background,
    backgroundGradient: GraphiteTheme.backgroundGradient,
    card: GraphiteTheme.card,
    cardGradient: GraphiteTheme.cardGradient,
    border: GraphiteTheme.borderStroke,
    borderGradient: GraphiteTheme.borderGradient,
    accentPrimary: GraphiteTheme.accentPrimary,
    accentSecondary: GraphiteTheme.accentSecondary,
    textHeader: GraphiteTheme.textHeader,
    textBody: GraphiteTheme.textBody,
    // Real white→steel gradient (not a flat signal-flag one) — see
    // GraphiteTheme.titleGradient's own doc comment. Non-null here is also
    // this app's "dark-card theme, render white" flag app-wide.
    titleGradient: GraphiteTheme.titleGradient,
    // Every window AND button gets the same graphite fill as the outer
    // card — same "one consistent treatment app-wide" precedent as Black &
    // White/Midnight Sea.
    windowGradient: GraphiteTheme.cardGradient,
    buttonGradient: GraphiteTheme.cardGradient,
    onWindow: GraphiteTheme.onWindow,
    onButton: GraphiteTheme.onButton,
    disclaimerColor: GraphiteTheme.disclaimerColor,
    cardGlow: GraphiteTheme.cardGlow(),
    // Market Clock dial re-theme: ring, hour ticks/numerals, and the
    // digital-readout accent all go white/steel; hands reuse the same ring
    // gradient (see market_clock_dial.dart's [MarketClockDial]) rather than
    // a separate field — one white-steel "metallic hardware" look for both.
    marketClockFaceGradient: GraphiteTheme.dialFaceGradient,
    marketClockAccent: GraphiteTheme.accentPrimary,
    marketClockRingGradient: GraphiteTheme.dialRingGradient,
    marketClockHandGradient: GraphiteTheme.dialRingGradient,
  );

  static AppPalette get midnightSea => AppPalette(
    background: MidnightSeaTheme.background,
    backgroundGradient: MidnightSeaTheme.backgroundGradient,
    card: MidnightSeaTheme.card,
    cardGradient: MidnightSeaTheme.cardGradient,
    border: MidnightSeaTheme.borderStroke,
    borderGradient: MidnightSeaTheme.borderGradient,
    accentPrimary: MidnightSeaTheme.accentPrimary,
    accentSecondary: MidnightSeaTheme.accentSecondary,
    textHeader: MidnightSeaTheme.textHeader,
    textBody: MidnightSeaTheme.textBody,
    cardGlow: MidnightSeaTheme.cardGlow(),
    // Plain white, not a color sheen (unlike Luxury Gold's actual metallic
    // gradient) — this palette has no titleGradient of its own set, and
    // `palette.titleGradient != null` is the app-wide signal (~15 call
    // sites: widget/card titles + themedHeaderIcon's back/menu/bell/edit
    // icons, plus verdict/encyclopedia/search/order-entry/notifications
    // body text) for "dark-backdrop theme, render white" — without this,
    // every one of those fell through to the Standard-theme branch
    // (accentPrimary teal for headers/icons, muted textBody for body
    // text), which is why headers stayed turquoise even after textHeader
    // itself was whitened. A flat white-to-white gradient flips all of
    // them to the white branch while being a no-op under the ShaderMask
    // (BlendMode.modulate against already-white text/icons stays white).
    titleGradient: const LinearGradient(colors: [Colors.white, Colors.white]),
    marketClockFaceGradient: MidnightSeaTheme.dialFaceGradient,
    marketClockAccent: MidnightSeaTheme.accentPrimary,
    marketClockRingGradient: MidnightSeaTheme.dialRingGradient,
    // Inner window AND button fill — the SAME radial gradient for both
    // (user's ask, 2026-09-02: every window/button app-wide gets this one
    // consistent light-center/dark-edge treatment, distinct from the
    // outer card's own blue [cardGradient]). [glowShadow]/[cardGlow]
    // double as the downward shadow every dark panel already uses
    // (offset (0,3)).
    windowGradient: MidnightSeaTheme.windowGradient,
    buttonGradient: MidnightSeaTheme.windowGradient,
    glowShadow: MidnightSeaTheme.cardGlow(),
  );
}

/// Shared fill for the "More/Less" toggle pills scattered across Home/
/// Portfolio/Stress Test widgets (Holdings, Trade History, allocation
/// legends, etc.) — the same [AppPalette.windowGradient] + text-color
/// recipe every other "window" in the app uses (paired with a
/// [themedBorder] ring at the call site) for a theme that defines one,
/// else the original soft [AppPalette.accentPrimary]-tinted pill every
/// theme used before this existed.
///
/// Reuses [AppPalette.windowGradient] rather than [AppPalette.buttonGradient]
/// — Luxury Gold's buttonGradient is its bright, saturated gold (meant for
/// a real brand CTA), which read as a jarring solid-gold pill here
/// (confirmed on-device 2026-09-04); windowGradient is Luxury Gold's own
/// graphite "inner panel" fill, the same one every stat tile/mood window/
/// CTA shell (see themedDarkCtaButtonShell) already uses. Returns
/// (gradient, flat background, text color) — exactly one of the first two
/// is non-null.
(Gradient?, Color?, Color) moreLessPillStyle(AppPalette palette) {
  final gradient = palette.windowGradient;
  if (gradient != null) {
    return (gradient, null, palette.onWindow ?? palette.textHeader);
  }
  return (null, palette.accentPrimary.withValues(alpha: 0.06), palette.accentPrimary);
}

/// The single switch point for adding a new theme — everything else
/// (screens, the theme picker) reads through this or [AppThemeVariant.values].
AppPalette resolveAppPalette(AppThemeVariant variant) => switch (variant) {
  AppThemeVariant.standard => AppPalette.standard,
  AppThemeVariant.luxuryGold => AppPalette.luxuryGold,
  AppThemeVariant.blackWhite => AppPalette.blackWhite,
  AppThemeVariant.graphite => AppPalette.graphite,
  AppThemeVariant.midnightSea => AppPalette.midnightSea,
};
