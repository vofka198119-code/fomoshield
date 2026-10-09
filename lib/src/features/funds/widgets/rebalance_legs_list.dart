import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

import '../../../core/theme/app_palette.dart';
import '../../../core/theme/theme_v2.dart';
import '../../../core/theme/typography_helpers.dart';
import '../../../l10n/gen/app_localizations.dart';
import '../../../shared/utils/currency_format.dart';
import '../models/rebalance_leg.dart';

// ---------------------------------------------------------------------------
// The contents of a rebalance, one line per company — what a single trade's
// detail rows are to an ordinary proposal.
//
// Sells first, then buys, which is both the order they execute in and the
// order that reads correctly: the money arrives before it is spent.
//
// Each line answers the three questions an approver has — what, how much, and
// what it does to the company's share of the fund — and nothing else. The
// per-leg price is deliberately absent: it was the price when the plan was
// drawn, and by the time anyone approves this it is stale. The amount is what
// the decision is about.
// ---------------------------------------------------------------------------

class RebalanceLegsList extends StatelessWidget {
  final List<RebalanceLeg> legs;
  final AppPalette palette;
  final AppLocalizations l10n;

  /// Lines beyond this are hidden behind a count. A batch can run to forty
  /// companies, and a card that long buries the buttons under it.
  final int? maxVisible;

  const RebalanceLegsList({
    super.key,
    required this.legs,
    required this.palette,
    required this.l10n,
    this.maxVisible,
  });

  @override
  Widget build(BuildContext context) {
    if (legs.isEmpty) return const SizedBox.shrink();

    final sells = legs.where((l) => !l.isBuy).toList();
    final buys = legs.where((l) => l.isBuy).toList();
    final ordered = [...sells, ...buys];
    final visible = maxVisible != null && ordered.length > maxVisible!
        ? ordered.take(maxVisible!).toList()
        : ordered;
    final hidden = ordered.length - visible.length;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _totals(sells, buys),
        const SizedBox(height: 10),
        for (final leg in visible) _row(leg),
        if (hidden > 0)
          Padding(
            padding: const EdgeInsets.only(top: 2),
            child: Text(
              l10n.etfRebalanceLegCount(hidden),
              style: GoogleFonts.inter(fontSize: 12, color: palette.textBody),
            ),
          ),
      ],
    );
  }

  Widget _totals(List<RebalanceLeg> sells, List<RebalanceLeg> buys) {
    final sellTotal = sells.fold<double>(0, (sum, l) => sum + l.amount);
    final buyTotal = buys.fold<double>(0, (sum, l) => sum + l.amount);
    return Row(
      children: [
        if (sells.isNotEmpty)
          Expanded(
            child: _total(l10n.etfRebalanceSellTotal, sellTotal, ThemeV2.loss),
          ),
        if (buys.isNotEmpty)
          Expanded(
            child: _total(l10n.etfRebalanceBuyTotal, buyTotal, ThemeV2.success),
          ),
      ],
    );
  }

  Widget _total(String label, double amount, Color colour) => Column(
    crossAxisAlignment: CrossAxisAlignment.start,
    children: [
      Text(
        label,
        style: GoogleFonts.inter(fontSize: 11, color: palette.textBody),
      ),
      Text(
        formatUsd(amount),
        style: interNums(
          fontSize: 15,
          fontWeight: FontWeight.w700,
          color: colour,
        ),
      ),
    ],
  );

  Widget _row(RebalanceLeg leg) {
    final colour = leg.isBuy ? ThemeV2.success : ThemeV2.loss;
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // The arrow carries the direction, so the line does not have to
          // spell out "buy"/"sell" forty times.
          Icon(
            leg.isBuy ? Icons.arrow_downward_rounded : Icons.arrow_upward_rounded,
            size: 14,
            color: colour,
          ),
          const SizedBox(width: 6),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  leg.symbol,
                  style: GoogleFonts.inter(
                    fontSize: 13,
                    fontWeight: FontWeight.w600,
                    color: palette.textHeader,
                  ),
                ),
                Text(
                  '${leg.shareNow.toStringAsFixed(2)}% → '
                  '${leg.shareAfter.toStringAsFixed(2)}%',
                  style: interNums(fontSize: 11, color: palette.textBody),
                ),
                // Only ever set once the batch has run, and only on the
                // lines that did not go through — the rest of the batch did.
                if (leg.didFail)
                  Text(
                    l10n.etfRebalanceLegFailed,
                    style: GoogleFonts.inter(
                      fontSize: 11,
                      fontWeight: FontWeight.w600,
                      color: ThemeV2.warning,
                    ),
                  ),
              ],
            ),
          ),
          Column(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              Text(
                formatUsd(leg.amount),
                style: interNums(
                  fontSize: 13,
                  fontWeight: FontWeight.w700,
                  color: colour,
                ),
              ),
              Text(
                // The app's own "N шт." phrasing, reused rather than
                // invented — order entry says it the same way.
                l10n.orderEntrySharesAbbrev(leg.quantity.toStringAsFixed(4)),
                style: interNums(fontSize: 11, color: palette.textBody),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
