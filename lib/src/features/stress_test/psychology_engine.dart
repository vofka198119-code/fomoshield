// ---------------------------------------------------------------------------
// Psychology Engine — trade-time evaluation logic for TraderPsychologyProfile
// ---------------------------------------------------------------------------
// Everything here is called from trades_engine.dart at the moment a trade
// executes (buy or sell) — never per-tick. See project memory for the full
// redesign spec this implements.
// ---------------------------------------------------------------------------

import 'dart:math' as math;
import '../../core/services/gics_sector_mapper.dart';
import '../assets/screens/stock_detail/widgets/stock_detail_helpers.dart';
import 'stress_test_models.dart';

// Diversification score vs. holdings count — non-monotonic (too few AND
// too many holdings both score low). Single source of truth, shared with
// stress_test_portfolio_health_widget.dart's Diversification gauge — keep
// them using this same curve, don't let them drift apart.
//
// 5-tier curve confirmed 2026-08-06, tuned around the $15k stress-test
// budget (see sector_diversification_tiers.dart for the matching verdict
// copy — keep the tier boundaries here and there in sync):
//   1-2   concentrated ("all your eggs in one basket")
//   3-4   building a foundation
//   5-15  golden middle — flat peak, the intended sweet spot
//   16-24 excellent, but watch business quality as it grows
//   25+   overloaded ("a zoo") — declining the more it grows
const List<MapEntry<double, double>> diversificationStops = [
  MapEntry(1, 15),
  MapEntry(2, 15),
  MapEntry(4, 45),
  MapEntry(5, 92),
  MapEntry(15, 92),
  MapEntry(16, 75),
  MapEntry(24, 60),
  MapEntry(25, 35),
  MapEntry(40, 15),
];

/// 0-100 diversification score for a given holdings count.
double diversificationScoreForCount(double count) {
  final stops = diversificationStops;
  final clamped = count.clamp(stops.first.key, stops.last.key);
  for (var i = 0; i < stops.length - 1; i++) {
    final a = stops[i];
    final b = stops[i + 1];
    if (clamped <= b.key) {
      final t = (clamped - a.key) / (b.key - a.key);
      return a.value + (b.value - a.value) * t;
    }
  }
  return stops.last.value;
}

// ETF Exposure score vs. count of DISTINCT ETFs held — non-monotonic, peaks
// at 2-3 (enough for broad-market ballast without duplicating the same
// index under different tickers). Step function, not interpolated, since
// the input is always a small integer — keep the bands in sync with
// etf_exposure_tiers.dart's verdict copy:
//   0     No Safety Net — no index-fund ballast at all
//   1     A Step Toward Stability — a start, still stock-picking-dependent
//   2-3   A Strong Core — the intended sweet spot (broad market + optional
//         international/bonds), the ideal
//   4-6   Broadly Diversified — still good, first real overlaps appear
//   7+    Too Many Roads to the Same Destination — safe but redundant,
//         dilutes any edge from picking individual stocks
double etfExposureScoreForCount(int etfCount) {
  if (etfCount <= 0) return 10;
  if (etfCount == 1) return 35;
  if (etfCount <= 3) return 95;
  if (etfCount <= 6) return 85;
  return 70;
}

/// A symbol's price range across the WHOLE test, not just the current
/// epoch — used to judge how close a sale was to the test's real bottom
/// (panic-selling severity), regardless of which epoch it happened in.
///
/// Deliberately derived from [StressTestSession.priceHistory] (already
/// persisted every trade/tick, already survives app restart correctly)
/// instead of a new tracked field — the previous per-epoch tracker
/// (`epochPriceRanges`) resets to a single point on every app reload
/// (`fromJson` re-seeds it from the current price), which would silently
/// erase the test's real history right when it matters most. Reusing
/// `priceHistory` avoids adding another map that needs threading through
/// every session-copy call site.
///
/// Caveat: `priceHistory` is capped at `_maxPriceHistoryPoints` (5000)
/// per symbol — an extremely long-running test could in theory trim off
/// its true earliest low/high. Accepted trade-off, same cap the chart
/// already lives with.
({double min, double max})? lifetimePriceRange(
  StressTestSession session,
  String symbol,
) {
  final hist = session.priceHistory[symbol];
  if (hist == null || hist.isEmpty) return null;
  double min = hist.first;
  double max = hist.first;
  for (final p in hist) {
    if (p < min) min = p;
    if (p > max) max = p;
  }
  return (min: min, max: max);
}

