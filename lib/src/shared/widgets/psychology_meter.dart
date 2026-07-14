// ---------------------------------------------------------------------------
// PsychologyMeter — FS Score ring + 4 sub-index progress bars + trade analytics
// ---------------------------------------------------------------------------
// Design Bible Part 7 — psychologyCard:
//   progress bar 12px, radius 999px
//   4 sub-indices: Discipline, Patience, Panic Resistance, Strategy
// Extended with: trade timing, sector diversification, concentration, frequency
// ---------------------------------------------------------------------------

import 'dart:math' as math;
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../core/theme/theme_v2.dart';
import '../../core/theme/typography_helpers.dart';
import 'package:intl/intl.dart';
import '../../features/stress_test/stress_test_models.dart';
import '../../core/theme/fomo_shield_theme.dart';
import 'card_frame.dart';

/// Data for the Psychology Meter.
class PsychologyMeterData {
  final double fsScore; // 0-100 composite
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
  final double maxConcentrationPct; // 0-100, biggest single asset %
  final bool hasDiversificationWarning;

  // ── Step 4: Trade frequency ───────────────────────────────────────
  final double tradesPerDay;

  // ── Cash buffer for risk analysis ──────────────────────────────────
  final double cashBufferPct; // % of portfolio held in cash

  const PsychologyMeterData({
    required this.fsScore,
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
    this.maxConcentrationPct = 0,
    this.hasDiversificationWarning = false,
    this.tradesPerDay = 0,
    this.cashBufferPct = 0,
  });

  factory PsychologyMeterData.fromProfile(TraderPsychologyProfile profile) {
    return PsychologyMeterData(
      fsScore: (profile.compositeScore * 100).round().clamp(0, 100).toDouble(),
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

    return PsychologyMeterData(
      fsScore: (profile.compositeScore * 100).round().clamp(0, 100).toDouble(),
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
      maxConcentrationPct: (session.currentMaxAllocation * 100).roundToDouble(),
      hasDiversificationWarning: session.currentMaxAllocation > 0.50,
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

  const PsychologyMeter({super.key, required this.data});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () => _showAuditSheet(context, data),
      child: CardFrame(
        showTopBar: false,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Expanded(
                  child: Text(
                    'PSYCHOLOGY METER',
                    style: FomoShieldTheme.cardTitle(),
                  ),
                ),
                Icon(
                  Icons.info_outline,
                  size: 14,
                  color: FomoShieldTheme.textLight.withValues(alpha: 0.5),
                ),
              ],
            ),
            const SizedBox(height: 20),
            _PsychologyMeterBody(data: data),
            // ── Trade & portfolio analytics section ──────────────
            if (data.totalTrades > 0) ...[
              const SizedBox(height: 16),
              _DividerLine(),
              const SizedBox(height: 10),
              _AnalyticsSection(data: data),
            ],
          ],
        ),
      ),
    );
  }
}

/// Thin divider line.
class _DividerLine extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Container(
      height: 1,
      color: FomoShieldTheme.border.withValues(alpha: 0.3),
    );
  }
}

/// Analytics section: trade stats, diversification, frequency.
class _AnalyticsSection extends StatelessWidget {
  final PsychologyMeterData data;

  const _AnalyticsSection({required this.data});

