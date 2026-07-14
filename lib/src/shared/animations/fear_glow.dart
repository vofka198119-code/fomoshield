// ---------------------------------------------------------------------------
// FearGlow — Red glow pulse for danger states (Design Bible Part 8)
// ---------------------------------------------------------------------------
// Пульсирующее красное свечение для режимов Crash/BlackSwan/Volatility.
// Длительность: 1.2s (animFearGlow).
//
// Usage:
//   FearGlow(
//     intensity: 0.6,   // 0.0 – off, 1.0 – full
//     child: Card(...),
//   )
// ---------------------------------------------------------------------------

import 'package:flutter/material.dart';
import '../../core/theme/fomo_shield_theme.dart';

/// Pulsing red glow decoration for danger/panic states.
///
/// The glow is rendered as a [DecoratedBox] wrapping [child] with a
/// [BoxShadow] that pulses in intensity and spread.
class FearGlow extends StatefulWidget {
  /// The child to wrap with the glow effect.
  final Widget child;

  /// Glow intensity: 0.0 (off) to 1.0 (full).
  final double intensity;

  const FearGlow({
    super.key,
    required this.child,
    this.intensity = 0.6,
  });

  @override
  State<FearGlow> createState() => _FearGlowState();
}

class _FearGlowState extends State<FearGlow>
    with SingleTickerProviderStateMixin {
  late final AnimationController _controller;
  late final Animation<double> _pulseAnim;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: FomoShieldTheme.animFearGlow,
    )..repeat(reverse: true);

    _pulseAnim = CurvedAnimation(
      parent: _controller,
      curve: Curves.easeInOut,
    );
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _pulseAnim,
      builder: (context, child) {
        final t = _pulseAnim.value * widget.intensity;
        final glowColor = FomoShieldTheme.negative.withValues(alpha: t * 0.3);
        final blurRadius = 8.0 + t * 24.0;

        return DecoratedBox(
          decoration: BoxDecoration(
            borderRadius: FomoShieldTheme.cardRadius,
            boxShadow: [
              BoxShadow(
                color: glowColor,
                blurRadius: blurRadius,
                spreadRadius: t * 4.0,
              ),
            ],
          ),
          child: child,
        );
      },
      child: widget.child,
    );
  }
}
