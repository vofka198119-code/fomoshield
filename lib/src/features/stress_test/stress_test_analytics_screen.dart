// ---------------------------------------------------------------------------
// Stress Test Analytics Screen — FS Score + Radar + Key Metrics
// ---------------------------------------------------------------------------

import 'dart:math' as math;
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:intl/intl.dart' hide TextDirection;
import '../../core/theme/theme_v2.dart';
import '../../core/theme/typography_helpers.dart';
import '../../shared/services/scoring_engine.dart';
import 'stress_test_engine.dart';
import 'stress_test_models.dart';

class StressTestAnalyticsScreen extends ConsumerWidget {
  final String sessionId;

  const StressTestAnalyticsScreen({super.key, required this.sessionId});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    // Reactive watch — rebuilds every 20 s when _simulateCurrentPrices
    // pushes updated state via state = [...], triggering Riverpod notify.
    final sessions = ref.watch(stressTestProvider);
    final session = sessions.cast<StressTestSession?>().firstWhere(
      (s) => s?.id == sessionId,
      orElse: () => null,
    );
    if (session == null) {
      return Scaffold(
        backgroundColor: Colors.transparent,
        appBar: AppBar(
          backgroundColor: Colors.transparent,
          title: Text(
            'Analytics',
            style: GoogleFonts.inter(
              fontSize: 18,
              fontWeight: FontWeight.w700,
              color: ThemeV2.primary,
            ),
          ),
        ),
        body: const Center(child: Text('Session not found')),
      );
    }

    // Calculate scores for each holding
    final holdingsScores = <Map<String, dynamic>>[];
    for (final h in session.holdings) {
      final currentPrice = session.currentPrices[h.symbol] ?? h.entryPrice;
      final priceChange = ((currentPrice - h.entryPrice) / h.entryPrice) * 100;
      final metrics = {
        'metric': {
          'peTTM': 15.0 + priceChange * 0.1,
          'sectorPeTTM': 18.0,
          'debtEquityTTM': 0.5 + (priceChange < 0 ? 0.3 : 0.0),
          'currentRatioTTM': 1.8,
          'revenueGrowth5Y': 5.0 + priceChange * 0.05,
          'epsGrowth5Y': 4.0 + priceChange * 0.04,
          'netProfitMarginTTM': 8.0 + priceChange * 0.02,
          'roeTTM': 12.0 + priceChange * 0.03,
          'dividendYieldIndicatedAnnual': 0.0,
          'payoutRatioAnnual': 30.0,
        },
      };
      final score = ScoringEngine.calculate(metrics);
      holdingsScores.add({
        'symbol': h.symbol,
        'score': score,
        'priceChange': priceChange,
        'entryPrice': h.entryPrice,
        'currentPrice': currentPrice,
        'shares': h.shares,
      });
    }

    // Portfolio-level aggregated score
    double avgFsScore = 0;
    if (holdingsScores.isNotEmpty) {
      for (final hs in holdingsScores) {
        final s = hs['score'] as Map<String, dynamic>;
        avgFsScore += (s['fs_score'] as num?)?.toDouble() ?? 0;
      }
      avgFsScore = avgFsScore / holdingsScores.length;
    }

    final totalValue = session.totalValue;
    final totalPnl = totalValue - session.startingCash;
    final pnlPercent = session.startingCash > 0
        ? (totalPnl / session.startingCash) * 100
        : 0.0;

