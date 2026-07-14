import 'dart:math' as math;
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../../core/theme/theme_v2.dart';
import '../../../core/theme/typography_helpers.dart';

// ---------------------------------------------------------------------------
// FS Score Widget — gauge + radar chart + 6 marker details
// ---------------------------------------------------------------------------

class FsScoreWidget extends StatelessWidget {
  final Map<String, dynamic> score;

  const FsScoreWidget({super.key, required this.score});

  @override
  Widget build(BuildContext context) {
    final fsScore = score['fs_score'] as int? ?? 0;
    final markers = score['markers'] as Map<String, dynamic>? ?? {};
    final penalty = score['dividend_trap_penalty'] as int? ?? 0;

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: Container(
        padding: const EdgeInsets.all(20),
        decoration: BoxDecoration(
          color: ThemeV2.surface,
          borderRadius: BorderRadius.circular(20),
          border: Border.all(color: Colors.black.withValues(alpha: 0.04)),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // ── Title ──
            Row(
              children: [
                Icon(Icons.shield_rounded, size: 18, color: _gaugeColor(fsScore)),
                const SizedBox(width: 8),
                Text(
                  'FS Score',
                  style: GoogleFonts.inter(
                    fontSize: 16,
                    fontWeight: FontWeight.w700,
                    color: ThemeV2.textPrimary,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 20),

            // ── Gauge + Radar row ──
            Row(
              children: [
                // Gauge
                _buildFsScoreGauge(fsScore),
                const SizedBox(width: 24),
                // Radar chart
                Expanded(
                  child: SizedBox(
                    height: 140,
                    child: _RadarChart(markers: markers),
                  ),
                ),
              ],
            ),

            if (penalty > 0) ...[
              const SizedBox(height: 12),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                decoration: BoxDecoration(
                  color: ThemeV2.warning.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(color: ThemeV2.warning.withValues(alpha: 0.2)),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(Icons.warning_amber_rounded, size: 14, color: ThemeV2.warning),
                    const SizedBox(width: 6),
                    Text(
                      'Dividend trap penalty: -$penalty pts',
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
            const SizedBox(height: 20),

            // ── 6 Marker cards ──
            ...markers.entries.map((entry) {
              final marker = entry.value as Map<String, dynamic>;
              return _MarkerCard(marker: marker);
            }),
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

  Widget _buildFsScoreGauge(int score) {
    final color = _gaugeColor(score);

    return Container(
      width: 120,
      height: 120,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        color: ThemeV2.surface,
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
              'FS SCORE',
              style: GoogleFonts.inter(
                fontSize: 9,
                fontWeight: FontWeight.w700,
                letterSpacing: 2,
                color: ThemeV2.textSecondary,
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

  const _RadarChart({required this.markers});

  @override
  Widget build(BuildContext context) {
    return CustomPaint(
      size: const Size(double.infinity, double.infinity),
      painter: _RadarChartPainter(markers: markers),
    );
  }
}

class _RadarChartPainter extends CustomPainter {
  final Map<String, dynamic> markers;

  _RadarChartPainter({required this.markers});

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
      ..color = Colors.black.withValues(alpha: 0.06)
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
      ..color = ThemeV2.primary.withValues(alpha: 0.15)
      ..style = PaintingStyle.fill;
    canvas.drawPath(dataPath, dataPaint);

    final dataStroke = Paint()
      ..color = ThemeV2.primary.withValues(alpha: 0.6)
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
      canvas.drawCircle(
        Offset(x, y),
        3,
        Paint()..color = ThemeV2.primary,
      );

      // Label at edge
      final labelR = radius + 12;
      final lx = center.dx + labelR * math.cos(angle);
      final ly = center.dy + labelR * math.sin(angle);
      _drawLabel(canvas, _shortName(marker['name'] as String? ?? ''), Offset(lx, ly), angle);
    }
  }

  String _shortName(String name) {
    switch (name) {
      case 'Valuation': return 'VAL';
      case 'Financial Health': return 'FIN';
      case 'Growth Potential': return 'GRW';
      case 'Efficiency': return 'EFF';
      case 'Historical Trend': return 'TRD';
      case 'Capital Return': return 'CAP';
      default: return name.substring(0, 3).toUpperCase();
    }
  }

  void _drawLabel(Canvas canvas, String text, Offset pos, double angle) {
    final tp = TextPainter(
      text: TextSpan(
        text: text,
        style: TextStyle(
          color: ThemeV2.textSecondary.withValues(alpha: 0.8),
          fontSize: 9,
          fontWeight: FontWeight.w600,
        ),
      ),
      textDirection: TextDirection.ltr,
    )..layout();

    // Center the label around the position
    final offset = Offset(
      pos.dx - tp.width / 2,
      pos.dy - tp.height / 2,
    );
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
    final name = marker['name'] as String? ?? '';
    final score = marker['score'] as int? ?? 0;
    final description = marker['description'] as String? ?? '';
    final details = marker['details'] as String? ?? '';
    final colorStr = marker['color'] as String? ?? '';

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
        border: Border.all(color: Colors.black.withValues(alpha: 0.04)),
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
                Text(
                  name,
                  style: GoogleFonts.inter(
                    fontSize: 13,
                    fontWeight: FontWeight.w700,
                    color: ThemeV2.textPrimary,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  description,
                  style: GoogleFonts.inter(
                    fontSize: 11,
                    color: ThemeV2.textSecondary,
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
                details,
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

