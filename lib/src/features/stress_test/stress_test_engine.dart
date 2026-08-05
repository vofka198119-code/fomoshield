// ---------------------------------------------------------------------------
// Stress Test Engine — Riverpod State + Market Simulation + Scoring
// ---------------------------------------------------------------------------
// Manages stress test sessions, epoch-based market simulation, price
// generation, anti-catastrophe protection, and the final psychological
// verdict calculation.
// ---------------------------------------------------------------------------

import 'dart:math';
import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'dart:convert';
import '../../core/supabase/supabase_providers.dart';
import '../../core/services/gics_sector_mapper.dart';
import '../../shared/services/user_data_service.dart';
import 'stress_test_models.dart';

part 'gbm_engine.dart';
part 'casino_epochs.dart';
part 'trades_engine.dart';
part 'hype/hype_event.dart';
part 'news_event.dart';
part 'noise_engine.dart';

// ---------------------------------------------------------------------------
// Constants
// ---------------------------------------------------------------------------

const double _freeStartingCash = 5000;
const double _premiumStartingCash = 15000;
// Concurrent active slots — free: 1 ad-free + 1 ad-gated (stubbed as a
// "Go Premium" nudge until ad integration exists). No lifetime cap on
// total tests ever created — completing/deleting a test frees its slot.
const int _freeMaxSessions = 2;
const int _premiumMaxSessions = 5;
const int _adEveryNTrades = 5; // show ad after every N trades for free users
const int _adEveryNOpen = 6; // show ad on every Nth opening

/// Wall-clock seconds per simulation tick.
const int _tickSeconds = 20;

/// Public alias for [_tickSeconds] — UI code outside this `part of` library
/// (e.g. why_today_screen.dart's News/Hype countdown) needs the tick
/// length to convert `rampDurationTicks - currentTick` into real time.
const int tickIntervalSeconds = _tickSeconds;

/// Max ticks to simulate in catch-up (5 hours = 900 ticks @ 20s each).
const int _maxCatchUpTicks = 900;

/// Max points kept per symbol in [StressTestSession.priceHistory]. Long
/// Infinite/Custom tests would otherwise grow this (and its JSON
/// persistence) unbounded — chart consumers only ever downsample to a few
/// hundred points at most, so this comfortably covers every real use.
const int _maxPriceHistoryPoints = 5000;

/// Max price-history points recorded from a single catch-up burst (up to
/// [_maxCatchUpTicks] raw sub-ticks). Every sub-tick is simulated for GBM
/// accuracy either way; this only caps how many of those get written to
/// history/rendered on the chart, so a long catch-up still reads as an
/// organic jagged line instead of either a single straight jump (1 point)
/// or thousands of points collapsing onto a handful of screen pixels.
const int _maxRenderPointsPerBurst = 150;

/// Picks up to [maxPoints] evenly-spaced indices from `[0, length)`,
/// always including the first and last index so a downsampled burst still
/// starts and ends exactly where the real batch did.
List<int> _downsamplePointIndices(int length, int maxPoints) {
  if (length <= maxPoints) return List.generate(length, (i) => i);
  if (maxPoints <= 1) return [length - 1];
  final step = (length - 1) / (maxPoints - 1);
  final indices = <int>{};
  for (int i = 0; i < maxPoints; i++) {
    indices.add((i * step).round().clamp(0, length - 1));
  }
  final sorted = indices.toList()..sort();
  return sorted;
}

/// Max [TickExplanation]s kept per symbol in [StressTestSession.explanationLog].
/// Unlike priceHistory, this was never capped at all — Why Today's timeline
/// only ever displays the last 20 (`why_today_screen.dart`'s `displayTicks`)
/// and the summary/breakdown cards only ever read `.last`, so nothing reads
/// further back than that. Left uncapped, a long-lived session's per-tick
/// O(n) list-copy on every catch-up kept getting more expensive forever —
/// generous margin over the 20 actually shown, in case that display window
/// ever grows.
const int _maxExplanationLogEntries = 50;

// ---------------------------------------------------------------------------
// Storage keys (user-scoped)
// ── Task 1.7: Separated Cache Architecture ─────────────────────────
// active_stress_test_sessions — heavy ephemeral session data (wiped on complete/delete)
// stress_test_verdicts_history — lightweight verdict archive (FIFO, max 20)
// ---------------------------------------------------------------------------

String _sessionsKey(String? uid) => uid != null
    ? 'active_stress_test_sessions_$uid'
    : 'active_stress_test_sessions';
String _adCounterKey(String? uid) =>
    uid != null ? 'stress_test_ad_counter_$uid' : 'stress_test_ad_counter';
String _testCounterKey(String? uid) =>
    uid != null ? 'stress_test_total_$uid' : 'stress_test_total';
String _openCounterKey(String? uid) =>
    uid != null ? 'stress_test_open_$uid' : 'stress_test_open';
String _archiveKey(String? uid) => uid != null
    ? 'stress_test_verdicts_history_$uid'
    : 'stress_test_verdicts_history';

// ---------------------------------------------------------------------------
// Provider: Max simultaneous stress test sessions
// ---------------------------------------------------------------------------

final maxStressTestSessionsProvider = Provider<int>((ref) {
  final tier = ref.watch(subscriptionTierProvider);
  return (tier == SubscriptionTier.premium || tier == SubscriptionTier.admin)
      ? _premiumMaxSessions
      : _freeMaxSessions;
});

/// Starting cash for a stress test based on subscription tier.
final stressTestStartingCashProvider = Provider<double>((ref) {
  final tier = ref.watch(subscriptionTierProvider);
  return (tier == SubscriptionTier.premium || tier == SubscriptionTier.admin)
      ? _premiumStartingCash
      : _freeStartingCash;
});

// ---------------------------------------------------------------------------
// Stress Test Notifier — manages all sessions and simulation
// ---------------------------------------------------------------------------

class StressTestNotifier extends StateNotifier<List<StressTestSession>> {
  String? _userId;
  late Random _random;
  int _adCounter = 0;
  int _testCounter = 0; // total sessions created (across all time)
  int _openCounter = 0; // times the stress test screen has been opened
  List<VerdictArchiveEntry> _verdictArchive = [];

  final UserDataService? _supabaseService;
  // Guards against _load()'s async SharedPreferences read finishing AFTER
  // loadFromSupabase() and clobbering the just-synced server data with an
  // empty/stale local cache — same race fixed for the other 4 sync
  // notifiers (Watchlist/Portfolio/Order/HomeWidgets), see
  // project_fomo_shield_premium_subscription_system memory.
  bool _loadedFromSupabase = false;

  /// Per-session RNG map: sessionId → Random(simulationSeed).
  /// Каждая сессия использует свой изолированный генератор,
  /// что гарантирует детерминизм и отсутствие cross-session утечек.
  final Map<String, Random> _sessionRandom = {};

  /// Override for testing: if set, bypasses real clock for _isMarketOpen.
  /// Allows tests to simulate prices regardless of time/day.
  // ignore: prefer_private_fields
  bool Function(DateTime)? marketOpenOverride;