  @override
  Widget build(BuildContext context) {
    final nf = NumberFormat('#,##0.00', 'en_US');

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // ── Step 1: Trade timing ──────────────────────────────
        _analyticsHeader('📊 Trade Timing'),
        const SizedBox(height: 6),
        _analyticsRow(
          'Trades',
          '${data.totalTrades} (${data.buyTrades} buys · ${data.sellTrades} sells)',
        ),
        if (data.boughtAtPeakCount > 0 || data.soldAtBottomCount > 0)
          _analyticsRow(
            '⚠️ Timing',
            '${data.boughtAtPeakCount} buy peaks · ${data.soldAtBottomCount} sell bottoms',
            valueColor: FomoShieldTheme.negative,
          ),
        _analyticsRow(
          'Realized P&L',
          '\$${nf.format(data.realizedPnl)}',
          valueColor: data.realizedPnl >= 0
              ? FomoShieldTheme.positive
              : FomoShieldTheme.negative,
        ),
        const SizedBox(height: 10),

        // ── Step 2 & 3: Diversification & concentration ──────
        _analyticsHeader('🏭 Diversification'),
        const SizedBox(height: 6),
        _analyticsRow('Sectors held', '${data.sectorCount}'),
        _analyticsRow(
          'Max allocation',
          '${data.maxConcentrationPct.round()}%'
              '${data.hasDiversificationWarning ? ' ⚠️' : ' ✅'}',
          valueColor: data.hasDiversificationWarning
              ? FomoShieldTheme.negative
              : FomoShieldTheme.positive,
        ),
        const SizedBox(height: 10),

        // ── Step 4: Trade frequency ──────────────────────────
        _analyticsHeader('🔄 Activity'),
        const SizedBox(height: 6),
        _analyticsRow(
          'Trade frequency',
          '${data.tradesPerDay.round()} trades/day',
        ),
        const SizedBox(height: 6),
      ],
    );
  }

  Widget _analyticsHeader(String text) {
    return Text(
      text,
      style: GoogleFonts.inter(
        fontSize: 11,
        fontWeight: FontWeight.w700,
        color: ThemeV2.primary,
        letterSpacing: 0.4,
      ),
    );
  }

  Widget _analyticsRow(String label, String value, {Color? valueColor}) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 2),
      child: Row(
        children: [
          Expanded(
            flex: 2,
            child: Text(
              label,
              style: GoogleFonts.inter(
                fontSize: 12,
                color: FomoShieldTheme.textLight,
              ),
            ),
          ),
          Expanded(
            flex: 2,
            child: Text(
              value,
              textAlign: TextAlign.right,
              style: GoogleFonts.inter(
                fontSize: 12,
                fontWeight: FontWeight.w700,
                color: valueColor ?? FomoShieldTheme.text,
              ),
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
    return Row(
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        _FsScoreRing(score: data.fsScore),
        const SizedBox(width: 24),
        Expanded(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              _SubIndexRow(
                label: 'Panic Resistance',
                value: data.panicResistance,
                color: FomoShieldTheme.panic,
              ),
              const SizedBox(height: 10),
              _SubIndexRow(
                label: 'Discipline',
                value: data.discipline,
                color: FomoShieldTheme.discipline,
              ),
              const SizedBox(height: 10),
              _SubIndexRow(
                label: 'Patience',
                value: data.patience,
                color: FomoShieldTheme.patience,
              ),
              const SizedBox(height: 10),
              _SubIndexRow(
                label: 'Strategy',
                value: data.strategyAdherence,
                color: FomoShieldTheme.strategy,
              ),
            ],
          ),
        ),
      ],
    );
  }
}

/// Circular FS Score ring (CustomPainter).
class _FsScoreRing extends StatelessWidget {
  final double score; // 0-100

  const _FsScoreRing({required this.score});

  Color get _color {
    if (score >= 70) return FomoShieldTheme.positive;
    if (score >= 40) return FomoShieldTheme.sideways;
    return FomoShieldTheme.negative;
  }

