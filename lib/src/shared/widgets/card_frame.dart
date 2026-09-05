// ---------------------------------------------------------------------------
// CardFrame — Wrapper with shared card chrome (Design Bible Part 7)
// ---------------------------------------------------------------------------
// Единая обёртка для всех карточек:
// - border-radius: 22px (FomoShieldTheme.radius)
// - border: 1px solid var(--border)
// - box-shadow: var(--shadow-soft)
// ---------------------------------------------------------------------------

import 'package:flutter/material.dart';
import '../../core/theme/fomo_shield_theme.dart';
import '../../core/theme/app_palette.dart';

/// Wraps a child widget in a card with the app's shared chrome.
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
    this.decoration,
    this.margin,
    this.palette,
  });

  @override
  Widget build(BuildContext context) {
    // No explicit decoration override: use the theme's own flat card color
    // (palette.card) instead of always Standard's off-white — needed for
    // Black & White's white cards. A caller that passes its own
    // `decoration` (e.g. Market Clock's instrument-panel look) still wins
    // untouched.
    final effectiveDecoration =
        decoration ??
        FomoShieldTheme.cardDecoration.copyWith(
          color: palette?.card ?? FomoShieldTheme.card,
        );
    final effectivePadding = padding ?? EdgeInsets.all(FomoShieldTheme.cardPadding);

    final body = Padding(
      padding: effectivePadding,
      child: child,
    );

    // Molecule 4 (card background): when the theme defines a cardGradient,
    // it replaces the card's fill entirely — can't combine `color` and
    // `gradient` on one BoxDecoration, so this doesn't reuse
    // effectiveDecoration's color/border/shadow. Computed once so it
    // applies whether or not the theme also defines a [borderGradient] —
    // Black & White / Light Lime / Midnight Sea use cardGradient without
    // one (2026-09-01), unlike Luxury Gold which pairs both.
    var cardBodyDecoration = palette?.cardGradient != null
        ? BoxDecoration(
            gradient: palette!.cardGradient,
            borderRadius: FomoShieldTheme.cardRadius,
          )
        : effectiveDecoration.copyWith(borderRadius: FomoShieldTheme.cardRadius);

    // [cardGlow] previously only ever painted on the [borderGradient]
    // branch below (an outer Container it owns) — a theme with cardGlow
    // but no borderGradient (Black & White, 2026-09-05) had it silently
    // dropped. Applied here too so it reaches this plain-Container branch.
    if (palette?.borderGradient == null && palette?.cardGlow != null) {
      cardBodyDecoration = cardBodyDecoration.copyWith(
        boxShadow: [palette!.cardGlow!],
      );
    }

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
          decoration: cardBodyDecoration,
          clipBehavior: Clip.antiAlias,
          child: body,
        ),
      );
    }

    return Container(
      width: double.infinity,
      margin: margin ?? EdgeInsets.zero,
      decoration: cardBodyDecoration,
      clipBehavior: Clip.antiAlias,
      child: body,
    );
  }
}
