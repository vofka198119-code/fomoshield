import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../../core/theme/fomo_shield_theme.dart';
import '../../../core/theme/theme_v2.dart';
import '../../../core/theme/app_palette.dart';
import '../../../core/theme/theme_variant_provider.dart';
import '../../../core/theme/themed_divider.dart';
import '../../../core/theme/themed_header.dart';
import '../../../core/supabase/supabase_providers.dart';
import '../../../l10n/gen/app_localizations.dart';
import '../../../shared/widgets/card_frame.dart';
import '../models/trade_proposal.dart';
import '../providers/employee_providers.dart';
import '../providers/fund_providers.dart';
import '../services/fund_api_service.dart' show FundApiException;
import '../widgets/propose_trade_sheet.dart';

// ---------------------------------------------------------------------------
// Fund Blotter — Phase 4 (docs/ETF_FUND_EMULATION.md). The "рабочий экран
// профессионала" the design doc names: a live list of trade proposals with
// a status chip per row, not a hero chart. Reached from
// FundManagementScreen's own circle-shortcut row.
//
// Permissions are computed client-side from the SAME source the backend
// checks: isHead (fund.headUserId) OR the caller's own fund_team_members
// permissions row -- there's no dedicated "my permissions" endpoint, this
// mirrors fundTradeService.js's _getPermissions exactly.
// ---------------------------------------------------------------------------

class FundBlotterScreen extends ConsumerWidget {
  final String fundId;

  const FundBlotterScreen({super.key, required this.fundId});

