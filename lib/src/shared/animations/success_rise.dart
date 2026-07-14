// ---------------------------------------------------------------------------
// SuccessRise — Scale up + fade out for success events (Design Bible Part 8)
// ---------------------------------------------------------------------------
// Анимация успеха: scale 0.8 → 1.0 + fade 1.0 → 0.0 за 0.8s.
// Используется для подтверждения действий, бейджей, достижений.
//
// Usage:
//   SuccessRise(
//     child: Icon(Icons.check_circle, color: Colors.green, size: 64),
//   )
// ---------------------------------------------------------------------------

import 'package:flutter/material.dart';
import '../../core/theme/fomo_shield_theme.dart';

/// Scale-up + fade-out success animation.
///
/// Автоматически запускается при вставке в дерево виджетов.
/// После завершения анимации виджет становится невидимым (opacity: 0).
class SuccessRise extends StatefulWidget {
  /// The widget to animate (e.g., an icon or badge).
  final Widget child;

  /// Whether to play the animation automatically on init.
  final bool autoPlay;

  const SuccessRise({
    super.key,
    required this.child,
    this.autoPlay = true,
  });

  @override
  State<SuccessRise> createState() => _SuccessRiseState();
}

class _SuccessRiseState extends State<SuccessRise>
    with SingleTickerProviderStateMixin {
  late final AnimationController _controller;
  late final Animation<double> _scaleAnim;
  late final Animation<double> _fadeAnim;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: FomoShieldTheme.animSuccessRise,
    );

    _scaleAnim = Tween<double>(
      begin: 0.8,
      end: 1.0,
    ).animate(CurvedAnimation(
      parent: _controller,
      curve: Curves.easeOutBack,
    ));

    _fadeAnim = Tween<double>(
      begin: 1.0,
      end: 0.0,
    ).animate(CurvedAnimation(
      parent: _controller,
      curve: const Interval(0.3, 1.0, curve: Curves.easeOut),
    ));

    if (widget.autoPlay) {
      _controller.forward();
    }
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _controller,
      builder: (context, child) {
        return Opacity(
          opacity: _fadeAnim.value,
          child: Transform.scale(
            scale: _scaleAnim.value,
            child: child,
          ),
        );
      },
      child: widget.child,
    );
  }
}
