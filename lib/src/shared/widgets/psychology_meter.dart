// ---------------------------------------------------------------------------
// PsychologyMeter — FS Score ring + 4 sub-index progress bars + trade analytics
// ---------------------------------------------------------------------------
// Design Bible Part 7 — psychologyCard:
//   progress bar 12px, radius 999px
//   4 sub-indices: Discipline, Patience, Panic Resistance, Strategy
// Extended with: trade timing, sector diversification, concentration, frequency
// ---------------------------------------------------------------------------

import 'dart:math' as math;
import 'dart:ui' show ImageFilter;
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../core/theme/theme_v2.dart';
import '../../core/theme/typography_helpers.dart';
import '../../features/stress_test/stress_test_models.dart';
import '../../features/stress_test/psychology_engine.dart';
import '../../core/theme/fomo_shield_theme.dart';
import '../../l10n/gen/app_localizations.dart';
import '../utils/currency_format.dart';

/// Data for the Psychology Meter.
class PsychologyMeterData {
  final double fsScore; // 0-100, now equal to psychologicalScore — kept
  // as the field name every existing ring/label reads, see
  // psychologicalScore's doc for why the underlying formula changed.
  final double psychologicalScore; // 0-100, Discipline/Panic/Patience only
  final double strategicScore; // 0-100, portfolio-construction signals only
  final double panicResistance; // 0.0-1.0
  final double discipline; // 0.0-1.0
  final double patience; // 0.0-1.0
  final double strategyAdherence; // 0.0-1.0

  // ── Step 1: Trade timing analytics ────────────────────────────────
  final int totalTrades;
  final int buyTrades;
  final int sellTrades;
  final int boughtAtPeakCount;
  final int soldAtBottomCount;
  final double realizedPnl;

  // ── Step 2 & 3: Diversification & concentration ──────────────────
  final int sectorCount; // distinct sectors held
  final int holdingCount; // distinct companies currently held
  final int etfCount; // distinct ETFs currently held (subset of holdingCount)
  final int epochsPassed; // epochs completed/active so far this test
  final double maxConcentrationPct; // 0-100, biggest single asset %
  final bool hasDiversificationWarning;
  final double unrealizedPnl; // paper P&L on currently open positions

  // ── Step 4: Trade frequency ───────────────────────────────────────
  final double tradesPerDay;

  // ── Cash buffer for risk analysis ──────────────────────────────────
  final double cashBufferPct; // % of portfolio held in cash

  const PsychologyMeterData({
    required this.fsScore,
    required this.psychologicalScore,
    required this.strategicScore,
    required this.panicResistance,
    required this.discipline,
    required this.patience,
    required this.strategyAdherence,
    this.totalTrades = 0,
    this.buyTrades = 0,
    this.sellTrades = 0,
    this.boughtAtPeakCount = 0,
    this.soldAtBottomCount = 0,
    this.realizedPnl = 0,
    this.sectorCount = 0,
    this.holdingCount = 0,
    this.etfCount = 0,
    this.epochsPassed = 0,
    this.maxConcentrationPct = 0,
    this.hasDiversificationWarning = false,
    this.unrealizedPnl = 0,
    this.tradesPerDay = 0,
    this.cashBufferPct = 0,
  });

  factory PsychologyMeterData.fromProfile(TraderPsychologyProfile profile) {
    final psychScore = (profile.psychologicalScore() * 100)
        .round()
        .clamp(0, 100)
        .toDouble();
    return PsychologyMeterData(
      fsScore: psychScore,
      psychologicalScore: psychScore,
      // No holdings available in this factory (profile-only, unused by any
      // current call site) — strategyAdherence is the closest approximation.
      strategicScore: (profile.strategyAdherence * 100).clamp(0, 100),
      panicResistance: profile.panicResistance,
      discipline: profile.discipline,
      patience: profile.patience,
      strategyAdherence: profile.strategyAdherence,
    );
  }

