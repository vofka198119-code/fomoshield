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
// Trades Engine — buy/sell during setup, executeTrade during the active
// test, and portfolio allocation math.
// ---------------------------------------------------------------------------
// Extracted verbatim from stress_test_engine.dart as part of the mechanism
// split (Задание 1). No logic was changed during this move.
// ---------------------------------------------------------------------------

extension TradesEngine on StressTestNotifier {
  // ── Asset Management (Setup Phase) ───────────────────────────────

  /// Buy an asset during setup phase (real price from Finnhub).
  Future<bool> buyAssetSetup(
    String sessionId,
    String symbol,
    double amount,
    double price, {
    bool isEtf = false,
    SubscriptionTier? tier,
  }) async {
    final idx = state.indexWhere((s) => s.id == sessionId);
    if (idx < 0) return false;

    final session = state[idx];
    if (session.status != StressTestStatus.setup) return false;
    if (amount > session.cash) return false;
    if (tier != null && isStressTestSlotFrozen(state, sessionId, tier)) {
      return false;
    }

    // High-precision double: full IEEE 754, NEVER round to int
    final shares = amount / price;
    final newHoldings = [...session.holdings];
    final existingIdx = newHoldings.indexWhere((h) => h.symbol == symbol);
    if (existingIdx >= 0) {
      final existing = newHoldings[existingIdx];
      final totalShares = existing.shares + shares;
      final totalCost = existing.shares * existing.avgCost + amount;
      newHoldings[existingIdx] = StressTestHolding(
        symbol: symbol,
        shares: totalShares,
        avgCost: totalCost / totalShares,
        entryPrice: existing.entryPrice,
        cachedLogoUrl: existing.cachedLogoUrl,
        entryFsScore: existing.entryFsScore,
        isEtf: existing.isEtf,
      );
    } else {
      newHoldings.add(
        StressTestHolding(
          symbol: symbol,
          shares: shares,
          avgCost: price,
          entryPrice: price,
          isEtf: isEtf,
        ),
      );
      _fetchSafetyMarkerScore(sessionId, symbol);
      _fetchIsEtfFlag(sessionId, symbol);
    }

    final newSession = StressTestSession(
      id: session.id,
      duration: session.duration,
      startingCash: session.startingCash,
      cash: session.cash - amount,
      holdings: newHoldings,
      trades: session.trades,
      status: session.status,
      createdAt: session.createdAt,
      boughtAtPeakCount: session.boughtAtPeakCount,
      soldAtBottomCount: session.soldAtBottomCount,
      maxSingleAssetAllocation: session.maxSingleAssetAllocation,
      blackSwanSurvived: session.blackSwanSurvived,
      hasExperiencedCatastrophe: session.hasExperiencedCatastrophe,
      catastropheCooldown: session.catastropheCooldown,
      currentPrices: {...session.currentPrices, symbol: price},
      basePrices: {...session.basePrices, symbol: price},
      preCrashPrices: session.preCrashPrices,
      recoveryStartPrices: session.recoveryStartPrices,
      psychologyProfile: session.psychologyProfile,
      activeNewsEvent: session.activeNewsEvent,
      lastNewsCheckedEpoch: session.lastNewsCheckedEpoch,
      activeHypeEvents: session.activeHypeEvents,
      lastHypeCheckedEpoch: session.lastHypeCheckedEpoch,
      priceHistory: {
        ...session.priceHistory,
        symbol: [...(session.priceHistory[symbol] ?? []), price],
      },
      priceHistoryTimestamps: {
        ...session.priceHistoryTimestamps,
        symbol: [
          ...(session.priceHistoryTimestamps[symbol] ?? []),
          DateTime.now().millisecondsSinceEpoch,
        ],
      },
      explanationLog: session.explanationLog,
      currentWeights: session.currentWeights,
      soldDuringCatastrophe: session.soldDuringCatastrophe,
      catastropheSurvivalRecorded: session.catastropheSurvivalRecorded,
      lastEpochRollAt: session.lastEpochRollAt,
      epochHistory: session.epochHistory,
    );
    newSession.epochPriceRanges = {...session.epochPriceRanges};
    newSession.epochPriceRanges[symbol] = EpochPriceRange(price, price);

    // ── Strategy pillar (diversification/concentration/sector/ETF/cash) ──
    final newCash = session.cash - amount;
    evaluateStrategyPillar(
      profile: newSession.psychologyProfile,
      holdings: newHoldings,
      cash: newCash,
    );

    state = [
      for (int i = 0; i < state.length; i++)
        if (i == idx) newSession else state[i],
    ];
    _save();
    return true;
  }

