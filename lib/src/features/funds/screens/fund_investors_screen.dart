import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../../core/theme/app_palette.dart';
import '../../../core/theme/fomo_shield_theme.dart';
import '../../../core/theme/theme_v2.dart';
import '../../../core/theme/theme_variant_provider.dart';
import '../../../core/theme/themed_divider.dart';
import '../../../core/theme/themed_header.dart';
import '../../../l10n/gen/app_localizations.dart';
import '../../../shared/widgets/card_frame.dart';
import '../providers/fund_providers.dart';
import '../widgets/fund_investor_flow_chart.dart';
import '../widgets/fund_investors_list_card.dart';
import '../widgets/fund_investors_stats_card.dart';

// ---------------------------------------------------------------------------
// Fund Investors — Phase 2 follow-up (2026-09-13 ask), reached from
// FundManagementScreen's own circle-shortcut row alongside Employees/
// Requests. Four widgets: stats (total invested, investor count,
// bankruptcy payout preview), two monthly inflow/outflow bar charts (year
// picker in each header — "archive by calendar year" per the ask, picking
// a year just re-requests the same endpoint with that year, nothing is
// actually archived server-side), then the sorted investor list. Server-
// gated to head + active team members (not public like the team roster)
// since these are other users' personal $ amounts.
// ---------------------------------------------------------------------------
class FundInvestorsScreen extends ConsumerStatefulWidget {
  final String fundId;

  const FundInvestorsScreen({super.key, required this.fundId});

  @override
  ConsumerState<FundInvestorsScreen> createState() =>
      _FundInvestorsScreenState();
}

class _FundInvestorsScreenState extends ConsumerState<FundInvestorsScreen> {
  late int _selectedYear = DateTime.now().year;

  Future<void> _pickYear(AppPalette palette, int firstYear) async {
    final l10n = AppLocalizations.of(context)!;
    final currentYear = DateTime.now().year;
    final years = [for (var y = currentYear; y >= firstYear; y--) y];

    final picked = await showModalBottomSheet<int>(
      context: context,
      backgroundColor: Colors.transparent,
      builder: (sheetContext) => SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: CardFrame(
            decoration: FomoShieldTheme.cardDecoration,
            palette: palette,
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Center(
                  child: Container(
                    width: 40,
                    height: 4,
                    margin: const EdgeInsets.only(bottom: 14),
                    decoration: BoxDecoration(
                      color: palette.textBody.withValues(alpha: 0.3),
                      borderRadius: BorderRadius.circular(2),
                    ),
                  ),
                ),
                themedHeaderText(
                  l10n.etfInvestorsYearPickerTitle,
                  palette,
                  FomoShieldTheme.cardTitle(),
                ),
                const SizedBox(height: 10),
                themedDivider(palette, indent: 0, endIndent: 0),
                for (final year in years)
                  ListTile(
                    contentPadding: EdgeInsets.zero,
                    title: Text(
                      '$year',
                      style: GoogleFonts.inter(
                        fontSize: 15,
                        fontWeight: year == _selectedYear
                            ? FontWeight.w800
                            : FontWeight.w500,
                        color: year == _selectedYear
                            ? palette.accentPrimary
                            : palette.textHeader,
                      ),
                    ),
                    onTap: () => Navigator.of(sheetContext).pop(year),
                  ),
              ],
            ),
          ),
        ),
      ),
    );
    if (picked != null && picked != _selectedYear) {
      setState(() => _selectedYear = picked);
    }
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final palette = resolveAppPalette(ref.watch(themeVariantProvider));
    final investorsAsync = ref.watch(fundInvestorsProvider(widget.fundId));
    final flowsAsync = ref.watch(
      fundInvestorFlowsProvider((widget.fundId, _selectedYear)),
    );
    final fundAsync = ref.watch(fundDetailProvider(widget.fundId));
    final firstYear = fundAsync.valueOrNull?.createdAt.year ?? _selectedYear;

    return Scaffold(
      backgroundColor: Colors.transparent,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        centerTitle: true,
        leading: themedBackButton(context, palette),
        title: themedHeaderText(
          l10n.etfInvestorsScreenTitle,
          palette,
          GoogleFonts.inter(
            fontSize: 20,
            fontWeight: FontWeight.w800,
            letterSpacing: 1.5,
          ),
        ),
      ),
      body: SafeArea(
        child: investorsAsync.when(
          loading: () => Center(
            child: CircularProgressIndicator(color: palette.accentPrimary),
          ),
          error: (_, _) => Center(
            child: Text(
              l10n.etfFundsListErrorMessage,
              style: GoogleFonts.inter(color: palette.textBody),
            ),
          ),
          data: (investors) => RefreshIndicator(
            color: palette.accentPrimary,
            onRefresh: () async {
              ref.invalidate(fundInvestorsProvider(widget.fundId));
              ref.invalidate(
                fundInvestorFlowsProvider((widget.fundId, _selectedYear)),
              );
            },
            child: ListView(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 20),
              children: [
                FundInvestorsStatsCard(investors: investors, palette: palette),
                const SizedBox(height: 12),
                ...flowsAsync.when(
                  loading: () => const [],
                  error: (_, _) => const [],
                  data: (flows) => [
                    FundInvestorFlowChart(
                      title: l10n.etfInvestorsInflowChartTitle,
                      monthlyValues: flows.inflow,
                      barColor: ThemeV2.success,
                      palette: palette,
                      selectedYear: _selectedYear,
                      onTapYear: () => _pickYear(palette, firstYear),
                    ),
                    const SizedBox(height: 12),
                    FundInvestorFlowChart(
                      title: l10n.etfInvestorsOutflowChartTitle,
                      monthlyValues: flows.outflow,
                      barColor: ThemeV2.loss,
                      palette: palette,
                      selectedYear: _selectedYear,
                      onTapYear: () => _pickYear(palette, firstYear),
                    ),
                    const SizedBox(height: 12),
                  ],
                ),
                FundInvestorsListCard(investors: investors, palette: palette),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
