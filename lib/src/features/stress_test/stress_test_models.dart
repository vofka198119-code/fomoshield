// ---------------------------------------------------------------------------
// Stress Test — Data Models
// ---------------------------------------------------------------------------
// All domain models for the Stress Test engine: sessions, trades, epochs,
// scenarios, IPO events, and the psychological verdict.
// ---------------------------------------------------------------------------

import 'dart:math';

/// Supported test durations.
/// [custom] requires [StressTestSession.customDurationDays] at runtime.
enum TestDuration {
  week1('1W', Duration(hours: 12)),
  month1('1M', Duration(hours: 24)),
  months3('3M', Duration(hours: 24)),
  infinite('∞', Duration(hours: 24)),
  custom('Custom', Duration(hours: 24));

  final String label;
  final Duration epochDuration;
  const TestDuration(this.label, this.epochDuration);

  /// Total real-time duration before auto-completion.
  /// Returns [Duration] for preset options, `null` for [infinite] and [custom]
  /// ([custom] uses [StressTestSession.customDurationDays] at runtime).
  Duration? get totalDuration {
    return switch (this) {
      TestDuration.week1 => const Duration(days: 7),
      TestDuration.month1 => const Duration(days: 30),
      TestDuration.months3 => const Duration(days: 90),
      TestDuration.infinite => null,
      TestDuration.custom => null,
    };
  }

  /// Display name for the UI.
  String get displayName {
    return switch (this) {
      TestDuration.week1 => '1 Week',
      TestDuration.month1 => '1 Month',
      TestDuration.months3 => '3 Months',
      TestDuration.infinite => 'Infinite',
      TestDuration.custom => 'Custom',
    };
  }

  /// For Infinite/Custom, there is no fixed end — user triggers completion.
  bool get isTimeLimited => totalDuration != null;

  /// How often the casino rolls a new macro scenario on wall-clock.
  Duration get rollInterval {
    return switch (this) {
      TestDuration.week1 => const Duration(hours: 12),
      TestDuration.month1 => const Duration(hours: 24),
      TestDuration.months3 => const Duration(hours: 24),
      TestDuration.infinite => const Duration(days: 7),
      TestDuration.custom => const Duration(days: 5),
    };
  }
}

/// Minimum real-world elapsed time before an Infinite ("until bored") test
/// can be manually ended — a countdown to this mark is shown in the UI
/// (see stress_test_screen.dart's `_getTestDuration`/`_buildTimerBar`)
/// before it's replaced by the "test complete" state. Shared constant so
/// the UI countdown and [StressTestSession.canExitInfinite] can never drift.
const Duration infiniteMinDuration = Duration(days: 14);

// ═══════════════════════════════════════════════════════════════════════════
// Timeline — Deterministic Epoch Calculation
// ═══════════════════════════════════════════════════════════════════════════

/// Simplified test type for deterministic timeline math.
/// Mapped from [TestDuration] via [TestDurationToConfig] extension.
enum TestType {
  /// 1-Week test: 12h per epoch, 14 epochs total.
  oneWeek,

  /// 1-Month test: 24h per epoch, 30 epochs total.
  oneMonth,

  /// All other durations: computed from [TestConfig.epochsCount].
  custom,
}

/// Configuration for deterministic epoch timeline calculation.
class TestConfig {
  final TestType type;

  /// Total real-time duration (null for infinite/custom without explicit days).
  final Duration? totalDuration;

  /// Expected number of epochs for this test.
  final int epochsCount;

  const TestConfig({
    required this.type,
    this.totalDuration,
    required this.epochsCount,
  });
}

/// Converts [TestDuration] to [TestConfig] for deterministic timeline math.
extension TestDurationToConfig on TestDuration {
  TestConfig get config {
    return switch (this) {
      TestDuration.week1 => const TestConfig(
        type: TestType.oneWeek,
        totalDuration: Duration(days: 7),
        epochsCount: 14,
      ),
      TestDuration.month1 => const TestConfig(
        type: TestType.oneMonth,
        totalDuration: Duration(days: 30),
        epochsCount: 30,
      ),
      TestDuration.months3 => const TestConfig(
        type: TestType.custom,
        totalDuration: Duration(days: 90),
        epochsCount: 90,
      ),
      TestDuration.infinite => const TestConfig(
        type: TestType.custom,
        totalDuration: null,
        epochsCount: 999,
      ),
      TestDuration.custom => const TestConfig(
        type: TestType.custom,
        totalDuration: null,
        epochsCount: 999,
      ),
    };
  }
}

/// Returns the duration of a single epoch for the given test type.
Duration calculateSingleEpochDuration(TestType type) {
  return switch (type) {
    TestType.oneWeek => const Duration(hours: 12),
    TestType.oneMonth => const Duration(hours: 24),
    TestType.custom => const Duration(hours: 24),
  };
}

/// A deterministic snapshot of the current timeline position.
///
/// Computed by [calculateCurrentTimeline] using wall-clock elapsed time
/// and [TestConfig], eliminating the hardcoded 24h assumption in
/// [EpochRecord.progress].
class TimelineSnapshot {
  /// Index of the currently active epoch (0-based).
  final int activeEpochIndex;

  /// Progress through the current epoch as a percentage (0–100).
  final int epochProgressPercent;

  /// Whether the test's wall-clock duration has elapsed.
  final bool isTestCompleted;

  const TimelineSnapshot({
    required this.activeEpochIndex,
    required this.epochProgressPercent,
    required this.isTestCompleted,
  });

  /// Progress through the current epoch as a fraction (0.0–1.0).
  double get progressFraction => (epochProgressPercent / 100.0).clamp(0.0, 1.0);
}

/// Calculates the current timeline position from [session.epochHistory].
///
/// Before Block 6 (Casino Wall-Clock), epochs were predefined and evenly spaced.
/// After Block 6, epochs are created dynamically — so we read the active epoch
/// from [session.epochHistory] (single source of truth) instead of dividing
/// wall-clock time by a fixed duration.
///
/// Progress through the current epoch is computed from [session.lastEpochRollAt]
/// and [TestDuration.rollInterval].
///
/// Returns `null` if the session hasn't started or isn't running.
TimelineSnapshot? calculateCurrentTimeline(
  StressTestSession session,
  TestConfig config,
) {
  if (session.startedAt == null || session.status != StressTestStatus.active) {
    return null;
  }

  final now = DateTime.now();
  final elapsed = now.difference(session.startedAt!);

  // Test completed check (only for time-limited modes)
  if (config.totalDuration != null && elapsed >= config.totalDuration!) {
    final lastIdx = session.epochHistory.isNotEmpty
        ? session.epochHistory.last.index
        : 0;
    return TimelineSnapshot(
      activeEpochIndex: lastIdx,
      epochProgressPercent: 100,
      isTestCompleted: true,
    );
  }

  // ── Casino wall-clock model: epochs are dynamic ──
  // epochHistory is the single source of truth — find active epoch or last.
  if (session.epochHistory.isEmpty) {
    return const TimelineSnapshot(
      activeEpochIndex: 0,
      epochProgressPercent: 0,
      isTestCompleted: false,
    );
  }

  // Find the active epoch (isActive), fall back to last if all closed
  int activePos = session.epochHistory.length - 1;
  for (int i = 0; i < session.epochHistory.length; i++) {
    if (session.epochHistory[i].isActive) {
      activePos = i;
      break;
    }
  }
  final activeEpoch = session.epochHistory[activePos];

  // Progress: fraction of rollInterval elapsed since this epoch started.
  // Uses the same rollInterval that _getRollInterval() provides in the engine.
  final rollInterval = session.duration.rollInterval;
  final epochElapsed = now.difference(activeEpoch.startedAt);
  final fraction = (epochElapsed.inMilliseconds / rollInterval.inMilliseconds)
      .clamp(0.0, 1.0);

  return TimelineSnapshot(
    activeEpochIndex: activeEpoch.index,
    epochProgressPercent: (fraction * 100).round(),
    isTestCompleted: false,
  );
}

/// Market scenario types for each epoch.
///
/// Roulette pool (macro scenarios): bull, sideways, bear, volatility,
/// recovery, blackSwan, crash.  Total weight = 100.
///
/// Per-company only (excluded from roulette): hype, speculation.
enum MarketScenario {
  bull(35),
  sideways(18),
  bear(18),
  volatility(15),
  recovery(7),
  hype(8),
  speculation(8),
  blackSwan(3.5),
  crash(3.5);

  final double weight;
  const MarketScenario(this.weight);

  bool get isCatastrophe =>
      this == MarketScenario.blackSwan || this == MarketScenario.crash;
  bool get isDecline => this == MarketScenario.bear;

