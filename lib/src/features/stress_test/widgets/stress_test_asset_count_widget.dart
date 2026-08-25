// ---------------------------------------------------------------------------
// Stress Test — Diversification Progress card (was "Portfolio Size"), lives
// on the Portfolio Balance detail screen below Diversification Indicator.
// Same segmented-bar visual as
// Portfolio's TARGET widget (see target_widget.dart's _SegmentedBar), but
// mapped to holdings COUNT instead of goal %, with a non-monotonic color
// curve: too few holdings is risky (red) same as too many (red again) —
// the healthy zone is a band in the middle, not just "more is better".
// ---------------------------------------------------------------------------

import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../../core/theme/fomo_shield_theme.dart';
import '../../../core/theme/typography_helpers.dart';
import '../../../core/theme/app_palette.dart';
import '../../../core/theme/themed_header.dart';
import '../../../core/theme/themed_divider.dart';
import '../../../shared/widgets/card_frame.dart';
import '../../../l10n/gen/app_localizations.dart';
import '../../market_clock/market_clock_dial.dart'
    show dialBrassLight, darkCardDecoration;
import '../stress_test_models.dart';

const Color _red = Color(0xFFFF3B30);
const Color _yellow = Color(0xFFFFD600);
const Color _lightGreen = Color(0xFF9CCC65);
const Color _green = Color(0xFF00C853);

// Count -> color stops. Flat red up to 4, red->yellow through the "too
// concentrated" zone, yellow->light green->green through the healthy
// zone, then green->red again past 20 — over-diversifying is flagged
// same as under-diversifying, not treated as strictly better.
const List<MapEntry<double, Color>> _colorStops = [
  MapEntry(0, _red),
  MapEntry(4, _red),
  MapEntry(10, _yellow),
  MapEntry(15, _lightGreen),
  MapEntry(20, _green),
  MapEntry(30, _red),
];

Color _colorForCount(double value) {
  final clamped = value.clamp(_colorStops.first.key, _colorStops.last.key);
  for (var i = 0; i < _colorStops.length - 1; i++) {
    final a = _colorStops[i];
    final b = _colorStops[i + 1];
    if (clamped <= b.key) {
      final t = (clamped - a.key) / (b.key - a.key);
      return Color.lerp(a.value, b.value, t)!;
    }
  }
  return _colorStops.last.value;
}

class StressTestAssetCountCard extends StatelessWidget {
  final StressTestSession session;
  final AppPalette palette;

  const StressTestAssetCountCard({
    super.key,
    required this.session,
    required this.palette,
  });

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final count = session.holdings.length;
    final color = _colorForCount(count.toDouble());

