// ignore_for_file: invalid_use_of_protected_member, invalid_use_of_visible_for_testing_member
// `state` is StateNotifier's own protected/visibleForTesting field — see
// the matching comment in speculation/speculation_event.dart for why this
// ignore is needed on every `part of` mechanism file.
part of '../stress_test_engine.dart';

// ---------------------------------------------------------------------------
// Hype — a sector-wide trending move.
// ---------------------------------------------------------------------------
// Own file/folder, separate from the sibling per-company Speculation
// mechanism (../speculation/speculation_event.dart) and from the
// single-company News mechanism (../news_event.dart) — different trigger
// conditions, different target (a whole GICS sector, not one company),
// different shape, per explicit instruction to keep each micro-scenario
// mechanism physically isolated.
//
// Trigger (checked once per epoch, from noise_engine.dart's
// _simulateCurrentPrices, right next to the News check):
//   - Portfolio needs 8+ holdings, or the mechanism is disabled entirely
//     for that session — same threshold as News.
//   - Only rolled while 0 Hype events are currently active (a fresh check
//     is skipped entirely — not even attempted — while 1 or 2 are live).
//   - Two independent 7% draws per check. Both firing with the SAME sign
//     collapses to a single event (the extra one "rests"); both firing
//     with OPPOSITE signs is a genuine pair — two distinct sectors, one
//     trending up, one down, at the same time. Exactly one firing is a
//     single event. Neither firing means nothing happens this epoch.
// If it fires: sector picked uniformly from all 11 GICS sectors
// (regardless of whether the portfolio currently holds anything there —
// the event still "happens", it's just invisible until/unless the user
// holds something in that sector), signed magnitude 2-13%, ramped smoothly
// over 2-4 epochs (random per roll) with a gentle overshoot-then-correct
// tail (see HypeEvent._progressShape) rather than News's sharp no-reversal
// snap.
// ---------------------------------------------------------------------------

/// Minimum portfolio size for Hype to be eligible at all. Same threshold
/// as News — a sector move matters too much in a small, concentrated
/// portfolio.
const int _hypeMinHoldings = 8;

/// Chance per independent draw per epoch check (two draws per check).
const double _hypeChancePerEpochCheck = 0.07;

/// Total signed magnitude range — sign comes from the roll's direction.
const double _hypeAmplitudeMin = 0.02;
const double _hypeAmplitudeMax = 0.13;

/// Ramp duration range, in whole epochs (random per roll).
const int _hypeMinEpochSpan = 2;
const int _hypeMaxEpochSpan = 4;

/// Damping applied to a Hype tick increment when it would stack in the
/// same direction as an already-strong Bull/Recovery macro regime —
/// explicit design ask: sector Hype should never compound with a bull
/// market into "заоблачные" (sky-high) numbers. The existing per-regime
/// price clamp in gbm_engine.dart is still the hard backstop; this is a
/// softer, earlier damping so Bull+Hype doesn't routinely slam into that
/// ceiling the way an undamped stack would.
const double _hypeBullCoOccurrenceDamping = 0.5;

extension HypeEventEngine on StressTestNotifier {
  /// Roll for new sector Hype event(s). Only call when eligible (8+
  /// holdings) and [session.activeHypeEvents] is currently empty. Returns
  /// an empty list (nothing fired), or a list of 1-2 new events — 2 only
  /// when the roll produced a genuine opposite-signed pair.
  List<HypeEvent> _maybeFireHypeEvents(
    StressTestSession session,
    Random rng,
    DateTime now,
    int ticksPerEpoch,
  ) {
    final fireA = rng.nextDouble() < _hypeChancePerEpochCheck;
    final upA = fireA ? rng.nextBool() : null;
    final fireB = rng.nextDouble() < _hypeChancePerEpochCheck;
    final upB = fireB ? rng.nextBool() : null;

    if (!fireA && !fireB) return const [];

    if (fireA && fireB && upA != upB) {
      // Genuine opposite pair — two distinct sectors, opposite directions.
      final first = _rollOneHypeEvent(rng, now, ticksPerEpoch, isUp: upA!);
      final second = _rollOneHypeEvent(
        rng,
        now,
        ticksPerEpoch,
        isUp: upB!,
        exclude: first.sector,
      );
      return [first, second];
    }

    // Either only one draw fired, or both fired with the same sign —
    // same-sign duplicates collapse to a single event (the extra "rests").
    final isUp = (fireA ? upA : upB)!;
    return [_rollOneHypeEvent(rng, now, ticksPerEpoch, isUp: isUp)];
  }

  HypeEvent _rollOneHypeEvent(
    Random rng,
    DateTime now,
    int ticksPerEpoch, {
    required bool isUp,
    GicsSector? exclude,
  }) {
    final sectors = GicsSector.values;
    var sector = sectors[rng.nextInt(sectors.length)];
    if (exclude != null) {
      while (sector == exclude) {
        sector = sectors[rng.nextInt(sectors.length)];
      }
    }
    final magnitude =
        _hypeAmplitudeMin +
        rng.nextDouble() * (_hypeAmplitudeMax - _hypeAmplitudeMin);
    final epochSpan =
        _hypeMinEpochSpan +
        rng.nextInt(_hypeMaxEpochSpan - _hypeMinEpochSpan + 1);
    return HypeEvent(
      sector: sector,
      isPositive: isUp,
      targetAmplitude: isUp ? magnitude : -magnitude,
      startedAt: now,
      rampDurationTicks: ticksPerEpoch * epochSpan,
    );
  }

  /// Peek this tick's increment per sector across all active Hype events,
  /// without mutating anything. Call ONCE PER TICK (not once per holding —
  /// a single event can target many holdings within the same tick), apply
  /// the result to every matching holding, then call [_advanceHypeEvents]
  /// once to move all active events forward by that one tick.
  Map<GicsSector, double> _hypeTickIncrements(StressTestSession session) {
    final result = <GicsSector, double>{};
    for (final event in session.activeHypeEvents) {
      if (event.isExpired) continue;
      result[event.sector] =
          (result[event.sector] ?? 0.0) + event.tickIncrement;
    }
    return result;
  }

  /// Advance all active Hype events by exactly one tick, dropping any that
  /// just expired. Call exactly once per simulated tick, after applying
  /// that tick's increments to every holding.
  void _advanceHypeEvents(StressTestSession session) {
    final updated = <HypeEvent>[];
    for (final event in session.activeHypeEvents) {
      if (event.isExpired) continue;
      final advanced = event.copy();
      advanced.currentTick++;
      if (!advanced.isExpired) updated.add(advanced);
    }
    session.activeHypeEvents = updated;
  }
}