  /// Block 5: hype/speculation are per-COMPANY events now (see
  /// speculation_event.dart's CompanySpecEventType), not global epoch
  /// scenarios — they're never rolled by casino_epochs.dart's roulette.
  /// These two enum values only remain because [description]/[drift]/etc.
  /// need exhaustive switches; anything that deals with epoch weights
  /// (fatigue init, redistribution, recovery) must exclude them via this
  /// getter or they silently absorb/leak roulette weight they can never
  /// spend (confirmed during the Volatility-lock investigation).
  bool get isPerCompanyEvent =>
      this == MarketScenario.hype || this == MarketScenario.speculation;

  /// Recovery is scripted, not weighted-random: real markets recover
  /// after a crash, not randomly and never right after a Bull run. It
  /// happens deterministically for exactly the 2 epochs immediately
  /// following a blackSwan/crash (see casino_epochs.dart's
  /// _rollScenario) and is never reachable any other way — not via the
  /// normal roulette, not via the anti-stuck-bear redirect. Like
  /// [isPerCompanyEvent], must be excluded from all epoch fatigue-weight
  /// bookkeeping (it's never actually rolled, so it must never hold or
  /// absorb roulette weight).
  bool get isScriptedRecovery => this == MarketScenario.recovery;

  /// Human-readable description (hidden from user).
  String get description {
    return switch (this) {
      MarketScenario.bull => 'Bull market — broad sector growth',
      MarketScenario.sideways => 'Sideways — calm, range-bound market',
      MarketScenario.bear => 'Bear market — gradual decline, staples resilient',
      MarketScenario.volatility => 'Volatility — sharp swings, no clear trend',
      MarketScenario.recovery => 'Recovery — broad rebound after a crash',
      MarketScenario.hype => 'Hype — target sector spike (tech/AI surges)',
      MarketScenario.speculation =>
        'Speculation — multi-directional high volatility',
      MarketScenario.blackSwan => 'Black swan — everything crashes hard',
      MarketScenario.crash => 'Crash — heavy sector-wide drop',
    };
  }

  /// Average price drift per epoch (used by chart reverse calc).
  /// Task 1.8: calibrated to S&P 500 realistic bounds.
  double get drift {
    return switch (this) {
      MarketScenario.bull => 0.006, // +0.6% avg (range +0.2…+1.5%)
      MarketScenario.sideways => 0.001, // ~0% avg, narrow channel ±1-2%
      MarketScenario.bear => -0.011, // −1.1% avg (range −0.5…−2.0%)
      MarketScenario.volatility => 0.0, // 0% avg, high-amplitude noise
      MarketScenario.recovery => 0.022, // +2.2% avg (range +1.5…+3.5%)
      MarketScenario.hype => 0.023, // +2.3% avg (tech +8.5%, others flat)
      MarketScenario.speculation => 0.0, // 0% avg (range −5…+5%)
      MarketScenario.blackSwan => -0.29, // −29% avg (range −20…−40%)
      MarketScenario.crash => -0.11, // −11% avg (range −8…−15%)
    };
  }

  /// Average price volatility per epoch (used by chart reverse calc).
  /// Named `priceVolatility` to avoid conflict with the enum value `volatility`.
  double get priceVolatility {
    return switch (this) {
      MarketScenario.bull => 0.008,
      MarketScenario.sideways => 0.010,
      MarketScenario.bear => 0.009,
      MarketScenario.volatility => 0.060,
      MarketScenario.recovery => 0.012,
      MarketScenario.hype => 0.020,
      MarketScenario.speculation => 0.074,
      MarketScenario.blackSwan => 0.083,
      MarketScenario.crash => 0.035,
    };
  }

  /// Contrarian Fear/Greed score (0-100) for the Monster badge.
  /// Low = fear/pessimism = buy signal (green badge).
  /// High = greed/euphoria = danger signal (red badge).
  ///
  /// Mapping per Task 1.4:
  ///   blackSwan/crash:   0-20  (Extreme Panic → Bright Green)
  ///   bear:             21-40  (Fear → Light Green)
  ///   sideways:            40  (Calm → Neutral)
  ///   volatility:          45  (Uneasy → Neutral)
  ///   recovery/spec:    41-60  (Uncertainty → Orange/Yellow)
  ///   bull:             61-80  (Growth → Light Red)
  ///   hype:             81-100 (Euphoria → Crimson Red)
  int get contrarianScore => switch (this) {
    MarketScenario.blackSwan || MarketScenario.crash => 10,
    MarketScenario.bear => 30,
    MarketScenario.sideways => 40,
    MarketScenario.volatility => 45,
    MarketScenario.recovery => 50,
    MarketScenario.speculation => 55,
    MarketScenario.bull => 70,
    MarketScenario.hype => 90,
  };
}

// ---------------------------------------------------------------------------
// IPO Pattern & Phase — Autonomous Company Lifecycle
// ---------------------------------------------------------------------------

/// IPO pattern type for a company's public debut.
enum IpoPattern { none, tesla, reverse }

/// The 6 phases of an autonomous IPO lifecycle.
/// Each company manages its own phase transitions internally.
enum CompanyIpoPhase { none, shakeout, fomo, coolOff, sharpPullback, recovery }

/// Autonomous company stock with self-managed IPO lifecycle.
///
/// Each [CompanyStock] instance manages its own age, IPO phase transitions,
/// and daily drift bonus independently — no central IPO controller needed.
class CompanyStock {
  final String symbol;
  final String companyName;
  final MarketSector sector;
  int ageWeeks;
  final IpoPattern ipoPattern;
  CompanyIpoPhase ipoPhase;
  int _phaseWeeks; // weeks spent in current phase

  CompanyStock({
    required this.symbol,
    required this.companyName,
    required this.sector,
    this.ageWeeks = 0,
    this.ipoPattern = IpoPattern.none,
    this.ipoPhase = CompanyIpoPhase.none,
    int phaseWeeks = 0,
  }) : _phaseWeeks = phaseWeeks;

  /// Advance age by 1 week and transition IPO phase if needed.
  void advanceAge() {
    ageWeeks++;
    if (ipoPattern == IpoPattern.none) return;
    _phaseWeeks++;

    switch (ipoPattern) {
      case IpoPattern.tesla:
        _advanceTesla();
      case IpoPattern.reverse:
        _advanceReverse();
      case IpoPattern.none:
        break;
    }
  }

  void _advanceTesla() {
    // Tesla: shakeout(2w) → fomo(2w) → coolOff(2w) → recovery(∞)
    switch (ipoPhase) {
      case CompanyIpoPhase.shakeout:
        if (_phaseWeeks >= 2) {
          ipoPhase = CompanyIpoPhase.fomo;
          _phaseWeeks = 0;
        }
      case CompanyIpoPhase.fomo:
        if (_phaseWeeks >= 2) {
          ipoPhase = CompanyIpoPhase.coolOff;
          _phaseWeeks = 0;
        }
      case CompanyIpoPhase.coolOff:
        if (_phaseWeeks >= 2) {
          ipoPhase = CompanyIpoPhase.recovery;
          _phaseWeeks = 0;
        }
      default:
        break;
    }
  }

  void _advanceReverse() {
    // Reverse: shakeout(2w) → sharpPullback(2w) → recovery(∞)
    switch (ipoPhase) {
      case CompanyIpoPhase.shakeout:
        if (_phaseWeeks >= 2) {
          ipoPhase = CompanyIpoPhase.sharpPullback;
          _phaseWeeks = 0;
        }
      case CompanyIpoPhase.sharpPullback:
        if (_phaseWeeks >= 2) {
          ipoPhase = CompanyIpoPhase.recovery;
          _phaseWeeks = 0;
        }
      default:
        break;
    }
  }

  /// Micro-drift contributed by IPO phase activity for the current tick.
  ///
  /// Returns 0.0 when [ipoPattern] is [IpoPattern.none] or [ipoPhase] is
  /// [CompanyIpoPhase.none]. Otherwise uses [rng] to generate a random value
  /// within the configured range for the current phase + pattern combination.
  double computeIpoBonusDrift(Random rng) {
    if (ipoPattern == IpoPattern.none || ipoPhase == CompanyIpoPhase.none) {
      return 0.0;
    }
    return switch (ipoPattern) {
      IpoPattern.tesla => switch (ipoPhase) {
        CompanyIpoPhase.shakeout =>
          -(0.08 + rng.nextDouble() * 0.07), // -0.08..-0.15
        CompanyIpoPhase.fomo => 0.25 + rng.nextDouble() * 0.25, // +0.25..+0.50
        CompanyIpoPhase.coolOff =>
          -(0.05 + rng.nextDouble() * 0.05), // -0.05..-0.10
        CompanyIpoPhase.recovery =>
          0.02 + rng.nextDouble() * 0.03, // +0.02..+0.05
        _ => 0.0,
      },
      IpoPattern.reverse => switch (ipoPhase) {
        CompanyIpoPhase.shakeout =>
          0.15 + rng.nextDouble() * 0.15, // +0.15..+0.30
        CompanyIpoPhase.sharpPullback =>
          -(0.10 + rng.nextDouble() * 0.10), // -0.10..-0.20
        CompanyIpoPhase.recovery =>
          0.03 + rng.nextDouble() * 0.05, // +0.03..+0.08
        _ => 0.0,
      },
      IpoPattern.none => 0.0,
    };
  }

