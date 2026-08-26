import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../../core/cache/logo_providers.dart';
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
// Logo/sector resolution: if the caller already has a URL, pass it in
// directly. Otherwise this reads cachedLogoProvider/cachedGicsSectorProvider
// — cache-first, live Finnhub fetch on a miss — falling back to a letter
// avatar / resolveGicsSector's static table only while that fetch is in
// flight or genuinely fails. This data is shared across every user (same
// ticker, same logo/sector for everyone), so a fetch here warms the
// backend's persistent profile cache once and every other device benefits
// from it forever — cost scales with the S&P 500 catalog, not with user
// count (see feedback_finnhub_cost_at_scale memory's shared-list exception).
// Switched back from the cache-only quickLogoProvider/quickGicsSectorProvider
// 2026-08-26: that avoided a genuine ~60-simultaneous-fetch burst on 2026-08-22,
// but left rows stuck showing CompanyLogo's generic ticker-CDN fallback (often
// a stale/wrong logo) until the user opened that exact company's card. The
// burst risk it was guarding against is now covered at the network layer —
// finnhub_service.dart's _ConcurrencyLimiter (max 4 in flight) + in-flight
// dedup, plus the backend's persistent profileCache (survives restarts) — so
// there's no need to also block it here.
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
                  child: logoUrl != null
                      ? CompanyLogo(
                          ticker: symbol,
                          logoUrl: logoUrl,
                          radius: 18,
                        )
                      : Consumer(
                          builder: (context, ref, _) {
                            final resolved = ref
                                .watch(cachedLogoProvider(symbol))
                                .valueOrNull;
                            return CompanyLogo(
                              ticker: symbol,
                              logoUrl: resolved,
                              radius: 18,
                            );
                          },
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
                              .watch(cachedGicsSectorProvider(symbol))
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
