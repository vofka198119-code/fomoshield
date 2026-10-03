import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../../core/theme/fomo_shield_theme.dart';
import '../../../core/theme/theme_v2.dart';
import '../../../core/theme/typography_helpers.dart';
import '../../../core/theme/app_palette.dart';
import '../../../core/theme/themed_header.dart';
import '../../../core/theme/themed_divider.dart';
import '../../../l10n/gen/app_localizations.dart';
import '../../../shared/utils/currency_format.dart';
import '../../../shared/widgets/card_frame.dart';
import '../models/fund.dart';

// ---------------------------------------------------------------------------
// FundBalanceCard — 2026-09-13 redesign: "Доступно" moved out into its own
// FundCashWidget (one number per card, like Portfolio's portfolio_balance/
// portfolio_cash split) -- this card now shows only the fund's total value
// + unrealized P&L, centered, same typography as PortfolioBalanceWidget's
// own ring-center Column (caption/big-number/pnl-line). Explicitly asked to
// copy ONLY that center content, not the donut ring itself -- the
// per-holding allocation breakdown already lives in
// FundManagementHoldingsCard, a ring here would just duplicate it.
// Total is fund.aum (backend: cash + holdings at live price, so it already
// reflects unrealized gains -- no separate calc needed for that number).
// P&L is computed here from fund.holdings, same "avgCost <= 0 means no
// cost basis yet, not a real gain" guard as FundManagementHoldingsCard's
// own per-row P&L (a holding bought before Migration 021 reports avgCost 0).
// ---------------------------------------------------------------------------
class FundBalanceCard extends StatelessWidget {
  final FundDetail fund;
  final AppPalette palette;

  const FundBalanceCard({super.key, required this.fund, required this.palette});

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final priced = fund.holdings.where((h) => h.avgCost > 0);
    final costBasis = priced.fold<double>(0, (s, h) => s + h.costBasis);
    final pnl = priced.fold<double>(0, (s, h) => s + h.pnl);
    final hasPnl = priced.isNotEmpty;
    final pnlPercent = costBasis > 0 ? pnl / costBasis * 100 : 0;
    final isPositive = pnl >= 0;
    final isZero = pnl == 0;
    final pnlColor = !hasPnl || isZero
        ? ThemeV2.textSecondary
        : isPositive
        ? ThemeV2.success
        : ThemeV2.loss;
    final pnlText = !hasPnl
        ? '—'
        : isZero
        ? formatUsd(0)
        : '${formatUsdSigned(pnl)} '
              '(${isPositive ? '+' : ''}${pnlPercent.toStringAsFixed(2)}%)';

    return CardFrame(
      decoration: FomoShieldTheme.cardDecoration,
      palette: palette,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          themedHeaderText(
            l10n.etfFundBalanceTitle,
            palette,
            FomoShieldTheme.cardTitle(),
          ),
          const SizedBox(height: 10),
          themedDivider(palette, indent: 0, endIndent: 0),
          const SizedBox(height: 16),
          Center(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  l10n.etfFundBalanceTotalLabel,
                  style: GoogleFonts.inter(
                    fontSize: 13,
                    fontWeight: FontWeight.w700,
                    color: palette.windowGradient == null
                        ? palette.accentPrimary
                        : palette.textHeader,
                    letterSpacing: 0.5,
                  ),
                ),
                const SizedBox(height: 6),
                themedPriceText(
                  formatUsd(fund.aum),
                  palette,
                  interNums(fontSize: 28, fontWeight: FontWeight.w600),
                ),
                const SizedBox(height: 6),
                Text(
                  pnlText,
                  style: interNums(
                    fontSize: 13,
                    fontWeight: FontWeight.w600,
                    color: pnlColor,
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 4),
        ],
      ),
    );
  }
}
