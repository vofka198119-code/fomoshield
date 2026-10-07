import 'dart:async';

import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

import '../../core/theme/app_palette.dart';
import '../../core/theme/fomo_shield_theme.dart';
import '../../core/theme/theme_v2.dart';
import '../../features/market_clock/market_clock_dial.dart'
    show darkCardDecoration;
import '../../l10n/gen/app_localizations.dart';
import '../utils/chart_touch.dart';
import '../utils/currency_format.dart';
import 'chart_line_glow_painter.dart';

// ---------------------------------------------------------------------------
// The plot area for a chart of ONE DAILY SNAPSHOT PER POINT — portfolio value,
// fund NAV, anything else we record once a day.
//
// Company Detail's PriceChart is the app's reference chart, but it is welded to
// Finnhub candles (multi-resolution, its own loading/error states, a hover
// provider feeding the price header). Everything below the data layer is the
// same though, and until this file existed each daily-snapshot chart re-did a
// thinner copy of it and quietly lost the parts that make a chart readable:
// the scale labels, the end dot, the touch tooltip. This is that shared half,
// so the next one cannot drift again.
//
// Deliberately matches PriceChart value for value: 220px plot, the glow fill,
// a 130/3 right gutter holding the min/max labels, straight segments between
// points, and a hold before the tooltip appears.
// ---------------------------------------------------------------------------

class DailySnapshotPoint {
  final DateTime at;
  final double value;

  const DailySnapshotPoint({required this.at, required this.value});
}

/// Plot height, and the gutter reserved on the right for the min/max labels —
/// both copied from PriceChart so the three charts line up pixel for pixel.
const double _plotHeight = 220;
const double _labelGutter = 130 / 3;

/// Periods offered for daily data. No "1D"/"6M"/"5Y": one day is a single
/// point (nothing to draw), and 6M/5Y would sit dead next to 3M/1Y until
/// there are years of history. A span only ever appears once it actually
/// hides something — see [_visibleSpans].
enum _Span { week1, month1, month3, year1, all }

Duration? _spanWindow(_Span span) => switch (span) {
  _Span.week1 => const Duration(days: 7),
  _Span.month1 => const Duration(days: 30),
  _Span.month3 => const Duration(days: 90),
  _Span.year1 => const Duration(days: 365),
  _Span.all => null,
};

String _spanLabel(AppLocalizations l10n, _Span span) => switch (span) {
  _Span.week1 => l10n.chartPeriod1W,
  _Span.month1 => l10n.chartPeriod1M,
  _Span.month3 => l10n.chartPeriod3M,
  _Span.year1 => l10n.chartPeriod1Y,
  _Span.all => l10n.chartPeriodAll,
};

class DailySnapshotChart extends StatefulWidget {
  final List<DailySnapshotPoint> points;
  final AppPalette palette;

  /// How a value is written in the min/max labels and the touch tooltip.
  /// Defaults to the app-wide USD standard.
  final String Function(double) formatValue;

  /// Fires while a point is held, with that point and the one before it in
  /// the series (null for the first point), and again with both null when
  /// the finger lifts. Lets a card's own header follow the scrub — the same
  /// decoupling PriceChart and PriceHeader use via chartHoverPriceProvider,
  /// so the chart never needs to know who is listening. Optional: the
  /// Portfolio card has no header to move and passes nothing.
  final void Function(DailySnapshotPoint? point, DailySnapshotPoint? previous)?
  onHoverChanged;

  const DailySnapshotChart({
    super.key,
    required this.points,
    required this.palette,
    this.formatValue = formatUsd,
    this.onHoverChanged,
  });

  @override
  State<DailySnapshotChart> createState() => _DailySnapshotChartState();
}

class _DailySnapshotChartState extends State<DailySnapshotChart> {
  _Span _selected = _Span.all;