    return Scaffold(
      backgroundColor: Colors.transparent,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        title: Text(
          'Analytics',
          style: GoogleFonts.inter(
            fontSize: 18,
            fontWeight: FontWeight.w700,
            color: ThemeV2.primary,
          ),
        ),
        leading: IconButton(
          icon: const Icon(
            Icons.arrow_back_rounded,
            color: ThemeV2.textPrimary,
          ),
          onPressed: () => context.pop(),
        ),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // ── FS Score Gauge ──────────────────────────────────
            _buildCard(
              child: Column(
                children: [
                  const SizedBox(height: 8),
                  _buildFsScoreGauge(avgFsScore.round()),
                  const SizedBox(height: 16),
                  Text(
                    'Portfolio Financial Strength Score',
                    style: GoogleFonts.inter(
                      fontSize: 13,
                      fontWeight: FontWeight.w600,
                      color: ThemeV2.textSecondary,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    _scoreLabel(avgFsScore.round()),
                    style: GoogleFonts.inter(
                      fontSize: 12,
                      color: _scoreColor(avgFsScore.round()),
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                  const SizedBox(height: 8),
                ],
              ),
            ),
            const SizedBox(height: 12),

            // ── Key Metrics ────────────────────────────────────
            Row(
              children: [
                Expanded(
                  child: _buildMetricCard(
                    label: 'Total Value',
                    value: '\$${_fmt(totalValue)}',
                    icon: Icons.account_balance_wallet_rounded,
                    color: ThemeV2.primary,
                  ),
                ),
                const SizedBox(width: 10),
                Expanded(
                  child: _buildMetricCard(
                    label: 'P&L',
                    value:
                        '${pnlPercent >= 0 ? '+' : ''}${pnlPercent.toStringAsFixed(1)}%',
                    icon: pnlPercent >= 0
                        ? Icons.trending_up_rounded
                        : Icons.trending_down_rounded,
                    color: pnlPercent >= 0
                        ? ThemeV2.success
                        : ThemeV2.loss,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 10),
            Row(
              children: [
                Expanded(
                  child: _buildMetricCard(
                    label: 'Holdings',
                    value: '${session.holdings.length}',
                    icon: Icons.percent_rounded,
                    color: ThemeV2.warning,
                  ),
                ),
                const SizedBox(width: 10),
                Expanded(
                  child: _buildMetricCard(
                    label: 'Cash Remaining',
                    value: '\$${_fmt(session.cash)}',
                    icon: Icons.monetization_on_rounded,
                    color: ThemeV2.textSecondary,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),

            // ── Radar Chart ────────────────────────────────────
            if (holdingsScores.isNotEmpty) ...[
              _buildCard(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Padding(
                      padding: const EdgeInsets.only(left: 4, top: 4),
                      child: Text(
                        'SCORE BREAKDOWN',
                        style: GoogleFonts.inter(
                          fontSize: 11,
                          fontWeight: FontWeight.w700,
                          color: ThemeV2.textSecondary,
                          letterSpacing: 1.2,
                        ),
                      ),
                    ),
                    const SizedBox(height: 12),
                    SizedBox(
                      height: 200,
                      child: _AnalyticsRadarChart(
                        holdingsScores: holdingsScores,
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 16),
            ],

            // ── Holding Scores ─────────────────────────────────
            Text(
              'HOLDING SCORES',
              style: GoogleFonts.inter(
                fontSize: 11,
                fontWeight: FontWeight.w700,
                color: ThemeV2.textSecondary,
                letterSpacing: 1.2,
              ),
            ),
            const SizedBox(height: 8),
            ...holdingsScores.map((hs) => _buildHoldingScoreTile(hs)),
            if (holdingsScores.isEmpty)
              _buildCard(
                child: Padding(
                  padding: const EdgeInsets.all(24),
                  child: Center(
                    child: Text(
                      'No holdings yet. Buy stocks to see analytics.',
                      style: GoogleFonts.inter(
                        fontSize: 13,
                        color: ThemeV2.textSecondary,
                      ),
                    ),
                  ),
                ),
              ),
            const SizedBox(height: 24),
          ],
        ),
      ),
    );
  }

  Widget _buildCard({required Widget child}) {
    return Container(
      decoration: BoxDecoration(
        color: ThemeV2.surface,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: Colors.black.withValues(alpha: 0.06)),
      ),
      padding: const EdgeInsets.all(16),
      child: child,
    );
  }

  Widget _buildFsScoreGauge(int score) {
    final color = _scoreColor(score);

    return Container(
      width: 140,
      height: 140,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        color: Colors.white,
        border: Border.all(color: color.withValues(alpha: 0.4), width: 3),
        boxShadow: [
          BoxShadow(
            color: color.withValues(alpha: 0.25),
            blurRadius: 30,
            spreadRadius: 5,
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
                fontSize: 44,
                fontWeight: FontWeight.w900,
                color: color,
                letterSpacing: -1,
              ),
            ),
            Text(
              'FS SCORE',
              style: GoogleFonts.inter(
                fontSize: 9,
                fontWeight: FontWeight.w700,
                letterSpacing: 2.5,
                color: ThemeV2.textSecondary,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildMetricCard({
    required String label,
    required String value,
    required IconData icon,
    required Color color,
  }) {
    return Container(
      decoration: BoxDecoration(
        color: ThemeV2.surface,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: Colors.black.withValues(alpha: 0.06)),
      ),
      padding: const EdgeInsets.all(14),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(icon, size: 20, color: color),
          const SizedBox(height: 10),
          Text(
            value,
            style: GoogleFonts.inter(
              fontSize: 16,
              fontWeight: FontWeight.w800,
              color: ThemeV2.textPrimary,
            ),
          ),
          const SizedBox(height: 2),
          Text(
            label,
            style: GoogleFonts.inter(
              fontSize: 10,
              fontWeight: FontWeight.w500,
              color: ThemeV2.textSecondary,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildHoldingScoreTile(Map<String, dynamic> hs) {
    final symbol = hs['symbol'] as String;
    final scoreMap = hs['score'] as Map<String, dynamic>;
    final fsScore = scoreMap['fs_score'] as int? ?? 0;
    final priceChange = hs['priceChange'] as double;
    final entryPrice = hs['entryPrice'] as double;
    final currentPrice = hs['currentPrice'] as double;
    final shares = hs['shares'] as double;
    final color = _scoreColor(fsScore);

    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Container(
        decoration: BoxDecoration(
          color: ThemeV2.surface,
          borderRadius: BorderRadius.circular(14),
          border: Border.all(color: Colors.black.withValues(alpha: 0.06)),
        ),
        padding: const EdgeInsets.all(14),
        child: Row(
          children: [
            Container(
              width: 44,
              height: 44,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: color.withValues(alpha: 0.15),
                border: Border.all(color: color.withValues(alpha: 0.3)),
              ),
              child: Center(
                child: Text(
                  '$fsScore',
                  style: GoogleFonts.inter(
                    fontSize: 16,
                    fontWeight: FontWeight.w800,
                    color: color,
                  ),
                ),
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    symbol,
                    style: GoogleFonts.inter(
                      fontSize: 14,
                      fontWeight: FontWeight.w700,
                      color: ThemeV2.textPrimary,
                    ),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    '${shares.toStringAsFixed(2)} sh. @ \$${entryPrice.toStringAsFixed(2)}',
                    style: GoogleFonts.inter(
                      fontSize: 11,
                      color: ThemeV2.textSecondary,
                    ),
                  ),
                ],
              ),
            ),
            Column(
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                Text(
                  '\$${currentPrice.toStringAsFixed(2)}',
                  style: GoogleFonts.inter(
                    fontSize: 14,
                    fontWeight: FontWeight.w700,
                    color: ThemeV2.textPrimary,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  '${priceChange >= 0 ? '+' : ''}${priceChange.toStringAsFixed(1)}%',
                  style: GoogleFonts.inter(
                    fontSize: 11,
                    fontWeight: FontWeight.w600,
                    color: priceChange >= 0
                        ? ThemeV2.success
                        : ThemeV2.loss,
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Color _scoreColor(int score) {
    if (score >= 70) return ThemeV2.success;
    if (score >= 40) return ThemeV2.warning;
    return ThemeV2.loss;
  }

  String _scoreLabel(int score) {
    if (score >= 80) return 'Excellent';
    if (score >= 60) return 'Good';
    if (score >= 40) return 'Fair';
    if (score >= 20) return 'Weak';
    return 'Poor';
  }

  String _fmt(double value) {
    return NumberFormat('#,##0.00', 'en_US').format(value);
  }
}

// ===========================================================================
// Analytics Radar Chart
// ===========================================================================

class _AnalyticsRadarChart extends StatelessWidget {
  final List<Map<String, dynamic>> holdingsScores;

  const _AnalyticsRadarChart({required this.holdingsScores});

  @override
  Widget build(BuildContext context) {
    return CustomPaint(
      size: const Size(double.infinity, double.infinity),
      painter: _AnalyticsRadarPainter(holdingsScores: holdingsScores),
    );
  }
}

class _AnalyticsRadarPainter extends CustomPainter {
  final List<Map<String, dynamic>> holdingsScores;

  _AnalyticsRadarPainter({required this.holdingsScores});

  @override
  void paint(Canvas canvas, Size size) {
    if (holdingsScores.isEmpty) return;

    final center = Offset(size.width / 2, size.height / 2);
    final radius = math.min(size.width, size.height) / 2 - 16;
    final n = holdingsScores.length;
    if (n == 0) return;

    final gridPaint = Paint()
      ..color = Colors.black.withValues(alpha: 0.06)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 0.8;

    for (int level = 1; level <= 4; level++) {
      final r = radius * level / 4;
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

    for (int i = 0; i < n; i++) {
      final angle = -math.pi / 2 + (2 * math.pi * i / n);
      final x = center.dx + radius * math.cos(angle);
      final y = center.dy + radius * math.sin(angle);
      canvas.drawLine(center, Offset(x, y), gridPaint);
    }

    for (int h = 0; h < n; h++) {
      final scoreMap = holdingsScores[h]['score'] as Map<String, dynamic>;
      final markers = scoreMap['markers'] as Map<String, dynamic>? ?? {};
      final entries = markers.entries.toList();
      if (entries.isEmpty) continue;

      final dataPath = Path();
      final hue = (h * 60) % 360;
      final dataColor = HSLColor.fromAHSL(
        0.15,
        hue.toDouble(),
        0.7,
        0.55,
      ).toColor();
      final strokeColor = HSLColor.fromAHSL(
        0.5,
        hue.toDouble(),
        0.7,
        0.55,
      ).toColor();

      for (int i = 0; i < entries.length; i++) {
        final marker = entries[i].value as Map<String, dynamic>;
        final score = (marker['score'] as num?)?.toDouble() ?? 0;
        final r = radius * (score / 100);
        final angle = -math.pi / 2 + (2 * math.pi * i / entries.length);
        final x = center.dx + r * math.cos(angle);
        final y = center.dy + r * math.sin(angle);
        if (i == 0) {
          dataPath.moveTo(x, y);
        } else {
          dataPath.lineTo(x, y);
        }
      }
      dataPath.close();

      canvas.drawPath(
        dataPath,
        Paint()
          ..color = dataColor
          ..style = PaintingStyle.fill,
      );
      canvas.drawPath(
        dataPath,
        Paint()
          ..color = strokeColor
          ..style = PaintingStyle.stroke
          ..strokeWidth = 1.5,
      );
    }

    if (holdingsScores.isNotEmpty) {
      final firstScore = holdingsScores[0]['score'] as Map<String, dynamic>;
      final firstMarkers = firstScore['markers'] as Map<String, dynamic>? ?? {};
      final labelEntries = firstMarkers.entries.toList();

      for (int i = 0; i < labelEntries.length; i++) {
        final angle = -math.pi / 2 + (2 * math.pi * i / labelEntries.length);
        final labelR = radius + 14;
        final lx = center.dx + labelR * math.cos(angle);
        final ly = center.dy + labelR * math.sin(angle);
        final marker = labelEntries[i].value as Map<String, dynamic>;
        final name = marker['name'] as String? ?? '';
        final short = _shortName(name);
        final tp = TextPainter(
          text: TextSpan(
            text: short,
            style: TextStyle(
              color: ThemeV2.textSecondary.withValues(alpha: 0.7),
              fontSize: 9,
              fontWeight: FontWeight.w600,
            ),
          ),
          textDirection: TextDirection.ltr,
        )..layout();
        tp.paint(canvas, Offset(lx - tp.width / 2, ly - tp.height / 2));
      }
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
      case 'Capital Return':
        return 'CAP';
      default:
        return name.length > 3
            ? name.substring(0, 3).toUpperCase()
            : name.toUpperCase();
    }
  }

  @override
  bool shouldRepaint(_AnalyticsRadarPainter oldDelegate) => true;
}

