import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../../../core/theme/theme_v2.dart';
import '../../../../core/theme/fomo_shield_theme.dart';

// ---------------------------------------------------------------------------
// Trade Confirmation Toast — replaces the bottom SnackBar shown after a
// buy/sell. A small light card pops in at the center of the screen, holds,
// then swipes down toward the bottom of the screen while fading out.
// Inserted directly into the nearest Overlay (not a route/showDialog) so it
// survives the order entry screen popping right after it's shown — see
// project_fomo_shield_target_dialog_invisible_bug memory for why this
// deliberately avoids showDialog for anything beyond static alerts.
// ---------------------------------------------------------------------------

const Duration _enterDuration = Duration(milliseconds: 250);
const Duration _holdDuration = Duration(milliseconds: 3000);
const Duration _exitDuration = Duration(milliseconds: 550);

// The exit fade only kicks in once the card is already most of the way
// through its downward slide, so it reads as a swipe-away rather than a
// fade that happens to drift slightly.
const double _exitFadeStartFraction = 0.35;

void showTradeConfirmationToast(
  BuildContext context, {
  required String title,
  required String subtitle,
  required IconData icon,
  required Color accentColor,
}) {
  final overlay = Overlay.of(context);
  final screenHeight = MediaQuery.of(context).size.height;
  late OverlayEntry entry;
  entry = OverlayEntry(
    builder: (_) => _TradeConfirmationToast(
      title: title,
      subtitle: subtitle,
      icon: icon,
      accentColor: accentColor,
      exitTravel: screenHeight * 0.32,
      onFinished: () => entry.remove(),
    ),
  );
  overlay.insert(entry);
}

class _TradeConfirmationToast extends StatefulWidget {
  final String title;
  final String subtitle;
  final IconData icon;
  final Color accentColor;
  final double exitTravel;
  final VoidCallback onFinished;

  const _TradeConfirmationToast({
    required this.title,
    required this.subtitle,
    required this.icon,
    required this.accentColor,
    required this.exitTravel,
    required this.onFinished,
  });

  @override
  State<_TradeConfirmationToast> createState() => _TradeConfirmationToastState();
}

class _TradeConfirmationToastState extends State<_TradeConfirmationToast>
    with SingleTickerProviderStateMixin {
  late final AnimationController _controller;
  late final double _enterEnd;
  late final double _holdEnd;

  @override
  void initState() {
    super.initState();
    final total = _enterDuration + _holdDuration + _exitDuration;
    _enterEnd = _enterDuration.inMilliseconds / total.inMilliseconds;
    _holdEnd = (_enterDuration + _holdDuration).inMilliseconds / total.inMilliseconds;

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
    return Positioned.fill(
      child: IgnorePointer(
        child: Material(
          type: MaterialType.transparency,
          child: AnimatedBuilder(
            animation: _controller,
            builder: (context, child) {
              final t = _controller.value;
              double opacity;
              double translateY = 0;
              double scale = 1;

              if (t < _enterEnd) {
                final p = Curves.easeOut.transform(t / _enterEnd);
                opacity = p;
                scale = 0.88 + 0.12 * Curves.easeOutBack.transform(t / _enterEnd);
              } else if (t < _holdEnd) {
                opacity = 1;
              } else {
                final exitP = (t - _holdEnd) / (1 - _holdEnd);
                translateY = Curves.easeIn.transform(exitP) * widget.exitTravel;
                if (exitP < _exitFadeStartFraction) {
                  opacity = 1;
                } else {
                  final fadeP = (exitP - _exitFadeStartFraction) / (1 - _exitFadeStartFraction);
                  opacity = 1 - Curves.easeIn.transform(fadeP);
                }
              }

              return Center(
                child: Transform.translate(
                  offset: Offset(0, translateY),
                  child: Opacity(
                    opacity: opacity,
                    child: Transform.scale(scale: scale, child: child),
                  ),
                ),
              );
            },
            child: _card(),
          ),
        ),
      ),
    );
  }

  Widget _card() {
    return ConstrainedBox(
      constraints: const BoxConstraints(maxWidth: 340),
      child: Container(
        margin: const EdgeInsets.symmetric(horizontal: 20),
        padding: const EdgeInsets.symmetric(horizontal: 22, vertical: 20),
        decoration: BoxDecoration(
          color: FomoShieldTheme.card,
          borderRadius: BorderRadius.circular(FomoShieldTheme.radius),
          border: Border.all(color: ThemeV2.primary, width: 2),
          boxShadow: FomoShieldTheme.shadowHeavy,
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            Container(
              width: 46,
              height: 46,
              decoration: BoxDecoration(
                color: widget.accentColor.withValues(alpha: 0.12),
                shape: BoxShape.circle,
              ),
              child: Icon(widget.icon, color: widget.accentColor, size: 25),
            ),
            const SizedBox(width: 14),
            Flexible(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    widget.title,
                    style: GoogleFonts.inter(
                      fontSize: 17,
                      fontWeight: FontWeight.w700,
                      color: FomoShieldTheme.text,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    widget.subtitle,
                    style: GoogleFonts.inter(
                      fontSize: 14,
                      fontWeight: FontWeight.w500,
                      color: FomoShieldTheme.textLight,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