  /// Full factory using both profile + session data (4-step analytics).
  factory PsychologyMeterData.fromSession(StressTestSession session) {
    final profile = session.psychologyProfile;
    final trades = session.trades;
    final totalTrades = trades.length;
    final buyTrades = trades.where((t) => t.isBuy).length;
    final sellTrades = trades.where((t) => !t.isBuy).length;
    final boughtAtPeak = trades.where((t) => t.isBuy && t.wasPeak).length;
    final soldAtBottom = trades.where((t) => !t.isBuy && t.wasBottom).length;

    // Sector diversity
    final sectors = <MarketSector>{}; // FIXED: use MarketSector enum
    for (final h in session.holdings) {
      try {
        sectors.add(_symbolToSector(h.symbol));
      } catch (_) {}
    }

    // Trade frequency
    double tpd = 0;
    if (session.startedAt != null && totalTrades > 0) {
      final elapsedDays =
          DateTime.now().difference(session.startedAt!).inMinutes / 1440.0;
      // Floor at 0.25 days (6 hours) to prevent insane extrapolation
      // when trades happen in the first few seconds.
      tpd = totalTrades / elapsedDays.clamp(0.25, double.infinity);
    }

    final safetyMarker = safetyMarkerFor(session.holdings).score;
    final strategySubScores = computeStrategySubScores(
      holdings: session.holdings,
      cash: session.cash,
    );
    final psychScore = (profile.psychologicalScore() * 100)
        .round()
        .clamp(0, 100)
        .toDouble();
    final stratScore =
        (computeStrategicScore(
                  diversification: strategySubScores.diversification,
                  sector: strategySubScores.sector,
                  concentration: strategySubScores.concentration,
                  etf: strategySubScores.etf,
                  cashBuffer: strategySubScores.cashBuffer,
                  safetyMarker: safetyMarker,
                ) *
                100)
            .round()
            .clamp(0, 100)
            .toDouble();

    return PsychologyMeterData(
      fsScore: psychScore,
      psychologicalScore: psychScore,
      strategicScore: stratScore,
      panicResistance: profile.panicResistance,
      discipline: profile.discipline,
      patience: profile.patience,
      strategyAdherence: profile.strategyAdherence,
      totalTrades: totalTrades,
      buyTrades: buyTrades,
      sellTrades: sellTrades,
      boughtAtPeakCount: boughtAtPeak,
      soldAtBottomCount: soldAtBottom,
      realizedPnl: session.realizedPnl,
      sectorCount: sectors.length,
      holdingCount: session.holdings.length,
      etfCount: session.holdings
          .where(
            (h) =>
                h.isEtf ||
                resolveAssetSector(h.symbol) == AssetSector.etfBroadMarket,
          )
          .length,
      epochsPassed: session.epochHistory.length,
      maxConcentrationPct: (session.currentMaxAllocation * 100).roundToDouble(),
      hasDiversificationWarning: session.currentMaxAllocation > 0.50,
      unrealizedPnl: session.unrealizedPnl,
      tradesPerDay: tpd,
      cashBufferPct: session.totalValue > 0
          ? (session.cash / session.totalValue * 100)
          : 0,
    );
  }
}

/// Map symbol → sector (uses canonical mapping from models).
MarketSector _symbolToSector(String symbol) {
  final assetSector = resolveAssetSector(symbol);
  return marketSectorToAssetSectorReversed(assetSector);
}

/// Psychology Meter card: FS Score ring + 4 sub-index progress bars + analytics.
/// Tappable during active simulation → opens a Live Audit Bottom Sheet
/// analysing what the user is doing right, wrong, and active risks.
class PsychologyMeter extends StatelessWidget {
  final PsychologyMeterData data;
  final String sessionId;

  const PsychologyMeter({
    super.key,
    required this.data,
    required this.sessionId,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      decoration: FomoShieldTheme.cardDecoration,
      clipBehavior: Clip.antiAlias,
      child: Column(
        children: [
          InkWell(
            onTap: () =>
                context.push('/stress-test/$sessionId/psychology-meter'),
            child: Padding(
              padding: const EdgeInsets.fromLTRB(22, 14, 22, 14),
              child: Row(
                children: [
                  Text(
                    AppLocalizations.of(context)!.stressTestPsychologyMeterTitle,
                    style: FomoShieldTheme.cardTitle(),
                  ),
                  const SizedBox(width: 6),
                  GestureDetector(
                    onTap: () => context.push('/metric-info/investor-score'),
                    child: Container(
                      width: 20,
                      height: 20,
                      decoration: BoxDecoration(
                        color: Colors.black.withValues(alpha: 0.06),
                        borderRadius: BorderRadius.circular(10),
                      ),
                      alignment: Alignment.center,
                      child: const Icon(
                        Icons.help_outline_rounded,
                        size: 13,
                        color: ThemeV2.textSecondary,
                      ),
                    ),
                  ),
                  const Spacer(),
                  const Icon(
                    Icons.chevron_right_rounded,
                    color: ThemeV2.textSecondary,
                    size: 20,
                  ),
                ],
              ),
            ),
          ),
          Divider(
            height: 1,
            indent: 16,
            endIndent: 16,
            color: Colors.black.withValues(alpha: 0.06),
          ),
          Padding(
            padding: const EdgeInsets.fromLTRB(22, 18, 22, 22),
            child: GestureDetector(
              onTap: () => _showAuditSheet(context, data),
              child: _PsychologyMeterBody(data: data),
            ),
          ),
        ],
      ),
    );
  }
}