  /// Remove an asset during setup phase.
  void removeAssetSetup(String sessionId, String symbol, {SubscriptionTier? tier}) {
    final idx = state.indexWhere((s) => s.id == sessionId);
    if (idx < 0) return;

    final session = state[idx];
    if (session.status != StressTestStatus.setup) return;
    if (tier != null && isStressTestSlotFrozen(state, sessionId, tier)) return;

    final holding = session.holdings.firstWhere(
      (h) => h.symbol == symbol,
      orElse: () => const StressTestHolding(
        symbol: '',
        shares: 0,
        avgCost: 0,
        entryPrice: 0,
        cachedLogoUrl: null,
      ),
    );
    if (holding.symbol.isEmpty) return;

    final refund = holding.shares * holding.avgCost;

    state = [
      for (int i = 0; i < state.length; i++)
        if (i == idx)
          StressTestSession(
            id: session.id,
            duration: session.duration,
            startingCash: session.startingCash,
            cash: session.cash + refund,
            holdings: session.holdings
                .where((h) => h.symbol != symbol)
                .toList(),
            trades: session.trades,
            status: session.status,
            createdAt: session.createdAt,
            boughtAtPeakCount: session.boughtAtPeakCount,
            soldAtBottomCount: session.soldAtBottomCount,
            maxSingleAssetAllocation: session.maxSingleAssetAllocation,
            blackSwanSurvived: session.blackSwanSurvived,
            hasExperiencedCatastrophe: session.hasExperiencedCatastrophe,
            catastropheCooldown: session.catastropheCooldown,
            currentPrices: Map.from(session.currentPrices)..remove(symbol),
            basePrices: Map.from(session.basePrices)..remove(symbol),
            preCrashPrices: Map.from(session.preCrashPrices)..remove(symbol),
            recoveryStartPrices: Map.from(session.recoveryStartPrices)
              ..remove(symbol),
            psychologyProfile: session.psychologyProfile,
            activeNewsEvent: session.activeNewsEvent,
            lastNewsCheckedEpoch: session.lastNewsCheckedEpoch,
            activeHypeEvents: session.activeHypeEvents,
            lastHypeCheckedEpoch: session.lastHypeCheckedEpoch,
            priceHistory: Map.from(session.priceHistory)..remove(symbol),
            priceHistoryTimestamps: Map.from(session.priceHistoryTimestamps)
              ..remove(symbol),
            explanationLog: session.explanationLog,
            currentWeights: session.currentWeights,
            soldDuringCatastrophe: session.soldDuringCatastrophe,
            diversificationBonusRecorded: session.diversificationBonusRecorded,
            catastropheSurvivalRecorded: session.catastropheSurvivalRecorded,
            lastEpochRollAt: session.lastEpochRollAt,
            epochHistory: session.epochHistory,
          )
        else
          state[i],
    ];
    _save();
  }

  // ── Trading During Active Test ────────────────────────────────────

