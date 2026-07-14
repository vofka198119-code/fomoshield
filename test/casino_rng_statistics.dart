// ---------------------------------------------------------------------------
// Casino RNG Statistical Test — 100+ rolls across multiple session seeds
// Replicates _rollScenario + _applyScenarioFatigue from stress_test_engine.dart
//
// Purpose: verify that scenario distribution is not degenerate, and that
// the anti-stuck mechanism (casinoDeclineStreak >= 2 → forced Recovery/Bull)
// prevents 4+ consecutive Bear rolls.
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
}

// ── Fatigue constants (mirrors stress_test_engine.dart) ───────────────

const double fatigueDecay = 0.02;
const double fatigueRecovery = 0.005;
const double fatigueMinWeight = 5.0;
const int minEpochsBetweenCatastrophes = 6;

// ── Casino State (per-session mutable state) ─────────────────────────

class CasinoState {
  final Map<String, double> currentWeights;
  int casinoDeclineStreak = 0;
  int casinoCatastropheCooldown = 0;
  int casinoLastCatastropheEpoch = -999;
  int epochIdx = 0;

  CasinoState() : currentWeights = {} {
    // Init weights from MarketScenario base values
    for (final s in MarketScenario.values) {
      currentWeights[s.name] = s.weight;
    }
  }
}

// ── _rollScenario replica ─────────────────────────────────────────────

