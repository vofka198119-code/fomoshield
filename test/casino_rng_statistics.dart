// ---------------------------------------------------------------------------
// Casino RNG Statistical Test — mirrors the CURRENT _rollScenario +
// _applyScenarioFatigue from casino_epochs.dart (updated 2026-07-29 after a
// device-observed 9-epoch weekly run landed 6/9 Bear: bear, volatility,
// bear, bull, bear, bear, bull, bear, bear).
//
// Two things are checked against each other:
//   1. CONTINUOUS  — one Random stream advancing across all epochs (what a
//      "normal" RNG usage pattern looks like).
//   2. PER-EPOCH RESEED — production's actual scheme: every single roll
//      uses a freshly constructed Random(Object.hash(simulationSeed,
//      epochIndex)), one draw, then discarded. This survives app restarts
//      deterministically (see casino_epochs.dart's _catchUp comment) but is
//      a non-standard PRNG usage pattern — this script exists to check
//      whether it introduces a measurable skew that the continuous stream
//      wouldn't show.
//
// If both modes land statistically indistinguishable distributions, the
// per-epoch reseed scheme is cleared and the user's 6/9 Bear run was small-
// sample variance. If PER-EPOCH shows a persistent skew (globally or at
// specific epoch indices), that's the bug.
// ---------------------------------------------------------------------------
import 'dart:math';

// ── MarketScenario enum (mirrors stress_test_models.dart) ──────────────

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
  bool get isPerCompanyEvent =>
      this == MarketScenario.hype || this == MarketScenario.speculation;
  bool get isScriptedRecovery => this == MarketScenario.recovery;
}

// ── Constants (mirrors casino_epochs.dart) ─────────────────────────────

const double fatigueDecay = 0.02;
const double fatigueRecovery = 0.005;
const double fatigueMinWeight = 5.0;
const double bullRepeatTargetProb = 0.20;
const int minEpochsBetweenCatastrophes = 6;

// ── Casino State (per-session mutable state) ───────────────────────────

class CasinoState {
  final Map<String, double> currentWeights;
  int casinoDeclineStreak = 0;
  int casinoCatastropheCooldown = 0;
  int casinoLastCatastropheEpoch = -999;
  MarketScenario? lastScenario;

  CasinoState() : currentWeights = {} {
    for (final s in MarketScenario.values) {
      currentWeights[s.name] = s.weight;
    }
  }
}

// ── _rollScenario replica (exact port of casino_epochs.dart:32-118) ────

MarketScenario rollScenario(CasinoState state, int epochIdx, Random rng) {
  final lastCatIdx = state.casinoLastCatastropheEpoch;

  final epochsSinceLastCatastrophe = epochIdx - lastCatIdx;
  if (epochsSinceLastCatastrophe >= 1 && epochsSinceLastCatastrophe <= 2) {
    return MarketScenario.recovery;
  }

  if (state.casinoDeclineStreak >= 2) {
    final antiStuckRoll = rng.nextDouble();
    if (antiStuckRoll < 0.40) return MarketScenario.bull;
    if (antiStuckRoll < 0.70) return MarketScenario.sideways;
    return MarketScenario.volatility;
  }

  final pool = MarketScenario.values
      .where((s) => !s.isPerCompanyEvent && !s.isScriptedRecovery)
      .toList();
  final List<double> weights = [];
  final allowCatastrophe =
      (epochIdx - lastCatIdx) >= minEpochsBetweenCatastrophes;

  if (state.casinoCatastropheCooldown > 0 || !allowCatastrophe) {
    pool.removeWhere((s) => s.isCatastrophe);
  }
  for (final s in pool) {
    weights.add(state.currentWeights[s.name] ?? s.weight);
  }

  if (state.lastScenario == MarketScenario.bull) {
    final bullIdx = pool.indexOf(MarketScenario.bull);
    if (bullIdx != -1) {
      final othersSum = weights.fold(0.0, (a, b) => a + b) - weights[bullIdx];
      weights[bullIdx] =
          othersSum * (bullRepeatTargetProb / (1 - bullRepeatTargetProb));
    }
  }

  final totalWeight = weights.fold(0.0, (a, b) => a + b);
  double roll = rng.nextDouble() * totalWeight;
  for (int i = 0; i < pool.length; i++) {
    roll -= weights[i];
    if (roll < 0) return pool[i];
  }
  return MarketScenario.bull;
}

