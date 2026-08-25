// ---------------------------------------------------------------------------
// CardFrame — Wrapper with decorative top bar (Design Bible Part 7)
// ---------------------------------------------------------------------------
// Единая обёртка для всех карточек:
// - border-radius: 22px (FomoShieldTheme.radius)
// - border: 1px solid var(--border)
// - box-shadow: var(--shadow-soft)
// - Декоративная верхняя полоса (::before) — 5px градиент #6FA7D6 → #4E6D8D
// ---------------------------------------------------------------------------

import 'package:flutter/material.dart';
import '../../core/theme/fomo_shield_theme.dart';
import '../../core/theme/app_palette.dart';

/// Wraps a child widget in a card with decorative top bar.
///
/// Usage:
/// ```dart
/// CardFrame(
///   padding: const EdgeInsets.all(22),
///   child: Column(children: [...])
/// )
/// ```
class CardFrame extends StatelessWidget {
  /// The card content.
  final Widget child;

  /// Padding inside the card. Defaults to `EdgeInsets.all(FomoShieldTheme.cardPadding)`.
  final EdgeInsetsGeometry? padding;

  /// Whether to show the decorative top bar. Defaults to true.
  final bool showTopBar;

  /// Optional custom decoration override. Uses [FomoShieldTheme.cardDecoration] by default.
  final BoxDecoration? decoration;

  /// Optional margin around the card. Defaults to EdgeInsets.zero.
  final EdgeInsetsGeometry? margin;

  /// Optional theme palette — when it defines [AppPalette.borderGradient],
  /// this card gets a gradient border + [AppPalette.glowShadow] lifting it
  /// off the background instead of [FomoShieldTheme.cardDecoration]'s
  /// plain border (Luxury Gold molecule 2, 2026-08-23; the card BODY color
  /// is untouched by this — molecule 4 is still deferred). Null (the
  /// default) is a complete no-op — every existing call site is
  /// unaffected unless it opts in by passing a palette.
  final AppPalette? palette;

  const CardFrame({
    super.key,
    required this.child,
    this.padding,
    this.showTopBar = true,
    this.decoration,
    this.margin,
    this.palette,
  });

  @override
  Widget build(BuildContext context) {
    final effectiveDecoration = decoration ?? FomoShieldTheme.cardDecoration;
    final effectivePadding = padding ?? EdgeInsets.all(FomoShieldTheme.cardPadding);

    final body = Column(
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        // ── Decorative top bar (::before) ──
        if (showTopBar)
          Container(
            height: FomoShieldTheme.cardTopBarHeight,
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: [
                  FomoShieldTheme.cardTopBarStart.withValues(alpha: 0.12),
                  FomoShieldTheme.cardTopBarEnd.withValues(alpha: 0.12),
                ],
              ),
            ),
          ),

        // ── Card body ──
        Padding(
          padding: effectivePadding,
          child: child,
        ),
      ],
    );

    final borderGradient = palette?.borderGradient;
    if (borderGradient != null) {
      // Flutter's BoxDecoration.border can't paint a gradient directly —
      // an outer container filled with the gradient, inset by the border
      // width, standing in as the "stroke" around an inner container with
      // the real card body.
      return Container(
        width: double.infinity,
        margin: margin ?? EdgeInsets.zero,
        padding: const EdgeInsets.all(0.5),
        decoration: BoxDecoration(
          gradient: borderGradient,
          borderRadius: FomoShieldTheme.cardRadius,
          // Same recipe as the splash screen's wordmark shadow, gold
          // instead of black — see LuxuryGoldTheme.cardGlow's doc comment.
          boxShadow: [if (palette?.cardGlow != null) palette!.cardGlow!],
        ),
        child: Container(
          // Molecule 4 (card background): when the theme defines a
          // cardGradient, it replaces the card's fill entirely — can't
          // combine `color` and `gradient` on one BoxDecoration, so this
          // branch doesn't reuse effectiveDecoration's color/border/shadow.
          decoration: palette?.cardGradient != null
              ? BoxDecoration(
                  gradient: palette!.cardGradient,
                  borderRadius: FomoShieldTheme.cardRadius,
                )
              : effectiveDecoration.copyWith(
                  borderRadius: FomoShieldTheme.cardRadius,
                ),
          clipBehavior: Clip.antiAlias,
          child: body,
        ),
      );
    }

    return Container(
      width: double.infinity,
      margin: margin ?? EdgeInsets.zero,
      decoration: effectiveDecoration.copyWith(
        borderRadius: FomoShieldTheme.cardRadius, // ensure radius for clip
      ),
      // Use clipBehavior to ensure top bar respects border radius
      clipBehavior: Clip.antiAlias,
      child: body,
    );
  }
}
