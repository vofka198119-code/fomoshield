import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

import '../../../core/theme/app_palette.dart';
import '../../../core/theme/fomo_shield_theme.dart';
import '../../../core/theme/theme_v2.dart';
import '../../../core/theme/themed_divider.dart';
import '../../../core/theme/themed_header.dart';
import '../../../core/theme/typography_helpers.dart';
import '../../../l10n/gen/app_localizations.dart';
import '../../../shared/widgets/card_frame.dart';
import '../models/fund_drift.dart';

// ---------------------------------------------------------------------------
// The drift reading — "it should be like that, it is like this, here is the
// distance". Phase 2 of the target weights (2026-10-09).
//
// Deliberately NOT Trading 212's balance score. Their screen says "6,0" and
// "your pie is a little unbalanced", and his decision was to drop the invented
// scale entirely: state the largest gap outright and say how many companies
// have left the plan, so anyone can check the card by eye against the list
// below it. No formula to explain, nothing to trust.
//
// Colour here only ever answers "which number am I looking at", never "is
// this good": the fact takes the theme's chart colour and the target green,
// the same pairing as the editor underneath. Direction is an arrow and a
// word, because holding too much of something is not a worse sin than
// holding too little — the fund simply drifted, and which way is a fact.
// ---------------------------------------------------------------------------

class FundDriftCard extends StatelessWidget {
  final FundDrift drift;
  final AppPalette palette;
  final AppLocalizations l10n;

  const FundDriftCard({
    super.key,
    required this.drift,
    required this.palette,
    required this.l10n,
  });

  String _pct(double value) => '${value.toStringAsFixed(2)}%';

  /// Thresholds are whole percents in practice; "1%" reads better than
  /// "1.00%" in the middle of a sentence.
  String get _thresholdLabel =>
      drift.threshold == drift.threshold.roundToDouble()
      ? drift.threshold.toStringAsFixed(0)
      : drift.threshold.toStringAsFixed(2);

  @override
  Widget build(BuildContext context) {
    final largest = drift.largest;
    // Nothing to compare against: no plan yet, or a plan for an empty fund.
    // The editor below already explains both cases in words, and a card
    // announcing that an unplanned fund is "40% above target" would be a
    // reading of a plan that does not exist.
    if (largest == null) return const SizedBox.shrink();

    final offTarget = drift.offTarget;

    return CardFrame(
      decoration: FomoShieldTheme.cardDecoration,
      palette: palette,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          themedHeaderText(
            l10n.etfBalancingDriftTitle,
            palette,
            FomoShieldTheme.cardTitle(),
          ),
          const SizedBox(height: 10),
          themedDivider(palette, indent: 0, endIndent: 0),
          const SizedBox(height: 14),
          if (offTarget.isEmpty)
            Text(
              l10n.etfBalancingDriftOnPlan(_thresholdLabel),
              style: GoogleFonts.inter(fontSize: 13, color: palette.textBody),
            )
          else ...[
            _largestBlock(largest),
            const SizedBox(height: 14),
            _countRow(offTarget.length),
            // The biggest gap is spelled out above; the rest are listed in
            // the order a rebalance would care about — widest first.
            if (offTarget.length > 1) ...[
              const SizedBox(height: 12),
              themedDivider(palette, indent: 0, endIndent: 0),
              const SizedBox(height: 10),
              for (final row in offTarget.skip(1)) _compactRow(row),
            ],
          ],
        ],
      ),
    );
  }

  Widget _largestBlock(FundDriftRow row) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          l10n.etfBalancingDriftLargestLabel,
          style: GoogleFonts.inter(fontSize: 12, color: palette.textBody),
        ),
        const SizedBox(height: 6),
        Row(
          crossAxisAlignment: CrossAxisAlignment.end,
          children: [
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    row.symbol,
                    style: GoogleFonts.inter(
                      fontSize: 16,
                      fontWeight: FontWeight.w700,
                      color: palette.textHeader,
                    ),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    row.isOverweight
                        ? l10n.etfBalancingDriftAbove
                        : l10n.etfBalancingDriftBelow,
                    style: GoogleFonts.inter(
                      fontSize: 12,
                      color: palette.textBody,
                    ),
                  ),
                ],
              ),
            ),
            Icon(
              row.isOverweight
                  ? Icons.arrow_upward_rounded
                  : Icons.arrow_downward_rounded,
              size: 20,
              color: palette.textBody,
            ),
            const SizedBox(width: 2),
            Text(
              _pct(row.gap.abs()),
              style: interNums(
                fontSize: 26,
                fontWeight: FontWeight.w700,
                color: palette.textHeader,
              ),
            ),
          ],
        ),
        const SizedBox(height: 6),
        _factAgainstTarget(row),
      ],
    );
  }

  /// `факт 29,27% · цель 15,00%` — the two colours of the editor's own rows,
  /// so the eye carries one meaning down the screen instead of learning it
  /// twice.
  Widget _factAgainstTarget(FundDriftRow row) {
    final dot = TextSpan(
      text: '  ·  ',
      style: interNums(fontSize: 12, color: palette.textBody),
    );
    return Text.rich(
      TextSpan(
        children: [
          TextSpan(
            text: '${l10n.etfBalancingDriftNowLabel} ',
            style: GoogleFonts.inter(fontSize: 12, color: palette.textBody),
          ),
          TextSpan(
            text: _pct(row.actualPercent),
            style: interNums(
              fontSize: 12,
              fontWeight: FontWeight.w700,
              color: palette.actualFigureColour,
            ),
          ),
          dot,
          TextSpan(
            text: '${l10n.etfBalancingDriftTargetLabel} ',
            style: GoogleFonts.inter(fontSize: 12, color: palette.textBody),
          ),
          TextSpan(
            text: _pct(row.targetPercent),
            style: interNums(
              fontSize: 12,
              fontWeight: FontWeight.w700,
              color: ThemeV2.success,
            ),
          ),
        ],
      ),
    );
  }

  Widget _countRow(int offCount) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Expanded(
          child: Text(
            l10n.etfBalancingDriftOffLabel(_thresholdLabel),
            style: GoogleFonts.inter(fontSize: 12, color: palette.textBody),
          ),
        ),
        const SizedBox(width: 10),
        Text(
          l10n.etfBalancingDriftOffValue(offCount, drift.totalCount),
          style: interNums(
            fontSize: 14,
            fontWeight: FontWeight.w700,
            color: palette.textHeader,
          ),
        ),
      ],
    );
  }

  Widget _compactRow(FundDriftRow row) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Row(
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  row.symbol,
                  style: GoogleFonts.inter(
                    fontSize: 13,
                    fontWeight: FontWeight.w600,
                    color: palette.textHeader,
                  ),
                ),
                const SizedBox(height: 1),
                _factAgainstTarget(row),
              ],
            ),
          ),
          Icon(
            row.isOverweight
                ? Icons.arrow_upward_rounded
                : Icons.arrow_downward_rounded,
            size: 14,
            color: palette.textBody,
          ),
          const SizedBox(width: 2),
          Text(
            _pct(row.gap.abs()),
            style: interNums(
              fontSize: 14,
              fontWeight: FontWeight.w700,
              color: palette.textHeader,
            ),
          ),
        ],
      ),
    );
  }
}