/// Raw session numbers: trade counts, holdings, ETF count, unrealized +
/// realized P&L — plain counters, not scored 0-100 bars (those live in the
/// Discipline/Panic/Patience/Strategy/Diversification cards above this one
/// on the Psychology Meter detail screen). Sectors-held, max-allocation,
/// and trade frequency were cut 2026-08-07 — the first two duplicate what
/// the Diversification/Strategy cards' own bars already show as a score,
/// frequency wasn't a useful signal on its own. ETF count reuses the same
/// isEtf/etfBroadMarket predicate as computeStrategySubScores
/// (psychology_engine.dart) — Finnhub tags real ETFs `type: 'ETP'`, not
/// `'ETF'`, so don't check the literal string here either (see
/// isEtfSecurityType in finnhub_service.dart for the shared fix). Same row
/// style as verdict_screen.dart's Session Stats card (`_statRow`) — keep
/// the two in sync if either changes.
/// Public — reused by the Psychology Meter detail screen
/// (stress_test_psychology_meter_screen.dart).
class PsychologyAnalyticsSection extends StatelessWidget {
  final PsychologyMeterData data;

  const PsychologyAnalyticsSection({super.key, required this.data});

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _statRow(l10n.stressTestAnalyticsTotalTrades, '${data.totalTrades}'),
        _statRow(l10n.stressTestAnalyticsTradesBuy, '${data.buyTrades}'),
        _statRow(l10n.stressTestAnalyticsTradesSell, '${data.sellTrades}'),
        _statRow(l10n.stressTestWidgetHoldings, '${data.holdingCount}'),
        _statRow('ETF', '${data.etfCount}'),
        _statRow(l10n.stressTestWidgetEpochs, '${data.epochsPassed}'),
        _statRow(
          l10n.stressTestAnalyticsUnrealizedPnl,
          formatUsdSigned(data.unrealizedPnl),
          valueColor: data.unrealizedPnl >= 0
              ? FomoShieldTheme.positive
              : FomoShieldTheme.negative,
        ),
        _statRow(
          l10n.stressTestAnalyticsRealizedPnl,
          formatUsdSigned(data.realizedPnl),
          valueColor: data.realizedPnl >= 0
              ? FomoShieldTheme.positive
              : FomoShieldTheme.negative,
          isLast: true,
        ),
      ],
    );
  }

  Widget _statRow(
    String label,
    String value, {
    Color? valueColor,
    bool isLast = false,
  }) {
    return Padding(
      padding: EdgeInsets.only(bottom: isLast ? 0 : 10),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            label,
            style: GoogleFonts.inter(
              fontSize: 13,
              color: FomoShieldTheme.textLight,
            ),
          ),
          Text(
            value,
            style: GoogleFonts.inter(
              fontSize: 14,
              fontWeight: FontWeight.w700,
              color: valueColor ?? FomoShieldTheme.text,
            ),
          ),
        ],
      ),
    );
  }
}

/// Body of Psychology Meter (separated for CardFrame wrapping).
class _PsychologyMeterBody extends StatelessWidget {
  final PsychologyMeterData data;

  const _PsychologyMeterBody({required this.data});

  @override
  Widget build(BuildContext context) {
    // Ring shows the average of the two 2026-08-16-split scores — this
    // compact card is a quick glance, not the place for a per-signal
    // breakdown (that's what the Psychology Meter detail screen's own
    // Strategy Score / Psychology Score circles + Discipline/Panic/
    // Patience/Strategy/Diversification cards are for).
    final avgScore = (data.psychologicalScore + data.strategicScore) / 2;
    final l10n = AppLocalizations.of(context)!;

    return Column(
      children: [
        FsScoreRing(score: avgScore),
        const SizedBox(height: 20),
        _SubIndexRow(
          label: l10n.stressTestStrategyScore,
          value: data.strategicScore / 100,
        ),
        _SubIndexRow(
          label: l10n.stressTestPsychologyScore,
          value: data.psychologicalScore / 100,
          isLast: true,
        ),
      ],
    );
  }
}