  /// Global override — when set, applies to ALL StressTestNotifier instances.
  /// Used in test suites to avoid setting marketOpenOverride per-instance.
  static bool Function(DateTime)? globalMarketOpenOverride;

  StressTestNotifier({this._userId, int? seed, this._supabaseService})
      : super([]) {
    _random = (seed != null) ? Random(seed) : Random();
    _load();
  }

  /// Load sessions from Supabase (replaces local). Called on login.
  void loadFromSupabase(List<dynamic> rawSessions) {
    if (rawSessions.isEmpty) return;
    _loadedFromSupabase = true;
    try {
      state = rawSessions
          .map((e) => _sessionFromJson(e as Map<String, dynamic>))
          .toList();
      _catchUpAll();
      _save();
    } catch (_) {}
  }

  /// Pushes the current active sessions to Supabase. Called only from
  /// significant events (trade, start, complete, delete) — NOT from the
  /// ~20s tick-simulation _save(), which would hammer Supabase with writes
  /// for every user with the screen open.
  void _syncToSupabase() {
    final uid = _userId;
    final service = _supabaseService;
    if (uid == null || service == null) return;
    service.saveStressTestSessions(
      uid,
      state.map((s) => _sessionToJson(s)).toList(),
    );
  }

  void setUserId(String? uid) {
    _userId = uid;
    _load();
  }

  // ── Persistence ──────────────────────────────────────────────────

  String get _storageKey => _sessionsKey(_userId);
  String get _adKey => _adCounterKey(_userId);
  String get _testKey => _testCounterKey(_userId);
  String get _openKey => _openCounterKey(_userId);
  String get _archiveStorageKey => _archiveKey(_userId);

  /// ── Task 1.7: Load active sessions from ephemeral cache ──────
  /// Reads `active_stress_test_sessions` (heavy payload: ticks, trades,
  /// price history) and `stress_test_verdicts_history` (lightweight archive)
  /// from completely separate storage keys.
  Future<void> _load() async {
    final prefs = await SharedPreferences.getInstance();
    // ── Isolated verdict history (lightweight, FIFO 20) ───────────
    // Loaded BEFORE catch-up runs. _catchUpAll() below can synchronously
    // complete a test (if its duration elapsed while the app was closed)
    // and append a fresh entry to _verdictArchive via _completeTest(); that
    // completion's own _save() is fire-and-forget, so if _loadArchive ran
    // AFTER catch-up (as it used to), it would read the stale pre-completion
    // archive off disk and clobber the entry that was just added in memory
    // — silently losing the verdict. Loading first means catch-up only ever
    // appends on top of the real, already-current archive.
    _loadArchive(prefs);
    // ── Ephemeral active sessions (heavy) ────────────────────────
    // If loadFromSupabase() already landed (async race — see
    // _loadedFromSupabase docs above), don't let a stale/empty local
    // cache clobber the just-synced server data.
    final raw = _loadedFromSupabase ? null : prefs.getString(_storageKey);
    bool ranCatchUp = false;
    if (raw != null) {
      try {
        final list = (jsonDecode(raw) as List<dynamic>)
            .map((e) => _sessionFromJson(e as Map<String, dynamic>))
            .toList();
        state = list;
        // Run catch-up for any active sessions
        _catchUpAll();
        ranCatchUp = true;
      } catch (_) {
        state = [];
      }
    }
    _adCounter = prefs.getInt(_adKey) ?? 0;
    _testCounter = prefs.getInt(_testKey) ?? 0;
    _openCounter = prefs.getInt(_openKey) ?? 0;
    if (ranCatchUp) {
      // Guarantee anything catch-up completed (session removal + archive
      // entry) is actually persisted before _load() resolves, instead of
      // trusting the completion's own fire-and-forget _save() to land
      // before anyone reads storage again.
      await _save();
    }
  }

  /// ── Task 1.7: Persist with strict cache separation ────────────
  /// Writes active sessions to `active_stress_test_sessions` and
  /// verdict history to `stress_test_verdicts_history` independently.
  /// If a session was removed from `state` (by _completeTest or
  /// deleteSession), its heavy payload is permanently wiped.
  Future<void> _save() async {
    final prefs = await SharedPreferences.getInstance();
    // ── Ephemeral: only currently-active sessions ────────────────
    final raw = jsonEncode(state.map((s) => _sessionToJson(s)).toList());
    await prefs.setString(_storageKey, raw);
    await prefs.setInt(_adKey, _adCounter);
    await prefs.setInt(_testKey, _testCounter);
    await prefs.setInt(_openKey, _openCounter);
    // ── Isolated: verdict history (never mixed with active data) ─
    await _saveArchive(prefs);
  }

  Future<void> _saveArchive(SharedPreferences prefs) async {
    final raw = jsonEncode(_verdictArchive.map((e) => e.toJson()).toList());
    await prefs.setString(_archiveStorageKey, raw);
  }

  void _loadArchive(SharedPreferences prefs) {
    final raw = prefs.getString(_archiveStorageKey);
    if (raw != null) {
      try {
        _verdictArchive = (jsonDecode(raw) as List<dynamic>)
            .map((e) => VerdictArchiveEntry.fromJson(e as Map<String, dynamic>))
            .toList();
      } catch (_) {
        _verdictArchive = [];
      }
    }
  }

  // ── Serialization helpers ────────────────────────────────────────

