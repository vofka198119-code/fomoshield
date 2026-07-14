// ---------------------------------------------------------------------------
// ExplainableCard — "Why?" Engine UI (Design Bible Part 9)
// ---------------------------------------------------------------------------
// Показывает разложение изменения цены на 5 факторов:
//   Market (#6FA7D6), Sector (#77C88A), Company (#F0B04F),
//   News (#8A76D6), Noise (#BFB9AE)
//
//   ┌────────────────────────────────────┐
//   │          WHY TODAY?                │
//   │      AAPL +3.28%                   │
//   │ ████████████ 46% Market            │
//   │ ████████     27% Sector            │
//   │ █████        18% News              │
//   │ ██            9% Noise             │
//   │ Market remained optimistic today.  │
//   │ Tech sector outperformed.          │
//   └────────────────────────────────────┘
// ---------------------------------------------------------------------------

import 'package:flutter/material.dart';
import '../../core/theme/typography_helpers.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../core/theme/fomo_shield_theme.dart';
import '../../features/stress_test/stress_test_models.dart';
import 'card_frame.dart';

/// Data for a single explainable card.
class ExplainableData {
  final String symbol;
  final double changePercent;
  final PriceContribution contributions;
  final String marketPhase;
  final String scenario;

  const ExplainableData({
    required this.symbol,
    required this.changePercent,
    required this.contributions,
    required this.marketPhase,
    required this.scenario,
  });

  factory ExplainableData.fromExplanation(TickExplanation exp) {
    return ExplainableData(
      symbol: exp.symbol,
      changePercent: exp.changePercent,
      contributions: exp.contributions,
      marketPhase: exp.marketPhase,
      scenario: exp.scenario,
    );
  }

  /// Top 3 factors + Noise (skipping the smallest non-noise factor).
  List<_FactorEntry> get displayFactors {
    final all = [
      _FactorEntry('Market', contributions.marketPct, FomoShieldTheme.factorMarket),
      _FactorEntry('Sector', contributions.sectorPct, FomoShieldTheme.factorSector),
      _FactorEntry('Company', contributions.companyPct, FomoShieldTheme.factorCompany),
      _FactorEntry('News', contributions.newsPct, FomoShieldTheme.factorNews),
      _FactorEntry('Noise', contributions.noisePct, FomoShieldTheme.factorNoise),
    ];
    // Sort by percent descending
    all.sort((a, b) => b.percent.compareTo(a.percent));
    // Take top 3 non-noise + add noise at end
    final top = all.take(4).toList();
    // If Noise isn't already in top 3, keep it; otherwise keep as-is
    if (!top.any((f) => f.label == 'Noise')) {
      final noise = all.firstWhere((f) => f.label == 'Noise');
      top[3] = noise;
    }
    return top;
  }
}

class _FactorEntry {
  final String label;
  final double percent;
  final Color color;
  const _FactorEntry(this.label, this.percent, this.color);
}

/// A card that explains "Why?" a price moved.
class ExplainableCard extends StatelessWidget {
  final ExplainableData data;

  const ExplainableCard({super.key, required this.data});

