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
  }) {
    // Raw weights for each factor (all per-tick scaled)
    double mW = (marketDriftRaw?.abs() ?? 0.0);
    double sW = (sectorDriftRaw?.abs() ?? 0.0);
    double nW = (noiseRaw?.abs() ?? 0.0);
    double cW = (companyDriftRaw?.abs() ?? 0.0);
    final double newsW = hasCorrection ? 0.15 : 0.0;

    final double totalW = mW + sW + nW + cW + newsW;
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

    // Force exact 100 by adjusting the largest component
    double sum = mPct + sPct + cPct + nPct + newsPct;
    final double diff = 100.0 - sum;
    if (diff.abs() > 1e-10) {
      final List<double> components = [mPct, sPct, cPct, nPct, newsPct];
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

    // ── Block 5: Spec/Hype weekly wall-clock check ──────────────────
    // Runs at most once per call (regardless of the `ticks` batch size),
    // gated on real elapsed time rather than epoch rolls — epoch length
    // varies per test type (Block 6: 12h/24h/7d/5d), so tying this to the
    // epoch counter would fire far more often than the intended weekly
    // cadence. Mirrors the lastEpochRollAt pattern used for casino state.
    final lastSpecCheck =
        session.lastSpecEventCheckAt ?? session.startedAt ?? now;
    if (now.difference(lastSpecCheck) >= const Duration(days: 7)) {
      for (final h in session.holdings) {
        final newSpecEvent = _maybeFireSpecEvent(session, h.symbol, rng, now);
        if (newSpecEvent != null) {
          session.specEvents = [...session.specEvents, newSpecEvent];
        }
      }
      session.lastSpecEventCheckAt = now;
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

    // ── Sandbox Isolation (Step 3): Shock decay tracking ────────
    MarketShock? newActiveShock = session.activeShock;

    for (int tick = 0; tick < ticks; tick++) {
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
        final rawChange = params.annualDrift * dtPerTick + noise + microNoise;
        final clampedChange = _clampDrift(rawChange, regime);
        currentPrice = currentPrice * (1 + clampedChange);
        // ignore: avoid_print
        print(
          '[TICK] ${h.symbol} basePrice=${basePrice.toStringAsFixed(4)} beforeGbm=${beforeGbm.toStringAsFixed(4)} afterGbm=${currentPrice.toStringAsFixed(4)} regime=${regime.name}',
        );

        // ── Sandbox Isolation (Step 3): Apply active market shock ──
        final shock = session.activeShock;
        if (shock != null) {
          if (shock.isExpired) {
            newActiveShock = null; // clear expired shock
          } else {
            currentPrice *= (1.0 + shock.currentAmplitude);
          }
        }

        // ── Block 5: Apply per-company spec/hype bell-shape event ──
        // Firing is decided once per weekly wall-clock window, before this
        // loop (see the lastSpecEventCheckAt check above). Here we only
        // advance/apply the amplitude of whatever is currently active.
        final specAmplitude = _applySpecEvents(session, h.symbol);
        if (specAmplitude.abs() > 0.0001) {
          currentPrice *= (1.0 + specAmplitude);
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
          marketDriftRaw: params.annualDrift * dtPerTick,
          sectorDriftRaw: (params.annualDrift - avgDrift) * dtPerTick,
          noiseRaw: noise,
          companyDriftRaw: specAmplitude,
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
            stabilizationDeadlines: session.stabilizationDeadlines,
            simulationSeed: session.simulationSeed,
            companies: session.companies,
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
            devNextEvent: session.devNextEvent,
            devNextEventDays: session.devNextEventDays,
            devVolatilityLabel: session.devVolatilityLabel,
            catastropheSurvivalRecorded: newCatastropheSurvivalRecorded,
            diversificationBonusRecorded: session.diversificationBonusRecorded,
            soldDuringCatastrophe: session.soldDuringCatastrophe,
            activeShock: newActiveShock,
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
              return hist;
            }(),
            lastTickTimestamp: now,
            // ── Block 5 + 6: Per-company events & casino state ─
            specEvents: session.specEvents,
            specEventCooldowns: session.specEventCooldowns,
            lastSpecEventCheckAt: session.lastSpecEventCheckAt,
            lastEpochRollAt: session.lastEpochRollAt ?? now,
            epochHistory: session.epochHistory,
          )
        else
          state[i],
    ];
    _save();
  }
}
