import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../../core/theme/app_palette.dart';
import '../../../core/theme/theme_v2.dart';
import '../../../core/theme/typography_helpers.dart';

// ---------------------------------------------------------------------------
// FundAllocationBarRow — one horizontal bar per holding for the fund
// "Asset Allocation" chart (2026-09-13, "как в притоке/оттоке инвесторов"
// style request generalized to "как виджет распределения активов в стресс
// тесте"). Same visual read as Stress Test's own AllocationBarRow (name
// left, filled bar, % at the end, red past the 70% concentration mark) but
// NOT that exact widget reused verbatim: AllocationBarRow keys its colors
// off palette.onWindow/marketClockAccent/barFillGradient, which only the
// windowGradient-based Stress Test/Market Clock themes populate -- under
// the plain Standard theme (a white card, no windowGradient) those fields
// are null and AllocationBarRow's white-text fallback would be invisible.
// This row instead uses palette.textHeader/accentPrimary, the same fields
// every other fund card already relies on to stay legible across every
// theme (see FundInvestorsStatsCard, proposal_card.dart).
// ---------------------------------------------------------------------------
class FundAllocationBarRow extends StatelessWidget {
  final String name;
  final double percent;
  final AppPalette palette;

  const FundAllocationBarRow({
    super.key,
    required this.name,
    required this.percent,
    required this.palette,
  });

  /// Blends the bar's fill from the theme accent into a red warning past
  /// the 70% mark of [percent] itself -- one holding eating too much of
  /// the fund is the risk signal here, same threshold Stress Test's own
  /// allocation bars use.
  LinearGradient _fillGradient() {
    const threshold = 0.70;
    const blend = 0.05;
    final accent = palette.accentPrimary;
    final fraction = (percent / 100).clamp(0.0, 1.0);
    if (fraction <= threshold || fraction == 0) {
      return LinearGradient(colors: [accent, accent]);
    }
    final localThreshold = (threshold / fraction).clamp(0.0, 1.0);
    final blendStart = (localThreshold - blend).clamp(0.0, 1.0);
    final blendEnd = (localThreshold + blend).clamp(0.0, 1.0);
    return LinearGradient(
      colors: [accent, accent, ThemeV2.loss, ThemeV2.loss],
      stops: [0.0, blendStart, blendEnd, 1.0],
    );
  }

  @override
  Widget build(BuildContext context) {
    final fraction = (percent / 100).clamp(0.0, 1.0);

    return Padding(
      padding: const EdgeInsets.only(bottom: 14),
      child: Row(
        children: [
          SizedBox(
            width: 100,
            child: Text(
              name,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: GoogleFonts.inter(
                fontSize: 12.5,
                fontWeight: FontWeight.w600,
                color: palette.textHeader,
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
                      color: palette.textBody.withValues(alpha: 0.12),
                      borderRadius: BorderRadius.circular(4),
                    ),
                  ),
                  FractionallySizedBox(
                    widthFactor: fraction,
                    child: Container(
                      decoration: BoxDecoration(
                        gradient: _fillGradient(),
                        borderRadius: BorderRadius.circular(4),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(width: 10),
          SizedBox(
            width: 46,
            child: Text(
              '${percent.toStringAsFixed(1)}%',
              textAlign: TextAlign.right,
              maxLines: 1,
              softWrap: false,
              overflow: TextOverflow.visible,
              style: interNums(
                fontSize: 12.5,
                fontWeight: FontWeight.w600,
                color: palette.textHeader,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
