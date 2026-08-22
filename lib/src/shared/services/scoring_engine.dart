import 'dart:math';
import '../../core/utils/constants.dart';

/// 6-marker FS Score algorithm
/// Each marker: 0-100, overall FS Score: 0-100
class ScoringEngine {
  /// Calculate all 6 markers from financial metrics.
  ///
  /// [sectorPe] — average P/E across the company's GICS sector, computed
  /// server-side from the tracked-company basket (Finnhub has no such
  /// field of its own) — null until that job is wired in; Valuation stays
  /// neutral (50) until then rather than guessing.
  /// [priceCagr5Y] — 5-year annualized share-price return in percentage
  /// points (e.g. 12.5 for +12.5%/yr), computed from Yahoo candle
  /// history — null until wired in; Historical Trend stays neutral (50)
  /// until then.
  ///
  /// Returns null when Finnhub has no fundamentals at all for this
  /// instrument — funds/ETFs and some thinly-covered tickers. Confirmed
  /// live 2026-07-31 (FGDL, an ETF): /stock/metric returns only
  /// price/volume technicals, none of the fields below. Scoring that
  /// with nothing but neutral 50s would look like a real analysis
  /// happened when it didn't — better to show no score at all.
  static Map<String, dynamic>? calculate(
    Map<String, dynamic> metrics, {
    double? sectorPe,
    double? priceCagr5Y,
  }) {
    final m = metrics['metric'] as Map<String, dynamic>? ?? {};

    final hasFundamentals = m['peTTM'] != null ||
        m['totalDebt/totalEquityQuarterly'] != null ||
        m['currentRatioQuarterly'] != null ||
        m['revenueGrowth5Y'] != null ||
        m['epsGrowth5Y'] != null ||
        m['netProfitMarginTTM'] != null ||
        m['roeTTM'] != null;
    if (!hasFundamentals) return null;

    // 1. Valuation (P/E vs sector)
    final pe = _d(m['peTTM']);
    final valuation = _calcValuation(pe, sectorPe);

    // 2. Financial Health (debt/liquidity) — Finnhub's real field names.
    // The previous 'debtEquityTTM'/'currentRatioTTM' keys never existed
    // in Finnhub's response (confirmed against a live call), so this
    // marker silently defaulted to a fixed 70 for every company.
    final debtEquity = _d(m['totalDebt/totalEquityQuarterly']);
    final currentRatio = _d(m['currentRatioQuarterly']);
    final financialHealth = _calcFinancialHealth(debtEquity, currentRatio);

    // 3. Growth Potential — Finnhub's growth fields already arrive as
    // percentage points (7.75 means 7.75%), not 0-1 fractions, unlike
    // e.g. Yahoo's equivalents. Confirmed live 2026-07-31.
    final revGrowth = _d(m['revenueGrowth5Y']);
    final epsGrowth = _d(m['epsGrowth5Y']);
    // marketCapitalization is already in this same Finnhub response (in
    // $millions) — used to dampen the growth signal for micro/nano-caps,
    // where % growth off a near-zero revenue/earnings base swings huge
    // and isn't comparable to a larger company's growth rate. Confirmed
    // live 2026-07-31 (SPCE: Growth Potential scored 80 "Excellent" off
    // this exact small-base effect).
    final marketCapMillions = _dOrNull(m['marketCapitalization']);
    final growth = _calcGrowth(revGrowth, epsGrowth, marketCapMillions);

    // 4. Efficiency (net margin + ROE) — same percentage-point
    // convention as Growth Potential above.
    final netMargin = _d(m['netProfitMarginTTM']);
    final roe = _d(m['roeTTM']);
    final efficiency = _calcEfficiency(netMargin, roe);

    // 5. Historical Trend — real 5Y share-price CAGR. Used to just
    // re-read Growth Potential's exact same two fundamentals fields,
    // making it a duplicate marker rather than an independent signal.
    final historicalTrend = _calcHistoricalTrend(priceCagr5Y);

    // 6. Shareholder Returns (dividends/buybacks)
    final divYield = _pct(m['dividendYieldIndicatedAnnual']);
    final payoutRatio = _pct(m['payoutRatioAnnual']);
    final capitalReturn = _calcCapitalReturn(divYield, payoutRatio);

    // Calculate final FS Score (weighted average)
    final weights = [0.20, 0.20, 0.20, 0.15, 0.15, 0.10];
    double totalScore = 0;
    final scores = [valuation, financialHealth, growth, efficiency, historicalTrend, capitalReturn];
    for (int i = 0; i < 6; i++) {
      totalScore += scores[i] * weights[i];
    }

    // Dividend trap protection
    double finalScore = totalScore;
    if (divYield > AppConstants.dividendTrapThreshold / 100) {
      finalScore = max(0, finalScore - AppConstants.dividendTrapPenalty);
    }

    // Catastrophic unprofitability protection — a clean balance sheet
    // (Financial Health) shouldn't be able to offset losses this severe
    // in the weighted average. Confirmed live 2026-07-31: VANI (net
    // margin -993.8%, zero debt) still scored 46 "Average" without this.
    final catastrophicLoss = netMargin < AppConstants.catastrophicLossThreshold;
    if (catastrophicLoss) {
      finalScore = max(0, finalScore - AppConstants.catastrophicLossPenalty);
    }

    return {
      // Named 'financial_score' (not 'fs_score') to avoid the collision
      // with Stress Test's unrelated behavioral Psychology Meter score
      // (TraderPsychologyProfile.compositeScore), which also produces a
      // 0-100 number under the same 'fs_score' name.
      'financial_score': finalScore.round(),
      'markers': {
        'valuation': _markerResult('Valuation', valuation, 'P/E vs sector average'),
        'financial_health': _markerResult('Financial Health', financialHealth, 'Debt/Equity ratio'),
        'growth_potential': _markerResult('Growth Potential', growth, 'Revenue & EPS 5Y growth'),
        'efficiency': _markerResult('Efficiency', efficiency, 'Net margin & ROE'),
        'historical_trend': _markerResult('Historical Trend', historicalTrend, '5Y share price CAGR'),
        'capital_return': _markerResult('Shareholder Returns', capitalReturn, 'Dividends & buybacks'),
      },
      'dividend_trap_penalty': divYield > AppConstants.dividendTrapThreshold / 100
          ? AppConstants.dividendTrapPenalty
          : 0,
      'catastrophic_loss_penalty':
          catastrophicLoss ? AppConstants.catastrophicLossPenalty : 0,
    };
  }

