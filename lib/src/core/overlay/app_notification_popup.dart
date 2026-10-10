import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:go_router/go_router.dart';
import '../models/app_notification.dart';
import '../notifications/notification_providers.dart';
import '../notifications/notification_text.dart';
import '../theme/theme_v2.dart';
import 'app_overlay_host.dart';
import 'slide_down_card.dart';
import '../../l10n/gen/app_localizations.dart';
import '../../shared/widgets/company_logo.dart';

// ---------------------------------------------------------------------------
// App Notification Popup — a notification from the bell, shown in the moment
// it happens: logo or icon, title, one line of detail. The card and the
// motion live in slide_down_card.dart, shared since 2026-10-10 with the
// plain confirmations in app_banner.dart, so everything that drops in from
// the top of this app is the same object.
// ---------------------------------------------------------------------------

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
  // Not mounted yet means no card, which is fine: anything raised through
  // pushAppNotification above is already in the history by this point.
  showSlideDownCard(
    builder: (context, dismiss) =>
        _NotificationCard(notification: notification, onDismiss: dismiss),
  );
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
    case AppNotificationType.weeklyPayout:
      return Icons.savings_rounded;
    case AppNotificationType.weeklyPayoutPaused:
      return Icons.pause_circle_rounded;
    case AppNotificationType.subscriptionStatusChanged:
      return Icons.workspace_premium_rounded;
    case AppNotificationType.fundLiquidation:
      return Icons.account_balance_rounded;
  }
}

/// Buy/sell get their title colored green/red — a tester bought the same
/// asset twice because the plain-black title next to a small icon didn't
/// read as clear confirmation that the trade actually went through. Shared
/// by the transient popup here AND the bell-icon history list
/// (notifications_screen.dart), so a trade reads the same color in both
/// places. Everything else keeps the caller's own neutral [fallback].
Color notificationTitleColor(
  AppNotificationType type, {
  required Color fallback,
}) {
  switch (type) {
    case AppNotificationType.buy:
      return ThemeV2.success;
    case AppNotificationType.sell:
      return ThemeV2.loss;
    case AppNotificationType.limitOrderPlaced:
    case AppNotificationType.limitOrderFilled:
    case AppNotificationType.news:
    case AppNotificationType.stressTestCompleted:
    case AppNotificationType.priceSwing:
    case AppNotificationType.goalUpdated:
    case AppNotificationType.weeklyPayout:
    case AppNotificationType.weeklyPayoutPaused:
    case AppNotificationType.subscriptionStatusChanged:
    case AppNotificationType.fundLiquidation:
      return fallback;
  }
}

class _NotificationCard extends StatelessWidget {
  final AppNotification notification;
  final VoidCallback onDismiss;

  const _NotificationCard({
    required this.notification,
    required this.onDismiss,
  });

  /// A finished stress test is the one notification with somewhere to go, so
  /// a tap takes the card away and opens the verdict. Every other tap just
  /// gets the card out of the way.
  void _handleTap() {
    final n = notification;
    onDismiss();
    if (n.type == AppNotificationType.stressTestCompleted &&
        n.portfolioId != null) {
      final rootContext = appOverlayKey.currentContext;
      if (rootContext != null) {
        rootContext.go('/stress-test/${n.portfolioId}/verdict');
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final n = notification;
    final l10n = AppLocalizations.of(context)!;
    return slideDownCardShell(
      onTap: _handleTap,
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
                  notificationTitle(n, l10n),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: GoogleFonts.inter(
                    fontSize: 14,
                    fontWeight: FontWeight.w700,
                    color: notificationTitleColor(
                      n.type,
                      fallback: Colors.black,
                    ),
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  notificationDetail(n, l10n),
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
    );
  }

  Widget _leading(AppNotification n) {
    if (n.symbol != null) {
      return _PopupLogo(symbol: n.symbol!, logoUrl: n.logoUrl);
    }
    return slideDownCardBadge(
      icon: _iconFor(n.type),
      color: const Color(0xFF1B365D),
      background: const Color(0x141B365D),
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
