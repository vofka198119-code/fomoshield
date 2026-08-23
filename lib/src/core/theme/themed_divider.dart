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
