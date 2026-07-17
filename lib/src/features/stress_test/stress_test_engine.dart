// ---------------------------------------------------------------------------
// Stress Test Engine — Riverpod State + Market Simulation + Scoring
// ---------------------------------------------------------------------------
// Manages stress test sessions, epoch-based market simulation, price
// generation, IPO events, anti-catastrophe protection, and the final
// psychological verdict calculation.
// ---------------------------------------------------------------------------

import 'dart:math';
import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'dart:convert';
import '../../core/supabase/supabase_providers.dart';
import 'stress_test_models.dart';

part 'gbm_engine.dart';
part 'casino_epochs.dart';
part 'trades_engine.dart';
part 'speculation_event.dart';

// ---------------------------------------------------------------------------
// Constants
// ---------------------------------------------------------------------------

const double _freeStartingCash = 5000;
const double _premiumStartingCash = 15000;
const int _freeMaxSessions = 1;
const int _premiumMaxSessions = 5;
const int _freeMaxTotalSessions = 2; // free: 1 ad-free + 1 with ads
const int _premiumMaxTotalSessions = 5; // premium: 5 total
const int _adEveryNTrades = 5; // show ad after every N trades for free users
const int _adEveryNOpen = 6; // show ad on every Nth opening

/// Wall-clock seconds per simulation tick.
const int _tickSeconds = 20;

/// Max ticks to simulate in catch-up (5 hours = 900 ticks @ 20s each).
const int _maxCatchUpTicks = 900;

/// 10 fictional companies for IPO events (Infinite mode only, 3% chance).
const List<Map<String, String>> _fictionalIpoCandidates = [
  {'symbol': 'NOVA', 'name': 'NovaTech Quantum'},
  {'symbol': 'ZEN', 'name': 'Zenith Biologics'},
  {'symbol': 'AURA', 'name': 'Aura Cyber Systems'},
  {'symbol': 'VERT', 'name': 'VertEx Robotics'},
  {'symbol': 'CORE', 'name': 'CoreVault Financial'},
  {'symbol': 'MORF', 'name': 'Morphic Energy'},
  {'symbol': 'DRIF', 'name': 'Drift Auto'},
  {'symbol': 'PULS', 'name': 'PulseMed Devices'},
  {'symbol': 'CASP', 'name': 'Caspian AI'},
  {'symbol': 'NEXO', 'name': 'NexoSpace Industries'},
];

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

