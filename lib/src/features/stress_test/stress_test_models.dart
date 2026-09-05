// ---------------------------------------------------------------------------
// Stress Test — Data Models
// ---------------------------------------------------------------------------
// All domain models for the Stress Test engine: sessions, trades, epochs,
// scenarios, and the psychological verdict.
// ---------------------------------------------------------------------------

import 'dart:math';
import '../../core/services/gics_sector_mapper.dart';
import '../../l10n/gen/app_localizations.dart';
import 'psychology_profile.dart';

export 'psychology_profile.dart';

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

  /// Display name for the UI. English-only — for non-UI callers (engine/
  /// notification text) that have no [BuildContext]. UI call sites should
  /// use [localizedLabel] instead.
  String get displayName {
    return switch (this) {
      TestDuration.week1 => '1 Week',
      TestDuration.month1 => '1 Month',
      TestDuration.months3 => '3 Months',
      TestDuration.infinite => 'Infinite',
      TestDuration.custom => 'Custom',
    };
  }

  /// Localized display name for the UI — use this instead of [displayName]
  /// anywhere a [BuildContext] is available.
  String localizedLabel(AppLocalizations l10n) {
    return switch (this) {
      TestDuration.week1 => l10n.testDuration1Week,
      TestDuration.month1 => l10n.testDuration1Month,
      TestDuration.months3 => l10n.testDuration3Months,
      TestDuration.infinite => l10n.testDurationInfinite,
      TestDuration.custom => l10n.testDurationCustom,
    };
  }

  /// For Infinite/Custom, there is no fixed end — user triggers completion.
  bool get isTimeLimited => totalDuration != null;

  /// How often the casino rolls a new macro scenario on wall-clock.
  /// [custom] was previously hard-coded to a flat 5 days regardless of the
  /// actual [StressTestSession.customDurationDays] the user picked — a
  /// 2-day custom test would never see a second epoch, a 30-day one would
  /// get only 6. Matched to month1/months3's cadence instead (1 roll/day)
  /// so any custom length gets a sane, proportional number of epochs.
  Duration get rollInterval {
    return switch (this) {
      TestDuration.week1 => const Duration(hours: 12),
      TestDuration.month1 => const Duration(hours: 24),
      TestDuration.months3 => const Duration(hours: 24),
      TestDuration.infinite => const Duration(days: 7),
      TestDuration.custom => const Duration(hours: 24),
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

  /// Block 5: hype/speculation are per-COMPANY concepts, not global epoch
  /// scenarios — they're never rolled by casino_epochs.dart's roulette.
  /// (Speculation's implementation was removed 2026-07-19 — see repair
  /// queue in project memory for the "add back later" list.)
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
      MarketScenario.recovery => 0.010, // +1.0% avg lean, NOT guaranteed
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
      MarketScenario.recovery => 0.018, // same swing character as Bull
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

// TraderPsychologyProfile moved to psychology_profile.dart (2026-08-05) —
// imported/re-exported above.

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
///
/// UI-подписи (why_today_screen.dart) сознательно отличаются от имён полей
/// ниже — переименовано 2026-07-29, чтобы не путать [marketPct] с реальным
/// рынком и не путать [sectorPct] с Hype-событием (оба "про сектор", но
/// разные вещи и разные системы классификации секторов — см. доки ниже):
///   marketPct → в UI "Scenario", sectorPct → в UI "Sector Skew",
///   hypePct → в UI "Sector Trend". newsPct/noisePct подписаны как есть.
class PriceContribution {
  /// Эффект основного сценария эпохи (Bull/Bear/Crash/...), применённый
  /// через [AssetSector] ИМЕННО этого актива — не единое число для всего
  /// рынка: разные AssetSector под одним и тем же сценарием получают
  /// разный дрифт (см. gbm_engine.dart's `_masterMatrix`). В UI: "Scenario".
  final double marketPct;

  /// НЕ отдельное событие — отклонение дрифта [AssetSector] этого актива
  /// от СРЕДНЕГО дрифта по всем активам ТВОЕГО портфеля (`avgDrift` в
  /// noise_engine.dart). Зависит от состава портфеля, а не от рынка — в
  /// однородном портфеле (все активы одного AssetSector) почти всегда
  /// ≈0%. В UI: "Sector Skew".
  ///
  /// Использует другую секторную систему, чем [hypePct]: здесь 5-категорийный
  /// [AssetSector] (матрица дрифта), у Hype — 11-категорийный `GicsSector`
  /// (`resolveGicsSector`). Один и тот же актив может по-разному попадать
  /// в эти две классификации — не путать их между собой.
  final double sectorPct;

  /// Вклад активного News-события (news_event.dart) — случайная новость
  /// по ОДНОЙ конкретной компании.
  final double newsPct;

  /// Вклад активного Hype-события (hype/hype_event.dart) — движение по
  /// ЦЕЛОМУ GICS-сектору сразу (все активы этого сектора двигаются вместе).
  /// В UI: "Sector Trend" — не путать с [sectorPct] выше, это другая вещь
  /// и другая классификация секторов (см. её доку).
  final double hypePct;

  /// Случайный шум GBM-модели без какого-либо направленного драйвера.
  final double noisePct;

  const PriceContribution({
    required this.marketPct,
    required this.sectorPct,
    required this.newsPct,
    this.hypePct = 0,
    required this.noisePct,
  });

  /// Сумма всех факторов = 100% (с rounding tolerance).
  double get total => marketPct + sectorPct + newsPct + hypePct + noisePct;

  Map<String, dynamic> toJson() => {
    'marketPct': marketPct,
    'sectorPct': sectorPct,
    'newsPct': newsPct,
    'hypePct': hypePct,
    'noisePct': noisePct,
  };

  factory PriceContribution.fromJson(Map<String, dynamic> json) =>
      PriceContribution(
        marketPct: (json['marketPct'] as num?)?.toDouble() ?? 0,
        sectorPct: (json['sectorPct'] as num?)?.toDouble() ?? 0,
        newsPct: (json['newsPct'] as num?)?.toDouble() ?? 0,
        hypePct: (json['hypePct'] as num?)?.toDouble() ?? 0,
        noisePct: (json['noisePct'] as num?)?.toDouble() ?? 0,
      );
}

/// Weighted-average contribution breakdown across [ticks], weighted by
/// each tick's own price move (bigger swings count more) — same
/// weighting formula as WhyDiagnosticsAccumulator.averaged
/// (stress_test_why_diagnostics.dart), just computed on demand over
/// whatever ticks are passed in (e.g. a symbol's capped explanationLog)
/// instead of a persistent admin-only accumulator. Use this instead of a
/// single TickExplanation.contributions when a UI number represents a
/// whole window (e.g. "change since market open") rather than one
/// instant — a single latest tick can read as ~0% for a factor (News,
/// Hype) that clearly drove the period's move but isn't contributing
/// anything at this exact instant, which visibly disagreed with the
/// window's own $/% headline number (confirmed live 2026-08-23: an
/// active News event moved the price, but the latest-tick-only
/// breakdown showed 0% News).
PriceContribution aggregatePriceContributions(
  Iterable<TickExplanation> ticks,
) {
  double weightedMarket = 0;
  double weightedSector = 0;
  double weightedNews = 0;
  double weightedHype = 0;
  double weightedNoise = 0;
  double totalWeight = 0;
  for (final t in ticks) {
    final w = t.changePercent.abs();
    final effectiveW = w > 0 ? w : 0.0001;
    weightedMarket += t.contributions.marketPct * effectiveW;
    weightedSector += t.contributions.sectorPct * effectiveW;
    weightedNews += t.contributions.newsPct * effectiveW;
    weightedHype += t.contributions.hypePct * effectiveW;
    weightedNoise += t.contributions.noisePct * effectiveW;
    totalWeight += effectiveW;
  }
  if (totalWeight <= 0) {
    return const PriceContribution(
      marketPct: 0,
      sectorPct: 0,
      newsPct: 0,
      noisePct: 0,
    );
  }
  return PriceContribution(
    marketPct: weightedMarket / totalWeight,
    sectorPct: weightedSector / totalWeight,
    newsPct: weightedNews / totalWeight,
    hypePct: weightedHype / totalWeight,
    noisePct: weightedNoise / totalWeight,
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

  /// Сырой recovery drift (пост-катастрофное восстановление) до нормализации.
  final double? recoveryDriftRaw;

  /// Сырой noise (стохастический шум) до нормализации.
  final double? noiseRaw;

  /// Сырой News-инкремент (news_event.dart) до нормализации — null/0 when
  /// this tick's newsPct came from the old synthetic >5%-correction proxy
  /// rather than a real News event; only non-zero for the latter.
  final double? newsRaw;

  /// Сырой Hype-инкремент (hype/hype_event.dart) до нормализации.
  final double? hypeRaw;

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
    this.recoveryDriftRaw,
    this.noiseRaw,
    this.newsRaw,
    this.hypeRaw,
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

/// A single-company random "News" event — one headline from
/// [newsScenarios] (news_event.dart) picked for one holding, moving that
/// holding's own price by a signed total amount over a gradual ramp.
///
/// Replaces the old `MarketShock` (half-life decay, applied uniformly to
/// EVERY holding) — that class was fully wired but never once triggered
/// anywhere in the codebase (confirmed via a full-repo grep for
/// `MarketShock(`), and its shape (instant peak + exponential decay onto
/// every holding) didn't match the intended design: one company, gradual
/// ramp, no reversal back to zero (a real news-driven move mostly sticks).
///
/// Shape: a front-loaded ease-out curve (`1-(1-t)^3`) over
/// [rampDurationTicks] — most of [targetAmplitude] lands early, tapering
/// to ~flat by the end, never reversing. Applied as a per-TICK INCREMENT
/// (the difference in eased-progress between this tick and the last),
/// not by re-applying the full amplitude every tick — that per-tick-vs-
/// cumulative confusion was a real bug class found while building this
/// mechanism, not repeated here.
class NewsEvent {
  final String symbol;
  final String headline;

  /// The scenario's explanatory body text (news_event.dart's
  /// [NewsScenario.description]) — carried through so the notification
  /// (and any other consumer) can show real "why this happened" copy
  /// instead of just the one-line headline. English only, same as
  /// [headline] — see [scenarioIndex] for the re-localizable version.
  final String description;

  /// This event's position in news_event.dart's `newsScenarios` list —
  /// lets a consumer with real AppLocalizations access (unlike this
  /// engine's tick loop) re-localize [headline]/[description] via
  /// news_scenario_l10n.dart instead of showing the English fallback
  /// above. -1 for events loaded from a pre-this-field persisted session
  /// (see [fromJson]) — falls back to the English strings in that case.
  final int scenarioIndex;
  final bool isPositive;

  /// Total signed price move over the event's full life (e.g. 0.09 = +9%,
  /// -0.11 = -11%). Matches [isPositive]'s sign.
  final double targetAmplitude;

  final DateTime startedAt;
  final int rampDurationTicks;

  /// Ticks elapsed since [startedAt]. Advances once per tick this event
  /// is applied to its symbol; the event expires once this reaches
  /// [rampDurationTicks].
  int currentTick;

  NewsEvent({
    required this.symbol,
    required this.headline,
    required this.description,
    required this.scenarioIndex,
    required this.isPositive,
    required this.targetAmplitude,
    required this.startedAt,
    required this.rampDurationTicks,
    this.currentTick = 0,
  });

  /// Front-loaded ease-out progress curve, 0.0 → 1.0, never decreasing.
  static double _ease(double t) {
    final clamped = t.clamp(0.0, 1.0);
    final inv = 1.0 - clamped;
    return 1.0 - inv * inv * inv;
  }

  /// Fraction of [targetAmplitude] that should be "in" the price by the
  /// given tick (0.0 before start, 1.0 once fully ramped in).
  double _progressAt(int tick) {
    if (rampDurationTicks <= 0) return 1.0;
    return _ease(tick / rampDurationTicks);
  }

  /// The price multiplier to apply THIS tick — the incremental slice of
  /// [targetAmplitude] between the previous tick's progress and this
  /// one's. Sums to exactly [targetAmplitude] across the whole ramp.
  double get tickIncrement =>
      (_progressAt(currentTick + 1) - _progressAt(currentTick)) *
      targetAmplitude;

  /// Whether the ramp has fully completed — the move is now permanently
  /// part of the price, nothing left to apply.
  bool get isExpired => currentTick >= rampDurationTicks;

  NewsEvent copy() => NewsEvent(
    symbol: symbol,
    headline: headline,
    description: description,
    scenarioIndex: scenarioIndex,
    isPositive: isPositive,
    targetAmplitude: targetAmplitude,
    startedAt: startedAt,
    rampDurationTicks: rampDurationTicks,
    currentTick: currentTick,
  );

  Map<String, dynamic> toJson() => {
    'symbol': symbol,
    'headline': headline,
    'description': description,
    'scenarioIndex': scenarioIndex,
    'isPositive': isPositive,
    'targetAmplitude': targetAmplitude,
    'startedAt': startedAt.toIso8601String(),
    'rampDurationTicks': rampDurationTicks,
    'currentTick': currentTick,
  };

  factory NewsEvent.fromJson(Map<String, dynamic> json) => NewsEvent(
    symbol: json['symbol'] as String,
    headline: json['headline'] as String,
    // Old persisted sessions from before this field existed — fall back
    // to empty rather than crash; a stale in-progress News event just
    // shows no body text until it expires naturally.
    description: json['description'] as String? ?? '',
    scenarioIndex: json['scenarioIndex'] as int? ?? -1,
    isPositive: json['isPositive'] as bool,
    targetAmplitude: (json['targetAmplitude'] as num).toDouble(),
    startedAt: DateTime.parse(json['startedAt'] as String),
    rampDurationTicks: json['rampDurationTicks'] as int,
    currentTick: json['currentTick'] as int? ?? 0,
  );
}

/// ── Hype — a sector-wide trending move (hype/hype_event.dart) ─────────
///
/// Unlike [NewsEvent] (one company, sharp ramp, no reversal), Hype targets
/// an entire GICS sector at once — every holding in that sector trends the
/// same direction together, the way a real sector-wide rally or sell-off
/// would move a diversified portfolio.
///
/// Progress curve: smooth ease-in-out ramp that OVERSHOOTS to 115% of
/// [targetAmplitude] around 70% of the way through, then eases back down
/// to exactly 100% by the end — a gentle "small pullback before settling"
/// correction, per explicit design ask, rather than a flat plateau or an
/// instant snap. Applied as a per-TICK INCREMENT (like [NewsEvent]), never
/// by re-applying the full amplitude every tick.
class HypeEvent {
  final GicsSector sector;
  final bool isPositive;

  /// Total signed net move by the end of the ramp (e.g. 0.07 = +7%).
  /// The curve overshoots this mid-ramp and corrects back to exactly
  /// this value — see class doc.
  final double targetAmplitude;

  final DateTime startedAt;
  final int rampDurationTicks;
  int currentTick;

  HypeEvent({
    required this.sector,
    required this.isPositive,
    required this.targetAmplitude,
    required this.startedAt,
    required this.rampDurationTicks,
    this.currentTick = 0,
  });

  /// Ease-in-out overshoot-then-correct progress curve, 0.0 → 1.15 → 1.0.
  static double _progressShape(double t) {
    final clamped = t.clamp(0.0, 1.0);
    if (clamped < 0.7) {
      // 0 → 0.7: ease up to the 1.15 overshoot peak.
      return sin(clamped / 0.7 * pi / 2) * 1.15;
    }
    // 0.7 → 1.0: ease back down from 1.15 to 1.0 (the correction).
    final tail = (clamped - 0.7) / 0.3;
    return 1.15 - sin(tail * pi / 2) * 0.15;
  }

  double _progressAt(int tick) {
    if (rampDurationTicks <= 0) return 1.0;
    return _progressShape(tick / rampDurationTicks);
  }

  /// The price multiplier to apply THIS tick — the incremental slice of
  /// [targetAmplitude] between the previous tick's progress and this
  /// one's. Sums to exactly [targetAmplitude] across the whole ramp
  /// (the overshoot and correction cancel out along the way).
  double get tickIncrement =>
      (_progressAt(currentTick + 1) - _progressAt(currentTick)) *
      targetAmplitude;

  bool get isExpired => currentTick >= rampDurationTicks;

  HypeEvent copy() => HypeEvent(
    sector: sector,
    isPositive: isPositive,
    targetAmplitude: targetAmplitude,
    startedAt: startedAt,
    rampDurationTicks: rampDurationTicks,
    currentTick: currentTick,
  );

  Map<String, dynamic> toJson() => {
    'sector': sector.name,
    'isPositive': isPositive,
    'targetAmplitude': targetAmplitude,
    'startedAt': startedAt.toIso8601String(),
    'rampDurationTicks': rampDurationTicks,
    'currentTick': currentTick,
  };

  factory HypeEvent.fromJson(Map<String, dynamic> json) => HypeEvent(
    sector: GicsSector.values.firstWhere(
      (s) => s.name == json['sector'],
      orElse: () => GicsSector.technology,
    ),
    isPositive: json['isPositive'] as bool,
    targetAmplitude: (json['targetAmplitude'] as num).toDouble(),
    startedAt: DateTime.parse(json['startedAt'] as String),
    rampDurationTicks: json['rampDurationTicks'] as int,
    currentTick: json['currentTick'] as int? ?? 0,
  );
}

/// Broker-style commission charged on every Stress Test trade — matches
/// real brokers' fee structure, 0.5% of trade value on both buys and
/// sells. Applied in trades_engine.dart's executeTrade, which is the ONE
/// path both Market fills and Limit fills go through (see
/// stress_test_pending_orders_provider.dart's comment on reusing
/// executeTrade unmodified) — so this single constant covers both.
const double stressTestCommissionRate = 0.005;

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
  // Brokerage commission charged on this trade (stressTestCommissionRate
  // of shares*price) — already deducted from/added against cash by
  // executeTrade, stored here purely for display (Trade Detail card).
  // Defaults 0 so trades saved before this field existed still decode.
  final double fee;

  const StressTestTrade({
    required this.symbol,
    required this.isBuy,
    required this.shares,
    required this.price,
    required this.date,
    this.wasPeak = false,
    this.wasBottom = false,
    this.realizedPnl, // null for buys
    this.fee = 0,
  });

  Map<String, dynamic> toJson() => {
    'symbol': symbol,
    'isBuy': isBuy,
    'shares': shares,
    'price': price,
    'date': date.toIso8601String(),
    'wasPeak': wasPeak,
    'wasBottom': wasBottom,
    'realizedPnl': realizedPnl,
    'fee': fee,
  };

  factory StressTestTrade.fromJson(Map<String, dynamic> json) =>
      StressTestTrade(
        symbol: json['symbol'] as String,
        isBuy: json['isBuy'] as bool,
        shares: (json['shares'] as num).toDouble(),
        price: (json['price'] as num).toDouble(),
        date: DateTime.parse(json['date'] as String),
        wasPeak: json['wasPeak'] as bool? ?? false,
        wasBottom: json['wasBottom'] as bool? ?? false,
        realizedPnl: (json['realizedPnl'] as num?)?.toDouble(),
        fee: (json['fee'] as num?)?.toDouble() ?? 0,
      );
}

/// A holding in a stress test session.
class StressTestHolding {
  final String symbol;
  final double shares;
  final double avgCost;
  final double entryPrice; // real price from Finnhub at purchase
  final String? cachedLogoUrl; // Logo URL cached during initial search

  /// The company's FS Score (0-100) at the moment of the FIRST purchase
  /// of this symbol in this session — "Safety Marker" signal. Fetched
  /// asynchronously right after that first buy (see trades_engine.dart)
  /// and never touched again by later buys/sells of the same symbol —
  /// averaging up doesn't change the entry-quality judgment. Null until
  /// the fetch resolves, or if it fails / the symbol has no fundamentals
  /// (funds/ETFs) — excluded from the Safety Marker average in that case.
  final double? entryFsScore;

  /// True when Finnhub's search result for this symbol was tagged
  /// `type: 'ETF'` at the moment it was bought (see
  /// stress_test_search_sheet.dart's onTap → _selectCompany). Feeds the
  /// Strategy pillar's ETF Exposure signal directly — added 2026-08-06
  /// after confirmed bug: real ETFs outside the small hardcoded
  /// `AssetSector.etfBroadMarket` ticker list (e.g. SCJ, PPH) never moved
  /// that bar, since sector-based classification has no general "is this
  /// an ETF" detector. Defaults false for holdings bought before this
  /// field existed, or via a path that doesn't have the search result's
  /// `type` (see computeStrategySubScores — ORs this with the old
  /// sector-based check, doesn't replace it).
  final bool isEtf;

  /// Fundamentals snapshotted from the SAME `metrics()` call that resolves
  /// [entryFsScore], right after this symbol's FIRST purchase — never
  /// re-fetched or touched by later buys/sells/top-ups. [entryPeTTM] and
  /// [entryDividendYieldAnnual] are the raw Finnhub `peTTM`/
  /// `dividendYieldIndicatedAnnual` values; [entryNetMargin]/[entryOpMargin]/
  /// [entryGrossMargin]/[entryRoe] are the matching margin/ROE fields —
  /// none of these move with price, they're frozen at entry like
  /// [entryFsScore]. [entryFundamentalsPrice] is the real price at the
  /// moment these were fetched — deliberately separate from [entryPrice],
  /// which later top-up buys reset to the top-up's own price; using that
  /// mutated value as the P/E-ratio anchor would silently miscalibrate the
  /// live P/E (see stress_test_live_metrics.dart's liveKeyMetrics).
  final double? entryPeTTM;
  final double? entryDividendYieldAnnual;
  final double? entryNetMargin;
  final double? entryOpMargin;
  final double? entryGrossMargin;
  final double? entryRoe;
  final double? entryFundamentalsPrice;

  const StressTestHolding({
    required this.symbol,
    required this.shares,
    required this.avgCost,
    required this.entryPrice,
    this.cachedLogoUrl,
    this.entryFsScore,
    this.isEtf = false,
    this.entryPeTTM,
    this.entryDividendYieldAnnual,
    this.entryNetMargin,
    this.entryOpMargin,
    this.entryGrossMargin,
    this.entryRoe,
    this.entryFundamentalsPrice,
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

  /// User-given label, settable on the Setup screen before the test
  /// starts (see `StressTestNotifier.renameSession`). Null/empty means
  /// "no custom name" — every display site falls back to a
  /// duration-based label via [displayLabel]. Mutable (not final) so
  /// renaming doesn't require a full session reconstruction.
  String? name;
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

  // Trader psychology profile (4 sub-indices)
  TraderPsychologyProfile psychologyProfile;

  // Current simulated prices (symbol → price)
  Map<String, double> currentPrices;
  Map<String, double> basePrices; // entry prices from Finnhub
  // Per-symbol epoch price range for peak/bottom detection
  Map<String, EpochPriceRange> epochPriceRanges;

  /// ── Recovery cross-asset tuning (device-test feedback 2026-07-23) ──
  /// Snapshot of each held symbol's price the moment the preceding
  /// catastrophe (crash/blackSwan) epoch started — used to measure how
  /// hard THIS asset fell, so the scripted Recovery regime can weight its
  /// bounce-back speed per-asset instead of a flat rate for every holding.
  Map<String, double> preCrashPrices;

  /// Snapshot of each held symbol's price the moment the scripted
  /// Recovery regime's first epoch started (== the crash's ending price).
  /// Used as the divergence-limit anchor: during Recovery, no single
  /// asset is allowed to drop more than [_recoveryDivergenceFloor] below
  /// this price, so one holding's bad noise-roll can't cancel out the
  /// regime's designed positive drift for the rest of the portfolio.
  Map<String, double> recoveryStartPrices;

  /// Total realized P&L from all sell trades.
  double realizedPnl;

  /// Total simulated dividend payouts credited to [cash] over the session
  /// (see [creditDividendPayout] in stress_test_engine.dart) — shown as a
  /// single summary row on the verdict's Trade Breakdown card.
  double dividendsReceived;

  /// Number of weekly DCA top-up credits applied (see [creditDcaPayout]),
  /// counted per elapsed week rather than per catch-up call (a catch-up
  /// spanning 3 missed weeks counts as 3, not 1) — paired with
  /// [dcaTotalReceived] for the verdict's Trade Breakdown card.
  int dcaTopUpCount;

  /// Total $ credited via weekly DCA top-ups over the session.
  double dcaTotalReceived;

  /// Custom duration in days (only when [duration] == [TestDuration.custom]).
  int? customDurationDays;

  /// Historical prices per symbol for sparkline chart (newest appended last).
  /// Each tick of the simulation pushes the latest currentPrice into this list.
  Map<String, List<double>> priceHistory;

  /// Real wall-clock timestamp (epoch millis) for each entry in
  /// [priceHistory], same keys, same per-key length/order — every place
  /// that appends a price also appends its real timestamp here. Lets
  /// [StressTestNotifier.computeChartData] plot against genuine calendar
  /// time (including large catch-up gaps) instead of a synthetic "now
  /// minus index × 20s" reconstruction. Sessions persisted before this
  /// field existed simply have a shorter (or missing) array per symbol —
  /// computeChartData falls back to the old synthetic method for those
  /// points rather than crashing/misaligning.
  Map<String, List<int>> priceHistoryTimestamps;

  /// One point per UTC calendar day (holding that day's LAST tick — the
  /// same "close" convention a real daily candle uses), folded in
  /// alongside every [priceHistory] append (see `_foldIntoDailyHistory`
  /// in stress_test_engine.dart). [priceHistory] itself is trimmed to
  /// ~27h by `_maxPriceHistoryPoints`, so for any chart period longer
  /// than 1D this is the only place older price history survives at all —
  /// without it, 1W/1M/3M/1Y charts had nothing to show but the same
  /// ~27h of raw ticks stretched to fill the width, which is why they all
  /// used to render identically. Reset to empty whenever [priceHistory]
  /// itself resets (test start), same lifecycle.
  Map<String, List<double>> dailyPriceHistory;

  /// Real wall-clock timestamp (epoch millis, UTC midnight of that day)
  /// for each entry in [dailyPriceHistory] — same lockstep convention as
  /// [priceHistoryTimestamps].
  Map<String, List<int>> dailyPriceHistoryTimestamps;

  /// Explainable Simulation — лог причин изменения цен (не сохраняется в JSON).
  /// symbol → список объяснений за каждый тик.
  Map<String, List<TickExplanation>> explanationLog;

  /// Seed генератора случайных чисел для детерминированной симуляции.
  /// Любой перезапуск сессии с одинаковым [simulationSeed] гарантирует
  /// идентичные графики цен и фазы рынка.
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
  /// Заменяет старый глобальный `Set<String>` в StateNotifier.
  bool catastropheSurvivalRecorded;

  /// Task 1.5: true, когда бонус диверсификации уже начислен.
  bool diversificationBonusRecorded;

  /// Task 1.5: символы, проданные во время текущей катастрофы.
  Set<String> soldDuringCatastrophe;

  /// ── News micro-scenario (news_event.dart) ───────────────────────
  /// The one active random single-company News event, if any. Applied in
  /// _simulateCurrentPrices as a per-tick incremental multiplier, only to
  /// the matching holding. Set to null once its ramp completes.
  NewsEvent? activeNewsEvent;

  /// Epoch index this session last rolled the 5%-per-epoch News check at
  /// (whether or not it actually fired) — prevents re-rolling every tick
  /// within the same epoch. -1 = never checked.
  int lastNewsCheckedEpoch;

  /// ── Hype (hype/hype_event.dart) ──────────────────────────────────
  /// Active sector-wide Hype events. 0, 1, or 2 concurrent — when 2 are
  /// active they are always opposite-signed (one sector up, one down);
  /// same-signed duplicates are collapsed to 1 at roll time. No new roll
  /// is attempted while this is non-empty.
  List<HypeEvent> activeHypeEvents;

  /// Epoch index this session last rolled the 7%-per-epoch Hype check at
  /// (whether or not it actually fired) — mirrors [lastNewsCheckedEpoch].
  int lastHypeCheckedEpoch;

  // ── Block 6: Casino Wall-Clock Epoch History ──────────────────
  /// Timestamp of the last epoch roll (for catch-up on re-entry).
  DateTime? lastEpochRollAt;

  /// History of all epoch transitions (populated incrementally).
  List<EpochRecord> epochHistory;

  StressTestSession({
    required this.id,
    this.name,
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
    TraderPsychologyProfile? psychologyProfile,
    this.currentPrices = const {},
    this.basePrices = const {},
    this.epochPriceRanges = const {},
    this.preCrashPrices = const {},
    this.recoveryStartPrices = const {},
    this.realizedPnl = 0,
    this.dividendsReceived = 0,
    this.dcaTopUpCount = 0,
    this.dcaTotalReceived = 0,
    this.customDurationDays,
    this.priceHistory = const {},
    this.priceHistoryTimestamps = const {},
    this.dailyPriceHistory = const {},
    this.dailyPriceHistoryTimestamps = const {},
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
    this.devVolatilityLabel = 'Normal',
    this.stabilizationDeadlines = const {},
    this.currentWeights = const {},
    this.lastTickTimestamp,
    this.catastropheSurvivalRecorded = false,
    this.diversificationBonusRecorded = false,
    this.soldDuringCatastrophe = const <String>{},
    this.activeNewsEvent,
    this.lastNewsCheckedEpoch = -1,
    this.activeHypeEvents = const [],
    this.lastHypeCheckedEpoch = -1,
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

  /// Total cash the user actually put at risk: [startingCash] plus every
  /// DCA top-up credited via [dcaTotalReceived]. DCA top-ups are deposits
  /// (see `creditDcaPayout` in stress_test_engine.dart) — free cash added
  /// to fund a Custom-duration test, not investment return — so they must
  /// be added to the baseline rather than counted as profit. Dividends are
  /// NOT included here: they're income earned from a held position (a real
  /// investment outcome), so they correctly stay part of [profitLoss].
  double get totalContributedCapital => startingCash + dcaTotalReceived;

  /// Profit/loss in dollars (realized + unrealized), measured against
  /// [totalContributedCapital] rather than the raw [startingCash]. Without
  /// this, a zero-trade Custom-duration DCA test could show a large
  /// "profit" purely from weekly top-ups sitting in cash — which also fed
  /// straight into [calculateVerdict]'s pnl-based Panic/Patient Shield
  /// gates, letting deposited cash mask real panic-selling or falsely
  /// reward an untraded session. Fixed 2026-09-05.
  double get profitLoss => totalValue - totalContributedCapital;

  /// Profit/loss as percentage of [totalContributedCapital].
  double get profitLossPercent => totalContributedCapital > 0
      ? (profitLoss / totalContributedCapital) * 100
      : 0;

  /// Total unrealized (paper) profit/loss.
  double get unrealizedPnl => profitLoss - realizedPnl;

  /// Unrealized P&L as a percentage of the cost basis of currently held
  /// positions — matches positionPnLPercent's per-symbol convention (%
  /// vs. cost, not vs. current value). 0 if nothing is currently held.
  double get unrealizedPnlPercent {
    final costBasis = holdings.fold(
      0.0,
      (sum, h) => sum + h.shares * h.avgCost,
    );
    return costBasis > 0 ? (unrealizedPnl / costBasis) * 100 : 0;
  }

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

  /// [name] when the user set one, else [fallback] (each call site's own
  /// existing duration-based label) — the single place every list row /
  /// notification should go through instead of reading [name] directly.
  String displayLabel(String fallback) =>
      (name != null && name!.trim().isNotEmpty) ? name!.trim() : fallback;
}

// ---------------------------------------------------------------------------
// Psychological Verdict
// ---------------------------------------------------------------------------

enum VerdictType { panic, fomo, activeTrader, patientShield }

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
        // orElse covers 'buffettShield' from archives saved before the enum
        // was renamed to patientShield — falls back instead of throwing so
        // old on-device verdict history doesn't crash on load.
        primaryType: VerdictType.values.firstWhere(
          (t) => t.name == (json['primaryType'] as String),
          orElse: () => VerdictType.patientShield,
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

  /// User-given label snapshotted from [StressTestSession.name] at
  /// completion (that session object is wiped right after archiving) —
  /// null/empty means no custom name, same convention as the live session.
  final String? name;
  final String durationLabel;
  final double startingCash;
  final double finalValue;
  final double pnlPercent;
  final int totalTrades;
  final int holdingCount;
  final DateTime completedAt;
  final PsychologicalVerdict verdict;

  /// Full per-trade record, kept for the verdict screen's trade breakdown
  /// widget (symbol, buy/sell, price, realized P&L, peak/bottom flags).
  /// Added 2026-08-05 — previously the whole session (including this) was
  /// discarded on completion, leaving only aggregate counts like
  /// [totalTrades] with no way to show what actually happened per trade.
  final List<StressTestTrade> trades;

  /// Final Psychology Meter marker scores (0.0-1.0), snapshotted at the
  /// moment the session completes — needed by the Session Complete
  /// screen's per-marker verdict widgets. Added 2026-08-06; previously
  /// `TraderPsychologyProfile` was discarded along with the rest of the
  /// session on completion, same gap [trades] fixed for per-trade data.
  final double discipline;
  final double panicResistance;
  final double patience;
  final double strategyAdherence;

  /// True once [panicResistance]/[patience] were ever actually evaluated
  /// (a sell trade resolved, or a catastrophe-survival psychology event
  /// fired) — unlike [discipline], which moves on every trade including
  /// buys, these two only move on a sell or a catastrophe event, so
  /// [totalTrades] alone can't tell "untouched neutral 0.5" apart from a
  /// real score. Distinct from a real, scored 0.5, same convention as
  /// [safetyMarkerHasData].
  final bool panicHasData;
  final bool patienceHasData;

  /// The 5 signals behind [strategyAdherence], snapshotted the same way —
  /// see [StrategySubScores]/computeStrategySubScores in psychology_engine.dart.
  /// Stored as flat doubles rather than the holdings list itself, since
  /// StressTestHolding has no toJson/fromJson yet and these are already
  /// deterministic from the portfolio at completion time.
  final double strategyDiversification;
  final double strategyConcentration;
  final double strategySector;
  final double strategyEtf;
  final double strategyCashBuffer;

  /// "Safety Marker" — cost-basis-weighted average FS Score (0.0-1.0) of
  /// every holding's FIRST purchase, snapshotted at completion — see
  /// safetyMarkerFor() in psychology_engine.dart. [safetyMarkerHasData]
  /// is false when no holding's FS Score ever resolved (e.g. the test
  /// completed before the async fetch landed, or an empty portfolio) —
  /// distinct from a real, scored 0.
  final double safetyMarker;
  final bool safetyMarkerHasData;

  /// How many epochs of each [MarketScenario] the session went through
  /// before completion, keyed by [MarketScenario.name] — snapshotted from
  /// [StressTestSession.epochHistory] the same way [trades] is, since the
  /// live session itself is wiped on completion. Added 2026-08-08 for the
  /// Trade Breakdown detail screen's "Scenarios Experienced" card; absent
  /// (empty map) for verdicts archived before this field existed.
  final Map<String, int> scenarioCounts;

  /// Mark-to-market P&L for every symbol STILL HELD at completion —
  /// `(finalPrice - avgCost) * shares`, snapshotted from the live
  /// session's holdings/currentPrices the moment before it's wiped (same
  /// reason [scenarioCounts] exists — this data doesn't survive archiving
  /// otherwise). The Companies card adds this to a symbol's realized P&L
  /// (summed from [trades]) so a never-sold holding shows its real gain/
  /// loss "as if sold at test end" instead of a misleading $0. Added
  /// 2026-08-08; absent (empty map) for verdicts archived before this
  /// field existed.
  final Map<String, double> unrealizedPnlBySymbol;

  /// True if this session was slot #2/#3 (a premium-only "extra" slot,
  /// see stress_test_engine.dart's isStressTestSlotFrozen) at the moment
  /// it completed — snapshotted here because slot position can no longer
  /// be computed once the live session is wiped from state on archival.
  /// Drives the "one free look after Premium lapses" verdict gate — see
  /// stress_test_verdict_access_provider.dart. Absent (false) for
  /// verdicts archived before this field existed, which just means no
  /// gate applies to them (same as slot #1 today).
  final bool wasPremiumSlot;

  /// Total simulated dividend payouts credited over the session — snapshot
  /// of [StressTestSession.dividendsReceived] at completion. Absent (0)
  /// for verdicts archived before this field existed.
  final double dividendsReceived;

  /// Number of weekly DCA top-up credits, and their total $ — snapshot of
  /// [StressTestSession.dcaTopUpCount]/[dcaTotalReceived] at completion.
  /// Both 0 for a non-DCA-funded session, or for verdicts archived before
  /// these fields existed.
  final int dcaTopUpCount;
  final double dcaTotalReceived;

  const VerdictArchiveEntry({
    required this.sessionId,
    this.name,
    required this.durationLabel,
    required this.startingCash,
    required this.finalValue,
    required this.pnlPercent,
    required this.totalTrades,
    required this.holdingCount,
    required this.completedAt,
    required this.verdict,
    this.trades = const [],
    this.discipline = 0,
    this.panicResistance = 0,
    this.patience = 0,
    this.panicHasData = false,
    this.patienceHasData = false,
    this.strategyAdherence = 0,
    this.strategyDiversification = 0,
    this.strategyConcentration = 0,
    this.strategySector = 0,
    this.strategyEtf = 0,
    this.strategyCashBuffer = 0,
    this.safetyMarker = 0,
    this.safetyMarkerHasData = false,
    this.scenarioCounts = const {},
    this.unrealizedPnlBySymbol = const {},
    this.wasPremiumSlot = false,
    this.dividendsReceived = 0,
    this.dcaTopUpCount = 0,
    this.dcaTotalReceived = 0,
  });

  Map<String, dynamic> toJson() => {
    'sessionId': sessionId,
    if (name != null) 'name': name,
    'durationLabel': durationLabel,
    'startingCash': startingCash,
    'finalValue': finalValue,
    'pnlPercent': pnlPercent,
    'totalTrades': totalTrades,
    'holdingCount': holdingCount,
    'completedAt': completedAt.toIso8601String(),
    'verdict': verdict.toJson(),
    'trades': trades.map((t) => t.toJson()).toList(),
    'discipline': discipline,
    'panicResistance': panicResistance,
    'patience': patience,
    'panicHasData': panicHasData,
    'patienceHasData': patienceHasData,
    'strategyAdherence': strategyAdherence,
    'strategyDiversification': strategyDiversification,
    'strategyConcentration': strategyConcentration,
    'strategySector': strategySector,
    'strategyEtf': strategyEtf,
    'strategyCashBuffer': strategyCashBuffer,
    'safetyMarker': safetyMarker,
    'safetyMarkerHasData': safetyMarkerHasData,
    'scenarioCounts': scenarioCounts,
    'unrealizedPnlBySymbol': unrealizedPnlBySymbol,
    'wasPremiumSlot': wasPremiumSlot,
    'dividendsReceived': dividendsReceived,
    'dcaTopUpCount': dcaTopUpCount,
    'dcaTotalReceived': dcaTotalReceived,
  };

  factory VerdictArchiveEntry.fromJson(
    Map<String, dynamic> json,
  ) => VerdictArchiveEntry(
    sessionId: json['sessionId'] as String,
    name: json['name'] as String?,
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
    // Absent for verdicts archived before this field existed —
    // backward-compatible empty list, the widget shows a fallback.
    trades:
        (json['trades'] as List<dynamic>?)
            ?.map((t) => StressTestTrade.fromJson(t as Map<String, dynamic>))
            .toList() ??
        const [],
    // Absent for verdicts archived before this field existed — the
    // marker widgets just show 0, same convention as [trades] above.
    discipline: (json['discipline'] as num?)?.toDouble() ?? 0,
    panicResistance: (json['panicResistance'] as num?)?.toDouble() ?? 0,
    patience: (json['patience'] as num?)?.toDouble() ?? 0,
    // Absent for verdicts archived before this field existed — falls back
    // to false, same as a never-scored marker (matches prior behavior for
    // old archives, which is the best available without re-deriving it
    // from a trades list that itself may be absent).
    panicHasData: json['panicHasData'] as bool? ?? false,
    patienceHasData: json['patienceHasData'] as bool? ?? false,
    strategyAdherence: (json['strategyAdherence'] as num?)?.toDouble() ?? 0,
    strategyDiversification:
        (json['strategyDiversification'] as num?)?.toDouble() ?? 0,
    strategyConcentration:
        (json['strategyConcentration'] as num?)?.toDouble() ?? 0,
    strategySector: (json['strategySector'] as num?)?.toDouble() ?? 0,
    strategyEtf: (json['strategyEtf'] as num?)?.toDouble() ?? 0,
    strategyCashBuffer: (json['strategyCashBuffer'] as num?)?.toDouble() ?? 0,
    safetyMarker: (json['safetyMarker'] as num?)?.toDouble() ?? 0,
    safetyMarkerHasData: json['safetyMarkerHasData'] as bool? ?? false,
    // Absent for verdicts archived before this field existed — the
    // Scenarios Experienced card just shows all zeros.
    scenarioCounts:
        (json['scenarioCounts'] as Map<String, dynamic>?)?.map(
          (k, v) => MapEntry(k, v as int),
        ) ??
        const {},
    // Absent for verdicts archived before this field existed — the
    // Companies card falls back to realized-only P&L (still-held
    // positions show $0 instead of a real mark-to-market figure).
    unrealizedPnlBySymbol:
        (json['unrealizedPnlBySymbol'] as Map<String, dynamic>?)?.map(
          (k, v) => MapEntry(k, (v as num).toDouble()),
        ) ??
        const {},
    wasPremiumSlot: json['wasPremiumSlot'] as bool? ?? false,
    dividendsReceived: (json['dividendsReceived'] as num?)?.toDouble() ?? 0,
    dcaTopUpCount: json['dcaTopUpCount'] as int? ?? 0,
    dcaTotalReceived: (json['dcaTotalReceived'] as num?)?.toDouble() ?? 0,
  );

  /// [name] when the user set one, else [fallback] — mirrors
  /// [StressTestSession.displayLabel].
  String displayLabel(String fallback) =>
      (name != null && name!.trim().isNotEmpty) ? name!.trim() : fallback;
}

/// Bridges the 11 GICS sectors ([GicsSector], resolved live from Finnhub
/// where available — see resolveGicsSector in gics_sector_mapper.dart) down
/// to this engine's 5 coarser [AssetSector] buckets used by the GBM drift/
/// volatility matrix (gbm_engine.dart).
const Map<GicsSector, AssetSector> _gicsToAssetSector = {
  GicsSector.technology: AssetSector.techSpeculative,
  GicsSector.communicationServices: AssetSector.techSpeculative,
  GicsSector.healthCare: AssetSector.consumerStaples,
  GicsSector.consumerStaples: AssetSector.consumerStaples,
  GicsSector.utilities: AssetSector.consumerStaples,
  GicsSector.financials: AssetSector.cyclicalConsumer,
  GicsSector.consumerDiscretionary: AssetSector.cyclicalConsumer,
  GicsSector.energy: AssetSector.cyclicalConsumer,
  GicsSector.industrials: AssetSector.cyclicalConsumer,
  GicsSector.materials: AssetSector.cyclicalConsumer,
  GicsSector.realEstate: AssetSector.realEstateREIT,
};

/// Resolves a symbol to its [AssetSector] using the canonical mapping.
///
/// This is the **Single Source of Truth (SSOT)** for sector classification.
/// Both the simulation engine and all analytics widgets read from this
/// function. Prefers the live GICS sector from [resolveGicsSector] (real
/// Finnhub data when the holding has been bought at least once — see
/// SectorRepository) via [_gicsToAssetSector]; falls back to the static
/// per-ticker [_legacyMap] below only for symbols GICS resolution can't
/// classify (e.g. broad-market ETFs, which have no single GICS sector but
/// still need an AssetSector bucket for the GBM matrix).
AssetSector resolveAssetSector(String symbol) {
  final gics = resolveGicsSector(symbol);
  if (gics != null) {
    final bucket = _gicsToAssetSector[gics];
    if (bucket != null) return bucket;
  }
  return _legacyMap[symbol] ?? AssetSector.cyclicalConsumer;
}

/// Static fallback — kept only for symbols [resolveGicsSector] can't
/// classify (mainly broad-market ETFs, which are deliberately excluded
/// from GICS sector mapping but still need an AssetSector for the GBM
/// matrix). Historically this was the sole SSOT; now [resolveGicsSector]
/// (live Finnhub-backed) takes priority — see [resolveAssetSector].
const Map<String, AssetSector> _legacyMap = {
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

/// Reverse mapping from [AssetSector] → representative [MarketSector].
MarketSector marketSectorToAssetSectorReversed(AssetSector a) => switch (a) {
  AssetSector.techSpeculative => MarketSector.technology,
  AssetSector.consumerStaples => MarketSector.consumerStaples,
  AssetSector.cyclicalConsumer => MarketSector.cyclical,
  AssetSector.realEstateREIT => MarketSector.realEstate,
  AssetSector.etfBroadMarket => MarketSector.other,
};
