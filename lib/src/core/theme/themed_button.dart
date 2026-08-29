import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'app_palette.dart';
import 'themed_border.dart';

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
  if (palette.windowGradient == null) {
    return DecoratedBox(decoration: standardDecoration, child: child);
  }
  return themedBorder(
    palette: palette,
    borderRadius: borderRadius,
    child: Material(
      color: Colors.transparent,
      child: Ink(
        decoration: BoxDecoration(
          gradient: palette.windowGradient,
          borderRadius: borderRadius,
        ),
        child: child,
      ),
    ),
  );
}

/// Text/icon color for content inside [themedDarkCtaButtonShell] — flat
/// white on Standard's dark-green fill, cream [AppPalette.textHeader] on
/// Luxury Gold's graphite window fill.
Color themedDarkCtaContentColor(AppPalette palette) =>
    palette.windowGradient == null ? Colors.white : palette.textHeader;

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
}) {
  if (palette.windowGradient == null) {
    return TextButton.icon(
      onPressed: onTap,
      icon: Icon(Icons.add_rounded, color: palette.accentPrimary, size: 20),
      label: Text(
        label,
        style: GoogleFonts.inter(
          fontSize: 14,
          fontWeight: FontWeight.w600,
          color: palette.accentPrimary,
        ),
      ),
      style: TextButton.styleFrom(
        padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 14),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(30),
          side: BorderSide(color: palette.accentPrimary, width: 0.5),
        ),
      ),
    );
  }
  final radius = BorderRadius.circular(30);
  return themedBorder(
    palette: palette,
    borderRadius: radius,
    child: Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap,
        child: Ink(
          decoration: BoxDecoration(
            gradient: palette.windowGradient,
            borderRadius: radius,
          ),
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 14),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(Icons.add_rounded, color: palette.textHeader, size: 20),
              const SizedBox(width: 8),
              Text(
                label,
                style: GoogleFonts.inter(
                  fontSize: 14,
                  fontWeight: FontWeight.w600,
                  color: palette.textHeader,
                ),
              ),
            ],
          ),
        ),
      ),
    ),
  );
}
