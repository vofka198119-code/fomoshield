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

// The "TOP S&P 500" lane's own "see all" used to hand company_list_sheet
// all ~500 ranked constituents at once — opening it fired a burst of
// concurrent profile/logo fetches for every row scrolled into view,
// hitting the backend's per-client rate limit within a second on a cold
// cache. Real users don't need all 500 in one flat list anyway — the
// per-sector lanes below already cover the full roster, dosed out lane by
// lane instead of in one 500-row dump.
const _topSp500Limit = 30;

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
        // Companies resolveGicsSector can't place in any of the 11 GICS
        // sectors (mid/small-cap names outside CompanyTagMapper's curated
        // table — ~236 of the 502 real S&P 500 constituents, spot-checked
        // 2026-08-22) used to just vanish from every lane instead of
        // showing up in the sector they'd normally belong to — real stocks
        // here, not ETFs/crypto (the other null case), so "unclassified"
        // beats "invisible". Collected into its own OTHER lane below.
        final unclassified = <TopCompanyEntry>[];
        for (final c in companies) {
          final sector = resolveGicsSector(c.symbol);
          if (sector == null) {
            unclassified.add(c);
            continue;
          }
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
              companies.take(_topSp500Limit).toList(),
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
          if (unclassified.isNotEmpty)
            BrowseLane(
              title: l10n.searchOtherSector,
              items: _cards(unclassified.take(_lanePreviewCount).toList()),
              onSeeAll: () => showCompanyListSheet(
                context,
                l10n.searchOtherSector,
                unclassified,
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
