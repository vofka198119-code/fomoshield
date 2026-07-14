// ---------------------------------------------------------------------------
// CardAppear — Slide + Fade entrance for cards (Design Bible Part 8)
// ---------------------------------------------------------------------------
// Анимация появления карточек: slide from bottom (dy: 0.08 → 0.0) +
// fade (0.0 → 1.0) за 0.45s.
//
// Usage:
//   CardAppear(
//     delay: 100.ms,
//     child: MyCard(),
//   )
// ---------------------------------------------------------------------------

import 'package:flutter/material.dart';
import '../../core/theme/fomo_shield_theme.dart';

/// Wraps a child with a slide+fade entrance animation.
///
/// Использует [FomoShieldTheme.animCardAppear] (450ms) как длительность.
/// Параметр [delay] позволяет создать staggered-эффект для списка карточек.
class CardAppear extends StatefulWidget {
  final Widget child;
  final Duration delay;

  const CardAppear({
    super.key,
    required this.child,
    this.delay = Duration.zero,
  });

  @override
  State<CardAppear> createState() => _CardAppearState();
}

class _CardAppearState extends State<CardAppear>
    with SingleTickerProviderStateMixin {
  late final AnimationController _controller;
  late final Animation<double> _fadeAnim;
  late final Animation<Offset> _slideAnim;

  @override
  void initState() {
    super.initState();

    _controller = AnimationController(
      vsync: this,
      duration: FomoShieldTheme.animCardAppear,
    );

    _fadeAnim = CurvedAnimation(
      parent: _controller,
      curve: Curves.easeOut,
    );

    _slideAnim = Tween<Offset>(
      begin: const Offset(0.0, 0.08),
      end: Offset.zero,
    ).animate(CurvedAnimation(
      parent: _controller,
      curve: Curves.easeOutCubic,
    ));

    Future.delayed(widget.delay, () => _controller.forward());
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return SlideTransition(
      position: _slideAnim,
      child: FadeTransition(
        opacity: _fadeAnim,
        child: widget.child,
      ),
    );
  }
}
