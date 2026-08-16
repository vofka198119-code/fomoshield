import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../../core/theme/theme_v2.dart';
import '../../../core/theme/fomo_shield_theme.dart';
import '../../../core/theme/typography_helpers.dart';
import '../../../shared/utils/currency_format.dart';
import '../../../shared/widgets/card_frame.dart';
import '../../../shared/widgets/segment_gauge_math.dart';
import '../../market_clock/market_clock_dial.dart';
import '../portfolio_providers.dart';

/// Maps a portfolio's current total value onto the -100%/0%/+100% scale.
/// Below starting capital: -100%..0% spans $0..startingBalance (fixed).
/// Above starting capital: 0%..+100% spans startingBalance..goalAmount —
/// rescaling to whatever goal is set, or startingBalance doubled as a
/// fallback when no goal exists yet. Public — also used by the Home
/// screen's compact vertical bar (`portfolio_widget.dart`) so both bars
/// agree on the same scale.
double targetDisplayPercent({
  required double currentValue,
  required double startingBalance,
  required double? goalAmount,
}) {
  if (startingBalance <= 0) return 0.0;
  final diff = currentValue - startingBalance;
  if (diff <= 0) {
    return (diff / startingBalance) * 100;
  }
  final upperSpan = (goalAmount != null && goalAmount > startingBalance)
      ? (goalAmount - startingBalance)
      : startingBalance;
  return (diff / upperSpan) * 100;
}

/// Bidirectional progress bar: -100% / 0% / +100%, where 0% is always the
/// portfolio's starting capital and -100% is always $0 (wiped out). The
/// right side is NOT fixed: +100% is the portfolio's total-value goal
/// (an absolute dollar target the user sets, e.g. "reach $15,685" — not a
/// profit amount), so the bar's positive half rescales to whatever goal
/// is set. Before a goal is set, the positive half falls back to
/// "starting capital doubled" so the bar still has a sensible right edge.
/// No flag/marker is drawn for the goal itself — since it's always
/// exactly the right edge by definition, a marker there is redundant.
class TargetWidget extends ConsumerWidget {
  final String portfolioId;
  final PortfolioPerformance? performance;
  final bool isLoading;
  final bool hasError;

  const TargetWidget({
    super.key,
    required this.portfolioId,
    this.performance,
    this.isLoading = false,
    this.hasError = false,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final perf = performance;
    final hasData = perf != null && !isLoading && !hasError;

    final currentValue = hasData ? perf.currentValue : 0.0;
    final goalAmount = hasData ? perf.goalAmount : null;
    final startingBalance = hasData ? perf.startingBalance : 0.0;

    final currentPercent = targetDisplayPercent(
      currentValue: currentValue,
      startingBalance: startingBalance,
      goalAmount: goalAmount,
    );
    final remaining = goalAmount != null ? goalAmount - currentValue : null;

    return CardFrame(
      showTopBar: false,
      padding: EdgeInsets.zero,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: const EdgeInsets.fromLTRB(22, 14, 22, 14),
            child: Text('TARGET', style: FomoShieldTheme.cardTitle()),
          ),
          Divider(
            height: 1,
            indent: 16,
            endIndent: 16,
            color: Colors.black.withValues(alpha: 0.06),
          ),
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 12, 16, 10),
            child: _GraphWindow(currentPercent: currentPercent),
          ),
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 0, 16, 10),
            child: _GoalSummaryRow(
              goalAmount: goalAmount,
              remaining: remaining,
            ),
          ),
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
            child: _SelectGoalButton(
              portfolioId: portfolioId,
              hasGoal: goalAmount != null,
            ),
          ),
        ],
      ),
    );
  }
}

/// Goal amount (left) / amount left to reach it (right) — two separate
/// boxes, same cell style (fonts, olive fill) as the Home Portfolio
/// widget's Balance/Cash cells. The right box is tinted red while short
/// of the goal, green once it's met or exceeded.
class _GoalSummaryRow extends StatelessWidget {
  final double? goalAmount;
  final double? remaining; // >0: still short, <=0: goal met/exceeded

  const _GoalSummaryRow({required this.goalAmount, required this.remaining});

  @override
  Widget build(BuildContext context) {
    final goalText = goalAmount != null ? formatUsd(goalAmount!) : '—';

    String remainingText = '—';
    Color remainingColor = ThemeV2.textPrimary;
    Color remainingBg = ThemeV2.primaryBg;
    if (remaining != null) {
      remainingText = formatUsdSigned(-remaining!);
      if (remaining! > 0) {
        remainingColor = ThemeV2.loss;
        remainingBg = ThemeV2.lossBg;
      } else {
        remainingColor = ThemeV2.success;
        remainingBg = ThemeV2.successBg;
      }
    }

    return Row(
      children: [
        Expanded(
          child: _summaryBox(
            label: 'GOAL',
            value: goalText,
            alignEnd: false,
            bgColor: ThemeV2.primaryBg,
          ),
        ),
        const SizedBox(width: 10),
        Expanded(
          child: _summaryBox(
            label: 'LEFT TO GOAL',
            value: remainingText,
            valueColor: remainingColor,
            alignEnd: true,
            bgColor: remainingBg,
          ),
        ),
      ],
    );
  }

