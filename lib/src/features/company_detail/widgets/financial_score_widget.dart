import 'dart:math' as math;
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../../core/theme/theme_v2.dart';
import '../../../core/theme/fomo_shield_theme.dart';
import '../../../core/theme/app_palette.dart';
import '../../../core/theme/themed_header.dart';
import '../../../core/theme/themed_divider.dart';
import '../../../shared/widgets/card_frame.dart';
import '../../../l10n/gen/app_localizations.dart';
import '../../market_clock/market_clock_dial.dart'
    show dialBrassLight, darkCardDecoration;
import 'metric_info_data.dart';

// ---------------------------------------------------------------------------
// Financial Score Widget — gauge + radar chart + 6 marker details. Named
// distinctly from Stress Test's unrelated behavioral "Psychology Meter"
// (which also produces a 0-100 number via TraderPsychologyProfile.compositeScore).
// ---------------------------------------------------------------------------

// scoring_engine.dart's marker name/description/details stay fixed English
// identifiers (also used as metricInfoIdByLabel lookup keys and in the radar
// chart's switch statement) — these map them to the localized display text,
// same pattern as verdict's `_scenarioLabel`.
String _markerDisplayName(AppLocalizations l10n, String name) => switch (name) {
  'Valuation' => l10n.companyDetailMarkerValuation,
  'Financial Health' => l10n.companyDetailMarkerFinancialHealth,
  'Growth Potential' => l10n.companyDetailMarkerGrowthPotential,
  'Efficiency' => l10n.companyDetailMarkerEfficiency,
  'Historical Trend' => l10n.companyDetailMarkerHistoricalTrend,
  'Shareholder Returns' => l10n.companyDetailMarkerShareholderReturns,
  _ => name,
};

String _markerDisplayDescription(AppLocalizations l10n, String name) =>
    switch (name) {
      'Valuation' => l10n.companyDetailMarkerDescValuation,
      'Financial Health' => l10n.companyDetailMarkerDescFinancialHealth,
      'Growth Potential' => l10n.companyDetailMarkerDescGrowth,
      'Efficiency' => l10n.companyDetailMarkerDescEfficiency,
      'Historical Trend' => l10n.companyDetailMarkerDescHistoricalTrend,
      'Shareholder Returns' => l10n.companyDetailMarkerDescShareholderReturns,
      _ => name,
    };

String _markerDisplayDetails(AppLocalizations l10n, String details) =>
    switch (details) {
      'Excellent' => l10n.companyDetailRatingExcellent,
      'Good' => l10n.companyDetailRatingGood,
      'Average' => l10n.companyDetailRatingAverage,
      'Weak' => l10n.companyDetailRatingWeak,
      'Poor' => l10n.companyDetailRatingPoor,
      _ => details,
    };

class FinancialScoreWidget extends StatelessWidget {
  final Map<String, dynamic> score;
  final AppPalette palette;

