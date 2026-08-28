import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../../core/cache/sector_providers.dart';
import '../../../core/services/gics_sector_mapper.dart';
import '../../../core/theme/app_palette.dart';
import '../../../core/theme/themed_divider.dart';
import '../../../shared/widgets/company_logo.dart';

// ---------------------------------------------------------------------------
// CompanyMiniCard — one row inside a browse lane (Search screen)
// ---------------------------------------------------------------------------
// Full-width row, same visual as watchlist_full_screen.dart's _WatchlistRow:
// logo ring, name + sector stacked to the right, trailing chevron, thin
// bottom divider between rows. Lanes stack these vertically instead of
// scrolling horizontally.
//
// Logo: CompanyLogo resolves it on its own now (via cachedLogoProvider,
// which goes through our backend's /icons endpoint — never Finnhub
// directly from the client) whenever this doesn't pass an explicit
// logoUrl, so there's nothing to wire up here for it.
//
// Sector: cache-only (quickGicsSectorProvider) — falls back to
// resolveGicsSector's static table on a miss rather than firing a live
// Finnhub call, since (unlike icons) there's no safe backend endpoint for
// sector yet. Was briefly switched to the live-fetching
// cachedGicsSectorProvider 2026-08-26 to fix stale icons, but that
// provider fetches sector via the exact same Finnhub profile call as the
// old logo path (SectorRepository.loadSector -> LogoRepository.loadLogo)
// — reverted back here 2026-08-27 once the icon fix above made that
// detour unnecessary; see fomoshield_finnhub_rate_limit_fix_2026_08_22
// memory, round 6.
//
// No price here, by design — a lane full of these rows must never trigger
// a live quote per row (that's what blew through Finnhub's rate limit).
// Price only shows once the user taps into the company card.

class CompanyMiniCard extends StatelessWidget {
  final String symbol;
  final String name;
  final String? logoUrl;
  final VoidCallback? onTap;
  final bool showDivider;
  final AppPalette palette;

  const CompanyMiniCard({
    super.key,
    required this.symbol,
    required this.name,
    required this.palette,
    this.logoUrl,
    this.onTap,
    this.showDivider = false,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        GestureDetector(
          onTap: onTap,
          behavior: HitTestBehavior.opaque,
          child: Container(
            // minHeight (not a hard height) so the row can grow instead of
            // overflowing when the title+sector stack renders taller than
            // this — confirmed happening on a Redmi Note 9S both from RU font
            // metrics at a fixed 60px and, separately, from the OS
            // accessibility text-scale slider.
            constraints: const BoxConstraints(minHeight: 66),
            padding: const EdgeInsets.symmetric(horizontal: 22, vertical: 6),
            child: Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(2),
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    border: Border.all(
                      color: palette.accentPrimary,
                      width: 1.5,
                    ),
                  ),
                  child: CompanyLogo(
                    ticker: symbol,
                    logoUrl: logoUrl,
                    radius: 18,
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text(
                        name,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: GoogleFonts.inter(
                          fontSize: 14,
                          fontWeight: FontWeight.w600,
                          color: palette.textHeader,
                        ),
                      ),
                      const SizedBox(height: 2),
                      Consumer(
                        builder: (context, ref, _) {
                          final cachedSector = ref
                              .watch(quickGicsSectorProvider(symbol))
                              .valueOrNull;
                          final sector =
                              cachedSector ??
                              resolveGicsSector(symbol, companyName: name);
                          return Text(
                            sector?.label ?? symbol,
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                            style: GoogleFonts.inter(
                              fontSize: 11,
                              // Same fix as watchlist_widget.dart's tile —
                              // see its comment.
                              color: palette.titleGradient != null
                                  ? Colors.white.withValues(alpha: 0.85)
                                  : palette.textBody,
                            ),
                          );
                        },
                      ),
                    ],
                  ),
                ),
                const SizedBox(width: 8),
                Icon(
                  Icons.chevron_right_rounded,
                  color: palette.textBody,
                  size: 20,
                ),
              ],
            ),
          ),
        ),
        if (showDivider) themedRowDivider(palette),
      ],
    );
  }
}