  Widget _summaryBox({
    required String label,
    required String value,
    required bool alignEnd,
    required Color bgColor,
    Color valueColor = ThemeV2.textPrimary,
  }) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 7),
      decoration: BoxDecoration(
        color: bgColor,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: ThemeV2.divider),
      ),
      child: _summaryCell(
        label: label,
        value: value,
        alignEnd: alignEnd,
        valueColor: valueColor,
      ),
    );
  }

  Widget _summaryCell({
    required String label,
    required String value,
    required bool alignEnd,
    Color valueColor = ThemeV2.textPrimary,
  }) {
    final crossAlign = alignEnd
        ? CrossAxisAlignment.end
        : CrossAxisAlignment.start;
    final boxAlign = alignEnd ? Alignment.centerRight : Alignment.centerLeft;
    return Column(
      crossAxisAlignment: crossAlign,
      children: [
        Text(
          label,
          style: GoogleFonts.inter(
            fontSize: 10,
            fontWeight: FontWeight.w700,
            letterSpacing: 0.6,
            color: ThemeV2.primary,
          ),
        ),
        const SizedBox(height: 4),
        FittedBox(
          fit: BoxFit.scaleDown,
          alignment: boxAlign,
          child: Text(
            value,
            style: interNums(
              fontSize: 14,
              fontWeight: FontWeight.w600,
              color: valueColor,
              letterSpacing: -0.3,
            ),
          ),
        ),
      ],
    );
  }
}

/// CTA button below the goal summary. "Select Goal" when no goal is set
/// yet, "Change Goal" once one exists. Pushes a full-screen route (not a
/// dialog — see project memory on the invisible-dialog bug in this app).
class _SelectGoalButton extends StatelessWidget {
  final String portfolioId;
  final bool hasGoal;

  const _SelectGoalButton({required this.portfolioId, required this.hasGoal});

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: double.infinity,
      height: ThemeV2.buttonHeight,
      child: DecoratedBox(
        decoration: darkCardDecoration(
          borderRadius: BorderRadius.circular(ThemeV2.buttonRadius),
        ),
        child: Material(
          type: MaterialType.transparency,
          child: InkWell(
            borderRadius: BorderRadius.circular(ThemeV2.buttonRadius),
            onTap: () => context.push('/portfolio/$portfolioId/goal'),
            child: Center(
              child: Text(
                hasGoal ? 'Change Goal' : 'Select Goal',
                style: GoogleFonts.inter(
                  fontSize: 14,
                  fontWeight: FontWeight.w700,
                  color: Colors.white,
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}

/// The graph "window" — its own gradient-backed panel nested inside the
/// standard card, holding the marker, bar, and tick labels.
class _GraphWindow extends StatelessWidget {
  final double currentPercent;

  const _GraphWindow({required this.currentPercent});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.fromLTRB(14, 12, 14, 10),
      decoration: darkCardDecoration(borderRadius: BorderRadius.circular(16)),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _MarkerRow(currentPercent: currentPercent),
          const SizedBox(height: 4),
          _SegmentedBar(currentPercent: currentPercent),
          const SizedBox(height: 6),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: const [_Tick('-100%'), _Tick('0%'), _Tick('+100%')],
          ),
        ],
      ),
    );
  }
}

class _Tick extends StatelessWidget {
  final String label;
  const _Tick(this.label);

  @override
  Widget build(BuildContext context) {
    return Text(
      label,
      style: GoogleFonts.inter(
        fontSize: 11,
        fontWeight: FontWeight.w600,
        color: Colors.white.withValues(alpha: 0.5),
      ),
    );
  }
}

/// Small pill showing the current %, floating above the bar at the
/// matching horizontal position.
class _MarkerRow extends StatelessWidget {
  final double currentPercent; // any range, clamped for position only
  const _MarkerRow({required this.currentPercent});

  @override
  Widget build(BuildContext context) {
    final t = ((currentPercent + 100) / 200).clamp(0.0, 1.0); // 0..1
    return SizedBox(
      height: 20,
      child: LayoutBuilder(
        builder: (context, constraints) {
          const pillWidth = 42.0;
          final x = (t * constraints.maxWidth - pillWidth / 2).clamp(
            0.0,
            constraints.maxWidth - pillWidth,
          );
          return Stack(
            children: [
              Positioned(
                left: x,
                child: Container(
                  width: pillWidth,
                  alignment: Alignment.center,
                  padding: const EdgeInsets.symmetric(vertical: 2),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(6),
                  ),
                  child: Text(
                    '${currentPercent >= 0 ? '+' : ''}${currentPercent.toStringAsFixed(0)}%',
                    style: GoogleFonts.inter(
                      fontSize: 10,
                      fontWeight: FontWeight.w700,
                      color: ThemeV2.primary,
                    ),
                  ),
                ),
              ),
            ],
          );
        },
      ),
    );
  }
}

/// Row of small segments, color-graded red (-100%) -> yellow (0%) ->
/// green (+100%). Each segment spans a fixed 10%-wide range of the
/// -100%..+100% scale; the segment the current position falls inside
/// is only partially colored, proportional to how far through its
/// range the position sits (e.g. +5% lights up half of the 0%-10%
/// segment). Segments fully below the current position are fully
/// colored, segments above stay grey.
class _SegmentedBar extends StatelessWidget {
  final double currentPercent; // -100..100
  const _SegmentedBar({required this.currentPercent});

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 28,
      child: Row(
        children: List.generate(SegmentGaugeMath.segmentCount, (i) {
          final fraction = SegmentGaugeMath.fillFraction(currentPercent, i);
          return Expanded(
            child: Container(
              margin: EdgeInsets.only(
                right: i == SegmentGaugeMath.segmentCount - 1 ? 0 : 3,
              ),
              clipBehavior: Clip.antiAlias,
              decoration: BoxDecoration(
                color: SegmentGaugeMath.unfilled,
                borderRadius: BorderRadius.circular(4),
              ),
              child: fraction > 0
                  ? FractionallySizedBox(
                      widthFactor: fraction,
                      alignment: Alignment.centerLeft,
                      child: Container(
                        color: SegmentGaugeMath.colorForIndex(i),
                      ),
                    )
                  : null,
            ),
          );
        }),
      ),
    );
  }
}
