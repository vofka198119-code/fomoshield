// ignore_for_file: invalid_use_of_protected_member, invalid_use_of_visible_for_testing_member
// `state` is StateNotifier's own protected/visibleForTesting field. These
// methods used to be declared directly inside StressTestNotifier's class
// body, where that access is unrestricted; moving them into an `extension
// on StressTestNotifier` (required to split a single class across files
// without renaming any private members — see Задание 1 report) makes the
// analyzer treat the access as external, even though it's the same library
// and the same class instance. No runtime behavior is affected.
part of 'stress_test_engine.dart';

// ---------------------------------------------------------------------------
// Casino Epochs — scenario roulette, scenario fatigue, wall-clock epoch
// rolling/recording, catch-up on app resume, and anti-stuck protection.
// ---------------------------------------------------------------------------
// Extracted verbatim from stress_test_engine.dart as part of the mechanism
// split (Задание 1). No logic was changed during this move. Methods are
// declared as an `extension` on [StressTestNotifier] inside this `part of`
// file — same library as stress_test_engine.dart, so all private field/
// method access (state, _sessionRandom, _completeTest, _simulateCurrentPrices,
// etc.) resolves exactly as before the split.
// ---------------------------------------------------------------------------

// ── Scenario Fatigue (dynamic roulette weights) ────────────────────
const double _fatigueDecay = 0.02; // 2% штраф активному сценарию
const double _fatigueRecovery = 0.005; // 0.5% восстановление за шаг
const double _fatigueMinWeight = 5.0; // 5% от total=100 — пол стандартных

extension CasinoEpochsEngine on StressTestNotifier {
  /// Roll a market scenario using session casino state.
  /// Reads catastrophe cooldown, decline streak from the session itself.
  MarketScenario _rollScenario(
    StressTestSession session, {
    required Random rng,
  }) {
    // Anti-stuck Bear correction: after 2+ consecutive Bear declines,
    // hard-redirect to Recovery/Bull/Sideways/Volatility — prevents death loops.
    if (session.casinoDeclineStreak >= 2) {
      final antiStuckRoll = rng.nextDouble();
      if (antiStuckRoll < 0.30) return MarketScenario.recovery;
      if (antiStuckRoll < 0.60) return MarketScenario.bull;
      if (antiStuckRoll < 0.80) return MarketScenario.sideways;
      return MarketScenario.volatility;
    }

    // ── Block 5 fix: hype/speculation are now per-company events, ──
    // NOT global macro scenarios. Remove them from the roulette wheel.
    final pool = MarketScenario.values
        .where(
          (s) => s != MarketScenario.hype && s != MarketScenario.speculation,
        )
        .toList();
    final List<double> weights = [];
    final currentWeights = session.currentWeights;
    final cooldown = session.casinoCatastropheCooldown;
    final epochIdx = session.epochHistory.length;
    final lastCatIdx = session.casinoLastCatastropheEpoch;
    const minEpochsBetweenCatastrophes = 6;
    final allowCatastrophe =
        (epochIdx - lastCatIdx) >= minEpochsBetweenCatastrophes;

    if (cooldown > 0 || !allowCatastrophe) {
      pool.removeWhere((s) => s.isCatastrophe);
      for (final s in pool) {
        weights.add(currentWeights[s.name] ?? s.weight.toDouble());
      }
      final catWeight = MarketScenario.values
          .where((s) => s.isCatastrophe)
          .fold<double>(0, (a, b) => a + b.weight);
      final toRecovery = catWeight * 0.6;
      final toBull = catWeight - toRecovery;
      final recoveryIdx = pool.indexOf(MarketScenario.recovery);
      final bullIdx = pool.indexOf(MarketScenario.bull);
      if (recoveryIdx >= 0) weights[recoveryIdx] += toRecovery;
      if (bullIdx >= 0) weights[bullIdx] += toBull;
    } else {
      for (final s in pool) {
        weights.add(currentWeights[s.name] ?? s.weight.toDouble());
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

  /// Apply Scenario Fatigue after a non-catastrophe scenario is rolled.
  void _applyScenarioFatigue(
    StressTestSession session,
    MarketScenario scenario,
  ) {
    if (scenario.isCatastrophe) return;
    final currentWeights = session.currentWeights;

    final double oldW =
        currentWeights[scenario.name] ?? scenario.weight.toDouble();
    final double newW = (oldW - _fatigueDecay).clamp(
      _fatigueMinWeight,
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
            _fatigueMinWeight,
            double.infinity,
          );
        }
      }
    }

    for (final s in MarketScenario.values) {
      if (s.isCatastrophe || s == scenario) continue;
      final String name = s.name;
      if (currentWeights.containsKey(name)) {
        final double cur = currentWeights[name]!;
        final double base = s.weight.toDouble();
        if (cur < base) {
          currentWeights[name] = (cur + _fatigueRecovery).clamp(0, base);
        }
      }
    }
  }

  /// How long between casino scenario rolls for a given test duration.
  Duration _getRollInterval(TestDuration duration) {
    return duration.rollInterval;
  }