/// Evaluates a BUY at the instant it executes — mutates [profile] in
/// place. Never called per-tick, only from trades_engine.dart's
/// executeTrade. Two independent signals, both checked every buy:
///
/// 1. Macro regime (the epoch's own scenario) — per the confirmed table:
///    Bear/Crash/BlackSwan → buying is disciplined (fear buy)
///    Recovery             → buying is disciplined (confirmed rebound)
///    Bull                 → neutral (normal investing, not rewarded or
///                            punished — a past version wrongly treated
///                            Bull the same as Hype)
///    Hype (macro epoch)   → FOMO, chasing the whole-portfolio spike
///    Sideways/Volatility/Speculation → neutral, no signal either way
///
/// 2. Micro Hype/News event on THIS symbol specifically — independent of
///    the macro regime, because a per-company pump can happen during an
///    otherwise calm Bull epoch. Chasing an active POSITIVE Hype
///    (sector-wide) or News (single-company) event is FOMO regardless of
///    what the macro regime says. A NEGATIVE event isn't penalized here —
///    buying into bad company-specific news isn't the same behavior as
///    chasing a pump.
///
/// A dip-buy (Bear/Crash/BlackSwan/Recovery) that STILL leaves a real
/// cash cushion afterward gets a small extra bonus — deploying part of a
/// reserve while keeping some in hand is prudent sizing, not a lucky
/// all-in. There's no way to know the cash was set aside *specifically in
/// anticipation* of this dip (we don't track cash history), so this is an
/// approximation: "still has a cushion after this buy" stands in for
/// "didn't panic-deploy everything at once."
void evaluateBuyTrade({
  required TraderPsychologyProfile profile,
  required StressTestSession session,
  required String symbol,
  required MarketScenario? macroRegime,
  required double cashAfterBuy,
  required double totalValueAfterBuy,
}) {
  bool isDipBuy = false;
  switch (macroRegime) {
    case MarketScenario.bear:
    case MarketScenario.crash:
    case MarketScenario.blackSwan:
      profile.discipline = (profile.discipline + 0.15).clamp(0.0, 1.0);
      isDipBuy = true;
      break;
    case MarketScenario.recovery:
      profile.discipline = (profile.discipline + 0.08).clamp(0.0, 1.0);
      isDipBuy = true;
      break;
    case MarketScenario.hype:
      profile.discipline = (profile.discipline - 0.20).clamp(0.0, 1.0);
      break;
    case MarketScenario.bull:
    case MarketScenario.sideways:
    case MarketScenario.volatility:
    case MarketScenario.speculation:
    case null:
      break;
  }

  if (isDipBuy && totalValueAfterBuy > 0) {
    final cashPctAfter = cashAfterBuy / totalValueAfterBuy;
    if (cashPctAfter >= 0.10) {
      profile.discipline = (profile.discipline + 0.05).clamp(0.0, 1.0);
    }
  }

  final sector = resolveGicsSector(symbol);
  final chasingHype =
      sector != null &&
      session.activeHypeEvents.any((h) => h.sector == sector && h.isPositive);
  final chasingNews =
      session.activeNewsEvent?.symbol == symbol &&
      session.activeNewsEvent!.isPositive;
  if (chasingHype || chasingNews) {
    profile.discipline = (profile.discipline - 0.10).clamp(0.0, 1.0);
  }
}

