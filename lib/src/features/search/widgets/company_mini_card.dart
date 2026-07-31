import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../core/cache/logo_providers.dart';
import '../../../core/theme/theme_v2.dart';
import '../../../core/theme/typography_helpers.dart';
import '../../../shared/widgets/company_logo.dart';

// ---------------------------------------------------------------------------
// CompanyMiniCard — one entry inside a horizontal browse lane (Search screen)
// ---------------------------------------------------------------------------
// Logo ring style matches watchlist_full_screen.dart's list rows.
//
// Logo resolution: if the caller already has a URL (e.g. from a live search
// result), pass it in directly. Otherwise this falls back to the same
// permanent on-device logo cache the rest of the app uses (LogoDao via
// cachedLogoProvider) — a known ticker like AAPL resolves instantly from
// cache with no network call.
//
// No price here, by design — a lane full of these cards must never trigger
// a live quote per card (that's what blew through Finnhub's rate limit).
// Price only shows once the user taps into the company card.

class CompanyMiniCard extends StatelessWidget {
  final String symbol;
  final String name;
  final String? logoUrl;
  final VoidCallback? onTap;

  const CompanyMiniCard({
    super.key,
    required this.symbol,
    required this.name,
    this.logoUrl,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: SizedBox(
        width: 76,
        child: Column(
          children: [
            Container(
              padding: const EdgeInsets.all(2),
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                border: Border.all(color: ThemeV2.primary, width: 1.5),
              ),
              child: logoUrl != null
                  ? CompanyLogo(ticker: symbol, logoUrl: logoUrl, radius: 22)
                  : Consumer(
                      builder: (context, ref, _) {
                        final resolved = ref
                            .watch(cachedLogoProvider(symbol))
                            .valueOrNull;
                        return CompanyLogo(
                          ticker: symbol,
                          logoUrl: resolved,
                          radius: 22,
                        );
                      },
                    ),
            ),
            const SizedBox(height: 6),
            Text(
              symbol,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: interNums(
                fontSize: 12,
                fontWeight: FontWeight.w700,
                color: ThemeV2.textPrimary,
              ),
            ),
            Text(
              name,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              textAlign: TextAlign.center,
              style: TextStyle(fontSize: 10, color: ThemeV2.textSecondary),
            ),
          ],
        ),
      ),
    );
  }
}
