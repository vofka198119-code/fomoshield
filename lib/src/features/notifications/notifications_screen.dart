import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../core/theme/fomo_shield_theme.dart';
import '../../core/theme/app_palette.dart';
import '../../core/theme/theme_variant_provider.dart';
import '../../core/theme/themed_header.dart';
import '../../core/theme/themed_divider.dart';
import '../../shared/widgets/card_frame.dart';
import '../../core/models/app_notification.dart';
import '../../core/notifications/notification_providers.dart';
import '../../core/notifications/notification_text.dart';
import '../../core/overlay/app_notification_popup.dart';
import '../../l10n/gen/app_localizations.dart';
import '../../shared/widgets/company_logo.dart';
import '../../shared/widgets/more_less_pill.dart';
import '../portfolio/portfolio_providers.dart';
import '../stress_test/stress_test_engine.dart';

// Rows are revealed 6 at a time (MoreLessPill below the list) instead of
// all at once — every row's CompanyLogo fires its own fetch the moment
// it's built, and a long history otherwise fires all of them in one
// SingleChildScrollView build (same reasoning as
// search/widgets/company_list_screen.dart's own reveal cap).
const int _revealBatchSize = 6;

// ---------------------------------------------------------------------------
// Notifications Screen — bell-icon history. One card, compact rows; the
// title/detail text is always visible (no expand/collapse step — see
// 2026-08-23 project memory for why that round-tripped a few times), and
// tapping anywhere on a row navigates to whatever it's about: Verdict for
// a completion, the symbol for a trade confirmation/price swing/news,
// Portfolio for a goal/payout update, Profile for a subscription change.
// A type with nothing to navigate to (missing symbol/portfolioId) just
// marks itself read.
// ---------------------------------------------------------------------------

class NotificationsScreen extends ConsumerStatefulWidget {
  const NotificationsScreen({super.key});

  @override
  ConsumerState<NotificationsScreen> createState() =>
      _NotificationsScreenState();
}

class _NotificationsScreenState extends ConsumerState<NotificationsScreen> {
  int _revealedCount = _revealBatchSize;

  void _handleTap(AppNotification n) {
    ref.read(notificationsProvider.notifier).markRead(n.id);

    if (n.type == AppNotificationType.stressTestCompleted &&
        n.portfolioId != null) {
      context.go('/stress-test/${n.portfolioId}/verdict');
      return;
    }
    if (n.type == AppNotificationType.weeklyPayout ||
        n.type == AppNotificationType.weeklyPayoutPaused) {
      context.push('/notifications/weekly-payout-detail', extra: n);
      return;
    }
    if (n.type == AppNotificationType.subscriptionStatusChanged) {
      context.go('/profile');
      return;
    }
    if (n.type == AppNotificationType.goalUpdated) {
      context.go('/portfolio');
      return;
    }
    // A trade confirmation (market buy/sell, immediate, OR a limit order
    // that just filled) should open that exact fill's own detail screen,
    // not just the company page, so the user can see what actually
    // happened. Falls through to the company page below if the trade can
    // no longer be found (e.g. a very old notification outliving its
    // portfolio).
    if ((n.type == AppNotificationType.buy ||
            n.type == AppNotificationType.sell ||
            n.type == AppNotificationType.limitOrderFilled) &&
        n.portfolioId != null) {
      if (n.portfolioKind == NotificationPortfolioKind.stressTest) {
        final session = ref
            .read(stressTestProvider)
            .where((s) => s.id == n.portfolioId)
            .firstOrNull;
        final trade = n.tradeTimestamp == null
            ? null
            : session?.trades
                  .where(
                    (t) => t.date == n.tradeTimestamp && t.symbol == n.symbol,
                  )
                  .firstOrNull;
        if (trade != null) {
          context.push(
            '/stress-test/${n.portfolioId}/trade-detail',
            extra: trade,
          );
          return;
        }
      } else {
        final portfolio = ref
            .read(portfoliosProvider)
            .where((p) => p.id == n.portfolioId)
            .firstOrNull;
        final tx = n.orderId == null
            ? null
            : portfolio?.transactions
                  .where((t) => t.orderId == n.orderId)
                  .firstOrNull;
        if (tx != null) {
          context.push('/portfolio/${n.portfolioId}/trade-detail', extra: tx);
          return;
        }
      }
    }
    // Everything else (buy/sell/limit orders, priceSwing, news) points at
    // one specific symbol — jump there. Safe now that the row's own text
    // is always visible (see file header) instead of only showing on tap,
    // so navigating away never loses the one thing worth reading on it.
    if (n.portfolioKind == NotificationPortfolioKind.stressTest &&
        n.portfolioId != null) {
      if (n.symbol != null) {
        context.push('/stress-test/${n.portfolioId}/stock/${n.symbol}');
      } else {
        context.go('/stress-test/${n.portfolioId}');
      }
    } else if (n.symbol != null) {
      context.push(
        '/company/${n.symbol}',
        extra: {'portfolioId': n.portfolioId},
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final notifications = ref.watch(notificationsProvider);
    final unread = ref.watch(unreadNotificationCountProvider);
    final palette = resolveAppPalette(ref.watch(themeVariantProvider));

    return Scaffold(
      backgroundColor: Colors.transparent,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        centerTitle: true,
        leading: themedBackButton(context, palette),
        title: FittedBox(
          fit: BoxFit.scaleDown,
          child: themedHeaderText(
            l10n.notificationsScreenTitle,
            palette,
            GoogleFonts.inter(
              fontSize: 20,
              fontWeight: FontWeight.w800,
              letterSpacing: 1.5,
            ),
            maxLines: 1,
          ),
        ),
        actions: [
          if (unread > 0)
            IconButton(
              onPressed: () =>
                  ref.read(notificationsProvider.notifier).markAllRead(),
              tooltip: l10n.notificationsScreenMarkAllRead,
              icon: Icon(Icons.done_all_rounded, color: palette.accentPrimary),
            ),
        ],
      ),
      body: SafeArea(
        bottom: true,
        top: false,
        left: false,
        right: false,
        child: notifications.isEmpty
            ? _emptyState(l10n, palette)
            : SingleChildScrollView(
                padding: const EdgeInsets.fromLTRB(16, 8, 16, 32),
                child: CardFrame(
                  padding: EdgeInsets.zero,
                  decoration: FomoShieldTheme.cardDecoration,
                  palette: palette,
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      for (
                        int i = 0;
                        i < _revealedCount.clamp(0, notifications.length);
                        i++
                      ) ...[
                        if (i > 0)
                          palette.dividerGradient != null
                              ? themedDivider(palette, indent: 68, endIndent: 0)
                              : const Divider(
                                  height: 1,
                                  indent: 68,
                                  color: Color(0x0F000000),
                                ),
                        _NotificationRow(
                          notification: notifications[i],
                          onTap: () => _handleTap(notifications[i]),
                          palette: palette,
                        ),
                      ],
                      if (_revealedCount < notifications.length)
                        MoreLessPill(
                          label: l10n.commonMoreCount(
                            notifications.length - _revealedCount,
                          ),
                          onTap: () => setState(
                            () => _revealedCount += _revealBatchSize,
                          ),
                          palette: palette,
                        ),
                    ],
                  ),
                ),
              ),
      ),
    );
  }

  Widget _emptyState(AppLocalizations l10n, AppPalette palette) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32),
        child: Text(
          l10n.notificationsScreenEmptyState,
          style: GoogleFonts.inter(fontSize: 14, color: palette.textBody),
        ),
      ),
    );
  }
}