  // ── Catch-up on app resume ───────────────────────────────────────

  /// Run catch-up for all active sessions using the new pipeline.
  void _catchUpAll() {
    for (int i = 0; i < state.length; i++) {
      if (state[i].status == StressTestStatus.active) {
        _catchUp(i);
      }
    }
  }

  void _catchUp(int idx) {
    final session = state[idx];
    final now = DateTime.now();

    // Check if test should be completed (timer expired — time-limited modes)
    if (session.duration.isTimeLimited) {
      final limit =
          session.duration == TestDuration.custom &&
              session.customDurationDays != null
          ? Duration(days: session.customDurationDays!)
          : session.duration.totalDuration!;
      final elapsed = now.difference(session.startedAt!);
      if (elapsed >= limit) {
        _completeTest(idx);
        return;
      }
    }

    // ── Pipeline catch-up: compute missed roll count ──────────
    final lastRoll = session.lastEpochRollAt ?? session.startedAt ?? now;
    final rollInterval = _getRollInterval(session.duration);
    final elapsedSinceLastRoll = now.difference(lastRoll);
    final missedRolls =
        (elapsedSinceLastRoll.inMilliseconds / rollInterval.inMilliseconds)
            .floor()
            .clamp(0, 30); // cap at 30 to avoid massive lag

    // If no epoch rolls missed, still catch up on granular ticks —
    // otherwise a freshly bought holding (or any position refreshed less
    // often than every _tickSeconds) sits frozen at its entry price until
    // enough wall-clock time passes to cross an epoch boundary.
    if (missedRolls == 0) {
      final lastTick =
          session.lastTickTimestamp ??
          session.lastEpochRollAt ??
          session.startedAt ??
          now;
      final missedSeconds = now.difference(lastTick).inSeconds;
      final missedTicks = (missedSeconds / _tickSeconds).floor().clamp(
        1,
        _maxCatchUpTicks,
      );
      _simulateCurrentPrices(idx, ticks: missedTicks);
      return;
    }

    // ── DIAGNOSTIC DUMP: session state before catch-up ──────────
    // ignore: avoid_print
    print('[CATCHUP-BEFORE] session=${session.id}');
    // ignore: avoid_print
    print('  epochHistory.length=${session.epochHistory.length}');
    // ignore: avoid_print
    print(
      '  epochHistory=${session.epochHistory.map((e) => "E${e.index}:${e.scenario.name}").toList()}',
    );
    // ignore: avoid_print
    print('  lastEpochRollAt=${session.lastEpochRollAt}');
    // ignore: avoid_print
    print('  casinoLastCatastropheEpoch=${session.casinoLastCatastropheEpoch}');
    // ignore: avoid_print
    print('  casinoCatastropheCooldown=${session.casinoCatastropheCooldown}');
    // ignore: avoid_print
    print('  casinoDeclineStreak=${session.casinoDeclineStreak}');
    // ignore: avoid_print
    print('  basePrices=${session.basePrices}');
    // ignore: avoid_print
    print('  currentPrices=${session.currentPrices}');
    // ignore: avoid_print
    print(
      '  specEvents=${session.specEvents.map((e) => "${e.symbol}:${e.type.name} tick=${e.currentTick}/${e.rampDurationTicks} peak=${e.peakAmplitude}").toList()}',
    );
    // ignore: avoid_print
    print('  lastSpecEventCheckAt=${session.lastSpecEventCheckAt}');
    // ignore: avoid_print
    print('  missedRolls=$missedRolls');

    // Apply missed macro-step rolls
    final rng = _sessionRandom[session.id] ?? Random(session.simulationSeed);
    _sessionRandom[session.id] = rng;

    // Capture base length BEFORE the loop — Bug #1 fix:
    // session.epochHistory.length grows each iteration (we append records),
    // so `length + r` double-counts. Use fixed baseLength + r instead.
    final baseLength = session.epochHistory.length;

    for (int r = 0; r < missedRolls; r++) {
      final scenario = _rollScenario(session, rng: rng);
      _applyScenarioFatigue(session, scenario);

      // Update casino state
      if (scenario.isCatastrophe) {
        session.casinoCatastropheCount++;
        session.casinoLastCatastropheEpoch = baseLength + r;
        session.casinoCatastropheCooldown = 2;
        session.casinoDeclineStreak = 0;
      } else if (scenario.isDecline) {
        session.casinoDeclineStreak++;
      } else {
        session.casinoDeclineStreak = 0;
        if (session.casinoCatastropheCooldown > 0) {
          session.casinoCatastropheCooldown--;
        }
      }

      // ── Bug #2 fix: close previous active epoch BEFORE adding new one ──
      // In normal flow, _recordEpochTransition() closes the active epoch
      // then opens a new one. _catchUp() was skipping the close step,
      // leaving multiple epochs with endedAt=null, which breaks
      // _getCurrentEpoch() (returns first active, not current).
      final history = session.epochHistory;
      for (int i = history.length - 1; i >= 0; i--) {
        if (history[i].isActive) {
          final closeTime = lastRoll.add(rollInterval * (r + 1));
          final updated = [...history];
          updated[i] = EpochRecord(
            index: history[i].index,
            scenario: history[i].scenario,
            startedAt: history[i].startedAt,
            endedAt: closeTime,
          );
          session.epochHistory = updated;
          break;
        }
      }

      // Start new epoch with correct index (baseLength + r, not length + r)
      final rollTime = lastRoll.add(rollInterval * (r + 1));
      session.epochHistory = [
        ...session.epochHistory,
        EpochRecord(
          index: baseLength + r,
          scenario: scenario,
          startedAt: rollTime,
        ),
      ];
    }

    session.lastEpochRollAt = lastRoll.add(rollInterval * missedRolls);

    // ── Granular time-stepping: simulate each missed 20s tick ──
    // Instead of one mega-tick (which makes GBM explode against the clamp
    // ceiling), we break the wall-clock gap into standard 20-second quanta
    // and simulate each tick separately. This produces realistic, smooth
    // price trajectories instead of instant clamp hits.
    final lastTick =
        session.lastTickTimestamp ??
        session.lastEpochRollAt ??
        session.startedAt ??
        now;
    final missedSeconds = now.difference(lastTick).inSeconds;
    final missedTicks = (missedSeconds / _tickSeconds).floor().clamp(
      1,
      _maxCatchUpTicks,
    );
    // ignore: avoid_print
    print(
      '[CATCHUP-TICKS] missedSeconds=$missedSeconds missedTicks=$missedTicks',
    );
    _simulateCurrentPrices(idx, ticks: missedTicks);

    // ── DIAGNOSTIC DUMP: session state after catch-up ──────────
    // ignore: avoid_print
    print('[CATCHUP-AFTER] session=${session.id}');
    // ignore: avoid_print
    print(
      '  epochHistory=${session.epochHistory.map((e) => "E${e.index}:${e.scenario.name}").toList()}',
    );
    // ignore: avoid_print
    print('  currentPrices=${session.currentPrices}');
    // ignore: avoid_print
    print(
      '  specEvents=${session.specEvents.map((e) => "${e.symbol}:${e.type.name} tick=${e.currentTick}/${e.rampDurationTicks}").toList()}',
    );
  }

