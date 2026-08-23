import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../core/theme/theme_v2.dart';
import '../../core/theme/fomo_shield_theme.dart';
import '../../core/models/app_notification.dart';
import '../../core/notifications/notification_providers.dart';
import '../../core/overlay/app_notification_popup.dart';
import '../../l10n/gen/app_localizations.dart';
import '../../shared/widgets/company_logo.dart';

// ---------------------------------------------------------------------------
// Notifications Screen — bell-icon history. One card, compact rows; tap
// expands inline details, EXCEPT stress-test-completion rows, which jump
// straight to that session's Verdict per explicit spec.
// ---------------------------------------------------------------------------

class NotificationsScreen extends ConsumerStatefulWidget {
  const NotificationsScreen({super.key});

  @override
  ConsumerState<NotificationsScreen> createState() =>
      _NotificationsScreenState();
}

class _NotificationsScreenState extends ConsumerState<NotificationsScreen> {
  final Set<String> _expandedIds = {};

  void _handleTap(AppNotification n) {
    ref.read(notificationsProvider.notifier).markRead(n.id);
    if (n.type == AppNotificationType.stressTestCompleted &&
        n.portfolioId != null) {
      context.go('/stress-test/${n.portfolioId}/verdict');
      return;
    }
    if (n.type == AppNotificationType.weeklyPayout) {
      if (n.portfolioKind == NotificationPortfolioKind.stressTest &&
          n.portfolioId != null) {
        context.go('/stress-test/${n.portfolioId}');
      } else {
        context.go('/portfolio');
      }
      return;
    }
    setState(() {
      if (_expandedIds.contains(n.id)) {
        _expandedIds.remove(n.id);
      } else {
        _expandedIds.add(n.id);
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final notifications = ref.watch(notificationsProvider);
    final unread = ref.watch(unreadNotificationCountProvider);

    return Scaffold(
      backgroundColor: Colors.transparent,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        centerTitle: true,
        title: Text(
          l10n.notificationsScreenTitle,
          style: GoogleFonts.inter(
            fontSize: 20,
            fontWeight: FontWeight.w800,
            color: ThemeV2.primary,
            letterSpacing: 1.5,
          ),
        ),
        actions: [
          if (unread > 0)
            TextButton(
              onPressed: () =>
                  ref.read(notificationsProvider.notifier).markAllRead(),
              child: Text(
                l10n.notificationsScreenMarkAllRead,
                style: GoogleFonts.inter(
                  fontSize: 13,
                  fontWeight: FontWeight.w600,
                  color: ThemeV2.primary,
                ),
              ),
            ),
        ],
      ),
      body: SafeArea(
        bottom: true,
        top: false,
        left: false,
        right: false,
        child: notifications.isEmpty
            ? _emptyState(l10n)
            : SingleChildScrollView(
                padding: const EdgeInsets.fromLTRB(16, 8, 16, 32),
                child: Container(
                  decoration: FomoShieldTheme.cardDecoration,
                  clipBehavior: Clip.antiAlias,
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      for (int i = 0; i < notifications.length; i++) ...[
                        if (i > 0)
                          const Divider(
                            height: 1,
                            indent: 68,
                            color: Color(0x0F000000),
                          ),
                        _NotificationRow(
                          notification: notifications[i],
                          expanded: _expandedIds.contains(notifications[i].id),
                          onTap: () => _handleTap(notifications[i]),
                        ),
                      ],
                    ],
                  ),
                ),
              ),
      ),
    );
  }

  Widget _emptyState(AppLocalizations l10n) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32),
        child: Text(
          l10n.notificationsScreenEmptyState,
          style: GoogleFonts.inter(fontSize: 14, color: ThemeV2.textSecondary),
        ),
      ),
    );
  }
}

class _NotificationRow extends StatelessWidget {
  final AppNotification notification;
  final bool expanded;
  final VoidCallback onTap;

  const _NotificationRow({
    required this.notification,
    required this.expanded,
    required this.onTap,
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
                              decoration: const BoxDecoration(
                                color: ThemeV2.primary,
                                shape: BoxShape.circle,
                              ),
                            ),
                          Expanded(
                            child: Text(
                              notification.title,
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                              style: GoogleFonts.inter(
                                fontSize: 14,
                                fontWeight: FontWeight.w600,
                                color: notificationTitleColor(
                                  notification.type,
                                  fallback: ThemeV2.textPrimary,
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
                          color: ThemeV2.textSecondary,
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
                    color: ThemeV2.textSecondary,
                  ),
                ),
              ],
            ),
            if (expanded) ...[
              const SizedBox(height: 10),
              Padding(
                padding: const EdgeInsets.only(left: 48),
                child: Text(
                  notification.detail,
                  style: GoogleFonts.inter(
                    fontSize: 12.5,
                    color: ThemeV2.textPrimary,
                    height: 1.4,
                  ),
                ),
              ),
            ],
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
          border: Border.all(color: ThemeV2.primary, width: 1.5),
        ),
        child: CompanyLogo(
          ticker: notification.symbol!,
          logoUrl: notification.logoUrl,
          radius: 16,
        ),
      );
    }
    return Container(
      width: 36,
      height: 36,
      decoration: const BoxDecoration(
        color: Color(0x141B365D),
        shape: BoxShape.circle,
      ),
      child: Icon(_icon, size: 18, color: const Color(0xFF1B365D)),
    );
  }
}
