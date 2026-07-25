import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:intl/intl.dart';
import '../../../core/theme/theme_v2.dart';
import '../../../core/theme/fomo_shield_theme.dart';
import '../../../core/theme/typography_helpers.dart';
import '../../../shared/widgets/card_frame.dart';
import '../portfolio_providers.dart';

// Shared gradient for the graph window and the CTA button below it.
const List<Color> _indicatorGradient = [
  Color(0xFF2A6B4C),
  Color(0xFF163D2C),
];

String _fmtCurrency(double amount) =>
    '\$${NumberFormat('#,##0', 'en_US').format(amount)}';

/// Bidirectional progress bar: -100% / 0% / +100%, where 0% is the
/// portfolio's starting capital and +/-100% is the capital doubled/wiped
/// out. The user's profit goal is a fixed dollar amount, plotted as a flag
/// on this same fixed scale (clamped to the edge if it exceeds ±100%).
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

    final currentPercent = hasData ? perf.pnlPercent : 0.0;
    final goalAmount = hasData ? perf.goalAmount : null;
    final startingBalance = hasData ? perf.startingBalance : 0.0;
    final pnl = hasData ? perf.pnl : 0.0;

    final goalPercent = (goalAmount != null && startingBalance > 0)
        ? (goalAmount / startingBalance * 100).clamp(-100.0, 100.0)
        : null;
    final remaining = goalAmount != null ? goalAmount - pnl : null;

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
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 0, 16, 10),
            child: _GraphWindow(
              currentPercent: currentPercent,
              goalPercent: goalPercent,
            ),
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

/// Goal amount (left) / amount left to reach it (right) — same cell style
/// (fonts, olive fill) as the Home Portfolio widget's Balance/Cash cells.
class _GoalSummaryRow extends StatelessWidget {
  final double? goalAmount;
  final double? remaining; // >0: still short, <=0: goal met/exceeded

  const _GoalSummaryRow({required this.goalAmount, required this.remaining});

  @override
  Widget build(BuildContext context) {
    final goalText = goalAmount != null ? _fmtCurrency(goalAmount!) : '—';

    String remainingText = '—';
    Color remainingColor = ThemeV2.textPrimary;
    if (remaining != null) {
      if (remaining! > 0) {
        remainingText = '-${_fmtCurrency(remaining!)}';
        remainingColor = ThemeV2.loss;
      } else {
        remainingText = '+${_fmtCurrency(-remaining!)}';
        remainingColor = ThemeV2.success;
      }
    }

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 7),
      decoration: BoxDecoration(
        color: ThemeV2.primaryBg,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: ThemeV2.divider),
      ),
      child: Row(
        children: [
          Expanded(
            child: _summaryCell(
              label: 'GOAL',
              value: goalText,
              alignEnd: false,
            ),
          ),
          Expanded(
            child: _summaryCell(
              label: 'LEFT TO GOAL',
              value: remainingText,
              valueColor: remainingColor,
              alignEnd: true,
            ),
          ),
        ],
      ),
    );
  }

  Widget _summaryCell({
    required String label,
    required String value,
    required bool alignEnd,
    Color valueColor = ThemeV2.textPrimary,
  }) {
    final crossAlign = alignEnd ? CrossAxisAlignment.end : CrossAxisAlignment.start;
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
        decoration: BoxDecoration(
          gradient: const LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: _indicatorGradient,
          ),
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
/// standard card, holding the marker, bar (+ goal flag), and tick labels.
class _GraphWindow extends StatelessWidget {
  final double currentPercent;
  final double? goalPercent;

  const _GraphWindow({required this.currentPercent, required this.goalPercent});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.fromLTRB(14, 12, 14, 10),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: _indicatorGradient,
        ),
        borderRadius: BorderRadius.circular(16),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _MarkerRow(currentPercent: currentPercent),
          const SizedBox(height: 4),
          Stack(
            children: [
              _SegmentedBar(currentPercent: currentPercent),
              if (goalPercent != null) _GoalFlag(goalPercent: goalPercent!),
            ],
          ),
          const SizedBox(height: 6),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: const [
              _Tick('-100%'),
              _Tick('0%'),
              _Tick('+100%'),
            ],
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
          final x =
              (t * constraints.maxWidth - pillWidth / 2)
                  .clamp(0.0, constraints.maxWidth - pillWidth);
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

/// Thin vertical line marking the profit-goal position on the bar.
class _GoalFlag extends StatelessWidget {
  final double goalPercent; // any range, clamped for position only
  const _GoalFlag({required this.goalPercent});

  @override
  Widget build(BuildContext context) {
    final t = ((goalPercent + 100) / 200).clamp(0.0, 1.0); // 0..1
    return SizedBox(
      height: 28,
      width: double.infinity,
      child: LayoutBuilder(
        builder: (context, constraints) {
          final x = (t * constraints.maxWidth - 1).clamp(
            0.0,
            constraints.maxWidth - 2,
          );
          return Stack(
            children: [
              Positioned(
                left: x,
                top: 0,
                bottom: 0,
                child: Container(width: 2, color: Colors.white),
              ),
            ],
          );
        },
      ),
    );
  }
}

/// Row of small segments, color-graded red (-100%) -> yellow (0%) ->
/// green (+100%). Only the segments between 0% and the current position
/// are colored (progressive fill); the rest sit grey.
class _SegmentedBar extends StatelessWidget {
  final double currentPercent; // -100..100
  const _SegmentedBar({required this.currentPercent});

  static const int _segmentCount = 21;
  static const Color _red = Color(0xFFFF3B30);
  static const Color _yellow = Color(0xFFFFD600);
  static const Color _green = Color(0xFF00C853);
  static const Color _unfilled = Color(0x33FFFFFF); // white @ 20%

  static double _percentForIndex(int index) =>
      -100 + (index / (_segmentCount - 1)) * 200;

  static Color _colorForIndex(int index) {
    final t = index / (_segmentCount - 1); // 0..1
    if (t <= 0.5) return Color.lerp(_red, _yellow, t / 0.5)!;
    return Color.lerp(_yellow, _green, (t - 0.5) / 0.5)!;
  }

  bool _isFilled(int index) {
    final segPercent = _percentForIndex(index);
    return currentPercent >= 0
        ? (segPercent >= 0 && segPercent <= currentPercent)
        : (segPercent <= 0 && segPercent >= currentPercent);
  }

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 28,
      child: Row(
        children: List.generate(_segmentCount, (i) {
          return Expanded(
            child: Container(
              margin: EdgeInsets.only(
                right: i == _segmentCount - 1 ? 0 : 3,
              ),
              decoration: BoxDecoration(
                color: _isFilled(i) ? _colorForIndex(i) : _unfilled,
                borderRadius: BorderRadius.circular(4),
              ),
            ),
          );
        }),
      ),
    );
  }
}