/// Max total stress test sessions a user can ever create based on tier.
final maxStressTestTotalProvider = Provider<int>((ref) {
  final tier = ref.watch(subscriptionTierProvider);
  return (tier == SubscriptionTier.premium || tier == SubscriptionTier.admin)
      ? _premiumMaxTotalSessions
      : _freeMaxTotalSessions;
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

  StressTestNotifier({this._userId, int? seed}) : super([]) {
    _random = (seed != null) ? Random(seed) : Random();
    _load();
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
    // ── Ephemeral active sessions (heavy) ────────────────────────
    final raw = prefs.getString(_storageKey);
    if (raw != null) {
      try {
        final list = (jsonDecode(raw) as List<dynamic>)
            .map((e) => _sessionFromJson(e as Map<String, dynamic>))
            .toList();
        state = list;
        // Run catch-up for any active sessions
        _catchUpAll();
      } catch (_) {
        state = [];
      }
    }
    _adCounter = prefs.getInt(_adKey) ?? 0;
    _testCounter = prefs.getInt(_testKey) ?? 0;
    _openCounter = prefs.getInt(_openKey) ?? 0;
    // ── Isolated verdict history (lightweight, FIFO 20) ──────────
    _loadArchive(prefs);
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
      'simulationSeed': s.simulationSeed,
      'stabilizationDeadlines': s.stabilizationDeadlines.map(
        (k, v) => MapEntry(k, v.toIso8601String()),
      ),
      'priceHistory': s.priceHistory.map(
        (k, v) => MapEntry(k, v.map((e) => e).toList()),
      ),
      'status': s.status.name,
      'psychologyProfile': s.psychologyProfile.toJson(),
      'diversificationBonusRecorded': s.diversificationBonusRecorded,
      'catastropheSurvivalRecorded': s.catastropheSurvivalRecorded,
      'soldDuringCatastrophe': s.soldDuringCatastrophe.toList(),
      if (s.activeShock != null) 'activeShock': s.activeShock!.toJson(),
      'customDurationDays': s.customDurationDays,
      'companies': s.companies.map((k, v) => MapEntry(k, v.toJson())),
      // ── Block 5: Per-company spec/hype events ──────────────
      'specEvents': s.specEvents.map((e) => e.toJson()).toList(),
      'specEventCooldowns': s.specEventCooldowns.map(
        (k, v) => MapEntry(k, v.toIso8601String()),
      ),
      if (s.lastSpecEventCheckAt != null)
        'lastSpecEventCheckAt': s.lastSpecEventCheckAt!.toIso8601String(),
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
      priceHistory:
          (json['priceHistory'] as Map<String, dynamic>?)?.map(
            (k, v) => MapEntry(
              k,
              (v as List<dynamic>).map((e) => (e as num).toDouble()).toList(),
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
      companies:
          (json['companies'] as Map<String, dynamic>?)?.map(
            (k, v) =>
                MapEntry(k, CompanyStock.fromJson(v as Map<String, dynamic>)),
          ) ??
          const {},

      // ── Block 5: Per-company spec/hype events ──────────────
      specEvents:
          (json['specEvents'] as List<dynamic>?)
              ?.map((e) => CompanySpecEvent.fromJson(e as Map<String, dynamic>))
              .toList() ??
          const [],
      specEventCooldowns:
          (json['specEventCooldowns'] as Map<String, dynamic>?)?.map(
            (k, v) => MapEntry(k, DateTime.parse(v as String)),
          ) ??
          const {},
      lastSpecEventCheckAt: json['lastSpecEventCheckAt'] != null
          ? DateTime.parse(json['lastSpecEventCheckAt'] as String)
          : null,

      // ── Block 6: Casino wall-clock epoch history ──────────
      lastEpochRollAt: json['lastEpochRollAt'] != null
          ? DateTime.parse(json['lastEpochRollAt'] as String)
          : null,
      epochHistory:
          (json['epochHistory'] as List<dynamic>?)
              ?.map((e) => EpochRecord.fromJson(e as Map<String, dynamic>))
              .toList() ??
          const [],
    );
    // Restore active shock if present
    if (json['activeShock'] != null) {
      s.activeShock = MarketShock.fromJson(
        json['activeShock'] as Map<String, dynamic>,
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
    );
    state = [...state, session];
    _save();
    return id;
  }

  /// Check if the user can create a new session based on the given max.
  bool canCreateSession(int maxTotal) {
    return _testCounter < maxTotal;
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
            currentPrices: {...session.currentPrices, symbol: price},
            basePrices: {...session.basePrices, symbol: price},
            epochPriceRanges: session.epochPriceRanges,
            realizedPnl: session.realizedPnl,
            customDurationDays: session.customDurationDays,
            psychologyProfile: session.psychologyProfile,
            activeShock: session.activeShock,
            priceHistory: {
              ...session.priceHistory,
              symbol: [...(session.priceHistory[symbol] ?? []), price],
            },
            explanationLog: session.explanationLog,
            currentWeights: session.currentWeights,
            soldDuringCatastrophe: session.soldDuringCatastrophe,
            diversificationBonusRecorded: session.diversificationBonusRecorded,
            catastropheSurvivalRecorded: session.catastropheSurvivalRecorded,
            specEvents: session.specEvents,
            specEventCooldowns: session.specEventCooldowns,
            lastSpecEventCheckAt: session.lastSpecEventCheckAt,
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
            customDurationDays:
                customDurationDays ?? session.customDurationDays,
            psychologyProfile: session.psychologyProfile,
            activeShock: session.activeShock,
            priceHistory: session.priceHistory,
            explanationLog: session.explanationLog,
            currentWeights: session.currentWeights,
            soldDuringCatastrophe: session.soldDuringCatastrophe,
            diversificationBonusRecorded: session.diversificationBonusRecorded,
            catastropheSurvivalRecorded: session.catastropheSurvivalRecorded,
            specEvents: session.specEvents,
            specEventCooldowns: session.specEventCooldowns,
            lastSpecEventCheckAt: session.lastSpecEventCheckAt,
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
    final Map<String, double> fatigueWeights = {};
    for (final s in MarketScenario.values) {
      if (!s.isCatastrophe) {
        fatigueWeights[s.name] = s.weight.toDouble();
      }
    }

    // ── IPO generation (Infinite mode, ~3% chance) ──────────────
    final Map<String, CompanyStock> newCompanies = {};
    final Map<String, double> ipoPrices = {};
    if (session.duration == TestDuration.infinite && rng.nextDouble() < 0.03) {
      final heldSymbols = session.holdings.map((h) => h.symbol).toSet();
      final candidates = _fictionalIpoCandidates
          .where((c) => !heldSymbols.contains(c['symbol']))
          .toList();
      if (candidates.isNotEmpty) {
        final pick = candidates[rng.nextInt(candidates.length)];
        final sector = _getSector(pick['symbol']!);
        final pattern = rng.nextDouble() < 0.5
            ? IpoPattern.tesla
            : IpoPattern.reverse;
        newCompanies[pick['symbol']!] = CompanyStock(
          symbol: pick['symbol']!,
          companyName: pick['name']!,
          sector: sector,
          ipoPattern: pattern,
          ipoPhase: CompanyIpoPhase.shakeout,
          phaseWeeks: 0,
        );
        final ipoPrice = 30.0 + rng.nextDouble() * 120.0;
        ipoPrices[pick['symbol']!] = pattern == IpoPattern.tesla
            ? ipoPrice * (1 - (rng.nextDouble() * 0.15 + 0.15))
            : ipoPrice * (1 + (rng.nextDouble() * 0.30 + 0.30));
      }
    }

    // ── Zero Roll: Roll first scenario, don't pre-generate ────
    final firstScenario = _rollScenario(session, rng: rng);

    // Push the first EpochRecord
    final firstRecord = EpochRecord(
      index: 0,
      scenario: firstScenario,
      startedAt: now,
    );

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
      currentPrices: {...Map.from(session.currentPrices), ...ipoPrices},
      basePrices: {...Map.from(session.basePrices), ...ipoPrices},
      companies: newCompanies,
      currentWeights: fatigueWeights,
      psychologyProfile: session.psychologyProfile,
      simulationSeed: rng.nextInt(99999999) + 1,
      catastropheSurvivalRecorded: false,
      customDurationDays: session.customDurationDays,
      casinoCatastropheCooldown: 0,
      casinoDeclineStreak: 0,
      casinoCatastropheCount: 0,
      casinoLastCatastropheEpoch: -100,
      priceHistory: () {
        final history = <String, List<double>>{};
        for (final h in session.holdings) {
          final p = session.currentPrices[h.symbol] ?? h.entryPrice;
          history[h.symbol] = [p];
        }
        return history;
      }(),
      explanationLog: session.explanationLog,
      soldDuringCatastrophe: session.soldDuringCatastrophe,
      diversificationBonusRecorded: session.diversificationBonusRecorded,
      activeShock: session.activeShock,
      // ── Block 5 + 6: Fresh for new test ──
      specEvents: const [],
      specEventCooldowns: {},
      lastSpecEventCheckAt: now,
      lastEpochRollAt: now,
      epochHistory: [firstRecord],
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
  }

  /// Build a price contribution breakdown for explainable simulation.
  /// Factors always sum to exactly 100%.
  TickExplanation _explainPriceChange({
    required String symbol,
    required double priceBefore,
    required double priceAfter,
    required int epochIndex,
    required MarketScenario scenario,
    required MarketSector sector,
    required bool hasCorrection,
    double? marketDriftRaw,
    double? sectorDriftRaw,
    double? noiseRaw,
    double? companyDriftRaw,
  }) {
    // Raw weights for each factor (all per-tick scaled)
    double mW = (marketDriftRaw?.abs() ?? 0.0);
    double sW = (sectorDriftRaw?.abs() ?? 0.0);
    double nW = (noiseRaw?.abs() ?? 0.0);
    double cW = (companyDriftRaw?.abs() ?? 0.0);
    final double newsW = hasCorrection ? 0.15 : 0.0;

    final double totalW = mW + sW + nW + cW + newsW;
    if (totalW < 1e-12) {
      // No meaningful move → balanced default split
      return TickExplanation(
        epochIndex: epochIndex,
        symbol: symbol,
        priceBefore: priceBefore,
        priceAfter: priceAfter,
        contributions: const PriceContribution(
          marketPct: 40,
          sectorPct: 25,
          companyPct: 15,
          newsPct: 0,
          noisePct: 20,
        ),
        marketPhase: scenario.name,
        scenario: scenario.name,
      );
    }

    // Compute exact percentages
    double mPct = mW / totalW * 100;
    double sPct = sW / totalW * 100;
    double cPct = cW / totalW * 100;
    double nPct = nW / totalW * 100;
    double newsPct = newsW / totalW * 100;

    // Force exact 100 by adjusting the largest component
    double sum = mPct + sPct + cPct + nPct + newsPct;
    final double diff = 100.0 - sum;
    if (diff.abs() > 1e-10) {
      final List<double> components = [mPct, sPct, cPct, nPct, newsPct];
      final int maxIdx = components.indexOf(
        components.reduce((a, b) => a >= b ? a : b),
      );
      switch (maxIdx) {
        case 0:
          mPct += diff;
          break;
        case 1:
          sPct += diff;
          break;
        case 2:
          cPct += diff;
          break;
        case 3:
          nPct += diff;
          break;
        case 4:
          newsPct += diff;
          break;
      }
    }

    return TickExplanation(
      epochIndex: epochIndex,
      symbol: symbol,
      priceBefore: priceBefore,
      priceAfter: priceAfter,
      contributions: PriceContribution(
        marketPct: mPct.clamp(0, 100),
        sectorPct: sPct.clamp(0, 100),
        companyPct: cPct.clamp(0, 100),
        newsPct: newsPct.clamp(0, 100),
        noisePct: nPct.clamp(0, 100),
      ),
      marketPhase: scenario.name,
      scenario: scenario.name,
    );
  }

  /// Simulate current prices using sector-based market model.
  /// Each holding's price moves according to its sector's drift + noise.
  /// Virtual market is always open — rolls new casino scenarios on wall-clock.
  ///
  /// When [ticks] > 1 (catch-up mode), simulates multiple 20-second ticks
  /// in a granular loop so GBM produces smooth trajectories instead of
  /// hitting the clamp ceiling on a single mega-tick.
  void _simulateCurrentPrices(int idx, {int ticks = 1}) {
    final session = state[idx];
    if (session.holdings.isEmpty) return;

    final now = DateTime.now();

    // ── Casino Wall-Clock: check if it's time to roll a new epoch ──
    final rollInterval = _getRollInterval(session.duration);
    final lastRollAt = session.lastEpochRollAt ?? session.startedAt ?? now;
    if (now.difference(lastRollAt) >= rollInterval) {
      final rng = _sessionRandom[session.id] ?? Random(session.simulationSeed);
      _sessionRandom[session.id] = rng;
      final newScenario = _rollScenario(session, rng: rng);
      _applyScenarioFatigue(session, newScenario);

      // Update casino state
      if (newScenario.isCatastrophe) {
        session.casinoCatastropheCount++;
        session.casinoLastCatastropheEpoch = session.epochHistory.length;
        session.casinoCatastropheCooldown = 2;
        session.casinoDeclineStreak = 0;
      } else if (newScenario.isDecline) {
        session.casinoDeclineStreak++;
      } else {
        session.casinoDeclineStreak = 0;
        if (session.casinoCatastropheCooldown > 0) {
          session.casinoCatastropheCooldown--;
        }
      }

      // Close previous active epoch and start new one
      _recordEpochTransition(session, newScenario, now);
    }

    final currentEpoch = _getCurrentEpoch(session);
    if (currentEpoch == null) return;

    // ── Per-session RNG ─────────────────────────────────────────
    final rng = _sessionRandom[session.id] ?? Random(session.simulationSeed);
    _sessionRandom[session.id] = rng;

    final newPrices = Map<String, double>.from(session.currentPrices);
    final newRanges = Map<String, EpochPriceRange>.from(
      session.epochPriceRanges,
    );

    // Get sector params from the master matrix for this scenario
    final scenario = currentEpoch.scenario;

    // Snapshot of pre-bounce prices so explanationLog chain is consistent:
    // priceBefore MUST equal the previous tick's priceAfter.
    final Map<String, double> preBouncePrices = Map<String, double>.from(
      session.currentPrices,
    );

    // ── Block 5: Spec/Hype weekly wall-clock check ──────────────────
    // Runs at most once per call (regardless of the `ticks` batch size),
    // gated on real elapsed time rather than epoch rolls — epoch length
    // varies per test type (Block 6: 12h/24h/7d/5d), so tying this to the
    // epoch counter would fire far more often than the intended weekly
    // cadence. Mirrors the lastEpochRollAt pattern used for casino state.
    final lastSpecCheck =
        session.lastSpecEventCheckAt ?? session.startedAt ?? now;
    if (now.difference(lastSpecCheck) >= const Duration(days: 7)) {
      for (final h in session.holdings) {
        final newSpecEvent = _maybeFireSpecEvent(session, h.symbol, rng, now);
        if (newSpecEvent != null) {
          session.specEvents = [...session.specEvents, newSpecEvent];
        }
      }
      session.lastSpecEventCheckAt = now;
    }

    final explanations = Map<String, List<TickExplanation>>.from(
      session.explanationLog,
    );

    // Average annual drift across all held sectors for market-relative deviation
    final double avgDrift = session.holdings.isEmpty
        ? 0.0
        : session.holdings
                  .map((h) => _getSectorParams(h.symbol, scenario).annualDrift)
                  .reduce((a, b) => a + b) /
              session.holdings.length;

    // ── Sandbox Isolation (Step 3): Shock decay tracking ────────
    MarketShock? newActiveShock = session.activeShock;

    for (int tick = 0; tick < ticks; tick++) {
      for (final h in session.holdings) {
        final basePrice = session.basePrices[h.symbol] ?? h.entryPrice;
        double currentPrice = newPrices[h.symbol] ?? h.entryPrice;
        final priceBefore =
            preBouncePrices[h.symbol] ??
            session.currentPrices[h.symbol] ??
            h.entryPrice;
        final sector = _getSector(h.symbol);
        final assetSector = _getAssetSector(h.symbol);
        final params = _getSectorParams(h.symbol, scenario);

        // ── Geometric Brownian Motion with dt scaling ─────────────
        // P_new = P_old × (1 + μ×dt + σ×ε×√dt + microNoiseFactor×ε₂×√dt)
        // All μ,σ are ANNUAL. dt=0.005 scales them to per-tick.
        final sqrtDt = _sqrtDt;
        final noise =
            (rng.nextDouble() - 0.5) * params.annualVolatility * sqrtDt;

        // ETF micro-noise: reduced by 75% for smooth chart curves
        final microNoiseFactor = assetSector == AssetSector.etfBroadMarket
            ? _microNoiseRange * 0.25
            : _microNoiseRange;
        final microNoise = (rng.nextDouble() - 0.5) * microNoiseFactor * sqrtDt;

        // ── Sandbox Isolation (Step 3): Drift clamping per regime ──
        final regime = _toMacroRegime(scenario);
        final beforeGbm = currentPrice;
        final rawChange = params.annualDrift * _dtPerTick + noise + microNoise;
        final clampedChange = _clampDrift(rawChange, regime);
        currentPrice = currentPrice * (1 + clampedChange);
        // ignore: avoid_print
        print(
          '[TICK] ${h.symbol} basePrice=${basePrice.toStringAsFixed(4)} beforeGbm=${beforeGbm.toStringAsFixed(4)} afterGbm=${currentPrice.toStringAsFixed(4)} regime=${regime.name}',
        );

        // ── Sandbox Isolation (Step 3): Apply active market shock ──
        final shock = session.activeShock;
        if (shock != null) {
          if (shock.isExpired) {
            newActiveShock = null; // clear expired shock
          } else {
            currentPrice *= (1.0 + shock.currentAmplitude);
          }
        }

        // ── Block 5: Apply per-company spec/hype bell-shape event ──
        // Firing is decided once per weekly wall-clock window, before this
        // loop (see the lastSpecEventCheckAt check above). Here we only
        // advance/apply the amplitude of whatever is currently active.
        final specAmplitude = _applySpecEvents(session, h.symbol);
        if (specAmplitude.abs() > 0.0001) {
          currentPrice *= (1.0 + specAmplitude);
        }

        // ── Sandbox Isolation (Step 3): Per-regime price bounds ──
        final beforeClamp = currentPrice;
        final regimeBounds = _getRegimeBounds(regime);
        currentPrice = currentPrice.clamp(
          basePrice * regimeBounds.minPriceMultiplier,
          basePrice * regimeBounds.maxPriceMultiplier,
        );
        if ((currentPrice - beforeClamp).abs() > 0.0001) {
          // ignore: avoid_print
          print(
            '[CLAMP] ${h.symbol} clamped '
            '${((beforeClamp - basePrice) / basePrice * 100).toStringAsFixed(1)}% → '
            '${((currentPrice - basePrice) / basePrice * 100).toStringAsFixed(1)}% '
            '(bounds: ${regimeBounds.minPriceMultiplier.toStringAsFixed(2)}x–'
            '${regimeBounds.maxPriceMultiplier.toStringAsFixed(2)}x)',
          );
        }

        // ── Debug: log dt calibration once per app session ──────
        if (!_dtCalibrationLogged) {
          _dtCalibrationLogged = true;
          final dtDrift = params.annualDrift * _dtPerTick;
          final dtVol = params.annualVolatility * sqrtDt;
          // ignore: avoid_print
          print(
            '[FOMO-DT] dt=$_dtPerTick  sqrt(dt)=${sqrtDt.toStringAsFixed(6)}  '
            'drift×dt=${dtDrift.toStringAsFixed(6)}  '
            'vol×√dt=${dtVol.toStringAsFixed(6)}  '
            '(μ,σ)=(${params.annualDrift.toStringAsFixed(4)},${params.annualVolatility.toStringAsFixed(4)}) '
            'sector=${assetSector.name}  regime=${_toMacroRegime(scenario).name}',
          );
        }

        // Gradual recovery: bounce decays over 3 epochs after a catastrophe.
        // Each subsequent epoch gets a smaller bounce (full → 60% → 30%).
        // Rates calibrated for realistic blackSwan (−20…−40%) / crash (−8…−15%).
        final epochIdx = session.epochHistory.indexWhere(
          (e) => e.index == currentEpoch.index,
        );
        for (int dist = 1; dist <= 3; dist++) {
          if (epochIdx >= dist &&
              session.epochHistory[epochIdx - dist].scenario.isCatastrophe) {
            double recoveryRate;
            switch (sector) {
              case MarketSector.consumerStaples:
              case MarketSector.healthcare:
                recoveryRate = 0.020 + rng.nextDouble() * 0.020; // 2-4%
              case MarketSector.finance:
              case MarketSector.realEstate:
                recoveryRate = 0.015 + rng.nextDouble() * 0.025; // 1.5-4%
              case MarketSector.technology:
                recoveryRate = 0.015 + rng.nextDouble() * 0.025; // 1.5-4%
              case MarketSector.energy:
                recoveryRate = 0.015 + rng.nextDouble() * 0.025; // 1.5-4%
              case MarketSector.biotech:
                recoveryRate = 0.010 + rng.nextDouble() * 0.020; // 1-3%
              case MarketSector.cyclical:
                recoveryRate = 0.015 + rng.nextDouble() * 0.025; // 1.5-4%
              default:
                recoveryRate = 0.015 + rng.nextDouble() * 0.020; // 1.5-3.5%
            }
            // Decay factor: 1.0 (immediate), 0.6 (one epoch later), 0.3 (two epochs later)
            final decay = (4 - dist) / 3.0;
            currentPrice *= (1 + recoveryRate * decay);
            currentPrice = currentPrice.clamp(basePrice * 0.3, basePrice * 3.0);
            break; // only the nearest catastrophe counts
          }
        }

        // ── Stabilization Period ───────────────────────────────────
        // Freeze price at entryPrice for 30 seconds after purchase
        final stabDeadline = session.stabilizationDeadlines[h.symbol];
        if (stabDeadline != null && now.isBefore(stabDeadline)) {
          currentPrice = h.entryPrice;
        }
        newPrices[h.symbol] = currentPrice;

        // ── Explainable Simulation ────────────────────────────────
        final hasCorrection =
            priceBefore > 0 &&
            (priceBefore - currentPrice).abs() / priceBefore > 0.05;
        final expl = _explainPriceChange(
          symbol: h.symbol,
          priceBefore: priceBefore,
          priceAfter: currentPrice,
          epochIndex: currentEpoch.index,
          scenario: scenario,
          sector: sector,
          hasCorrection: hasCorrection,
          marketDriftRaw: params.annualDrift * _dtPerTick,
          sectorDriftRaw: (params.annualDrift - avgDrift) * _dtPerTick,
          noiseRaw: noise,
          companyDriftRaw: specAmplitude,
        );
        final symLog = <TickExplanation>[
          ...(explanations[h.symbol] ?? []),
          expl,
        ];
        explanations[h.symbol] = symLog;

        // Track price range for peak/bottom detection
        if (!newRanges.containsKey(h.symbol)) {
          newRanges[h.symbol] = EpochPriceRange(currentPrice, currentPrice);
        } else {
          final range = newRanges[h.symbol]!;
          if (currentPrice < range.min) range.min = currentPrice;
          if (currentPrice > range.max) range.max = currentPrice;
        }
      }
    }

    // ── Psychology Profile: diversification / concentration ──
    if (session.holdings.length >= 2) {
      // Sector allocation
      final sectorValues = <MarketSector, double>{};
      for (final h in session.holdings) {
        final sector = _getSector(h.symbol);
        final val = h.shares * (newPrices[h.symbol] ?? h.entryPrice);
        sectorValues[sector] = (sectorValues[sector] ?? 0) + val;
      }
      final totalAssets = sectorValues.values.fold(0.0, (a, b) => a + b);
      if (totalAssets > 0) {
        for (final v in sectorValues.values) {
          if (v / totalAssets > 0.50) {
            session.psychologyProfile.recordOverconcentration();
          }
        }
      }

      // Single-asset concentration
      final maxAlloc = _calcAllocation(
        session.holdings,
        newPrices,
        session.cash,
      );
      if (maxAlloc > 0.80) {
        session.psychologyProfile.recordOverconcentration();
      } else if (maxAlloc <= 0.50) {
        session.psychologyProfile.recordGoodDiversification();
      }
    }

    // ── Psychology Profile: catastrophe survival ─────────────
    bool newCatastropheSurvivalRecorded = session.catastropheSurvivalRecorded;
    if (currentEpoch.scenario.isCatastrophe &&
        session.holdings.isNotEmpty &&
        !session.catastropheSurvivalRecorded) {
      newCatastropheSurvivalRecorded = true;
      session.psychologyProfile.recordCatastropheSurvived();
    }

    // ── Task 1.5: Patience — held through catastrophe ────────
    // Guarded with !session.catastropheSurvivalRecorded to fire
    // only ONCE per catastrophe (not every tick).
    if (currentEpoch.scenario.isCatastrophe &&
        session.soldDuringCatastrophe.isEmpty &&
        session.holdings.isNotEmpty &&
        !session.catastropheSurvivalRecorded) {
      session.psychologyProfile.recordHeldThroughCatastrophe();
    }

    // ── Task 1.5: Reset soldDuringCatastrophe on recovery ────
    if (!currentEpoch.scenario.isCatastrophe &&
        session.soldDuringCatastrophe.isNotEmpty) {
      session.soldDuringCatastrophe = <String>{};
      session.diversificationBonusRecorded = false;
    }

    // ── Trade frequency deduction is applied ONLY in executeTrade(),
    // NOT during tick simulation — otherwise the same deduction is
    // subtracted on every tick, multiplying the penalty exponentially.

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
            casinoCatastropheCooldown: session.casinoCatastropheCooldown,
            casinoDeclineStreak: session.casinoDeclineStreak,
            casinoCatastropheCount: session.casinoCatastropheCount,
            casinoLastCatastropheEpoch: session.casinoLastCatastropheEpoch,
            currentPrices: newPrices,
            basePrices: session.basePrices,
            epochPriceRanges: newRanges,
            stabilizationDeadlines: session.stabilizationDeadlines,
            simulationSeed: session.simulationSeed,
            companies: session.companies,
            explanationLog: explanations,
            devMarketPhase: currentEpoch.scenario.name,
            devFearIndex: currentEpoch.scenario.contrarianScore,
            psychologyProfile: session.psychologyProfile,
            currentWeights: session.currentWeights,
            realizedPnl: session.realizedPnl,
            customDurationDays: session.customDurationDays,
            enableDeveloperTrace: session.enableDeveloperTrace,
            devMarketTemperature: session.devMarketTemperature,
            devFatigue: session.devFatigue,
            devCurrentTick: session.devCurrentTick,
            devRecoveryProgress: session.devRecoveryProgress,
            devVolatilityMultiplier: session.devVolatilityMultiplier,
            devNextEvent: session.devNextEvent,
            devNextEventDays: session.devNextEventDays,
            devVolatilityLabel: session.devVolatilityLabel,
            catastropheSurvivalRecorded: newCatastropheSurvivalRecorded,
            diversificationBonusRecorded: session.diversificationBonusRecorded,
            soldDuringCatastrophe: session.soldDuringCatastrophe,
            activeShock: newActiveShock,
            priceHistory: () {
              final hist = Map<String, List<double>>.from(session.priceHistory);
              for (final h in session.holdings) {
                final sym = h.symbol;
                if (newPrices.containsKey(sym)) {
                  hist[sym] = [...(hist[sym] ?? []), newPrices[sym]!];
                }
              }
              for (final sym in newPrices.keys) {
                if (!hist.containsKey(sym)) {
                  hist[sym] = [newPrices[sym]!];
                }
              }
              return hist;
            }(),
            lastTickTimestamp: now,
            // ── Block 5 + 6: Per-company events & casino state ─
            specEvents: session.specEvents,
            specEventCooldowns: session.specEventCooldowns,
            lastSpecEventCheckAt: session.lastSpecEventCheckAt,
            lastEpochRollAt: session.lastEpochRollAt ?? now,
            epochHistory: session.epochHistory,
          )
        else
          state[i],
    ];
    _save();
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
            stabilizationDeadlines: session.stabilizationDeadlines,
            simulationSeed: session.simulationSeed,
            companies: session.companies,
            explanationLog: session.explanationLog,
            currentWeights: session.currentWeights,
            psychologyProfile: session.psychologyProfile,
            activeShock: session.activeShock,
            priceHistory: session.priceHistory,
            soldDuringCatastrophe: session.soldDuringCatastrophe,
            diversificationBonusRecorded: session.diversificationBonusRecorded,
            catastropheSurvivalRecorded: session.catastropheSurvivalRecorded,
            specEvents: session.specEvents,
            specEventCooldowns: session.specEventCooldowns,
            lastSpecEventCheckAt: session.lastSpecEventCheckAt,
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
  }

  /// Manually complete a test (for infinite mode).
  bool terminateTest(String sessionId) {
    final idx = state.indexWhere((s) => s.id == sessionId);
    if (idx < 0) return false;

    final session = state[idx];
    if (session.duration != TestDuration.infinite) return false;
    if (!session.canExitInfinite) return false;

    _completeTest(idx);
    return true;
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

  /// Compute historical portfolio value data points for charting.
  /// Returns a list of (timestamp, totalValue) pairs sorted ascending.
  List<ChartDataPoint> computeChartData(String sessionId) {
    final session = getSession(sessionId);
    if (session == null ||
        session.epochHistory.isEmpty ||
        session.holdings.isEmpty) {
      return [];
    }

    final points = <ChartDataPoint>[];
    double cumulativeMul = 1.0;
    final now = DateTime.now();

    // Add current point
    points.add(ChartDataPoint(now, session.totalValue));

    // Walk epoch history backwards, applying reverse drift
    final reversedEpochs = session.epochHistory.toList()
      ..sort((a, b) => b.index.compareTo(a.index));

    for (final record in reversedEpochs) {
      final startAt = record.startedAt;
      final endAt = record.endedAt ?? now;
      if (now.isAfter(endAt) || now.isBefore(startAt)) {
        cumulativeMul /= (1 + record.scenario.drift);
        final historicalTotal = _valueAtMultiplier(session, cumulativeMul);
        points.add(ChartDataPoint(endAt, historicalTotal));
        points.add(
          ChartDataPoint(
            startAt,
            historicalTotal * (1 - record.scenario.priceVolatility * 0.5),
          ),
        );
      }
    }

    points.sort((a, b) => a.time.compareTo(b.time));
    return points;
  }

  double _valueAtMultiplier(StressTestSession session, double multiplier) {
    double holdingsValue = 0;
    for (final h in session.holdings) {
      final currentPrice = session.currentPrices[h.symbol] ?? h.entryPrice;
      holdingsValue += h.shares * (currentPrice / multiplier);
    }
    return holdingsValue + session.cash;
  }
}

// ---------------------------------------------------------------------------
// Provider
// ---------------------------------------------------------------------------

final stressTestProvider =
    StateNotifierProvider<StressTestNotifier, List<StressTestSession>>((ref) {
      final user = ref.watch(currentUserProvider);
      return StressTestNotifier(userId: user?.id);
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
