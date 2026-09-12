import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../../core/theme/fomo_shield_theme.dart';
import '../../../core/theme/theme_v2.dart';
import '../../../core/theme/app_palette.dart';
import '../../../core/theme/themed_divider.dart';
import '../../../l10n/gen/app_localizations.dart';
import '../../../shared/widgets/card_frame.dart';
import '../models/trade_proposal.dart';

// ---------------------------------------------------------------------------
// Proposal Card — one trade proposal's full display + action buttons.
// Shared by FundBlotterScreen (the list) and ProposalDetailScreen (a single
// one, full screen) so the two never drift — extracted 2026-09-12 when the
// detail screen was added.
// ---------------------------------------------------------------------------

String proposalStatusLabel(AppLocalizations l10n, TradeProposal p) {
  switch (p.status) {
    case 'approved':
      return l10n.etfProposalStatusApproved;
    case 'rejected':
      return l10n.etfProposalStatusRejected;
    case 'executed':
      return l10n.etfProposalStatusExecuted;
    default:
      return l10n.etfProposalStatusPending;
  }
}

Color proposalStatusColor(TradeProposal p) {
  switch (p.status) {
    case 'approved':
      return ThemeV2.warning;
    case 'rejected':
      return ThemeV2.loss;
    case 'executed':
      return ThemeV2.success;
    default:
      return ThemeV2.textSecondary;
  }
}

class ProposalCard extends StatelessWidget {
  final TradeProposal proposal;
  final AppPalette palette;
  final AppLocalizations l10n;
  final bool canApprove;
  final bool canFlagRisk;
  final bool canExecute;
  final VoidCallback? onApprove;
  final VoidCallback? onReject;
  final VoidCallback? onFlag;
  final VoidCallback? onExecute;
  final VoidCallback? onTap;

  const ProposalCard({
    super.key,
    required this.proposal,
    required this.palette,
    required this.l10n,
    required this.canApprove,
    required this.canFlagRisk,
    required this.canExecute,
    this.onApprove,
    this.onReject,
    this.onFlag,
    this.onExecute,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final card = CardFrame(
      decoration: FomoShieldTheme.cardDecoration,
      palette: palette,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Text(
                proposal.symbol,
                style: GoogleFonts.inter(
                  fontSize: 15,
                  fontWeight: FontWeight.w700,
                  color: palette.textHeader,
                ),
              ),
              const SizedBox(width: 8),
              Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 6,
                  vertical: 2,
                ),
                decoration: BoxDecoration(
                  color: (proposal.isBuy ? ThemeV2.success : ThemeV2.loss)
                      .withValues(alpha: 0.12),
                  borderRadius: BorderRadius.circular(4),
                ),
                child: Text(
                  proposal.isBuy ? l10n.tradeBuy : l10n.tradeSell,
                  style: GoogleFonts.inter(
                    fontSize: 9,
                    fontWeight: FontWeight.w700,
                    color: proposal.isBuy ? ThemeV2.success : ThemeV2.loss,
                  ),
                ),
              ),
              const Spacer(),
              Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 8,
                  vertical: 3,
                ),
                decoration: BoxDecoration(
                  color: proposalStatusColor(proposal).withValues(alpha: 0.12),
                  borderRadius: BorderRadius.circular(6),
                ),
                child: Text(
                  proposalStatusLabel(l10n, proposal),
                  style: GoogleFonts.inter(
                    fontSize: 10,
                    fontWeight: FontWeight.w700,
                    color: proposalStatusColor(proposal),
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 4),
          Text(
            '${proposal.quantity} @ ${proposal.orderType == 'limit' ? proposal.limitPrice?.toStringAsFixed(2) : l10n.etfProposeOrderTypeMarket}',
            style: GoogleFonts.inter(fontSize: 12, color: palette.textBody),
          ),
          if (proposal.executedPrice != null) ...[
            const SizedBox(height: 4),
            Text(
              '${l10n.etfProposalStatusExecuted}: \$${proposal.executedPrice!.toStringAsFixed(2)}',
              style: GoogleFonts.inter(
                fontSize: 12,
                fontWeight: FontWeight.w600,
                color: ThemeV2.success,
              ),
            ),
          ],
          if (proposal.justification != null &&
              proposal.justification!.isNotEmpty) ...[
            const SizedBox(height: 6),
            Text(
              proposal.justification!,
              style: GoogleFonts.inter(fontSize: 12, color: palette.textBody),
            ),
          ],
          if (proposal.rejectionReason != null &&
              proposal.rejectionReason!.isNotEmpty) ...[
            const SizedBox(height: 6),
            Text(
              proposal.rejectionReason!,
              style: GoogleFonts.inter(fontSize: 12, color: ThemeV2.loss),
            ),
          ],
          if (proposal.flaggedRisky) ...[
            const SizedBox(height: 6),
            Text(
              l10n.etfProposalFlaggedLabel,
              style: GoogleFonts.inter(
                fontSize: 11,
                fontWeight: FontWeight.w700,
                color: ThemeV2.warning,
              ),
            ),
          ],
          if (proposal.isPending && (canApprove || canFlagRisk)) ...[
            const SizedBox(height: 10),
            themedDivider(palette, indent: 0, endIndent: 0),
            const SizedBox(height: 8),
            Wrap(
              spacing: 8,
              children: [
                if (canApprove)
                  TextButton(
                    onPressed: onApprove,
                    child: Text(
                      l10n.etfProposalApproveButton,
                      style: const TextStyle(color: ThemeV2.success),
                    ),
                  ),
                if (canApprove)
                  TextButton(
                    onPressed: onReject,
                    child: Text(
                      l10n.etfProposalRejectButton,
                      style: const TextStyle(color: ThemeV2.loss),
                    ),
                  ),
                if (canFlagRisk && !proposal.flaggedRisky)
                  TextButton(
                    onPressed: onFlag,
                    child: Text(
                      l10n.etfProposalFlagButton,
                      style: const TextStyle(color: ThemeV2.warning),
                    ),
                  ),
              ],
            ),
          ],
          if (proposal.isApproved && canExecute) ...[
            const SizedBox(height: 10),
            themedDivider(palette, indent: 0, endIndent: 0),
            const SizedBox(height: 8),
            TextButton(
              onPressed: onExecute,
              child: Text(
                l10n.etfProposalExecuteButton,
                style: TextStyle(color: palette.accentPrimary),
              ),
            ),
          ],
        ],
      ),
    );

    if (onTap == null) return card;
    return InkWell(
      onTap: onTap,
      borderRadius: FomoShieldTheme.cardRadius,
      child: card,
    );
  }
}