  Map<String, dynamic> _sessionToJson(StressTestSession s) {
    return {
      'id': s.id,
      'duration': s.duration.name,
      'startingCash': s.startingCash,
      'cash': s.cash,
      'holdings': s.holdings
          .map(
            (h) => {
              'symbol': h.symbol,
              'shares': h.shares,
              'avgCost': h.avgCost,
              'entryPrice': h.entryPrice,
              if (h.cachedLogoUrl != null) 'cachedLogoUrl': h.cachedLogoUrl,
            },
          )
          .toList(),
      'trades': s.trades
          .map(
            (t) => {
              'symbol': t.symbol,
              'isBuy': t.isBuy,
              'shares': t.shares,
              'price': t.price,
              'date': t.date.toIso8601String(),
              'wasPeak': t.wasPeak,
              'wasBottom': t.wasBottom,
              if (t.realizedPnl != null) 'realizedPnl': t.realizedPnl,
            },
          )
          .toList(),
      'currentWeights': s.currentWeights,
      if (s.lastTickTimestamp != null)
        'lastTickTimestamp': s.lastTickTimestamp!.toIso8601String(),
      'createdAt': s.createdAt.toIso8601String(),
      'startedAt': s.startedAt?.toIso8601String(),
      'completedAt': s.completedAt?.toIso8601String(),
      'realizedPnl': s.realizedPnl,
      'boughtAtPeakCount': s.boughtAtPeakCount,
      'soldAtBottomCount': s.soldAtBottomCount,
      'maxSingleAssetAllocation': s.maxSingleAssetAllocation,
      'blackSwanSurvived': s.blackSwanSurvived,
      'hasExperiencedCatastrophe': s.hasExperiencedCatastrophe,
      'catastropheCooldown': s.catastropheCooldown,
      'casinoCatastropheCooldown': s.casinoCatastropheCooldown,
      'casinoDeclineStreak': s.casinoDeclineStreak,
      'casinoCatastropheCount': s.casinoCatastropheCount,
      'casinoLastCatastropheEpoch': s.casinoLastCatastropheEpoch,
      'currentPrices': s.currentPrices,
      'basePrices': s.basePrices,
      'preCrashPrices': s.preCrashPrices,
      'recoveryStartPrices': s.recoveryStartPrices,
      'simulationSeed': s.simulationSeed,
      'stabilizationDeadlines': s.stabilizationDeadlines.map(
        (k, v) => MapEntry(k, v.toIso8601String()),
      ),
      'priceHistory': s.priceHistory.map(
        (k, v) => MapEntry(k, v.map((e) => e).toList()),
      ),
      'priceHistoryTimestamps': s.priceHistoryTimestamps,
      'status': s.status.name,
      'psychologyProfile': s.psychologyProfile.toJson(),
      'diversificationBonusRecorded': s.diversificationBonusRecorded,
      'catastropheSurvivalRecorded': s.catastropheSurvivalRecorded,
      'soldDuringCatastrophe': s.soldDuringCatastrophe.toList(),
      if (s.activeNewsEvent != null)
        'activeNewsEvent': s.activeNewsEvent!.toJson(),
      'lastNewsCheckedEpoch': s.lastNewsCheckedEpoch,
      // ── Hype: sector-wide trending move (0-2 concurrent) ──────
      'activeHypeEvents': s.activeHypeEvents.map((e) => e.toJson()).toList(),
      'lastHypeCheckedEpoch': s.lastHypeCheckedEpoch,
      'customDurationDays': s.customDurationDays,
      // ── Block 6: Casino wall-clock epoch history ──────────
      if (s.lastEpochRollAt != null)
        'lastEpochRollAt': s.lastEpochRollAt!.toIso8601String(),
      'epochHistory': s.epochHistory.map((e) => e.toJson()).toList(),
    };
  }

  StressTestSession _sessionFromJson(Map<String, dynamic> json) {
    final s = StressTestSession(
      id: json['id'] as String,
      duration: TestDuration.values.firstWhere(
        (d) => d.name == (json['duration'] as String),
      ),
      startingCash: (json['startingCash'] as num).toDouble(),
      cash: (json['cash'] as num).toDouble(),
      holdings: (json['holdings'] as List<dynamic>)
          .map(
            (h) => StressTestHolding(
              symbol: h['symbol'] as String,
              shares: (h['shares'] as num).toDouble(),
              avgCost: (h['avgCost'] as num).toDouble(),
              entryPrice: (h['entryPrice'] as num).toDouble(),
              cachedLogoUrl: h['cachedLogoUrl'] as String?,
            ),
          )
          .toList(),
      trades: (json['trades'] as List<dynamic>)
          .map(
            (t) => StressTestTrade(
              symbol: t['symbol'] as String,
              isBuy: t['isBuy'] as bool,
              shares: (t['shares'] as num).toDouble(),
              price: (t['price'] as num).toDouble(),
              date: DateTime.parse(t['date'] as String),
              wasPeak: t['wasPeak'] as bool? ?? false,
              wasBottom: t['wasBottom'] as bool? ?? false,
              realizedPnl: (t['realizedPnl'] as num?)?.toDouble(),
            ),
          )
          .toList(),
      status: StressTestStatus.values.firstWhere(
        (s) => s.name == (json['status'] as String),
      ),
      createdAt: DateTime.parse(json['createdAt'] as String),
      startedAt: json['startedAt'] != null
          ? DateTime.parse(json['startedAt'] as String)
          : null,
      completedAt: json['completedAt'] != null
          ? DateTime.parse(json['completedAt'] as String)
          : null,
      realizedPnl: (json['realizedPnl'] as num?)?.toDouble() ?? 0,
      boughtAtPeakCount: json['boughtAtPeakCount'] as int? ?? 0,
      soldAtBottomCount: json['soldAtBottomCount'] as int? ?? 0,
      maxSingleAssetAllocation:
          (json['maxSingleAssetAllocation'] as num?)?.toDouble() ?? 0,
      blackSwanSurvived: json['blackSwanSurvived'] as bool? ?? false,
      hasExperiencedCatastrophe:
          json['hasExperiencedCatastrophe'] as bool? ?? false,
      catastropheCooldown: json['catastropheCooldown'] as int? ?? 0,
      casinoCatastropheCooldown: json['casinoCatastropheCooldown'] as int? ?? 0,
      casinoDeclineStreak: json['casinoDeclineStreak'] as int? ?? 0,
      casinoCatastropheCount: json['casinoCatastropheCount'] as int? ?? 0,
      casinoLastCatastropheEpoch:
          json['casinoLastCatastropheEpoch'] as int? ?? -100,
      simulationSeed: json['simulationSeed'] as int? ?? 0,
      psychologyProfile: json['psychologyProfile'] != null
          ? TraderPsychologyProfile.fromJson(
              json['psychologyProfile'] as Map<String, dynamic>,
            )
          : null,
      stabilizationDeadlines:
          (json['stabilizationDeadlines'] as Map<String, dynamic>?)?.map(
            (k, v) => MapEntry(k, DateTime.parse(v as String)),
          ) ??
          {},
      currentPrices:
          (json['currentPrices'] as Map<String, dynamic>?)?.map(
            (k, v) => MapEntry(k, (v as num).toDouble()),
          ) ??
          {},
      basePrices:
          (json['basePrices'] as Map<String, dynamic>?)?.map(
            (k, v) => MapEntry(k, (v as num).toDouble()),
          ) ??
          {},
      preCrashPrices:
          (json['preCrashPrices'] as Map<String, dynamic>?)?.map(
            (k, v) => MapEntry(k, (v as num).toDouble()),
          ) ??
          {},
      recoveryStartPrices:
          (json['recoveryStartPrices'] as Map<String, dynamic>?)?.map(
            (k, v) => MapEntry(k, (v as num).toDouble()),
          ) ??
          {},
      priceHistory:
          (json['priceHistory'] as Map<String, dynamic>?)?.map(
            (k, v) => MapEntry(
              k,
              (v as List<dynamic>).map((e) => (e as num).toDouble()).toList(),
            ),
          ) ??
          {},
      // Missing entirely (or a shorter list than priceHistory) for sessions
      // persisted before this field existed — computeChartData falls back
      // to synthetic timestamps for those, see its own doc comment.
      priceHistoryTimestamps:
          (json['priceHistoryTimestamps'] as Map<String, dynamic>?)?.map(
            (k, v) => MapEntry(
              k,
              (v as List<dynamic>).map((e) => (e as num).toInt()).toList(),
            ),
          ) ??
          {},
      currentWeights:
          (json['currentWeights'] as Map<String, dynamic>?)?.map(
            (k, v) => MapEntry(k, (v as num).toDouble()),
          ) ??
          {},
      lastTickTimestamp: json['lastTickTimestamp'] != null
          ? DateTime.parse(json['lastTickTimestamp'] as String)
          : null,
      diversificationBonusRecorded:
          json['diversificationBonusRecorded'] as bool? ?? false,
      catastropheSurvivalRecorded:
          json['catastropheSurvivalRecorded'] as bool? ?? false,
      soldDuringCatastrophe:
          (json['soldDuringCatastrophe'] as List<dynamic>?)
              ?.map((e) => e as String)
              .toSet() ??
          const <String>{},
      customDurationDays: json['customDurationDays'] as int?,

      // ── Hype: sector-wide trending move (0-2 concurrent) ──────
      activeHypeEvents:
          (json['activeHypeEvents'] as List<dynamic>?)
              ?.map((e) => HypeEvent.fromJson(e as Map<String, dynamic>))
              .toList() ??
          const [],
      lastHypeCheckedEpoch: json['lastHypeCheckedEpoch'] as int? ?? -1,

      // ── Block 6: Casino wall-clock epoch history ──────────
      lastEpochRollAt: json['lastEpochRollAt'] != null
          ? DateTime.parse(json['lastEpochRollAt'] as String)
          : null,
      epochHistory:
          (json['epochHistory'] as List<dynamic>?)
              ?.map((e) => EpochRecord.fromJson(e as Map<String, dynamic>))
              .toList() ??
          const [],
      lastNewsCheckedEpoch: json['lastNewsCheckedEpoch'] as int? ?? -1,
    );
    // Restore active News event if present
    if (json['activeNewsEvent'] != null) {
      s.activeNewsEvent = NewsEvent.fromJson(
        json['activeNewsEvent'] as Map<String, dynamic>,
      );
    }
    // Restore epoch price ranges
    s.epochPriceRanges = {};
    for (final h in s.holdings) {
      final bp =
          s.basePrices[h.symbol] ?? s.currentPrices[h.symbol] ?? h.entryPrice;
      s.epochPriceRanges[h.symbol] = EpochPriceRange(bp, bp);
    }
    return s;
  }

