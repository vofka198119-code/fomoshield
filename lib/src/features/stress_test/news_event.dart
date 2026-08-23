// ignore_for_file: invalid_use_of_protected_member, invalid_use_of_visible_for_testing_member
// `state` is StateNotifier's own protected/visibleForTesting field — needed
// on every `part of` mechanism file (see the matching comment in
// hype/hype_event.dart).
part of 'stress_test_engine.dart';

// ---------------------------------------------------------------------------
// News — a random single-company headline event.
// ---------------------------------------------------------------------------
// Deliberately its own file, separate from the Hype mechanism
// (hype/hype_event.dart) — different trigger conditions, different shape,
// different content — per explicit instruction to keep each micro-scenario
// mechanism isolated so any one of them can be fixed without touching the
// others. (A third sibling, "Speculation", existed briefly and was removed
// 2026-07-19 — see repair queue in project memory for the "add back later"
// list. It is NOT currently live in any form.)
//
// Trigger (checked once per epoch, from noise_engine.dart's
// _simulateCurrentPrices, right next to the Hype check):
//   - Portfolio needs 8+ holdings. That's the ONLY eligibility gate — there
//     is no separate per-session on/off switch anywhere in the code.
//   - Skipped if a News event is already active (one at a time).
//   - 5% roll chance when checked.
// If it fires: one random holding, one random headline from
// [newsScenarios] (sign matches the headline's own positive/negative
// list), a signed total move of 6-12%, ramped in over a random
// 2-6 hour window with NO reversal — a real news-driven move mostly
// sticks, it doesn't mechanically snap back to zero the way Hype's
// overshoot-then-correct curve does.
// ---------------------------------------------------------------------------

/// One canned headline + its direction. Magnitude is rolled separately
/// (see [_newsAmplitudeMin]/[_newsAmplitudeMax]) — the scenario table only
/// supplies the story and the sign.
class NewsScenario {
  final String headline;
  final String description;
  final bool isPositive;

  const NewsScenario({
    required this.headline,
    required this.description,
    required this.isPositive,
  });
}

/// The 25 confirmed scenarios (12 positive, 13 negative) — user-provided
/// 2026-07-19, see memory note project-fomo-shield-corporate-scenarios-list.
const List<NewsScenario> newsScenarios = [
  // ── Positive ──────────────────────────────────────────────────
  NewsScenario(
    headline: 'Earnings Beat Expectations',
    description:
        'The company reported quarterly revenue and profit above analyst forecasts.',
    isPositive: true,
  ),
  NewsScenario(
    headline: 'Annual Guidance Raised',
    description:
        'Management raised its revenue and profit guidance for the current fiscal year.',
    isPositive: true,
  ),
  NewsScenario(
    headline: 'Major Contract Signed',
    description:
        'The company announced a multi-year agreement with a large corporate client.',
    isPositive: true,
  ),
  NewsScenario(
    headline: 'Share Buyback Announced',
    description:
        'The board approved a large-scale program to repurchase the company\'s own shares.',
    isPositive: true,
  ),
  NewsScenario(
    headline: 'Dividend Increase',
    description:
        'The company raised its quarterly dividend and reaffirmed a stable dividend policy.',
    isPositive: true,
  ),
  NewsScenario(
    headline: 'Deal Successfully Closed',
    description:
        'All required approvals were obtained and the acquisition of another company officially closed.',
    isPositive: true,
  ),
  NewsScenario(
    headline: 'New Product Approved',
    description:
        'A regulator approved the launch of a new product, opening an additional revenue stream for the company.',
    isPositive: true,
  ),
  NewsScenario(
    headline: 'Cost Reduction Program',
    description:
        'The company announced an optimization program expected to significantly cut operating expenses.',
    isPositive: true,
  ),
  NewsScenario(
    headline: 'Debt Repayment',
    description:
        'The company repaid part of its debt load ahead of schedule and improved its balance sheet.',
    isPositive: true,
  ),
  NewsScenario(
    headline: 'Business Expansion',
    description:
        'Management announced entry into a new international market with local operations launching.',
    isPositive: true,
  ),
  NewsScenario(
    headline: 'Customer Base Growth',
    description:
        'The number of active customers reached a record high for the company.',
    isPositive: true,
  ),
  NewsScenario(
    headline: 'Strategic Partnership',
    description:
        'The company signed a long-term cooperation agreement with an industry leader.',
    isPositive: true,
  ),
  // ── Negative ──────────────────────────────────────────────────
  NewsScenario(
    headline: 'Earnings Miss Expectations',
    description:
        'The company reported results below analyst forecasts for profit and revenue.',
    isPositive: false,
  ),
  NewsScenario(
    headline: 'Guidance Cut',
    description:
        'Management lowered its financial guidance for the rest of the year.',
    isPositive: false,
  ),
  NewsScenario(
    headline: 'Deal Falls Through',
    description:
        'A planned acquisition of another company was called off after lengthy negotiations.',
    isPositive: false,
  ),
  NewsScenario(
    headline: 'Product Recall',
    description:
        'The company began a large-scale product recall due to manufacturing defects.',
    isPositive: false,
  ),
  NewsScenario(
    headline: 'Cyberattack',
    description:
        'The company confirmed a cyberattack that affected part of its internal systems.',
    isPositive: false,
  ),
  NewsScenario(
    headline: 'CEO Departure',
    description:
        'The CEO unexpectedly announced their departure from the role.',
    isPositive: false,
  ),
  NewsScenario(
    headline: 'Lawsuit Filed',
    description:
        'A major class-action lawsuit tied to the company\'s core business was filed against it.',
    isPositive: false,
  ),
  NewsScenario(
    headline: 'Supply Chain Issues',
    description:
        'The company warned of supply chain disruptions and possible production delays.',
    isPositive: false,
  ),
  NewsScenario(
    headline: 'Debt Load Increase',
    description:
        'The company reported a significant increase in debt following its latest financial report.',
    isPositive: false,
  ),
  NewsScenario(
    headline: 'Regulatory Investigation',
    description:
        'A regulator opened a formal investigation into the company\'s operations.',
    isPositive: false,
  ),
  NewsScenario(
    headline: 'Key Client Lost',
    description:
        'One of the company\'s largest clients declined to renew its long-term contract.',
    isPositive: false,
  ),
  NewsScenario(
    headline: 'Production Halted',
    description:
        'Operations at one of the company\'s main production facilities were temporarily halted due to technical issues.',
    isPositive: false,
  ),
  NewsScenario(
    headline: 'Layoffs Announced',
    description:
        'The company announced a major restructuring involving workforce reductions.',
    isPositive: false,
  ),
];