/// Evaluates a SELL at the instant it executes — mutates [profile] in
/// place. Never called per-tick, only from trades_engine.dart's
/// executeTrade.
///
/// Confirmed design: judged against the WHOLE TEST's price range for this
/// symbol (see [lifetimePriceRange]), not just the current epoch — a
/// panic sell is a panic sell whether it happens in epoch 2 or epoch 20.
/// Severity blends two things: how close the sale price was to the
/// symbol's real low across the whole test, AND how big the realized
/// loss was relative to what was actually invested — a small loss sold
/// near the bottom is milder than a large loss sold near the bottom, and
/// neither matters if the sale wasn't a loss at all. A realized PROFIT
/// gets a small, un-scaled bonus — taking gains calmly is good behavior,
/// not something to grade by degree.
void evaluateSellTrade({
  required TraderPsychologyProfile profile,
  required StressTestSession session,
  required String symbol,
  required double sellPrice,
  required double? realizedPnl,
  required double? realizedCostBasis,
}) {
  if (realizedPnl == null) return;

  if (realizedPnl > 0) {
    profile.panicResistance = (profile.panicResistance + 0.05).clamp(
      0.0,
      1.0,
    );
    profile.patience = (profile.patience + 0.05).clamp(0.0, 1.0);
    return;
  }
  if (realizedPnl == 0) return;

  // Realized loss — how big, relative to what was actually invested.
  final lossPct = (realizedCostBasis != null && realizedCostBasis > 0)
      ? (-realizedPnl / realizedCostBasis).clamp(0.0, 1.0)
      : 0.5; // no cost-basis data — assume a moderate loss rather than 0

  // How close to the symbol's real low, across the whole test.
  final range = lifetimePriceRange(session, symbol);
  double bottomProximity = 0.5; // no history yet — assume moderate
  if (range != null && range.max > range.min) {
    bottomProximity = (1 - (sellPrice - range.min) / (range.max - range.min))
        .clamp(0.0, 1.0);
  }

  final severity = lossPct * 0.5 + bottomProximity * 0.5;
  profile.panicResistance = (profile.panicResistance - severity * 0.30)
      .clamp(0.0, 1.0);
}

/// The 5 independent signals behind the Strategy pillar, plus their
/// weighted blend (`target`) — see [computeStrategySubScores]. All 0.0-1.0.
class StrategySubScores {
  final double diversification;
  final double concentration;
  final double sector;
  final double etf;
  final double cashBuffer;
  final double target;
  // False only when there's no real cost-basis data to score yet (empty
  // portfolio, or a degenerate all-zero-avgCost holding list) — lets
  // callers tell "nothing to score" apart from "scored and it's 0".
  final bool hasData;

  const StrategySubScores({
    required this.diversification,
    required this.concentration,
    required this.sector,
    required this.etf,
    required this.cashBuffer,
    required this.target,
    this.hasData = true,
  });

  static const zero = StrategySubScores(
    diversification: 0,
    concentration: 0,
    sector: 0,
    etf: 0,
    cashBuffer: 0,
    target: 0,
    hasData: false,
  );
}

