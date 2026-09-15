import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../../core/theme/app_palette.dart';
import '../../../core/theme/theme_v2.dart';
import '../../../core/theme/theme_variant_provider.dart';
import '../../../core/theme/themed_header.dart';
import '../../../core/supabase/supabase_providers.dart';
import '../../../l10n/gen/app_localizations.dart';
import '../models/trade_proposal.dart';
import '../providers/employee_providers.dart';
import '../providers/fund_providers.dart';
import '../services/fund_api_service.dart' show FundApiException;
import '../widgets/proposal_card.dart';

// ---------------------------------------------------------------------------
// Proposal Detail — one trade proposal, full screen. Reached from
// FundBlotterScreen's own rows -- NOT auto-opened after submitting a new
// proposal via FundTradeEntryScreen, which pops straight back to wherever
// it was opened from instead (2026-09-12 ask, still the rule as of the
// 2026-09-15 rebuild: opening a second view of the exact same data right
// after submitting read as a duplicate). Same ProposalCard as the blotter
// list, just alone on its own screen.
// ---------------------------------------------------------------------------

class ProposalDetailScreen extends ConsumerStatefulWidget {
  final TradeProposal proposal;

  const ProposalDetailScreen({super.key, required this.proposal});

  @override
  ConsumerState<ProposalDetailScreen> createState() =>
      _ProposalDetailScreenState();
}

class _ProposalDetailScreenState extends ConsumerState<ProposalDetailScreen> {
  late TradeProposal _proposal;

  @override
  void initState() {
    super.initState();
    _proposal = widget.proposal;
  }

  // [alsoInvalidateFundData] covers approve AND execute -- approve alone
  // can move holdings/cash too: fundTradeService.js auto-executes on
  // approval whenever the fund has no Trader hired ("если Trader не нанят
  // — одобрение сразу отправляет ордер в исполнение"), so a plain approve
  // isn't always the holdings-neutral action it looks like. Without this,
  // Fund Holdings/Asset Allocation/Balance/Commission charts kept showing
  // pre-trade data until the user manually left and re-opened the screen
  // (autoDispose only refetches on a fresh watch) -- confirmed on-device
  // 2026-09-14. Balance/commission history are invalidated by their bare
  // family reference (every cached year, not just the one currently
  // selected on Fund Charts -- that screen's own _selectedYear isn't
  // reachable from here).
  Future<void> _act(
    Future<TradeProposal> Function() action,
    AppLocalizations l10n, {
    bool alsoInvalidateFundData = false,
  }) async {
    try {
      final updated = await action();
      ref.invalidate(fundProposalsProvider(_proposal.fundId));
      if (alsoInvalidateFundData) {
        ref.invalidate(fundDetailProvider(_proposal.fundId));
        ref.invalidate(fundBalanceHistoryProvider);
        ref.invalidate(fundCommissionHistoryProvider);
      }
      if (!mounted) return;
      setState(() => _proposal = updated);
    } on FundApiException catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(e.message), backgroundColor: ThemeV2.loss),
      );
    } catch (_) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(l10n.etfProposalActionError),
          backgroundColor: ThemeV2.loss,
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final palette = resolveAppPalette(ref.watch(themeVariantProvider));
    final fundId = _proposal.fundId;
    final fundAsync = ref.watch(fundDetailProvider(fundId));
    final teamAsync = ref.watch(fundTeamProvider(fundId));
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
          _proposal.symbol,
          palette,
          GoogleFonts.inter(
            fontSize: 18,
            fontWeight: FontWeight.w800,
            letterSpacing: 1,
          ),
        ),
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(20),
          child: ProposalCard(
            proposal: _proposal,
            palette: palette,
            l10n: l10n,
            canApprove: canApprove,
            canFlagRisk: canFlagRisk,
            canExecute: canExecute,
            onApprove: () => _act(
              () => ref
                  .read(fundApiServiceProvider)
                  .approveProposal(fundId, _proposal.id),
              l10n,
              alsoInvalidateFundData: true,
            ),
            onReject: () => _act(
              () => ref
                  .read(fundApiServiceProvider)
                  .rejectProposal(fundId, _proposal.id),
              l10n,
            ),
            onRework: (reason) => _act(
              () => ref
                  .read(fundApiServiceProvider)
                  .reworkProposal(fundId, _proposal.id, reason: reason),
              l10n,
            ),
            onFlag: () => _act(
              () => ref
                  .read(fundApiServiceProvider)
                  .flagProposal(fundId, _proposal.id),
              l10n,
            ),
            onExecute: () => _act(
              () => ref
                  .read(fundApiServiceProvider)
                  .executeProposal(fundId, _proposal.id),
              l10n,
              alsoInvalidateFundData: true,
            ),
          ),
        ),
      ),
    );
  }
}
