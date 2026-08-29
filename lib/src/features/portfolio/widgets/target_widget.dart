import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../../core/theme/theme_v2.dart';
import '../../../core/theme/fomo_shield_theme.dart';
import '../../../core/theme/typography_helpers.dart';
import '../../../core/theme/app_palette.dart';
import '../../../core/theme/theme_variant_provider.dart';
import '../../../core/theme/themed_header.dart';
import '../../../core/theme/themed_divider.dart';
import '../../../core/theme/themed_border.dart';
import '../../../core/theme/themed_button.dart';
import '../../../shared/utils/currency_format.dart';
import '../../../shared/widgets/card_frame.dart';
import '../../../shared/widgets/segment_gauge_math.dart';
import '../../market_clock/market_clock_dial.dart';
import '../../../l10n/gen/app_localizations.dart';
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
    final palette = resolveAppPalette(ref.watch(themeVariantProvider));

    return CardFrame(
      showTopBar: false,
      padding: EdgeInsets.zero,
      palette: palette,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: const EdgeInsets.fromLTRB(22, 14, 22, 14),
            child: themedHeaderText(
              AppLocalizations.of(context)!.targetLabel,
              palette,
              FomoShieldTheme.cardTitle(),
            ),
          ),
          themedDivider(palette),
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 12, 16, 10),
            child: _GraphWindow(
              currentPercent: currentPercent,
              palette: palette,
            ),
          ),
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 0, 16, 10),
            child: _GoalSummaryRow(
              goalAmount: goalAmount,
              remaining: remaining,
              palette: palette,
            ),
          ),
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
            child: _SelectGoalButton(
              portfolioId: portfolioId,
              hasGoal: goalAmount != null,
              palette: palette,
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
  final AppPalette palette;

  const _GoalSummaryRow({
    required this.goalAmount,
    required this.remaining,
    required this.palette,
  });

  @override
  Widget build(BuildContext context) {
    final goalText = goalAmount != null ? formatUsd(goalAmount!) : '—';

    String remainingText = '—';
    Color? remainingColor;
    Color remainingBg = ThemeV2.primaryBg;
    if (remaining != null) {
      if (remaining! > 0) {
        // Still short of the goal — a plain amount ("still need $X more"),
        // not a negative one: a leading "-" here read like a loss, not
        // "amount left to go".
        remainingText = formatUsd(remaining!);
        remainingColor = ThemeV2.loss;
        remainingBg = ThemeV2.lossBg;
      } else {
        remainingText = formatUsdSigned(-remaining!);
        remainingColor = ThemeV2.success;
        remainingBg = ThemeV2.successBg;
      }
    }

    return Row(
      children: [
        Expanded(
          child: themedBorder(
            palette: palette,
            borderRadius: BorderRadius.circular(16),
            child: _summaryBox(
              label: AppLocalizations.of(context)!.targetGoalLabel,
              value: goalText,
              alignEnd: false,
              bgColor: ThemeV2.primaryBg,
              goldValue: true,
            ),
          ),
        ),
        const SizedBox(width: 10),
        Expanded(
          child: themedBorder(
            palette: palette,
            borderRadius: BorderRadius.circular(16),
            child: _summaryBox(
              label: AppLocalizations.of(context)!.targetLeftToGoal,
              value: remainingText,
              valueColor: remainingColor,
              alignEnd: true,
              bgColor: remainingBg,
            ),
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
    Color? valueColor,
    bool goldValue = false,
  }) {
    final hasThemedBorder = palette.borderGradient != null;
    final effectiveGradient = hasThemedBorder ? palette.windowGradient : null;
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 7),
      decoration: BoxDecoration(
        color: effectiveGradient == null ? bgColor : null,
        gradient: effectiveGradient,
        borderRadius: BorderRadius.circular(16),
        border: effectiveGradient == null && !hasThemedBorder
            ? Border.all(color: ThemeV2.divider)
            : null,
      ),
      child: _summaryCell(
        label: label,
        value: value,
        alignEnd: alignEnd,
        valueColor: valueColor,
        goldValue: goldValue,
      ),
    );
  }

  Widget _summaryCell({
    required String label,
    required String value,
    required bool alignEnd,
    Color? valueColor,
    bool goldValue = false,
  }) {
    final crossAlign = alignEnd
        ? CrossAxisAlignment.end
        : CrossAxisAlignment.start;
    final boxAlign = alignEnd ? Alignment.centerRight : Alignment.centerLeft;
    final valueStyle = interNums(
      fontSize: 14,
      fontWeight: FontWeight.w600,
      color: valueColor ?? palette.textHeader,
      letterSpacing: -0.3,
    );
    return Column(
      crossAxisAlignment: crossAlign,
      children: [
        Text(
          label,
          style: GoogleFonts.inter(
            fontSize: 10,
            fontWeight: FontWeight.w700,
            letterSpacing: 0.6,
            color: palette.accentPrimary,
          ),
        ),
        const SizedBox(height: 4),
        FittedBox(
          fit: BoxFit.scaleDown,
          alignment: boxAlign,
          child: goldValue
              ? themedPriceText(value, palette, valueStyle)
              : Text(value, style: valueStyle),
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
  final AppPalette palette;

  const _SelectGoalButton({
    required this.portfolioId,
    required this.hasGoal,
    required this.palette,
  });

  @override
  Widget build(BuildContext context) {
    final radius = BorderRadius.circular(ThemeV2.buttonRadius);
    return SizedBox(
      width: double.infinity,
      height: ThemeV2.buttonHeight,
      child: Material(
        type: MaterialType.transparency,
        child: themedDarkCtaButtonShell(
          palette: palette,
          borderRadius: radius,
          standardDecoration: darkCardDecoration(borderRadius: radius),
          child: InkWell(
            borderRadius: radius,
            onTap: () => context.push('/portfolio/$portfolioId/goal'),
            child: Center(
              child: Text(
                hasGoal
                    ? AppLocalizations.of(context)!.targetChangeGoal
                    : AppLocalizations.of(context)!.targetSelectGoal,
                style: GoogleFonts.inter(
                  fontSize: 14,
                  fontWeight: FontWeight.w700,
                  color: themedDarkCtaContentColor(palette),
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
  final AppPalette palette;

  const _GraphWindow({required this.currentPercent, required this.palette});

  @override
  Widget build(BuildContext context) {
    final radius = BorderRadius.circular(16);
    final content = Container(
      width: double.infinity,
      padding: const EdgeInsets.fromLTRB(14, 12, 14, 10),
      decoration: palette.windowGradient != null
          ? BoxDecoration(gradient: palette.windowGradient, borderRadius: radius)
          : darkCardDecoration(borderRadius: radius),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _MarkerRow(currentPercent: currentPercent, palette: palette),
          const SizedBox(height: 4),
          _SegmentedBar(currentPercent: currentPercent),
          const SizedBox(height: 6),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              _Tick('-100%', palette: palette),
              _Tick('0%', palette: palette),
              _Tick('+100%', palette: palette),
            ],
          ),
        ],
      ),
    );
    return palette.windowGradient != null
        ? themedBorder(palette: palette, borderRadius: radius, child: content)
        : content;
  }
}

class _Tick extends StatelessWidget {
  final String label;
  final AppPalette palette;
  const _Tick(this.label, {required this.palette});

  @override
  Widget build(BuildContext context) {
    return Text(
      label,
      style: GoogleFonts.inter(
        fontSize: 11,
        fontWeight: FontWeight.w600,
        color: palette.windowGradient != null
            ? palette.textHeader
            : Colors.white.withValues(alpha: 0.5),
      ),
    );
  }
}

/// Small pill showing the current %, floating above the bar at the
/// matching horizontal position. Window style (gold border + window
/// gradient + flat gold digits) under Luxury, matching the identical
/// pill on Home's compact Portfolio bar — not the button treatment, per
/// explicit correction there.
class _MarkerRow extends StatelessWidget {
  final double currentPercent; // any range, clamped for position only
  final AppPalette palette;
  const _MarkerRow({required this.currentPercent, required this.palette});

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
          final pillRadius = BorderRadius.circular(6);
          final pillText =
              '${currentPercent >= 0 ? '+' : ''}${currentPercent.toStringAsFixed(0)}%';
          final pill = palette.windowGradient != null
              ? themedBorder(
                  palette: palette,
                  borderRadius: pillRadius,
                  child: Container(
                    width: pillWidth,
                    alignment: Alignment.center,
                    padding: const EdgeInsets.symmetric(vertical: 2),
                    decoration: BoxDecoration(gradient: palette.windowGradient),
                    child: Text(
                      pillText,
                      style: GoogleFonts.inter(
                        fontSize: 10,
                        fontWeight: FontWeight.w700,
                        color: palette.accentPrimary,
                      ),
                    ),
                  ),
                )
              : Container(
                  width: pillWidth,
                  alignment: Alignment.center,
                  padding: const EdgeInsets.symmetric(vertical: 2),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: pillRadius,
                  ),
                  child: Text(
                    pillText,
                    style: GoogleFonts.inter(
                      fontSize: 10,
                      fontWeight: FontWeight.w700,
                      color: ThemeV2.primary,
                    ),
                  ),
                );
          return Stack(children: [Positioned(left: x, child: pill)]);
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