  /// @Deprecated Use [computeIpoBonusDrift] instead.
  double get ipoBonusDrift => computeIpoBonusDrift(_fallbackRng);

  static final Random _fallbackRng = Random();

  Map<String, dynamic> toJson() => {
    'symbol': symbol,
    'companyName': companyName,
    'sector': sector.name,
    'ageWeeks': ageWeeks,
    'ipoPattern': ipoPattern.name,
    'ipoPhase': ipoPhase.name,
    '_phaseWeeks': _phaseWeeks,
  };

  factory CompanyStock.fromJson(Map<String, dynamic> json) => CompanyStock(
    symbol: json['symbol'] as String,
    companyName: json['companyName'] as String? ?? '',
    sector: MarketSector.values.firstWhere(
      (s) => s.name == (json['sector'] as String? ?? 'other'),
    ),
    ageWeeks: json['ageWeeks'] as int? ?? 0,
    ipoPattern: IpoPattern.values.firstWhere(
      (p) => p.name == (json['ipoPattern'] as String? ?? 'none'),
    ),
    ipoPhase: CompanyIpoPhase.values.firstWhere(
      (p) => p.name == (json['ipoPhase'] as String? ?? 'none'),
    ),
    phaseWeeks: json['_phaseWeeks'] as int? ?? 0,
  );
}

/// @Deprecated Use [CompanyStock.computeIpoBonusDrift] instead.

// ---------------------------------------------------------------------------
// Trader Psychology Profile — 4 Sub-Indices
// ---------------------------------------------------------------------------

/// Tracks the psychological state of a trader across 4 independent sub-indices.
///
/// Each index ranges 0.0 (weak) → 1.0 (strong), initialized at 0.5 (neutral).
/// All mutations are clamped to [0.0, 1.0].
class TraderPsychologyProfile {
  /// Resistance to panic selling under pressure.
  double panicResistance;

  /// Discipline to follow a plan (not over-trade, not chase).
  double discipline;

  /// Patience to hold through volatility and avoid impulsive moves.
  double patience;

  /// Adherence to a strategy (diversification, risk management).
  double strategyAdherence;

  TraderPsychologyProfile({
    this.panicResistance = 0.0,
    this.discipline = 0.0,
    this.patience = 0.0,
    this.strategyAdherence = 0.0,
  });

  // ── Accumulator methods (called by engine on trade events) ──────

  /// Called when user buys near a peak (FOMO behavior).
  void recordBuyPeak() {
    discipline = (discipline - 0.08).clamp(0.0, 1.0);
    patience = (patience - 0.05).clamp(0.0, 1.0);
  }

  /// Called when user sells near a bottom (panic behavior).
  void recordSellBottom() {
    panicResistance = (panicResistance - 0.12).clamp(0.0, 1.0);
    discipline = (discipline - 0.06).clamp(0.0, 1.0);
  }

  /// Called after every trade — frequent trading erodes discipline/patience.
  void recordTradeExecuted() {
    discipline = (discipline - 0.01).clamp(0.0, 1.0);
    patience = (patience - 0.005).clamp(0.0, 1.0);
  }

  /// Called when user survives a Black Swan / catastrophe without panic selling.
  void recordCatastropheSurvived() {
    panicResistance = (panicResistance + 0.15).clamp(0.0, 1.0);
    patience = (patience + 0.10).clamp(0.0, 1.0);
  }

  /// Called when the user's max allocation is healthy (≤50%).
  void recordGoodDiversification() {
    strategyAdherence = (strategyAdherence + 0.03).clamp(0.0, 1.0);
  }

  /// Called when the user's max allocation is excessive (>80%).
  void recordOverconcentration() {
    strategyAdherence = (strategyAdherence - 0.08).clamp(0.0, 1.0);
  }

  /// Called on a profitable trade (realized P&L > 0).
  void recordProfitTaking() {
    patience = (patience + 0.02).clamp(0.0, 1.0);
    strategyAdherence = (strategyAdherence + 0.01).clamp(0.0, 1.0);
  }

  /// Called on a losing trade (realized P&L < 0).
  void recordLossCut() {
    discipline = (discipline - 0.03).clamp(0.0, 1.0);
    patience = (patience - 0.02).clamp(0.0, 1.0);
  }

  // ── Task 1.5: Cumulative Scoring Methods ───────────────────────

  /// Strategy: diversification bonus on first portfolio setup.
  /// ≥3 sectors = +100 pts (max out), 1-2 sectors = +40 pts.
  void recordStrategyDiversification(int sectorCount) {
    if (sectorCount >= 3) {
      strategyAdherence = (strategyAdherence + 1.0).clamp(0.0, 1.0);
    } else if (sectorCount >= 1) {
      strategyAdherence = (strategyAdherence + 0.4).clamp(0.0, 1.0);
    }
  }

  /// Strategy: cash buffer — user didn't go all-in.
  void recordCashBuffer() {
    strategyAdherence = (strategyAdherence + 0.1).clamp(0.0, 1.0);
  }

  /// Strategy: trade frequency deduction.
  /// If trades/epoch > 0.5, deduct proportional amount (capped at -0.3).
  void recordTradeFrequencyDeduction(int totalTrades, int epochs) {
    if (epochs > 0) {
      final ratio = totalTrades / epochs;
      if (ratio > 0.5) {
        final deduction = ((ratio - 0.5) * 0.2).clamp(0.0, 0.3);
        strategyAdherence = (strategyAdherence - deduction).clamp(0.0, 1.0);
      }
    }
  }

  /// Discipline: buying during fear/green zone (blackSwan, crash, bear).
  void recordBuyLow() {
    discipline = (discipline + 0.15).clamp(0.0, 1.0);
  }

  /// Discipline: buying during euphoria/red zone (hype, bull). FOMO penalty.
  void recordBuyHighFomo() {
    discipline = (discipline - 0.2).clamp(0.0, 1.0);
  }

  /// Patience: held through catastrophe epoch without panic selling.
  void recordHeldThroughCatastrophe() {
    patience = (patience + 0.2).clamp(0.0, 1.0);
  }

  /// Patience + Panic: panic selling at a loss during fear/green zone.
  void recordPanicSell() {
    patience = (patience - 0.25).clamp(0.0, 1.0);
    panicResistance = (panicResistance - 0.25).clamp(0.0, 1.0);
  }

  /// Create a copy with the same values.
  TraderPsychologyProfile copy() {
    return TraderPsychologyProfile(
      panicResistance: panicResistance,
      discipline: discipline,
      patience: patience,
      strategyAdherence: strategyAdherence,
    );
  }

  /// Calculate weighted composite score (0.0–1.0).
  double get compositeScore {
    // Веса: panicResistance 0.25, discipline 0.30, patience 0.25, strategyAdherence 0.20
    return panicResistance * 0.25 +
        discipline * 0.30 +
        patience * 0.25 +
        strategyAdherence * 0.20;
  }

  Map<String, dynamic> toJson() => {
    'panicResistance': panicResistance,
    'discipline': discipline,
    'patience': patience,
    'strategyAdherence': strategyAdherence,
  };

  factory TraderPsychologyProfile.fromJson(Map<String, dynamic> json) =>
      TraderPsychologyProfile(
        panicResistance: (json['panicResistance'] as num?)?.toDouble() ?? 0.0,
        discipline: (json['discipline'] as num?)?.toDouble() ?? 0.0,
        patience: (json['patience'] as num?)?.toDouble() ?? 0.0,
        strategyAdherence:
            (json['strategyAdherence'] as num?)?.toDouble() ?? 0.0,
      );
}

/// ── Block 5: Per-Company Speculation / Hype Event ─────────────────────
///
/// Instead of global market-wide hype/speculation scenarios, each company
/// can get a hidden bell-shape event with 5% weekly chance per tick.
///
/// Bell-shape: price ramps up in the first half, then reverses.
/// Peak amplitude: hype +8%, speculation ±15% (volatile).
/// Cooldown: 3–4 weeks after event ends.
class CompanySpecEvent {
  final String symbol;
  final CompanySpecEventType type;
  final DateTime startedAt;
  final DateTime endsAt;
  final int rampDurationTicks;
  int currentTick;

  /// Peak price impact (% as decimal, e.g. 0.08 = +8%).
  final double peakAmplitude;

  CompanySpecEvent({
    required this.symbol,
    required this.type,
    required this.startedAt,
    required this.endsAt,
    required this.rampDurationTicks,
    this.currentTick = 0,
    this.peakAmplitude = 0.08,
  });

  /// Bell-shape amplitude at current tick.
  /// f(t) = sin(π × t / duration) × peakAmplitude
  /// Positive = hype (ramp up), negative after reversal point for speculation.
  double get amplitude {
    if (rampDurationTicks <= 0) return 0.0;
    final progress = (currentTick / rampDurationTicks).clamp(0.0, 1.0);
    return _bellShape(progress) * peakAmplitude;
  }

