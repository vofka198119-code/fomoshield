import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../../core/theme/app_palette.dart';
import '../../../core/theme/themed_divider.dart';
import '../../../l10n/gen/app_localizations.dart';
import '../models/fund.dart';
import '../providers/fund_providers.dart';
import 'fund_browse_lanes.dart';

// ---------------------------------------------------------------------------
// Funds Tab List — the Search screen's "Funds" tab (ETF Fund Emulation).
// Empty query: FundBrowseLanes (top-by-cap / new-this-week / per-sector
// lanes — see its own doc comment, and the Companies tab's identical
// empty-vs-typed split in search_screen.dart's _buildCompaniesResults).
// Non-empty query: flat client-side filtered list — fund counts are small
// enough that a dedicated backend search endpoint isn't worth it yet.
//
// The search FIELD itself lives in search_screen.dart (rendered above the
// Funds/Companies tab labels, alongside the Companies tab's own field —
// see its own doc comment for why), which owns the query string and passes
// it down here as [query].
// ---------------------------------------------------------------------------

class FundsTabList extends ConsumerWidget {
  final AppPalette palette;
  final String query;

  const FundsTabList({super.key, required this.palette, required this.query});

  List<Fund> _filter(List<Fund> funds) {
    if (query.isEmpty) return funds;
    final q = query.toLowerCase();
    return funds
        .where(
          (f) =>
              f.name.toLowerCase().contains(q) ||
              f.ticker.toLowerCase().contains(q),
        )
        .toList();
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = AppLocalizations.of(context)!;
    final fundsAsync = ref.watch(fundsListProvider);

    return fundsAsync.when(
      loading: () => Center(
        child: CircularProgressIndicator(color: palette.accentPrimary),
      ),
      error: (_, _) => Center(
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Text(
            l10n.etfFundsListErrorMessage,
            textAlign: TextAlign.center,
            style: GoogleFonts.inter(color: palette.textBody, fontSize: 14),
          ),
        ),
      ),
      data: (allFunds) {
        if (allFunds.isEmpty) {
          return Center(
            child: Padding(
              padding: const EdgeInsets.all(24),
              child: Text(
                l10n.etfFundsEmptyState,
                textAlign: TextAlign.center,
                style: GoogleFonts.inter(color: palette.textBody, fontSize: 14),
              ),
            ),
          );
        }
        if (query.isEmpty) {
          return FundBrowseLanes(
            funds: allFunds,
            palette: palette,
            onTapFund: (fund) => context.push('/funds/${fund.id}'),
          );
        }
        final funds = _filter(allFunds);
        if (funds.isEmpty) {
          return Center(
            child: Padding(
              padding: const EdgeInsets.all(24),
              child: Text(
                l10n.searchNoResults,
                textAlign: TextAlign.center,
                style: GoogleFonts.inter(color: palette.textBody, fontSize: 14),
              ),
            ),
          );
        }
        return RefreshIndicator(
          color: palette.accentPrimary,
          onRefresh: () async => ref.invalidate(fundsListProvider),
          child: ListView.separated(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            itemCount: funds.length,
            separatorBuilder: (_, _) => palette.dividerGradient != null
                ? themedDivider(palette, indent: 0, endIndent: 0)
                : const Divider(),
            itemBuilder: (context, i) =>
                _FundRow(fund: funds[i], palette: palette),
          ),
        );
      },
    );
  }
}

class _FundRow extends StatelessWidget {
  final Fund fund;
  final AppPalette palette;

  const _FundRow({required this.fund, required this.palette});

  @override
  Widget build(BuildContext context) {
    final up = fund.navPerUnit >= 10.0; // vs. the $10.00 launch NAV
    return ListTile(
      leading: CircleAvatar(
        radius: 20,
        backgroundColor: palette.accentPrimary.withValues(alpha: 0.15),
        child: Text(
          fund.ticker.length > 4 ? fund.ticker.substring(0, 4) : fund.ticker,
          style: GoogleFonts.inter(
            fontSize: 10,
            fontWeight: FontWeight.w800,
            color: palette.accentPrimary,
          ),
        ),
      ),
      title: Text(
        fund.name,
        maxLines: 1,
        overflow: TextOverflow.ellipsis,
        style: GoogleFonts.inter(
          fontSize: 15,
          fontWeight: FontWeight.w600,
          color: palette.textHeader,
        ),
      ),
      subtitle: Text(
        fund.ticker,
        style: GoogleFonts.inter(fontSize: 12, color: palette.textBody),
      ),
      trailing: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        crossAxisAlignment: CrossAxisAlignment.end,
        children: [
          Text(
            '\$${fund.navPerUnit.toStringAsFixed(2)}',
            style: GoogleFonts.inter(
              fontSize: 14,
              fontWeight: FontWeight.w700,
              color: palette.textHeader,
            ),
          ),
          Text(
            up ? '▲' : '▼',
            style: GoogleFonts.inter(
              fontSize: 11,
              color: up ? Colors.green : Colors.red,
            ),
          ),
        ],
      ),
      onTap: () => context.push('/funds/${fund.id}'),
    );
  }
}
