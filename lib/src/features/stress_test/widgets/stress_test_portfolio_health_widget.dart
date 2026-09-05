// ---------------------------------------------------------------------------
// Stress Test — Portfolio Health card, first widget on the Portfolio
// Balance detail screen (a dashboard-style summary sitting above the raw
// breakdowns below it). Four 0-100 scores, each its own small ring gauge:
// Diversification (holdings count), Concentration (largest single
// holding's share), Sector Balance (largest sector's share), Stability
// (value-weighted sector risk tier). All four read "higher = healthier".
// Standard light card (FomoShieldTheme.cardDecoration) — deliberately
// differs from the other 3 (dark-green) widgets on this screen.
// ---------------------------------------------------------------------------

import 'dart:math' as math;
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../../core/services/gics_sector_mapper.dart';
import '../../../core/theme/fomo_shield_theme.dart';
import '../../../core/theme/typography_helpers.dart';
import '../../../core/theme/app_palette.dart';
import '../../../core/theme/themed_header.dart';
import '../../../core/theme/themed_divider.dart';
import '../../../shared/widgets/card_frame.dart';
import '../../../l10n/gen/app_localizations.dart';
import '../psychology_engine.dart' show diversificationScoreForCount;
import '../stress_test_models.dart';
import '../stress_test_naming.dart';

// Relative baseline-risk tier per AssetSector — NOT the GBM engine's exact
// sigma values (those are private to gbm_engine.dart and tuned separately),
// just the same relative ordering: speculative tech is riskiest, staples
// calmest. Used only to rank a portfolio's overall Stability, not to
// simulate anything.
const Map<AssetSector, double> _sectorRiskWeight = {
  AssetSector.techSpeculative: 1.0,
  AssetSector.cyclicalConsumer: 0.65,
  AssetSector.etfBroadMarket: 0.45,
  AssetSector.realEstateREIT: 0.25,
  AssetSector.consumerStaples: 0.15,
};

class StressTestPortfolioHealthCard extends StatelessWidget {
  final StressTestSession session;
  final AppPalette palette;

  const StressTestPortfolioHealthCard({
    super.key,
    required this.session,
    required this.palette,
  });

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final holdings = session.holdings;
    // Cost basis (shares × avgCost — money actually invested), NOT current
    // market value. A market swing on ANY holding would otherwise shift
    // every other holding's allocation % without the user doing anything —
    // these scores are meant to grade a DECISION, not the market's mood.
    final values = <String, double>{};
    double total = 0;
    for (final h in holdings) {
      final val = h.shares * h.avgCost;
      values[h.symbol] = val;
      total += val;
    }
    final hasData = holdings.isNotEmpty && total > 0;

    double diversification = 0;
    double concentration = 0;
    double sectorBalance = 0;
    double stability = 0;

    if (hasData) {
      diversification = diversificationScoreForCount(
        holdings.length.toDouble(),
      );

      final maxHoldingPct = values.values.reduce(math.max) / total * 100;
      concentration = (100 - maxHoldingPct).clamp(0.0, 100.0);

      final sectorTotals = <String, double>{};
      for (final h in holdings) {
        final sector = stressTestGicsSector(h.symbol)?.label ?? 'Other';
        sectorTotals[sector] = (sectorTotals[sector] ?? 0) + values[h.symbol]!;
      }
      final maxSectorPct = sectorTotals.values.reduce(math.max) / total * 100;
      sectorBalance = (100 - maxSectorPct).clamp(0.0, 100.0);

      double riskWeighted = 0;
      for (final h in holdings) {
        final risk = _sectorRiskWeight[resolveAssetSector(h.symbol)] ?? 0.5;
        riskWeighted += (values[h.symbol]! / total) * risk;
      }
      stability = (100 - riskWeighted * 100).clamp(0.0, 100.0);
    }

    return CardFrame(
      padding: EdgeInsets.zero,
      decoration: FomoShieldTheme.cardDecoration,
      palette: palette,
      child: Column(
        children: [
          SizedBox(
            width: double.infinity,
            child: Padding(
              padding: const EdgeInsets.fromLTRB(22, 14, 22, 14),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  themedHeaderText(
                    l10n.portfolioHealthWidgetTitle,
                    palette,
                    FomoShieldTheme.cardTitle(),
                  ),
                  themedHelpIcon(
                    palette: palette,
                    onTap: () => context.push('/metric-info/portfolio-health'),
                  ),
                ],
              ),
            ),
          ),
          themedDivider(palette),
          if (hasData)
            Padding(
              padding: const EdgeInsets.fromLTRB(18, 18, 18, 14),
              child: Center(
                child: _HealthGaugeCluster(
                  diversification: diversification,
                  concentration: concentration,
                  sectorBalance: sectorBalance,
                  stability: stability,
                  palette: palette,
                ),
              ),
            )
          else
            const SizedBox(height: 60),
        ],
      ),
    );
  }
}