  String get _label {
    if (score >= 80) return 'Excellent';
    if (score >= 60) return 'Good';
    if (score >= 40) return 'Fair';
    if (score >= 20) return 'Poor';
    return 'Critical';
  }

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: 100,
      height: 100,
      child: Stack(
        alignment: Alignment.center,
        children: [
          CustomPaint(
            size: const Size(100, 100),
            painter: _RingPainter(
              score: score,
              color: _color,
              trackColor: FomoShieldTheme.border.withValues(alpha: 0.3),
            ),
          ),
          Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                '${score.round()}',
                style: interNums(
                  fontSize: 24,
                  fontWeight: FontWeight.w900,
                  color: FomoShieldTheme.text,
                  letterSpacing: -1,
                ),
              ),
              Text(
                _label,
                style: GoogleFonts.inter(
                  fontSize: 9,
                  fontWeight: FontWeight.w600,
                  color: _color,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

/// Custom painter for the FS Score ring.
class _RingPainter extends CustomPainter {
  final double score;
  final Color color;
  final Color trackColor;

  _RingPainter({
    required this.score,
    required this.color,
    required this.trackColor,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final center = Offset(size.width / 2, size.height / 2);
    final radius = size.width / 2 - 6;
    const strokeWidth = 8.0;

    // Track
    final trackPaint = Paint()
      ..color = trackColor
      ..style = PaintingStyle.stroke
      ..strokeWidth = strokeWidth
      ..strokeCap = StrokeCap.round;
    canvas.drawCircle(center, radius, trackPaint);

    // Fill
    final sweepAngle = (score / 100.0) * 2 * math.pi;
    if (sweepAngle > 0) {
      final fillPaint = Paint()
        ..color = color
        ..style = PaintingStyle.stroke
        ..strokeWidth = strokeWidth
        ..strokeCap = StrokeCap.round;
      canvas.drawArc(
        Rect.fromCircle(center: center, radius: radius),
        -math.pi / 2, // start from top
        sweepAngle,
        false,
        fillPaint,
      );
    }
  }

  @override
  bool shouldRepaint(_RingPainter old) =>
      old.score != score || old.color != color;
}

/// Single sub-index row: label + progress bar + value.
class _SubIndexRow extends StatelessWidget {
  final String label;
  final double value; // 0.0-1.0
  final Color color;

  const _SubIndexRow({
    required this.label,
    required this.value,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        // Label — flex 4 gives "Panic Resistance" guaranteed room
        Flexible(
          flex: 4,
          child: Text(
            label,
            maxLines: 1,
            overflow: TextOverflow.visible,
            style: GoogleFonts.inter(
              fontSize: 11,
              fontWeight: FontWeight.w600,
              color: FomoShieldTheme.textLight,
            ),
          ),
        ),
        const SizedBox(width: 6),
        // Progress bar — slightly reduced flex
        Flexible(
          flex: 3,
          child: ClipRRect(
            borderRadius: BorderRadius.circular(999),
            child: LinearProgressIndicator(
              value: value,
              backgroundColor: FomoShieldTheme.border.withValues(alpha: 0.4),
              valueColor: AlwaysStoppedAnimation(color),
              minHeight: 12,
            ),
          ),
        ),
        const SizedBox(width: 6),
        // Value — small numeric label
        Flexible(
          flex: 1,
          child: Text(
            '${(value * 100).round()}',
            textAlign: TextAlign.right,
            maxLines: 1,
            style: interNums(
              fontSize: 13,
              fontWeight: FontWeight.w800,
              color: FomoShieldTheme.text,
            ),
          ),
        ),
      ],
    );
  }
}

// ═══════════════════════════════════════════════════════════════════════════
// Live Audit Bottom Sheet — opens on Psychology Meter tap
// ═══════════════════════════════════════════════════════════════════════════

/// Opens the live audit Bottom Sheet with a jargon-free analysis
/// of the user's current actions, split into three sections.
void _showAuditSheet(BuildContext context, PsychologyMeterData data) {
  final rights = <String>[];
  final mistakes = <String>[];
  final risks = <String>[];

  // ── 🟢 What you are doing right ──────────────────────────────────
  if (data.strategyAdherence > 0.6) {
    rights.add(
      'Great job on diversifying! You bought assets from different sectors, '
      'which protects your cash.',
    );
  }
  if (data.patience > 0.6) {
    rights.add(
      'Excellent patience. You aren\'t panic-selling during drops '
      'and you\'re letting profits grow smoothly.',
    );
  }
  if (data.discipline > 0.6) {
    rights.add(
      'Strong discipline. You\'re sticking to your plan '
      'and not chasing every market move.',
    );
  }
  if (data.panicResistance > 0.6) {
    rights.add(
      'Solid nerve. You\'re holding steady during market turbulence '
      'instead of panic-selling.',
    );
  }
  if (data.sectorCount >= 3) {
    rights.add(
      'You\'re spread across ${data.sectorCount} sectors. '
      'Good diversification reduces your risk if one industry struggles.',
    );
  }
  if (data.cashBufferPct >= 15) {
    rights.add(
      'You\'re keeping ${data.cashBufferPct.round()}% in cash. '
      'This gives you flexibility to buy when opportunities appear.',
    );
  }

  // ── 🔴 Where you are messing up ─────────────────────────────────
  if (data.discipline < 0.4 && data.discipline > 0.0) {
    mistakes.add(
      'You are buying during market Hype/Euphoria! '
      'You are chasing green candles due to FOMO.',
    );
  }
  if (data.panicResistance < 0.4 && data.panicResistance > 0.0) {
    mistakes.add(
      'You are selling assets at a loss as soon as '
      'the market bleeds a little bit.',
    );
  }
  if (data.strategyAdherence < 0.4 &&
      data.strategyAdherence > 0.0 &&
      data.sectorCount < 3) {
    mistakes.add(
      'Your portfolio lacks diversification. '
      'Putting too much into one asset increases your risk dramatically.',
    );
  }
  if (data.patience < 0.4 && data.patience > 0.0) {
    mistakes.add(
      'You\'re trading too frequently. Every trade costs you — '
      'slow down and think twice before acting.',
    );
  }
  if (data.boughtAtPeakCount > 0) {
    final times = data.boughtAtPeakCount == 1
        ? 'once'
        : '${data.boughtAtPeakCount} times';
    mistakes.add(
      'You bought at a peak $times. '
      'This is classic FOMO — buying when everyone else is excited.',
    );
  }
  if (data.soldAtBottomCount > 0) {
    final times = data.soldAtBottomCount == 1
        ? 'once'
        : '${data.soldAtBottomCount} times';
    mistakes.add(
      'You sold at the bottom $times. '
      'Panic selling locks in losses that might have recovered.',
    );
  }

  // ── ⚠️ Current Risks ────────────────────────────────────────────
  if (data.maxConcentrationPct > 40) {
    risks.add(
      'High Concentration Risk! '
      'If your top asset drops, your entire portfolio goes down with it.',
    );
  }
  if (data.cashBufferPct < 5 && data.totalTrades > 0) {
    risks.add(
      'No Safety Net! You went 100% all-in. '
      'If a Black Swan hits right now, you won\'t have cash to buy the dip.',
    );
  }
  if (data.sectorCount == 1) {
    risks.add(
      'You\'re only in 1 sector. '
      'A single industry downturn could wipe out your gains.',
    );
  }
  if (data.tradesPerDay > 3) {
    risks.add(
      'Overtrading alert! You\'re making '
      '${data.tradesPerDay.toStringAsFixed(1)} trades/day. '
      'High frequency = high stress + more mistakes.',
    );
  }
  if (data.realizedPnl < -500) {
    risks.add(
      'Your realized losses are adding up. '
      'Consider smaller position sizes until you find your rhythm.',
    );
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
                title: 'Your stress test has just begun!',
              ),
              const SizedBox(height: 16),
              _buildTip(
                'Make your first moves wisely: diversify across '
                '3+ sectors and keep some cash in reserve to build '
                'your Strategy score.',
              ),
            ] else ...[
              _buildHeader(
                icon: Icons.psychology_outlined,
                iconColor: _fsScoreColor(fsScore),
                title: 'Live Action Audit',
                subtitle: 'FS Score: ${fsScore.round()}/100',
              ),
              const SizedBox(height: 20),

              // ── 🟢 What you are doing right ────────────────────
              if (rights.isNotEmpty) ...[
                _sectionTitle(
                  '🟢 What you are doing right',
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
                  '🔴 Where you are slipping up',
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
                _sectionTitle('⚠️ Active Risks', FomoShieldTheme.sideways),
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
                _buildTip(
                  'You\'re doing fine so far. Keep observing the market '
                  'and make thoughtful decisions — don\'t rush.',
                ),
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

