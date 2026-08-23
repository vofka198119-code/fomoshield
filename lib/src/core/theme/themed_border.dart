import 'package:flutter/material.dart';
import 'app_palette.dart';
import 'fomo_shield_theme.dart';

// ---------------------------------------------------------------------------
// Themed border — the canonical border treatment (gradient ring + gold
// splash-recipe shadow) confirmed universal on 2026-08-23: every card,
// widget, AND nested "window"/sub-panel inside a widget uses this, not
// just each widget's own outer CardFrame. Wrap any inner box (a stat
// tile, a mood/explanation panel, etc.) in [themedBorder] instead of
// hand-rolling the gradient-container trick again — see CardFrame for
// the original version of this same pattern.
// ---------------------------------------------------------------------------

/// Wraps [child] in the theme's gradient border + shadow when [palette]
/// defines one; otherwise returns [child] unchanged (no-op for Standard
/// and any future theme that doesn't opt into this treatment).
///
/// [child] should be a fully self-contained box (its own background fill,
/// no border/shadow of its own — those would show through/double up with
/// this wrapper's border).
Widget themedBorder({
  required Widget child,
  required AppPalette palette,
  BorderRadius? borderRadius,
  EdgeInsetsGeometry? margin,
}) {
  final gradient = palette.borderGradient;
  if (gradient == null) return child;

  final radius = borderRadius ?? FomoShieldTheme.cardRadius;
  return Container(
    margin: margin,
    padding: const EdgeInsets.all(1.5),
    decoration: BoxDecoration(
      gradient: gradient,
      borderRadius: radius,
      boxShadow: [if (palette.cardGlow != null) palette.cardGlow!],
    ),
    child: ClipRRect(
      borderRadius: BorderRadius.circular(
        (radius.topLeft.x - 1.5).clamp(0.0, double.infinity),
      ),
      child: child,
    ),
  );
}