  // ── Session Management ───────────────────────────────────────────

  /// Create a new session in setup mode.
  String createSession(
    TestDuration duration,
    double startingCash, {
    int? customDurationDays,
    int? simulationSeed,
  }) {
    _testCounter++;
    final id =
        'st_${DateTime.now().millisecondsSinceEpoch}_${_random.nextInt(9999)}';
    final seed = simulationSeed ?? _random.nextInt(99999999) + 1;
    _sessionRandom[id] = Random(seed);
    final session = StressTestSession(
      id: id,
      duration: duration,
      startingCash: startingCash,
      customDurationDays: customDurationDays,
      simulationSeed: seed,
      priceHistory: const {},
      priceHistoryTimestamps: const {},
    );
    state = [...state, session];
    _save();
    _syncToSupabase();
    return id;
  }

  /// Whether the user can create a new session given a concurrent-slot cap.
  /// Counts only currently ACTIVE sessions — NOT lifetime total. An earlier
  /// version gated on the lifetime `_testCounter`, which permanently locked
  /// users out once they'd ever created 5 sessions, even after completing
  /// or deleting them (real bug, fixed in 45d8d77 — see
  /// project_fomo_shield_widget_polish_and_stress_test_fixes memory).
  bool canCreateSession(int maxConcurrent) {
    final activeCount =
        state.where((s) => s.status == StressTestStatus.active).length;
    return activeCount < maxConcurrent;
  }

  /// Whether this is the user's first ever session (ad-free for free users).
  bool isFirstFreeSession() => _testCounter <= 1;

  /// Returns the total number of sessions created by this user.
  int get totalSessionsCreated => _testCounter;

  /// Returns the verdict archive (lightweight completed test records).
  List<VerdictArchiveEntry> get verdictArchive => _verdictArchive;

  /// Increment the open counter and return true if an ad should be shown
  /// (every Nth opening for free users who are past their first session).
  bool checkAndIncrementOpenCounter() {
    _openCounter++;
    _save();
    if (isFirstFreeSession()) return false; // first session: no ads
    return _openCounter % _adEveryNOpen == 0;
  }

  /// Reset open counter (e.g. after ad is shown).
  void resetOpenCounter() {
    _openCounter = 0;
    _save();
  }

  /// ── Task 1.7: Delete a session — wipes heavy ephemeral payload ──
  /// Removes the session from `state`, then `_save()` rewrites
  /// `active_stress_test_sessions` without this session's data,
  /// effectively purging all ticks, trades, and price history.
  /// The verdict history (`stress_test_verdicts_history`) is NOT touched.
  void deleteSession(String id) {
    state = state.where((s) => s.id != id).toList();
    _sessionRandom.remove(id);
    _save();
    _syncToSupabase();
  }

  /// ── Task 1.7: Delete ALL sessions — wipes both caches ─────────
  /// Clears active sessions, verdict history, and all counters.
  void deleteAllSessions() {
    if (state.isEmpty && _testCounter == 0 && _verdictArchive.isEmpty) return;
    state = [];
    _verdictArchive = [];
    _testCounter = 0;
    _sessionRandom.clear();
    _save();
    _syncToSupabase();
  }

  /// Get a session by ID.
  StressTestSession? getSession(String id) {
    try {
      return state.firstWhere((s) => s.id == id);
    } catch (_) {
      return null;
    }
  }

  /// Set an external price (from Finnhub) for a symbol not yet in the portfolio.
  /// Used when viewing a new company before buying — stores the Finnhub price
  /// so the engine can display it as current price until the engine takes over.
  void setExternalPrice(String sessionId, String symbol, double price) {
    final idx = state.indexWhere((s) => s.id == sessionId);
    if (idx < 0) return;

    final session = state[idx];
    state = [
      for (int i = 0; i < state.length; i++)
        if (i == idx)
          StressTestSession(
            id: session.id,
            duration: session.duration,
            startingCash: session.startingCash,
            cash: session.cash,
            holdings: session.holdings,
            trades: session.trades,
            status: session.status,
            createdAt: session.createdAt,
            startedAt: session.startedAt,
            completedAt: session.completedAt,
            boughtAtPeakCount: session.boughtAtPeakCount,
            soldAtBottomCount: session.soldAtBottomCount,
            maxSingleAssetAllocation: session.maxSingleAssetAllocation,
            blackSwanSurvived: session.blackSwanSurvived,
            hasExperiencedCatastrophe: session.hasExperiencedCatastrophe,
            catastropheCooldown: session.catastropheCooldown,
            // ── Casino Wall-Clock State + other engine state — must ──
            // survive every call, same fix as executeTrade's rebuild
            // (trades_engine.dart). Previously omitted here entirely,
            // silently resetting casinoLastCatastropheEpoch to its
            // constructor default (-100) every time the user viewed a
            // stock detail page mid-active-test — which made the
            // scripted-recovery window (casino_epochs.dart's
            // _rollScenario) permanently unreachable, since
            // epochsSinceLastCatastrophe is computed against that
            // field. Also silently reset simulationSeed to 0
            // (breaks RNG determinism) and stabilizationDeadlines to {}.
            casinoCatastropheCooldown: session.casinoCatastropheCooldown,
            casinoDeclineStreak: session.casinoDeclineStreak,
            casinoCatastropheCount: session.casinoCatastropheCount,
            casinoLastCatastropheEpoch: session.casinoLastCatastropheEpoch,
            simulationSeed: session.simulationSeed,
            enableDeveloperTrace: session.enableDeveloperTrace,
            stabilizationDeadlines: session.stabilizationDeadlines,
            lastTickTimestamp: session.lastTickTimestamp,
            currentPrices: {...session.currentPrices, symbol: price},
            basePrices: {...session.basePrices, symbol: price},
            epochPriceRanges: session.epochPriceRanges,
            preCrashPrices: session.preCrashPrices,
            recoveryStartPrices: session.recoveryStartPrices,
            realizedPnl: session.realizedPnl,
            customDurationDays: session.customDurationDays,
            psychologyProfile: session.psychologyProfile,
            activeNewsEvent: session.activeNewsEvent,
            lastNewsCheckedEpoch: session.lastNewsCheckedEpoch,
            activeHypeEvents: session.activeHypeEvents,
            lastHypeCheckedEpoch: session.lastHypeCheckedEpoch,
            priceHistory: {
              ...session.priceHistory,
              symbol: [...(session.priceHistory[symbol] ?? []), price],
            },
            priceHistoryTimestamps: {
              ...session.priceHistoryTimestamps,
              symbol: [
                ...(session.priceHistoryTimestamps[symbol] ?? []),
                DateTime.now().millisecondsSinceEpoch,
              ],
            },
            explanationLog: session.explanationLog,
            currentWeights: session.currentWeights,
            soldDuringCatastrophe: session.soldDuringCatastrophe,
            diversificationBonusRecorded: session.diversificationBonusRecorded,
            catastropheSurvivalRecorded: session.catastropheSurvivalRecorded,
            lastEpochRollAt: session.lastEpochRollAt,
            epochHistory: session.epochHistory,
          )
        else
          state[i],
    ];
    _save();
  }

