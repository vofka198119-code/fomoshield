import 'dart:math' as math;
import 'package:flutter/material.dart';
import '../../core/theme/app_palette.dart';

// ---------------------------------------------------------------------------
// Chart Left Axis — shared by every fund chart with a numeric $/% left
// scale (2026-09-13, extracted from FundMonthlyLineChart once
// FundDrawdownChart needed the identical positioning logic). A chart's
// own left axis, pinned OUTSIDE any horizontal scroll view so it stays
// visible while swiping through months -- putting it inside the same
// scroll view as the data (fl_chart's own built-in leftTitles does this
// by default) meant swiping right to see later months scrolled the whole
// scale off-screen along with the data, leaving no reference at all
// (caught in review before it reached the device the first time this was
// built).
//
// Manually positions each tick label at the same pixel row fl_chart's own
// (disabled) left axis would have used, via the identical linear-
// interpolation formula LineChart/BarChart use internally (portion of the
// Y range -> fraction of [chartPlotHeight] from the top). Clamped so the
// topmost/bottommost labels stay fully inside the box instead of bleeding
// into whatever sits above/below the card (confirmed on-device: an
// unclamped "$180K" bled into the divider above it).
// ---------------------------------------------------------------------------

const double chartPlotHeight = 220;
const double chartLeftAxisWidth = 50;

/// Rounds a raw step (e.g. 13,842) to a "nice" 1/2/5 × 10^n value (e.g.
/// 10,000) — fl_chart's own default interval picker doesn't round
/// cleanly, and left un-interval'd it also renders a forced extra label
/// at the raw min/max on top of the regular ticks, duplicating whatever
/// tick already sits nearby (confirmed on-device: "$173K" over "$170K").
double niceAxisInterval(double rawStep) {
  if (rawStep <= 0) return 1;
  final magnitude = math.pow(10, (math.log(rawStep) / math.ln10).floor())
      .toDouble();
  final residual = rawStep / magnitude;
  final niceResidual = residual > 5
      ? 10
      : residual > 2
      ? 5
      : residual > 1
      ? 2
      : 1;
  return niceResidual * magnitude;
}

class ChartLeftAxis extends StatelessWidget {
  final double chartMinY;
  final double chartMaxY;
  final double interval;
  final String Function(double value) formatter;
  final AppPalette palette;

  const ChartLeftAxis({
    super.key,
    required this.chartMinY,
    required this.chartMaxY,
    required this.interval,
    required this.formatter,
    required this.palette,
  });

  @override
  Widget build(BuildContext context) {
    final range = chartMaxY - chartMinY;
    final tickCount = range > 0 ? (range / interval).round() : 0;
    final ticks = [
      for (int i = 0; i <= tickCount; i++) chartMinY + i * interval,
    ];

    return SizedBox(
      width: chartLeftAxisWidth,
      height: chartPlotHeight,
      child: Stack(
        children: [
          for (final tick in ticks)
            Positioned(
              // -7 centers the ~14px-tall label line on that pixel row
              // instead of hanging below it.
              top: (range > 0
                      ? chartPlotHeight * (1 - (tick - chartMinY) / range) - 7
                      : chartPlotHeight / 2 - 7)
                  .clamp(0.0, chartPlotHeight - 14),
              right: 4,
              child: Text(
                formatter(tick),
                style: TextStyle(fontSize: 10, color: palette.textBody),
              ),
            ),
        ],
      ),
    );
  }
}
