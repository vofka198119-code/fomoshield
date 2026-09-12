import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../../core/theme/app_palette.dart';
import '../../../core/theme/theme_variant_provider.dart';
import '../../../core/theme/themed_header.dart';
import '../../../core/supabase/supabase_providers.dart';
import '../../../l10n/gen/app_localizations.dart';
import '../providers/employee_providers.dart';
import '../providers/fund_providers.dart';
import '../widgets/proposal_card.dart';

// ---------------------------------------------------------------------------
// Fund Blotter — Phase 4 (docs/ETF_FUND_EMULATION.md). The "рабочий экран
// профессионала" the design doc names: a live list of trade proposals with
// a status chip per row, not a hero chart. Reached from
// FundManagementScreen's own circle-shortcut row.
//
// Redesigned 2026-09-12 to be a plain identification+status list — no
// action buttons here anymore. Every row (ProposalListTile,
// proposal_card.dart) just names the order side, shows the company +
// status, and pushes into ProposalDetailScreen, which owns the single
// "одно окно большое со всеми подробностями" (modeled on
// PortfolioTradeDetailScreen's "детали сделки") where Approve/Reject/
// Flag/Rework/Execute actually live.
//
// "Propose" is its own full screen (propose_trade_screen.dart), not a
// bottom sheet -- the sheet version lagged noticeably typing into its
// typeahead field (2026-09-12).
// ---------------------------------------------------------------------------

class FundBlotterScreen extends ConsumerWidget {
  final String fundId;

  const FundBlotterScreen({super.key, required this.fundId});

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
                        child: ProposalListTile(
                          proposal: proposal,
                          palette: palette,
                          l10n: l10n,
                          onTap: () => context.push(
                            '/funds/$fundId/proposals/detail',
                            extra: proposal,
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
