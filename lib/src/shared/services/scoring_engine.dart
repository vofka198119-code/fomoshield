import 'dart:math';
import '../../core/utils/constants.dart';

/// 6-marker FS Score algorithm
/// Each marker: 0-100, overall FS Score: 0-100
class ScoringEngine {
  /// Calculate all 6 markers from financial metrics
  static Map<String, dynamic> calculate(Map<String, dynamic> metrics) {
    final m = metrics['metric'] as Map<String, dynamic>? ?? {};

    // 1. Valuation (P/E vs sector)
    final pe = _d(m['peTTM']);
    final sectorPe = _d(m['sectorPeTTM']);
    final valuation = _calcValuation(pe, sectorPe);

    // 2. Financial Health (debt)
    final debtEquity = _d(m['debtEquityTTM']);
    final currentRatio = _d(m['currentRatioTTM']);
    final financialHealth = _calcFinancialHealth(debtEquity, currentRatio);

    // 3. Growth Potential
    final revGrowth = _d(m['revenueGrowth5Y']);
    final epsGrowth = _d(m['epsGrowth5Y']);
    final growth = _calcGrowth(revGrowth, epsGrowth);

    // 4. Efficiency (net margin)
    final netMargin = _d(m['netProfitMarginTTM']);
    final roe = _d(m['roeTTM']);
    final efficiency = _calcEfficiency(netMargin, roe);

    // 5. Historical Trend (5Y CAGR)
    final revCagr = _d(m['revenueGrowth5Y']);
    final epsCagr = _d(m['epsGrowth5Y']);
    final historicalTrend = _calcHistoricalTrend(revCagr, epsCagr);

    // 6. Capital Return (dividends/buybacks)
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

    return {
      'fs_score': finalScore.round(),
      'markers': {
        'valuation': _markerResult('Valuation', valuation, 'P/E vs sector average'),
        'financial_health': _markerResult('Financial Health', financialHealth, 'Debt/Equity ratio'),
        'growth_potential': _markerResult('Growth Potential', growth, 'Revenue & EPS 5Y growth'),
        'efficiency': _markerResult('Efficiency', efficiency, 'Net margin & ROE'),
        'historical_trend': _markerResult('Historical Trend', historicalTrend, '5Y CAGR'),
        'capital_return': _markerResult('Capital Return', capitalReturn, 'Dividends & buybacks'),
      },
      'dividend_trap_penalty': divYield > AppConstants.dividendTrapThreshold / 100
          ? AppConstants.dividendTrapPenalty
          : 0,
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

  // Valuation: lower P/E relative to sector = better
  static double _calcValuation(double pe, double sectorPe) {
    if (pe <= 0 || sectorPe <= 0) return 50;
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
    if (debtEquity <= 0.3) score += 30;
    else if (debtEquity <= 1.0) score += 15;
    else if (debtEquity <= 2.0) score += 0;
    else score -= 20;
    // Higher current ratio is better
    if (currentRatio >= 2.0) score += 20;
    else if (currentRatio >= 1.0) score += 10;
    else score -= 10;
    return score.clamp(0, 100);
  }

  // Growth Potential
  static double _calcGrowth(double revGrowth, double epsGrowth) {
    double score = 50;
    score += (revGrowth * 100).clamp(-30, 30);
    score += (epsGrowth * 100).clamp(-30, 30);
    return score.clamp(0, 100);
  }

  // Efficiency: net margin + ROE
  static double _calcEfficiency(double netMargin, double roe) {
    double score = 50;
    score += (netMargin * 100).clamp(-25, 25);
    score += (roe * 100).clamp(-25, 25);
    return score.clamp(0, 100);
  }

  // Historical Trend: 5Y CAGR
  static double _calcHistoricalTrend(double revCagr, double epsCagr) {
    double score = 50;
    score += (revCagr * 100).clamp(-25, 25);
    score += (epsCagr * 100).clamp(-25, 25);
    return score.clamp(0, 100);
  }

  // Capital Return
  static double _calcCapitalReturn(double divYield, double payoutRatio) {
    double score = 40;
    // Yield up to reasonable threshold
    if (divYield > 0 && divYield <= 0.05) score += 20;
    else if (divYield > 0.05 && divYield <= AppConstants.dividendTrapThreshold / 100) score += 15;
    // Reasonable payout ratio
    if (payoutRatio > 0 && payoutRatio <= 0.6) score += 20;
    else if (payoutRatio > 0.6 && payoutRatio <= 0.9) score += 10;
    else if (payoutRatio > 0.9) score -= 10;
    return score.clamp(0, 100);
  }

  static double _d(dynamic v) => (v is num) ? v.toDouble() : 0.0;
  static double _pct(dynamic v) => (v is num) ? v.toDouble() / 100.0 : 0.0;
}
