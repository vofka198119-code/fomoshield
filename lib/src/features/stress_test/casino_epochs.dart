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
    final epochIdx = session.epochHistory.length;
    final lastCatIdx = session.casinoLastCatastropheEpoch;

    // ── Scripted post-catastrophe recovery ──────────────────────────
    // Recovery is not weighted-random: real markets recover after a
    // crash, not out of nowhere and never right after a Bull run. Force
    // it for exactly the 2 epochs immediately following a blackSwan/
    // crash — bypasses the roulette AND the anti-stuck-bear redirect
    // below entirely, so recovery is unreachable any other way. See
    // MarketScenario.isScriptedRecovery.
    final epochsSinceLastCatastrophe = epochIdx - lastCatIdx;
    if (epochsSinceLastCatastrophe >= 1 && epochsSinceLastCatastrophe <= 2) {
      return MarketScenario.recovery;
    }

    // Anti-stuck Bear correction: after 2+ consecutive Bear declines,
    // hard-redirect to Bull/Sideways/Volatility — prevents death loops.
    // Recovery is deliberately NOT one of the options here (see above).
    if (session.casinoDeclineStreak >= 2) {
      final antiStuckRoll = rng.nextDouble();
      if (antiStuckRoll < 0.40) return MarketScenario.bull;
      if (antiStuckRoll < 0.70) return MarketScenario.sideways;
      return MarketScenario.volatility;
    }

    // ── Block 5 fix: hype/speculation are per-company events, NOT ──
    // global macro scenarios — remove them from the roulette wheel.
    // Recovery is also removed: it's scripted-only (see above), never
    // part of the weighted roll.
    final pool = MarketScenario.values
        .where((s) => !s.isPerCompanyEvent && !s.isScriptedRecovery)
        .toList();
    final List<double> weights = [];
    final currentWeights = session.currentWeights;
    final cooldown = session.casinoCatastropheCooldown;
    const minEpochsBetweenCatastrophes = 6;
    final allowCatastrophe =
        (epochIdx - lastCatIdx) >= minEpochsBetweenCatastrophes;

    if (cooldown > 0 || !allowCatastrophe) {
      // No manual weight redirect needed: removing catastrophes from
      // `pool` without re-injecting their weight elsewhere lets the
      // remaining pool members absorb that share proportionally on
      // their own (recovery used to get a hand-picked 60% cut here —
      // it can't anymore, since it's scripted-only now).
      pool.removeWhere((s) => s.isCatastrophe);
      for (final s in pool) {
        weights.add(currentWeights[s.name] ?? s.weight.toDouble());
      }
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
    // Catastrophes and scripted recovery never participate in fatigue —
    // recovery is forced (not weighted-random), so it must never decay,
    // absorb redistribution, or hold epoch weight. See
    // MarketScenario.isScriptedRecovery.
    if (scenario.isCatastrophe || scenario.isScriptedRecovery) return;
    final currentWeights = session.currentWeights;

    // Self-heal sessions persisted before hype/speculation/recovery were
    // isolated from epoch weight bookkeeping — none of them can ever be
    // rolled by the roulette (excluded from `pool` above), so any
    // lingering entry is dead weight that used to silently absorb
    // redistribution/recovery below forever.
    currentWeights.remove(MarketScenario.hype.name);
    currentWeights.remove(MarketScenario.speculation.name);
    currentWeights.remove(MarketScenario.recovery.name);

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
      if (s.isCatastrophe ||
          s.isPerCompanyEvent ||
          s.isScriptedRecovery ||
          s == scenario) {
        continue;
      }
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
    // Not `final` — the fair-per-epoch-tick-budget loop below calls
    // _simulateCurrentPrices mid-loop, which rebuilds `state[idx]` as a
    // brand-new StressTestSession (immutable-update pattern), so this
    // reference must be re-synced to `state[idx]` after each such call or
    // every subsequent in-place mutation here (closing the next epoch,
    // etc.) would land on an orphaned object that state[idx] no longer
    // points to and silently vanish.
    var session = state[idx];
    final now = DateTime.now();

    // Check if test should be completed (timer expired — time-limited modes)
    // `session.duration.isTimeLimited` is an enum-level property and knows
    // nothing about the session's own `customDurationDays` — it's `false`
    // for TestDuration.custom by definition (see totalDuration's doc comment
    // in stress_test_models.dart), so a Custom test needs its own check
    // here rather than being gated behind `isTimeLimited`.
    final isCustomWithLimit =
        session.duration == TestDuration.custom &&
        session.customDurationDays != null;
    if (session.duration.isTimeLimited || isCustomWithLimit) {
      final limit = isCustomWithLimit
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
    print('  missedRolls=$missedRolls');

    // Apply missed macro-step rolls
    final rng = _sessionRandom[session.id] ?? Random(session.simulationSeed);
    _sessionRandom[session.id] = rng;

    // Capture base length BEFORE the loop — Bug #1 fix:
    // session.epochHistory.length grows each iteration (we append records),
    // so `length + r` double-counts. Use fixed baseLength + r instead.
    final baseLength = session.epochHistory.length;

    // ── Fair per-epoch tick budget (device-test bug, 2026-07-20) ──────
    // Confirmed on-device: epochHistory correctly recorded every missed
    // epoch (Bull, Crash, BlackSwan, whatever the roulette produced), but
    // ALL of the catch-up's price simulation used to happen in ONE call
    // AFTER this loop, under only the LAST (current) epoch's regime — so
    // every skipped epoch's drift/volatility never touched the price at
    // all, and the whole gap's tick budget landed on whichever regime
    // happened to be current when the app was reopened (observed: a
    // Volatility epoch — zero drift by design — absorbed a gap that had
    // actually rolled through several regimes, one of which was almost
    // certainly a decline). Splitting the capped tick budget evenly
    // across every epoch actually experienced (each missed epoch + the
    // trailing current one) and simulating each segment while ITS epoch
    // is the active one fixes this — every regime the roulette landed on
    // now gets a fair (if attenuated, given the cap) say in the price.
    final totalSegments = missedRolls + 1; // + the trailing current epoch
    final ticksPerSegment = (_maxCatchUpTicks / totalSegments)
        .floor()
        .clamp(1, _maxCatchUpTicks);

    for (int r = 0; r < missedRolls; r++) {
      // ── Scenario-roll RNG: deterministic per epoch, NOT the shared
      // `rng` stream above. `_sessionRandom` (and therefore `rng`) is
      // in-memory-only — it never survives an app restart. Real usage
      // means the app is almost always closed between rolls (12h/24h/
      // 7-day cadence), so every catch-up's first `_rollScenario` call
      // was drawing from a freshly re-seeded Random(simulationSeed) —
      // the SAME deterministic first value every single time, hard-
      // locking every post-restart roll onto one scenario. Seeding by
      // (simulationSeed, epochIndex) instead makes each epoch's roll
      // reproducible AND distinct, independent of in-memory RNG state.
      // `rng` itself is left untouched above — _simulateCurrentPrices'
      // tick noise still needs that continuously-advancing stream.
      final epochIndexForRoll = baseLength + r;
      final scenario = _rollScenario(
        session,
        rng: Random(Object.hash(session.simulationSeed, epochIndexForRoll)),
      );
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

      // Simulate this epoch's own fair share of ticks under ITS OWN
      // regime, right now while it's the active epoch (before the next
      // iteration's close-previous-epoch step ends it). `lastEpochRollAt`
      // is pinned to `now` first so _simulateCurrentPrices' own wall-clock
      // roll-check (`now.difference(lastRollAt) >= rollInterval`) doesn't
      // fire a SECOND, non-deterministic roll on top of the deterministic
      // one this loop just performed above.
      session.lastEpochRollAt = now;
      _simulateCurrentPrices(idx, ticks: ticksPerSegment);
      // Re-sync: _simulateCurrentPrices just replaced state[idx] with a
      // new object — point `session` at it so the next iteration's
      // mutations (and casino-state fields read below the loop) land on
      // the object that's actually live in `state`, not an orphan.
      session = state[idx];
    }

    session.lastEpochRollAt = lastRoll.add(rollInterval * missedRolls);

    // ── Trailing partial epoch (the current one) — same fair share ──
    // Each already-closed missed epoch got its own `ticksPerSegment` above;
    // give the still-open current epoch the same segment size rather than
    // deriving it from `lastTickTimestamp` — the interior calls in the
    // loop above already advanced that timestamp to `now` for their own
    // segments, so a `now.difference(lastTickTimestamp)` computed here
    // would read as ~0 and starve this trailing segment down to the
    // clamp's 1-tick floor.
    final missedTicks = ticksPerSegment;
    // ignore: avoid_print
    print(
      '[CATCHUP-TICKS] ticksPerSegment=$ticksPerSegment missedTicks=$missedTicks',
    );
    _simulateCurrentPrices(idx, ticks: missedTicks);
    session = state[idx]; // re-sync for the diagnostic prints below

    // ── DIAGNOSTIC DUMP: session state after catch-up ──────────
    // ignore: avoid_print
    print('[CATCHUP-AFTER] session=${session.id}');
    // ignore: avoid_print
    print(
      '  epochHistory=${session.epochHistory.map((e) => "E${e.index}:${e.scenario.name}").toList()}',
    );
    // ignore: avoid_print
    print('  currentPrices=${session.currentPrices}');
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

    // Deterministic per-epoch seed — see the matching comment in _catchUp's
    // roll loop for why this can't use the shared `rng` stream above.
    final epochIndexForRoll = session.epochHistory.length;
    final newScenario = _rollScenario(
      session,
      rng: Random(Object.hash(session.simulationSeed, epochIndexForRoll)),
    );
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