  // ── Block 6: Casino Wall-Clock Epoch Recording ─────────────────────
  // Instead of knowing all epochs upfront, the session records epoch
  // transitions as they happen on wall-clock. Catch-up on re-entry
  // fills in any gaps.

  /// Test-only: force-roll exactly one casino epoch, bypassing wall-clock.
  /// Replicates the epoch-roll + casino-state logic from
  /// [_simulateCurrentPrices] without requiring real time to pass.
  @visibleForTesting
  void debugForceEpochRoll(String sessionId) {
    final idx = state.indexWhere((s) => s.id == sessionId);
    if (idx == -1) return;
    final session = state[idx];
    if (session.status != StressTestStatus.active) return;

    final now = DateTime.now();
    final rng = _sessionRandom[session.id] ?? Random(session.simulationSeed);
    _sessionRandom[session.id] = rng;

    final newScenario = _rollScenario(session, rng: rng);
    _applyScenarioFatigue(session, newScenario);

    // ── Casino state update (mirrors _simulateCurrentPrices / _catchUp) ──
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

    // Close previous epoch, open new one.
    _recordEpochTransition(session, newScenario, now);

    // Trigger Riverpod state notification (mutations were in-place on session).
    state = [...state];
  }

  /// Record an epoch transition in the session's [epochHistory].
  /// Called once per epoch per tick loop.
  void _recordEpochTransition(
    StressTestSession session,
    MarketScenario newScenario,
    DateTime now,
  ) {
    // Close the currently active epoch (if any)
    final history = session.epochHistory;
    for (int i = history.length - 1; i >= 0; i--) {
      if (history[i].isActive) {
        final closed = EpochRecord(
          index: history[i].index,
          scenario: history[i].scenario,
          startedAt: history[i].startedAt,
          endedAt: now,
        );
        final updated = [...history];
        updated[i] = closed;
        session.epochHistory = updated;
        break;
      }
    }

    // Start new epoch
    final newIndex = history.lastOrNull != null ? history.last.index + 1 : 0;
    session.epochHistory = [
      ...session.epochHistory,
      EpochRecord(index: newIndex, scenario: newScenario, startedAt: now),
    ];
    session.lastEpochRollAt = now;
  }

  /// Find the active (current) epoch from epoch history.
  /// Returns the EpochRecord whose endedAt is null (active),
  /// or the last record if all are closed.
  EpochRecord? _getCurrentEpoch(StressTestSession session) {
    final history = session.epochHistory;
    if (history.isEmpty) return null;
    // Find the active epoch (endedAt == null)
    for (final e in history) {
      if (e.isActive) return e;
    }
    // All closed — return the last one
    return history.last;
  }
}