  String _statusLabel(AppLocalizations l10n, TradeProposal p) {
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

  Color _statusColor(TradeProposal p) {
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

  Future<void> _act(
    BuildContext context,
    WidgetRef ref,
    Future<void> Function() action,
    AppLocalizations l10n,
  ) async {
    try {
      await action();
      ref.invalidate(fundProposalsProvider(fundId));
    } on FundApiException catch (e) {
      if (!context.mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(e.message), backgroundColor: ThemeV2.loss),
      );
    } catch (_) {
      if (!context.mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(l10n.etfProposalActionError),
          backgroundColor: ThemeV2.loss,
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = AppLocalizations.of(context)!;
    final palette = resolveAppPalette(ref.watch(themeVariantProvider));
    final fundAsync = ref.watch(fundDetailProvider(fundId));
    final teamAsync = ref.watch(fundTeamProvider(fundId));
    final proposalsAsync = ref.watch(fundProposalsProvider(fundId));
    final currentUserId = ref.watch(currentUserProvider)?.id;

    final isHead = fundAsync.valueOrNull?.headUserId == currentUserId;
    final team = teamAsync.valueOrNull ?? [];
    Map<String, bool>? myPermissions;
    for (final member in team) {
      if (member.userId == currentUserId) {
        myPermissions = member.permissions;
        break;
      }
    }
    final canPropose = isHead || (myPermissions?['canPropose'] ?? false);
    final canApprove = isHead || (myPermissions?['canApprove'] ?? false);
    final canFlagRisk = isHead || (myPermissions?['canFlagRisk'] ?? false);
    final canExecute = isHead || (myPermissions?['canExecute'] ?? false);

    return Scaffold(
      backgroundColor: Colors.transparent,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        centerTitle: true,
        leading: themedBackButton(context, palette),
        title: themedHeaderText(
          l10n.etfBlotterTitle,
          palette,
          GoogleFonts.inter(
            fontSize: 20,
            fontWeight: FontWeight.w800,
            letterSpacing: 1.5,
          ),
        ),
        actions: [
          if (canPropose)
            IconButton(
              icon: Icon(Icons.add_rounded, color: palette.accentPrimary),
              onPressed: () =>
                  showProposeTradeSheet(
                    context: context,
                    ref: ref,
                    fundId: fundId,
                    palette: palette,
                  ),
            ),
        ],
      ),
      body: SafeArea(
        child: proposalsAsync.when(
          loading: () => Center(
            child: CircularProgressIndicator(color: palette.accentPrimary),
          ),
          error: (_, _) => Center(
            child: Text(
              l10n.etfFundsListErrorMessage,
              style: GoogleFonts.inter(color: palette.textBody),
            ),
          ),
          data: (proposals) => proposals.isEmpty
              ? Center(
                  child: Text(
                    l10n.etfBlotterEmptyText,
                    style: GoogleFonts.inter(color: palette.textBody),
                  ),
                )
              : ListView(
                  padding: const EdgeInsets.all(20),
                  children: [
                    for (final proposal in proposals)
                      Padding(
                        padding: const EdgeInsets.only(bottom: 12),
                        child: CardFrame(
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
                                      color:
                                          (proposal.isBuy
                                                  ? ThemeV2.success
                                                  : ThemeV2.loss)
                                              .withValues(alpha: 0.12),
                                      borderRadius: BorderRadius.circular(4),
                                    ),
                                    child: Text(
                                      proposal.isBuy ? l10n.tradeBuy : l10n.tradeSell,
                                      style: GoogleFonts.inter(
                                        fontSize: 9,
                                        fontWeight: FontWeight.w700,
                                        color: proposal.isBuy
                                            ? ThemeV2.success
                                            : ThemeV2.loss,
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
                                      color: _statusColor(
                                        proposal,
                                      ).withValues(alpha: 0.12),
                                      borderRadius: BorderRadius.circular(6),
                                    ),
                                    child: Text(
                                      _statusLabel(l10n, proposal),
                                      style: GoogleFonts.inter(
                                        fontSize: 10,
                                        fontWeight: FontWeight.w700,
                                        color: _statusColor(proposal),
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                              const SizedBox(height: 4),
                              Text(
                                '${proposal.quantity} @ ${proposal.orderType == 'limit' ? proposal.limitPrice?.toStringAsFixed(2) : l10n.etfProposeOrderTypeMarket}',
                                style: GoogleFonts.inter(
                                  fontSize: 12,
                                  color: palette.textBody,
                                ),
                              ),
                              if (proposal.justification != null &&
                                  proposal.justification!.isNotEmpty) ...[
                                const SizedBox(height: 6),
                                Text(
                                  proposal.justification!,
                                  style: GoogleFonts.inter(
                                    fontSize: 12,
                                    color: palette.textBody,
                                  ),
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
                              if (proposal.isPending &&
                                  (canApprove || canFlagRisk)) ...[
                                const SizedBox(height: 10),
                                themedDivider(palette, indent: 0, endIndent: 0),
                                const SizedBox(height: 8),
                                Wrap(
                                  spacing: 8,
                                  children: [
                                    if (canApprove)
                                      TextButton(
                                        onPressed: () => _act(
                                          context,
                                          ref,
                                          () => ref
                                              .read(fundApiServiceProvider)
                                              .approveProposal(
                                                fundId,
                                                proposal.id,
                                              ),
                                          l10n,
                                        ),
                                        child: Text(
                                          l10n.etfProposalApproveButton,
                                          style: TextStyle(color: ThemeV2.success),
                                        ),
                                      ),
                                    if (canApprove)
                                      TextButton(
                                        onPressed: () => _act(
                                          context,
                                          ref,
                                          () => ref
                                              .read(fundApiServiceProvider)
                                              .rejectProposal(
                                                fundId,
                                                proposal.id,
                                              ),
                                          l10n,
                                        ),
                                        child: Text(
                                          l10n.etfProposalRejectButton,
                                          style: const TextStyle(color: ThemeV2.loss),
                                        ),
                                      ),
                                    if (canFlagRisk && !proposal.flaggedRisky)
                                      TextButton(
                                        onPressed: () => _act(
                                          context,
                                          ref,
                                          () => ref
                                              .read(fundApiServiceProvider)
                                              .flagProposal(
                                                fundId,
                                                proposal.id,
                                              ),
                                          l10n,
                                        ),
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
                                  onPressed: () => _act(
                                    context,
                                    ref,
                                    () => ref
                                        .read(fundApiServiceProvider)
                                        .executeProposal(fundId, proposal.id),
                                    l10n,
                                  ),
                                  child: Text(
                                    l10n.etfProposalExecuteButton,
                                    style: TextStyle(color: palette.accentPrimary),
                                  ),
                                ),
                              ],
                            ],
                          ),
                        ),
                      ),
                  ],
                ),
        ),
      ),
    );
  }
}