  // ── Set Duration (Setup Phase) ──────────────────────────────────

  /// Update the duration of a session during setup phase.
  void setSessionDuration(
    String sessionId,
    TestDuration duration, {
    int? customDurationDays,
  }) {
    final idx = state.indexWhere((s) => s.id == sessionId);
    if (idx < 0) return;

    final session = state[idx];
    if (session.status != StressTestStatus.setup) return;

    state = [
      for (int i = 0; i < state.length; i++)
        if (i == idx)
          StressTestSession(
            id: session.id,
            duration: duration,
            startingCash: session.startingCash,
            cash: session.cash,
            holdings: session.holdings,
            trades: session.trades,
            status: session.status,
            createdAt: session.createdAt,
            startedAt: session.startedAt,
            boughtAtPeakCount: session.boughtAtPeakCount,
            soldAtBottomCount: session.soldAtBottomCount,
            maxSingleAssetAllocation: session.maxSingleAssetAllocation,
            blackSwanSurvived: session.blackSwanSurvived,
            hasExperiencedCatastrophe: session.hasExperiencedCatastrophe,
            catastropheCooldown: session.catastropheCooldown,
            currentPrices: Map.from(session.currentPrices),
            basePrices: Map.from(session.basePrices),
            preCrashPrices: Map.from(session.preCrashPrices),
            recoveryStartPrices: Map.from(session.recoveryStartPrices),
            customDurationDays:
                customDurationDays ?? session.customDurationDays,
            psychologyProfile: session.psychologyProfile,
            activeNewsEvent: session.activeNewsEvent,
            lastNewsCheckedEpoch: session.lastNewsCheckedEpoch,
            activeHypeEvents: session.activeHypeEvents,
            lastHypeCheckedEpoch: session.lastHypeCheckedEpoch,
            priceHistory: session.priceHistory,
            priceHistoryTimestamps: session.priceHistoryTimestamps,
            explanationLog: session.explanationLog,
            currentWeights: session.currentWeights,
            soldDuringCatastrophe: session.soldDuringCatastrophe,
            diversificationBonusRecorded: session.diversificationBonusRecorded,
            catastropheSurvivalRecorded: session.catastropheSurvivalRecorded,
            lastEpochRollAt: session.lastEpochRollAt,
            epochHistory: session.epochHistory,
          )
        else
          state[i],
    ];
    _save();
  }

  // ── Start Test ───────────────────────────────────────────────────

