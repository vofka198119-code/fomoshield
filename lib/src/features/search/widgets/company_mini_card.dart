import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../../core/cache/logo_providers.dart';
import '../../../core/cache/sector_providers.dart';
import '../../../core/services/gics_sector_mapper.dart';
import '../../../core/theme/theme_v2.dart';
import '../../../shared/widgets/company_logo.dart';

// ---------------------------------------------------------------------------
// CompanyMiniCard — one row inside a browse lane (Search screen)
// ---------------------------------------------------------------------------
// Full-width row, same visual as watchlist_full_screen.dart's _WatchlistRow:
// logo ring, name + sector stacked to the right, trailing chevron, thin
// bottom divider between rows. Lanes stack these vertically instead of
// scrolling horizontally.
//
// Logo resolution: if the caller already has a URL (e.g. from a live search
// result), pass it in directly. Otherwise this falls back to the same
// permanent on-device logo cache the rest of the app uses (LogoDao via
// cachedLogoProvider) — a known ticker like AAPL resolves instantly from
// cache with no network call.
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

  const CompanyMiniCard({
    super.key,
    required this.symbol,
    required this.name,
    this.logoUrl,
    this.onTap,
    this.showDivider = false,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      behavior: HitTestBehavior.opaque,
      child: Container(
        height: 60,
        padding: const EdgeInsets.symmetric(horizontal: 22, vertical: 6),
        decoration: showDivider
            ? BoxDecoration(
                border: Border(
                  bottom: BorderSide(
                    color: Colors.black.withValues(alpha: 0.06),
                    width: 0.5,
                  ),
                ),
              )
            : null,
        child: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(2),
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                border: Border.all(color: ThemeV2.primary, width: 1.5),
              ),
              child: logoUrl != null
                  ? CompanyLogo(ticker: symbol, logoUrl: logoUrl, radius: 18)
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
                      color: ThemeV2.textPrimary,
                    ),
                  ),
                  const SizedBox(height: 2),
                  Consumer(
                    builder: (context, ref, _) {
                      final liveSector = ref
                          .watch(cachedGicsSectorProvider(symbol))
                          .valueOrNull;
                      final sector =
                          liveSector ??
                          resolveGicsSector(symbol, companyName: name);
                      return Text(
                        sector?.label ?? symbol,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: GoogleFonts.inter(
                          fontSize: 11,
                          color: ThemeV2.textSecondary,
                        ),
                      );
                    },
                  ),
                ],
              ),
            ),
            const SizedBox(width: 8),
            const Icon(
              Icons.chevron_right_rounded,
              color: ThemeV2.textSecondary,
              size: 20,
            ),
          ],
        ),
      ),
    );
  }
}
