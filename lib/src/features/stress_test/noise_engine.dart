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
// Noise Engine — the unified per-tick simulation loop.
// ---------------------------------------------------------------------------
// Extracted verbatim from stress_test_engine.dart as part of the mechanism
// split (Задание 1). No logic was changed during this move.
//
// NOTE (see report — "не удалось однозначно распределить"): per-tick /
// per-company micro-noise (the mechanism this file is named after) is NOT
// a standalone function in the current code — it's two inline expressions
// (`noise` and `microNoise`) computed directly inside _simulateCurrentPrices'
// per-holding tick loop, interleaved with GBM drift, active market-shock
// application, spec/hype event application, per-regime clamping, post-
// catastrophe recovery bounce, stabilization-period freezing, and
// explainable-simulation logging (_explainPriceChange) — all reading and
// mutating the same local variables in a fixed sequence, several of them
// consuming `rng.nextDouble()` in an order that session determinism depends
// on. Per explicit instruction for this pass: move the whole loop as one
// unit into the file most associated with "noise" rather than decomposing
// it into per-mechanism functions — that decomposition is next-stage work,
// not this move-only pass. So this file actually contains the full unified
// tick loop (GBM + noise + shocks + spec-events + catastrophe-recovery +
// stabilization + psychology-diversification + explanation-log), not only
// the noise term.
// ---------------------------------------------------------------------------

// ── Price-swing radar (device-test feedback 2026-08-12) ──────────────────
// How often (real wall-clock time) each holding's price is re-sampled for
// the swing check, and how big a move between two samples counts as a
// "swing" worth a notification. User's own spec: "к примеру час" (an hour,
// as an example) narrowed down to 10 minutes; threshold "10 процентов...
// можно снизить до 6%" — 10% picked as the starting value, tune down
// toward 6% later if it reads as too rare on-device.
const Duration _swingCheckInterval = Duration(minutes: 10);
const double _swingThreshold = 0.10;

// ── Recovery cross-asset tuning (device-test feedback 2026-07-23) ────────
// Snapshot the price anchors the divergence-limit floor and the crash-
// depth recovery-drift weighting both depend on (see gbm_engine.dart's
// `_recoveryDriftMultiplier`/`_recoveryDivergenceFloor` and this file's
// tick-loop use of them). Called from every site that rolls a new epoch —
// noise_engine.dart's own wall-clock roll below, casino_epochs.dart's
// `_catchUp` loop, and `debugForceEpochRoll` — right after that site's
// existing casino-state if/else block and BEFORE the new epoch is
// appended to `epochHistory`, so `epochHistory.length` here still equals
// the new epoch's about-to-be-assigned index (matching whatever value the
// casino-state block just wrote into `casinoLastCatastropheEpoch` for a
// catastrophe roll).
void _captureRecoveryAnchors(
  StressTestSession session,
  MarketScenario newScenario,
) {
  if (newScenario.isCatastrophe) {
    session.preCrashPrices = Map<String, double>.from(session.currentPrices);
  } else if (newScenario == MarketScenario.recovery &&
      session.epochHistory.length - session.casinoLastCatastropheEpoch == 1) {
    session.recoveryStartPrices = Map<String, double>.from(
      session.currentPrices,
    );
  }
}

/// How much [symbol] fell during the crash/blackSwan epoch that preceded
/// the current scripted Recovery window (0.0-1.0, clamped to non-negative
/// — a symbol that somehow rose during the "crash" contributes no boost,
/// not a negative one). Returns 0.0 if either anchor is missing (e.g. the
/// holding was bought mid-recovery, after the crash already happened, so
/// there's no real drawdown to weight against).
double _recoveryCrashDropPct(StressTestSession session, String symbol) {
  final pre = session.preCrashPrices[symbol];
  final start = session.recoveryStartPrices[symbol];
  if (pre == null || start == null || pre <= 0) return 0.0;
  return ((pre - start) / pre).clamp(0.0, 1.0);
}

