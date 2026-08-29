// ---------------------------------------------------------------------------
// Shared horizontal bar row for the Stress Test Portfolio Balance detail
// screen's widgets (asset allocation, sector allocation, ...) — company/
// sector name (ellipsized) + a filled bar for its % share + the number at
// the end. Gold fill normally; switches to a red warning gradient when the
// caller flags a row as over some concentration threshold.
// ---------------------------------------------------------------------------

import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../../core/theme/typography_helpers.dart';
import '../../market_clock/market_clock_dial.dart' show dialBrassLight;

const _warningGradient = LinearGradient(
  colors: [Color(0xFFFF6B4A), Color(0xFFB3261E)],
);
const _warningGlow = Color(0xFFFF3B30);

class AllocationBarRow extends StatelessWidget {
  final String name;
  final double percent;
  final bool warning;
  // Value label formatting — defaults match the original allocation-%
  // callers (1 decimal + '%'). Psychology Meter's 0-100 score bars pass
  // decimals: 0, suffix: '' since they're points, not a percentage.
  final int decimals;
  final String suffix;

  const AllocationBarRow({
    super.key,
    required this.name,
    required this.percent,
    this.warning = false,
    this.decimals = 1,
    this.suffix = '%',
  });

  @override
  Widget build(BuildContext context) {
    final glowColor = warning ? _warningGlow : dialBrassLight;

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
                color: Colors.white,
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
                      color: Colors.white.withValues(alpha: 0.10),
                      borderRadius: BorderRadius.circular(4),
                    ),
                  ),
                  FractionallySizedBox(
                    widthFactor: (percent / 100).clamp(0.0, 1.0),
                    child: Container(
                      decoration: BoxDecoration(
                        color: warning ? null : dialBrassLight,
                        gradient: warning ? _warningGradient : null,
                        borderRadius: BorderRadius.circular(4),
                        boxShadow: [
                          BoxShadow(
                            color: glowColor.withValues(alpha: 0.6),
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
                color: Colors.white,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