MarketScenario rollScenario(CasinoState state, Random rng) {
  // Anti-stuck: after 2+ consecutive Bear → Recovery/Bull/Sideways/Volatility
  if (state.casinoDeclineStreak >= 2) {
    final antiStuckRoll = rng.nextDouble();
    if (antiStuckRoll < 0.30) return MarketScenario.recovery;
    if (antiStuckRoll < 0.60) return MarketScenario.bull;
    if (antiStuckRoll < 0.80) return MarketScenario.sideways;
    return MarketScenario.volatility;
  }

  // Remove hype/speculation from roulette wheel (Block 5 fix)
  final pool = MarketScenario.values
      .where((s) => s != MarketScenario.hype && s != MarketScenario.speculation)
      .toList();

  final List<double> weights = [];
  final allowCatastrophe =
      (state.epochIdx - state.casinoLastCatastropheEpoch) >=
      minEpochsBetweenCatastrophes;

  if (state.casinoCatastropheCooldown > 0 || !allowCatastrophe) {
    pool.removeWhere((s) => s.isCatastrophe);
    for (final s in pool) {
      weights.add(state.currentWeights[s.name] ?? s.weight);
    }
    final catWeight = MarketScenario.values
        .where((s) => s.isCatastrophe)
        .fold(0.0, (a, b) => a + b.weight);
    final toRecovery = catWeight * 0.6;
    final toBull = catWeight - toRecovery;
    final recoveryIdx = pool.indexOf(MarketScenario.recovery);
    final bullIdx = pool.indexOf(MarketScenario.bull);
    if (recoveryIdx >= 0) weights[recoveryIdx] += toRecovery;
    if (bullIdx >= 0) weights[bullIdx] += toBull;
  } else {
    for (final s in pool) {
      weights.add(state.currentWeights[s.name] ?? s.weight);
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

// ── _applyScenarioFatigue replica ─────────────────────────────────────

void applyFatigue(CasinoState state, MarketScenario scenario) {
  if (scenario.isCatastrophe) return;

  final oldW = state.currentWeights[scenario.name] ?? scenario.weight;
  final newW = (oldW - fatigueDecay).clamp(fatigueMinWeight, double.infinity);
  final actualDecay = oldW - newW;
  state.currentWeights[scenario.name] = newW;

  if (actualDecay > 0) {
    final others = state.currentWeights.entries
        .where((e) => e.key != scenario.name)
        .toList();
    final totalOtherW = others.fold(0.0, (a, b) => a + b.value);
    if (totalOtherW > 0) {
      for (final e in others) {
        final share = actualDecay * (e.value / totalOtherW);
        state.currentWeights[e.key] = (state.currentWeights[e.key]! + share)
            .clamp(fatigueMinWeight, double.infinity);
      }
    }
  }

  for (final s in MarketScenario.values) {
    if (s.isCatastrophe || s == scenario) continue;
    final name = s.name;
    final cur = state.currentWeights[name];
    if (cur != null) {
      final base = s.weight;
      if (cur < base) {
        state.currentWeights[name] = (cur + fatigueRecovery).clamp(0, base);
      }
    }
  }
}

// ── Update casino state after roll ────────────────────────────────────

void updateState(CasinoState state, MarketScenario scenario) {
  if (scenario.isCatastrophe) {
    state.casinoLastCatastropheEpoch = state.epochIdx;
    state.casinoCatastropheCooldown = 2;
    state.casinoDeclineStreak = 0;
  } else if (scenario.isDecline) {
    state.casinoDeclineStreak++;
  } else {
    state.casinoDeclineStreak = 0;
    if (state.casinoCatastropheCooldown > 0) {
      state.casinoCatastropheCooldown--;
    }
  }
  state.epochIdx++;
}

// ── Main ──────────────────────────────────────────────────────────────

void main() {
  const rollsPerSession = 200;
  const sessionCount = 10;
  final seeds = List.generate(sessionCount, (i) => i * 777 + 42);

  print('═══════════════════════════════════════════');
  print('  Casino RNG Statistics');
  print('  $rollsPerSession rolls × $sessionCount sessions');
  print('═══════════════════════════════════════════\n');

  final globalCounts = <MarketScenario, int>{};
  for (final s in MarketScenario.values) {
    globalCounts[s] = 0;
  }

  int maxConsecutiveBear = 0;
  int sessionsWith4PlusBear = 0;

  for (int si = 0; si < sessionCount; si++) {
    final seed = seeds[si];
    final rng = Random(seed);
    final state = CasinoState();
    final history = <MarketScenario>[];

    for (int r = 0; r < rollsPerSession; r++) {
      final scenario = rollScenario(state, rng);
      applyFatigue(state, scenario);
      updateState(state, scenario);
      history.add(scenario);
      globalCounts[scenario] = globalCounts[scenario]! + 1;
    }

    // ── Per-session analysis ──
    int localConsecutiveBear = 0;
    int localMaxConsecutive = 0;
    for (final s in history) {
      if (s == MarketScenario.bear) {
        localConsecutiveBear++;
        if (localConsecutiveBear > localMaxConsecutive) {
          localMaxConsecutive = localConsecutiveBear;
        }
      } else {
        localConsecutiveBear = 0;
      }
    }
    if (localMaxConsecutive > maxConsecutiveBear) {
      maxConsecutiveBear = localMaxConsecutive;
    }
    if (localMaxConsecutive >= 4) {
      sessionsWith4PlusBear++;
    }

    // Per-session distribution
    final localCounts = <MarketScenario, int>{};
    for (final s in history) {
      localCounts[s] = (localCounts[s] ?? 0) + 1;
    }
    print('Session seed=$seed (maxBearStreak=$localMaxConsecutive):');
    for (final s in MarketScenario.values.where(
      (s) => s != MarketScenario.hype && s != MarketScenario.speculation,
    )) {
      final pct = (localCounts[s] ?? 0) / rollsPerSession * 100;
      print(
        '  ${s.name.padRight(12)} ${(localCounts[s] ?? 0).toString().padLeft(4)}  (${pct.toStringAsFixed(1)}%)',
      );
    }
    print('');
  }

  // ── Global distribution ──
  final total = rollsPerSession * sessionCount;
  print('═══════════════════════════════════════════');
  print('  GLOBAL DISTRIBUTION ($total rolls)');
  print('═══════════════════════════════════════════');
  for (final s in MarketScenario.values.where(
    (s) => s != MarketScenario.hype && s != MarketScenario.speculation,
  )) {
    final pct = globalCounts[s]! / total * 100;
    final bar = '█' * (globalCounts[s]! ~/ (total ~/ 50));
    print(
      '  ${s.name.padRight(12)} ${globalCounts[s].toString().padLeft(5)}  (${pct.toStringAsFixed(1)}%) $bar',
    );
  }

  print('\n───────────────────────────────────────────');
  print('  Max consecutive Bear across all sessions: $maxConsecutiveBear');
  print(
    '  Sessions with 4+ consecutive Bear: $sessionsWith4PlusBear / $sessionCount',
  );
  if (sessionsWith4PlusBear > 0) {
    print('  ⚠ WARNING: Anti-stuck mechanism may have a gap!');
  } else {
    print('  ✅ Anti-stuck mechanism working correctly');
  }
  print('═══════════════════════════════════════════');
}