  /// Start the stress test: generate epochs and begin simulation.
  void startTest(String sessionId) {
    final idx = state.indexWhere((s) => s.id == sessionId);
    if (idx < 0) return;

    final session = state[idx];
    if (session.status != StressTestStatus.setup) return;

    final now = DateTime.now();

    // ── Per-session RNG ─────────────────────────────────────────
    final rng = _sessionRandom[sessionId] ?? Random(session.simulationSeed);
    _sessionRandom[sessionId] = rng;

    // ── Initialize Scenario Fatigue weights ─────────────────────
    // hype/speculation excluded: they're per-company events (Block 5),
    // never rolled by the epoch roulette — see isPerCompanyEvent.
    // recovery excluded: it's scripted (forced for 2 epochs right after
    // a catastrophe), never weighted-random — see isScriptedRecovery.
    final Map<String, double> fatigueWeights = {};
    for (final s in MarketScenario.values) {
      if (!s.isCatastrophe && !s.isPerCompanyEvent && !s.isScriptedRecovery) {
        fatigueWeights[s.name] = s.weight.toDouble();
      }
    }

    // ── Zero Roll: Roll first scenario, don't pre-generate ────
    // Deterministic per-epoch seed (Object.hash(simulationSeed, epochIndex))
    // instead of the shared `rng` stream: _sessionRandom is in-memory-only
    // and doesn't survive an app restart, so any roll fed from a lazily
    // re-seeded Random(simulationSeed) — which every subsequent roll is,
    // once the app has been closed and reopened — must not depend on the
    // stream's in-memory position. See casino_epochs.dart's other roll
    // sites for the full fix and the harness log proving the bug.
    final firstScenario = _rollScenario(
      session,
      rng: Random(Object.hash(session.simulationSeed, 0)),
    );

    // Push the first EpochRecord
    final firstRecord = EpochRecord(
      index: 0,
      scenario: firstScenario,
      startedAt: now,
    );

    // ── Casino state for epoch 0 (device-test bug, 2026-07-21) ──────
    // Every OTHER roll site (_catchUp's loop, _simulateCurrentPrices'
    // inline live roll, debugForceEpochRoll) updates
    // casinoLastCatastropheEpoch/casinoCatastropheCooldown/
    // casinoCatastropheCount/casinoDeclineStreak based on whether the
    // scenario it just rolled isCatastrophe/isDecline — this one used to
    // hard-code all four back to their session-start defaults regardless
    // of what firstScenario actually was. If the very first epoch rolled
    // Crash/BlackSwan, casinoLastCatastropheEpoch stayed at -100 instead
    // of 0, so the NEXT roll's scripted-recovery check
    // (epochIdx - lastCatIdx <= 2) saw a gap of 100+ epochs and silently
    // fell through to the normal roulette instead of forcing Recovery —
    // confirmed on-device: Epoch 1 Crash → Epoch 2 Volatility, no
    // Recovery ever appeared in the timeline widget.
    final firstIsCatastrophe = firstScenario.isCatastrophe;
    final firstIsDecline = firstScenario.isDecline;

    final newSession = StressTestSession(
      id: session.id,
      duration: session.duration,
      startingCash: session.startingCash,
      cash: session.cash,
      holdings: session.holdings,
      trades: session.trades,
      status: StressTestStatus.active,
      createdAt: session.createdAt,
      startedAt: now,
      boughtAtPeakCount: session.boughtAtPeakCount,
      soldAtBottomCount: session.soldAtBottomCount,
      maxSingleAssetAllocation: session.maxSingleAssetAllocation,
      blackSwanSurvived: session.blackSwanSurvived,
      hasExperiencedCatastrophe: session.hasExperiencedCatastrophe,
      catastropheCooldown: session.catastropheCooldown,
      currentPrices: Map.from(session.currentPrices),
      basePrices: Map.from(session.basePrices),
      // Mirrors the epoch-0-catastrophe fix above: if the very first
      // rolled epoch is itself Crash/BlackSwan, snapshot the pre-crash
      // anchor now too, so a Recovery pair rolling in right after epoch 0
      // has a real crash-drop % to weight against (same as any other
      // catastrophe mid-test — see casino_epochs.dart's roll sites).
      preCrashPrices: firstIsCatastrophe
          ? Map.from(session.currentPrices)
          : {},
      recoveryStartPrices: const {},
      currentWeights: fatigueWeights,
      psychologyProfile: session.psychologyProfile,
      simulationSeed: rng.nextInt(99999999) + 1,
      catastropheSurvivalRecorded: false,
      customDurationDays: session.customDurationDays,
      casinoCatastropheCooldown: firstIsCatastrophe ? 2 : 0,
      casinoDeclineStreak: firstIsDecline ? 1 : 0,
      casinoCatastropheCount: firstIsCatastrophe ? 1 : 0,
      casinoLastCatastropheEpoch: firstIsCatastrophe ? 0 : -100,
      priceHistory: () {
        final history = <String, List<double>>{};
        for (final h in session.holdings) {
          final p = session.currentPrices[h.symbol] ?? h.entryPrice;
          history[h.symbol] = [p];
        }
        return history;
      }(),
      priceHistoryTimestamps: () {
        final timestamps = <String, List<int>>{};
        for (final h in session.holdings) {
          timestamps[h.symbol] = [now.millisecondsSinceEpoch];
        }
        return timestamps;
      }(),
      explanationLog: session.explanationLog,
      soldDuringCatastrophe: session.soldDuringCatastrophe,
      diversificationBonusRecorded: session.diversificationBonusRecorded,
      // ── Block 5 + 6 + News: Fresh for new test ──
      lastEpochRollAt: now,
      epochHistory: [firstRecord],
      activeNewsEvent: null,
      lastNewsCheckedEpoch: -1,
      activeHypeEvents: const [],
      lastHypeCheckedEpoch: -1,
    );
    newSession.epochPriceRanges = {};
    for (final h in session.holdings) {
      final p = session.currentPrices[h.symbol] ?? h.entryPrice;
      newSession.epochPriceRanges[h.symbol] = EpochPriceRange(p, p);
    }

    state = [
      for (int i = 0; i < state.length; i++)
        if (i == idx) newSession else state[i],
    ];
    _save();
    _syncToSupabase();
  }

  /// Refresh prices (called when user opens the stress test screen).
  void refreshPrices(String sessionId) {
    final idx = state.indexWhere((s) => s.id == sessionId);
    if (idx < 0) return;
    _catchUp(idx);
  }

  // ── Test Completion ──────────────────────────────────────────────

  /// Complete a test (timer expired or user triggered).
  void _completeTest(int idx) {
    final session = state[idx];
    state = [
      for (int i = 0; i < state.length; i++)
        if (i == idx)
          StressTestSession(
            id: session.id,
            duration: session.duration,
            startingCash: session.startingCash,
            cash: session.cash,
            holdings: session.holdings,
            trades: session.trades,
            status: StressTestStatus.completed,
            createdAt: session.createdAt,
            startedAt: session.startedAt,
            completedAt: DateTime.now(),
            boughtAtPeakCount: session.boughtAtPeakCount,
            soldAtBottomCount: session.soldAtBottomCount,
            maxSingleAssetAllocation: session.maxSingleAssetAllocation,
            blackSwanSurvived: session.blackSwanSurvived,
            hasExperiencedCatastrophe: session.hasExperiencedCatastrophe,
            catastropheCooldown: session.catastropheCooldown,
            currentPrices: session.currentPrices,
            basePrices: session.basePrices,
            epochPriceRanges: session.epochPriceRanges,
            preCrashPrices: session.preCrashPrices,
            recoveryStartPrices: session.recoveryStartPrices,
            stabilizationDeadlines: session.stabilizationDeadlines,
            simulationSeed: session.simulationSeed,
            explanationLog: session.explanationLog,
            currentWeights: session.currentWeights,
            psychologyProfile: session.psychologyProfile,
            activeNewsEvent: session.activeNewsEvent,
            lastNewsCheckedEpoch: session.lastNewsCheckedEpoch,
            activeHypeEvents: session.activeHypeEvents,
            lastHypeCheckedEpoch: session.lastHypeCheckedEpoch,
            priceHistory: session.priceHistory,
            priceHistoryTimestamps: session.priceHistoryTimestamps,
            soldDuringCatastrophe: session.soldDuringCatastrophe,
            diversificationBonusRecorded: session.diversificationBonusRecorded,
            catastropheSurvivalRecorded: session.catastropheSurvivalRecorded,
            lastEpochRollAt: session.lastEpochRollAt,
            epochHistory: session.epochHistory,
          )
        else
          state[i],
    ];

    // Archive the verdict and remove the session from active state
    final completed = state.firstWhere((s) => s.id == session.id);
    final verdict = calculateVerdict(session.id);
    final entry = VerdictArchiveEntry(
      sessionId: session.id,
      durationLabel: session.duration.displayName,
      startingCash: session.startingCash,
      finalValue: completed.totalValue,
      pnlPercent: completed.profitLossPercent,
      totalTrades: completed.trades.length,
      holdingCount: completed.holdings.length,
      completedAt: completed.completedAt ?? DateTime.now(),
      verdict: verdict,
    );
    // ── Task 1.7: FIFO Verdict History ──────────────────────────
    // Oldest record at index 0, newest appended at the end.
    // When length exceeds 20, drop the oldest (index 0).
    _verdictArchive.add(entry);
    if (_verdictArchive.length > 20) {
      _verdictArchive.removeAt(0);
    }

    // ── Task 1.7: Wipe completed session from active cache ──────
    // The session is removed from `state` below, so when _save()
    // rewrites the active_stress_test_sessions key, this session's
    // heavy payload (ticks, trades, price history) is fully purged.
    state = state.where((s) => s.id != session.id).toList();
    _sessionRandom.remove(session.id);
    _save();
    _syncToSupabase();
  }

