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
    double price,
  ) async {
    final idx = state.indexWhere((s) => s.id == sessionId);
    if (idx < 0) return false;

    final session = state[idx];
    if (session.status != StressTestStatus.setup) return false;
    if (amount > session.cash) return false;

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
      );
    } else {
      newHoldings.add(
        StressTestHolding(
          symbol: symbol,
          shares: shares,
          avgCost: price,
          entryPrice: price,
        ),
      );
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
      psychologyProfile: session.psychologyProfile,
      activeNewsEvent: session.activeNewsEvent,
      lastNewsCheckedEpoch: session.lastNewsCheckedEpoch,
      priceHistory: {
        ...session.priceHistory,
        symbol: [...(session.priceHistory[symbol] ?? []), price],
      },
      explanationLog: session.explanationLog,
      currentWeights: session.currentWeights,
      soldDuringCatastrophe: session.soldDuringCatastrophe,
      catastropheSurvivalRecorded: session.catastropheSurvivalRecorded,
      specEvents: session.specEvents,
      specEventCooldowns: session.specEventCooldowns,
      lastSpecEventCheckAt: session.lastSpecEventCheckAt,
      lastEpochRollAt: session.lastEpochRollAt,
      epochHistory: session.epochHistory,
    );
    newSession.epochPriceRanges = {...session.epochPriceRanges};
    newSession.epochPriceRanges[symbol] = EpochPriceRange(price, price);

    // ── Task 1.5: Strategy — diversification bonus ────────────
    if (!session.diversificationBonusRecorded && newHoldings.length >= 2) {
      final sectors = newHoldings.map((h) => _getSector(h.symbol)).toSet();
      newSession.psychologyProfile.recordStrategyDiversification(
        sectors.length,
      );
      newSession.diversificationBonusRecorded = true;
    }

    // ── Task 1.5: Strategy — cash buffer ──────────────────────
    final newCash = session.cash - amount;
    final bufferRatio = newCash / session.startingCash;
    if (bufferRatio > 0.1) {
      newSession.psychologyProfile.recordCashBuffer();
    }

    state = [
      for (int i = 0; i < state.length; i++)
        if (i == idx) newSession else state[i],
    ];
    _save();
    return true;
  }

  /// Remove an asset during setup phase.
  void removeAssetSetup(String sessionId, String symbol) {
    final idx = state.indexWhere((s) => s.id == sessionId);
    if (idx < 0) return;

    final session = state[idx];
    if (session.status != StressTestStatus.setup) return;

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
            psychologyProfile: session.psychologyProfile,
            activeNewsEvent: session.activeNewsEvent,
            lastNewsCheckedEpoch: session.lastNewsCheckedEpoch,
            priceHistory: Map.from(session.priceHistory)..remove(symbol),
            explanationLog: session.explanationLog,
            currentWeights: session.currentWeights,
            soldDuringCatastrophe: session.soldDuringCatastrophe,
            diversificationBonusRecorded: session.diversificationBonusRecorded,
            catastropheSurvivalRecorded: session.catastropheSurvivalRecorded,
            specEvents: session.specEvents,
            specEventCooldowns: session.specEventCooldowns,
            lastSpecEventCheckAt: session.lastSpecEventCheckAt,
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
  }) {
    final idx = state.indexWhere((s) => s.id == sessionId);
    if (idx < 0) {
      return TradeResult(success: false, reason: 'Session not found');
    }

    final session = state[idx];
    if (session.status != StressTestStatus.active) {
      return TradeResult(success: false, reason: 'Test not active');
    }

    // Virtual market is always open — no market-hour trading restrictions.

    final currentPrice = session.currentPrices[symbol] ?? 0;
    if (currentPrice <= 0) {
      return TradeResult(success: false, reason: 'Price not available');
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
      return TradeResult(success: false, reason: 'Invalid amount');
    }

    if (isBuy) {
      if (cost > session.cash) {
        return TradeResult(success: false, reason: 'Insufficient cash');
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
          return TradeResult(success: false, reason: 'Insufficient shares');
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
        realizedPnl =
            (currentPrice - held.avgCost) * shares.clamp(0, held.shares);
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
        );
      } else {
        newHoldings.add(
          StressTestHolding(
            symbol: symbol,
            shares: shares,
            avgCost: currentPrice,
            entryPrice: currentPrice,
          ),
        );
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

    // ── Psychology Profile: record trade behavior ─────────────
    session.psychologyProfile.recordTradeExecuted();
    if (wasPeak) session.psychologyProfile.recordBuyPeak();
    if (wasBottom) session.psychologyProfile.recordSellBottom();
    if (!isBuy && realizedPnl != null) {
      if (realizedPnl > 0) {
        session.psychologyProfile.recordProfitTaking();
      } else if (realizedPnl < 0) {
        session.psychologyProfile.recordLossCut();
      }
    }

    // ── Task 1.5: Discipline — buy low (green zone) / buy high (red zone) ──
    if (isBuy) {
      final phase = session.devMarketPhase.toLowerCase();
      final isGreen =
          phase == 'blackswan' ||
          phase == 'black_swan' ||
          phase == 'crash' ||
          phase == 'bear';
      final isRed = phase == 'hype' || phase == 'bull';
      if (isGreen) {
        session.psychologyProfile.recordBuyLow();
      } else if (isRed) {
        session.psychologyProfile.recordBuyHighFomo();
      }

      // ── Task 1.5: Strategy — cash buffer ──
      final bufferRatio = newCash / session.startingCash;
      if (bufferRatio > 0.1) {
        session.psychologyProfile.recordCashBuffer();
      }
    }

    // ── Task 1.5: Panic — panic selling at a loss in green zone ──
    if (!isBuy && realizedPnl != null && realizedPnl < 0) {
      final phase = session.devMarketPhase.toLowerCase();
      final isGreen =
          phase == 'blackswan' ||
          phase == 'black_swan' ||
          phase == 'crash' ||
          phase == 'bear';
      if (isGreen) {
        session.psychologyProfile.recordPanicSell();
      }
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

    // ── Task 1.5: Strategy — trade frequency deduction ──
    // Only applies AFTER initial portfolio setup (3+ trades).
    // During setup, a disciplined user needs 3+ trades for the
    // Diversification Bonus — penalizing early trades would
    // create a "First Move" trap where Epoch 1 ratio ≥ 3.0
    // triggers the maximum penalty instantly.
    final newTradeCount = session.trades.length + 1;
    if (newTradeCount >= 4) {
      session.psychologyProfile.recordTradeFrequencyDeduction(
        newTradeCount,
        session.epochHistory.length,
      );
    }

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
            realizedPnl: newRealizedPnl,
            customDurationDays: session.customDurationDays,
            stabilizationDeadlines: newStabilizationDeadlines,
            psychologyProfile: session.psychologyProfile,
            simulationSeed: session.simulationSeed,
            enableDeveloperTrace: session.enableDeveloperTrace,
            companies: session.companies,
            explanationLog: session.explanationLog,
            currentWeights: session.currentWeights,
            priceHistory: session.priceHistory,
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
            specEvents: session.specEvents,
            specEventCooldowns: session.specEventCooldowns,
            lastSpecEventCheckAt: session.lastSpecEventCheckAt,
            lastEpochRollAt: session.lastEpochRollAt,
            epochHistory: session.epochHistory,
          )
        else
          state[i],
    ];
    _save();
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
}

/// Result of a trade execution.
class TradeResult {
  final bool success;
  final String reason;

  const TradeResult({required this.success, required this.reason});
}
