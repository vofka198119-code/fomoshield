// ---------------------------------------------------------------------------
// ChartGrow — Clip-path growth for charts (Design Bible Part 8)
// ---------------------------------------------------------------------------
// Анимация роста графика: clip от bottom (0%) до full (100%) за 0.6s.
//
// Usage:
//   ChartGrow(
//     child: MyCustomChart(),
//   )
// ---------------------------------------------------------------------------

import 'package:flutter/material.dart';
import '../../core/theme/fomo_shield_theme.dart';

/// Animates a chart growing from bottom to full height using a clip rect.
///
/// Длительность: [FomoShieldTheme.animChartGrow] (600ms).
/// Автоматически запускается при вставке в дерево виджетов.
class ChartGrow extends StatefulWidget {
  /// The chart widget to animate.
  final Widget child;

  /// Whether to play the animation automatically on init.
  final bool autoPlay;

  /// Optional delay before starting the animation.
  final Duration delay;

  const ChartGrow({
    super.key,
    required this.child,
    this.autoPlay = true,
    this.delay = Duration.zero,
  });

  @override
  State<ChartGrow> createState() => _ChartGrowState();
}

class _ChartGrowState extends State<ChartGrow>
    with SingleTickerProviderStateMixin {
  late final AnimationController _controller;
  late final Animation<double> _growAnim;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: FomoShieldTheme.animChartGrow,
    );

    _growAnim = CurvedAnimation(
      parent: _controller,
      curve: Curves.easeOutCubic,
    );

    if (widget.autoPlay) {
      Future.delayed(widget.delay, () => _controller.forward());
    }
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  /// Triggers the growth animation again (useful on data refresh).
  void trigger() => _controller.forward(from: 0.0);

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _growAnim,
      builder: (context, child) {
        return ClipRect(
          clipper: _ChartGrowClipper(_growAnim.value),
          child: child,
        );
      },
      child: widget.child,
    );
  }
}

/// Clips the child from bottom upward based on [progress] (0.0 → 1.0).
class _ChartGrowClipper extends CustomClipper<Rect> {
  final double progress;

  const _ChartGrowClipper(this.progress);

  @override
  Rect getClip(Size size) {
    return Rect.fromLTWH(
      0.0,
      size.height * (1.0 - progress),
      size.width,
      size.height * progress,
    );
  }

  @override
  bool shouldReclip(_ChartGrowClipper oldClipper) =>
      oldClipper.progress != progress;
}