  @override
  Widget build(BuildContext context) {
    final factors = data.displayFactors;
    final isPositive = data.changePercent >= 0;

    return CardFrame(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // ── Header ──
          Text('WHY TODAY?', style: FomoShieldTheme.cardTitle()),
          const SizedBox(height: 12),

          // ── Symbol + change ──
          Row(
            children: [
              Text(
                data.symbol,
                style: GoogleFonts.inter(
                  fontSize: 22,
                  fontWeight: FontWeight.w800,
                  color: FomoShieldTheme.text,
                ),
              ),
              const SizedBox(width: 10),
              Text(
                '${isPositive ? '+' : ''}${data.changePercent.toStringAsFixed(2)}%',
                style: interNums(
                  fontSize: 22,
                  fontWeight: FontWeight.w800,
                  color: isPositive
                      ? FomoShieldTheme.positive
                      : FomoShieldTheme.negative,
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),

          // ── Composition bar (conic-gradient style) ──
          _buildCompositionBar(factors),
          const SizedBox(height: 14),

          // ── Factor bars ──
          for (final factor in factors) ...[
            _FactorBar(
              label: factor.label,
              percent: factor.percent,
              color: factor.color,
            ),
            const SizedBox(height: 6),
          ],

          const SizedBox(height: 12),

          // ── Textual explanation ──
          Text(
            _buildExplanation(data),
            style: FomoShieldTheme.factorDescription(),
          ),
        ],
      ),
    );
  }

  /// Conic-style composition bar: all factor segments in a single row.
  Widget _buildCompositionBar(List<_FactorEntry> factors) {
    // Keep only non-zero factors, sorted by percent descending
    final nonZero = factors.where((f) => f.percent > 0).toList();
    if (nonZero.isEmpty) return const SizedBox.shrink();

    return ClipRRect(
      borderRadius: BorderRadius.circular(4),
      child: SizedBox(
        height: 20,
        child: Row(
          children: nonZero.map((f) {
            final fraction = (f.percent / 100).clamp(0.0, 1.0);
            return Expanded(
              flex: (fraction * 1000).round().clamp(1, 1000),
              child: Container(
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    colors: [
                      f.color,
                      f.color.withValues(alpha: 0.7),
                    ],
                    begin: Alignment.centerLeft,
                    end: Alignment.centerRight,
                  ),
                ),
              ),
            );
          }).toList(),
        ),
      ),
    );
  }

  /// Генерирует человекопонятное объяснение на основе топ-факторов.
  String _buildExplanation(ExplainableData data) {
    final factors = data.displayFactors;
    final top = factors[0];
    final second = factors.length > 1 ? factors[1] : null;

    final buf = StringBuffer();
    buf.write(_phaseDescription(data.marketPhase, data.scenario));
    buf.write(' ');

    if (top.percent >= 35) {
      buf.write('${top.label} is the dominant factor');
      if (second != null && second.percent >= 20) {
        buf.write(', followed by ${second.label.toLowerCase()}');
      }
      buf.write('.');
    } else if (top.percent >= 20 && second != null) {
      buf.write('${top.label} and ${second.label.toLowerCase()} '
          'are driving the movement.');
    } else {
      buf.write('Mixed factors with no clear dominant driver.');
    }

    buf.write(' ');
    buf.write(_factorExplanation(top.label, changePhaseDirection));

    return buf.toString();
  }

  String _phaseDescription(String phase, String scenario) {
    switch (phase.toLowerCase()) {
      case 'bull':
        return 'Market is in an uptrend.';
      case 'bear':
        return 'Market is declining.';
      case 'sideways':
        return 'Market is range-bound.';
      case 'volatility':
        return 'Market is volatile.';
      case 'crash':
        return 'Market is crashing.';
      case 'blackswan':
      case 'black_swan':
        return 'A rare catastrophic event is unfolding.';
      case 'recovery':
        return 'Market is recovering from a downturn.';
      default:
        return 'Market conditions are ${phase.toLowerCase()}.';
    }
  }

  String _factorExplanation(String factor, String direction) {
    switch (factor.toLowerCase()) {
      case 'market':
        return direction == 'up'
            ? 'Broad market sentiment is pushing prices up.'
            : 'Broad market weakness is dragging prices down.';
      case 'sector':
        return direction == 'up'
            ? 'The sector is outperforming the broader market.'
            : 'The sector is underperforming today.';
      case 'company':
        return direction == 'up'
            ? 'Company-specific developments are driving gains.'
            : 'Company-specific headwinds are affecting the stock.';
      case 'news':
        return direction == 'up'
            ? 'Positive news flow is supporting the price.'
            : 'Negative headlines are weighing on sentiment.';
      case 'noise':
        return 'Short-term noise with no clear fundamental driver.';
      default:
        return '';
    }
  }

  /// 'up' or 'down' based on net factor direction.
  String get changePhaseDirection =>
      data.changePercent >= 0 ? 'up' : 'down';
}

/// A single factor bar: label + gradient bar (conic-style) + percent.
class _FactorBar extends StatelessWidget {
  final String label;
  final double percent;
  final Color color;

  const _FactorBar({
    required this.label,
    required this.percent,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        // Colored bar (20px height, conic-gradient style)
        Expanded(
          child: ClipRRect(
            borderRadius: BorderRadius.circular(4),
            child: Container(
              height: 20,
              color: FomoShieldTheme.border.withValues(alpha: 0.4),
                child: TweenAnimationBuilder<double>(
                tween: Tween(begin: 0.0, end: (percent / 100).clamp(0.0, 1.0)),
                duration: FomoShieldTheme.animChartGrow,
                curve: Curves.easeOutCubic,
                builder: (context, value, _) => FractionallySizedBox(
                  alignment: Alignment.centerLeft,
                  widthFactor: value,
                  child: Container(
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        colors: [
                          color,
                          color.withValues(alpha: 0.65),
                          Color.lerp(color, Colors.white, 0.3)!,
                        ],
                        stops: const [0.0, 0.6, 1.0],
                        begin: Alignment.centerLeft,
                        end: Alignment.centerRight,
                      ),
                    ),
                  ),
                ),
              ),
            ),
          ),
        ),
        const SizedBox(width: 10),
        // Label
        SizedBox(
          width: 60,
          child: Text(
            label,
            style: FomoShieldTheme.factorLabel(color),
          ),
        ),
        const SizedBox(width: 6),
        // Percent
        SizedBox(
          width: 40,
          child: Text(
            '${percent.round()}%',
            textAlign: TextAlign.right,
            style: FomoShieldTheme.factorPercent(color),
          ),
        ),
      ],
    );
  }
}
