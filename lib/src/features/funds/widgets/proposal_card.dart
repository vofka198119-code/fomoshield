import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../../core/cache/logo_providers.dart';
import '../../../core/theme/fomo_shield_theme.dart';
import '../../../core/theme/theme_v2.dart';
import '../../../core/theme/typography_helpers.dart';
import '../../../core/theme/app_palette.dart';
import '../../../core/theme/themed_divider.dart';
import '../../../core/theme/themed_header.dart';
import '../../../l10n/gen/app_localizations.dart';
import '../../../shared/widgets/card_frame.dart';
import '../../../shared/widgets/company_logo.dart';
import '../models/trade_proposal.dart';

// ---------------------------------------------------------------------------
// Proposal Card + Proposal List Tile — 2026-09-12 redesign. The blotter list
// (ProposalListTile) is now just identification + status, no action
// buttons; ProposalCard is the "одно окно большое со всеми подробностями"
// that lives on ProposalDetailScreen, modeled directly on
// PortfolioTradeDetailScreen's own _TradeDetailCard/_DetailRow ("детали
// сделки" -- the reference the user pointed at): ringed logo header
// (green/red per side, same as every other trade/order row in the app --
// TradeHistoryTile, _TradeDetailCard -- NOT the plain Watchlist-style
// single-accent ring, which is for a non-directional asset list), then a
// clean label/value row list, then action buttons.
// ---------------------------------------------------------------------------

String proposalStatusLabel(AppLocalizations l10n, TradeProposal p) {
  switch (p.status) {
    case 'approved':
      return l10n.etfProposalStatusApproved;
    case 'rejected':
      return l10n.etfProposalStatusRejected;
    case 'executed':
      return l10n.etfProposalStatusExecuted;
    case 'needs_revision':
      return l10n.etfProposalStatusNeedsRevision;
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
    case 'needs_revision':
      return ThemeV2.warning;
    default:
      return ThemeV2.textSecondary;
  }
}

Future<void> _showReworkDialog(
  BuildContext context,
  AppLocalizations l10n,
  void Function(String reason) onSubmit,
) async {
  final controller = TextEditingController();
  final formKey = GlobalKey<FormState>();

  await showDialog<void>(
    context: context,
    builder: (dialogContext) => AlertDialog(
      title: Text(l10n.etfProposalReworkDialogTitle),
      content: Form(
        key: formKey,
        child: TextFormField(
          controller: controller,
          autofocus: true,
          maxLines: 3,
          decoration: InputDecoration(
            hintText: l10n.etfProposalReworkReasonHint,
          ),
          validator: (value) => (value ?? '').trim().isEmpty
              ? l10n.etfProposalReworkReasonRequired
              : null,
        ),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.of(dialogContext).pop(),
          child: Text(
            MaterialLocalizations.of(dialogContext).cancelButtonLabel,
          ),
        ),
        TextButton(
          onPressed: () {
            if (!formKey.currentState!.validate()) return;
            Navigator.of(dialogContext).pop();
            onSubmit(controller.text.trim());
          },
          child: Text(l10n.etfProposalReworkSubmitButton),
        ),
      ],
    ),
  );
}

Widget _pairedButton({
  required VoidCallback? onPressed,
  required IconData icon,
  required String label,
  required Color color,
  required bool filled,
}) {
  final child = Row(
    mainAxisAlignment: MainAxisAlignment.center,
    mainAxisSize: MainAxisSize.min,
    children: [
      Icon(icon, size: 16, color: filled ? Colors.white : color),
      const SizedBox(width: 6),
      Text(
        label,
        style: GoogleFonts.inter(
          fontSize: 13,
          fontWeight: FontWeight.w700,
          color: filled ? Colors.white : color,
        ),
      ),
    ],
  );
  if (filled) {
    return ElevatedButton(
      onPressed: onPressed,
      style: ElevatedButton.styleFrom(
        backgroundColor: color,
        minimumSize: const Size.fromHeight(42),
        padding: EdgeInsets.zero,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
        elevation: 0,
      ),
      child: child,
    );
  }
  return OutlinedButton(
    onPressed: onPressed,
    style: OutlinedButton.styleFrom(
      minimumSize: const Size.fromHeight(42),
      padding: EdgeInsets.zero,
      side: BorderSide(color: color.withValues(alpha: 0.5)),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
    ),
    child: child,
  );
}

