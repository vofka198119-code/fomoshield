import 'stress_test_models.dart';

// ---------------------------------------------------------------------------
// Stress Test — live fundamentals markers + dividend-simulation math.
// ---------------------------------------------------------------------------
// P/E and dividend yield are both, by definition, ratios against price
// (price/EPS and dividend-per-share/price) — so once EPS and the $ dividend
// are pinned down at entry (see StressTestHolding.entryPeTTM/
// entryDividendYieldAnnual/entryFundamentalsPrice, snapshotted in
// trades_engine.dart's _fetchSafetyMarkerScore), both markers can be
// recomputed live from the simulated current price with zero extra API
// calls — [liveKeyMetrics] does exactly that, in the same
// `{'metric': {...}}` shape company_detail/widgets/key_metrics_section.dart
// already reads, so that widget can be reused as-is for Stress Test.
// ---------------------------------------------------------------------------

/// Builds a live fundamentals snapshot for [holding] at [currentPrice], in
/// the same shape Finnhub's own `metrics()` response uses — pass straight
/// into `KeyMetricsSection(metrics: ..., palette: ...)`.
///
/// P/E and dividend yield move with price (scaled off the real
/// [StressTestHolding.entryFundamentalsPrice] anchor, not the mutable
/// [StressTestHolding.entryPrice], which top-up buys reset). Margins and ROE
/// aren't price-driven, so they pass through frozen at their entry value.
Map<String, dynamic> liveKeyMetrics(StressTestHolding holding, double currentPrice) {
  final anchorPrice = holding.entryFundamentalsPrice;
  final hasAnchor = anchorPrice != null && anchorPrice > 0 && currentPrice > 0;

  final livePe = (hasAnchor && holding.entryPeTTM != null)
      ? holding.entryPeTTM! * (currentPrice / anchorPrice)
      : null;
  final liveDividendYield =
      (hasAnchor && holding.entryDividendYieldAnnual != null)
      ? holding.entryDividendYieldAnnual! * (anchorPrice / currentPrice)
      : null;

  return {
    'metric': {
      if (livePe != null) 'peTTM': livePe,
      if (liveDividendYield != null)
        'dividendYieldIndicatedAnnual': liveDividendYield,
      if (holding.entryNetMargin != null)
        'netProfitMarginTTM': holding.entryNetMargin,
      if (holding.entryOpMargin != null)
        'operatingMarginTTM': holding.entryOpMargin,
      if (holding.entryGrossMargin != null)
        'grossMarginTTM': holding.entryGrossMargin,
      if (holding.entryRoe != null) 'roeTTM': holding.entryRoe,
    },
  };
}

// ---------------------------------------------------------------------------
// Dividend payout simulation math (Custom-duration, opt-in — see
// stress_test_dividend_provider.dart). Finnhub's real dividend calendar
// (`/stock/dividend`) is paid-tier-gated and unavailable in this app (see
// finnhub_service.dart's dividendsCalendar), so real per-company payout
// frequency can't be fetched — [dividendPeriodDays] is a disclosed
// heuristic (monthly by default; every 2 real weeks for REITs, which pay
// out unusually often), not real data. Expressed directly as a real-day
// period (not a "payments per year" count) since that's what the
// catch-up clock in stress_test_dividend_provider.dart actually needs —
// a REIT's 14-day period isn't an exact divisor of 365, so deriving days
// from a rounded per-year count would drift.
// ---------------------------------------------------------------------------

/// How many real days between [symbol]'s simulated dividend payments.
int dividendPeriodDays(String symbol) {
  return resolveAssetSector(symbol) == AssetSector.realEstateREIT ? 14 : 30;
}

/// The fixed $/share annual dividend implied by [holding]'s entry-snapshot
/// yield — a flat amount, deliberately NOT recomputed from the live price
/// (real dividends are a declared $ figure the company doesn't revise every
/// tick, unlike the live yield % marker in [liveKeyMetrics] which does move
/// with price). Zero (not just null) yield correctly implies zero here too
/// — a real 0%-yield company should never have anything credited.
double annualDividendPerShare(StressTestHolding holding) {
  final yieldPct = holding.entryDividendYieldAnnual;
  final anchorPrice = holding.entryFundamentalsPrice;
  if (yieldPct == null ||
      yieldPct <= 0 ||
      anchorPrice == null ||
      anchorPrice <= 0) {
    return 0;
  }
  return yieldPct / 100 * anchorPrice;
}