extension NoiseEngine on StressTestNotifier {
  /// Build a price contribution breakdown for explainable simulation.
  /// Factors always sum to exactly 100%.
  TickExplanation _explainPriceChange({
    required String symbol,
    required double priceBefore,
    required double priceAfter,
    required int epochIndex,
    required MarketScenario scenario,
    required bool hasCorrection,
    double? marketDriftRaw,
    double? sectorDriftRaw,
    double? noiseRaw,
    double? newsRaw,
    double? hypeRaw,
  }) {
    // Raw weights for each factor (all per-tick scaled)
    double mW = (marketDriftRaw?.abs() ?? 0.0);
    double sW = (sectorDriftRaw?.abs() ?? 0.0);
    double nW = (noiseRaw?.abs() ?? 0.0);
    // Real News event (news_event.dart) takes priority when this symbol is
    // the one it's targeting. A >5% correction with no real News event
    // used to get the same "News" attribution via a synthetic 0.15 proxy
    // — but WhyDiagnosticsAccumulator's episode history (stress_test_why_
    // diagnostics.dart) only ever counts real News events (keyed off
    // newsRaw), so that synthetic weight inflated the whole-period "News"
    // percentage while the episode count stayed at 0 for the exact same
    // ticks — the two numbers on the admin diagnostics screen visibly
    // disagreed. Folding it into Noise instead keeps both consistent;
    // this only changes the explanatory attribution label, not any price
    // the simulation actually produces (contributions here are computed
    // AFTER priceBefore/priceAfter, purely for display).
    final bool realNewsActive = newsRaw != null && newsRaw.abs() > 0.0001;
    final double newsW = realNewsActive ? newsRaw.abs() : 0.0;
    if (!realNewsActive && hasCorrection) {
      nW += 0.15;
    }
    // Real Hype event (hype/hype_event.dart) — previously computed and
    // applied to the price but never passed in here, so a sector-wide
    // Hype move had no attribution slot and got silently absorbed into
    // the other factors' proportions, showing up to the user as "mostly
    // Noise" even when Hype was the actual driver (confirmed on-device:
    // holdings 10-15% off from the rest of the portfolio with nothing but
    // Noise in the Why breakdown).
    final double hypeW = (hypeRaw?.abs() ?? 0.0);

    final double totalW = mW + sW + nW + newsW + hypeW;
    if (totalW < 1e-12) {
      // No meaningful move → balanced default split
      return TickExplanation(
        epochIndex: epochIndex,
        symbol: symbol,
        priceBefore: priceBefore,
        priceAfter: priceAfter,
        contributions: const PriceContribution(
          marketPct: 47,
          sectorPct: 29,
          newsPct: 0,
          hypePct: 0,
          noisePct: 24,
        ),
        marketPhase: scenario.name,
        scenario: scenario.name,
        marketDriftRaw: marketDriftRaw,
        sectorDriftRaw: sectorDriftRaw,
        noiseRaw: noiseRaw,
        newsRaw: newsRaw,
        hypeRaw: hypeRaw,
      );
    }

    // Compute exact percentages
    double mPct = mW / totalW * 100;
    double sPct = sW / totalW * 100;
    double nPct = nW / totalW * 100;
    double newsPct = newsW / totalW * 100;
    double hypePct = hypeW / totalW * 100;

    // Force exact 100 by adjusting the largest component
    double sum = mPct + sPct + nPct + newsPct + hypePct;
    final double diff = 100.0 - sum;
    if (diff.abs() > 1e-10) {
      final List<double> components = [mPct, sPct, nPct, newsPct, hypePct];
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
          nPct += diff;
          break;
        case 3:
          newsPct += diff;
          break;
        case 4:
          hypePct += diff;
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
        newsPct: newsPct.clamp(0, 100),
        hypePct: hypePct.clamp(0, 100),
        noisePct: nPct.clamp(0, 100),
      ),
      marketPhase: scenario.name,
      scenario: scenario.name,
      marketDriftRaw: marketDriftRaw,
      sectorDriftRaw: sectorDriftRaw,
      noiseRaw: noiseRaw,
      newsRaw: newsRaw,
      hypeRaw: hypeRaw,
    );
  }

  /// Simulate current prices using sector-based market model.
  /// Each holding's price moves according to its sector's drift + noise.
  /// Virtual market is always open — rolls new casino scenarios on wall-clock.
  ///
  /// When [ticks] > 1 (catch-up mode), simulates multiple 20-second ticks
  /// in a granular loop so GBM produces smooth trajectories instead of
  /// hitting the clamp ceiling on a single mega-tick.
  /// [priceHistoryAsOf] — the real wall-clock moment this batch of ticks
  /// should be recorded as having happened at, for [priceHistoryTimestamps]
  /// only. Defaults to the real `DateTime.now()` fetched below (correct for
  /// normal live ticking and the single-batch catch-up path). Catch-up's
  /// per-epoch-segment loop (casino_epochs.dart) passes each segment's own
  /// already-computed `rollTime` instead — those calls all happen back-to-
  /// back synchronously with no real delay between them, so without this
  /// override every segment would otherwise get stamped with virtually the
  /// same instant instead of being spread across the actual missed gap.
  void _simulateCurrentPrices(
    int idx, {
    int ticks = 1,
    DateTime? priceHistoryAsOf,
  }) {
    final session = state[idx];

    // ── Background engine for symbols under a pending limit order ──────
    // A brand-new symbol with an open BUY limit order isn't in
    // session.holdings yet (no trade has executed), so without this it
    // would sit frozen at its seeded quote forever — a limit price below
    // a price that never moves can never cross. Driving it through the
    // same tick loop as real holdings (just without adding it to
    // holdings/portfolio value) means that if/when the order fills, the
    // symbol already "lived" under the test's regime instead of starting
    // from a flat line. Wired via [_watchedSymbolsFor] (set by
    // stress_test_pending_orders_provider.dart) rather than an import
    // here, keeping this engine file unaware of the pending-order system
    // — same isolation principle as stress_test_pending_order.dart.
    final heldSymbols = session.holdings.map((h) => h.symbol).toSet();
    final watchedExtra =
        (_watchedSymbolsFor?.call(session.id) ?? const <String>{})
            .difference(heldSymbols);
    if (session.holdings.isEmpty && watchedExtra.isEmpty) return;

    final now = DateTime.now();
    final tickTimestamp = (priceHistoryAsOf ?? now).millisecondsSinceEpoch;

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
      _captureRecoveryAnchors(session, newScenario);

      // Close previous active epoch and start new one
      _recordEpochTransition(session, newScenario, now);
    }

    final currentEpoch = _getCurrentEpoch(session);
    if (currentEpoch == null) return;

    // ── Epoch-relative time scaling ──────────────────────────────
    // dt used to be a fixed 0.005/tick regardless of the epoch's actual
    // real-world length (12h/24h/5d/7d) — meaning the full annual-
    // equivalent drift/volatility for ANY scenario fully "burned through"
    // in ~200 ticks (~67 real minutes), no matter how long the epoch was
    // nominally supposed to last. For every tick after that (which is
    // most of a 12h+ epoch), the price just kept randomly walking with
    // nothing anchoring it to the epoch's remaining time, until it hit
    // the regime's own price clamp and sat pinned there — confirmed on a
    // real device: a Bull epoch sitting at exactly its +100% ceiling,
    // ticks oscillating ±1-2% right against it. Scaling dt to the
    // CURRENT epoch's real tick count spreads the scenario's full
    // designed magnitude evenly across the whole epoch instead.
    final ticksPerEpoch = (rollInterval.inSeconds / _tickSeconds).round().clamp(
      1,
      1 << 30,
    );
    final dtPerTick = 1.0 / ticksPerEpoch;
    final sqrtDt = sqrt(dtPerTick);

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

    // ── News micro-scenario: single-company random headline event ──
    // Checked once per EPOCH (not per tick/day) — gated on the current
    // epoch's index vs lastNewsCheckedEpoch, so re-entering the screen
    // (or the ongoing 20s ticker) within the same epoch doesn't re-roll.
    // See news_event.dart for the trigger conditions (8+ holdings, no
    // event already active, 5% chance) and the 25-scenario table.
    if (session.lastNewsCheckedEpoch != currentEpoch.index) {
      session.lastNewsCheckedEpoch = currentEpoch.index;
      if (session.activeNewsEvent == null) {
        final newsEvent = _maybeFireNewsEvent(session, rng, now);
        if (newsEvent != null) {
          session.activeNewsEvent = newsEvent;
          // Only pop up/record for a genuine live tick (ticks<=1) — a
          // catch-up batch (ticks>1, see this method's own doc comment)
          // can roll News for epochs the user never actually watched live,
          // and a popup for a "headline" from 3 days ago the instant the
          // app reopens would be exactly the stale-notification spam the
          // price-swing radar is being built to avoid (same principle,
          // applied here too).
          if (ticks <= 1) {
            _onNotify?.call(
              AppNotification(
                id: 'notif_${DateTime.now().microsecondsSinceEpoch}',
                type: AppNotificationType.news,
                portfolioKind: NotificationPortfolioKind.stressTest,
                portfolioId: session.id,
                portfolioLabel:
                    'Market Simulation — ${session.duration.displayName}',
                symbol: newsEvent.symbol,
                companyName: stressTestCompanyName(newsEvent.symbol),
                title: newsEvent.headline,
                detail: newsEvent.description,
                newsScenarioIndex: newsEvent.scenarioIndex,
                createdAt: DateTime.now(),
              ),
            );
          }
        }
      }
    }

    // ── Hype: sector-wide trending move, checked once per EPOCH ──────
    // Same eligibility/cadence pattern as News (8+ holdings, once per
    // epoch index) but only rolled while 0 Hype events are currently
    // active — see hype/hype_event.dart for the pairing/rest rules.
    if (session.lastHypeCheckedEpoch != currentEpoch.index) {
      session.lastHypeCheckedEpoch = currentEpoch.index;
      if (session.activeHypeEvents.isEmpty &&
          session.holdings.length >= _hypeMinHoldings) {
        final newHypeEvents = _maybeFireHypeEvents(
          session,
          rng,
          now,
          ticksPerEpoch,
        );
        if (newHypeEvents.isNotEmpty) {
          session.activeHypeEvents = newHypeEvents;
        }
      }
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

    // Ticks in this catch-up batch are the most recent [ticks] ticks
    // leading up to `now`, each _tickSeconds apart (see stress_test_engine
    // .dart's catch-up comment). Used below to reshape Crash's drift by
    // how far into the epoch's real duration each subtick actually falls.
    final epochElapsedTicksNow =
        now.difference(currentEpoch.startedAt).inSeconds / _tickSeconds;

    // Per-tick price history snapshots — one entry per sub-tick simulated
    // below, not just the final result. A single catch-up call can cover
    // up to _maxCatchUpTicks (900) sub-ticks; without recording each one,
    // the chart only ever sees the batch's start and end price and draws
    // a straight line between them (the catch-up straight-line artifact).
    // Downsampled to _maxRenderPointsPerBurst before being merged into
    // priceHistory below.
    final tickSnapshots = <Map<String, double>>[];
    final tickTimestamps = <int>[];
    final tickIntervalMs = _tickSeconds * 1000;

    // entryPrice only exists for real holdings — watchedExtra symbols fall
    // back to their already-seeded base/current price instead (see
    // seedPrice below), so this map is intentionally partial.
    final heldEntryPriceBySymbol = {
      for (final h in session.holdings) h.symbol: h.entryPrice,
    };
    final symbolsThisTick = <String>[
      ...session.holdings.map((h) => h.symbol),
      ...watchedExtra,
    ];

    for (int tick = 0; tick < ticks; tick++) {
      // Peek once per tick (not once per holding — one Hype event can
      // target many holdings within the same tick); advanced once after
      // the holdings loop below via _advanceHypeEvents.
      final hypeIncrements = _hypeTickIncrements(session);

      final epochFraction = ticksPerEpoch > 0
          ? ((epochElapsedTicksNow - (ticks - 1 - tick)) / ticksPerEpoch).clamp(
              0.0,
              1.0,
            )
          : 0.0;

      for (final symbol in symbolsThisTick) {
        // Real holdings always have entryPrice; a watchedExtra symbol
        // (pending limit order, not bought yet) falls back to whatever
        // price it was already seeded with when its stock detail page
        // was first opened (see _ensurePriceForNewAsset/setExternalPrice).
        final entryPriceFallback =
            heldEntryPriceBySymbol[symbol] ??
            session.basePrices[symbol] ??
            session.currentPrices[symbol] ??
            0.0;
        final basePrice = session.basePrices[symbol] ?? entryPriceFallback;
        double currentPrice = newPrices[symbol] ?? entryPriceFallback;
        final priceBefore =
            preBouncePrices[symbol] ??
            session.currentPrices[symbol] ??
            entryPriceFallback;
        final assetSector = _getAssetSector(symbol);
        final params = _getSectorParams(symbol, scenario);

        // ── Geometric Brownian Motion with dt scaling ─────────────
        // P_new = P_old × (1 + μ×dt + σ×ε×√dt + microNoiseFactor×ε₂×√dt)
        // All μ,σ are ANNUAL. dt (computed above from this epoch's real
        // duration) scales them to per-tick.
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
        final driftMultiplier = regime == _MacroRegime.crash
            ? _crashDriftMultiplier(epochFraction)
            : regime == _MacroRegime.recovery
            ? _recoveryDriftMultiplier(_recoveryCrashDropPct(session, symbol))
            : 1.0;
        final effectiveAnnualDrift =
            params.annualDrift +
            _varianceDragCompensation(params.annualVolatility);
        final rawChange =
            effectiveAnnualDrift * dtPerTick * driftMultiplier +
            noise +
            microNoise;
        final clampedChange = _clampDrift(rawChange, regime);
        currentPrice = currentPrice * (1 + clampedChange);
        // Gated behind kDebugMode — this fires once per held symbol per
        // simulated tick, and catch-up can run up to 900 ticks in one
        // screen-entry call (see _maxCatchUpTicks); ungated, that's up to
        // 9000 string-interpolating print() calls on a single re-entry,
        // in release builds too.
        if (kDebugMode) {
          // ignore: avoid_print
          print(
            '[TICK] $symbol basePrice=${basePrice.toStringAsFixed(4)} beforeGbm=${beforeGbm.toStringAsFixed(4)} afterGbm=${currentPrice.toStringAsFixed(4)} regime=${regime.name}',
          );
        }

        // ── News micro-scenario: apply if this holding is the one hit ──
        // Mutates session.activeNewsEvent in place (advances currentTick,
        // clears to null on expiry) so multi-tick catch-up batches
        // (ticks>1) progress correctly call-by-call.
        final newsIncrement = _applyNewsEvent(session, symbol);
        if (newsIncrement.abs() > 0.0001) {
          currentPrice *= (1.0 + newsIncrement);
        }

        // ── Hype: apply this tick's sector increment, if this holding's
        // GICS sector currently has an active Hype event ──────────────
        final holdingGicsSector = resolveGicsSector(symbol);
        double hypeIncrement = holdingGicsSector != null
            ? (hypeIncrements[holdingGicsSector] ?? 0.0)
            : 0.0;
        if (hypeIncrement > 0 &&
            (regime == _MacroRegime.bull || regime == _MacroRegime.recovery)) {
          // Damp Hype when it would stack in the same direction as an
          // already-strong Bull/Recovery regime — explicit ask: Hype +
          // Bull together should never compound into sky-high numbers.
          // The per-regime price clamp below is still the hard backstop;
          // this is a softer, earlier damping.
          hypeIncrement *= _hypeBullCoOccurrenceDamping;
        }
        if (hypeIncrement.abs() > 0.0001) {
          currentPrice *= (1.0 + hypeIncrement);
        }

        // ── Sandbox Isolation (Step 3): Per-regime price bounds ──
        final beforeClamp = currentPrice;
        final regimeBounds = _getRegimeBounds(regime);
        currentPrice = currentPrice.clamp(
          basePrice * regimeBounds.minPriceMultiplier,
          basePrice * regimeBounds.maxPriceMultiplier,
        );
        if (kDebugMode && (currentPrice - beforeClamp).abs() > 0.0001) {
          // ignore: avoid_print
          print(
            '[CLAMP] $symbol clamped '
            '${((beforeClamp - basePrice) / basePrice * 100).toStringAsFixed(1)}% → '
            '${((currentPrice - basePrice) / basePrice * 100).toStringAsFixed(1)}% '
            '(bounds: ${regimeBounds.minPriceMultiplier.toStringAsFixed(2)}x–'
            '${regimeBounds.maxPriceMultiplier.toStringAsFixed(2)}x)',
          );
        }

        // ── Recovery divergence limit (device-test feedback 2026-07-23) ──
        // On top of the regime's normal (much looser) basePrice-relative
        // bounds above: during Recovery specifically, don't let any ONE
        // asset drop more than _recoveryDivergenceFloor below its OWN
        // price at the moment this recovery window started — an isolated
        // bad noise-roll on one heavyweight holding shouldn't be able to
        // cancel out the regime's designed positive drift for the rest of
        // the portfolio (confirmed on-device: Ecolab alone at -19.10% for
        // ~70% of a window where its peers were up 20-30%). Only ever
        // raises the price (a floor, not a ceiling) — Recovery's upside is
        // untouched. No-op if this holding wasn't held yet when the
        // recovery window started (no anchor to measure against).
        if (regime == _MacroRegime.recovery) {
          final recoveryAnchor = session.recoveryStartPrices[symbol];
          if (recoveryAnchor != null && recoveryAnchor > 0) {
            final floor = recoveryAnchor * (1 - _recoveryDivergenceFloor);
            if (currentPrice < floor) currentPrice = floor;
          }
        }

        // ── Debug: log dt calibration once per app session ──────
        if (kDebugMode && !_dtCalibrationLogged) {
          _dtCalibrationLogged = true;
          final dtDrift = params.annualDrift * dtPerTick;
          final dtVol = params.annualVolatility * sqrtDt;
          // ignore: avoid_print
          print(
            '[FOMO-DT] dt=$dtPerTick (ticksPerEpoch=$ticksPerEpoch)  sqrt(dt)=${sqrtDt.toStringAsFixed(6)}  '
            'drift×dt=${dtDrift.toStringAsFixed(6)}  '
            'vol×√dt=${dtVol.toStringAsFixed(6)}  '
            '(μ,σ)=(${params.annualDrift.toStringAsFixed(4)},${params.annualVolatility.toStringAsFixed(4)}) '
            'sector=${assetSector.name}  regime=${_toMacroRegime(scenario).name}',
          );
        }

        // ── Stabilization Period ───────────────────────────────────
        // Freeze price at entryPrice for 30 seconds after purchase
        final stabDeadline = session.stabilizationDeadlines[symbol];
        if (stabDeadline != null && now.isBefore(stabDeadline)) {
          currentPrice = entryPriceFallback;
        }
        newPrices[symbol] = currentPrice;

        // ── Explainable Simulation ────────────────────────────────
        final hasCorrection =
            priceBefore > 0 &&
            (priceBefore - currentPrice).abs() / priceBefore > 0.05;
        final expl = _explainPriceChange(
          symbol: symbol,
          priceBefore: priceBefore,
          priceAfter: currentPrice,
          epochIndex: currentEpoch.index,
          scenario: scenario,
          hasCorrection: hasCorrection,
          marketDriftRaw: effectiveAnnualDrift * dtPerTick * driftMultiplier,
          sectorDriftRaw:
              (params.annualDrift - avgDrift) * dtPerTick * driftMultiplier,
          noiseRaw: noise,
          newsRaw: newsIncrement,
          hypeRaw: hypeIncrement,
        );
        var symLog = <TickExplanation>[...(explanations[symbol] ?? []), expl];
        // Cap per-symbol log — see _maxExplanationLogEntries.
        if (symLog.length > _maxExplanationLogEntries) {
          symLog = symLog.sublist(symLog.length - _maxExplanationLogEntries);
        }
        explanations[symbol] = symLog;

        // Fold into the whole-period Why Diagnostics accumulator BEFORE
        // the cap above can trim this tick out of explanationLog — see
        // stress_test_why_diagnostics.dart for why this can't just be
        // derived from explanationLog after the fact.
        _foldWhyDiagnostics(session.id, symbol, expl);

        // Advance the anchor to this tick's result so the NEXT tick (in
        // this same catch-up batch) diffs against its immediate
        // predecessor instead of the price from before the whole batch —
        // restores the invariant stated in the comment above the
        // `preBouncePrices` snapshot ("priceBefore MUST equal the
        // previous tick's priceAfter"), which the loop was violating for
        // ticks > 1.
        preBouncePrices[symbol] = currentPrice;

        // Track price range for peak/bottom detection
        if (!newRanges.containsKey(symbol)) {
          newRanges[symbol] = EpochPriceRange(currentPrice, currentPrice);
        } else {
          final range = newRanges[symbol]!;
          if (currentPrice < range.min) range.min = currentPrice;
          if (currentPrice > range.max) range.max = currentPrice;
        }
      }

      // Advance all active Hype events by exactly this one tick — once
      // per tick, not once per holding (see _hypeTickIncrements' peek
      // above, which one or more holdings may have just consumed).
      _advanceHypeEvents(session);

      // Snapshot this tick's resulting prices — see the `tickSnapshots`
      // comment above the loop. Timestamp walks backward from this batch's
      // anchor (`tickTimestamp`) so the LAST tick lands exactly on it,
      // matching the pre-existing single-point behavior when ticks == 1.
      tickSnapshots.add(Map<String, double>.from(newPrices));
      tickTimestamps.add(tickTimestamp - (ticks - 1 - tick) * tickIntervalMs);
    }

    // Diversification/concentration/sector-balance scoring moved to
    // evaluateStrategyPillar (psychology_engine.dart), called from
    // trades_engine.dart at trade time only — this per-tick version used
    // to fire every 20s with no cooldown, saturating strategyAdherence to
    // 0 or 1 within minutes purely from portfolio composition. Removed.

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

    // Price + real-timestamp history, built together so they can never
    // drift out of lockstep (same symbols, same append, same cap).
    //
    // Every sub-tick recorded in `tickSnapshots` above gets its own history
    // point (downsampled to at most _maxRenderPointsPerBurst if the batch
    // is large) instead of only the batch's final price — this is what
    // actually fixes the catch-up straight-line artifact. For the normal
    // live-tick path (ticks == 1) tickSnapshots has exactly one entry, so
    // behavior is unchanged from before.
    final priceHistoryUpdate = () {
      final hist = Map<String, List<double>>.from(session.priceHistory);
      final ts = Map<String, List<int>>.from(session.priceHistoryTimestamps);
      final renderIndices = _downsamplePointIndices(
        tickSnapshots.length,
        _maxRenderPointsPerBurst,
      );
      final allSymbols = <String>{
        ...session.holdings.map((h) => h.symbol),
        ...newPrices.keys,
      };
      for (final sym in allSymbols) {
        final newPts = <double>[];
        final newTs = <int>[];
        for (final i in renderIndices) {
          final p = tickSnapshots[i][sym];
          if (p != null) {
            newPts.add(p);
            newTs.add(tickTimestamps[i]);
          }
        }
        if (newPts.isEmpty) continue;
        hist[sym] = [...(hist[sym] ?? []), ...newPts];
        ts[sym] = [...(ts[sym] ?? []), ...newTs];
      }
      // Cap per-symbol history — see _maxPriceHistoryPoints. Both maps
      // trimmed identically so they stay the same length per symbol.
      for (final sym in hist.keys.toList()) {
        final points = hist[sym]!;
        if (points.length > _maxPriceHistoryPoints) {
          hist[sym] = points.sublist(points.length - _maxPriceHistoryPoints);
        }
        final symTs = ts[sym];
        if (symTs != null && symTs.length > _maxPriceHistoryPoints) {
          ts[sym] = symTs.sublist(symTs.length - _maxPriceHistoryPoints);
        }
      }
      return (hist, ts);
    }();

    // ── Price-swing radar (notifications) ────────────────────────────
    // Live-tick only (ticks<=1) — same principle as the News notification
    // gate above: a catch-up batch replaying several missed epochs at once
    // isn't a "sudden" move the user is watching happen, it's the engine
    // catching up on price history, so it must never fire this.
    if (ticks <= 1) {
      _checkPriceSwings(session, newPrices, now);
    }

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
            preCrashPrices: session.preCrashPrices,
            recoveryStartPrices: session.recoveryStartPrices,
            stabilizationDeadlines: session.stabilizationDeadlines,
            simulationSeed: session.simulationSeed,
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
            devVolatilityLabel: session.devVolatilityLabel,
            catastropheSurvivalRecorded: newCatastropheSurvivalRecorded,
            diversificationBonusRecorded: session.diversificationBonusRecorded,
            soldDuringCatastrophe: session.soldDuringCatastrophe,
            activeNewsEvent: session.activeNewsEvent,
            lastNewsCheckedEpoch: session.lastNewsCheckedEpoch,
            activeHypeEvents: session.activeHypeEvents,
            lastHypeCheckedEpoch: session.lastHypeCheckedEpoch,
            priceHistory: priceHistoryUpdate.$1,
            priceHistoryTimestamps: priceHistoryUpdate.$2,
            lastTickTimestamp: now,
            // ── Block 5 + 6: Per-company events & casino state ─
            lastEpochRollAt: session.lastEpochRollAt ?? now,
            epochHistory: session.epochHistory,
          )
        else
          state[i],
    ];
    _save();
  }

  // ── Price-swing radar (device-test feedback 2026-08-12) ────────────
  // Passive: only observes prices that already moved (via GBM/News/Hype
  // above), never generates movement itself. Periodic wall-clock sampling
  // per symbol — NOT a per-tick check — so it naturally can't fire from a
  // catch-up burst (which replays many simulated ticks within a single
  // real-world instant, never accumulating _swingCheckInterval of real
  // time between samples) even without the ticks<=1 guard at the call
  // site; the explicit guard is a second, belt-and-suspenders layer for
  // the same requirement. Up to 5 sessions can run at once (premium) —
  // each session's own snapshot map is keyed independently, so their
  // 10-minute windows naturally desync by whenever each session was last
  // opened rather than needing explicit staggering.
  void _checkPriceSwings(
    StressTestSession session,
    Map<String, double> prices,
    DateTime now,
  ) {
    final snapshots = _swingSnapshots.putIfAbsent(session.id, () => {});

    for (final h in session.holdings) {
      final price = prices[h.symbol];
      if (price == null || price <= 0) continue;

      final snap = snapshots[h.symbol];
      if (snap == null) {
        // First time seeing this holding — just establish a baseline,
        // nothing to compare against yet.
        snapshots[h.symbol] = (price: price, checkedAt: now);
        continue;
      }
      if (now.difference(snap.checkedAt) < _swingCheckInterval) continue;

      final changePct = (price - snap.price) / snap.price;
      snapshots[h.symbol] = (price: price, checkedAt: now);
      if (changePct.abs() < _swingThreshold) continue;

      final name = stressTestCompanyName(h.symbol);
      _onNotify?.call(
        AppNotification(
          id: 'notif_${DateTime.now().microsecondsSinceEpoch}',
          type: AppNotificationType.priceSwing,
          portfolioKind: NotificationPortfolioKind.stressTest,
          portfolioId: session.id,
          portfolioLabel:
              'Market Simulation — ${session.duration.displayName}',
          symbol: h.symbol,
          companyName: name,
          title:
              '$name ${changePct >= 0 ? 'jumped' : 'dropped'} '
              '${(changePct.abs() * 100).toStringAsFixed(1)}%',
          detail:
              'In your ${session.duration.displayName} test, ${h.symbol} moved '
              '${changePct >= 0 ? '+' : ''}${(changePct * 100).toStringAsFixed(1)}% '
              'over the last ~${_swingCheckInterval.inMinutes} min.',
          createdAt: DateTime.now(),
          priceSwingIsUp: changePct >= 0,
          priceSwingChangePercent: changePct.abs() * 100,
          priceSwingWindowMinutes: _swingCheckInterval.inMinutes,
        ),
      );
    }

    // Drop snapshots for symbols no longer held, so a later re-buy starts
    // a fresh baseline instead of comparing against a stale price.
    snapshots.removeWhere(
      (symbol, _) => !session.holdings.any((h) => h.symbol == symbol),
    );
  }
}