/// FS Score gauge — full-width car-speedometer dial: 270° arc (a 90° gap
/// at the bottom), static red→yellow→green track (same 3-stop palette as
/// the sub-index bars), tick marks + numbers at 0/20/40/60/80/100, and a
/// needle pivoting from the dial's center pointing at the current score.
/// The numeric readout sits in a small pill below the pivot, in the open
/// bottom gap, occluding whatever part of the needle passes behind it.
class FsScoreRing extends StatelessWidget {
  final double score; // 0-100

  const FsScoreRing({super.key, required this.score});

  Color get _color {
    if (score >= 70) return FomoShieldTheme.positive;
    if (score >= 40) return FomoShieldTheme.sideways;
    return FomoShieldTheme.negative;
  }

  // How far the tick marks + their number labels reach beyond the arc's
  // own radius — must stay in sync with _SpeedometerPainter's tick metrics.
  static const double _outerPad = 60;
  static const double _sideSin = 0.7071; // sin(135°) / sin(45°)
  static const double _pillTopGap = 52;
  static const double _pillHeight = 56;

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        final width = constraints.maxWidth.isFinite
            ? constraints.maxWidth
            : 260.0;
        final radius = (width / 2 - _outerPad).clamp(60.0, 220.0);
        final topExtent = radius + _outerPad;
        final sideBottomExtent = radius * _sideSin + _outerPad;
        final centerY = topExtent + 8;
        final height =
            centerY + math.max(sideBottomExtent, _pillTopGap + _pillHeight) + 8;
        final center = Offset(width / 2, centerY);