  static Map<String, dynamic> _markerResult(String name, double score, String description) {
    return {
      'name': name,
      'score': score.round(),
      'description': description,
      'color': _scoreColor(score),
      'details': _markerDetails(name, score),
    };
  }

  static String _markerDetails(String name, double score) {
    if (score >= 80) return 'Excellent';
    if (score >= 60) return 'Good';
    if (score >= 40) return 'Average';
    if (score >= 20) return 'Weak';
    return 'Poor';
  }

  static String _scoreColor(double score) {
    if (score >= 70) return 'green';
    if (score >= 40) return 'yellow';
    return 'red';
  }

  // Valuation: lower P/E relative to sector = better. Neutral (50) until
  // a real sector average is available — never guess.
  static double _calcValuation(double pe, double? sectorPe) {
    if (pe <= 0 || sectorPe == null || sectorPe <= 0) return 50;
    final ratio = pe / sectorPe;
    if (ratio <= 0.5) return 90;  // Undervalued
    if (ratio <= 0.8) return 75;
    if (ratio <= 1.2) return 60;  // Fair
    if (ratio <= 2.0) return 40;
    return 20;  // Overvalued
  }

  // Financial Health: low debt, good liquidity
  static double _calcFinancialHealth(double debtEquity, double currentRatio) {
    double score = 50;
    // Lower D/E is better
    if (debtEquity <= 0.3) {
      score += 30;
    } else if (debtEquity <= 1.0) {
      score += 15;
    } else if (debtEquity <= 2.0) {
      score += 0;
    } else {
      score -= 20;
    }
    // Higher current ratio is better
    if (currentRatio >= 2.0) {
      score += 20;
    } else if (currentRatio >= 1.0) {
      score += 10;
    } else {
      score -= 10;
    }
    return score.clamp(0, 100);
  }

  // Growth Potential — revGrowth/epsGrowth are already percentage points
  // (e.g. 7.75 = 7.75%), added directly rather than re-multiplied by 100.
  // marketCapMillions dampens the swing below real small-cap territory
  // (~$2B), where % growth off a modest-to-tiny base is noisy rather
  // than genuinely informative — the effect gets stronger the smaller
  // the company. Verified live 2026-07-31: SPCE at $343M (initially
  // undampened — the first cutoff was $300M, just below it) still
  // scored a small-base-inflated 80. Unknown market cap (null) gets
  // full confidence rather than guessing a company is small.
  static double _calcGrowth(
    double revGrowth,
    double epsGrowth,
    double? marketCapMillions,
  ) {
    double score = 50;
    score += revGrowth.clamp(-30, 30);
    score += epsGrowth.clamp(-30, 30);
    score = score.clamp(0, 100);

    if (marketCapMillions != null && marketCapMillions > 0) {
      double confidence = 1.0;
      if (marketCapMillions < 50) {
        confidence = 0.4; // nano-cap
      } else if (marketCapMillions < 300) {
        confidence = 0.6; // micro-cap
      } else if (marketCapMillions < 2000) {
        confidence = 0.8; // small-cap
      }
      if (confidence < 1.0) {
        score = 50 + (score - 50) * confidence;
      }
    }
    return score.clamp(0, 100);
  }

  // Efficiency: net margin + ROE — same percentage-point convention.
  static double _calcEfficiency(double netMargin, double roe) {
    double score = 50;
    score += netMargin.clamp(-25, 25);
    score += roe.clamp(-25, 25);
    return score.clamp(0, 100);
  }

  // Historical Trend: real 5Y annualized share-price return. Wider clamp
  // than fundamentals-based Growth Potential since price CAGR reflects
  // market sentiment too, not just the underlying business.
  static double _calcHistoricalTrend(double? priceCagr5Y) {
    if (priceCagr5Y == null) return 50;
    double score = 50;
    score += priceCagr5Y.clamp(-35, 35);
    return score.clamp(0, 100);
  }

  // Shareholder Returns
  static double _calcCapitalReturn(double divYield, double payoutRatio) {
    double score = 40;
    // Yield up to reasonable threshold
    if (divYield > 0 && divYield <= 0.05) {
      score += 20;
    } else if (divYield > 0.05 && divYield <= AppConstants.dividendTrapThreshold / 100) {
      score += 15;
    }
    // Reasonable payout ratio
    if (payoutRatio > 0 && payoutRatio <= 0.6) {
      score += 20;
    } else if (payoutRatio > 0.6 && payoutRatio <= 0.9) {
      score += 10;
    } else if (payoutRatio > 0.9) {
      score -= 10;
    }
    return score.clamp(0, 100);
  }

  static double _d(dynamic v) => (v is num) ? v.toDouble() : 0.0;
  static double? _dOrNull(dynamic v) => (v is num) ? v.toDouble() : null;
  static double _pct(dynamic v) => (v is num) ? v.toDouble() / 100.0 : 0.0;
}