  /// Execute a trade within an active stress test session.
  /// Returns true if successful, false if insufficient funds/shares.
  TradeResult executeTrade(
    String sessionId,
    String symbol,
    bool isBuy,
    double amountOrShares, {
    bool useShares = false,
    bool isEtf = false,
    AppLocalizations? l10n,
    SubscriptionTier? tier,
  }) {
    final idx = state.indexWhere((s) => s.id == sessionId);
    if (idx < 0) {
      return TradeResult(
        success: false,
        reason: l10n?.stressTestSessionNotFound ?? 'Session not found',
      );
    }

    final session = state[idx];
    if (session.status != StressTestStatus.active) {
      return TradeResult(
        success: false,
        reason: l10n?.tradesEngineTestNotActive ?? 'Test not active',
      );
    }

    // Slot #2/#3 frozen — trading blocked once the tier drops back to
    // free, until Premium is renewed. Caller passes tier == null to skip
    // this check (e.g. system-driven fills where it's already been
    // checked upstream); pass the real tier for anything user-initiated.
    if (tier != null && isStressTestSlotFrozen(state, sessionId, tier)) {
      return TradeResult(
        success: false,
        reason: l10n?.tradesEngineSlotFrozen ?? 'This test is frozen.',
      );
    }

    // Virtual market is always open — no market-hour trading restrictions.

    final currentPrice = session.currentPrices[symbol] ?? 0;
    if (currentPrice <= 0) {
      return TradeResult(
        success: false,
        reason: l10n?.tradesEnginePriceNotAvailable ?? 'Price not available',
      );
    }

    // Check ad counter for free users
    // (ad checking is done by the UI)

    double shares;
    double cost;

    if (useShares) {
      shares = amountOrShares;
      cost = shares * currentPrice;
    } else {
      cost = amountOrShares;
      // High-precision double division — full IEEE 754 precision preserved
      // (15+ significant digits), NEVER round to int or .00 here.
      shares = currentPrice > 0 ? cost / currentPrice : 0;
    }

    if (shares <= 0 || cost <= 0) {
      return TradeResult(
        success: false,
        reason: l10n?.tradesEngineInvalidAmount ?? 'Invalid amount',
      );
    }

    if (isBuy) {
      if (cost > session.cash) {
        return TradeResult(
          success: false,
          reason: l10n?.tradesEngineInsufficientCash ?? 'Insufficient cash',
        );
      }
    } else {
      final heldShares = session.holdings
          .firstWhere(
            (h) => h.symbol == symbol,
            orElse: () => const StressTestHolding(
              symbol: '',
              shares: 0,
              avgCost: 0,
              entryPrice: 0,
              cachedLogoUrl: null,
            ),
          )
          .shares;
      // Clamp sell shares to held shares with epsilon tolerance
      if (shares > heldShares) {
        if (shares <= heldShares + 0.000001) {
          shares = heldShares;
        } else {
          return TradeResult(
            success: false,
            reason:
                l10n?.tradesEngineInsufficientShares ?? 'Insufficient shares',
          );
        }
      }
    }

    // Detect peak/bottom
    final range = session.epochPriceRanges[symbol];
    bool wasPeak = false;
    bool wasBottom = false;
    if (range != null && (range.max - range.min) > 0.01) {
      final peakPrice = range.max;
      final bottomPrice = range.min;
      final threshold = (range.max - range.min) * 0.10;
      wasPeak = isBuy && (currentPrice >= peakPrice - threshold);
      wasBottom = !isBuy && (currentPrice <= bottomPrice + threshold);
    }

    // ── Calculate realized P&L on sell ───────────────────────────────
    double? realizedPnl;
    double? realizedCostBasis;
    if (!isBuy) {
      final held = session.holdings.firstWhere(
        (h) => h.symbol == symbol,
        orElse: () => const StressTestHolding(
          symbol: '',
          shares: 0,
          avgCost: 0,
          entryPrice: 0,
          cachedLogoUrl: null,
        ),
      );
      if (held.shares > 0) {
        final soldShares = shares.clamp(0, held.shares);
        realizedPnl = (currentPrice - held.avgCost) * soldShares;
        realizedCostBasis = held.avgCost * soldShares;
      }
    }

    final trade = StressTestTrade(
      symbol: symbol,
      isBuy: isBuy,
      shares: shares,
      price: currentPrice,
      date: DateTime.now(),
      wasPeak: wasPeak,
      wasBottom: wasBottom,
      realizedPnl: realizedPnl,
    );

    // Update holdings
    final newHoldings = [...session.holdings];
    if (isBuy) {
      final existingIdx = newHoldings.indexWhere((h) => h.symbol == symbol);
      if (existingIdx >= 0) {
        final existing = newHoldings[existingIdx];
        final totalShares = existing.shares + shares;
        final totalCost = existing.shares * existing.avgCost + cost;
        newHoldings[existingIdx] = StressTestHolding(
          symbol: symbol,
          shares: totalShares,
          avgCost: totalCost / totalShares,
          entryPrice: currentPrice,
          cachedLogoUrl: existing.cachedLogoUrl,
          entryFsScore: existing.entryFsScore,
          isEtf: existing.isEtf,
        );
      } else {
        newHoldings.add(
          StressTestHolding(
            symbol: symbol,
            shares: shares,
            avgCost: currentPrice,
            entryPrice: currentPrice,
            isEtf: isEtf,
          ),
        );
        _fetchSafetyMarkerScore(sessionId, symbol);
        _fetchIsEtfFlag(sessionId, symbol);
      }
    } else {
      final existingIdx = newHoldings.indexWhere((h) => h.symbol == symbol);
      if (existingIdx >= 0) {
        final existing = newHoldings[existingIdx];
        final remainingShares = existing.shares - shares;
        if (remainingShares <= 0.0001) {
          newHoldings.removeAt(existingIdx);
        } else {
          newHoldings[existingIdx] = StressTestHolding(
            symbol: symbol,
            shares: remainingShares,
            avgCost: existing.avgCost,
            entryPrice: existing.entryPrice,
            cachedLogoUrl: existing.cachedLogoUrl,
            entryFsScore: existing.entryFsScore,
          );
        }
      }
    }

    final newCash = isBuy ? session.cash - cost : session.cash + cost;
    final newBoughtPeak = wasPeak
        ? session.boughtAtPeakCount + 1
        : session.boughtAtPeakCount;
    final newSoldBottom = wasBottom
        ? session.soldAtBottomCount + 1
        : session.soldAtBottomCount;
    final newMaxAlloc = max(
      session.maxSingleAssetAllocation,
      _calcAllocation(newHoldings, session.currentPrices, newCash),
    );
    final newRealizedPnl = realizedPnl != null
        ? session.realizedPnl + realizedPnl
        : session.realizedPnl;

    // ── Stabilization Period ───────────────────────────────────
    // After buy, freeze price at entryPrice for 30 seconds
    final newStabilizationDeadlines = Map<String, DateTime>.from(
      session.stabilizationDeadlines,
    );
    if (isBuy) {
      newStabilizationDeadlines[symbol] = DateTime.now().add(
        const Duration(seconds: 30),
      );
    }

    // Check if black swan survived
    bool newBlackSwanSurvived = session.blackSwanSurvived;
    if (!isBuy && session.hasExperiencedCatastrophe) {
      // User sold during/after catastrophe — doesn't count as survived
      newBlackSwanSurvived = false;
    }

    // ── Psychology: regime/context-aware trade evaluation ──────
    // Trade COUNT itself is tracked separately as a verdict-only
    // narrative (see Phase 2e), not a live score driver — replaces the
    // old flat per-trade discipline/patience tax that applied regardless
    // of whether the trade itself was good or bad. Buy evaluation
    // happens further down (needs newHoldings/newCash computed above);
    // sell evaluation happens here.
    if (!isBuy) {
      evaluateSellTrade(
        profile: session.psychologyProfile,
        session: session,
        symbol: symbol,
        sellPrice: currentPrice,
        realizedPnl: realizedPnl,
        realizedCostBasis: realizedCostBasis,
      );
    }
    evaluateStrategyPillar(
      profile: session.psychologyProfile,
      holdings: newHoldings,
      cash: newCash,
    );

    // ── Psychology: regime-aware buy evaluation (see psychology_engine.dart) ──
    if (isBuy) {
      final totalValueAfterBuy =
          newCash +
          newHoldings.fold<double>(
            0,
            (sum, h) =>
                sum +
                h.shares * (session.currentPrices[h.symbol] ?? h.entryPrice),
          );
      evaluateBuyTrade(
        profile: session.psychologyProfile,
        session: session,
        symbol: symbol,
        macroRegime: _getCurrentEpoch(session)?.scenario,
        cashAfterBuy: newCash,
        totalValueAfterBuy: totalValueAfterBuy,
      );
    }

    // ── Task 1.5: Track sells during catastrophe ──
    if (!isBuy) {
      final currentEpoch = _getCurrentEpoch(session);
      if (currentEpoch != null && currentEpoch.scenario.isCatastrophe) {
        session.soldDuringCatastrophe = {
          ...session.soldDuringCatastrophe,
          symbol,
        };
      }
    }

    // Trade frequency is no longer a live-score penalty — see Phase 2e:
    // it's tracked as a verdict-only narrative (session.trades.length is
    // already available there), not blended into strategyAdherence. The
    // old version divided by session.epochHistory.length, which stays at
    // 1 for the entire first roll interval (12-24h) — meaning simply
    // buying 4 diversified positions on day one (exactly the behavior the
    // diversification bonus rewards) instantly triggered the MAXIMUM
    // frequency penalty. Don't reintroduce a live per-trade-count penalty
    // without fixing that denominator first.

    state = [
      for (int i = 0; i < state.length; i++)
        if (i == idx)
          StressTestSession(
            id: session.id,
            duration: session.duration,
            startingCash: session.startingCash,
            cash: newCash,
            holdings: newHoldings,
            trades: [...session.trades, trade],
            status: session.status,
            createdAt: session.createdAt,
            startedAt: session.startedAt,
            completedAt: session.completedAt,
            boughtAtPeakCount: newBoughtPeak,
            soldAtBottomCount: newSoldBottom,
            maxSingleAssetAllocation: newMaxAlloc,
            blackSwanSurvived: newBlackSwanSurvived,
            hasExperiencedCatastrophe: session.hasExperiencedCatastrophe,
            catastropheCooldown: session.catastropheCooldown,
            // ── Casino Wall-Clock State — must survive every trade ──────
            // Previously omitted here, silently resetting to their
            // constructor defaults (0/0/0/-100) on every buy/sell during
            // an active test: wiped the post-catastrophe cooldown and the
            // 6-epoch minimum-gap tracking the instant the user traded,
            // making catastrophes roll far more often than the casino
            // engine intends. Confirmed empirically during the
            // Volatility-lock investigation (ruled out as that bug's
            // cause, but real on its own).
            casinoCatastropheCooldown: session.casinoCatastropheCooldown,
            casinoDeclineStreak: session.casinoDeclineStreak,
            casinoCatastropheCount: session.casinoCatastropheCount,
            casinoLastCatastropheEpoch: session.casinoLastCatastropheEpoch,
            currentPrices: session.currentPrices,
            basePrices: session.basePrices,
            epochPriceRanges: session.epochPriceRanges,
            preCrashPrices: session.preCrashPrices,
            recoveryStartPrices: session.recoveryStartPrices,
            realizedPnl: newRealizedPnl,
            customDurationDays: session.customDurationDays,
            stabilizationDeadlines: newStabilizationDeadlines,
            psychologyProfile: session.psychologyProfile,
            simulationSeed: session.simulationSeed,
            enableDeveloperTrace: session.enableDeveloperTrace,
            explanationLog: session.explanationLog,
            currentWeights: session.currentWeights,
            priceHistory: session.priceHistory,
            priceHistoryTimestamps: session.priceHistoryTimestamps,
            // lastTickTimestamp drives _catchUp's granular-tick fallback
            // chain (lastTickTimestamp ?? lastEpochRollAt ?? startedAt) —
            // was also silently dropped here, reverting to null and
            // making catch-up fall back to a coarser anchor right after
            // any trade.
            lastTickTimestamp: session.lastTickTimestamp,
            catastropheSurvivalRecorded: session.catastropheSurvivalRecorded,
            diversificationBonusRecorded: session.diversificationBonusRecorded,
            soldDuringCatastrophe: session.soldDuringCatastrophe,
            activeNewsEvent: session.activeNewsEvent,
            lastNewsCheckedEpoch: session.lastNewsCheckedEpoch,
            activeHypeEvents: session.activeHypeEvents,
            lastHypeCheckedEpoch: session.lastHypeCheckedEpoch,
            lastEpochRollAt: session.lastEpochRollAt,
            epochHistory: session.epochHistory,
          )
        else
          state[i],
    ];
    _save();
    _syncToSupabase();
    return TradeResult(success: true, reason: '');
  }

