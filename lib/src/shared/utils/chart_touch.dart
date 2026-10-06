// ---------------------------------------------------------------------------
// How close a finger has to land to a data point for fl_chart to count it as
// touched.
//
// fl_chart's own default is 10 PIXELS, measured horizontally. That is fine for
// a chart built from hundreds of candles — every x position is within 10px of
// something — and silently broken for a chart with only a handful of points:
// on the Portfolio value chart's first days there were exactly two points, one
// at each edge of the plot, so every touch in between was a "miss" and the
// hold-to-read tooltip could never appear at all (found on-device 2026-10-06).
//
// So the threshold scales with the gap between neighbouring points instead:
// any touch is then within one gap of some point, and the nearest one wins.
// Never narrower than fl_chart's 10px, so dense charts keep exactly the
// behaviour they already had.
// ---------------------------------------------------------------------------

/// Touch threshold for a chart [plotWidth] pixels wide holding [pointCount]
/// evenly-spaced points.
double chartTouchThreshold(double plotWidth, int pointCount) {
  if (pointCount < 2 || plotWidth <= 0) return 10;
  final gap = plotWidth / (pointCount - 1);
  return gap > 10 ? gap : 10;
}