  // Touch state — the tooltip is pinned to the top of the plot and moves only
  // horizontally, and only after a hold. Both rules come from PriceChart: a
  // tooltip that rides the line's peaks is hard to read, and an instant one
  // makes a scroll-swipe across the card feel like the chart grabbed it.
  static const _revealDelay = Duration(milliseconds: 800);
  Timer? _holdTimer;
  bool _revealed = false;
  double? _touchDx;
  int? _touchedIndex;
  double? _pendingDx;
  int? _pendingIndex;

  @override
  void dispose() {
    _holdTimer?.cancel();
    super.dispose();
  }

  /// A span is offered only when it has at least two points AND leaves
  /// something out — otherwise every tab would draw the identical line, which
  /// is exactly what the first weeks of a freshly-started history look like.
  /// If nothing qualifies, the row disappears entirely rather than showing a
  /// lone "All".
  List<_Span> _visibleSpans() {
    if (widget.points.length < 2) return const [];
    final narrower = <_Span>[];
    for (final span in const [
      _Span.week1,
      _Span.month1,
      _Span.month3,
      _Span.year1,
    ]) {
      final count = _pointsIn(span).length;
      if (count >= 2 && count < widget.points.length) narrower.add(span);
    }
    return narrower.isEmpty ? const [] : [...narrower, _Span.all];
  }

  List<DailySnapshotPoint> _pointsIn(_Span span) {
    final window = _spanWindow(span);
    if (window == null) return widget.points;
    final cutoff = DateTime.now().subtract(window);
    return [
      for (final p in widget.points)
        if (p.at.isAfter(cutoff)) p,
    ];
  }