  /// Manually complete a test before its natural end. Only Infinite ("until
  /// bored") tests support this, gated on [StressTestSession.canExitInfinite]
  /// (minimum 14 days elapsed). Fixed-duration (week1/month1/months3) and
  /// Custom tests always auto-complete on their own schedule and are never
  /// manually terminable early — reverted from a previous incorrect change
  /// that allowed early exit for Custom.
  bool terminateTest(String sessionId) {
    final idx = state.indexWhere((s) => s.id == sessionId);
    if (idx < 0) return false;

    final session = state[idx];
    if (session.duration != TestDuration.infinite) return false;
    if (!session.canExitInfinite) return false;

    _completeTest(idx);
    return true;
  }

  /// Test-only: force-complete a session immediately, bypassing every
  /// duration/gate check (wall-clock time limits, canExitInfinite, etc).
  /// Mirrors [CasinoEpochsEngine.debugForceEpochRoll] — lets tests exercise
  /// verdict-archive behavior (FIFO cap, persistence, entry structure)
  /// without needing real elapsed time to satisfy a duration's actual
  /// completion gate.
  @visibleForTesting
  void debugCompleteTest(String sessionId) {
    final idx = state.indexWhere((s) => s.id == sessionId);
    if (idx == -1) return;
    _completeTest(idx);
  }

  // ── Ad Counter ───────────────────────────────────────────────────

  /// Check if an ad should be shown (for free users on BUY/SELL).
  /// Returns true if ad should be shown.
  /// First session (ad-free) never shows trade ads.
  bool checkAndIncrementAd() {
    if (isFirstFreeSession()) return false;
    _adCounter++;
    _save();
    return _adCounter % _adEveryNTrades == 0;
  }

  // ── Verdict Calculation ──────────────────────────────────────────

  /// Calculate the psychological verdict for a completed session.
  PsychologicalVerdict calculateVerdict(String sessionId) {
    final session = state.firstWhere(
      (s) => s.id == sessionId,
      orElse: () => StressTestSession(
        id: '',
        duration: TestDuration.week1,
        startingCash: 0,
      ),
    );

    if (session.id.isEmpty) {
      return const PsychologicalVerdict(
        primaryType: VerdictType.buffettShield,
        fsScore: 0,
        title: 'No Data',
        description: 'Session data not found.',
      );
    }

    final totalTrades = session.trades.length;
    final pnl = session.profitLossPercent;
    final soldBottom = session.soldAtBottomCount;
    final boughtPeak = session.boughtAtPeakCount;
    final maxAlloc = session.maxSingleAssetAllocation;
    final catSurvived = session.blackSwanSurvived;

    // Calculate FS Score (0-100)
    int fsScore = _calculateFsScore(session);

    // Priority chain
    VerdictType primaryType;
    String title;
    String description;
    bool hasDiversificationWarning = maxAlloc > 0.50;
    bool hasAbsoluteShieldBadge = false;

    // Priority 1: Panic (Fear)
    if (soldBottom >= 2 && pnl < 0) {
      primaryType = VerdictType.panic;
      title = 'PANIC — Fear-Driven Investor';
      description =
          'You let fear dictate your actions, selling assets at the worst possible '
          'moment and locking in losses. The data shows you sold at the bottom '
          'at least twice while the market was in decline. '
          'Emotional discipline is the cornerstone of successful investing. '
          'Consider setting stop-loss limits and sticking to a predefined strategy '
          'rather than reacting to short-term market noise.';
    }
    // Priority 2: FOMO (Greed)
    else if (boughtPeak >= 2) {
      primaryType = VerdictType.fomo;
      title = 'FOMO — Momentum Chaser';
      description =
          'You exhibit classic FOMO (Fear Of Missing Out) behavior, buying assets '
          'near their peak prices. This pattern of chasing green candles often leads '
          'to overpaying for assets. Successful investors buy when there is '
          '"blood in the streets," not when euphoria takes over. '
          'Try dollar-cost averaging instead of lump-sum buying at all-time highs.';
    }
    // Priority 3: Active Trader
    else if (totalTrades > 15) {
      primaryType = VerdictType.activeTrader;
      title = 'ACTIVE TRADER — High-Frequency Risk';
      description =
          'You executed over $totalTrades trades in this simulation. '
          'While trading activity can be profitable, it also incurs significant '
          'costs through commissions, slippage, and taxes. '
          'More importantly, frequent trading often crosses the line from '
          'methodical investing to dopamine-driven speculation. '
          'Consider whether each trade has a clear thesis behind it.';
    }
    // Priority 4: Buffett Shield (Ultimate Praise)
    else if (totalTrades <= 5 && pnl > 0 && soldBottom == 0) {
      primaryType = VerdictType.buffettShield;
      title = 'BUFFETT SHIELD — Disciplined Investor';
      description =
          'You demonstrated remarkable discipline by making few, well-timed trades, '
          'holding through volatility, and avoiding panic selling. '
          'This patient, long-term approach is the hallmark of legendary investors.';

      if (catSurvived) {
        fsScore = (fsScore + 20).clamp(0, 100);
        hasAbsoluteShieldBadge = true;
        title = 'ABSOLUTE SHIELD — Master of Emotions';
        description +=
            '\n\nExceptional: You not only survived a Black Swan event — you bought '
            'the dip and held steady. This is the rarest and most profitable '
            'investing mindset. You have earned the ABSOLUTE SHIELD badge.';
      }
    }
    // Fallback: Balanced
    else {
      primaryType = VerdictType.buffettShield;
      title = 'BALANCED — Developing Investor';
      description =
          'Your trading patterns show a mix of behaviors. While you avoided '
          'major emotional pitfalls, there is room for improvement in your '
          'decision-making process. Focus on building a systematic approach '
          'to investing that minimizes emotional reactions.';
    }

    return PsychologicalVerdict(
      primaryType: primaryType,
      fsScore: fsScore.clamp(0, 100),
      title: title,
      description: description,
      hasDiversificationWarning: hasDiversificationWarning,
      hasAbsoluteShieldBadge: hasAbsoluteShieldBadge,
    );
  }

  int _calculateFsScore(StressTestSession session) {
    final totalTrades = session.trades.length;
    final pnl = session.profitLossPercent;
    final soldBottom = session.soldAtBottomCount;
    final boughtPeak = session.boughtAtPeakCount;
    final maxAlloc = session.maxSingleAssetAllocation;
    final hasCat = session.hasExperiencedCatastrophe;

    int score = 50; // start at neutral

    // PnL contribution (±30 pts)
    score += (pnl / 2).round().clamp(-30, 30);

    // Penalty for panic selling (-15 pts per occurrence)
    score -= soldBottom * 15;

    // Penalty for buying peaks (-10 pts per occurrence)
    score -= boughtPeak * 10;

    // Penalty for over-trading
    if (totalTrades > 15) score -= 10;
    if (totalTrades > 30) score -= 10;

    // Penalty for over-concentration
    if (maxAlloc > 0.80) {
      score -= 15;
    } else if (maxAlloc > 0.50) {
      score -= 5;
    }

    // Bonus for surviving catastrophe
    if (hasCat && session.blackSwanSurvived) score += 20;

    // Bonus for low trading + profit (Buffett behavior)
    if (totalTrades <= 5 && pnl > 0) score += 15;

    return score.clamp(0, 100);
  }

