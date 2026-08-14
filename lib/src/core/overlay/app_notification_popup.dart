import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:go_router/go_router.dart';
import '../models/app_notification.dart';
import '../notifications/notification_providers.dart';
import 'app_overlay_host.dart';
import '../../shared/widgets/company_logo.dart';

// ---------------------------------------------------------------------------
// App Notification Popup — plain white card, black text, slides down from
// the top of the screen over whatever is currently showing, holds, then
// slides back up. Renders via the global AppOverlayHost (app_overlay_host
// .dart) so it's visible regardless of which screen/tab triggered it and
// works from plain Dart notifier code with no BuildContext at all.
// ---------------------------------------------------------------------------

const Duration _enterDuration = Duration(milliseconds: 550);
const Duration _holdDuration = Duration(milliseconds: 3500);
const Duration _exitDuration = Duration(milliseconds: 450);

/// The one entry point every trigger site should call: records the
/// notification into history AND shows the popup. Safe to call from
/// anywhere — screens (has a BuildContext) or plain notifier code (doesn't).
void pushAppNotification(
  NotificationsNotifier notifier,
  AppNotification notification,
) {
  notifier.add(notification);
  showTransientAppNotificationPopup(notification);
}

/// Shows the popup card without recording it into notification history —
/// for confirmations that matter in the moment but don't belong in the
/// bell's history (e.g. "goal updated").
void showTransientAppNotificationPopup(AppNotification notification) {
  final overlayState = appOverlayKey.currentState;
  if (overlayState == null) return; // app not mounted yet — still recorded
  late OverlayEntry entry;
  entry = OverlayEntry(
    builder: (context) => _AppNotificationPopup(
      notification: notification,
      onFinished: () => entry.remove(),
      onTapDismiss: () => entry.remove(),
    ),
  );
  overlayState.insert(entry);
}

IconData _iconFor(AppNotificationType type) {
  switch (type) {
    case AppNotificationType.buy:
      return Icons.arrow_upward_rounded;
    case AppNotificationType.sell:
      return Icons.arrow_downward_rounded;
    case AppNotificationType.limitOrderPlaced:
      return Icons.schedule_rounded;
    case AppNotificationType.limitOrderFilled:
      return Icons.check_circle_rounded;
    case AppNotificationType.news:
      return Icons.article_rounded;
    case AppNotificationType.stressTestCompleted:
      return Icons.flag_rounded;
    case AppNotificationType.priceSwing:
      return Icons.bolt_rounded;
    case AppNotificationType.goalUpdated:
      return Icons.track_changes_rounded;
  }
}

class _AppNotificationPopup extends StatefulWidget {
  final AppNotification notification;
  final VoidCallback onFinished;
  final VoidCallback onTapDismiss;

  const _AppNotificationPopup({
    required this.notification,
    required this.onFinished,
    required this.onTapDismiss,
  });

  @override
  State<_AppNotificationPopup> createState() => _AppNotificationPopupState();
}

class _AppNotificationPopupState extends State<_AppNotificationPopup>
    with SingleTickerProviderStateMixin {
  late final AnimationController _controller;
  late final double _enterEnd;
  late final double _holdEnd;

  @override
  void initState() {
    super.initState();
    final total = _enterDuration + _holdDuration + _exitDuration;
    _enterEnd = _enterDuration.inMilliseconds / total.inMilliseconds;
    _holdEnd =
        (_enterDuration + _holdDuration).inMilliseconds / total.inMilliseconds;

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

  void _handleTap() {
    final n = widget.notification;
    if (n.type == AppNotificationType.stressTestCompleted &&
        n.portfolioId != null) {
      widget.onTapDismiss();
      final rootContext = appOverlayKey.currentContext;
      if (rootContext != null) {
        rootContext.go('/stress-test/${n.portfolioId}/verdict');
      }
      return;
    }
    widget.onTapDismiss();
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
          child: _card(),
        ),
      ),
    );
  }

  Widget _card() {
    final n = widget.notification;
    return GestureDetector(
      onTap: _handleTap,
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
          child: Row(
            children: [
              _leading(n),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(
                      n.title,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: GoogleFonts.inter(
                        fontSize: 14,
                        fontWeight: FontWeight.w700,
                        color: Colors.black,
                      ),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      n.detail,
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                      style: GoogleFonts.inter(
                        fontSize: 12.5,
                        fontWeight: FontWeight.w500,
                        color: Colors.black87,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _leading(AppNotification n) {
    if (n.symbol != null) {
      return _PopupLogo(symbol: n.symbol!, logoUrl: n.logoUrl);
    }
    return Container(
      width: 36,
      height: 36,
      decoration: const BoxDecoration(
        color: Color(0x141B365D),
        shape: BoxShape.circle,
      ),
      child: Icon(_iconFor(n.type), size: 20, color: const Color(0xFF1B365D)),
    );
  }
}

/// Small standalone logo circle for the popup — doesn't need Riverpod watch
/// reactivity (the popup is short-lived and the URL is already resolved by
/// the time the notification was created), just a direct render.
class _PopupLogo extends StatelessWidget {
  final String symbol;
  final String? logoUrl;

  const _PopupLogo({required this.symbol, this.logoUrl});

  @override
  Widget build(BuildContext context) {
    return CompanyLogo(ticker: symbol, logoUrl: logoUrl, radius: 18);
  }
}