  /// Asymmetric surge+correction shape — no mechanical symmetry.
  /// Hype: gradual ramp (0→35%), then slow correction retains ~33% of peak.
  /// Speculation: fast ramp (0→25%), plateau (25→45%), sharp reversal past zero.
  double _bellShape(double t) {
    if (type == CompanySpecEventType.speculation) {
      // Phase 1 (0→25%): fast ramp up → market overreacts
      if (t < 0.25) {
        return sin(t / 0.25 * pi / 2); // 0 → 1.0
      }
      // Phase 2 (25→45%): plateau — price stays elevated
      if (t < 0.45) {
        return 1.0;
      }
      // Phase 3 (45→100%): sharp correction past zero → overcorrects
      // 1.0 → -0.25 (net negative, panic overreaction)
      return 1.0 - (t - 0.45) / 0.55 * 1.25;
    }
    // Hype: moderate news, partial correction
    // Phase 1 (0→35%): gradual ramp
    if (t < 0.35) {
      return sin(t / 0.35 * pi / 2); // 0 → 1.0
    }
    // Phase 2 (35→100%): slow correction, retains ~33% of peak
    return 1.0 - (t - 0.35) / 0.65 * 0.67; // 1.0 → 0.33
  }

  /// Whether the event has finished its ramp.
  bool get isExpired => currentTick >= rampDurationTicks;

  /// Time remaining until expiry.
  Duration get remaining => endsAt.difference(DateTime.now()).isNegative
      ? Duration.zero
      : endsAt.difference(DateTime.now());

  CompanySpecEvent copy() => CompanySpecEvent(
    symbol: symbol,
    type: type,
    startedAt: startedAt,
    endsAt: endsAt,
    rampDurationTicks: rampDurationTicks,
    currentTick: currentTick,
    peakAmplitude: peakAmplitude,
  );

  Map<String, dynamic> toJson() => {
    'symbol': symbol,
    'type': type.name,
    'startedAt': startedAt.toIso8601String(),
    'endsAt': endsAt.toIso8601String(),
    'rampDurationTicks': rampDurationTicks,
    'currentTick': currentTick,
    'peakAmplitude': peakAmplitude,
  };

  factory CompanySpecEvent.fromJson(Map<String, dynamic> json) =>
      CompanySpecEvent(
        symbol: json['symbol'] as String,
        type: CompanySpecEventType.values.firstWhere(
          (e) => e.name == json['type'],
          orElse: () => CompanySpecEventType.hype,
        ),
        startedAt: DateTime.parse(json['startedAt'] as String),
        endsAt: DateTime.parse(json['endsAt'] as String),
        rampDurationTicks: json['rampDurationTicks'] as int? ?? 40,
        currentTick: json['currentTick'] as int? ?? 0,
        peakAmplitude: (json['peakAmplitude'] as num?)?.toDouble() ?? 0.08,
      );
}

enum CompanySpecEventType { hype, speculation }

/// ── Block 6: Casino Wall-Clock Epoch Record ──────────────────────────
///
/// Unlike the pre-generated [MarketEpoch] list, [EpochRecord] captures
/// when each epoch ACTUALLY began and ended on wall-clock time.
/// Populated incrementally as the user watches the test unfold.
class EpochRecord {
  final int index;
  final MarketScenario scenario;
  final DateTime startedAt;
  final DateTime? endedAt;

  const EpochRecord({
    required this.index,
    required this.scenario,
    required this.startedAt,
    this.endedAt,
  });

  bool get isActive => endedAt == null;

  /// How long this epoch actually lasted (or has been active so far).
  Duration get duration => endedAt != null
      ? endedAt!.difference(startedAt)
      : DateTime.now().difference(startedAt);

  /// Progress from 0.0 to 1.0.
  /// Closed epochs: always 1.0 (100%).
  /// Active epochs: estimated from wall-clock elapsed time ÷ ~24h default.
  double get progress => endedAt != null
      ? 1.0
      : (DateTime.now().difference(startedAt).inMilliseconds /
                const Duration(hours: 24).inMilliseconds)
            .clamp(0.0, 1.0);

  Map<String, dynamic> toJson() => {
    'index': index,
    'scenario': scenario.name,
    'startedAt': startedAt.toIso8601String(),
    'endedAt': endedAt?.toIso8601String(),
  };

  factory EpochRecord.fromJson(Map<String, dynamic> json) => EpochRecord(
    index: json['index'] as int,
    scenario: MarketScenario.values.firstWhere(
      (s) => s.name == (json['scenario'] as String),
      orElse: () => MarketScenario.bull,
    ),
    startedAt: DateTime.parse(json['startedAt'] as String),
    endedAt: json['endedAt'] != null
        ? DateTime.parse(json['endedAt'] as String)
        : null,
  );
}

///
/// Every asset in the application is classified into exactly one of these
/// five categories. Drift (μ) and Volatility (σ) are determined strictly
/// by the [AssetSector] × [MarketScenario] matrix in the engine.
enum AssetSector {
  /// High-beta, hyper-growth (AMD, NVDA, biotech).
  techSpeculative,

  /// Low-beta, defensive blue-chips (KO, PEP, PG, JNJ).
  consumerStaples,

  /// Economically sensitive (auto, luxury, finance, energy, industrials).
  cyclicalConsumer,

  /// Slow moving, high dividend income focus (REITs).
  realEstateREIT,

  /// Balanced diversified funds (SPY, QQQ, index ETFs).
  etfBroadMarket,
}

/// Maps a legacy [MarketSector] to the new [AssetSector] classification.
AssetSector marketSectorToAssetSector(MarketSector ms) => switch (ms) {
  MarketSector.technology ||
  MarketSector.biotech => AssetSector.techSpeculative,
  MarketSector.consumerStaples ||
  MarketSector.healthcare => AssetSector.consumerStaples,
  MarketSector.finance ||
  MarketSector.energy ||
  MarketSector.cyclical => AssetSector.cyclicalConsumer,
  MarketSector.realEstate => AssetSector.realEstateREIT,
  MarketSector.other => AssetSector.etfBroadMarket,
};

/// Market sectors for sector-aware price simulation.
/// Each holding's symbol is mapped to one of these sectors.
enum MarketSector {
  technology,
  finance,
  healthcare,
  consumerStaples,
  energy,
  realEstate,
  biotech,
  cyclical,
  other,
}

// ---------------------------------------------------------------------------
// Explainable Simulation — Price Contribution Breakdown
// ---------------------------------------------------------------------------

/// Разложение изменения цены на факторы для explainable simulation.
///
/// Каждое поле — процент вклада фактора в общее абсолютное изменение цены.
/// Сумма всех полей всегда равна 100% (± rounding tolerance).
class PriceContribution {
  /// Вклад макро-рынка — средний drift по всем секторам для текущей фазы.
  final double marketPct;

  /// Вклад сектора — отклонение drift сектора от среднерыночного.
  final double sectorPct;

  /// Вклад компании — IPO bonus drift, специфичные события.
  final double companyPct;

  /// Вклад новостей/событий — коррекции, катастрофы, восстановления.
  final double newsPct;

  /// Вклад случайного шума.
  final double noisePct;

  const PriceContribution({
    required this.marketPct,
    required this.sectorPct,
    required this.companyPct,
    required this.newsPct,
    required this.noisePct,
  });

  /// Сумма всех факторов = 100% (с rounding tolerance).
  double get total => marketPct + sectorPct + companyPct + newsPct + noisePct;

  Map<String, dynamic> toJson() => {
    'marketPct': marketPct,
    'sectorPct': sectorPct,
    'companyPct': companyPct,
    'newsPct': newsPct,
    'noisePct': noisePct,
  };

  factory PriceContribution.fromJson(Map<String, dynamic> json) =>
      PriceContribution(
        marketPct: (json['marketPct'] as num?)?.toDouble() ?? 0,
        sectorPct: (json['sectorPct'] as num?)?.toDouble() ?? 0,
        companyPct: (json['companyPct'] as num?)?.toDouble() ?? 0,
        newsPct: (json['newsPct'] as num?)?.toDouble() ?? 0,
        noisePct: (json['noisePct'] as num?)?.toDouble() ?? 0,
      );
}

/// Объяснение изменения цены для одного тикера за один тик симуляции.
class TickExplanation {
  /// Индекс эпохи, в которой произошёл тик.
  final int epochIndex;

  /// Тикер.
  final String symbol;

  /// Цена до тика.
  final double priceBefore;

  /// Цена после тика.
  final double priceAfter;

  /// Общее изменение в процентах.
  double get changePercent =>
      priceBefore > 0 ? ((priceAfter - priceBefore) / priceBefore) * 100 : 0;

  /// Разложение на факторы (нормализованные проценты).
  final PriceContribution contributions;

  /// Фаза рынка в момент тика.
  final String marketPhase;

  /// Сценарий эпохи.
  final String scenario;

