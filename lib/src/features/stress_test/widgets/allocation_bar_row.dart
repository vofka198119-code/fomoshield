// ---------------------------------------------------------------------------
// Shared horizontal bar row for the Stress Test Portfolio Balance detail
// screen's widgets (asset allocation, sector allocation, ...) and the
// Psychology Meter's marker bars — company/sector name (ellipsized) + a
// filled bar for its % share + the number at the end. Themed accent fill
// (turquoise under Midnight Sea, gold elsewhere) normally; switches to a red
// warning gradient when the caller flags a row as over some threshold, or —
// for [dangerZoneGradient] callers — blends into red past the 70% mark of
// the bar's own value, same technique as Market Clock's risk-score bars.
// ---------------------------------------------------------------------------

import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../../core/theme/theme_v2.dart';
import '../../../core/theme/typography_helpers.dart';
import '../../../core/theme/app_palette.dart';
import '../../market_clock/market_clock_dial.dart' show dialBrassLight;

const _warningGradient = LinearGradient(
  colors: [Color(0xFFFF6B4A), Color(0xFFB3261E)],
);
const _warningGlow = Color(0xFFFF3B30);

class AllocationBarRow extends StatelessWidget {
  final String name;
  final double percent;
  final AppPalette palette;
  final bool warning;
  // Value label formatting — defaults match the original allocation-%
  // callers (1 decimal + '%'). Psychology Meter's 0-100 score bars pass
  // decimals: 0, suffix: '' since they're points, not a percentage.
  final int decimals;
  final String suffix;
  // When true, ignores [warning] and instead blends the bar's own fill from
  // this theme's accent (turquoise under Midnight Sea, gold elsewhere) into
  // red past the 70% mark of [percent] itself — see [_dangerZoneGradient]'s
  // doc comment. Used by allocation-style bars where the VALUE itself is
  // the risk signal (one holding/sector eating too much of the portfolio).
  // Psychology bars keep the boolean [warning] instead, since their danger
  // direction is inverted (a LOW score is bad, not a high one).
  final bool dangerZoneGradient;

  const AllocationBarRow({
    super.key,
    required this.name,
    required this.percent,
    required this.palette,
    this.warning = false,
    this.decimals = 1,
    this.suffix = '%',
    this.dangerZoneGradient = false,
  });

  Color get _accentColor => palette.marketClockAccent ?? dialBrassLight;

  /// Same 70%-threshold blend as Market Clock's risk bars (see
  /// market_clock_timing_widget.dart's _barGradient) — the gradient is
  /// defined over the bar's full conceptual 0-100% width, so a value under
  /// 70% never shows any red at all, only a value that actually crosses the
  /// threshold reveals it.
  LinearGradient _dangerZoneGradient() {
    const threshold = 0.70;
    const blend = 0.05;
    final ringColors = palette.marketClockRingGradient?.colors;
    final start = ringColors?.first ?? dialBrassLight;
    final end = ringColors?.last ?? dialBrassLight;
    final fraction = (percent / 100).clamp(0.0, 1.0);
    if (fraction <= threshold || fraction == 0) {
      return LinearGradient(colors: [start, end]);
    }
    final localThreshold = (threshold / fraction).clamp(0.0, 1.0);
    final blendStart = (localThreshold - blend).clamp(0.0, 1.0);
    final blendEnd = (localThreshold + blend).clamp(0.0, 1.0);
    return LinearGradient(
      colors: [start, end, ThemeV2.loss, ThemeV2.loss],
      stops: [0.0, blendStart, blendEnd, 1.0],
    );
  }

  @override
  Widget build(BuildContext context) {
    final fraction = (percent / 100).clamp(0.0, 1.0);
    final inDangerZone = dangerZoneGradient && fraction > 0.70;
    final glowColor = inDangerZone
        ? ThemeV2.loss
        : (!dangerZoneGradient && warning ? _warningGlow : _accentColor);
    final fillGradient = dangerZoneGradient
        ? _dangerZoneGradient()
        : (warning
              ? _warningGradient
              : LinearGradient(colors: [_accentColor, _accentColor]));

    return Padding(
      padding: const EdgeInsets.only(bottom: 14),
      child: Row(
        children: [
          SizedBox(
            width: 130,
            child: Text(
              name,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: GoogleFonts.inter(
                fontSize: 12.5,
                fontWeight: FontWeight.w600,
                color: palette.onWindow ?? Colors.white,
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
                      color: (palette.onWindow ?? Colors.white).withValues(
                        alpha: 0.10,
                      ),
                      borderRadius: BorderRadius.circular(4),
                    ),
                  ),
                  FractionallySizedBox(
                    widthFactor: fraction,
                    child: Container(
                      decoration: BoxDecoration(
                        gradient: fillGradient,
                        borderRadius: BorderRadius.circular(4),
                        boxShadow: (palette.glowOpacity ?? 1.0) > 0
                            ? [
                                BoxShadow(
                                  color: glowColor.withValues(alpha: 0.6),
                                  blurRadius: 6,
                                  spreadRadius: 0.5,
                                ),
                              ]
                            : null,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(width: 10),
          SizedBox(
            width: 50,
            child: Text(
              '${percent.toStringAsFixed(decimals)}$suffix',
              textAlign: TextAlign.right,
              maxLines: 1,
              softWrap: false,
              overflow: TextOverflow.visible,
              style: interNums(
                fontSize: 12.5,
                fontWeight: FontWeight.w600,
                color: palette.onWindow ?? Colors.white,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
