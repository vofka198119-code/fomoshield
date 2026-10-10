import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_fonts/google_fonts.dart';

import '../../../core/theme/app_palette.dart';
import '../../../core/theme/theme_v2.dart';
import '../../../core/theme/typography_helpers.dart';
import '../../../l10n/gen/app_localizations.dart';
import '../../../shared/utils/currency_format.dart';
import '../../../shared/widgets/ringed_company_logo.dart';
import '../models/rebalance_leg.dart';

// ---------------------------------------------------------------------------
// The contents of a rebalance, one line per company — what a single trade's
// detail rows are to an ordinary proposal.
//
// Sells first, then buys: the order they execute in, and the order that reads
// correctly, since the money arrives before it is spent.
//
// Built to the house standard rather than to its own taste (DESIGN_TOKENS §7):
// every number is w600 and never bolder, body text starts at 13px, and each
// row carries the company's logo the way every other list of companies in the
// app does — the first version used 11px grey for half the line and no logos
// at all, which read as a spreadsheet dump (2026-10-10).
// ---------------------------------------------------------------------------

class RebalanceLegsList extends ConsumerWidget {
  final List<RebalanceLeg> legs;
  final AppPalette palette;
  final AppLocalizations l10n;

  /// Companies left alone — drawn unticked so the box can be put back on.
  /// They have no trade, only a current share and the target they are
  /// missing.
  final List<UntouchedHolding> untouched;

  /// Null for a read-only list (a filed proposal). When given, every row
  /// carries a box and this is called with the company that was tapped.
  final void Function(String symbol)? onToggle;

  const RebalanceLegsList({
    super.key,
    required this.legs,
    required this.palette,
    required this.l10n,
    this.untouched = const [],
    this.onToggle,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    if (legs.isEmpty) return const SizedBox.shrink();

    final sells = legs.where((l) => !l.isBuy).toList();
    final buys = legs.where((l) => l.isBuy).toList();

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _totals(sells, buys),
        const SizedBox(height: 14),
        for (final leg in [...sells, ...buys])
          _LegRow(
            leg: leg,
            palette: palette,
            l10n: l10n,
            onToggle: onToggle,
          ),
        // The ones left alone sit at the bottom, muted — out of the way of
        // what is actually being done, but still reachable.
        for (final holding in untouched)
          _UntouchedRow(
            holding: holding,
            palette: palette,
            l10n: l10n,
            onToggle: onToggle,
          ),
      ],
    );
  }

  /// The two totals, centred as a pair with the gap between them — and each
  /// carrying the same arrow its own rows carry below, so the arrows in the
  /// list need no explaining (his ask, 2026-10-10).
  Widget _totals(List<RebalanceLeg> sells, List<RebalanceLeg> buys) {
    final sellTotal = sells.fold<double>(0, (sum, l) => sum + l.amount);
    final buyTotal = buys.fold<double>(0, (sum, l) => sum + l.amount);
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        if (sells.isNotEmpty)
          _total(
            l10n.etfRebalanceSellTotal,
            sellTotal,
            ThemeV2.loss,
            Icons.arrow_upward_rounded,
          ),
        if (sells.isNotEmpty && buys.isNotEmpty) const SizedBox(width: 36),
        if (buys.isNotEmpty)
          _total(
            l10n.etfRebalanceBuyTotal,
            buyTotal,
            ThemeV2.success,
            Icons.arrow_downward_rounded,
          ),
      ],
    );
  }

  Widget _total(String label, double amount, Color colour, IconData icon) =>
      Column(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(icon, size: 16, color: colour),
              const SizedBox(width: 4),
              Text(
                label,
                style: GoogleFonts.inter(fontSize: 14, color: palette.textBody),
              ),
            ],
          ),
          const SizedBox(height: 2),
          Text(
            formatUsd(amount),
            style: interNums(
              fontSize: 20,
              fontWeight: FontWeight.w600,
              color: colour,
            ),
          ),
        ],
      );
}