// ── _applyScenarioFatigue replica (exact port of casino_epochs.dart:120-182) ──

void applyFatigue(CasinoState state, MarketScenario scenario) {
  if (scenario.isCatastrophe || scenario.isScriptedRecovery) return;
  final currentWeights = state.currentWeights;

  currentWeights.remove(MarketScenario.hype.name);
  currentWeights.remove(MarketScenario.speculation.name);
  currentWeights.remove(MarketScenario.recovery.name);

  final double oldW = currentWeights[scenario.name] ?? scenario.weight;
  final double newW = (oldW - fatigueDecay).clamp(
    fatigueMinWeight,
    double.infinity,
  );
  final double actualDecay = oldW - newW;
  currentWeights[scenario.name] = newW;

  if (actualDecay > 0) {
    final others = currentWeights.entries
        .where((e) => e.key != scenario.name)
        .toList();
    final double totalOtherW = others.fold(0.0, (a, b) => a + b.value);
    if (totalOtherW > 0) {
      for (final e in others) {
        final double share = actualDecay * (e.value / totalOtherW);
        currentWeights[e.key] = (currentWeights[e.key]! + share).clamp(
          fatigueMinWeight,
          double.infinity,
        );
      }
    }
  }

  for (final s in MarketScenario.values) {
    if (s.isCatastrophe || s.isPerCompanyEvent || s.isScriptedRecovery ||
        s == scenario) {
      continue;
    }
    final String name = s.name;
    if (currentWeights.containsKey(name)) {
      final double cur = currentWeights[name]!;
      final double base = s.weight;
      if (cur < base) {
        currentWeights[name] = (cur + fatigueRecovery).clamp(0, base);
      }
    }
  }
}

// ── Update casino state after roll (mirrors _catchUp's bookkeeping) ─────

void updateState(CasinoState state, MarketScenario scenario, int epochIdx) {
  if (scenario.isCatastrophe) {
    state.casinoCatastropheCooldown = 2;
    state.casinoLastCatastropheEpoch = epochIdx;
    state.casinoDeclineStreak = 0;
  } else if (scenario.isDecline) {
    state.casinoDeclineStreak++;
  } else {
    state.casinoDeclineStreak = 0;
    if (state.casinoCatastropheCooldown > 0) {
      state.casinoCatastropheCooldown--;
    }
  }
  state.lastScenario = scenario;
}

// ── Reportable scenarios (excludes hype/speculation — never rolled) ────

const reportable = [
  MarketScenario.bull,
  MarketScenario.sideways,
  MarketScenario.bear,
  MarketScenario.volatility,
  MarketScenario.recovery,
  MarketScenario.blackSwan,
  MarketScenario.crash,
];

class RunResult {
  final List<MarketScenario> history;
  RunResult(this.history);
}

/// Simulate one session of [epochs] rolls.
/// [perEpochReseed]=true replicates production exactly: a fresh
/// Random(Object.hash(seed, epochIndex)) per roll.
/// [perEpochReseed]=false uses one continuously-advancing Random(seed)
/// stream for comparison.
RunResult simulateSession(int seed, int epochs, {required bool perEpochReseed}) {
  final state = CasinoState();
  final history = <MarketScenario>[];
  final continuousRng = Random(seed);

  for (int i = 0; i < epochs; i++) {
    final rng = perEpochReseed
        ? Random(Object.hash(seed, i))
        : continuousRng;
    final scenario = rollScenario(state, i, rng);
    applyFatigue(state, scenario);
    updateState(state, scenario, i);
    history.add(scenario);
  }
  return RunResult(history);
}

class Stats {
  final Map<MarketScenario, int> counts = {for (final s in reportable) s: 0};
  int total = 0;
  int maxConsecutiveBear = 0;
  int sessionsWith4PlusBear = 0;
  int sessionsWith5of9Bear = 0; // sessions replicating user's observation
  // Per-epoch-index distribution: epochIdx -> scenario -> count
  final Map<int, Map<MarketScenario, int>> byEpochIndex = {};

