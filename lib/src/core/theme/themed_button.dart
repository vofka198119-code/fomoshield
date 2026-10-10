import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'app_palette.dart';
import 'theme_v2.dart';
import 'luxury_gold_theme.dart';
import 'themed_border.dart';
import '../../features/market_clock/market_clock_dial.dart'
    show buyButtonDecoration;

// ---------------------------------------------------------------------------
// Themed dark CTA button shell — for full-width text/icon action buttons
// that (unlike BUY/SELL, which stay a real dark-green CTA in both themes on
// purpose) should pick up the Luxury Gold "instrument panel" look: gold
// gradient ring border + radial windowGradient fill instead of the flat
// dark-green gradient, cream (textHeader) text instead of white. Standard
// theme is untouched — caller supplies its own pre-existing decoration.
// ---------------------------------------------------------------------------

/// Wraps a CTA button's content in the theme-aware panel treatment.
/// [standardDecoration] is whatever the button already used pre-Luxury
/// (typically `darkCardDecoration(borderRadius: ...)`) — passed through
/// unchanged for Standard theme so its look never regresses.
///
/// Self-contained on purpose: the Luxury branch owns its own local
/// [Material] sitting INSIDE [themedBorder]'s gold ring Container, so the
/// graphite [Ink] decoration it controls paints (as an ink feature) only
/// after that Container's own opaque gradient has already been painted —
/// nesting a `Material` OUTSIDE the border instead (e.g. one supplied by
/// the caller) reverses that order: the ink feature paints first, then the
/// border Container's normal child-paint pass draws its opaque gold fill
/// straight over it, so the whole button reads solid gold with the
/// graphite invisible. Callers don't need (and shouldn't rely on) their
/// own surrounding Material for this to render correctly.
Widget themedDarkCtaButtonShell({
  required AppPalette palette,
  required BorderRadius borderRadius,
  required BoxDecoration standardDecoration,
  required Widget child,
}) {
  // REVERTED (2026-09-05): a same-day attempt to prefer [buttonGradient]
  // here broke Luxury Gold's "Add Widgets"/CTA buttons — LuxuryGoldTheme
  // sets its OWN distinct buttonGradient (a bright gold linear gradient,
  // its real CTA brand color) separate from windowGradient (the radial
  // graphite-gold instrument-panel fill this button is deliberately
  // themed to match instead, per the doc comment above) — so buttonGradient
  // silently took over and the button went solid bright gold instead of
  // the intended panel look (user: "сломал кнопку адд виджет"). Black &
  // White doesn't need the override either: its windowGradient is already
  // the same light card gradient buttonGradient would have pointed at
  // (unified 2026-09-05), so plain windowGradient is correct for every
  // theme here.
  final gradient = palette.windowGradient;
  if (gradient == null) {
    return DecoratedBox(decoration: standardDecoration, child: child);
  }
  return themedBorder(
    palette: palette,
    borderRadius: borderRadius,
    child: Material(
      color: Colors.transparent,
      child: Ink(
        decoration: BoxDecoration(
          gradient: gradient,
          borderRadius: borderRadius,
        ),
        child: child,
      ),
    ),
  );
}

/// Text/icon color for content inside [themedDarkCtaButtonShell] — flat
/// white on Standard's dark-green fill, else [AppPalette.onButton] ??
/// [AppPalette.onWindow] ?? [AppPalette.textHeader] (falling back through
/// in that order; Luxury Gold's cream comes from textHeader, Black &
/// White's near-black button text from onButton).
Color themedDarkCtaContentColor(AppPalette palette) {
  if (palette.windowGradient == null) return Colors.white;
  return palette.onButton ?? palette.onWindow ?? palette.textHeader;
}

// ---------------------------------------------------------------------------
// Label colour for a button filled with a THEME-DEPENDENT colour.
//
// Hardcoding `foregroundColor: Colors.white` over a palette accent is a trap,
// because some themes' accents are light: Graphite's accentPrimary is
// literally `Colors.white`, so a white label on it renders at 1.00:1 and is
// invisible (two live reports, 2026-09-27 and 2026-09-28). Deriving the label
// from the fill fixes every theme at once instead of special-casing one.
//
// Measured on the real fills: near-black accents keep white at ~19.6:1 and
// the brand green at ~7.9:1, while the gold (#D4AF37) goes from 2.1:1 white
// to 7.8:1 near-black and Midnight Sea's teal from 2.5:1 to 6.5:1 — which
// also matches what premiumCtaContentColor below does on gold.
//
// Only for FILLS. Accent-coloured text or icons sitting on a card background
// are a different question and must not go through here.
// ---------------------------------------------------------------------------