  // ── Developer Trace Layer (raw values, null when trace is disabled) ─────
  // Architectural note: эти поля встроены временно. При росте диагностических
  // данных TickTrace должен быть выделен в самостоятельную сущность без
  // изменения публичного API Explainable Simulation.

  /// Сквозной идентификатор тика в формате sessionId_tickIndex.
  final String? tickId;

  /// Сырой market drift (средний по всем секторам) до нормализации.
  final double? marketDriftRaw;

  /// Сырой sector drift (отклонение от среднерыночного) до нормализации.
  final double? sectorDriftRaw;

  /// Сырой IPO bonus drift компании до нормализации.
  final double? ipoBonusDriftRaw;

  /// Сырой recovery drift (пост-катастрофное восстановление) до нормализации.
  final double? recoveryDriftRaw;

  /// Сырой noise (стохастический шум) до нормализации.
  final double? noiseRaw;

  const TickExplanation({
    required this.epochIndex,
    required this.symbol,
    required this.priceBefore,
    required this.priceAfter,
    required this.contributions,
    required this.marketPhase,
    required this.scenario,
    this.tickId,
    this.marketDriftRaw,
    this.sectorDriftRaw,
    this.ipoBonusDriftRaw,
    this.recoveryDriftRaw,
    this.noiseRaw,
  });
}

/// Tracks price range within an epoch for peak/bottom detection.
class EpochPriceRange {
  double min;
  double max;

  EpochPriceRange(this.min, this.max);

  void update(double price) {
    if (price < min) min = price;
    if (price > max) max = price;
  }

  double get range => max - min;
}

/// Temporary market shock with exponential decay (Step 3: Sandbox Isolation).
///
/// Applied as a per-tick multiplier: price *= (1 + amplitude × decay).
/// The decay follows a half-life model: after [halfLife] duration,
/// the amplitude is halved. After ~5 half-lives, the shock is negligible.
class MarketShock {
  /// Human-readable identifier (e.g., "fomc_hike", "earnings_surprise").
  final String id;

  /// Maximum price multiplier at the moment of impact.
  /// Positive = boost, negative = drag (e.g., -0.15 = -15%).
  final double amplitude;

  /// Time when the shock was triggered.
  final DateTime appliedAt;

  /// Time needed for the amplitude to halve.
  final Duration halfLife;

  const MarketShock({
    required this.id,
    required this.amplitude,
    required this.appliedAt,
    this.halfLife = const Duration(minutes: 10),
  });

  /// Current effective amplitude after decay.
  double get currentAmplitude {
    final elapsed = DateTime.now().difference(appliedAt);
    if (elapsed <= Duration.zero) return amplitude;
    final halfLives = elapsed.inMilliseconds / halfLife.inMilliseconds;
    // pow(0.5, halfLives) gives the decay factor
    // After 1 half-life: amplitude × 0.5
    // After 2 half-lives: amplitude × 0.25
    return amplitude * pow(0.5, halfLives);
  }

  /// Whether the shock has fully decayed (amplitude < 0.1%).
  bool get isExpired => currentAmplitude.abs() < 0.001;

  Map<String, dynamic> toJson() => {
    'id': id,
    'amplitude': amplitude,
    'appliedAt': appliedAt.toIso8601String(),
    'halfLifeMs': halfLife.inMilliseconds,
  };

  factory MarketShock.fromJson(Map<String, dynamic> json) => MarketShock(
    id: json['id'] as String,
    amplitude: (json['amplitude'] as num).toDouble(),
    appliedAt: DateTime.parse(json['appliedAt'] as String),
    halfLife: Duration(milliseconds: json['halfLifeMs'] as int),
  );
}

/// A single trade executed in a stress test session.
class StressTestTrade {
  final String symbol;
  final bool isBuy; // true = buy, false = sell
  final double shares;
  final double price;
  final DateTime date;
  final bool wasPeak; // bought at top 10% of epoch price curve
  final bool wasBottom; // sold at bottom 10% of epoch price curve
  final double? realizedPnl; // P&L on sell (null for buys)

  const StressTestTrade({
    required this.symbol,
    required this.isBuy,
    required this.shares,
    required this.price,
    required this.date,
    this.wasPeak = false,
    this.wasBottom = false,
    this.realizedPnl, // null for buys
  });
}

/// A holding in a stress test session.
class StressTestHolding {
  final String symbol;
  final double shares;
  final double avgCost;
  final double entryPrice; // real price from Finnhub at purchase
  final String? cachedLogoUrl; // Logo URL cached during initial search

  const StressTestHolding({
    required this.symbol,
    required this.shares,
    required this.avgCost,
    required this.entryPrice,
    this.cachedLogoUrl,
  });

  /// Alias for [avgCost] — the average purchase price of the position.
  double get averagePrice => avgCost;
}

/// Status of a stress test session.
enum StressTestStatus {
  setup, // User is still buying assets and configuring
  active, // Timer is running, simulation active
  completed, // Timer ended, verdict available
  terminated, // User manually ended (only for infinite)
}

/// Длительность периода стабилизации после покупки (в секундах).
/// В течение этого времени цена актива заморожена на entryPrice,
/// а P&L отображается как 0.00%.
const int stabilizationDurationSeconds = 30;

/// Full state of a single stress test session.
class StressTestSession {
  final String id;
  final TestDuration duration;
  final double startingCash;
  double cash;
  List<StressTestHolding> holdings;
  List<StressTestTrade> trades;
  StressTestStatus status;
  final DateTime createdAt;
  DateTime? startedAt;
  DateTime? completedAt;

  // Scoring variables
  int boughtAtPeakCount;
  int soldAtBottomCount;
  double maxSingleAssetAllocation;
  bool blackSwanSurvived;
  bool hasExperiencedCatastrophe;
  int catastropheCooldown; // epochs remaining before next catastrophe allowed

  // ── Casino Wall-Clock State ──────────────────────────────────
  /// Persistent casino state: catastrophe cooldown counter (epochs remaining).
  int casinoCatastropheCooldown;

  /// Persistent casino state: consecutive decline streak for anti-stuck logic.
  int casinoDeclineStreak;

  /// Persistent casino state: total catastrophes rolled so far.
  int casinoCatastropheCount;

  /// Persistent casino state: index of the last catastrophe epoch.
  int casinoLastCatastropheEpoch;

  // Autonomous company stocks with self-managed IPO lifecycles
  Map<String, CompanyStock> companies;

  // Trader psychology profile (4 sub-indices)
  TraderPsychologyProfile psychologyProfile;

  // Current simulated prices (symbol → price)
  Map<String, double> currentPrices;
  Map<String, double> basePrices; // entry prices from Finnhub
  // Per-symbol epoch price range for peak/bottom detection
  Map<String, EpochPriceRange> epochPriceRanges;

  /// Total realized P&L from all sell trades.
  double realizedPnl;

  /// Custom duration in days (only when [duration] == [TestDuration.custom]).
  int? customDurationDays;

  /// Historical prices per symbol for sparkline chart (newest appended last).
  /// Each tick of the simulation pushes the latest currentPrice into this list.
  Map<String, List<double>> priceHistory;

  /// Explainable Simulation — лог причин изменения цен (не сохраняется в JSON).
  /// symbol → список объяснений за каждый тик.
  Map<String, List<TickExplanation>> explanationLog;

  /// Seed генератора случайных чисел для детерминированной симуляции.
  /// Любой перезапуск сессии с одинаковым [simulationSeed] гарантирует
  /// идентичные графики цен, фазы рынка и IPO-паттерны.
  final int simulationSeed;

  /// Флаг включения Developer Trace Layer.
  /// Если true, движок аккумулирует [TickExplanation.tickId] и raw-поля
  /// (marketDriftRaw, sectorDriftRaw, …) в памяти сессии.
  final bool enableDeveloperTrace;

  // ── Developer Trace Bar (runtime, не сохраняется в JSON) ──────────
  /// Текущая фаза MarketCycleManager (bull, bear, sideways, …).
  String devMarketPhase;

  /// Текущая температура рынка (-90..+90).
  double devMarketTemperature;

  /// Текущая усталость фазы (0.0..1.0).
  double devFatigue;

  /// Сквозной счётчик тиков с момента старта сессии.
  int devCurrentTick;

  // ── Dashboard dev fields (заполняются engine'ом) ────────────────
  /// Fear Index: 0 (greed) … 100 (fear).
  int devFearIndex;

  /// Recovery progress as percentage (0-100).
  double devRecoveryProgress;

  /// Current volatility multiplier (1.0 = baseline).
  double devVolatilityMultiplier;

  /// Name of the next predicted market event.
  String devNextEvent;

  /// Days until the next event.
  int devNextEventDays;

  /// Human-readable volatility level (Low, Normal, Elevated, High, Extreme).
  String devVolatilityLabel;

  /// Моменты окончания периода стабилизации (symbol → DateTime) после покупки.
  /// Пока действует стабилизация — цена заморожена на entryPrice, P&L = 0.00%.
  /// Используется для предотвращения мгновенных скачков P&L после сделки.
  Map<String, DateTime> stabilizationDeadlines;

