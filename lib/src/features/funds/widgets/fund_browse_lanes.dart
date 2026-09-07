import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../../../core/theme/app_palette.dart';
import '../../../l10n/gen/app_localizations.dart';
import '../../search/widgets/browse_lane.dart';
import '../models/fund.dart';
import '../sector_labels.dart';
import 'fund_mini_card.dart';

// ---------------------------------------------------------------------------
// Funds Browse Lanes — the Funds tab's empty-query state (mirrors
// search_browse_lanes.dart's own lanes for Companies, reusing the same
// BrowseLane shell — see its doc comment). Three real, present-data lanes:
//
//   - Top by capitalization (aum, already computed server-side)
//   - New this week (createdAt within the last 7 days)
//   - One lane per sector a fund actually declared (sectors are a mandatory
//     multi-select at creation — etfCreateFundSelectAtLeastOneSector — so,
//     unlike Companies' GICS mapper, there's no "unclassified" bucket to
//     worry about; a fund can legitimately appear in more than one lane)
//
// Deliberately NOT here yet: "Popular" (by distinct investor count) and
// "Most traded" (by transaction volume) — both need real investor/trade
// data that doesn't exist until Phase 2 (buy/sell fund units) ships. Adding
// either now would just be a fake number. Tracked in
// fomoshield_etf_implementation_plan_2026_09_06 memory as a Phase 2 TODO —
// see that file before starting Phase 2.
// ---------------------------------------------------------------------------

const _lanePreviewCount = 6;
const _seeAllLimit = 30;

class FundBrowseLanes extends StatelessWidget {
  final List<Fund> funds;
  final AppPalette palette;
  final void Function(Fund fund) onTapFund;

  const FundBrowseLanes({
    super.key,
    required this.funds,
    required this.palette,
    required this.onTapFund,
  });

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;

    final byCap = [...funds]..sort((a, b) => b.aum.compareTo(a.aum));

    final weekAgo = DateTime.now().subtract(const Duration(days: 7));
    final newThisWeek =
        funds.where((f) => f.createdAt.isAfter(weekAgo)).toList()
          ..sort((a, b) => b.createdAt.compareTo(a.createdAt));

    final bySector = <String, List<Fund>>{};
    for (final f in funds) {
      for (final s in f.sectors) {
        bySector.putIfAbsent(s, () => []).add(f);
      }
    }

    final lanes = <Widget>[
      BrowseLane(
        title: l10n.etfFundsTopByCap,
        items: _cards(byCap.take(_lanePreviewCount).toList()),
        palette: palette,
        onSeeAll: byCap.length > _lanePreviewCount
            ? () => _openList(
                context,
                l10n.etfFundsTopByCap,
                byCap.take(_seeAllLimit).toList(),
              )
            : null,
      ),
      if (newThisWeek.isNotEmpty)
        BrowseLane(
          title: l10n.etfFundsNewThisWeek,
          items: _cards(newThisWeek.take(_lanePreviewCount).toList()),
          palette: palette,
          onSeeAll: newThisWeek.length > _lanePreviewCount
              ? () => _openList(
                  context,
                  l10n.etfFundsNewThisWeek,
                  newThisWeek.take(_seeAllLimit).toList(),
                )
              : null,
        ),
      for (final code in allowedSectorCodes(l10n))
        if (bySector[code] != null)
          BrowseLane(
            title: sectorLabel(l10n, code).toUpperCase(),
            items: _cards(bySector[code]!.take(_lanePreviewCount).toList()),
            palette: palette,
            onSeeAll: bySector[code]!.length > _lanePreviewCount
                ? () => _openList(
                    context,
                    sectorLabel(l10n, code).toUpperCase(),
                    bySector[code]!,
                  )
                : null,
          ),
    ];

    return ListView.separated(
      padding: const EdgeInsets.fromLTRB(16, 4, 16, 24),
      itemCount: lanes.length,
      separatorBuilder: (_, _) => const SizedBox(height: 16),
      itemBuilder: (context, i) => lanes[i],
    );
  }

  void _openList(BuildContext context, String title, List<Fund> list) {
    context.push(
      '/funds/list',
      extra: {'title': title, 'funds': list, 'onTapFund': onTapFund},
    );
  }

  List<FundMiniCard> _cards(List<Fund> data) {
    return [
      for (int i = 0; i < data.length; i++)
        FundMiniCard(
          fund: data[i],
          palette: palette,
          onTap: () => onTapFund(data[i]),
          showDivider: i < data.length - 1,
        ),
    ];
  }
}