/// Pure computation of the Strategy pillar's 5 sub-signals from the
/// portfolio's CURRENT state — diversification (holdings-count curve),
/// concentration (1 - largest single holding's %), sector balance
/// (1 - largest sector's %), ETF exposure, and cash buffer. All money
/// shares use cost basis (`shares × avgCost`), not live market value — a
/// market swing shouldn't change this score without the user doing
/// anything (see the same fix in stress_test_portfolio_health_widget.dart).
///
/// Deterministic given the current holdings/cash — no session history
/// involved — so both [evaluateStrategyPillar] (trade-time engine) and
/// the Strategy/Diversification detail widgets (live UI) can call this
/// directly and always agree.
StrategySubScores computeStrategySubScores({
  required List<StressTestHolding> holdings,
  required double cash,
}) {
  if (holdings.isEmpty) return StrategySubScores.zero;

  final values = <String, double>{};
  double total = 0;
  for (final h in holdings) {
    final val = h.shares * h.avgCost;
    values[h.symbol] = val;
    total += val;
  }
  if (total <= 0) return StrategySubScores.zero;

  // Cash buffer — scaled: 0% cash held back is the full penalty, ~10%+
  // clears it. Folded in here (not a separate ungated per-buy bonus like
  // the old `recordCashBuffer`, which could stack unbounded across many
  // qualifying buys) so it's just one more input to the same eased target.
  final totalWithCash = total + cash;
  final cashBufferScore = totalWithCash > 0
      ? (cash / totalWithCash / 0.10).clamp(0.0, 1.0)
      : 0.0;

  final diversificationScore =
      diversificationScoreForCount(holdings.length.toDouble()) / 100;

  final maxHoldingPct = values.values.reduce(math.max) / total;
  final concentrationScore = (1 - maxHoldingPct).clamp(0.0, 1.0);

  final sectorTotals = <String, double>{};
  for (final h in holdings) {
    final sector = stressTestSectorName(h.symbol);
    sectorTotals[sector] = (sectorTotals[sector] ?? 0) + values[h.symbol]!;
  }
  final maxSectorPct = sectorTotals.values.reduce(math.max) / total;
  final sectorScore = (1 - maxSectorPct).clamp(0.0, 1.0);

  // ETF exposure — keyed by COUNT of distinct ETFs held, not their %
  // of portfolio value (see etfExposureScoreForCount: peaks at 2-3, more
  // is redundant, not better). A holding counts as an ETF if it was
  // tagged `type: 'ETF'` at buy time (h.isEtf — real Finnhub data,
  // covers any ETF) OR falls in the small static AssetSector.etfBroadMarket
  // list (covers holdings bought before isEtf existed, or via a path that
  // doesn't have the search result's type).
  final etfCount = holdings
      .where(
        (h) =>
            h.isEtf || resolveAssetSector(h.symbol) == AssetSector.etfBroadMarket,
      )
      .length;
  final etfScore = etfExposureScoreForCount(etfCount) / 100;

  final target =
      diversificationScore * 0.30 +
      concentrationScore * 0.20 +
      sectorScore * 0.20 +
      etfScore * 0.15 +
      cashBufferScore * 0.15;

  return StrategySubScores(
    diversification: diversificationScore,
    concentration: concentrationScore,
    sector: sectorScore,
    etf: etfScore,
    cashBuffer: cashBufferScore,
    target: target,
  );
}

/// Evaluates the Strategy pillar — called once per trade (buy or sell),
/// never per-tick. The old version (`recordGoodDiversification`/
/// `recordOverconcentration` in noise_engine.dart) fired every 20s tick
/// with no cooldown, saturating strategyAdherence to 0 or 1 within
/// minutes purely from portfolio composition, unrelated to any decision
/// the user actually made — confirmed on review, removed.
///
/// Eases `strategyAdherence` a fraction of the way toward a freshly
/// computed target each trade, rather than snapping to it — one trade
/// shouldn't swing the whole pillar instantly.
void evaluateStrategyPillar({
  required TraderPsychologyProfile profile,
  required List<StressTestHolding> holdings,
  required double cash,
}) {
  if (holdings.isEmpty) return;
  final scores = computeStrategySubScores(holdings: holdings, cash: cash);
  if (!scores.hasData) return;
  profile.strategyAdherence =
      profile.strategyAdherence +
      (scores.target - profile.strategyAdherence) * 0.25;
}

/// "Safety Marker" — cost-basis-weighted average of the FS Score each
/// holding had at the moment of its FIRST purchase (`entryFsScore`, see
/// StressTestHolding), normalized to 0.0-1.0. Answers "how good were the
/// companies this trader actually bought", independent of diversification
/// or timing — a portfolio of 20 well-spread penny biotechs still scores
/// low here.
///
/// Holdings whose `entryFsScore` hasn't resolved yet (fetch still in
/// flight, or failed / no fundamentals) are excluded from the average
/// rather than counted as 0 — an unresolved score isn't a bad score, it's
/// no data yet. `hasData` is false only when NONE of the holdings have a
/// resolved score.
({double score, bool hasData}) safetyMarkerFor(
  List<StressTestHolding> holdings,
) {
  double weightedSum = 0;
  double totalWeight = 0;
  for (final h in holdings) {
    if (h.entryFsScore == null) continue;
    final weight = h.shares * h.avgCost;
    if (weight <= 0) continue;
    weightedSum += h.entryFsScore! * weight;
    totalWeight += weight;
  }
  if (totalWeight <= 0) return (score: 0.0, hasData: false);
  final score = (weightedSum / totalWeight / 100).clamp(0.0, 1.0);
  return (score: score, hasData: true);
}
