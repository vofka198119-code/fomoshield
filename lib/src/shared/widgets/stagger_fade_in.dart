import 'package:flutter/material.dart';

// ---------------------------------------------------------------------------
// Stagger Fade-In — top-to-bottom cascade entrance for a screen's widget
// list: each slot fades + slides up shortly after the one above it,
// instead of everything popping into place at once. Originally built for
// Company Detail (masks async layout reflow there); shared so Home,
// Portfolio, and Search's browse lanes use the exact same rhythm. Runs
// once per widget instance — wrap each item in a `KeyedSubtree` with a
// stable key so it doesn't replay on every rebuild.
//
// [anchorTime] is for lazily-built lists (`ListView.builder`/`.separated`):
// without it, delay is counted from this widget's own `initState` — fine
// when every item builds eagerly at once (Home/Portfolio/Company Detail),
// but wrong for a lazy list, where an item built late (because the user
// scrolled to it) would still wait its full `index`-based delay from that
// later moment, arriving noticeably behind the scroll instead of already
// being there. With [anchorTime] set (captured once, e.g. in the parent's
// `initState`), delay counts from that shared start instead — an item
// whose slot time has already passed shows immediately, no artificial
// wait. [maxDelay] caps the total cascade window regardless of list
// length, so a long list doesn't take forever to finish revealing.
// ---------------------------------------------------------------------------

class StaggerFadeIn extends StatefulWidget {
  final int index;
  final Widget child;
  final Duration delayPerIndex;
  final Duration duration;
  final DateTime? anchorTime;
  final Duration? maxDelay;

  const StaggerFadeIn({
    super.key,
    required this.index,
    required this.child,
    this.delayPerIndex = const Duration(milliseconds: 70),
    this.duration = const Duration(milliseconds: 350),
    this.anchorTime,
    this.maxDelay,
  });

  @override
  State<StaggerFadeIn> createState() => _StaggerFadeInState();
}

class _StaggerFadeInState extends State<StaggerFadeIn>
    with SingleTickerProviderStateMixin {
  late final AnimationController _controller;
  late final Animation<double> _fade;
  late final Animation<Offset> _slide;

  Duration get _delay {
    var raw = widget.delayPerIndex * widget.index;
    final cap = widget.maxDelay;
    if (cap != null && raw > cap) raw = cap;

    final anchor = widget.anchorTime;
    if (anchor == null) return raw;

    final remaining = anchor.add(raw).difference(DateTime.now());
    return remaining.isNegative ? Duration.zero : remaining;
  }

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(vsync: this, duration: widget.duration);
    _fade = CurvedAnimation(parent: _controller, curve: Curves.easeOut);
    _slide = Tween<Offset>(begin: const Offset(0, 0.06), end: Offset.zero).animate(_fade);
    Future.delayed(_delay, () {
      if (mounted) _controller.forward();
    });
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return FadeTransition(
      opacity: _fade,
      child: SlideTransition(position: _slide, child: widget.child),
    );
  }
}