/// Minimum portfolio size for the News mechanism to be eligible at all.
const int _newsMinHoldings = 8;

/// Chance per epoch that a News event fires (once eligible).
const double _newsChancePerEpochCheck = 0.05;

/// Total signed price move range — magnitude only, sign comes from the
/// picked [NewsScenario.isPositive].
const double _newsAmplitudeMin = 0.06;
const double _newsAmplitudeMax = 0.12;

/// Ramp duration range — deliberately shorter/sharper than the spec/hype
/// mechanism's full-epoch ramp, per explicit instruction ("более резкий
/// скачок").
const Duration _newsRampMin = Duration(hours: 2);
const Duration _newsRampMax = Duration(hours: 6);

extension NewsEventEngine on StressTestNotifier {
  /// Try to fire a News event for this session. Called once per epoch
  /// (gate lives in noise_engine.dart's lastNewsCheckedEpoch check).
  NewsEvent? _maybeFireNewsEvent(
    StressTestSession session,
    Random rng,
    DateTime now,
  ) {
    if (session.holdings.length < _newsMinHoldings) return null;
    if (rng.nextDouble() >= _newsChancePerEpochCheck) return null;

    final holding = session.holdings[rng.nextInt(session.holdings.length)];
    final scenarioIndex = rng.nextInt(newsScenarios.length);
    final scenario = newsScenarios[scenarioIndex];
    final magnitude =
        _newsAmplitudeMin +
        rng.nextDouble() * (_newsAmplitudeMax - _newsAmplitudeMin);
    final signedAmplitude = scenario.isPositive ? magnitude : -magnitude;

    final rampMs =
        _newsRampMin.inMilliseconds +
        rng.nextDouble() *
            (_newsRampMax.inMilliseconds - _newsRampMin.inMilliseconds);
    final rampTicks = (rampMs / 1000 / _tickSeconds).round().clamp(1, 1000000);

    return NewsEvent(
      symbol: holding.symbol,
      headline: scenario.headline,
      description: scenario.description,
      scenarioIndex: scenarioIndex,
      isPositive: scenario.isPositive,
      targetAmplitude: signedAmplitude,
      startedAt: now,
      rampDurationTicks: rampTicks,
    );
  }

  /// Apply this tick's slice of the active News event, if [symbol] is the
  /// one it targets. Mutates session.activeNewsEvent in place (advances
  /// currentTick, clears to null on expiry) so multi-tick catch-up
  /// batches progress correctly call-by-call.
  double _applyNewsEvent(StressTestSession session, String symbol) {
    final event = session.activeNewsEvent;
    if (event == null || event.symbol != symbol) return 0.0;
    if (event.isExpired) {
      session.activeNewsEvent = null;
      return 0.0;
    }

    final increment = event.tickIncrement;
    final advanced = event.copy();
    advanced.currentTick++;
    session.activeNewsEvent = advanced.isExpired ? null : advanced;
    return increment;
  }
}
