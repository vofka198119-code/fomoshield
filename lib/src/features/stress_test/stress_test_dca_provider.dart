import 'dart:convert';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../../core/models/app_notification.dart';
import '../../core/notifications/notification_providers.dart';
import '../../core/overlay/app_notification_popup.dart';
import '../../core/supabase/free_reading_trust.dart';
import '../../core/supabase/supabase_providers.dart';
import '../../l10n/gen/app_localizations.dart';
import '../../shared/utils/currency_format.dart';
import 'stress_test_engine.dart';
import 'stress_test_funding_sync.dart';
import 'stress_test_models.dart';

// ---------------------------------------------------------------------------
// Stress Test DCA (Custom-duration weekly funding option)
// ---------------------------------------------------------------------------
// Deliberately NOT fields on StressTestSession — that class is reconstructed
// wholesale at ~10 call sites across trades_engine.dart/stress_test_engine
// .dart, and any field this store didn't get threaded through every one of
// those would silently reset to its default the next time the session was
// touched. A small standalone sessionId-keyed store, mirroring the pattern
// StressTestNotifier already uses for its own per-session auxiliary maps
// (_sessionRandom, _swingSnapshots, _whyDiagnostics — though those are
// memory-only; this one needs to survive a restart, hence SharedPreferences)
// sidesteps that risk entirely.
// ---------------------------------------------------------------------------

class _DcaEntry {
  final DateTime? lastPayoutAt;
  const _DcaEntry({this.lastPayoutAt});

  Map<String, dynamic> toJson() => {
    if (lastPayoutAt != null) 'lastPayoutAt': lastPayoutAt!.toIso8601String(),
  };

  factory _DcaEntry.fromJson(Map<String, dynamic> json) => _DcaEntry(
    lastPayoutAt: json['lastPayoutAt'] != null
        ? DateTime.tryParse(json['lastPayoutAt'] as String)
        : null,
  );
}

String _dcaStoreKey(String? uid) =>
    uid != null ? 'stress_test_dca_$uid' : 'stress_test_dca';

Future<Map<String, _DcaEntry>> _loadStore(String? uid) async {
  final prefs = await SharedPreferences.getInstance();
  final raw = prefs.getString(_dcaStoreKey(uid));
  if (raw == null) return {};
  try {
    final map = Map<String, dynamic>.from(json.decode(raw) as Map);
    return map.map(
      (k, v) => MapEntry(k, _DcaEntry.fromJson(Map<String, dynamic>.from(v))),
    );
  } catch (_) {
    return {};
  }
}

Future<void> _saveStore(String? uid, Map<String, _DcaEntry> store) async {
  final prefs = await SharedPreferences.getInstance();
  await prefs.setString(
    _dcaStoreKey(uid),
    json.encode(store.map((k, v) => MapEntry(k, v.toJson()))),
  );
}

// ── Server sync (Migration 032) ──────────────────────────────────────────
// This store is the device's copy; user_data.stress_test_funding is the
// durable one. Without this the markers died with the app install while the
// session itself came back from the server — see the migration file.

/// The whole store as plain JSON, for [pushStressTestFunding].
Future<Map<String, dynamic>> exportDcaStore(String? uid) async {
  final store = await _loadStore(uid);
  return store.map((k, v) => MapEntry(k, v.toJson()));
}

/// Merges a server copy into the device's. Where both know a session, the
/// LATER clock wins: a later lastPayoutAt means more has already been paid,
/// so taking it can only ever under-pay, never pay the same week twice (the
/// bug fixed in weekly_payout_provider.dart's history, worth not repeating).
Future<void> importDcaStore(String? uid, Map<String, dynamic> raw) async {
  final incoming = <String, _DcaEntry>{};
  raw.forEach((k, v) {
    if (v is Map) {
      incoming[k] = _DcaEntry.fromJson(Map<String, dynamic>.from(v));
    }
  });
  if (incoming.isEmpty) return;
  final store = await _loadStore(uid);
  for (final entry in incoming.entries) {
    final mine = store[entry.key];
    if (mine == null) {
      store[entry.key] = entry.value;
      continue;
    }
    final a = mine.lastPayoutAt;
    final b = entry.value.lastPayoutAt;
    if (a == null || (b != null && b.isAfter(a))) {
      store[entry.key] = entry.value;
    }
  }
  await _saveStore(uid, store);
}