  const FinancialScoreWidget({
    super.key,
    required this.score,
    required this.palette,
  });

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final fsScore = score['financial_score'] as int? ?? 0;
    final markers = score['markers'] as Map<String, dynamic>? ?? {};
    final penalty = score['dividend_trap_penalty'] as int? ?? 0;
    final lossPenalty = score['catastrophic_loss_penalty'] as int? ?? 0;

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: CardFrame(
        padding: const EdgeInsets.all(FomoShieldTheme.cardPadding),
        decoration: palette.windowGradient != null
            ? BoxDecoration(
                gradient: palette.windowGradient,
                borderRadius: FomoShieldTheme.cardRadius,
                boxShadow: FomoShieldTheme.shadowSoft,
              )
            : darkCardDecoration(),
        palette: palette,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // ── Title ──
            Row(
              children: [
                Icon(
                  Icons.shield_rounded,
                  size: 18,
                  color: _gaugeColor(fsScore),
                ),
                const SizedBox(width: 8),
                themedGoldGradient(
                  Text(
                    l10n.companyDetailFsScoreLabel,
                    style: FomoShieldTheme.cardTitle(Colors.white),
                  ),
                  palette,
                ),
              ],
            ),
            const SizedBox(height: 10),
            palette.dividerGradient != null
                ? themedDivider(palette, indent: 0, endIndent: 0)
                : Divider(height: 1, color: Colors.white.withValues(alpha: 0.15)),
            const SizedBox(height: 16),

            // ── Gauge + Radar row ──
            Row(
              children: [
                // Gauge
                _buildFsScoreGauge(l10n, fsScore),
                const SizedBox(width: 24),
                // Radar chart
                Expanded(
                  child: SizedBox(
                    height: 140,
                    child: _RadarChart(markers: markers, palette: palette),
                  ),
                ),
              ],
            ),

            if (penalty > 0) ...[
              const SizedBox(height: 12),
              Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 12,
                  vertical: 8,
                ),
                decoration: BoxDecoration(
                  color: ThemeV2.warning.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(
                    color: ThemeV2.warning.withValues(alpha: 0.2),
                  ),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(
                      Icons.warning_amber_rounded,
                      size: 14,
                      color: ThemeV2.warning,
                    ),
                    const SizedBox(width: 6),
                    Text(
                      l10n.companyDetailDividendTrapPenalty(penalty),
                      style: GoogleFonts.inter(
                        fontSize: 12,
                        fontWeight: FontWeight.w600,
                        color: ThemeV2.warning,
                      ),
                    ),
                  ],
                ),
              ),
            ],
            if (lossPenalty > 0) ...[
              const SizedBox(height: 12),
              Container(
                width: double.infinity,
                padding: const EdgeInsets.symmetric(
                  horizontal: 12,
                  vertical: 8,
                ),
                decoration: BoxDecoration(
                  color: ThemeV2.loss.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(
                    color: ThemeV2.loss.withValues(alpha: 0.2),
                  ),
                ),
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Icon(
                      Icons.warning_amber_rounded,
                      size: 14,
                      color: ThemeV2.loss,
                    ),
                    const SizedBox(width: 6),
                    Expanded(
                      child: Text(
                        l10n.companyDetailCatastrophicLossPenalty(lossPenalty),
                        style: GoogleFonts.inter(
                          fontSize: 12,
                          fontWeight: FontWeight.w600,
                          color: ThemeV2.loss,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ],
            const SizedBox(height: 20),

            // ── 6 Marker cards ──
            ...markers.entries.map((entry) {
              final marker = entry.value as Map<String, dynamic>;
              return _MarkerCard(marker: marker);
            }),

            const SizedBox(height: 4),
            GestureDetector(
              onTap: () => context.push('/metric-info/fs-score-legal'),
              child: Container(
                width: double.infinity,
                padding: const EdgeInsets.symmetric(
                  horizontal: 12,
                  vertical: 10,
                ),
                decoration: BoxDecoration(
                  border: Border.all(color: _accentColor, width: 1),
                  borderRadius: BorderRadius.circular(10),
                  boxShadow: [
                    BoxShadow(
                      color: _accentColor.withValues(alpha: 0.25),
                      blurRadius: 6,
                    ),
                  ],
                ),
                child: Row(
                  children: [
                    Icon(Icons.gavel_rounded, size: 14, color: _accentColor),
                    const SizedBox(width: 8),
                    Expanded(
                      child: Text(
                        l10n.companyDetailLegalDisclaimerMethodology,
                        style: GoogleFonts.inter(
                          fontSize: 11,
                          fontWeight: FontWeight.w600,
                          color: _accentColor,
                        ),
                      ),
                    ),
                    Icon(
                      Icons.chevron_right_rounded,
                      size: 16,
                      color: _accentColor,
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Color _gaugeColor(int score) {
    if (score >= 70) return ThemeV2.success;
    if (score >= 40) return ThemeV2.warning;
    return ThemeV2.loss;
  }

  // Theme accent for decorative (non score-semantic) gold elements — the
  // radar chart and the disclaimer/methodology pill. Reuses
  // [AppPalette.marketClockAccent] (null under every theme that doesn't
  // opt in, falling back to the original brass/gold) rather than
  // [AppPalette.accentPrimary] — Midnight Sea's accentPrimary is already
  // used all over this card for other purposes, marketClockAccent is the
  // field specifically meant for "brass/gold decorative accent, themed".
  Color get _accentColor => palette.marketClockAccent ?? dialBrassLight;

  Widget _buildFsScoreGauge(AppLocalizations l10n, int score) {
    final color = _gaugeColor(score);

    return Container(
      width: 120,
      height: 120,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        gradient: palette.windowGradient,
        color: palette.windowGradient == null ? ThemeV2.surface : null,
        border: Border.all(color: color.withValues(alpha: 0.3), width: 3),
        boxShadow: [
          BoxShadow(
            color: color.withValues(alpha: 0.1),
            blurRadius: 20,
            spreadRadius: 3,
          ),
        ],
      ),
      child: Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              '$score',
              style: GoogleFonts.inter(
                fontSize: 40,
                fontWeight: FontWeight.w900,
                color: color,
                letterSpacing: -1,
              ),
            ),
            Text(
              l10n.companyDetailFsScoreLabel,
              style: GoogleFonts.inter(
                fontSize: 9,
                fontWeight: FontWeight.w700,
                letterSpacing: 2,
                color: palette.textBody,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// ===========================================================================
// Radar Chart (6-axis custom painted)
// ===========================================================================

class _RadarChart extends StatelessWidget {
  final Map<String, dynamic> markers;
  final AppPalette palette;

  const _RadarChart({required this.markers, required this.palette});

  @override
  Widget build(BuildContext context) {
    return CustomPaint(
      size: const Size(double.infinity, double.infinity),
      painter: _RadarChartPainter(
        markers: markers,
        color: palette.marketClockAccent ?? dialBrassLight,
      ),
    );
  }
}

class _RadarChartPainter extends CustomPainter {
  final Map<String, dynamic> markers;
  final Color color;

  _RadarChartPainter({required this.markers, required this.color});

  @override
  void paint(Canvas canvas, Size size) {
    final center = Offset(size.width / 2, size.height / 2);
    final radius = math.min(size.width, size.height) / 2 - 8;
    final entries = markers.entries.toList();
    final n = entries.length;
    if (n == 0) return;

    // Paint filled data shape
    final dataPath = Path();
    // Paint grid lines
    final gridPaint = Paint()
      ..color = color.withValues(alpha: 0.35)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1;

    for (int level = 1; level <= 3; level++) {
      final r = radius * level / 3;
      final path = Path();
      for (int i = 0; i < n; i++) {
        final angle = -math.pi / 2 + (2 * math.pi * i / n);
        final x = center.dx + r * math.cos(angle);
        final y = center.dy + r * math.sin(angle);
        if (i == 0) {
          path.moveTo(x, y);
        } else {
          path.lineTo(x, y);
        }
      }
      path.close();
      canvas.drawPath(path, gridPaint);
    }

    // Draw axis lines
    for (int i = 0; i < n; i++) {
      final angle = -math.pi / 2 + (2 * math.pi * i / n);
      final x = center.dx + radius * math.cos(angle);
      final y = center.dy + radius * math.sin(angle);
      canvas.drawLine(center, Offset(x, y), gridPaint);
    }

    // Draw data area
    for (int i = 0; i < n; i++) {
      final marker = entries[i].value as Map<String, dynamic>;
      final score = (marker['score'] as num?)?.toDouble() ?? 0;
      final r = radius * (score / 100);
      final angle = -math.pi / 2 + (2 * math.pi * i / n);
      final x = center.dx + r * math.cos(angle);
      final y = center.dy + r * math.sin(angle);
      if (i == 0) {
        dataPath.moveTo(x, y);
      } else {
        dataPath.lineTo(x, y);
      }
    }
    dataPath.close();

    final dataPaint = Paint()
      ..color = color.withValues(alpha: 0.25)
      ..style = PaintingStyle.fill;
    canvas.drawPath(dataPath, dataPaint);

    final dataStroke = Paint()
      ..color = color.withValues(alpha: 0.8)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 2;
    canvas.drawPath(dataPath, dataStroke);

    // Draw dots + labels at each vertex
    for (int i = 0; i < n; i++) {
      final marker = entries[i].value as Map<String, dynamic>;
      final score = (marker['score'] as num?)?.toDouble() ?? 0;
      final r = radius * (score / 100);
      final angle = -math.pi / 2 + (2 * math.pi * i / n);
      final x = center.dx + r * math.cos(angle);
      final y = center.dy + r * math.sin(angle);

      // Dot
      canvas.drawCircle(Offset(x, y), 3.5, Paint()..color = color);

      // Label at edge
      final labelR = radius + 12;
      final lx = center.dx + labelR * math.cos(angle);
      final ly = center.dy + labelR * math.sin(angle);
      _drawLabel(
        canvas,
        _shortName(marker['name'] as String? ?? ''),
        Offset(lx, ly),
        angle,
      );
    }
  }

  String _shortName(String name) {
    switch (name) {
      case 'Valuation':
        return 'VAL';
      case 'Financial Health':
        return 'FIN';
      case 'Growth Potential':
        return 'GRW';
      case 'Efficiency':
        return 'EFF';
      case 'Historical Trend':
        return 'TRD';
      case 'Shareholder Returns':
        return 'SHR';
      default:
        return name.substring(0, 3).toUpperCase();
    }
  }

  void _drawLabel(Canvas canvas, String text, Offset pos, double angle) {
    final tp = TextPainter(
      text: TextSpan(
        text: text,
        style: TextStyle(
          color: Colors.white.withValues(alpha: 0.7),
          fontSize: 9,
          fontWeight: FontWeight.w600,
        ),
      ),
      textDirection: TextDirection.ltr,
    )..layout();

    // Center the label around the position
    final offset = Offset(pos.dx - tp.width / 2, pos.dy - tp.height / 2);
    tp.paint(canvas, offset);
  }

  @override
  bool shouldRepaint(covariant _RadarChartPainter oldDelegate) => true;
}

// ===========================================================================
// Marker Card
// ===========================================================================

class _MarkerCard extends StatelessWidget {
  final Map<String, dynamic> marker;

  const _MarkerCard({required this.marker});

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final name = marker['name'] as String? ?? '';
    final score = marker['score'] as int? ?? 0;
    final details = marker['details'] as String? ?? '';
    final colorStr = marker['color'] as String? ?? '';
    final infoId = metricInfoIdByLabel[name];

    Color markerColor;
    switch (colorStr) {
      case 'green':
        markerColor = ThemeV2.success;
        break;
      case 'yellow':
        markerColor = ThemeV2.warning;
        break;
      case 'red':
        markerColor = ThemeV2.loss;
        break;
      default:
        markerColor = ThemeV2.textSecondary;
    }

    return Container(
      margin: const EdgeInsets.only(bottom: 8),
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
      decoration: BoxDecoration(
        color: Colors.transparent,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.white.withValues(alpha: 0.1)),
      ),
      child: Row(
        children: [
          // Color indicator
          Container(
            width: 4,
            height: 36,
            decoration: BoxDecoration(
              color: markerColor,
              borderRadius: BorderRadius.circular(2),
            ),
          ),
          const SizedBox(width: 12),
          // Name + description
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Flexible(
                      child: Text(
                        _markerDisplayName(l10n, name),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: GoogleFonts.inter(
                          fontSize: 13,
                          fontWeight: FontWeight.w700,
                          color: Colors.white,
                        ),
                      ),
                    ),
                    if (infoId != null) ...[
                      const SizedBox(width: 6),
                      GestureDetector(
                        onTap: () => context.push('/metric-info/$infoId'),
                        child: Container(
                          width: 20,
                          height: 20,
                          decoration: BoxDecoration(
                            color: Colors.white.withValues(alpha: 0.12),
                            borderRadius: BorderRadius.circular(
                              ThemeV2.radiusSmall,
                            ),
                          ),
                          alignment: Alignment.center,
                          child: const Icon(
                            Icons.help_outline_rounded,
                            size: 13,
                            color: Colors.white,
                          ),
                        ),
                      ),
                    ],
                  ],
                ),
                const SizedBox(height: 2),
                Text(
                  _markerDisplayDescription(l10n, name),
                  style: GoogleFonts.inter(
                    fontSize: 11,
                    color: Colors.white.withValues(alpha: 0.7),
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(width: 12),
          // Score + detail
          Column(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              Text(
                '$score',
                style: GoogleFonts.inter(
                  fontSize: 20,
                  fontWeight: FontWeight.w900,
                  color: markerColor,
                  letterSpacing: -1,
                ),
              ),
              Text(
                _markerDisplayDetails(l10n, details),
                style: GoogleFonts.inter(
                  fontSize: 10,
                  fontWeight: FontWeight.w600,
                  color: markerColor,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
