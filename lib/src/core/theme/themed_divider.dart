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
  if (gradient == null) {
    return Divider(
      height: height,
      indent: indent,
      endIndent: endIndent,
      color: Colors.black.withValues(alpha: 0.06),
    );
  }
  return Container(
    height: height,
    margin: EdgeInsets.only(left: indent, right: endIndent),
    decoration: BoxDecoration(gradient: gradient),
  );
}

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
        : BoxDecoration(color: Colors.black.withValues(alpha: 0.06)),
  );
}