/// Marks [sessionId] as DCA-funded and starts its payout clock — call once,
/// right when the user picks the DCA option in the Custom-duration setup
/// step (alongside dropping the session's cash to [dcaStartingCash] via
/// StressTestNotifier.setSessionDuration's overrideCash).
Future<void> markStressTestDcaFunded(WidgetRef ref, String sessionId) async {
  final uid = ref.read(currentUserProvider)?.id;
  final store = await _loadStore(uid);
  store[sessionId] = _DcaEntry(lastPayoutAt: DateTime.now());
  await _saveStore(uid, store);
  await pushStressTestFunding(ref);
}

Future<bool> isStressTestDcaFunded(WidgetRef ref, String sessionId) async {
  final uid = ref.read(currentUserProvider)?.id;
  final store = await _loadStore(uid);
  return store.containsKey(sessionId);
}

// Note for anyone extending this: the two remaining local writes below —
// pinning the clock while the subscription is lapsed, and seeding a clock
// for a holding that owes nothing — deliberately do NOT push to the server.
// They run on every check-in, i.e. every 20s while the screen is open, so
// syncing them would mean a Supabase write every 20 seconds per viewer. Only
// opting in and actually crediting push, and those are the two states worth
// surviving a reinstall anyway.
/// Catch-up check for one session — credits any elapsed weeks of DCA
/// funding if currently premium/admin. No-ops for a non-DCA session or a
/// non-active one. Freezing on a lapsed subscription works the same way as
/// Portfolio's weekly payout: while the tier doesn't read premium/admin,
/// the clock is pinned to now on every check-in instead of crediting —
/// so no backlog accrues for the lapsed stretch once renewed.
Future<void> checkStressTestDcaPayout(
  WidgetRef ref,
  StressTestSession session,
  AppLocalizations l10n,
) async {
  if (session.status != StressTestStatus.active) return;
  final uid = ref.read(currentUserProvider)?.id;
  final store = await _loadStore(uid);
  final entry = store[session.id];
  if (entry == null) return; // not a DCA-funded session

  // Awaits the real tier instead of racing subscriptionTierProvider's
  // async DB fetch (see resolveSubscriptionTier's doc comment) — closes
  // the race this function's own doc comment above used to route around
  // via the 20s timer retry alone, which doesn't help a session shorter
  // than that.
  final tier = await resolveSubscriptionTier(ref);
  if (!tier.isPremiumOrAdmin) {
    // Only believe `free` once it's confirmed (or unconfirmable for a day) —
    // see free_reading_trust.dart. An unconfirmed free reading here used to
    // pin the clock and silently cost a paying user the week they'd accrued.
    if (!await freeReadingIsTrustworthy(ref)) return;
    // Pin the clock to now while lapsed, so the elapsed-weeks calc below
    // never spans the lapsed stretch once Premium resumes — otherwise the
    // frozen lastPayoutAt would make the next check-in look like weeks of
    // backlog and pay it all out at once.
    store[session.id] = _DcaEntry(lastPayoutAt: DateTime.now());
    await _saveStore(uid, store);
    return;
  }

  final lastPayout = entry.lastPayoutAt ?? DateTime.now();
  final elapsedWeeks = DateTime.now().difference(lastPayout).inDays ~/ 7;
  if (elapsedWeeks <= 0) return;

  final amount = elapsedWeeks * dcaWeeklyAmount;
  final creditedThrough = lastPayout.add(Duration(days: elapsedWeeks * 7));

  ref
      .read(stressTestProvider.notifier)
      .creditDcaPayout(session.id, amount, weeksCredited: elapsedWeeks);
  store[session.id] = _DcaEntry(lastPayoutAt: creditedThrough);
  await _saveStore(uid, store);
  await pushStressTestFunding(ref);

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
      title: l10n.weeklyPayoutTitle,
      detail: l10n.weeklyPayoutDetail(formatUsd(amount)),
      createdAt: DateTime.now(),
      payoutAmount: amount,
    ),
  );
}