  /// Динамические веса сценариев для Scenario Fatigue.
  /// Только для стандартных сценариев (bull, sideways, bear, volatile).
  /// Катастрофы (blackSwan, mortgageCrisis) — статичны и не входят в карту.
  /// Ключ — scenario.name, значение — текущий вес в рулетке.
  Map<String, double> currentWeights;

  /// Временная метка последнего сгенерированного тика.
  /// Используется для catch-up при возврате пользователя.
  DateTime? lastTickTimestamp;

  /// Per-session sandbox: true, если катастрофа уже записана
  /// в психологический профиль для этой сессии.
  /// Заменяет старый глобальный Set<String> в StateNotifier.
  bool catastropheSurvivalRecorded;

  /// Task 1.5: true, когда бонус диверсификации уже начислен.
  bool diversificationBonusRecorded;

  /// Task 1.5: символы, проданные во время текущей катастрофы.
  Set<String> soldDuringCatastrophe;

  /// ── Sandbox Isolation (Step 3): Active market shock ────────────
  /// Temporary price modifier with exponential decay. Applied in
  /// _simulateCurrentPrices as a per-tick multiplier. When expired
  /// (amplitude < 0.1%), set to null.
  MarketShock? activeShock;

  // ── Block 5: Per-Company Spec/Hype Events ────────────────────
  /// Active per-company speculation/hype events (bell-shape price impact).
  List<CompanySpecEvent> specEvents;

  /// Cooldown map: symbol → DateTime until which new events are blocked.
  Map<String, DateTime> specEventCooldowns;

  /// Timestamp of the last weekly wall-clock check for spec/hype events.
  /// Gated on real elapsed time (~7 days), not on epoch rolls — epoch
  /// length varies per test type (Block 6), so tying this to epoch count
  /// would fire far more often than the intended weekly cadence.
  DateTime? lastSpecEventCheckAt;

  // ── Block 6: Casino Wall-Clock Epoch History ──────────────────
  /// Timestamp of the last epoch roll (for catch-up on re-entry).
  DateTime? lastEpochRollAt;

  /// History of all epoch transitions (populated incrementally).
  List<EpochRecord> epochHistory;

  StressTestSession({
    required this.id,
    required this.duration,
    required this.startingCash,
    double? cash,
    this.holdings = const [],
    this.trades = const [],
    this.status = StressTestStatus.setup,
    DateTime? createdAt,
    this.startedAt,
    this.completedAt,
    this.boughtAtPeakCount = 0,
    this.soldAtBottomCount = 0,
    this.maxSingleAssetAllocation = 0,
    this.blackSwanSurvived = false,
    this.hasExperiencedCatastrophe = false,
    this.catastropheCooldown = 0,
    this.casinoCatastropheCooldown = 0,
    this.casinoDeclineStreak = 0,
    this.casinoCatastropheCount = 0,
    this.casinoLastCatastropheEpoch = -100,
    this.companies = const {},
    TraderPsychologyProfile? psychologyProfile,
    this.currentPrices = const {},
    this.basePrices = const {},
    this.epochPriceRanges = const {},
    this.realizedPnl = 0,
    this.customDurationDays,
    this.priceHistory = const {},
    this.explanationLog = const {},
    this.simulationSeed = 0,
    this.enableDeveloperTrace = false,
    this.devMarketPhase = '',
    this.devMarketTemperature = 0,
    this.devFatigue = 0,
    this.devCurrentTick = 0,
    this.devFearIndex = 50,
    this.devRecoveryProgress = 0,
    this.devVolatilityMultiplier = 1.0,
    this.devNextEvent = '',
    this.devNextEventDays = 0,
    this.devVolatilityLabel = 'Normal',
    this.stabilizationDeadlines = const {},
    this.currentWeights = const {},
    this.lastTickTimestamp,
    this.catastropheSurvivalRecorded = false,
    this.diversificationBonusRecorded = false,
    this.soldDuringCatastrophe = const <String>{},
    this.activeShock,
    this.specEvents = const [],
    this.specEventCooldowns = const {},
    this.lastSpecEventCheckAt,
    this.lastEpochRollAt,
    this.epochHistory = const [],
  }) : cash = cash ?? startingCash,
       createdAt = createdAt ?? DateTime.now(),
       psychologyProfile = psychologyProfile ?? TraderPsychologyProfile();

  /// Возвращает эффективную цену для расчётов.
  /// Во время стабилизации (первые 30 сек после покупки) — entryPrice.
  /// Иначе — currentPrice или entryPrice как fallback.
  double _effectivePrice(String symbol) {
    final deadline = stabilizationDeadlines[symbol];
    if (deadline != null && DateTime.now().isBefore(deadline)) {
      final hIdx = holdings.indexWhere((h) => h.symbol == symbol);
      if (hIdx >= 0) return holdings[hIdx].entryPrice;
    }
    return currentPrices[symbol] ?? 0;
  }

  /// Total portfolio value at simulated current prices.
  double get totalValue {
    double value = cash;
    for (final h in holdings) {
      final price = _effectivePrice(h.symbol);
      value += h.shares * price;
    }
    return value;
  }

  /// Profit/loss in dollars (realized + unrealized).
  double get profitLoss => totalValue - startingCash;

  /// Profit/loss as percentage of starting cash.
  double get profitLossPercent =>
      startingCash > 0 ? (profitLoss / startingCash) * 100 : 0;

  /// Total unrealized (paper) profit/loss.
  double get unrealizedPnl => profitLoss - realizedPnl;

  /// Per-symbol unrealized P&L in dollars.
  /// Возвращает 0.0 для активов в периоде стабилизации.
  Map<String, double> get positionPnL {
    final result = <String, double>{};
    for (final h in holdings) {
      final deadline = stabilizationDeadlines[h.symbol];
      if (deadline != null && DateTime.now().isBefore(deadline)) {
        result[h.symbol] = 0.0;
        continue;
      }
      final price = currentPrices[h.symbol] ?? h.entryPrice;
      result[h.symbol] = (price - h.avgCost) * h.shares;
    }
    return result;
  }

  /// Per-symbol unrealized P&L as percentage.
  /// Возвращает 0.0% для активов в периоде стабилизации.
  Map<String, double> get positionPnLPercent {
    final result = <String, double>{};
    for (final h in holdings) {
      final deadline = stabilizationDeadlines[h.symbol];
      if (deadline != null && DateTime.now().isBefore(deadline)) {
        result[h.symbol] = 0.0;
        continue;
      }
      final price = currentPrices[h.symbol] ?? h.entryPrice;
      result[h.symbol] = h.avgCost > 0
          ? ((price - h.avgCost) / h.avgCost) * 100
          : 0;
    }
    return result;
  }

  /// Total value of all holdings at simulated current prices (cash excluded).
  double get totalAssetsValue {
    double value = 0;
    for (final h in holdings) {
      final price = _effectivePrice(h.symbol);
      value += h.shares * price;
    }
    return value;
  }

  /// Per-symbol allocation as percentage of total assets (cash excluded).
  /// Calculated ONLY among actual holdings — free cash does NOT dilute this %.
  Map<String, double> get positionAllocation {
    final result = <String, double>{};
    final assetsValue = totalAssetsValue;
    if (assetsValue <= 0) return result;
    for (final h in holdings) {
      final price = _effectivePrice(h.symbol);
      result[h.symbol] = (h.shares * price / assetsValue) * 100;
    }
    return result;
  }

  /// Current allocation to the largest holding as fraction of total.
  double get currentMaxAllocation {
    if (holdings.isEmpty || totalValue <= 0) return 0;
    double maxVal = 0;
    for (final h in holdings) {
      final price = _effectivePrice(h.symbol);
      final val = h.shares * price;
      if (val > maxVal) maxVal = val;
    }
    return maxVal / totalValue;
  }

  /// Number of symbols held.
  int get holdingCount => holdings.length;

  /// True once the Infinite ("until bored") minimum has elapsed and the
  /// user is allowed to manually end the test. Purely time-based — real
  /// wall-clock elapsed since [startedAt], same measure every other
  /// duration type uses for its own completion check (see
  /// casino_epochs.dart's `_catchUp` and `stress_test_screen.dart`'s
  /// `_getTestDuration`/`_buildTimerBar`, which already counts down to
  /// this same [infiniteMinDuration] before switching to "Test Complete").
  bool get canExitInfinite =>
      duration == TestDuration.infinite &&
      startedAt != null &&
      DateTime.now().difference(startedAt!) >= infiniteMinDuration;
}

// ---------------------------------------------------------------------------
// Psychological Verdict
// ---------------------------------------------------------------------------

enum VerdictType { panic, fomo, activeTrader, buffettShield }

class PsychologicalVerdict {
  final VerdictType primaryType;
  final int fsScore;
  final String title;
  final String description;
  final bool hasDiversificationWarning;
  final bool hasAbsoluteShieldBadge;

