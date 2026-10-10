import 'package:flutter/material.dart';

import 'app_overlay_host.dart';

// ---------------------------------------------------------------------------
// Slide-down card — the shell and the motion shared by everything that drops
// in over the top of the app and leaves again on its own.
//
// Extracted from app_notification_popup.dart on 2026-10-10, when
// confirmations ("анкета сохранена", "права сохранены") moved off the
// bottom SnackBar and onto the same card. Extracted rather than copied: the
// timings below were tuned on a real device -- the opacity ramp exists
// because a pure slide from an opaque off-screen start read as an abrupt pop
// the moment it cleared the top edge -- and a second hand-made copy would
// drift from that the first time either one was touched.
//
// Renders through the app-wide AppOverlayHost, so a card shows over every
// screen and tab, and can be raised from plain notifier code that holds no
// BuildContext at all.
// ---------------------------------------------------------------------------

const Duration _enterDuration = Duration(milliseconds: 550);
const Duration defaultSlideDownHold = Duration(milliseconds: 3500);
const Duration _exitDuration = Duration(milliseconds: 450);

/// Drops a card built by [builder] in from the top, holds it for [hold], then
/// takes it back up. The callback handed to [builder] removes the card early
/// -- wire it to a tap so the card is never in the way.
///
/// Answers false when the app's overlay is not mounted yet (before the first
/// frame); nothing is shown in that case, and a caller who must not lose its
/// message should say so some other way.
/// Whatever is on screen right now, so the next card can take its place.
/// One slot, deliberately: both cards are pinned to the top edge, so a
/// second one does not queue behind the first the way a SnackBar did -- it
/// lands exactly on top of it, and the two animate through each other. The
/// newest message is the one worth reading, so it evicts the old one instead.
VoidCallback? _dismissCurrent;

bool showSlideDownCard({
  required Widget Function(BuildContext context, VoidCallback dismiss) builder,
  Duration hold = defaultSlideDownHold,
}) {
  final overlayState = appOverlayKey.currentState;
  if (overlayState == null) return false;

  _dismissCurrent?.call();

  late OverlayEntry entry;
  var removed = false;
  void remove() {
    if (removed) return;
    removed = true;
    if (_dismissCurrent == remove) _dismissCurrent = null;
    entry.remove();
  }

  _dismissCurrent = remove;

  entry = OverlayEntry(
    builder: (context) => _SlideDownHost(
      hold: hold,
      onFinished: remove,
      child: builder(context, remove),
    ),
  );
  overlayState.insert(entry);
  return true;
}

/// The card itself: white, rounded, shadowed, inset from the screen edges.
/// Deliberately one fixed look rather than a themed one -- it floats over
/// whichever screen happens to be showing, including the dark admin themes,
/// and a card that changed colour underneath the same message would read as a
/// different kind of message.
Widget slideDownCardShell({required Widget child, VoidCallback? onTap}) {
  return GestureDetector(
    onTap: onTap,
    behavior: HitTestBehavior.opaque,
    child: Material(
      color: Colors.transparent,
      child: Container(
        margin: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(16),
          boxShadow: const [
            BoxShadow(
              color: Colors.black26,
              blurRadius: 16,
              offset: Offset(0, 6),
            ),
          ],
        ),
        child: child,
      ),
    ),
  );
}

/// A round tinted badge for the card's leading slot, matching the one the
/// notification popup has always drawn.
Widget slideDownCardBadge({
  required IconData icon,
  required Color color,
  Color? background,
}) {
  return Container(
    width: 36,
    height: 36,
    decoration: BoxDecoration(
      color: background ?? color.withValues(alpha: 0.12),
      shape: BoxShape.circle,
    ),
    child: Icon(icon, size: 20, color: color),
  );
}

class _SlideDownHost extends StatefulWidget {
  final Widget child;
  final Duration hold;
  final VoidCallback onFinished;

  const _SlideDownHost({
    required this.child,
    required this.hold,
    required this.onFinished,
  });

  @override
  State<_SlideDownHost> createState() => _SlideDownHostState();
}

class _SlideDownHostState extends State<_SlideDownHost>
    with SingleTickerProviderStateMixin {
  late final AnimationController _controller;
  late final double _enterEnd;
  late final double _holdEnd;

  @override
  void initState() {
    super.initState();
    final total = _enterDuration + widget.hold + _exitDuration;
    _enterEnd = _enterDuration.inMilliseconds / total.inMilliseconds;
    _holdEnd =
        (_enterDuration + widget.hold).inMilliseconds / total.inMilliseconds;

    _controller = AnimationController(vsync: this, duration: total)
      ..addStatusListener((status) {
        if (status == AnimationStatus.completed) widget.onFinished();
      })
      ..forward();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Positioned(
      top: 0,
      left: 0,
      right: 0,
      child: SafeArea(
        bottom: false,
        child: AnimatedBuilder(
          animation: _controller,
          builder: (context, child) {
            final t = _controller.value;
            double translateY;
            double opacity;

            if (t < _enterEnd) {
              final p = Curves.easeInOutCubic.transform(t / _enterEnd);
              translateY = -120 * (1 - p);
              // Fades in alongside the slide — a pure slide from a
              // fully-opaque, off-screen start still reads as an abrupt
              // "pop" the instant it clears the top edge; easing opacity
              // in over the same interval softens that first moment.
              opacity = p;
            } else if (t < _holdEnd) {
              translateY = 0;
              opacity = 1;
            } else {
              final exitP = (t - _holdEnd) / (1 - _holdEnd);
              translateY = -120 * Curves.easeInCubic.transform(exitP);
              opacity = 1;
            }

            return Transform.translate(
              offset: Offset(0, translateY),
              child: Opacity(opacity: opacity, child: child),
            );
          },
          child: widget.child,
        ),
      ),
    );
  }
}