const Color _zoneRed = Color(0xFFFF3B30);
const Color _zoneYellow = Color(0xFFFFD600);
const Color _zoneGreen = Color(0xFF00C853);

Color _colorForScore(double s) {
  if (s < 33.3) return _zoneRed;
  if (s < 66.6) return _zoneYellow;
  return _zoneGreen;
}

// The gauge track (the pale full-circle guide behind the colored score
// arc) was a flat black@8% — fine on this card's light Standard
// background, but nearly invisible once the card turns dark under
// Luxury. `palette.titleGradient != null` is this file's stand-in for
// "Luxury is active" (this card has exactly one dark state, so no
// finer-grained gating is needed).
Color _trackColorFor(AppPalette palette) => palette.titleGradient != null
    ? Colors.white.withValues(alpha: 0.08)
    : Colors.black.withValues(alpha: 0.08);

// Corner gap orientation: each satellite gauge's opening faces INWARD,
// toward the center circle, instead of always facing down. Gap is a fixed
// 90° wide, centered on the angle pointing from that corner toward the
// middle (NW→SE, NE→SW, SW→NE, SE→NW); startAngle = gapCenter + 45°,
// sweeping 270° clockwise back around to gapCenter - 45°.
const double _startAngleNW = math.pi / 2; // gap centered SE (45°)
const double _startAngleNE = math.pi; // gap centered SW (135°)
const double _startAngleSW = 0; // gap centered NE (315°)
const double _startAngleSE = 3 * math.pi / 2; // gap centered NW (225°)

/// The whole Portfolio Health visual: 4 satellite gauges at the corners
/// (each open toward the shared center) plus one full-circle overall-score
/// gauge in the middle, slightly larger than the satellites.
class _HealthGaugeCluster extends StatelessWidget {
  final double diversification;
  final double concentration;
  final double sectorBalance;
  final double stability;
  final AppPalette palette;

  const _HealthGaugeCluster({
    required this.diversification,
    required this.concentration,
    required this.sectorBalance,
    required this.stability,
    required this.palette,
  });

  static const double _clusterSize = 300;
  static const double _cornerBox = 132;
  static const double _miniDiameter = 100;
  static const double _centerDiameter = 165;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final overall =
        (diversification + concentration + sectorBalance + stability) / 4;
    final overallColor = _colorForScore(overall);