  const PsychologicalVerdict({
    required this.primaryType,
    required this.fsScore,
    required this.title,
    required this.description,
    this.hasDiversificationWarning = false,
    this.hasAbsoluteShieldBadge = false,
  });

  Map<String, dynamic> toJson() => {
    'primaryType': primaryType.name,
    'fsScore': fsScore,
    'title': title,
    'description': description,
    'hasDiversificationWarning': hasDiversificationWarning,
    'hasAbsoluteShieldBadge': hasAbsoluteShieldBadge,
  };

  factory PsychologicalVerdict.fromJson(Map<String, dynamic> json) =>
      PsychologicalVerdict(
        primaryType: VerdictType.values.firstWhere(
          (t) => t.name == (json['primaryType'] as String),
        ),
        fsScore: json['fsScore'] as int? ?? 0,
        title: json['title'] as String? ?? '',
        description: json['description'] as String? ?? '',
        hasDiversificationWarning:
            json['hasDiversificationWarning'] as bool? ?? false,
        hasAbsoluteShieldBadge:
            json['hasAbsoluteShieldBadge'] as bool? ?? false,
      );
}

// ---------------------------------------------------------------------------
// Verdict Archive Entry — lightweight record kept after test completion
// ---------------------------------------------------------------------------

/// Minimal record saved when a stress test completes.
/// The full session is discarded — only the verdict + key stats survive.
class VerdictArchiveEntry {
  final String sessionId;
  final String durationLabel;
  final double startingCash;
  final double finalValue;
  final double pnlPercent;
  final int totalTrades;
  final int holdingCount;
  final DateTime completedAt;
  final PsychologicalVerdict verdict;

  const VerdictArchiveEntry({
    required this.sessionId,
    required this.durationLabel,
    required this.startingCash,
    required this.finalValue,
    required this.pnlPercent,
    required this.totalTrades,
    required this.holdingCount,
    required this.completedAt,
    required this.verdict,
  });

  Map<String, dynamic> toJson() => {
    'sessionId': sessionId,
    'durationLabel': durationLabel,
    'startingCash': startingCash,
    'finalValue': finalValue,
    'pnlPercent': pnlPercent,
    'totalTrades': totalTrades,
    'holdingCount': holdingCount,
    'completedAt': completedAt.toIso8601String(),
    'verdict': verdict.toJson(),
  };

  factory VerdictArchiveEntry.fromJson(Map<String, dynamic> json) =>
      VerdictArchiveEntry(
        sessionId: json['sessionId'] as String,
        durationLabel: json['durationLabel'] as String? ?? '',
        startingCash: (json['startingCash'] as num?)?.toDouble() ?? 0,
        finalValue: (json['finalValue'] as num?)?.toDouble() ?? 0,
        pnlPercent: (json['pnlPercent'] as num?)?.toDouble() ?? 0,
        totalTrades: json['totalTrades'] as int? ?? 0,
        holdingCount: json['holdingCount'] as int? ?? 0,
        completedAt: json['completedAt'] != null
            ? DateTime.parse(json['completedAt'] as String)
            : DateTime.now(),
        verdict: PsychologicalVerdict.fromJson(
          json['verdict'] as Map<String, dynamic>,
        ),
      );
}

// ---------------------------------------------------------------------------
// Reactive Analytics — computed immutably from StressTestSession
// ---------------------------------------------------------------------------
// Design principle (Product Constitution VIII — Explainable First):
//   Every metric is derived reactively via ref.watch, never mutated
//   synchronously inside build(). This eliminates Riverpod build-phase
//   violations ("Tried to modify a provider while the widget tree was
//   building") caused by StateController<String?> modifications during
//   live tick calculations.
// ---------------------------------------------------------------------------

/// Immutable snapshot of all portfolio analytics computed from a session.
/// Created reactively by [stressTestAnalyticsProvider] using [ref.watch],
/// ensuring zero side effects during the widget build phase.
class StressTestAnalytics {
  // ── Core psychology scores ────────────────────────────────────
  final double fsScore; // 0-100 composite
  final double panicResistance; // 0.0-1.0
  final double discipline;
  final double patience;
  final double strategyAdherence;

  // ── Trade statistics ──────────────────────────────────────────
  final int totalTrades;
  final int buyTrades;
  final int sellTrades;
  final int boughtAtPeakCount;
  final int soldAtBottomCount;
  final double realizedPnl;

  // ── Diversification ───────────────────────────────────────────
  final int sectorCount;
  final double maxConcentrationPct; // 0-100
  final bool hasDiversificationWarning;

  // ── Activity ──────────────────────────────────────────────────
  final double tradesPerDay;

  // ── Risk ──────────────────────────────────────────────────────
  final double cashBufferPct; // 0-100

  // ── Portfolio snapshot ────────────────────────────────────────
  final double totalValue;
  final double totalPnl;
  final double pnlPercent;
  final double cash;
  final int holdingCount;

  // ── Derived audit labels (never mutated directly) ─────────────
  final String auditTitle;
  final String auditSubtitle;
  final String activeRiskLabel;

  const StressTestAnalytics({
    required this.fsScore,
    required this.panicResistance,
    required this.discipline,
    required this.patience,
    required this.strategyAdherence,
    required this.totalTrades,
    required this.buyTrades,
    required this.sellTrades,
    required this.boughtAtPeakCount,
    required this.soldAtBottomCount,
    required this.realizedPnl,
    required this.sectorCount,
    required this.maxConcentrationPct,
    required this.hasDiversificationWarning,
    required this.tradesPerDay,
    required this.cashBufferPct,
    required this.totalValue,
    required this.totalPnl,
    required this.pnlPercent,
    required this.cash,
    required this.holdingCount,
    required this.auditTitle,
    required this.auditSubtitle,
    required this.activeRiskLabel,
  });

  /// Neutral / empty analytics — safe default before any session starts.
  static const empty = StressTestAnalytics(
    fsScore: 0,
    panicResistance: 0,
    discipline: 0,
    patience: 0,
    strategyAdherence: 0,
    totalTrades: 0,
    buyTrades: 0,
    sellTrades: 0,
    boughtAtPeakCount: 0,
    soldAtBottomCount: 0,
    realizedPnl: 0,
    sectorCount: 0,
    maxConcentrationPct: 0,
    hasDiversificationWarning: false,
    tradesPerDay: 0,
    cashBufferPct: 0,
    totalValue: 0,
    totalPnl: 0,
    pnlPercent: 0,
    cash: 0,
    holdingCount: 0,
    auditTitle: 'No Data',
    auditSubtitle: 'Start a stress test to see analytics',
    activeRiskLabel: '',
  );

  /// Reactive factory — computes analytics from session data.
  /// Called exclusively by [stressTestAnalyticsProvider] via [ref.watch],
  /// never directly from a widget build method.
  factory StressTestAnalytics.fromSession(StressTestSession session) {
    final profile = session.psychologyProfile;
    final trades = session.trades;

    final totalTrades = trades.length;
    final buyTrades = trades.where((t) => t.isBuy).length;
    final sellTrades = trades.where((t) => !t.isBuy).length;
    final boughtAtPeak = trades.where((t) => t.isBuy && t.wasPeak).length;
    final soldAtBottom = trades.where((t) => !t.isBuy && t.wasBottom).length;

    // Sector count
    final sectors = <MarketSector>{};
    for (final h in session.holdings) {
      try {
        // Use the asset-sector mapping from engine constants
        final assetSector = resolveAssetSector(h.symbol);
        sectors.add(marketSectorToAssetSectorReversed(assetSector));
      } catch (_) {}
    }

    // Trade frequency (trades per day)
    double tpd = 0;
    if (session.startedAt != null && totalTrades > 0) {
      final elapsedDays =
          DateTime.now().difference(session.startedAt!).inMinutes / 1440.0;
      tpd = totalTrades / elapsedDays.clamp(0.25, double.infinity);
    }

    // Cash buffer
    final cashPct = session.totalValue > 0
        ? (session.cash / session.totalValue * 100)
        : 0.0;

    // Derived audit labels
    final fsVal = (profile.compositeScore * 100).round().clamp(0, 100);
    final auditTitle = _deriveAuditTitle(fsVal, profile);
    final auditSubtitle = _deriveAuditSubtitle(profile, tpd, sectors.length);
    final activeRiskLabel = _deriveActiveRisk(
      session.currentMaxAllocation,
      cashPct,
      sectors.length,
      tpd,
    );

    return StressTestAnalytics(
      fsScore: fsVal.toDouble(),
      panicResistance: profile.panicResistance,
      discipline: profile.discipline,
      patience: profile.patience,
      strategyAdherence: profile.strategyAdherence,
      totalTrades: totalTrades,
      buyTrades: buyTrades,
      sellTrades: sellTrades,
      boughtAtPeakCount: boughtAtPeak,
      soldAtBottomCount: soldAtBottom,
      realizedPnl: session.realizedPnl,
      sectorCount: sectors.length,
      maxConcentrationPct: (session.currentMaxAllocation * 100).roundToDouble(),
      hasDiversificationWarning: session.currentMaxAllocation > 0.50,
      tradesPerDay: tpd,
      cashBufferPct: cashPct,
      totalValue: session.totalValue,
      totalPnl: session.profitLoss,
      pnlPercent: session.profitLossPercent,
      cash: session.cash,
      holdingCount: session.holdings.length,
      auditTitle: auditTitle,
      auditSubtitle: auditSubtitle,
      activeRiskLabel: activeRiskLabel,
    );
  }