  // ── Chart Data ──────────────────────────────────────────────────

  /// Compute historical portfolio value data points for the Market Timeline
  /// chart, from REAL per-tick simulation data (`session.priceHistory`) —
  /// not a reverse-calculation from each epoch's static `.drift`/
  /// `.priceVolatility` getters (the old approach here, which was never
  /// actually wired to any visible chart and produced numbers unrelated to
  /// what the simulation actually did tick-by-tick).
  ///
  /// Alignment: each held symbol's price history is appended once per
  /// simulated tick, but a symbol bought partway through the test has a
  /// SHORTER history than one held from the start. Every symbol's array
  /// ends at "now" (the most recent tick), so they're aligned from the
  /// END, truncated to the shortest current holding's history — before
  /// that point, the newest holding simply wasn't part of the portfolio.
  ///
  /// Known limitation, accepted rather than solved: this uses CURRENT
  /// share counts and CURRENT cash for every historical point, because the
  /// engine doesn't track historical share-count changes from buys/sells
  /// over time. This is an honest "how would my current portfolio have
  /// performed" retrospective, not a perfectly reconstructed historical
  /// NAV that accounts for trade timing.
  List<ChartDataPoint> computeChartData(String sessionId) {
    final session = getSession(sessionId);
    if (session == null || session.holdings.isEmpty) return [];

    final histories = <List<double>>[];
    // Real per-tick timestamps, same length/order as the matching entry in
    // `histories` — null (or shorter than its price history) for a symbol
    // whose data predates `priceHistoryTimestamps` existing, or whenever
    // some other legacy write path skipped it.
    final timestampHistories = <List<int>?>[];
    for (final h in session.holdings) {
      final hist = session.priceHistory[h.symbol];
      if (hist == null || hist.isEmpty) return [];
      histories.add(hist);
      timestampHistories.add(session.priceHistoryTimestamps[h.symbol]);
    }
    final minLen = histories.map((h) => h.length).reduce(min);
    if (minLen < 2) return [];

    final now = DateTime.now();
    final points = <ChartDataPoint>[];
    for (int k = 0; k < minLen; k++) {
      double value = session.cash;
      DateTime? realTime;
      for (int i = 0; i < session.holdings.length; i++) {
        final hist = histories[i];
        // Right-aligned: count from the end so every symbol's k-th-from-
        // last point corresponds to the same simulated tick.
        final idx = hist.length - minLen + k;
        value += session.holdings[i].shares * hist[idx];

        // Every currently-held symbol gets exactly one price (and one
        // timestamp) appended per tick-processing call, so any symbol's
        // real timestamp at this same right-aligned idx is representative
        // of the whole point — first one found wins.
        if (realTime == null) {
          final ts = timestampHistories[i];
          if (ts != null && ts.length == hist.length) {
            realTime = DateTime.fromMillisecondsSinceEpoch(ts[idx]);
          }
        }
      }
      // Fallback for points recorded before real per-tick timestamps
      // existed: the old synthetic "nominally _tickSeconds apart" spacing.
      // Catch-up batches compress real gaps, so this was always an
      // approximation — real timestamps (above) replace it going forward.
      final ticksAgo = minLen - 1 - k;
      final time =
          realTime ??
          now.subtract(Duration(seconds: ticksAgo * _tickSeconds));
      points.add(ChartDataPoint(time, value));
    }
    return points;
  }
}

// ---------------------------------------------------------------------------
// Provider
// ---------------------------------------------------------------------------

final stressTestProvider =
    StateNotifierProvider<StressTestNotifier, List<StressTestSession>>((ref) {
      final user = ref.watch(currentUserProvider);
      final supabaseService = ref.watch(userDataServiceProvider);
      return StressTestNotifier(
        userId: user?.id,
        supabaseService: supabaseService,
      );
    });

/// Reactive provider for a stress test session by ID (family).
/// Each screen passes its own [sessionId] — no global state, no race.
final stressTestSessionProvider = Provider.family<StressTestSession?, String>((
  ref,
  sessionId,
) {
  final sessions = ref.watch(stressTestProvider);
  try {
    return sessions.firstWhere((s) => s.id == sessionId);
  } catch (_) {
    return null;
  }
});

/// Auto-refresh trigger for price updates.
final stressTestRefreshProvider = StateProvider<int>((ref) => 0);

/// Per-session timeline tick — incremented by the screen's periodic timer
/// to ensure epoch progress updates independently for each test tab.
final timelineTickProvider = StateProvider.family<int, String>(
  (ref, sessionId) => 0,
);

/// Per-session timeline snapshot.
///
/// Recalculated on every [timelineTickProvider] pulse (30s timer in screen).
/// Uses [calculateCurrentTimeline] which reads from [session.epochHistory]
/// (single source of truth, unified with Guardian's _getCurrentEpoch).
final timelineSnapshotProvider = Provider.family<TimelineSnapshot?, String>((
  ref,
  sessionId,
) {
  final session = ref.watch(stressTestSessionProvider(sessionId));
  // React to timer ticks — triggers recalculation every 30s
  ref.watch(timelineTickProvider(sessionId));
  if (session == null) return null;
  final config = session.duration.config;
  return calculateCurrentTimeline(session, config);
});

/// Verdict archive — lightweight history of completed stress tests.
final verdictArchiveProvider = Provider<List<VerdictArchiveEntry>>((ref) {
  final notifier = ref.read(stressTestProvider.notifier);
  return notifier.verdictArchive;
});

// ═══════════════════════════════════════════════════════════════════════════
// Reactive Analytics Engine (Task 2.7)
// ═══════════════════════════════════════════════════════════════════════════
// CRITICAL — Design Principle:
//   Uses ref.watch to react to portfolio changes AUTOMATICALLY.
//   NEVER mutates a StateProvider/StateNotifier during build().
//   The analytics are computed as a pure derivation of session state,
//   marked dirty by Riverpod's dependency tracking whenever the
//   underlying stressTestProvider changes.
//
//   This eliminates the root cause of:
//     "Tried to modify a provider while the widget tree was building."
// ═══════════════════════════════════════════════════════════════════════════

/// Reactive analytics for a stress test session by ID (family).
///
/// Recomputed automatically whenever:
///   - The engine updates prices/balance (via [stressTestRefreshProvider])
///   - A trade is executed
///
/// Returns [StressTestAnalytics.empty] when no session is active,
/// ensuring the UI always has a safe, non-null value to render.
final stressTestAnalyticsProvider =
    Provider.family<StressTestAnalytics, String>((ref, sessionId) {
      final session = ref.watch(stressTestSessionProvider(sessionId));
      if (session == null) return StressTestAnalytics.empty;
      return StressTestAnalytics.fromSession(session);
    });

// ---------------------------------------------------------------------------
// Chart Data Point
// ---------------------------------------------------------------------------

/// A single data point for charting portfolio value over time.
class ChartDataPoint {
  final DateTime time;
  final double value;

  const ChartDataPoint(this.time, this.value);
}
