import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_fonts/google_fonts.dart';

import '../../../core/theme/app_palette.dart';
import '../../../core/theme/fomo_shield_theme.dart';
import '../../../core/theme/theme_v2.dart';
import '../../../core/theme/themed_divider.dart';
import '../../../core/theme/themed_header.dart';
import '../../../core/theme/typography_helpers.dart';
import '../../../l10n/gen/app_localizations.dart';
import '../../../shared/utils/currency_format.dart';
import '../../../shared/widgets/card_frame.dart';
import '../../portfolio/portfolio_providers.dart' show brokerCommissionRate;
import '../models/fund.dart';
import '../models/trade_proposal.dart';
import 'proposal_card.dart' show proposalLivePriceProvider;

// ---------------------------------------------------------------------------
// What a proposed trade would do to the fund — the half an approver needs
// and the card above does not have. ProposalCard describes the ORDER (type,
// price, quantity, commission, who asked); this describes the CONSEQUENCE.
//
// Asked for 2026-10-07: "сколько актива уже есть, сколько в процентах,
// нереализованная прибыль на момент подачи, и сколько станет если одобрить".
// Everything here is computed on the spot from fundDetailProvider, which the
// screen already loads — no server work, no new endpoint.
//
// Deliberately a separate card rather than more rows on ProposalCard: that
// one is also the blotter's detail view and has no fund loaded, and the two
// answer different questions anyway.
// ---------------------------------------------------------------------------

class ProposalImpactCard extends ConsumerWidget {
  final TradeProposal proposal;
  final FundDetail fund;
  final AppPalette palette;
  final AppLocalizations l10n;

  const ProposalImpactCard({
    super.key,
    required this.proposal,
    required this.fund,
    required this.palette,
    required this.l10n,
  });

  /// Anything above this much of the fund in one name earns a warning line.
  /// Not a rule the engine enforces — the head can still approve it — just
  /// the thing a person would want pointed out before they tap Approve.
  static const _concentrationLimit = 0.20;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    // A rebalance has no single company to measure, and needs none: its own
    // list already carries share-before and share-after for every line in
    // it, which is this card's whole content said once per company.
    if (proposal.isRebalance) return const SizedBox.shrink();
    final symbol = proposal.symbol!;
    final quantity = proposal.quantity!;

    // The same price ProposalCard shows, from the same provider: an executed
    // trade keeps its real price, a limit order uses its own, and anything
    // else is a live estimate.
    final livePrice = ref
        .watch(proposalLivePriceProvider(symbol))
        .valueOrNull;
    final price =
        proposal.executedPrice ??
        (proposal.orderType == 'limit' ? proposal.limitPrice : null) ??
        livePrice;
    if (price == null || price <= 0) return const SizedBox.shrink();

    final held = _heldPosition();
    final tradeValue = quantity * price;
    final commission = proposal.commission ?? tradeValue * brokerCommissionRate;

    // Commission is the only money that actually leaves the fund — a buy
    // just moves cash into holdings and a sell moves it back, so AUM barely
    // moves and the share-of-fund figures below stay honest.
    final aumAfter = fund.aum - commission;
    final cashAfter = proposal.isBuy
        ? fund.cash - tradeValue - commission
        : fund.cash + tradeValue - commission;

    final valueNow = held?.value ?? 0;
    final valueAfter = proposal.isBuy
        ? valueNow + tradeValue
        : (valueNow - tradeValue).clamp(0, double.infinity).toDouble();

    final shareNow = fund.aum > 0 ? valueNow / fund.aum * 100 : 0.0;
    final shareAfter = aumAfter > 0 ? valueAfter / aumAfter * 100 : 0.0;

