// ---------------------------------------------------------------------------
// Period Selector — shared segmented pill control for chart timeframe tabs.
// ---------------------------------------------------------------------------
// Previously duplicated 3x with zero shared code across
// PortfolioValueChartWidget (PortfolioChartRange), MarketValueChart
// (_ValuePeriod), and PriceChart (ChartPeriod) — each its own enum, each a
// hand-rolled tab row, each drifting slightly in visual style. This is the
// "Trading 212-style" look Portfolio's chart already had (its own comment
// called it out as the intended look for the Stress Test chart too, which
// never actually matched it until now). Generic over the period type [T]
// so each caller keeps its own enum/period set — only the selector UI is
// unified, not the underlying periods or chart data.
// ---------------------------------------------------------------------------

import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../core/theme/theme_v2.dart';

class PeriodSelector<T> extends StatelessWidget {
  final List<T> periods;
  final T selected;
  final String Function(T period) labelOf;
  final ValueChanged<T> onSelected;

  const PeriodSelector({
    super.key,
    required this.periods,
    required this.selected,
    required this.labelOf,
    required this.onSelected,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(3),
      decoration: BoxDecoration(
        color: ThemeV2.surfaceDark,
        borderRadius: BorderRadius.circular(8),
      ),
      child: Row(
        children: periods.map((period) {
          final isSelected = period == selected;
          return Expanded(
            child: GestureDetector(
              onTap: () {
                if (!isSelected) onSelected(period);
              },
              child: AnimatedContainer(
                duration: const Duration(milliseconds: 200),
                padding: const EdgeInsets.symmetric(vertical: 5),
                decoration: BoxDecoration(
                  color: isSelected ? ThemeV2.surface : Colors.transparent,
                  borderRadius: BorderRadius.circular(6),
                  boxShadow: isSelected
                      ? [
                          BoxShadow(
                            color: Colors.black.withValues(alpha: 0.06),
                            blurRadius: 4,
                            offset: const Offset(0, 1),
                          ),
                        ]
                      : null,
                ),
                child: Text(
                  labelOf(period),
                  textAlign: TextAlign.center,
                  style: GoogleFonts.inter(
                    fontSize: 12,
                    fontWeight: isSelected ? FontWeight.w700 : FontWeight.w500,
                    color: isSelected
                        ? ThemeV2.textPrimary
                        : ThemeV2.textSecondary,
                  ),
                ),
              ),
            ),
          );
        }).toList(),
      ),
    );
  }
}