/// White on a dark fill, near-black on a light one.
Color labelColorOn(Color fill) =>
    ThemeData.estimateBrightnessForColor(fill) == Brightness.dark
    ? Colors.white
    : ThemeV2.textPrimary;

// ---------------------------------------------------------------------------
// "Go Premium" CTA fill — the buttons that actually sell the subscription
// (Profile's upsell card, Stress Test's locked-feature dialog). They colour
// themselves from `palette.marketClockAccent ?? <gold>`, so:
//
// - Black & White, Graphite and Midnight Sea name their own accent and keep
//   it FLAT. A gold gradient in a monochrome theme is the same mistake the
//   trade-breakdown amounts had (fixed 2026-09-27).
// - Standard and Luxury Gold name none and fall through to the app's gold.
//   They get it as the two-tone metallic gradient Luxury Gold already uses
//   for its own buttons, rather than one flat swatch — reused rather than
//   re-derived, so there is still exactly one definition of "gold button".
// ---------------------------------------------------------------------------

/// Gradient for a "go Premium" button, or null when the theme should keep
/// its own flat accent. Pair with [premiumCtaContentColor].
Gradient? premiumCtaGradient(AppPalette palette) =>
    palette.marketClockAccent == null ? LuxuryGoldTheme.buttonGradient : null;

/// Text/icon colour to sit on [premiumCtaGradient]. Near-black on the gold,
/// which is what Profile's button already did; themes that keep their flat
/// accent keep whatever they passed before.
Color premiumCtaContentColor(AppPalette palette, Color flatThemeColor) =>
    premiumCtaGradient(palette) != null ? Colors.black : flatThemeColor;

// ---------------------------------------------------------------------------
// Themed "Add Widgets" button — the canonical treatment for every screen's
// widget-picker CTA (Home, Market Clock, Portfolio, Stress Test main +
// Portfolio Balance detail, Company Detail). Was six near-identical
// hand-rolled TextButton.icon blocks that had started to drift; unified
// 2026-08-25.
//
// Standard theme: unchanged flat TextButton.icon (accentPrimary outline,
// no fill) — byte-for-byte the pre-existing look.
// Luxury Gold: rebuilt as a "window"-style pill — gradient ring border
// (themedBorder, same as every widget's own card border) + radial
// windowGradient fill (same as every widget's inner windows) + flat
// cream (textHeader) icon/label instead of gold, so it reads as a real
// button rather than plain accent-colored text.
// ---------------------------------------------------------------------------

Widget themedAddWidgetsButton(
  BuildContext context,
  AppPalette palette, {
  required String label,
  required VoidCallback onTap,
  // Defaults to the original "+" so every existing call site (Home, Market
  // Clock, Stress Test, Company Detail, Portfolio) renders byte-for-byte
  // unchanged -- added 2026-09-13 so a non-"add" action (e.g. Fund
  // Management's "open public card") can reuse this exact per-theme pill
  // shape instead of a plain TextButton that doesn't follow theme at all.
  IconData icon = Icons.add_rounded,
  // Standard theme only: the colour of the label, icon and ring. Null (every
  // original call site) keeps the accent, which is right on the light cards
  // this button was built for. Pass the card's own text colour when the
  // button sits on a DARK card — accent-on-dark-green is the same text the
  // card is painted in, and the button all but disappeared on the fund
  // management panel until this was spotted on the phone (2026-10-09).
  // Themed variants ignore it: there the pill has its own windowGradient
  // fill and onButton/onWindow already answer this question.
  Color? foreground,
}) {
  final gradient = palette.windowGradient;
  if (gradient == null) {
    final color = foreground ?? palette.accentPrimary;
    return TextButton.icon(
      onPressed: onTap,
      icon: Icon(icon, color: color, size: 20),
      label: Text(
        label,
        style: GoogleFonts.inter(
          fontSize: 14,
          fontWeight: FontWeight.w600,
          color: color,
        ),
      ),
      style: TextButton.styleFrom(
        padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 14),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(30),
          side: BorderSide(color: color, width: 0.5),
        ),
      ),
    );
  }
  final radius = BorderRadius.circular(30);
  final onWindowColor =
      palette.onButton ?? palette.onWindow ?? palette.textHeader;
  return themedBorder(
    palette: palette,
    borderRadius: radius,
    child: Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap,
        child: Ink(
          decoration: BoxDecoration(gradient: gradient, borderRadius: radius),
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 14),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(icon, color: onWindowColor, size: 20),
              const SizedBox(width: 8),
              Text(
                label,
                style: GoogleFonts.inter(
                  fontSize: 14,
                  fontWeight: FontWeight.w600,
                  color: onWindowColor,
                ),
              ),
            ],
          ),
        ),
      ),
    ),
  );
}