  void _clearTouch({bool rebuild = true}) {
    _holdTimer?.cancel();
    _holdTimer = null;
    _revealed = false;
    if (_touchDx == null && _touchedIndex == null) return;
    widget.onHoverChanged?.call(null, null);
    if (rebuild) {
      setState(() {
        _touchDx = null;
        _touchedIndex = null;
      });
    } else {
      _touchDx = null;
      _touchedIndex = null;
    }
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final spans = _visibleSpans();
    final span = spans.contains(_selected) ? _selected : _Span.all;
    final points = _pointsIn(span);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Bled almost to the card's own edges (1px left, 2px right), same as
        // PriceChart — the plot is the widest thing on the card.
        Padding(
          padding: const EdgeInsets.only(left: 1, right: 2),
          child: SizedBox(height: _plotHeight, child: _plot(points)),
        ),
        if (spans.length > 1) ...[
          const SizedBox(height: 12),
          Padding(
            padding: const EdgeInsets.symmetric(
              horizontal: FomoShieldTheme.cardPadding,
            ),
            child: _spanSelector(l10n, spans, span),
          ),
        ],
      ],
    );
  }

  Widget _spanSelector(
    AppLocalizations l10n,
    List<_Span> spans,
    _Span selected,
  ) {
    final palette = widget.palette;
    return Row(
      children: spans.map((span) {
        final isSelected = span == selected;
        return Expanded(
          child: GestureDetector(
            onTap: () {
              if (isSelected) return;
              _clearTouch(rebuild: false);
              setState(() => _selected = span);
            },
            child: Container(
              margin: const EdgeInsets.symmetric(horizontal: 2),
              padding: const EdgeInsets.symmetric(vertical: 6),
              decoration: !isSelected
                  ? null
                  : palette.windowGradient != null
                  ? BoxDecoration(
                      gradient: palette.windowGradient,
                      borderRadius: BorderRadius.circular(6),
                    )
                  : darkCardDecoration(borderRadius: BorderRadius.circular(6)),
              child: Text(
                _spanLabel(l10n, span),
                textAlign: TextAlign.center,
                style: GoogleFonts.inter(
                  fontSize: 12,
                  fontWeight: isSelected ? FontWeight.w700 : FontWeight.w500,
                  color: isSelected
                      ? (palette.onWindow ?? Colors.white)
                      : palette.textBody,
                ),
              ),
            ),
          ),
        );
      }).toList(),
    );
  }

  Widget _plot(List<DailySnapshotPoint> points) {
    final palette = widget.palette;
    if (points.length < 2) {
      return Center(
        child: Text(
          AppLocalizations.of(context)!.companyDetailChartNotEnoughData,
          style: GoogleFonts.inter(fontSize: 13, color: palette.textBody),
        ),
      );
    }

    final values = [for (final p in points) p.value];
    final minY = values.reduce((a, b) => a < b ? a : b);
    final maxY = values.reduce((a, b) => a > b ? a : b);
    final range = maxY - minY;
    // A flat line still needs a band to sit in; the +1 keeps a portfolio
    // sitting at exactly $0 from collapsing to a zero-height range.
    final pad = range > 0 ? range * 0.08 : (maxY.abs() * 0.08 + 1);
    final chartMinY = minY - pad;
    final chartMaxY = maxY + pad;

    final isUp = values.last >= values.first;
    final lineColor = isUp ? ThemeV2.success : ThemeV2.loss;
    final lineGradient = palette.chartLineGradient;
    final lineGlowColor = lineGradient?.colors.last ?? lineColor;
    final areaGradient = palette.chartAreaGradient;

    final spots = [
      for (int i = 0; i < values.length; i++) FlSpot(i.toDouble(), values[i]),
    ];

    return LayoutBuilder(
      builder: (context, constraints) {
        final plotWidth = (constraints.maxWidth - _labelGutter).clamp(
          1.0,
          double.infinity,
        );
        final pixelPoints = [
          for (final s in spots)
            Offset(
              (s.x / (spots.length - 1)) * plotWidth,
              _plotHeight * (1 - (s.y - chartMinY) / (chartMaxY - chartMinY)),
            ),
        ];

        // The Stack is forced to the FULL width rather than being left to
        // size itself to the plot: a Stack takes the size of its largest
        // non-positioned child, so with only the (narrower) plot inside it,
        // `right: 3` pinned the scale labels to the plot's edge and left the
        // whole label gutter empty to their right — about 50 logical pixels
        // of nothing, clearly visible on a fund's balance card (2026-10-07).
        // PriceChart avoids this by padding its chart instead of shrinking
        // it; same result, reached the other way round.
        return SizedBox(
          width: constraints.maxWidth,
          height: _plotHeight,
          child: Stack(
            children: [
              SizedBox(
                width: plotWidth,
                height: _plotHeight,
                child: Stack(
                  children: [
                    CustomPaint(
                      size: Size(plotWidth, _plotHeight),
                      painter: ChartLineGlowPainter(
                        pixelPoints: pixelPoints,
                        color: lineGlowColor,
                      ),
                    ),
                    LineChart(
                      LineChartData(
                        minY: chartMinY,
                        maxY: chartMaxY,
                        gridData: const FlGridData(show: false),
                        titlesData: const FlTitlesData(show: false),
                        borderData: FlBorderData(show: false),
                        lineTouchData: _touchData(
                          points,
                          chartTouchThreshold(plotWidth, spots.length),
                        ),
                        lineBarsData: [
                          LineChartBarData(
                            spots: spots,
                            // Straight segments: each point is a real recorded
                            // day, and a spline would invent values between them
                            // that were never measured.
                            isCurved: false,
                            color: lineGradient == null ? lineColor : null,
                            gradient: lineGradient,
                            barWidth: 2.5,
                            isStrokeCapRound: true,
                            // A dot on the last point only — anchors the eye to
                            // where the line currently ends.
                            dotData: FlDotData(
                              show: true,
                              checkToShowDot: (spot, barData) =>
                                  spot == barData.spots.last,
                              getDotPainter: (spot, percent, barData, index) =>
                                  FlDotCirclePainter(
                                    radius: 3,
                                    color: lineGlowColor,
                                    strokeWidth: 0,
                                  ),
                            ),
                            belowBarData: BarAreaData(
                              show: areaGradient != null,
                              gradient: areaGradient,
                            ),
                          ),
                        ],
                      ),
                      duration: Duration.zero,
                    ),
                  ],
                ),
              ),
              Positioned(top: 0, right: 3, child: _scaleLabel(maxY)),
              Positioned(bottom: 0, right: 3, child: _scaleLabel(minY)),
              if (_touchDx != null &&
                  _touchedIndex != null &&
                  _touchedIndex! < points.length)
                _tooltip(points[_touchedIndex!], constraints.maxWidth),
            ],
          ),
        );
      },
    );
  }

  LineTouchData _touchData(
    List<DailySnapshotPoint> points,
    double touchThreshold,
  ) => LineTouchData(
    // Scaled to the gap between points — fl_chart's 10px default makes a
    // two-point chart untouchable. See chartTouchThreshold.
    touchSpotThreshold: touchThreshold,
    // fl_chart's own bubble is suppressed entirely in favour of the fixed
    // tooltip drawn above — fighting its positioning was the original reason
    // PriceChart rolled its own.
    touchTooltipData: LineTouchTooltipData(
      getTooltipItems: (touched) => touched.map((_) => null).toList(),
    ),
    getTouchedSpotIndicator: (barData, spotIndexes) => spotIndexes
        .map(
          (_) => TouchedSpotIndicatorData(
            _revealed
                ? FlLine(color: widget.palette.textHeader, strokeWidth: 1.3)
                : const FlLine(color: Colors.transparent, strokeWidth: 0),
            const FlDotData(show: false),
          ),
        )
        .toList(),
    touchCallback: (event, response) {
      final touched = response?.lineBarSpots;
      final isDown =
          event.isInterestedForInteractions &&
          touched != null &&
          touched.isNotEmpty;

      if (!isDown) {
        _clearTouch();
        return;
      }

      _pendingDx = event.localPosition?.dx;
      _pendingIndex = touched.first.spotIndex;

      if (_revealed) {
        setState(() {
          _touchDx = _pendingDx;
          _touchedIndex = _pendingIndex;
        });
        _notifyHover(points);
      } else {
        _holdTimer ??= Timer(_revealDelay, () {
          _holdTimer = null;
          if (!mounted) return;
          _revealed = true;
          setState(() {
            _touchDx = _pendingDx;
            _touchedIndex = _pendingIndex;
          });
          _notifyHover(points);
        });
      }
    },
  );

  void _notifyHover(List<DailySnapshotPoint> points) {
    final cb = widget.onHoverChanged;
    if (cb == null) return;
    final i = _touchedIndex;
    if (i == null || i < 0 || i >= points.length) {
      cb(null, null);
      return;
    }
    cb(points[i], i > 0 ? points[i - 1] : null);
  }

  Widget _scaleLabel(double value) => Text(
    widget.formatValue(value),
    style: GoogleFonts.inter(
      fontSize: 11,
      fontWeight: FontWeight.w600,
      color: widget.palette.textBody,
    ),
  );

  Widget _tooltip(DailySnapshotPoint point, double fullWidth) {
    final palette = widget.palette;
    final text =
        '${point.at.day}.${point.at.month}.${point.at.year} · '
        '${widget.formatValue(point.value)}';
    // fl_chart gives no measured size here, so the pill is centred on the
    // touch using an estimate (11px Inter w600 runs ~6.6px per glyph) and
    // clamped to the card so a touch near either edge can't push it off.
    final estimatedWidth = text.length * 6.6 + 16;
    final left = (_touchDx! - estimatedWidth / 2).clamp(
      0.0,
      (fullWidth - estimatedWidth).clamp(0.0, double.infinity),
    );

    return Positioned(
      top: 0,
      left: left,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
        decoration: BoxDecoration(
          color: palette.windowGradient == null ? ThemeV2.primaryBg : null,
          gradient: palette.windowGradient,
          borderRadius: BorderRadius.circular(6),
        ),
        child: Text(
          text,
          style: GoogleFonts.inter(
            fontSize: 11,
            fontWeight: FontWeight.w600,
            color: palette.windowGradient == null
                ? Colors.black
                : (palette.onWindow ?? palette.textHeader),
          ),
        ),
      ),
    );
  }
}
