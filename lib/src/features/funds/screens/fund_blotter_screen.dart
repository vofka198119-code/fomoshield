import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../../core/theme/app_palette.dart';
import '../../../core/theme/theme_v2.dart';
import '../../../core/theme/theme_variant_provider.dart';
import '../../../core/theme/themed_header.dart';
import '../../../core/supabase/supabase_providers.dart';
import '../../../l10n/gen/app_localizations.dart';
import '../providers/employee_providers.dart';
import '../providers/fund_providers.dart';
import '../services/fund_api_service.dart' show FundApiException;
import '../widgets/proposal_card.dart';

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
//
// "Propose" is its own full screen now (propose_trade_screen.dart), not a
// bottom sheet -- the sheet version lagged noticeably typing into its
// typeahead field (2026-09-12). Rows here push into ProposalDetailScreen
// (proposal_card.dart's ProposalCard is shared by both).
// ---------------------------------------------------------------------------

class FundBlotterScreen extends ConsumerWidget {
  final String fundId;

  const FundBlotterScreen({super.key, required this.fundId});

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
              onPressed: () => context.push('/funds/$fundId/propose'),
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
                        child: ProposalCard(
                          proposal: proposal,
                          palette: palette,
                          l10n: l10n,
                          canApprove: canApprove,
                          canFlagRisk: canFlagRisk,
                          canExecute: canExecute,
                          onTap: () => context.push(
                            '/funds/$fundId/proposals/detail',
                            extra: proposal,
                          ),
                          onApprove: () => _act(
                            context,
                            ref,
                            () => ref
                                .read(fundApiServiceProvider)
                                .approveProposal(fundId, proposal.id),
                            l10n,
                          ),
                          onReject: () => _act(
                            context,
                            ref,
                            () => ref
                                .read(fundApiServiceProvider)
                                .rejectProposal(fundId, proposal.id),
                            l10n,
                          ),
                          onFlag: () => _act(
                            context,
                            ref,
                            () => ref
                                .read(fundApiServiceProvider)
                                .flagProposal(fundId, proposal.id),
                            l10n,
                          ),
                          onExecute: () => _act(
                            context,
                            ref,
                            () => ref
                                .read(fundApiServiceProvider)
                                .executeProposal(fundId, proposal.id),
                            l10n,
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