  double _calcAllocation(
    List<StressTestHolding> holdings,
    Map<String, double> prices,
    double cash,
  ) {
    double totalValue = cash;
    for (final h in holdings) {
      totalValue += h.shares * (prices[h.symbol] ?? h.entryPrice);
    }
    if (totalValue <= 0) return 0;
    double maxVal = 0;
    for (final h in holdings) {
      final val = h.shares * (prices[h.symbol] ?? h.entryPrice);
      if (val > maxVal) maxVal = val;
    }
    return maxVal / totalValue;
  }

  /// Fires off a one-time fetch of [symbol]'s FS Score for the "Safety
  /// Marker" signal, right after its FIRST purchase in this session —
  /// never re-fetched or overwritten by later buys/sells of the same
  /// symbol. Fire-and-forget: doesn't block the buy that triggered it,
  /// patches the holding's `entryFsScore` in place once resolved.
  ///
  /// Uses a plain `FinnhubService()` + `ScoringEngine.calculate()` call
  /// directly (no sectorPe/priceCagr5Y — those two markers just stay
  /// neutral 50, a documented fallback in scoring_engine.dart) rather
  /// than going through `companyDetailProvider`, since StressTestNotifier
  /// isn't constructed with a Riverpod `Ref` to read that provider.
  void _fetchSafetyMarkerScore(String sessionId, String symbol) {
    FinnhubService()
        .metrics(symbol)
        .then((metrics) {
          final score = ScoringEngine.calculate(metrics);
          final fs = (score?['financial_score'] as num?)?.toDouble();
          if (fs == null) return;

          final i = state.indexWhere((s) => s.id == sessionId);
          if (i < 0) return;
          final s = state[i];
          final hIdx = s.holdings.indexWhere((h) => h.symbol == symbol);
          if (hIdx < 0 || s.holdings[hIdx].entryFsScore != null) return;

          final existing = s.holdings[hIdx];
          s.holdings = [
            for (int j = 0; j < s.holdings.length; j++)
              if (j == hIdx)
                StressTestHolding(
                  symbol: existing.symbol,
                  shares: existing.shares,
                  avgCost: existing.avgCost,
                  entryPrice: existing.entryPrice,
                  cachedLogoUrl: existing.cachedLogoUrl,
                  entryFsScore: fs,
                  isEtf: existing.isEtf,
                )
              else
                s.holdings[j],
          ];
          state = [...state];
          _save();
        })
        .catchError((_) {});
  }

