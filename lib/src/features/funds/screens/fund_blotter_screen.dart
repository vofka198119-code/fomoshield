import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../../core/theme/app_palette.dart';
import '../../../core/theme/theme_variant_provider.dart';
import '../../../core/theme/themed_header.dart';
import '../../../l10n/gen/app_localizations.dart';
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
// Blotter is view/act-only -- proposing a new trade now happens exclusively
// via Fund Management's "Trading" shortcut (search a company, then
// Buy/Sell from its fund-context Company Detail page), not from a "+"
// button here (removed 2026-09-15 once that replacement flow existed --
// see fomoshield_etf_fund_trading_card_plan memory for why the old
// standalone form stuck around until then).
//
// Status filter chips added 2026-09-15 (last item of that same plan): a
// horizontal ChoiceChip row (All + each real status), plus a standing sort
// rule independent of whichever filter is active -- pending proposals
// (awaiting a decision) always float to the top, since those are the ones
// that actually need someone's attention right now. Reuses
// proposal_card.dart's own proposalStatusLabel/Color helpers (refactored
// to take a raw status string instead of a TradeProposal) so the chip
// labels/colors are guaranteed to match the status badge already shown on
// every row and on Proposal Detail -- no separate wording to keep in sync.
// ---------------------------------------------------------------------------

// Lifecycle-ish ordering for the filter row: actionable statuses first,
// terminal ones last.
const _statusFilterOrder = [
  'pending',
  'needs_revision',
  'approved',
  'executed',
  'rejected',
];

class FundBlotterScreen extends ConsumerStatefulWidget {
  final String fundId;

  const FundBlotterScreen({super.key, required this.fundId});

  @override
  ConsumerState<FundBlotterScreen> createState() => _FundBlotterScreenState();
}

class _FundBlotterScreenState extends ConsumerState<FundBlotterScreen> {
  // Null means "All".
  String? _statusFilter;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final palette = resolveAppPalette(ref.watch(themeVariantProvider));
    final proposalsAsync = ref.watch(fundProposalsProvider(widget.fundId));

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
      ),
      body: SafeArea(
        child: Column(
          children: [
            _filterRow(l10n, palette),
            Expanded(
              child: proposalsAsync.when(
                loading: () => Center(
                  child: CircularProgressIndicator(
                    color: palette.accentPrimary,
                  ),
                ),
                error: (_, _) => Center(
                  child: Text(
                    l10n.etfFundsListErrorMessage,
                    style: GoogleFonts.inter(color: palette.textBody),
                  ),
                ),
                data: (proposals) {
                  final filtered = _statusFilter == null
                      ? proposals
                      : proposals
                            .where((p) => p.status == _statusFilter)
                            .toList();
                  // Pending-review always floats to the top regardless of
                  // the active filter -- stable partition (not List.sort,
                  // which isn't guaranteed stable) so everything else keeps
                  // whatever order the provider already returned it in.
                  final pending = filtered
                      .where((p) => p.status == 'pending')
                      .toList();
                  final rest = filtered
                      .where((p) => p.status != 'pending')
                      .toList();
                  final sorted = [...pending, ...rest];

                  if (sorted.isEmpty) {
                    return Center(
                      child: Text(
                        _statusFilter == null
                            ? l10n.etfBlotterEmptyText
                            : l10n.etfBlotterEmptyFilteredText,
                        style: GoogleFonts.inter(color: palette.textBody),
                      ),
                    );
                  }
                  return ListView(
                    padding: const EdgeInsets.all(20),
                    children: [
                      for (final proposal in sorted)
                        Padding(
                          padding: const EdgeInsets.only(bottom: 12),
                          child: ProposalListTile(
                            proposal: proposal,
                            palette: palette,
                            l10n: l10n,
                            onTap: () => context.push(
                              '/funds/${widget.fundId}/proposals/detail',
                              extra: proposal,
                            ),
                          ),
                        ),
                    ],
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _filterRow(AppLocalizations l10n, AppPalette palette) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 12, 16, 0),
      child: SingleChildScrollView(
        scrollDirection: Axis.horizontal,
        child: Row(
          children: [
            _chip(l10n.etfBlotterFilterAll, _statusFilter == null, () {
              setState(() => _statusFilter = null);
            }, palette),
            for (final status in _statusFilterOrder) ...[
              const SizedBox(width: 8),
              _chip(proposalStatusLabel(l10n, status), _statusFilter == status, () {
                setState(() => _statusFilter = status);
              }, palette),
            ],
          ],
        ),
      ),
    );
  }

  Widget _chip(
    String label,
    bool selected,
    VoidCallback onTap,
    AppPalette palette,
  ) {
    return ChoiceChip(
      label: Text(label),
      selected: selected,
      onSelected: (_) => onTap(),
      selectedColor: palette.accentPrimary.withValues(alpha: 0.2),
      backgroundColor: palette.card,
      side: BorderSide(color: selected ? palette.accentPrimary : palette.border),
      labelStyle: GoogleFonts.inter(
        fontSize: 12,
        fontWeight: selected ? FontWeight.w700 : FontWeight.w500,
        color: selected ? palette.accentPrimary : palette.textBody,
      ),
    );
  }
}