    return SizedBox(
      width: _clusterSize,
      height: _clusterSize,
      child: Stack(
        alignment: Alignment.center,
        children: [
          Positioned(
            top: 0,
            left: 0,
            child: SizedBox(
              width: _cornerBox,
              height: _cornerBox,
              child: Align(
                alignment: Alignment.topLeft,
                child: _CornerGauge(
                  label: l10n.portfolioHealthWidgetDiversification,
                  score: diversification,
                  diameter: _miniDiameter,
                  startAngle: _startAngleNW,
                  labelBelow: false,
                  palette: palette,
                ),
              ),
            ),
          ),
          Positioned(
            top: 0,
            right: 0,
            child: SizedBox(
              width: _cornerBox,
              height: _cornerBox,
              child: Align(
                alignment: Alignment.topRight,
                child: _CornerGauge(
                  label: l10n.portfolioHealthWidgetConcentration,
                  score: concentration,
                  diameter: _miniDiameter,
                  startAngle: _startAngleNE,
                  labelBelow: false,
                  palette: palette,
                ),
              ),
            ),
          ),
          Positioned(
            bottom: 0,
            left: 0,
            child: SizedBox(
              width: _cornerBox,
              height: _cornerBox,
              child: Align(
                alignment: Alignment.bottomLeft,
                child: _CornerGauge(
                  label: l10n.portfolioHealthWidgetSectorBalance,
                  score: sectorBalance,
                  diameter: _miniDiameter,
                  startAngle: _startAngleSW,
                  labelBelow: true,
                  palette: palette,
                ),
              ),
            ),
          ),
          Positioned(
            bottom: 0,
            right: 0,
            child: SizedBox(
              width: _cornerBox,
              height: _cornerBox,
              child: Align(
                alignment: Alignment.bottomRight,
                child: _CornerGauge(
                  label: l10n.portfolioHealthWidgetStability,
                  score: stability,
                  diameter: _miniDiameter,
                  startAngle: _startAngleSE,
                  labelBelow: true,
                  palette: palette,
                ),
              ),
            ),
          ),
          SizedBox(
            width: _centerDiameter,
            height: _centerDiameter,
            child: Stack(
              alignment: Alignment.center,
              children: [
                CustomPaint(
                  size: Size.square(_centerDiameter),
                  painter: _GaugePainter(
                    percent: overall,
                    color: overallColor,
                    startAngle: -math.pi / 2,
                    totalSweep: 2 * math.pi,
                    glowOffset: 4,
                    trackColor: _trackColorFor(palette),
                  ),
                ),
                Text(
                  overall.round().toString(),
                  style: interNums(
                    fontSize: 40,
                    fontWeight: FontWeight.w600,
                    color: overallColor,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

/// One satellite gauge: a number inside an open ring whose gap faces the
/// cluster's center, with its label either above or below depending on
/// which corner it sits in.
class _CornerGauge extends StatelessWidget {
  final String label;
  final double score;
  final double diameter;
  final double startAngle;
  final bool labelBelow;
  final AppPalette palette;

  const _CornerGauge({
    required this.label,
    required this.score,
    required this.diameter,
    required this.startAngle,
    required this.labelBelow,
    required this.palette,
  });

  @override
  Widget build(BuildContext context) {
    final color = _colorForScore(score);
    final labelText = Text(
      label,
      textAlign: TextAlign.center,
      style: GoogleFonts.inter(
        fontSize: 11,
        fontWeight: FontWeight.w600,
        // Reads gray on Luxury Gold's dark card — flat white there instead
        // (user's explicit call, not the usual cream textHeader), same "is
        // Luxury active" check this file already uses elsewhere. Standard's
        // light card keeps the original gray.
        color: palette.titleGradient != null
            ? Colors.white
            : palette.textBody,
      ),
    );
    final gauge = SizedBox(
      width: diameter,
      height: diameter,
      child: Stack(
        alignment: Alignment.center,
        children: [
          CustomPaint(
            size: Size.square(diameter),
            painter: _GaugePainter(
              percent: score,
              color: color,
              startAngle: startAngle,
              totalSweep: 3 * math.pi / 2,
              glowOffset: 4,
              trackColor: _trackColorFor(palette),
            ),
          ),
          Text(
            score.round().toString(),
            style: interNums(
              fontSize: 24,
              fontWeight: FontWeight.w600,
              color: color,
            ),
          ),
        ],
      ),
    );

    return Column(
      mainAxisSize: MainAxisSize.min,
      children: labelBelow
          ? [gauge, const SizedBox(height: 4), labelText]
          : [labelText, const SizedBox(height: 4), gauge],
    );
  }
}

/// Ring gauge — pale track behind, a single-color arc filled proportional
/// to [percent] on top with a soft matching glow underneath. [totalSweep]
/// of 2π + any [startAngle] draws a full circle; a smaller sweep draws an
/// open gauge with a gap, oriented by [startAngle].
class _GaugePainter extends CustomPainter {
  final double percent;
  final Color color;
  final double startAngle;
  final double totalSweep;
  final double glowOffset;
  final Color trackColor;

  const _GaugePainter({
    required this.percent,
    required this.color,
    required this.startAngle,
    required this.totalSweep,
    this.glowOffset = 0,
    this.trackColor = const Color(0x14000000), // black @ 8%, prior default
  });

  // Matches the Allocation ring's stroke width (stress_test_allocation_
  // chart.dart's _DonutRingPainter) so the circular gauges on this screen
  // read as the same visual family.
  static const double _strokeWidth = 7;
  static const double _glowBlurSigma = 4;

  @override
  void paint(Canvas canvas, Size size) {
    final center = Offset(size.width / 2, size.height / 2);
    final radius = size.shortestSide / 2 - _strokeWidth / 2;
    final rect = Rect.fromCircle(center: center, radius: radius);

    final trackPaint = Paint()
      ..color = trackColor
      ..style = PaintingStyle.stroke
      ..strokeWidth = _strokeWidth
      ..strokeCap = StrokeCap.round;
    canvas.drawArc(rect, startAngle, totalSweep, false, trackPaint);

    final sweep = (percent.clamp(0, 100) / 100) * totalSweep;

    final glowPaint = Paint()
      ..color = color.withValues(alpha: 0.45)
      ..style = PaintingStyle.stroke
      ..strokeWidth = _strokeWidth
      ..strokeCap = StrokeCap.round
      ..maskFilter = const MaskFilter.blur(BlurStyle.normal, _glowBlurSigma);
    // Glow sits offset downward from the crisp arc above it — same trick
    // as the Allocation ring's _DonutRingPainter — so the ring reads as
    // lifted off the card instead of flat.
    canvas.save();
    canvas.translate(0, glowOffset);
    canvas.drawArc(rect, startAngle, sweep, false, glowPaint);
    canvas.restore();

    final fillPaint = Paint()
      ..color = color
      ..style = PaintingStyle.stroke
      ..strokeWidth = _strokeWidth
      ..strokeCap = StrokeCap.round;
    canvas.drawArc(rect, startAngle, sweep, false, fillPaint);
  }

  @override
  bool shouldRepaint(covariant _GaugePainter oldDelegate) =>
      oldDelegate.percent != percent ||
      oldDelegate.color != color ||
      oldDelegate.startAngle != startAngle ||
      oldDelegate.totalSweep != totalSweep ||
      oldDelegate.trackColor != trackColor;
}
