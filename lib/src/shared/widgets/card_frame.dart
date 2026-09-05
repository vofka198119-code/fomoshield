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
    // applies regardless of whether the theme also defines a
    // [borderGradient] — every current theme happens to pair both by now,
    // but this check is intentionally independent of that so a future
    // theme with only one of the two still works.
    //
    // Gated on `decoration == null` OR `decoration == FomoShieldTheme
    // .cardDecoration` (2026-09-06 fix, found live on Black & White's
    // Stress Test setup screen, refined same day after the first cut of
    // this fix broke a DIFFERENT set of screens). A caller's own explicit
    // `decoration` is documented above as always winning ("A caller that
    // passes its own `decoration` ... still wins untouched"), but this
    // branch previously ignored that entirely whenever the active theme
    // had a cardGradient — silently replacing a caller's own hardcoded
    // card look (e.g. the Stress Test balance card's fixed green/blue
    // gradient, paired with its own hardcoded white text) with the
    // theme's card fill, while the caller's hardcoded text stayed
    // untouched — white-on-white under Black & White's now-light
    // cardGradient.
    //
    // First attempt at this fix treated ANY non-null `decoration` as a
    // deliberate override — wrong: many pre-theming call sites
    // (Psychology Meter, Stress Test main screen, Trade Detail/History,
    // Allocation/Portfolio Health/My Limit Orders widgets, Verdict marker
    // "coming soon" fallback) explicitly pass `FomoShieldTheme
    // .cardDecoration` out of habit, not as a real "stay Standard-styled"
    // request — they RELIED on the old (buggy) cardGradient-always-wins
    // behavior to get themed at all, and the naive fix broke them (flat
    // Standard white/off-white under every dark theme). `BoxDecoration`
    // has structural `==`, so this equality check reliably catches every
    // one of those (a fresh `BoxDecoration(color: card, ...)` instance
    // each call, but with identical field values) while still letting a
    // genuinely distinct custom decoration (the balance card's own
    // gradient) win. Every call site that instead branches on
    // `palette.windowGradient`/`cardGradient` itself before passing
    // `decoration` was never affected either way (its own conditional
    // already resolves to the same themed look).
    final isDefaultDecoration =
        decoration == null || decoration == FomoShieldTheme.cardDecoration;
    var cardBodyDecoration = isDefaultDecoration && palette?.cardGradient != null
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