// ---------------------------------------------------------------------------
// The pair of buttons a sheet or an editor ends with: the brand action on the
// right, the way out on the left.
//
// Written down here because the fund screens kept growing their own —
// a FilledButton tinted with accentPrimary, which is not what any other CTA
// in this app looks like, and which under Graphite (white accent) or Luxury
// Gold reads as a different app entirely. The house CTA is the dark-green
// "dial" gradient, swapped for the instrument-panel treatment under themes
// that define one; that logic already lives in themedDarkCtaButtonShell and
// is simply reused here (DESIGN_TOKENS §6, user ask 2026-10-10: "кнопки
// нужно покрасить в данной теме, это тёмно-зелёный градиент как везде").
// ---------------------------------------------------------------------------

/// The brand action. [onTap] null disables it; [busy] swaps the label for a
/// spinner without changing the button's size, so a row of them does not jump
/// while one is working.
///
/// Sized like the order-confirmation sheet's own confirm button — 50 tall,
/// and paired with [cancelButton] at `Expanded(flex: 2)` against the
/// cancel's 1, which is the proportion the app already uses for "the way out
/// beside the commitment".
Widget brandCtaButton({
  required AppPalette palette,
  required String label,
  required VoidCallback? onTap,
  bool busy = false,
  double fontSize = 15,
  double height = 50,
}) {
  final radius = BorderRadius.circular(14);
  final enabled = onTap != null && !busy;
  final content = Padding(
    padding: const EdgeInsets.symmetric(horizontal: 12),
    child: Center(
      child: busy
          ? SizedBox(
              height: 18,
              width: 18,
              child: CircularProgressIndicator(
                strokeWidth: 2,
                color: themedDarkCtaContentColor(palette),
              ),
            )
          : Text(
              label,
              textAlign: TextAlign.center,
              maxLines: 2,
              style: GoogleFonts.inter(
                fontSize: fontSize,
                fontWeight: FontWeight.w700,
                letterSpacing: 0.5,
                color: themedDarkCtaContentColor(palette),
              ),
            ),
    ),
  );

  return Opacity(
    // Dimming the whole shell keeps the gradient's shape while saying it is
    // unavailable — a disabled fill colour cannot be set on a gradient.
    opacity: enabled ? 1 : 0.45,
    child: SizedBox(
      height: height,
      child: themedDarkCtaButtonShell(
      palette: palette,
      borderRadius: radius,
      standardDecoration: buyButtonDecoration(borderRadius: radius),
      child: Material(
        color: Colors.transparent,
        borderRadius: radius,
        child: InkWell(
          onTap: enabled ? onTap : null,
          borderRadius: radius,
          child: content,
        ),
        ),
      ),
    ),
  );
}

/// The way out, beside it. A plain label, no outline and no fill — exactly
/// how the order-confirmation sheet draws its own cancel, so the eye lands on
/// the action and not on the escape.
Widget cancelButton({
  required AppPalette palette,
  required String label,
  required VoidCallback? onTap,
  double fontSize = 15,
}) {
  return TextButton(
    onPressed: onTap,
    style: TextButton.styleFrom(
      padding: const EdgeInsets.symmetric(vertical: 14),
    ),
    child: Text(
      label,
      textAlign: TextAlign.center,
      maxLines: 2,
      style: GoogleFonts.inter(
        fontSize: fontSize,
        fontWeight: FontWeight.w600,
        color: palette.textBody,
      ),
    ),
  );
}