  void record(RunResult r) {
    int localStreak = 0, localMax = 0;
    for (int i = 0; i < r.history.length; i++) {
      final s = r.history[i];
      counts[s] = (counts[s] ?? 0) + 1;
      total++;
      byEpochIndex.putIfAbsent(i, () => {for (final x in reportable) x: 0});
      byEpochIndex[i]![s] = (byEpochIndex[i]![s] ?? 0) + 1;
      if (s == MarketScenario.bear) {
        localStreak++;
        if (localStreak > localMax) localMax = localStreak;
      } else {
        localStreak = 0;
      }
    }
    if (localMax > maxConsecutiveBear) maxConsecutiveBear = localMax;
    if (localMax >= 4) sessionsWith4PlusBear++;
    if (r.history.length >= 9) {
      final firstNine = r.history.take(9);
      final bearCount = firstNine.where((s) => s == MarketScenario.bear).length;
      if (bearCount >= 5) sessionsWith5of9Bear++;
    }
  }

  void printGlobal(String label, int sessionCount) {
    print('─── $label ───');
    for (final s in reportable) {
      final pct = counts[s]! / total * 100;
      final bar = '#' * (counts[s]! * 60 ~/ total);
      print('  ${s.name.padRight(12)} ${counts[s].toString().padLeft(6)}  '
          '(${pct.toStringAsFixed(1)}%) $bar');
    }
    print('  Max consecutive Bear (any session): $maxConsecutiveBear');
    print('  Sessions with 4+ consecutive Bear:  $sessionsWith4PlusBear / $sessionCount');
    print('  Sessions with 5+/9 Bear (user\'s observation replicated): '
        '$sessionsWith5of9Bear / $sessionCount');
    print('');
  }

  /// Flags epoch indices whose Bear share deviates from the global Bear
  /// share by more than [thresholdPct] percentage points — would indicate
  /// the per-epoch reseed scheme (Object.hash(seed, i)) is biased for
  /// specific values of i, independent of the session seed.
  void printEpochIndexSkew(double thresholdPct) {
    final globalBearPct = counts[MarketScenario.bear]! / total * 100;
    print('─── Bear share by epoch index (global bear avg: '
        '${globalBearPct.toStringAsFixed(1)}%) ───');
    final indices = byEpochIndex.keys.toList()..sort();
    bool anyFlag = false;
    for (final idx in indices) {
      final m = byEpochIndex[idx]!;
      final t = m.values.fold(0, (a, b) => a + b);
      final bearPct = (m[MarketScenario.bear] ?? 0) / t * 100;
      final flag = (bearPct - globalBearPct).abs() > thresholdPct;
      if (flag) anyFlag = true;
      print('  epoch[$idx]  bear=${bearPct.toStringAsFixed(1)}%'
          '${flag ? "  <-- FLAG (+/-${thresholdPct.toStringAsFixed(0)}pp)" : ""}');
    }
    if (!anyFlag) {
      print('  No epoch index deviates more than ${thresholdPct.toStringAsFixed(0)}pp '
          'from the global Bear average.');
    }
    print('');
  }
}

void main() {
  const sessionCount = 5000;
  const epochsPerSession = 14; // week1 test: 12h roll interval over 7 days

  final seeds = List.generate(sessionCount, (i) => (i * 999331 + 12345) % 99999999 + 1);

  print('===============================================================');
  print('  Casino RNG Statistics — $sessionCount sessions x $epochsPerSession epochs');
  print('===============================================================\n');

  final continuousStats = Stats();
  final perEpochStats = Stats();

  for (final seed in seeds) {
    continuousStats.record(
      simulateSession(seed, epochsPerSession, perEpochReseed: false),
    );
    perEpochStats.record(
      simulateSession(seed, epochsPerSession, perEpochReseed: true),
    );
  }

  continuousStats.printGlobal(
    'CONTINUOUS RNG STREAM (baseline, not what production uses)',
    sessionCount,
  );
  perEpochStats.printGlobal(
    'PER-EPOCH RESEED: Random(Object.hash(seed, epochIndex)) — PRODUCTION SCHEME',
    sessionCount,
  );

  perEpochStats.printEpochIndexSkew(3.0);

  print('===============================================================');
  print('If PER-EPOCH RESEED\'s global % and 5+/9-Bear rate roughly match');
  print('CONTINUOUS\'s, the reseed scheme is not the cause: the observed');
  print('9-epoch run (bear x6) was an unlucky draw, not a systemic bias.');
  print('===============================================================');
}