Widget _detailRow({
  required String label,
  required String value,
  required AppPalette palette,
  Color? valueColor,
  bool isLast = false,
}) {
  return Padding(
    padding: EdgeInsets.only(bottom: isLast ? 0 : 12),
    child: Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(
          label,
          style: GoogleFonts.inter(fontSize: 13, color: palette.textBody),
        ),
        valueColor != null
            ? Text(
                value,
                style: interNums(
                  fontSize: 14,
                  fontWeight: FontWeight.w600,
                  color: valueColor,
                ),
              )
            : themedPriceText(
                value,
                palette,
                interNums(fontSize: 14, fontWeight: FontWeight.w600),
              ),
      ],
    ),
  );
}

// ---------------------------------------------------------------------------
// ProposalListTile — the blotter's own row. Simple by design (2026-09-12):
// a header naming the order side, then identification + status, tap (or
// the "Подробности" affordance) goes to ProposalDetailScreen where the
// actual actions live. Same ringed-logo row shape as TradeHistoryTile.
// ---------------------------------------------------------------------------
class ProposalListTile extends ConsumerWidget {
  final TradeProposal proposal;
  final AppPalette palette;
  final AppLocalizations l10n;
  final VoidCallback onTap;

  const ProposalListTile({
    super.key,
    required this.proposal,
    required this.palette,
    required this.l10n,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final logoUrl = ref.watch(cachedLogoProvider(proposal.symbol)).valueOrNull;
    final companyName =
        ref.watch(resolvedCompanyNameProvider(proposal.symbol)).valueOrNull ??
        proposal.symbol;
    final accent = proposal.isBuy ? ThemeV2.success : ThemeV2.loss;

    return InkWell(
      onTap: onTap,
      borderRadius: FomoShieldTheme.cardRadius,
      child: CardFrame(
        decoration: FomoShieldTheme.cardDecoration,
        palette: palette,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              proposal.isBuy
                  ? l10n.etfProposalHeaderBuy
                  : l10n.etfProposalHeaderSell,
              style: GoogleFonts.inter(
                fontSize: 11,
                fontWeight: FontWeight.w800,
                letterSpacing: 0.6,
                color: accent,
              ),
            ),
            const SizedBox(height: 10),
            Row(
              children: [
                Container(
                  width: 40,
                  height: 40,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    border: Border.all(
                      color: accent.withValues(alpha: 0.3),
                      width: 1.5,
                    ),
                  ),
                  padding: const EdgeInsets.all(2),
                  child: ClipOval(
                    child: SizedBox(
                      width: 34,
                      height: 34,
                      child: CompanyLogo(
                        ticker: proposal.symbol,
                        logoUrl: logoUrl,
                        radius: 17,
                        resolveIfMissing: false,
                      ),
                    ),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        companyName,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: GoogleFonts.inter(
                          fontSize: 14,
                          fontWeight: FontWeight.w600,
                          color: palette.textHeader,
                        ),
                      ),
                      const SizedBox(height: 2),
                      Text(
                        proposal.symbol,
                        style: GoogleFonts.inter(
                          fontSize: 11,
                          color: palette.textBody,
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(width: 8),
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 8,
                    vertical: 3,
                  ),
                  decoration: BoxDecoration(
                    color: proposalStatusColor(
                      proposal,
                    ).withValues(alpha: 0.12),
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
            const SizedBox(height: 10),
            themedDivider(palette, indent: 0, endIndent: 0),
            const SizedBox(height: 8),
            Align(
              alignment: Alignment.centerRight,
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(
                    l10n.etfProposalDetailsButton,
                    style: GoogleFonts.inter(
                      fontSize: 12,
                      fontWeight: FontWeight.w700,
                      color: palette.accentPrimary,
                    ),
                  ),
                  Icon(
                    Icons.chevron_right_rounded,
                    size: 18,
                    color: palette.accentPrimary,
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// ---------------------------------------------------------------------------
// ProposalCard — the "одно окно большое со всеми подробностями" on
// ProposalDetailScreen, styled like PortfolioTradeDetailScreen's own
// _TradeDetailCard.
// ---------------------------------------------------------------------------
class ProposalCard extends ConsumerWidget {
  final TradeProposal proposal;
  final AppPalette palette;
  final AppLocalizations l10n;
  final bool canApprove;
  final bool canFlagRisk;
  final bool canExecute;
  final VoidCallback? onApprove;
  final VoidCallback? onReject;
  final void Function(String reason)? onRework;
  final VoidCallback? onFlag;
  final VoidCallback? onExecute;

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
    this.onRework,
    this.onFlag,
    this.onExecute,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final logoUrl = ref.watch(cachedLogoProvider(proposal.symbol)).valueOrNull;
    final companyName =
        ref.watch(resolvedCompanyNameProvider(proposal.symbol)).valueOrNull ??
        proposal.symbol;
    final accent = proposal.isBuy ? ThemeV2.success : ThemeV2.loss;

    return CardFrame(
      decoration: FomoShieldTheme.cardDecoration,
      padding: const EdgeInsets.all(22),
      palette: palette,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                width: 52,
                height: 52,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  border: Border.all(
                    color: accent.withValues(alpha: 0.3),
                    width: 1.5,
                  ),
                ),
                padding: const EdgeInsets.all(2),
                child: ClipOval(
                  child: SizedBox(
                    width: 46,
                    height: 46,
                    child: CompanyLogo(
                      ticker: proposal.symbol,
                      logoUrl: logoUrl,
                      radius: 23,
                      resolveIfMissing: false,
                    ),
                  ),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      companyName,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: GoogleFonts.inter(
                        fontSize: 16,
                        fontWeight: FontWeight.w600,
                        color: palette.textHeader,
                      ),
                    ),
                    Text(
                      proposal.symbol,
                      style: GoogleFonts.inter(
                        fontSize: 12,
                        color: palette.textBody,
                      ),
                    ),
                  ],
                ),
              ),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                decoration: BoxDecoration(
                  color: accent.withValues(alpha: 0.12),
                  borderRadius: BorderRadius.circular(6),
                ),
                child: Text(
                  proposal.isBuy ? l10n.tradeBuy : l10n.tradeSell,
                  style: GoogleFonts.inter(
                    fontSize: 11,
                    fontWeight: FontWeight.w700,
                    color: accent,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
            decoration: BoxDecoration(
              color: proposalStatusColor(proposal).withValues(alpha: 0.12),
              borderRadius: BorderRadius.circular(6),
            ),
            child: Text(
              proposalStatusLabel(l10n, proposal),
              style: GoogleFonts.inter(
                fontSize: 11,
                fontWeight: FontWeight.w700,
                color: proposalStatusColor(proposal),
              ),
            ),
          ),
          const SizedBox(height: 16),
          themedDivider(palette, indent: 0, endIndent: 0, height: 1),
          const SizedBox(height: 16),
          _detailRow(
            label: l10n.tradeOrderTypeLabel,
            value: proposal.orderType == 'limit'
                ? l10n.etfProposeOrderTypeLimit
                : l10n.etfProposeOrderTypeMarket,
            palette: palette,
          ),
          if (proposal.limitPrice != null)
            _detailRow(
              label: l10n.tradeLimitPriceLabel,
              value: '\$${proposal.limitPrice!.toStringAsFixed(2)}',
              palette: palette,
            ),
          _detailRow(
            label: proposal.isBuy
                ? l10n.tradeSharesBoughtLabel
                : l10n.tradeSharesSoldLabel,
            value: proposal.quantity.toStringAsFixed(4),
            palette: palette,
          ),
          if (proposal.executedPrice != null)
            _detailRow(
              label: l10n.etfProposalStatusExecuted,
              value: '\$${proposal.executedPrice!.toStringAsFixed(2)}',
              valueColor: ThemeV2.success,
              palette: palette,
            ),
          _detailRow(
            label: l10n.tradeDateLabel,
            value: _formatDate(context, proposal.createdAt),
            palette: palette,
            isLast:
                (proposal.justification == null ||
                    proposal.justification!.isEmpty) &&
                (proposal.rejectionReason == null ||
                    proposal.rejectionReason!.isEmpty) &&
                !proposal.flaggedRisky,
          ),
          if (proposal.justification != null &&
              proposal.justification!.isNotEmpty) ...[
            const SizedBox(height: 4),
            Text(
              proposal.justification!,
              style: GoogleFonts.inter(fontSize: 12, color: palette.textBody),
            ),
          ],
          if (proposal.rejectionReason != null &&
              proposal.rejectionReason!.isNotEmpty) ...[
            const SizedBox(height: 8),
            Text(
              proposal.rejectionReason!,
              style: GoogleFonts.inter(
                fontSize: 12,
                fontWeight: FontWeight.w600,
                color: proposalStatusColor(proposal),
              ),
            ),
          ],
          if (proposal.flaggedRisky) ...[
            const SizedBox(height: 8),
            Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(Icons.flag_rounded, size: 13, color: ThemeV2.warning),
                const SizedBox(width: 4),
                Text(
                  l10n.etfProposalFlaggedLabel,
                  style: GoogleFonts.inter(
                    fontSize: 11,
                    fontWeight: FontWeight.w700,
                    color: ThemeV2.warning,
                  ),
                ),
              ],
            ),
          ],
          if (proposal.isPending && (canApprove || canFlagRisk)) ...[
            const SizedBox(height: 16),
            themedDivider(palette, indent: 0, endIndent: 0),
            const SizedBox(height: 12),
            if (canApprove) ...[
              Row(
                children: [
                  Expanded(
                    child: _pairedButton(
                      onPressed: onReject,
                      icon: Icons.close_rounded,
                      label: l10n.etfProposalRejectButton,
                      color: ThemeV2.loss,
                      filled: false,
                    ),
                  ),
                  const SizedBox(width: 10),
                  Expanded(
                    child: _pairedButton(
                      onPressed: onApprove,
                      icon: Icons.check_rounded,
                      label: l10n.etfProposalApproveButton,
                      color: ThemeV2.success,
                      filled: true,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 8),
              _pairedButton(
                onPressed: onRework == null
                    ? null
                    : () => _showReworkDialog(context, l10n, onRework!),
                icon: Icons.undo_rounded,
                label: l10n.etfProposalReworkButton,
                color: ThemeV2.warning,
                filled: false,
              ),
            ],
            if (canFlagRisk && !proposal.flaggedRisky) ...[
              if (canApprove) const SizedBox(height: 8),
              _pairedButton(
                onPressed: onFlag,
                icon: Icons.flag_outlined,
                label: l10n.etfProposalFlagButton,
                color: ThemeV2.warning,
                filled: false,
              ),
            ],
          ],
          if (proposal.isApproved && canExecute) ...[
            const SizedBox(height: 16),
            themedDivider(palette, indent: 0, endIndent: 0),
            const SizedBox(height: 12),
            _pairedButton(
              onPressed: onExecute,
              icon: Icons.play_arrow_rounded,
              label: l10n.etfProposalExecuteButton,
              color: palette.accentPrimary,
              filled: true,
            ),
          ],
        ],
      ),
    );
  }

  String _formatDate(BuildContext context, DateTime d) {
    final date = MaterialLocalizations.of(context).formatMediumDate(d);
    final time = TimeOfDay.fromDateTime(d).format(context);
    return '$date $time';
  }
}
