import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../../core/models/app_notification.dart';
import '../../core/notifications/notification_providers.dart';
import '../../core/overlay/app_notification_popup.dart';
import '../../core/supabase/supabase_providers.dart';
import '../../l10n/gen/app_localizations.dart';
import '../../shared/utils/currency_format.dart';
import 'portfolio_providers.dart';

// ---------------------------------------------------------------------------
// Weekly Premium Payout — +$180/week auto-deposit into a Premium/admin
// user's portfolio.
// ---------------------------------------------------------------------------
// Client-driven catch-up, same idiom as Stress Test's own tick simulation
// (see stress_test_engine.dart's _catchUpAll): there's no server cron —
// [checkWeeklyPayout] is called opportunistically (on Portfolio screen open
// and on its periodic refresh timer) and credits however many full weeks
// have elapsed since the portfolio's own lastWeeklyPayoutAt, all at once.
//
// Freezing on a lapsed subscription: this only ever credits while
// subscriptionTierProvider reads premium/admin RIGHT NOW. While lapsed, a
// free-tier check-in pins lastWeeklyPayoutAt to now instead of crediting —
// no separate "frozen" flag on the portfolio itself, just a clock that
// keeps getting reset forward so no backlog accrues. Resuming premium
// later starts counting fresh from whenever that last lapsed check-in was
// (no back-pay for the lapsed period).
// ---------------------------------------------------------------------------

const double weeklyPayoutAmount = 180;
const Duration weeklyPayoutInterval = Duration(days: 7);

String _wasPremiumKey(String? uid) => uid != null
    ? 'weekly_payout_was_premium_$uid'
    : 'weekly_payout_was_premium';

/// Runs one check-in: credits any elapsed weeks if currently premium/admin,
/// and fires the pause/status-change popups on a tier transition. Safe to
/// call repeatedly (e.g. from a periodic timer) — a no-op call (nothing
/// elapsed, no transition) does no writes beyond the SharedPreferences
/// tier-tracking flag.
Future<void> checkWeeklyPayout(WidgetRef ref, AppLocalizations l10n) async {
  final portfolios = ref.read(portfoliosProvider);
  if (portfolios.isEmpty) return;
  // Single-portfolio system — see [[fomoshield_finnhub_rate_limit_fix]]-era
  // portfolio_limits_provider.dart; every user has exactly one.
  final portfolio = portfolios.first;

  final tier = ref.read(subscriptionTierProvider);
  final isPremiumNow = tier.isPremiumOrAdmin;

  final user = ref.read(currentUserProvider);
  final prefs = await SharedPreferences.getInstance();
  final key = _wasPremiumKey(user?.id);
  final wasPremium = prefs.getBool(key);
  final notifier = ref.read(notificationsProvider.notifier);

  if (isPremiumNow) {
    final lastPayout = portfolio.lastWeeklyPayoutAt;
    if (lastPayout == null) {
      // First-ever premium check-in for this portfolio — start the clock,
      // no retroactive credit for time before now.
      ref
          .read(portfoliosProvider.notifier)
          .startWeeklyPayoutClock(portfolio.id, DateTime.now());
    } else {
      final elapsedWeeks =
          DateTime.now().difference(lastPayout).inDays ~/
          weeklyPayoutInterval.inDays;
      if (elapsedWeeks > 0) {
        final amount = elapsedWeeks * weeklyPayoutAmount;
        final creditedThrough = lastPayout.add(
          Duration(days: elapsedWeeks * weeklyPayoutInterval.inDays),
        );
        ref
            .read(portfoliosProvider.notifier)
            .creditWeeklyPayout(portfolio.id, amount, creditedThrough);
        pushAppNotification(
          notifier,
          AppNotification(
            id: 'notif_${DateTime.now().microsecondsSinceEpoch}',
            type: AppNotificationType.weeklyPayout,
            portfolioKind: NotificationPortfolioKind.real,
            portfolioId: portfolio.id,
            portfolioLabel: portfolio.name,
            title: l10n.weeklyPayoutTitle,
            detail: l10n.weeklyPayoutDetail(formatUsd(amount)),
            createdAt: DateTime.now(),
          ),
        );
      }
    }

    if (wasPremium == false) {
      pushAppNotification(
        notifier,
        AppNotification(
          id: 'notif_${DateTime.now().microsecondsSinceEpoch}_up',
          type: AppNotificationType.subscriptionStatusChanged,
          portfolioKind: NotificationPortfolioKind.real,
          portfolioId: portfolio.id,
          title: l10n.subscriptionUpgradedTitle,
          detail: l10n.subscriptionUpgradedDetail,
          createdAt: DateTime.now(),
        ),
      );
    }
    await prefs.setBool(key, true);
  } else {
    // Only fire the "paused" popup on the actual free->premium-lapsed
    // transition (wasPremium == true), not on every free-tier check-in —
    // and only if a payout clock had ever actually started for this
    // portfolio (lastWeeklyPayoutAt != null), otherwise a free user who
    // never had premium would get a spurious "paused" notification on
    // their very first check-in (wasPremium starts as null, not true, so
    // this guard is mostly redundant, but keeps the intent explicit).
    if (wasPremium == true && portfolio.lastWeeklyPayoutAt != null) {
      pushAppNotification(
        notifier,
        AppNotification(
          id: 'notif_${DateTime.now().microsecondsSinceEpoch}_pause',
          type: AppNotificationType.weeklyPayoutPaused,
          portfolioKind: NotificationPortfolioKind.real,
          portfolioId: portfolio.id,
          title: l10n.weeklyPayoutPausedTitle,
          detail: l10n.weeklyPayoutPausedDetail,
          createdAt: DateTime.now(),
        ),
      );
      pushAppNotification(
        notifier,
        AppNotification(
          id: 'notif_${DateTime.now().microsecondsSinceEpoch}_down',
          type: AppNotificationType.subscriptionStatusChanged,
          portfolioKind: NotificationPortfolioKind.real,
          portfolioId: portfolio.id,
          title: l10n.subscriptionDowngradedTitle,
          detail: l10n.subscriptionDowngradedDetail,
          createdAt: DateTime.now(),
        ),
      );
    }
    // Pin the clock to now on every lapsed check-in (once a clock exists),
    // so the elapsed-weeks calc above never spans the lapsed stretch once
    // Premium resumes — otherwise a frozen lastWeeklyPayoutAt would make
    // the next check-in look like weeks of backlog and pay it all out at
    // once, instead of "no back-pay for the lapsed period" as intended.
    if (portfolio.lastWeeklyPayoutAt != null) {
      ref
          .read(portfoliosProvider.notifier)
          .startWeeklyPayoutClock(portfolio.id, DateTime.now());
    }
    await prefs.setBool(key, false);
  }
}
