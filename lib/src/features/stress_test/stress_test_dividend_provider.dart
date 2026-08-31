import 'dart:convert';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../../core/models/app_notification.dart';
import '../../core/notifications/notification_providers.dart';
import '../../core/overlay/app_notification_popup.dart';
import '../../core/supabase/supabase_providers.dart';
import '../../l10n/gen/app_localizations.dart';
import '../../shared/utils/currency_format.dart';
import 'stress_test_engine.dart';
import 'stress_test_models.dart';
import 'stress_test_live_metrics.dart';

// ---------------------------------------------------------------------------
// Stress Test Dividend Simulation (Custom-duration only, opt-in)
// ---------------------------------------------------------------------------
// Same standalone-store + client-driven-catch-up idiom as
// stress_test_dca_provider.dart, for the same reason: StressTestSession is
// reconstructed wholesale at ~10 call sites, so a field this store didn't
// get threaded through every one of them would silently reset. Unlike DCA
// (one flat amount, one session-wide clock), each holding has its own
// payout cadence (monthly, or every 2 real weeks for REITs — see
// dividendPeriodDays in stress_test_live_metrics.dart) and its own
// per-share $ amount, so the clock here is kept per symbol, not per session.
//
// Reuses AppNotificationType.weeklyPayout for the payout notification —
// same precedent DCA already established (see checkStressTestDcaPayout):
// weekly_payout_detail_screen.dart reads its title/amount/label generically
// off the AppNotification itself, it isn't hardcoded to the "weekly
// deposit" concept, so a distinct notification type would just be
// unnecessary surface area.
// ---------------------------------------------------------------------------

class _DividendEntry {
  final bool enabled;
  final Map<String, DateTime> lastPayoutBySymbol;

  const _DividendEntry({required this.enabled, this.lastPayoutBySymbol = const {}});

  Map<String, dynamic> toJson() => {
    'enabled': enabled,
    'lastPayoutBySymbol': lastPayoutBySymbol.map(
      (k, v) => MapEntry(k, v.toIso8601String()),
    ),
  };

  factory _DividendEntry.fromJson(Map<String, dynamic> json) => _DividendEntry(
    enabled: json['enabled'] as bool? ?? false,
    lastPayoutBySymbol:
        (json['lastPayoutBySymbol'] as Map<String, dynamic>? ?? {}).map(
          (k, v) => MapEntry(k, DateTime.parse(v as String)),
        ),
  );
}

String _dividendStoreKey(String? uid) =>
    uid != null ? 'stress_test_dividends_$uid' : 'stress_test_dividends';

Future<Map<String, _DividendEntry>> _loadStore(String? uid) async {
  final prefs = await SharedPreferences.getInstance();
  final raw = prefs.getString(_dividendStoreKey(uid));
  if (raw == null) return {};
  try {
    final map = Map<String, dynamic>.from(json.decode(raw) as Map);
    return map.map(
      (k, v) =>
          MapEntry(k, _DividendEntry.fromJson(Map<String, dynamic>.from(v))),
    );
  } catch (_) {
    return {};
  }
}

Future<void> _saveStore(String? uid, Map<String, _DividendEntry> store) async {
  final prefs = await SharedPreferences.getInstance();
  await prefs.setString(
    _dividendStoreKey(uid),
    json.encode(store.map((k, v) => MapEntry(k, v.toJson()))),
  );
}

/// Marks [sessionId] as dividend-simulation-enabled — call once, right when
/// the user picks "Simulate dividends" during Custom-duration setup. Seeds
/// every holding already bought (setup-phase buys) with a clock starting
/// now, so the very first catch-up after the test starts doesn't treat the
/// whole setup window as elapsed backlog.
Future<void> markStressTestDividendSimulationEnabled(
  WidgetRef ref,
  String sessionId,
) async {
  final uid = ref.read(currentUserProvider)?.id;
  final store = await _loadStore(uid);
  final session = ref.read(stressTestProvider.notifier).getSession(sessionId);
  final now = DateTime.now();
  store[sessionId] = _DividendEntry(
    enabled: true,
    lastPayoutBySymbol: {
      for (final h in session?.holdings ?? const <StressTestHolding>[])
        h.symbol: now,
    },
  );
  await _saveStore(uid, store);
}

