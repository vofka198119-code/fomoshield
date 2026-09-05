import 'package:flutter/material.dart';
import 'app_palette.dart';

// ---------------------------------------------------------------------------
// Themed divider — the canonical header/section divider treatment: a
// horizontal left-to-right gradient (companion to [AppPalette.borderGradient]'s
// vertical version) once a theme defines [AppPalette.dividerGradient].
// Falls back to a plain flat divider otherwise (Standard, or any future
// theme that doesn't opt in) — same look every existing hand-rolled
// `Divider(color: Colors.black.withValues(alpha: 0.06))` call already had.
// ---------------------------------------------------------------------------

Widget themedDivider(
  AppPalette palette, {
  double indent = 16,
  double endIndent = 16,
  double height = 1,
}) {
  final gradient = palette.dividerGradient;
  if (gradient != null) {
    return Container(
      height: height,
      margin: EdgeInsets.only(left: indent, right: endIndent),
      decoration: BoxDecoration(gradient: gradient),
    );
  }
  return Divider(
    height: height,
    indent: indent,
    endIndent: endIndent,
    color: _fallbackColor(palette),
  );
}

/// A theme with a dark card but no [AppPalette.dividerGradient] of its own
/// (Midnight Sea) still needs a WHITE-based line — [Colors.black] at low
/// alpha reads as invisible against a dark card, which is exactly what
/// made every widget header's underline (and every list's row dividers)
/// disappear under Midnight Sea (fixed 2026-09-03). Same 10%-alpha white
/// used by the Home Market Clock widget's own always-dark divider
/// (market_clock_widget.dart), the reference the fix was checked against.
///
/// REVISED (2026-09-05): was keyed on `palette.cardGradient != null` as a
/// "this card is dark" proxy — true when only Luxury Gold (own
/// dividerGradient, never reaches here) and Midnight Sea set cardGradient,
/// both dark. Broke once Black & White ALSO started setting cardGradient
/// (white → light graphite, still a LIGHT card) — every divider through
/// this helper silently went white-on-white. Keyed on [AppPalette.textHeader]'s
/// own luminance instead: light text ⇒ theme is dark-carded (white
/// divider), dark text ⇒ light-carded (black divider) — correct for every
/// theme including future ones, without needing another palette field.
Color _fallbackColor(AppPalette palette) =>
    palette.textHeader.computeLuminance() > 0.5
        ? Colors.white.withValues(alpha: 0.1)
        : Colors.black.withValues(alpha: 0.06);

// ---------------------------------------------------------------------------
// Themed row divider — for the OTHER divider shape found across the app:
// a `showDivider`-per-row pattern, where each list row paints its own
// bottom line via a Border rather than a parent interleaving standalone
// [themedDivider] widgets between siblings (see WidgetContainer for that
// pattern instead). A Border can't paint a gradient, so this renders a
// thin Container instead — meant to be placed as a sibling AFTER a row's
// own content (not inside its padding).
//
// Indent defaults match [themedDivider]'s own default (16/16) — confirmed
// 2026-08-25 as the canonical look app-wide (WidgetContainer's Trade
// History reference) after row-list widgets that had grown their own
// divider (Portfolio/Stress Test Holdings, Watchlist "view all", search's
// company mini-card) rendered it edge-to-edge instead, reading as
// inconsistent side-by-side with WidgetContainer-based widgets.
// ---------------------------------------------------------------------------

Widget themedRowDivider(
  AppPalette palette, {
  double indent = 16,
  double endIndent = 16,
  double height = 0.5,
}) {
  final gradient = palette.dividerGradient;
  return Container(
    height: height,
    margin: EdgeInsets.only(left: indent, right: endIndent),
    decoration: gradient != null
        ? BoxDecoration(gradient: gradient)
        : BoxDecoration(color: _fallbackColor(palette)),
  );
}
