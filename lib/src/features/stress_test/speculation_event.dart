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
// Speculation / Hype Events — per-company bell-shape price events.
// ---------------------------------------------------------------------------
// Extracted verbatim from stress_test_engine.dart as part of the mechanism
// split (Задание 1). No logic was changed during this move.
//
// NOTE (see report — "не удалось однозначно распределить"): the task table
// lists speculation_event.dart and hype_event.dart as two separate files.
// In the current code (post commit 585fc14, "Simplify spec/hype event
// mechanics") hype and speculation are NOT two separate implementations —
// they are one shared per-company event system (_maybeFireSpecEvent /
// _applySpecEvents) that branches on `CompanySpecEventType` using a single
// shared RNG draw, shared cooldown map, and shared active-event list.
// Physically splitting hype vs. speculation into two files would require
// restructuring that shared control flow and RNG call order — which risks
// changing simulation determinism/output — so per the "don't fix, don't
// restructure, just move" constraint, the whole merged mechanism was kept
// in this single file. No hype_event.dart was created.
// ---------------------------------------------------------------------------

extension SpeculationEventEngine on StressTestNotifier {
  // ── Block 5: Per-Company Speculation / Hype Events ──────────────────
  // Replaces the old global speculation/hype scenarios.
  // Each company gets one chance per weekly wall-clock window (see
  // lastSpecEventCheckAt in _simulateCurrentPrices) to trigger a hidden
  // spec/hype event with bell-shape price impact (ramp up → reversal).
  // Cooldown: 3-4 weeks after event ends.
  // Events are evaluated in _simulateCurrentPrices.

  /// Try to fire a spec/hype event for a single holding. Called once per
  /// holding per weekly wall-clock window (see lastSpecEventCheckAt).
  CompanySpecEvent? _maybeFireSpecEvent(
    StressTestSession session,
    String symbol,
    Random rng,
    DateTime now,
  ) {
    // Check cooldown: skip if still cooling down
    final cooldownUntil = session.specEventCooldowns[symbol];
    if (cooldownUntil != null && now.isBefore(cooldownUntil)) return null;

    // Avoid stacking: skip if this symbol already has an active event
    final hasActive = session.specEvents.any(
      (e) => e.symbol == symbol && !e.isExpired,
    );
    if (hasActive) return null;

    // 5% chance per weekly check
    if (rng.nextDouble() >= _specEventChancePerCheck) return null;

    // Hype vs speculation weighted: 60% hype, 40% speculation
    final type = rng.nextDouble() < 0.6
        ? CompanySpecEventType.hype
        : CompanySpecEventType.speculation;

    // Bell-shape duration spans the full current epoch (Block 6 roll
    // interval) rather than a fixed tick count — a weekly test's epoch is
    // 12h, a monthly/3-month test's is 24h, an infinite/custom test's is
    // 7/5 days — so the surge+reversal cycle scales with the test's own
    // rhythm instead of a constant that only matched one mode.
    final rampTicks = (session.duration.rollInterval.inSeconds / _tickSeconds)
        .round()
        .clamp(1, 1000000);

    // Peak amplitude:
    // Hype: moderate +3-8% (always positive — good news)
    // Speculation: volatile ±5-15% (50% positive / 50% negative — bad news)
    final peak = type == CompanySpecEventType.hype
        ? 0.03 + rng.nextDouble() * 0.05
        : (rng.nextDouble() < 0.5 ? 1.0 : -1.0) *
              (0.05 + rng.nextDouble() * 0.10);

    // Cooldown: 3-4 weeks from now
    final cooldownEnd = now.add(Duration(days: _specEventCooldownWeeks * 7));
    session.specEventCooldowns[symbol] = cooldownEnd;

    return CompanySpecEvent(
      symbol: symbol,
      type: type,
      startedAt: now,
      endsAt: now.add(Duration(seconds: rampTicks * _tickSeconds)),
      rampDurationTicks: rampTicks,
      peakAmplitude: peak,
    );
  }

  /// Apply active spec/hype events to price calculations.
  /// Returns the cumulative amplitude to add to the price change.
  double _applySpecEvents(StressTestSession session, String symbol) {
    double cumulative = 0.0;
    final updatedEvents = <CompanySpecEvent>[];

    for (final event in session.specEvents) {
      if (event.symbol != symbol) {
        updatedEvents.add(event);
        continue;
      }

      if (event.isExpired) continue; // drop expired

      cumulative += event.amplitude;

      // Advance tick counter
      final updated = event.copy();
      updated.currentTick++;
      updatedEvents.add(updated);
    }

    session.specEvents = updatedEvents;
    return cumulative;
  }
}

/// Chance per company per weekly check.
const double _specEventChancePerCheck = 0.05;

/// Cooldown in weeks after an event ends.
const int _specEventCooldownWeeks = 3;
