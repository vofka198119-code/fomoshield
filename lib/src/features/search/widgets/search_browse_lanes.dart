import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../../core/theme/theme_v2.dart';
import '../../../core/services/gics_sector_mapper.dart';
import '../../../shared/widgets/stagger_fade_in.dart';
import '../recently_viewed_provider.dart';
import '../top_companies_provider.dart';
import 'browse_lane.dart';
import 'company_list_sheet.dart';
import 'company_mini_card.dart';
import '../../../l10n/gen/app_localizations.dart';

// ---------------------------------------------------------------------------
// Browse Lanes — shown on the empty-query state. "TOP S&P 500" + per-sector
// lanes are real, backend-ranked data (topCompaniesProvider — quarterly
// Wikipedia+Finnhub job, see scanco-backend's sp500Service.js, now the full
// ranked S&P 500, not just a top-47 slice), grouped client-side by real GICS
// sector via resolveGicsSector(). Each lane previews 4 companies — no live
// price anywhere here (see CompanyMiniCard) — with a chevron that opens the
// full list via [showCompanyListSheet]. Recently Viewed is separately real —
// see recently_viewed_provider and company_detail_screen.dart's ref.listen
// that records each view.
// ---------------------------------------------------------------------------

const _lanePreviewCount = 6;

// Lanes cascade in over a ~2s total window (matches roughly how long it
// takes to scroll to the bottom) instead of a flat per-lane delay that
// would keep growing with the sector count — see StaggerFadeIn's
// anchorTime/maxDelay.
const _laneStaggerStep = Duration(milliseconds: 150);
const _laneStaggerCap = Duration(milliseconds: 1800);

class SearchBrowseLanes extends ConsumerStatefulWidget {
  final void Function(String symbol) onTapSymbol;

  const SearchBrowseLanes({super.key, required this.onTapSymbol});

  @override
  ConsumerState<SearchBrowseLanes> createState() => _SearchBrowseLanesState();
}

class _SearchBrowseLanesState extends ConsumerState<SearchBrowseLanes> {
  final _revealAnchor = DateTime.now();

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final recentlyViewed = ref.watch(recentlyViewedProvider);
    final topCompanies = ref.watch(topCompaniesProvider);

    return topCompanies.when(
      loading: () => const Center(
        child: CircularProgressIndicator(color: ThemeV2.primary),
      ),
      error: (err, _) => Center(
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Text(
            l10n.searchTopCompaniesLoadError,
            textAlign: TextAlign.center,
            style: GoogleFonts.inter(
              color: ThemeV2.textSecondary,
              fontSize: 13,
            ),
          ),
        ),
      ),
      data: (companies) {
        if (companies.isEmpty) {
          return Center(
            child: Padding(
              padding: const EdgeInsets.all(24),
              child: Text(
                l10n.searchTopCompaniesBuilding,
                textAlign: TextAlign.center,
                style: GoogleFonts.inter(
                  color: ThemeV2.textSecondary,
                  fontSize: 13,
                ),
              ),
            ),
          );
        }

        final bySector = <GicsSector, List<TopCompanyEntry>>{};
        for (final c in companies) {
          final sector = resolveGicsSector(c.symbol);
          if (sector == null) continue;
          bySector.putIfAbsent(sector, () => []).add(c);
        }

        // One BrowseLane per list item so ListView.separated only builds
        // (and only fires each card's logo fetch) for lanes actually
        // scrolled into view — building all ~10 lanes eagerly in one Column
        // was firing ~50+ simultaneous network calls on open.
        final lanes = <BrowseLane>[
          BrowseLane(
            title: l10n.searchTopSp500,
            items: _cards(companies.take(_lanePreviewCount).toList()),
            onSeeAll: () => showCompanyListSheet(
              context,
              l10n.searchTopSp500,
              companies,
              onTapSymbol: widget.onTapSymbol,
            ),
          ),
          for (final sector in GicsSector.values)
            if (bySector[sector] != null)
              BrowseLane(
                title: sector.localizedLabel(l10n).toUpperCase(),
                items: _cards(
                  bySector[sector]!.take(_lanePreviewCount).toList(),
                ),
                onSeeAll: () => showCompanyListSheet(
                  context,
                  sector.localizedLabel(l10n).toUpperCase(),
                  bySector[sector]!,
                  onTapSymbol: widget.onTapSymbol,
                ),
              ),
          if (recentlyViewed.isNotEmpty)
            BrowseLane(
              title: l10n.searchRecentlyViewed,
              items: _cards(
                recentlyViewed
                    .take(_lanePreviewCount)
                    .map(
                      (e) => TopCompanyEntry(
                        symbol: e.symbol,
                        name: e.name,
                        marketCap: 0,
                      ),
                    )
                    .toList(),
              ),
              onSeeAll: recentlyViewed.length > _lanePreviewCount
                  ? () => showCompanyListSheet(
                      context,
                      l10n.searchRecentlyViewed,
                      recentlyViewed
                          .map(
                            (e) => TopCompanyEntry(
                              symbol: e.symbol,
                              name: e.name,
                              marketCap: 0,
                            ),
                          )
                          .toList(),
                      onTapSymbol: widget.onTapSymbol,
                    )
                  : null,
            ),
        ];

        return ListView.separated(
          padding: const EdgeInsets.fromLTRB(16, 4, 16, 24),
          itemCount: lanes.length,
          separatorBuilder: (_, _) => const SizedBox(height: 16),
          itemBuilder: (context, i) => StaggerFadeIn(
            index: i,
            anchorTime: _revealAnchor,
            delayPerIndex: _laneStaggerStep,
            maxDelay: _laneStaggerCap,
            child: lanes[i],
          ),
        );
      },
    );
  }

  List<CompanyMiniCard> _cards(List<TopCompanyEntry> data) {
    return [
      for (int i = 0; i < data.length; i++)
        CompanyMiniCard(
          symbol: data[i].symbol,
          name: data[i].name,
          onTap: () => widget.onTapSymbol(data[i].symbol),
          showDivider: i < data.length - 1,
        ),
    ];
  }
}
