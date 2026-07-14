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

  const CardFrame({
    super.key,
    required this.child,
    this.padding,
    this.showTopBar = true,
    this.decoration,
    this.margin,
  });

  @override
  Widget build(BuildContext context) {
    final effectiveDecoration = decoration ?? FomoShieldTheme.cardDecoration;
    final effectivePadding = padding ?? EdgeInsets.all(FomoShieldTheme.cardPadding);

    return Container(
      width: double.infinity,
      margin: margin ?? EdgeInsets.zero,
      decoration: effectiveDecoration.copyWith(
        borderRadius: FomoShieldTheme.cardRadius, // ensure radius for clip
      ),
      // Use clipBehavior to ensure top bar respects border radius
      clipBehavior: Clip.antiAlias,
      child: Column(
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
                    FomoShieldTheme.cardTopBarStart.withOpacity(0.12),
                    FomoShieldTheme.cardTopBarEnd.withOpacity(0.12),
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
      ),
    );
  }
}