        return SizedBox(
          width: width,
          height: height,
          child: Stack(
            children: [
              CustomPaint(
                size: Size(width, height),
                painter: _SpeedometerPainter(
                  score: score,
                  needleColor: FomoShieldTheme.text,
                  accentColor: _color,
                  center: center,
                  radius: radius,
                ),
              ),
              Positioned(
                left: 0,
                right: 0,
                top: centerY + _pillTopGap,
                child: Center(
                  child: Container(
                    width: 110,
                    padding: const EdgeInsets.symmetric(vertical: 6),
                    decoration: BoxDecoration(
                      color: FomoShieldTheme.card,
                      borderRadius: BorderRadius.circular(14),
                      border: Border.all(
                        color: FomoShieldTheme.border.withValues(alpha: 0.6),
                      ),
                    ),
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Text(
                          '${score.round()}',
                          textAlign: TextAlign.center,
                          style: interNums(
                            fontSize: 26,
                            fontWeight: FontWeight.w900,
                            color: FomoShieldTheme.text,
                            letterSpacing: -1,
                          ),
                        ),
                        Text(
                          AppLocalizations.of(context)!.stressTestScoreLabel,
                          textAlign: TextAlign.center,
                          style: GoogleFonts.inter(
                            fontSize: 10,
                            fontWeight: FontWeight.w600,
                            color: FomoShieldTheme.textLight,
                            letterSpacing: 0.4,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ],
          ),
        );
      },
    );
  }
}

/// Custom painter for the FS Score gauge dial — see FsScoreRing.
class _SpeedometerPainter extends CustomPainter {
  final double score;
  final Color needleColor;
  final Color accentColor;
  final Offset center;
  final double radius;

  _SpeedometerPainter({
    required this.score,
    required this.needleColor,
    required this.accentColor,
    required this.center,
    required this.radius,
  });

  static const double _startAngle = 3 * math.pi / 4; // 135°, down-left
  static const double _sweepAngle = 3 * math.pi / 2; // 270°, ends down-right
  static const double _strokeWidth = 18.0;
  static const Color _red = Color(0xFFFF3B30);
  static const Color _yellow = Color(0xFFFFD600);
  static const Color _green = Color(0xFF00C853);
  static const List<int> _majorTicks = [0, 20, 40, 60, 80, 100];
  static const List<int> _minorTicks = [10, 30, 50, 70, 90];
  static const double _glowOffset = 5;
  static const double _glowBlurSigma = 6;

  @override
  void paint(Canvas canvas, Size size) {
    final rect = Rect.fromCircle(center: center, radius: radius);

    // Track gradient — same 3-stop palette as the sub-index bars / TARGET's
    // segmented bar, spun across the FULL circle (not just the visible
    // 270°) with a 4th stop back at red. A SweepGradient always has a seam
    // where its angle wraps; with only 3 stops over 270° that seam landed
    // exactly on the arc's own round start-cap, which bulges slightly past
    // the mathematical start angle and sampled the wrapped-around tail
    // (green) instead of clamping to red — a green fleck on the red end.
    // Coloring the hidden 90° gap green→red closes the loop so the seam
    // sits where both sides already agree on the color.
    final sweepFraction = _sweepAngle / (2 * math.pi);
    final trackShader = SweepGradient(
      colors: const [_red, _yellow, _green, _red],
      stops: [0.0, sweepFraction / 2, sweepFraction, 1.0],
      transform: const GradientRotation(_startAngle),
    ).createShader(rect);

    // Needle geometry — computed up front so both the glow pass and the
    // crisp pass draw the exact same shape.
    final t = (score / 100.0).clamp(0.0, 1.0);
    final needleAngle = _startAngle + _sweepAngle * t;
    final dir = Offset(math.cos(needleAngle), math.sin(needleAngle));
    final perp = Offset(-dir.dy, dir.dx);
    final needleLength = radius - 20;
    const baseHalfWidth = 4.5;
    final tip = center + dir * needleLength;
    final baseL = center + perp * baseHalfWidth;
    final baseR = center - perp * baseHalfWidth;
    final needlePath = Path()
      ..moveTo(tip.dx, tip.dy)
      ..lineTo(baseL.dx, baseL.dy)
      ..lineTo(baseR.dx, baseR.dy)
      ..close();

    // ── Glow pass — track + needle, one shared blur layer offset down.
    // Mirrors StressTestAllocationChart's _DonutRingPainter: a single
    // saveLayer/blur for everything glowing (not one MaskFilter.blur per
    // element) — per-element blur passes were the root cause of a prior
    // GPU raster corruption bug on MediaTek devices at higher element
    // counts, see project memory on the allocation ring.
    canvas.saveLayer(
      rect.inflate(_strokeWidth + _glowBlurSigma * 3),
      Paint()
        ..imageFilter = ImageFilter.blur(
          sigmaX: _glowBlurSigma,
          sigmaY: _glowBlurSigma,
        ),
    );
    canvas.save();
    canvas.translate(0, _glowOffset);
    canvas.drawArc(
      rect,
      _startAngle,
      _sweepAngle,
      false,
      Paint()
        ..shader = trackShader
        ..color = Colors.black.withValues(alpha: 0.55)
        ..style = PaintingStyle.stroke
        ..strokeWidth = _strokeWidth
        ..strokeCap = StrokeCap.round,
    );
    canvas.drawPath(
      needlePath,
      Paint()..color = needleColor.withValues(alpha: 0.5),
    );
    canvas.drawCircle(
      center,
      10,
      Paint()..color = needleColor.withValues(alpha: 0.5),
    );
    canvas.restore();
    canvas.restore();

    // ── Crisp pass — actual track, ticks, needle (no blur, no offset) ──
    canvas.drawArc(
      rect,
      _startAngle,
      _sweepAngle,
      false,
      Paint()
        ..shader = trackShader
        ..style = PaintingStyle.stroke
        ..strokeWidth = _strokeWidth
        ..strokeCap = StrokeCap.round,
    );

    for (final tick in _majorTicks) {
      _drawTick(canvas, tick / 100.0, label: '$tick');
    }
    for (final tick in _minorTicks) {
      _drawTick(canvas, tick / 100.0);
    }

    // Needle — a tapered triangle (not a plain stroked line) for a cleaner
    // pointer look, plus a 3-layer hub (dark outer, status-colored ring,
    // white center) instead of a flat dot.
    canvas.drawPath(needlePath, Paint()..color = needleColor);
    canvas.drawCircle(center, 10, Paint()..color = needleColor);
    canvas.drawCircle(center, 6.5, Paint()..color = accentColor);
    canvas.drawCircle(center, 3, Paint()..color = FomoShieldTheme.card);
  }

  /// Draws one tick line at [t] (0.0-1.0 across the dial). Pass [label] for
  /// a labeled major tick; omit it for a short, dim, unlabeled minor tick.
  void _drawTick(Canvas canvas, double t, {String? label}) {
    final angle = _startAngle + _sweepAngle * t;
    final cosA = math.cos(angle);
    final sinA = math.sin(angle);
    final isMajor = label != null;
    final innerR = radius + _strokeWidth / 2 + 3;
    final outerR = innerR + (isMajor ? 10 : 6);

    final p1 = Offset(center.dx + innerR * cosA, center.dy + innerR * sinA);
    final p2 = Offset(center.dx + outerR * cosA, center.dy + outerR * sinA);
    final tickPaint = Paint()
      ..color = FomoShieldTheme.textLight.withValues(
        alpha: isMajor ? 0.6 : 0.35,
      )
      ..strokeWidth = isMajor ? 2 : 1.5;
    canvas.drawLine(p1, p2, tickPaint);

    if (label == null) return;

    final labelR = outerR + 16;
    final labelCenter = Offset(
      center.dx + labelR * cosA,
      center.dy + labelR * sinA,
    );
    final tp = TextPainter(
      text: TextSpan(
        text: label,
        style: GoogleFonts.inter(
          fontSize: 10,
          fontWeight: FontWeight.w600,
          color: FomoShieldTheme.textLight,
        ),
      ),
      textDirection: TextDirection.ltr,
    )..layout();
    tp.paint(canvas, labelCenter - Offset(tp.width / 2, tp.height / 2));
  }

  @override
  bool shouldRepaint(_SpeedometerPainter old) =>
      old.score != score ||
      old.accentColor != accentColor ||
      old.center != center ||
      old.radius != radius;
}

/// Single sub-index row: label + filled/glowing bar + value. Visual match
/// for AllocationBarRow (Diversification Indicator card) — same glow-bar
/// look, adapted for a light card background (dark text, light track).
/// Fill color is a red→yellow→green lerp keyed to the row's own value —
/// same 3-stop palette as TARGET's _SegmentedBar / Diversification
/// Progress's segmented bar (a direct red→green lerp dips through a muddy
/// brown, not yellow — this avoids that).
class _SubIndexRow extends StatelessWidget {
  final String label;
  final double value; // 0.0-1.0
  final bool isLast;

  const _SubIndexRow({
    required this.label,
    required this.value,
    this.isLast = false,
  });

  static const Color _red = Color(0xFFFF3B30);
  static const Color _yellow = Color(0xFFFFD600);
  static const Color _green = Color(0xFF00C853);

  Color get _color {
    final t = value.clamp(0.0, 1.0);
    if (t <= 0.5) return Color.lerp(_red, _yellow, t / 0.5)!;
    return Color.lerp(_yellow, _green, (t - 0.5) / 0.5)!;
  }

  @override
  Widget build(BuildContext context) {
    final percent = (value * 100).clamp(0.0, 100.0);
    final color = _color;

    return Padding(
      padding: EdgeInsets.only(bottom: isLast ? 0 : 14),
      child: Row(
        children: [
          SizedBox(
            width: 112,
            child: Text(
              label,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: GoogleFonts.inter(
                fontSize: 12.5,
                fontWeight: FontWeight.w600,
                color: FomoShieldTheme.text,
              ),
            ),
          ),
          const SizedBox(width: 10),
          Expanded(
            child: SizedBox(
              height: 8,
              child: Stack(
                children: [
                  Container(
                    decoration: BoxDecoration(
                      color: FomoShieldTheme.border.withValues(alpha: 0.4),
                      borderRadius: BorderRadius.circular(4),
                    ),
                  ),
                  FractionallySizedBox(
                    widthFactor: (percent / 100).clamp(0.0, 1.0),
                    child: Container(
                      decoration: BoxDecoration(
                        color: color,
                        borderRadius: BorderRadius.circular(4),
                        boxShadow: [
                          BoxShadow(
                            color: color.withValues(alpha: 0.5),
                            blurRadius: 6,
                            spreadRadius: 0.5,
                          ),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(width: 10),
          SizedBox(
            width: 32,
            child: Text(
              '${percent.round()}',
              textAlign: TextAlign.right,
              style: interNums(
                fontSize: 12.5,
                fontWeight: FontWeight.w700,
                color: FomoShieldTheme.text,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

// ═══════════════════════════════════════════════════════════════════════════
// Live Audit Bottom Sheet — opens on Psychology Meter tap
// ═══════════════════════════════════════════════════════════════════════════

/// Opens the live audit Bottom Sheet with a jargon-free analysis
/// of the user's current actions, split into three sections.
void _showAuditSheet(BuildContext context, PsychologyMeterData data) {
  final l10n = AppLocalizations.of(context)!;
  final rights = <String>[];
  final mistakes = <String>[];
  final risks = <String>[];

  String timesLabel(int n) =>
      n == 1 ? l10n.psychologyAuditTimesOnce : l10n.psychologyAuditTimesCount(n);

  // ── 🟢 What you are doing right ──────────────────────────────────
  if (data.strategyAdherence > 0.6) {
    rights.add(l10n.psychologyAuditRightDiversifying);
  }
  if (data.patience > 0.6) {
    rights.add(l10n.psychologyAuditRightPatience);
  }
  if (data.discipline > 0.6) {
    rights.add(l10n.psychologyAuditRightDiscipline);
  }
  if (data.panicResistance > 0.6) {
    rights.add(l10n.psychologyAuditRightNerve);
  }
  if (data.sectorCount >= 3) {
    rights.add(l10n.psychologyAuditRightSectorSpread(data.sectorCount));
  }
  if (data.cashBufferPct >= 15) {
    rights.add(
      l10n.psychologyAuditRightCashBuffer(data.cashBufferPct.round()),
    );
  }

  // ── 🔴 Where you are messing up ─────────────────────────────────
  if (data.discipline < 0.4 && data.discipline > 0.0) {
    mistakes.add(l10n.psychologyAuditMistakeFomoBuying);
  }
  if (data.panicResistance < 0.4 && data.panicResistance > 0.0) {
    mistakes.add(l10n.psychologyAuditMistakePanicSelling);
  }
  if (data.strategyAdherence < 0.4 &&
      data.strategyAdherence > 0.0 &&
      data.sectorCount < 3) {
    mistakes.add(l10n.psychologyAuditMistakeLackDiversification);
  }
  if (data.patience < 0.4 && data.patience > 0.0) {
    mistakes.add(l10n.psychologyAuditMistakeOvertrading);
  }
  if (data.boughtAtPeakCount > 0) {
    mistakes.add(
      l10n.psychologyAuditMistakeBoughtAtPeak(
        timesLabel(data.boughtAtPeakCount),
      ),
    );
  }
  if (data.soldAtBottomCount > 0) {
    mistakes.add(
      l10n.psychologyAuditMistakeSoldAtBottom(
        timesLabel(data.soldAtBottomCount),
      ),
    );
  }

  // ── ⚠️ Current Risks ────────────────────────────────────────────
  if (data.maxConcentrationPct > 40) {
    risks.add(l10n.psychologyAuditRiskConcentration);
  }
  if (data.cashBufferPct < 5 && data.totalTrades > 0) {
    risks.add(l10n.psychologyAuditRiskNoSafetyNet);
  }
  if (data.sectorCount == 1) {
    risks.add(l10n.psychologyAuditRiskSingleSector);
  }
  if (data.tradesPerDay > 3) {
    risks.add(
      l10n.psychologyAuditRiskOvertrading(
        data.tradesPerDay.toStringAsFixed(1),
      ),
    );
  }
  if (data.realizedPnl < -500) {
    risks.add(l10n.psychologyAuditRiskRealizedLosses);
  }

  // ── Fallback: all metrics at 0.0 (fresh session) ────────────────
  final allZero =
      data.panicResistance == 0.0 &&
      data.discipline == 0.0 &&
      data.patience == 0.0 &&
      data.strategyAdherence == 0.0;

  showModalBottomSheet<void>(
    context: context,
    isScrollControlled: true,
    backgroundColor: FomoShieldTheme.card,
    shape: const RoundedRectangleBorder(
      borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
    ),
    builder: (ctx) => _AuditSheetContent(
      fsScore: data.fsScore,
      rights: rights,
      mistakes: mistakes,
      risks: risks,
      allZero: allZero,
    ),
  );
}

/// The content of the Live Audit Bottom Sheet.
class _AuditSheetContent extends StatelessWidget {
  final double fsScore;
  final List<String> rights;
  final List<String> mistakes;
  final List<String> risks;
  final bool allZero;

  const _AuditSheetContent({
    required this.fsScore,
    required this.rights,
    required this.mistakes,
    required this.risks,
    required this.allZero,
  });

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final bottomPad = MediaQuery.of(context).padding.bottom;
    return DraggableScrollableSheet(
      initialChildSize: 0.75,
      minChildSize: 0.4,
      maxChildSize: 0.92,
      expand: false,
      builder: (ctx, scrollController) {
        return ListView(
          controller: scrollController,
          padding: EdgeInsets.fromLTRB(24, 8, 24, bottomPad + 24),
          children: [
            // ── Drag handle ──────────────────────────────────────
            Center(
              child: Container(
                width: 40,
                height: 4,
                margin: const EdgeInsets.only(bottom: 16),
                decoration: BoxDecoration(
                  color: FomoShieldTheme.border,
                  borderRadius: BorderRadius.circular(999),
                ),
              ),
            ),

            // ── Header ───────────────────────────────────────────
            if (allZero) ...[
              _buildHeader(
                icon: Icons.auto_awesome,
                iconColor: FomoShieldTheme.sideways,
                title: l10n.psychologyAuditFreshTitle,
              ),
              const SizedBox(height: 16),
              _buildTip(l10n.psychologyAuditFreshTip),
            ] else ...[
              _buildHeader(
                icon: Icons.psychology_outlined,
                iconColor: _fsScoreColor(fsScore),
                title: l10n.psychologyAuditTitle,
                subtitle: l10n.psychologyAuditSubtitle(fsScore.round()),
              ),
              const SizedBox(height: 20),

              // ── 🟢 What you are doing right ────────────────────
              if (rights.isNotEmpty) ...[
                _sectionTitle(
                  l10n.psychologyAuditSectionRights,
                  FomoShieldTheme.positive,
                ),
                const SizedBox(height: 8),
                ...rights.map(
                  (r) => _sectionItem(
                    r,
                    FomoShieldTheme.positive.withValues(alpha: 0.12),
                  ),
                ),
                const SizedBox(height: 16),
              ],

              // ── 🔴 Where you are messing up ────────────────────
              if (mistakes.isNotEmpty) ...[
                _sectionTitle(
                  l10n.psychologyAuditSectionMistakes,
                  FomoShieldTheme.negative,
                ),
                const SizedBox(height: 8),
                ...mistakes.map(
                  (m) => _sectionItem(
                    m,
                    FomoShieldTheme.negative.withValues(alpha: 0.10),
                  ),
                ),
                const SizedBox(height: 16),
              ],

              // ── ⚠️ Current Risks ──────────────────────────────
              if (risks.isNotEmpty) ...[
                _sectionTitle(
                  l10n.psychologyAuditSectionRisks,
                  FomoShieldTheme.sideways,
                ),
                const SizedBox(height: 8),
                ...risks.map(
                  (r) => _sectionItem(
                    r,
                    FomoShieldTheme.sideways.withValues(alpha: 0.12),
                  ),
                ),
              ],

              // ── All clear ──────────────────────────────────────
              if (rights.isEmpty && mistakes.isEmpty && risks.isEmpty)
                _buildTip(l10n.psychologyAuditAllClearTip),
            ],
          ],
        );
      },
    );
  }

  Widget _buildHeader({
    required IconData icon,
    required Color iconColor,
    required String title,
    String? subtitle,
  }) {
    return Column(
      children: [
        Container(
          width: 56,
          height: 56,
          decoration: BoxDecoration(
            color: iconColor.withValues(alpha: 0.12),
            borderRadius: BorderRadius.circular(16),
          ),
          child: Icon(icon, color: iconColor, size: 28),
        ),
        const SizedBox(height: 12),
        Text(
          title,
          textAlign: TextAlign.center,
          style: GoogleFonts.inter(
            fontSize: 18,
            fontWeight: FontWeight.w700,
            color: FomoShieldTheme.text,
            height: 1.3,
          ),
        ),
        if (subtitle != null) ...[
          const SizedBox(height: 4),
          Text(
            subtitle,
            style: GoogleFonts.inter(
              fontSize: 13,
              fontWeight: FontWeight.w600,
              color: iconColor,
            ),
          ),
        ],
      ],
    );
  }

  Widget _buildTip(String text) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: FomoShieldTheme.sideways.withValues(alpha: 0.08),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(
          color: FomoShieldTheme.sideways.withValues(alpha: 0.2),
          width: 1,
        ),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Padding(
            padding: EdgeInsets.only(top: 2),
            child: Text('💡', style: TextStyle(fontSize: 16)),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Text(
              text,
              style: GoogleFonts.inter(
                fontSize: 14,
                fontWeight: FontWeight.w500,
                color: FomoShieldTheme.text,
                height: 1.5,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _sectionTitle(String text, Color color) {
    return Text(
      text,
      style: GoogleFonts.inter(
        fontSize: 14,
        fontWeight: FontWeight.w700,
        color: color,
        height: 1.3,
      ),
    );
  }

  Widget _sectionItem(String text, Color bgColor) {
    return Container(
      width: double.infinity,
      margin: const EdgeInsets.only(bottom: 8),
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
      decoration: BoxDecoration(
        color: bgColor,
        borderRadius: BorderRadius.circular(14),
      ),
      child: Text(
        text,
        style: GoogleFonts.inter(
          fontSize: 13,
          fontWeight: FontWeight.w500,
          color: FomoShieldTheme.text,
          height: 1.45,
        ),
      ),
    );
  }

  Color _fsScoreColor(double score) {
    if (score >= 70) return FomoShieldTheme.positive;
    if (score >= 40) return FomoShieldTheme.sideways;
    return FomoShieldTheme.negative;
  }
}

/// Opens audit from outside (used by screen builder).
void showPsychologyAudit(BuildContext context, PsychologyMeterData data) {
  _showAuditSheet(context, data);
}
