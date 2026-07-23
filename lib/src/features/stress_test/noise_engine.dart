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
    required MarketSector sector,
    required bool hasCorrection,
    double? marketDriftRaw,
    double? sectorDriftRaw,
    double? noiseRaw,
    double? companyDriftRaw,
    double? newsRaw,
    double? hypeRaw,
  }) {
    // Raw weights for each factor (all per-tick scaled)
    double mW = (marketDriftRaw?.abs() ?? 0.0);
    double sW = (sectorDriftRaw?.abs() ?? 0.0);
    double nW = (noiseRaw?.abs() ?? 0.0);
    double cW = (companyDriftRaw?.abs() ?? 0.0);
    // Real News event (news_event.dart) takes priority when this symbol is
    // the one it's targeting; otherwise fall back to the old synthetic
    // proxy (any >5% correction gets SOME "News" attribution) for organic
    // large moves that aren't from a real News event.
    final double newsW = (newsRaw != null && newsRaw.abs() > 0.0001)
        ? newsRaw.abs()
        : (hasCorrection ? 0.15 : 0.0);
    // Real Hype event (hype/hype_event.dart) — previously computed and
    // applied to the price but never passed in here, so a sector-wide
    // Hype move had no attribution slot and got silently absorbed into
    // the other factors' proportions, showing up to the user as "mostly
    // Noise" even when Hype was the actual driver (confirmed on-device:
    // holdings 10-15% off from the rest of the portfolio with nothing but
    // Noise in the Why breakdown).
    final double hypeW = (hypeRaw?.abs() ?? 0.0);

    final double totalW = mW + sW + nW + cW + newsW + hypeW;
    if (totalW < 1e-12) {
      // No meaningful move → balanced default split
      return TickExplanation(
        epochIndex: epochIndex,
        symbol: symbol,
        priceBefore: priceBefore,
        priceAfter: priceAfter,
        contributions: const PriceContribution(
          marketPct: 40,
          sectorPct: 25,
          companyPct: 15,
          newsPct: 0,
          hypePct: 0,
          noisePct: 20,
        ),
        marketPhase: scenario.name,
        scenario: scenario.name,
      );
    }

    // Compute exact percentages
    double mPct = mW / totalW * 100;
    double sPct = sW / totalW * 100;
    double cPct = cW / totalW * 100;
    double nPct = nW / totalW * 100;
    double newsPct = newsW / totalW * 100;
    double hypePct = hypeW / totalW * 100;

    // Force exact 100 by adjusting the largest component
    double sum = mPct + sPct + cPct + nPct + newsPct + hypePct;
    final double diff = 100.0 - sum;
    if (diff.abs() > 1e-10) {
      final List<double> components = [mPct, sPct, cPct, nPct, newsPct, hypePct];
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
          cPct += diff;
          break;
        case 3:
          nPct += diff;
          break;
        case 4:
          newsPct += diff;
          break;
        case 5:
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
        companyPct: cPct.clamp(0, 100),
        newsPct: newsPct.clamp(0, 100),
        hypePct: hypePct.clamp(0, 100),
        noisePct: nPct.clamp(0, 100),
      ),
      marketPhase: scenario.name,
      scenario: scenario.name,
    );
  }

  /// Simulate current prices using sector-based market model.
  /// Each holding's price moves according to its sector's drift + noise.
  /// Virtual market is always open — rolls new casino scenarios on wall-clock.
  ///
  /// When [ticks] > 1 (catch-up mode), simulates multiple 20-second ticks
  /// in a granular loop so GBM produces smooth trajectories instead of
  /// hitting the clamp ceiling on a single mega-tick.
  void _simulateCurrentPrices(int idx, {int ticks = 1}) {
    final session = state[idx];
    if (session.holdings.isEmpty) return;

    final now = DateTime.now();

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
    final ticksPerEpoch = (rollInterval.inSeconds / _tickSeconds)
        .round()
        .clamp(1, 1 << 30);
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

    for (int tick = 0; tick < ticks; tick++) {
      // Peek once per tick (not once per holding — one Hype event can
      // target many holdings within the same tick); advanced once after
      // the holdings loop below via _advanceHypeEvents.
      final hypeIncrements = _hypeTickIncrements(session);

      final epochFraction = ticksPerEpoch > 0
          ? ((epochElapsedTicksNow - (ticks - 1 - tick)) / ticksPerEpoch)
                .clamp(0.0, 1.0)
          : 0.0;

      for (final h in session.holdings) {
        final basePrice = session.basePrices[h.symbol] ?? h.entryPrice;
        double currentPrice = newPrices[h.symbol] ?? h.entryPrice;
        final priceBefore =
            preBouncePrices[h.symbol] ??
            session.currentPrices[h.symbol] ??
            h.entryPrice;
        final sector = _getSector(h.symbol);
        final assetSector = _getAssetSector(h.symbol);
        final params = _getSectorParams(h.symbol, scenario);

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
            ? _recoveryDriftMultiplier(
                _recoveryCrashDropPct(session, h.symbol),
              )
            : 1.0;
        final rawChange =
            params.annualDrift * dtPerTick * driftMultiplier + noise + microNoise;
        final clampedChange = _clampDrift(rawChange, regime);
        currentPrice = currentPrice * (1 + clampedChange);
        // ignore: avoid_print
        print(
          '[TICK] ${h.symbol} basePrice=${basePrice.toStringAsFixed(4)} beforeGbm=${beforeGbm.toStringAsFixed(4)} afterGbm=${currentPrice.toStringAsFixed(4)} regime=${regime.name}',
        );

        // ── News micro-scenario: apply if this holding is the one hit ──
        // Mutates session.activeNewsEvent in place (advances currentTick,
        // clears to null on expiry) so multi-tick catch-up batches
        // (ticks>1) progress correctly call-by-call.
        final newsIncrement = _applyNewsEvent(session, h.symbol);
        if (newsIncrement.abs() > 0.0001) {
          currentPrice *= (1.0 + newsIncrement);
        }

        // ── Hype: apply this tick's sector increment, if this holding's
        // GICS sector currently has an active Hype event ──────────────
        final holdingGicsSector = resolveGicsSector(h.symbol);
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
        if ((currentPrice - beforeClamp).abs() > 0.0001) {
          // ignore: avoid_print
          print(
            '[CLAMP] ${h.symbol} clamped '
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
          final recoveryAnchor = session.recoveryStartPrices[h.symbol];
          if (recoveryAnchor != null && recoveryAnchor > 0) {
            final floor = recoveryAnchor * (1 - _recoveryDivergenceFloor);
            if (currentPrice < floor) currentPrice = floor;
          }
        }

        // ── Debug: log dt calibration once per app session ──────
        if (!_dtCalibrationLogged) {
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
        final stabDeadline = session.stabilizationDeadlines[h.symbol];
        if (stabDeadline != null && now.isBefore(stabDeadline)) {
          currentPrice = h.entryPrice;
        }
        newPrices[h.symbol] = currentPrice;

        // ── Explainable Simulation ────────────────────────────────
        final hasCorrection =
            priceBefore > 0 &&
            (priceBefore - currentPrice).abs() / priceBefore > 0.05;
        final expl = _explainPriceChange(
          symbol: h.symbol,
          priceBefore: priceBefore,
          priceAfter: currentPrice,
          epochIndex: currentEpoch.index,
          scenario: scenario,
          sector: sector,
          hasCorrection: hasCorrection,
          marketDriftRaw: params.annualDrift * dtPerTick * driftMultiplier,
          sectorDriftRaw:
              (params.annualDrift - avgDrift) * dtPerTick * driftMultiplier,
          noiseRaw: noise,
          newsRaw: newsIncrement,
          hypeRaw: hypeIncrement,
        );
        final symLog = <TickExplanation>[
          ...(explanations[h.symbol] ?? []),
          expl,
        ];
        explanations[h.symbol] = symLog;

        // Advance the anchor to this tick's result so the NEXT tick (in
        // this same catch-up batch) diffs against its immediate
        // predecessor instead of the price from before the whole batch —
        // restores the invariant stated in the comment above the
        // `preBouncePrices` snapshot ("priceBefore MUST equal the
        // previous tick's priceAfter"), which the loop was violating for
        // ticks > 1.
        preBouncePrices[h.symbol] = currentPrice;

        // Track price range for peak/bottom detection
        if (!newRanges.containsKey(h.symbol)) {
          newRanges[h.symbol] = EpochPriceRange(currentPrice, currentPrice);
        } else {
          final range = newRanges[h.symbol]!;
          if (currentPrice < range.min) range.min = currentPrice;
          if (currentPrice > range.max) range.max = currentPrice;
        }
      }

      // Advance all active Hype events by exactly this one tick — once
      // per tick, not once per holding (see _hypeTickIncrements' peek
      // above, which one or more holdings may have just consumed).
      _advanceHypeEvents(session);
    }

    // ── Psychology Profile: diversification / concentration ──
    if (session.holdings.length >= 2) {
      // Sector allocation
      final sectorValues = <MarketSector, double>{};
      for (final h in session.holdings) {
        final sector = _getSector(h.symbol);
        final val = h.shares * (newPrices[h.symbol] ?? h.entryPrice);
        sectorValues[sector] = (sectorValues[sector] ?? 0) + val;
      }
      final totalAssets = sectorValues.values.fold(0.0, (a, b) => a + b);
      if (totalAssets > 0) {
        for (final v in sectorValues.values) {
          if (v / totalAssets > 0.50) {
            session.psychologyProfile.recordOverconcentration();
          }
        }
      }

      // Single-asset concentration
      final maxAlloc = _calcAllocation(
        session.holdings,
        newPrices,
        session.cash,
      );
      if (maxAlloc > 0.80) {
        session.psychologyProfile.recordOverconcentration();
      } else if (maxAlloc <= 0.50) {
        session.psychologyProfile.recordGoodDiversification();
      }
    }

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
            priceHistory: () {
              final hist = Map<String, List<double>>.from(session.priceHistory);
              for (final h in session.holdings) {
                final sym = h.symbol;
                if (newPrices.containsKey(sym)) {
                  hist[sym] = [...(hist[sym] ?? []), newPrices[sym]!];
                }
              }
              for (final sym in newPrices.keys) {
                if (!hist.containsKey(sym)) {
                  hist[sym] = [newPrices[sym]!];
                }
              }
              // Cap per-symbol history — see _maxPriceHistoryPoints.
              for (final sym in hist.keys.toList()) {
                final points = hist[sym]!;
                if (points.length > _maxPriceHistoryPoints) {
                  hist[sym] = points.sublist(
                    points.length - _maxPriceHistoryPoints,
                  );
                }
              }
              return hist;
            }(),
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
}