  // ── Audit label helpers ─────────────────────────────────────────

  static String _deriveAuditTitle(
    int fsScore,
    TraderPsychologyProfile profile,
  ) {
    if (fsScore >= 80) return 'Steady Hand';
    if (fsScore >= 65) return 'Thoughtful Investor';
    if (fsScore >= 50) return 'Learning the Ropes';
    if (fsScore >= 35) return 'Emotional Trader';
    if (fsScore > 0) return 'FOMO-Driven';
    return 'Fresh Start';
  }

  static String _deriveAuditSubtitle(
    TraderPsychologyProfile profile,
    double tradesPerDay,
    int sectorCount,
  ) {
    final buf = StringBuffer();
    if (profile.discipline >= 0.6) {
      buf.write('Disciplined execution. ');
    } else if (profile.discipline > 0.0) {
      buf.write('Needs more discipline. ');
    }
    if (profile.patience >= 0.6) {
      buf.write('Patient with drawdowns. ');
    } else if (profile.patience > 0.0 && tradesPerDay > 2) {
      buf.write('Trading too fast — slow down. ');
    }
    if (sectorCount >= 3) {
      buf.write('Well diversified.');
    } else if (sectorCount > 0) {
      buf.write('Consider adding more sectors.');
    }
    if (buf.isEmpty) buf.write('Start trading to build your profile.');
    return buf.toString();
  }

  static String _deriveActiveRisk(
    double maxAllocation,
    double cashPct,
    int sectorCount,
    double tradesPerDay,
  ) {
    if (maxAllocation > 0.50) return '⚠️ High concentration risk';
    if (cashPct < 5) return '⚠️ No safety net — fully invested';
    if (sectorCount == 1) return '⚠️ Single sector exposure';
    if (tradesPerDay > 3) return '⚠️ Overtrading — high stress';
    if (maxAllocation > 0.30) return 'Moderate concentration';
    return '';
  }
}

/// Resolves a symbol to its [AssetSector] using the canonical mapping.
///
/// This is the **Single Source of Truth (SSOT)** for sector classification.
/// Both the simulation engine and all analytics widgets read from this map.
AssetSector resolveAssetSector(String symbol) {
  const map = <String, AssetSector>{
    // ── Tech / Speculative ─────────────────────────────────────────
    'AAPL': AssetSector.techSpeculative,
    'MSFT': AssetSector.techSpeculative,
    'GOOGL': AssetSector.techSpeculative,
    'GOOG': AssetSector.techSpeculative,
    'AMZN': AssetSector.techSpeculative,
    'META': AssetSector.techSpeculative,
    'NVDA': AssetSector.techSpeculative,
    'TSLA': AssetSector.techSpeculative,
    'AMD': AssetSector.techSpeculative,
    'INTC': AssetSector.techSpeculative,
    'CRM': AssetSector.techSpeculative,
    'ADBE': AssetSector.techSpeculative,
    'NFLX': AssetSector.techSpeculative,
    'CSCO': AssetSector.techSpeculative,
    'ORCL': AssetSector.techSpeculative,
    'IBM': AssetSector.techSpeculative,
    'QCOM': AssetSector.techSpeculative,
    'TXN': AssetSector.techSpeculative,
    'AVGO': AssetSector.techSpeculative,
    'MU': AssetSector.techSpeculative,
    'BIIB': AssetSector.techSpeculative,
    'GILD': AssetSector.techSpeculative,
    'MRNA': AssetSector.techSpeculative,
    'ILMN': AssetSector.techSpeculative,
    'VRTX': AssetSector.techSpeculative,
    // ── Consumer Staples / Defensive ───────────────────────────────
    'KO': AssetSector.consumerStaples,
    'PEP': AssetSector.consumerStaples,
    'PG': AssetSector.consumerStaples,
    'WMT': AssetSector.consumerStaples,
    'COST': AssetSector.consumerStaples,
    'MO': AssetSector.consumerStaples,
    'CL': AssetSector.consumerStaples,
    'KMB': AssetSector.consumerStaples,
    'SYY': AssetSector.consumerStaples,
    'GIS': AssetSector.consumerStaples,
    'JNJ': AssetSector.consumerStaples,
    'PFE': AssetSector.consumerStaples,
    'UNH': AssetSector.consumerStaples,
    'ABBV': AssetSector.consumerStaples,
    'MRK': AssetSector.consumerStaples,
    'ABT': AssetSector.consumerStaples,
    'LLY': AssetSector.consumerStaples,
    'MDT': AssetSector.consumerStaples,
    'BMY': AssetSector.consumerStaples,
    'AMGN': AssetSector.consumerStaples,
    // ── Cyclical Consumer / Economically Sensitive ─────────────────
    'JPM': AssetSector.cyclicalConsumer,
    'BAC': AssetSector.cyclicalConsumer,
    'C': AssetSector.cyclicalConsumer,
    'GS': AssetSector.cyclicalConsumer,
    'MS': AssetSector.cyclicalConsumer,
    'WFC': AssetSector.cyclicalConsumer,
    'AXP': AssetSector.cyclicalConsumer,
    'V': AssetSector.cyclicalConsumer,
    'MA': AssetSector.cyclicalConsumer,
    'BLK': AssetSector.cyclicalConsumer,
    'SCHW': AssetSector.cyclicalConsumer,
    'PYPL': AssetSector.cyclicalConsumer,
    'XOM': AssetSector.cyclicalConsumer,
    'CVX': AssetSector.cyclicalConsumer,
    'COP': AssetSector.cyclicalConsumer,
    'EOG': AssetSector.cyclicalConsumer,
    'SLB': AssetSector.cyclicalConsumer,
    'OXY': AssetSector.cyclicalConsumer,
    'MPC': AssetSector.cyclicalConsumer,
    'PSX': AssetSector.cyclicalConsumer,
    'BP': AssetSector.cyclicalConsumer,
    'SHEL': AssetSector.cyclicalConsumer,
    'WHR': AssetSector.cyclicalConsumer,
    'HPQ': AssetSector.cyclicalConsumer,
    'HMC': AssetSector.cyclicalConsumer,
    'CAT': AssetSector.cyclicalConsumer,
    'DE': AssetSector.cyclicalConsumer,
    'FCX': AssetSector.cyclicalConsumer,
    'X': AssetSector.cyclicalConsumer,
    'NEM': AssetSector.cyclicalConsumer,
    'CLF': AssetSector.cyclicalConsumer,
    // ── Real Estate / REIT ─────────────────────────────────────────
    'PLD': AssetSector.realEstateREIT,
    'AMT': AssetSector.realEstateREIT,
    'CCI': AssetSector.realEstateREIT,
    'EQIX': AssetSector.realEstateREIT,
    'PSA': AssetSector.realEstateREIT,
    'O': AssetSector.realEstateREIT,
    'SPG': AssetSector.realEstateREIT,
    'WELL': AssetSector.realEstateREIT,
    // ── Energy / Oil & Gas ─────────────────────────────────────────
    'ECL': AssetSector.cyclicalConsumer,
    // ── ETF Broad Market ───────────────────────────────────────────
    'SPY': AssetSector.etfBroadMarket,
    'QQQ': AssetSector.etfBroadMarket,
    'DIA': AssetSector.etfBroadMarket,
    'IWM': AssetSector.etfBroadMarket,
    'VTI': AssetSector.etfBroadMarket,
    'VOO': AssetSector.etfBroadMarket,
    'IVV': AssetSector.etfBroadMarket,
    'SCHB': AssetSector.etfBroadMarket,
    'ITOT': AssetSector.etfBroadMarket,
    'VEA': AssetSector.etfBroadMarket,
    'VWO': AssetSector.etfBroadMarket,
    'AGG': AssetSector.etfBroadMarket,
    'BND': AssetSector.etfBroadMarket,
  };
  return map[symbol] ?? AssetSector.cyclicalConsumer;
}

/// Reverse mapping from [AssetSector] → representative [MarketSector].
MarketSector marketSectorToAssetSectorReversed(AssetSector a) => switch (a) {
  AssetSector.techSpeculative => MarketSector.technology,
  AssetSector.consumerStaples => MarketSector.consumerStaples,
  AssetSector.cyclicalConsumer => MarketSector.cyclical,
  AssetSector.realEstateREIT => MarketSector.realEstate,
  AssetSector.etfBroadMarket => MarketSector.other,
};