Future<bool> isStressTestDividendSimulationEnabled(
  WidgetRef ref,
  String sessionId,
) async {
  final uid = ref.read(currentUserProvider)?.id;
  final store = await _loadStore(uid);
  return store[sessionId]?.enabled ?? false;
}

/// Catch-up check for one session — credits any elapsed dividend periods,
/// per holding, if currently premium/admin (Custom-duration is already a
/// premium-only test mode, but a long-running test can outlive a lapsed
/// subscription — same freeze behavior as DCA: pin every symbol's clock to
/// now without crediting while lapsed, so no backlog accrues, resuming
/// clean whenever Premium is renewed).
Future<void> checkStressTestDividendPayout(
  WidgetRef ref,
  StressTestSession session,
  AppLocalizations l10n,
) async {
  if (session.status != StressTestStatus.active) return;
  final uid = ref.read(currentUserProvider)?.id;
  final store = await _loadStore(uid);
  final entry = store[session.id];
  if (entry == null || !entry.enabled) return;

  final tier = ref.read(subscriptionTierProvider);
  if (!tier.isPremiumOrAdmin) {
    store[session.id] = _DividendEntry(
      enabled: true,
      lastPayoutBySymbol: {
        for (final s in entry.lastPayoutBySymbol.keys) s: DateTime.now(),
      },
    );
    await _saveStore(uid, store);
    return;
  }

  final now = DateTime.now();
  final updatedClocks = Map<String, DateTime>.from(entry.lastPayoutBySymbol);
  double totalAmount = 0;

  for (final holding in session.holdings) {
    // Lazily seed a clock for a holding bought after simulation was
    // enabled (or after this symbol's last full sell/re-buy) — no
    // separate init hook needed at every buy call site (setup-phase buy,
    // active-test market buy, limit-order fill all funnel through
    // trades_engine.dart without a Riverpod ref to call into this store).
    // Starting "now" means zero backlog for time before it was held,
    // which is the correct behavior either way.
    final lastPayout = updatedClocks[holding.symbol] ?? now;
    updatedClocks[holding.symbol] = lastPayout;

    // A real 0%-yield holding (or one whose fundamentals never resolved)
    // never owes anything — skip before touching its clock at all, so an
    // untouched holding doesn't churn its stored timestamp forever.
    final annualPerShare = annualDividendPerShare(holding);
    if (annualPerShare <= 0) continue;

    final periodDays = dividendPeriodDays(holding.symbol);
    final elapsedPeriods = now.difference(lastPayout).inDays ~/ periodDays;
    if (elapsedPeriods <= 0) continue;

    final perPayment = annualPerShare * periodDays / 365;
    totalAmount += elapsedPeriods * holding.shares * perPayment;
    updatedClocks[holding.symbol] = lastPayout.add(
      Duration(days: elapsedPeriods * periodDays),
    );
  }

  if (totalAmount <= 0) {
    // Still persist any symbols whose clocks were newly seeded above for a
    // holding with no dividend data (0 per-share amount) — nothing to
    // credit, but keeps their clocks moving forward instead of re-checking
    // from the original timestamp every time.
    store[session.id] = _DividendEntry(
      enabled: true,
      lastPayoutBySymbol: updatedClocks,
    );
    await _saveStore(uid, store);
    return;
  }

  ref
      .read(stressTestProvider.notifier)
      .creditDividendPayout(session.id, totalAmount);
  store[session.id] = _DividendEntry(
    enabled: true,
    lastPayoutBySymbol: updatedClocks,
  );
  await _saveStore(uid, store);

  pushAppNotification(
    ref.read(notificationsProvider.notifier),
    AppNotification(
      id: 'notif_${DateTime.now().microsecondsSinceEpoch}',
      type: AppNotificationType.weeklyPayout,
      portfolioKind: NotificationPortfolioKind.stressTest,
      portfolioId: session.id,
      portfolioLabel: session.displayLabel(
        'Market Simulation — ${session.duration.displayName}',
      ),
      title: l10n.dividendPayoutTitle,
      detail: l10n.dividendPayoutDetail(formatUsd(totalAmount)),
      createdAt: DateTime.now(),
      payoutAmount: totalAmount,
    ),
  );
}