  /// Fires off a one-time check of whether [symbol] is a real ETF (via
  /// Finnhub's own `type` field, same signal the search UI already shows
  /// — see stress_test_search_sheet.dart), right after its FIRST purchase.
  /// Only ever flips `isEtf` false → true, never the reverse, so it's
  /// safe to call unconditionally for every new holding regardless of
  /// which UI path bought it — covers buys that come through the general
  /// Search screen → stock detail → Order Entry chain, which has no way
  /// to thread the search result's `type` field through 3 screens.
  /// Confirmed real bug 2026-08-06: ETF Exposure never moved for SCJ/PPH
  /// bought that way (only in AssetSector.etfBroadMarket's small static
  /// list, which neither is).
  void _fetchIsEtfFlag(String sessionId, String symbol) {
    FinnhubService()
        .search(symbol)
        .then((results) {
          final isEtf = results.any((r) {
            final rSymbol = (r['symbol'] as String? ?? '').split('.').first;
            return rSymbol.toUpperCase() == symbol.toUpperCase() &&
                isEtfSecurityType(r['type'] as String?);
          });
          if (!isEtf) return;

          final i = state.indexWhere((s) => s.id == sessionId);
          if (i < 0) return;
          final s = state[i];
          final hIdx = s.holdings.indexWhere((h) => h.symbol == symbol);
          if (hIdx < 0 || s.holdings[hIdx].isEtf) return;

          final existing = s.holdings[hIdx];
          s.holdings = [
            for (int j = 0; j < s.holdings.length; j++)
              if (j == hIdx)
                StressTestHolding(
                  symbol: existing.symbol,
                  shares: existing.shares,
                  avgCost: existing.avgCost,
                  entryPrice: existing.entryPrice,
                  cachedLogoUrl: existing.cachedLogoUrl,
                  entryFsScore: existing.entryFsScore,
                  isEtf: true,
                )
              else
                s.holdings[j],
          ];
          state = [...state];
          _save();
        })
        .catchError((_) {});
  }
}

/// Result of a trade execution.
class TradeResult {
  final bool success;
  final String reason;

  const TradeResult({required this.success, required this.reason});
}