class _NotificationRow extends StatelessWidget {
  final AppNotification notification;
  final VoidCallback onTap;
  final AppPalette palette;

  const _NotificationRow({
    required this.notification,
    required this.onTap,
    required this.palette,
  });

  IconData get _icon {
    switch (notification.type) {
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
    }
  }

  String _relativeTime(AppLocalizations l10n) {
    final diff = DateTime.now().difference(notification.createdAt);
    if (diff.inMinutes < 1) return l10n.notificationsRelativeTimeJustNow;
    if (diff.inMinutes < 60) {
      return l10n.notificationsRelativeTimeMinutesAgo(diff.inMinutes);
    }
    if (diff.inHours < 24) {
      return l10n.notificationsRelativeTimeHoursAgo(diff.inHours);
    }
    return l10n.notificationsRelativeTimeDaysAgo(diff.inDays);
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    return InkWell(
      onTap: onTap,
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                _leading(),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          if (!notification.read)
                            Container(
                              width: 7,
                              height: 7,
                              margin: const EdgeInsets.only(right: 6),
                              decoration: BoxDecoration(
                                color: palette.accentPrimary,
                                shape: BoxShape.circle,
                              ),
                            ),
                          Expanded(
                            child: Text(
                              notificationTitle(notification, l10n),
                              // 2 lines, not 1 — the limit-order titles
                              // ("Покупка (Лимитная): ордер выставлен")
                              // run noticeably longer in Russian than the
                              // plain "Вы купили" ones and were getting
                              // cut off mid-word (confirmed on-device
                              // 2026-09-04).
                              maxLines: 2,
                              overflow: TextOverflow.ellipsis,
                              style: GoogleFonts.inter(
                                fontSize: 14,
                                fontWeight: FontWeight.w600,
                                color: notificationTitleColor(
                                  notification.type,
                                  fallback: palette.textHeader,
                                ),
                              ),
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 2),
                      Text(
                        notification.portfolioLabel ?? _relativeTime(l10n),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: GoogleFonts.inter(
                          fontSize: 11.5,
                          color: palette.textBody,
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(width: 8),
                Text(
                  _relativeTime(l10n),
                  style: GoogleFonts.inter(
                    fontSize: 11,
                    color: palette.textBody,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 10),
            Padding(
              padding: const EdgeInsets.only(left: 48),
              child: Text(
                notificationDetail(notification, l10n),
                style: GoogleFonts.inter(
                  fontSize: 12.5,
                  color: palette.textHeader,
                  height: 1.4,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _leading() {
    if (notification.symbol != null) {
      return Container(
        padding: const EdgeInsets.all(2),
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          border: Border.all(color: palette.accentPrimary, width: 1.5),
        ),
        child: CompanyLogo(
          ticker: notification.symbol!,
          logoUrl: notification.logoUrl,
          radius: 16,
        ),
      );
    }
    // Fixed navy icon-on-navy-tint — invisible against Luxury Gold's dark
    // backdrop (this circle has no card of its own behind it, so the
    // near-transparent 8%-alpha tint reads as basically the same near-
    // black as the screen background). Swap to the theme's own gold
    // accent under Luxury; Standard keeps the original navy untouched.
    final isLuxury = palette.titleGradient != null;
    final iconColor = isLuxury
        ? palette.accentPrimary
        : const Color(0xFF1B365D);
    final iconBg = isLuxury
        ? palette.accentPrimary.withValues(alpha: 0.12)
        : const Color(0x141B365D);
    return Container(
      width: 36,
      height: 36,
      decoration: BoxDecoration(color: iconBg, shape: BoxShape.circle),
      child: Icon(_icon, size: 18, color: iconColor),
    );
  }
}
