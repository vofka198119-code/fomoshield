import 'market_clock_engine.dart';

// ---------------------------------------------------------------------------
// FOMO Shield Status — per-window risk metrics
// ---------------------------------------------------------------------------
// Feeds the "FOMO SHIELD STATUS" widget (market_clock_timing_widget.dart):
// 4 sub-metrics (Liquidity, Volatility, News Risk, Beginner Safe) per
// window, plus a composite 0-100 risk score and a 3-tier label derived from
// them. Pure classification of market_clock_engine.dart's existing windows —
// hand-tuned to match each window's own whatHappens/whyItMatters/
// dangerForBeginner copy, not a live market feed. Kept in its own file so
// this widget-specific algorithm doesn't bloat the core time/phase engine.
// ---------------------------------------------------------------------------

class RiskMetrics {
  /// 0-100, higher = easier to get filled near the quoted price.
  final int liquidity;

  /// 0-100, higher = wider/faster price swings right now.
  final int volatility;

  /// 0-100, higher = more likely a headline moves price sharply this window.
  final int newsRisk;

  /// 0-100, higher = more forgiving for a beginner to trade in.
  final int beginnerSafe;

  const RiskMetrics({
    required this.liquidity,
    required this.volatility,
    required this.newsRisk,
    required this.beginnerSafe,
  });

  /// Composite 0-100 score — higher means riskier. Simple average of the
  /// four signals, inverting the two "good" ones (liquidity, beginnerSafe)
  /// so all four point the same direction (higher = worse).
  int get score =>
      (((100 - liquidity) + volatility + newsRisk + (100 - beginnerSafe)) / 4)
          .round();
}

enum RiskTier { low, moderate, high, closed }

extension MarketWindowRisk on MarketWindow {
  RiskMetrics get riskMetrics {
    switch (id) {
      case 'early-pre-market':
        return const RiskMetrics(
          liquidity: 15,
          volatility: 55,
          newsRisk: 40,
          beginnerSafe: 20,
        );
      case 'pre-market-reports':
        return const RiskMetrics(
          liquidity: 30,
          volatility: 70,
          newsRisk: 90,
          beginnerSafe: 15,
        );
      case 'opening-bell':
        return const RiskMetrics(
          liquidity: 75,
          volatility: 95,
          newsRisk: 55,
          beginnerSafe: 25,
        );
      case 'morning-session':
        return const RiskMetrics(
          liquidity: 90,
          volatility: 30,
          newsRisk: 20,
          beginnerSafe: 90,
        );
      case 'lunch-hour':
        return const RiskMetrics(
          liquidity: 70,
          volatility: 15,
          newsRisk: 10,
          beginnerSafe: 85,
        );
      case 'mid-afternoon':
        return const RiskMetrics(
          liquidity: 85,
          volatility: 45,
          newsRisk: 50,
          beginnerSafe: 65,
        );
      case 'power-hour':
        return const RiskMetrics(
          liquidity: 90,
          volatility: 75,
          newsRisk: 30,
          beginnerSafe: 40,
        );
      case 'after-hours':
        return const RiskMetrics(
          liquidity: 20,
          volatility: 60,
          newsRisk: 80,
          beginnerSafe: 20,
        );
      case 'early-close-session':
        return const RiskMetrics(
          liquidity: 55,
          volatility: 60,
          newsRisk: 35,
          beginnerSafe: 45,
        );
      default:
        // closed / weekend-closed / market-holiday: nothing is trading.
        return const RiskMetrics(
          liquidity: 0,
          volatility: 0,
          newsRisk: 10,
          beginnerSafe: 100,
        );
    }
  }

  RiskTier get riskTier {
    if (phase == MarketPhase.closed) return RiskTier.closed;
    final s = riskMetrics.score;
    if (s < 35) return RiskTier.low;
    if (s < 60) return RiskTier.moderate;
    return RiskTier.high;
  }
}