    return CardFrame(
      decoration: FomoShieldTheme.cardDecoration,
      palette: palette,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          themedHeaderText(
            l10n.etfProposalImpactTitle,
            palette,
            FomoShieldTheme.cardTitle(),
          ),
          const SizedBox(height: 10),
          themedDivider(palette, indent: 0, endIndent: 0),
          const SizedBox(height: 16),
          ..._positionRows(held),
          _row(l10n.etfProposalImpactShare, _arrow(
            '${shareNow.toStringAsFixed(2)}%',
            '${shareAfter.toStringAsFixed(2)}%',
          )),
          _row(
            l10n.etfProposalImpactCash,
            _arrow(formatUsd(fund.cash), formatUsd(cashAfter)),
            valueColor: cashAfter < 0 ? ThemeV2.loss : null,
          ),
          ..._sideSpecificRows(held, price, tradeValue),
          if (cashAfter < 0) _note(l10n.etfProposalImpactNotEnoughCash),
          if (shareAfter > _concentrationLimit * 100)
            _note(l10n.etfProposalImpactConcentration),
        ],
      ),
    );
  }

  FundHolding? _heldPosition() {
    for (final h in fund.holdings) {
      if (h.symbol == proposal.symbol) return h;
    }
    return null;
  }

  List<Widget> _positionRows(FundHolding? held) {
    if (held == null) {
      return [
        Padding(
          padding: const EdgeInsets.only(bottom: 12),
          child: Text(
            l10n.etfProposalImpactNoPosition,
            style: GoogleFonts.inter(fontSize: 13, color: palette.textBody),
          ),
        ),
      ];
    }
    return [
      _row(
        l10n.etfProposalImpactAlreadyHeld,
        held.quantity.toStringAsFixed(4),
      ),
      _row(l10n.etfProposalImpactPositionValue, formatUsd(held.value)),
      // avgCost 0 means "bought before the cost basis existed", not a real
      // zero — the same guard every other fund P&L in the app uses.
      if (held.avgCost > 0) ...[
        _row(l10n.etfProposalImpactAvgCost, formatUsd(held.avgCost)),
        _row(
          l10n.etfProposalImpactUnrealized,
          '${formatUsdSigned(held.pnl)} '
          '(${held.pnlPercent >= 0 ? '+' : ''}'
          '${held.pnlPercent.toStringAsFixed(2)}%)',
          valueColor: held.pnl == 0
              ? ThemeV2.textSecondary
              : held.pnl > 0
              ? ThemeV2.success
              : ThemeV2.loss,
        ),
      ],
    ];
  }

  List<Widget> _sideSpecificRows(
    FundHolding? held,
    double price,
    double tradeValue,
  ) {
    // Reached only from build, which has already turned a rebalance away.
    final quantity = proposal.quantity!;
    if (proposal.isBuy) {
      if (held == null || held.avgCost <= 0) return const [];
      // Topping up always drags the average towards today's price; seeing
      // where it lands is half the decision on a position already in profit.
      final avgAfter =
          (held.costBasis + tradeValue) / (held.quantity + quantity);
      return [
        _row(
          l10n.etfProposalImpactAvgCostAfter,
          _arrow(formatUsd(held.avgCost), formatUsd(avgAfter)),
        ),
      ];
    }

    if (held == null || held.quantity <= 0) return const [];
    final soldShare = (quantity / held.quantity * 100).clamp(0, 100);
    final remaining = (held.quantity - quantity).clamp(
      0,
      double.infinity,
    );
    return [
      _row(
        l10n.etfProposalImpactSellingShare,
        '${soldShare.toStringAsFixed(1)}%',
      ),
      if (held.avgCost > 0)
        _row(
          l10n.etfProposalImpactRealized,
          formatUsdSigned(quantity * (price - held.avgCost)),
          valueColor: price >= held.avgCost ? ThemeV2.success : ThemeV2.loss,
        ),
      _row(
        l10n.etfProposalImpactRemaining,
        remaining.toStringAsFixed(4),
      ),
    ];
  }

  // Single spaces, not padded ones: a money pair plus an arrow is already
  // close to the width of a phone row, and the extra air was what pushed
  // the cash row onto two lines.
  String _arrow(String before, String after) => '$before → $after';

  Widget _row(String label, String value, {Color? valueColor}) => Padding(
    padding: const EdgeInsets.only(bottom: 12),
    child: Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Expanded(
          child: Text(
            label,
            style: GoogleFonts.inter(fontSize: 13, color: palette.textBody),
          ),
        ),
        const SizedBox(width: 12),
        Text(
          value,
          textAlign: TextAlign.right,
          style: interNums(
            fontSize: 14,
            fontWeight: FontWeight.w600,
            color: valueColor ?? palette.textHeader,
          ),
        ),
      ],
    ),
  );

  Widget _note(String text) => Padding(
    padding: const EdgeInsets.only(top: 4),
    child: Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Icon(Icons.warning_amber_rounded, size: 16, color: ThemeV2.loss),
        const SizedBox(width: 8),
        Expanded(
          child: Text(
            text,
            style: GoogleFonts.inter(
              fontSize: 12,
              fontWeight: FontWeight.w600,
              color: ThemeV2.loss,
            ),
          ),
        ),
      ],
    ),
  );
}
