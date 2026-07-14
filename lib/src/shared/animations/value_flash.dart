// ---------------------------------------------------------------------------
// ValueFlash — Flash overlay for value changes (Design Bible Part 8)
// ---------------------------------------------------------------------------
// Вспышка при изменении значения: зелёная (+), красная (-).
// Исчезает через 0.4s (animValueFlash).
//
// Usage:
//   ValueFlash(
//     value: currentValue,     // triggers flash on change
//     isPositive: true,
//     child: Text('$currentValue'),
//   )
// ---------------------------------------------------------------------------

import 'package:flutter/material.dart';
import '../../core/theme/fomo_shield_theme.dart';

/// Wraps [child] and shows a colored flash overlay whenever [value] changes.
///
/// Flash colour: green for [isPositive], red otherwise.
/// Duration: [FomoShieldTheme.animValueFlash] (400ms).
class ValueFlash extends StatefulWidget {
  /// The watched value — triggers flash when it changes.
  final dynamic value;

  /// Whether this value represents a positive change.
  final bool isPositive;

  /// The child widget (typically the displayed value).
  final Widget child;

  const ValueFlash({
    super.key,
    required this.value,
    required this.isPositive,
    required this.child,
  });

  @override
  State<ValueFlash> createState() => _ValueFlashState();
}

class _ValueFlashState extends State<ValueFlash>
    with SingleTickerProviderStateMixin {
  late final AnimationController _controller;
  late final Animation<double> _flashAnim;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: FomoShieldTheme.animValueFlash,
    );
    _flashAnim = CurvedAnimation(
      parent: _controller,
      curve: Curves.easeOut,
    );
  }

  @override
  void didUpdateWidget(ValueFlash oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.value != oldWidget.value) {
      _controller.forward(from: 0.0);
    }
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final flashColor = widget.isPositive
        ? FomoShieldTheme.positive.withValues(alpha: 0.15)
        : FomoShieldTheme.negative.withValues(alpha: 0.15);

    return AnimatedBuilder(
      animation: _flashAnim,
      builder: (context, child) {
        return Container(
          decoration: BoxDecoration(
            color: _controller.isAnimating
                ? flashColor.withValues(alpha: _flashAnim.value * 0.15)
                : Colors.transparent,
            borderRadius: BorderRadius.circular(4),
          ),
          child: child,
        );
      },
      child: widget.child,
    );
  }
}