/// The app's own checkbox — an icon inside a tappable area, the way the
/// stress test draws its acceptance box, with the theme's colours rather
/// than hardcoded ones.
Widget _box({
  required bool ticked,
  required AppPalette palette,
  required VoidCallback? onTap,
}) {
  if (onTap == null) return const SizedBox.shrink();
  return Padding(
    padding: const EdgeInsets.only(right: 8),
    child: InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(6),
      child: Icon(
        ticked
            ? Icons.check_box_rounded
            : Icons.check_box_outline_blank_rounded,
        size: 22,
        color: ticked ? palette.accentPrimary : palette.textBody,
      ),
    ),
  );
}

class _LegRow extends ConsumerWidget {
  final RebalanceLeg leg;
  final AppPalette palette;
  final AppLocalizations l10n;
  final void Function(String symbol)? onToggle;

  const _LegRow({
    required this.leg,
    required this.palette,
    required this.l10n,
    this.onToggle,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final colour = leg.isBuy ? ThemeV2.success : ThemeV2.loss;
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Row(
        children: [
          _box(
            ticked: true,
            palette: palette,
            onTap: onToggle == null ? null : () => onToggle!(leg.symbol),
          ),
          RingedCompanyLogo(symbol: leg.symbol, palette: palette),
          const SizedBox(width: 10),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Icon(
                      leg.isBuy
                          ? Icons.arrow_downward_rounded
                          : Icons.arrow_upward_rounded,
                      size: 14,
                      color: colour,
                    ),
                    const SizedBox(width: 4),
                    Text(
                      leg.symbol,
                      style: GoogleFonts.inter(
                        fontSize: 14,
                        fontWeight: FontWeight.w600,
                        color: palette.textHeader,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 2),
                Text(
                  '${leg.shareNow.toStringAsFixed(2)}%  →  '
                  '${leg.shareAfter.toStringAsFixed(2)}%',
                  style: interNums(
                    fontSize: 13,
                    fontWeight: FontWeight.w600,
                    color: palette.textBody,
                  ),
                ),
                if (leg.didFail)
                  Text(
                    l10n.etfRebalanceLegFailed,
                    style: GoogleFonts.inter(
                      fontSize: 13,
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
                  fontSize: 15,
                  fontWeight: FontWeight.w600,
                  color: colour,
                ),
              ),
              const SizedBox(height: 2),
              Text(
                l10n.orderEntrySharesAbbrev(leg.quantity.toStringAsFixed(4)),
                style: interNums(
                  fontSize: 13,
                  fontWeight: FontWeight.w600,
                  color: palette.textBody,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

/// A company the head has unticked: no trade, no amount, and a plain note of
/// where it stands against its target so the cost of leaving it alone is
/// visible on its own line.
class _UntouchedRow extends StatelessWidget {
  final UntouchedHolding holding;
  final AppPalette palette;
  final AppLocalizations l10n;
  final void Function(String symbol)? onToggle;

  const _UntouchedRow({
    required this.holding,
    required this.palette,
    required this.l10n,
    this.onToggle,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Opacity(
        opacity: 0.55,
        child: Row(
          children: [
            _box(
              ticked: false,
              palette: palette,
              onTap: onToggle == null ? null : () => onToggle!(holding.symbol),
            ),
            RingedCompanyLogo(symbol: holding.symbol, palette: palette),
            const SizedBox(width: 10),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    holding.symbol,
                    style: GoogleFonts.inter(
                      fontSize: 14,
                      fontWeight: FontWeight.w600,
                      color: palette.textHeader,
                    ),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    '${holding.shareNow.toStringAsFixed(2)}%  /  '
                    '${holding.targetPercent.toStringAsFixed(2)}%',
                    style: interNums(
                      fontSize: 13,
                      fontWeight: FontWeight.w600,
                      color: palette.textBody,
                    ),
                  ),
                ],
              ),
            ),
            Text(
              l10n.etfRebalanceUntouchedLabel,
              style: GoogleFonts.inter(fontSize: 13, color: palette.textBody),
            ),
          ],
        ),
      ),
    );
  }
}