    return CardFrame(
      showTopBar: false,
      padding: EdgeInsets.zero,
      decoration: darkCardDecoration(borderRadius: BorderRadius.circular(20)),
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
                  themedGoldGradient(
                    Text(
                      l10n.assetCountWidgetTitle,
                      style: FomoShieldTheme.cardTitle(Colors.white).copyWith(
                        shadows: palette.titleShadow != null
                            ? [palette.titleShadow!]
                            : null,
                      ),
                    ),
                    palette,
                  ),
                  GestureDetector(
                    onTap: () =>
                        context.push('/metric-info/diversification-progress'),
                    child: Container(
                      width: 20,
                      height: 20,
                      decoration: BoxDecoration(
                        color: Colors.white.withValues(alpha: 0.12),
                        borderRadius: BorderRadius.circular(12),
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
              ),
            ),
          ),
          palette.dividerGradient != null
              ? themedDivider(palette)
              : Divider(
                  height: 1,
                  indent: 16,
                  endIndent: 16,
                  color: Colors.white.withValues(alpha: 0.12),
                ),
          Padding(
            padding: const EdgeInsets.fromLTRB(22, 18, 22, 20),
            child: Column(
              children: [
                SizedBox(
                  width: 140,
                  height: 140,
                  child: Stack(
                    alignment: Alignment.center,
                    children: [
                      const CustomPaint(
                        size: Size(140, 140),
                        painter: _GlowRingPainter(
                          strokeWidth: 2.5,
                          color: dialBrassLight,
                        ),
                      ),
                      Column(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Text(
                            l10n.assetCountWidgetAssetsLabel,
                            style: GoogleFonts.inter(
                              fontSize: 11,
                              fontWeight: FontWeight.w700,
                              letterSpacing: 1,
                              color: dialBrassLight,
                            ),
                          ),
                          const SizedBox(height: 4),
                          Text(
                            '$count',
                            style: interNums(
                              fontSize: 40,
                              fontWeight: FontWeight.w600,
                              color: color,
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 20),
                _CountSegmentedBar(count: count),
                const SizedBox(height: 6),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    _tickLabel('0'),
                    _tickLabel('10'),
                    _tickLabel('20'),
                    _tickLabel('30+'),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _tickLabel(String label) => Text(
    label,
    style: GoogleFonts.inter(
      fontSize: 11,
      fontWeight: FontWeight.w600,
      color: Colors.white.withValues(alpha: 0.5),
    ),
  );
}

/// Row of small blocks spanning 0-30 holdings, each progressively filled
/// (blocks below the current count are fully lit, the count's own block
/// partially lit, blocks above stay grey) — same fill mechanic as
/// target_widget.dart's `_SegmentedBar`.
class _CountSegmentedBar extends StatelessWidget {
  final int count;

  const _CountSegmentedBar({required this.count});

  static const int _segmentCount = 20;
  static const double _min = 0;
  static const double _max = 30;
  static const double _rangeWidth = (_max - _min) / _segmentCount;
  static const Color _unfilled = Color(0x33FFFFFF);

  static double _rangeStart(int index) => _min + index * _rangeWidth;

  double _fillFraction(int index) {
    final start = _rangeStart(index);
    final value = count.toDouble();
    if (value <= start) return 0.0;
    if (value >= start + _rangeWidth) return 1.0;
    return (value - start) / _rangeWidth;
  }

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 28,
      child: Row(
        children: List.generate(_segmentCount, (i) {
          final fraction = _fillFraction(i);
          final segmentColor = _colorForCount(_rangeStart(i) + _rangeWidth / 2);
          return Expanded(
            child: Container(
              margin: EdgeInsets.only(right: i == _segmentCount - 1 ? 0 : 3),
              clipBehavior: Clip.antiAlias,
              decoration: BoxDecoration(
                color: _unfilled,
                borderRadius: BorderRadius.circular(4),
              ),
              child: fraction > 0
                  ? FractionallySizedBox(
                      widthFactor: fraction,
                      alignment: Alignment.centerLeft,
                      child: Container(color: segmentColor),
                    )
                  : null,
            ),
          );
        }),
      ),
    );
  }
}

/// Thin gold ring with a soft glow hugging just the ring line itself (a
/// blurred stroke circle behind the crisp one) — not a filled-disc glow.
/// Same technique as Market Clock's `_RingPainter`.
class _GlowRingPainter extends CustomPainter {
  final double strokeWidth;
  final Color color;

  const _GlowRingPainter({required this.strokeWidth, required this.color});

  @override
  void paint(Canvas canvas, Size size) {
    final center = Offset(size.width / 2, size.height / 2);
    final radius = (size.shortestSide - strokeWidth) / 2;

    final glowPaint = Paint()
      ..color = color.withValues(alpha: 0.35)
      ..style = PaintingStyle.stroke
      ..strokeWidth = strokeWidth * 2
      ..maskFilter = MaskFilter.blur(BlurStyle.normal, strokeWidth);
    canvas.drawCircle(center, radius, glowPaint);

    final ringPaint = Paint()
      ..color = color
      ..style = PaintingStyle.stroke
      ..strokeWidth = strokeWidth;
    canvas.drawCircle(center, radius, ringPaint);
  }

  @override
  bool shouldRepaint(covariant _GlowRingPainter oldDelegate) => false;
}
