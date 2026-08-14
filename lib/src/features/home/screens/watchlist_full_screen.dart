import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../../core/theme/theme_v2.dart';
import '../../../core/theme/fomo_shield_theme.dart';
import '../../../core/cache/logo_providers.dart';
import '../../../core/services/gics_sector_mapper.dart';
import '../../../shared/widgets/company_logo.dart';
import '../home_providers.dart';

// ---------------------------------------------------------------------------
// Watchlist Full Screen — All items, one card, My Assets-style rows
// ---------------------------------------------------------------------------

class WatchlistFullScreen extends ConsumerStatefulWidget {
  const WatchlistFullScreen({super.key});

  @override
  ConsumerState<WatchlistFullScreen> createState() =>
      _WatchlistFullScreenState();
}

class _WatchlistFullScreenState extends ConsumerState<WatchlistFullScreen> {
  bool _isNavigating = false;

  Future<void> _navigateToSearch() async {
    if (_isNavigating) return;
    setState(() => _isNavigating = true);
    await context.push('/search');
    if (mounted) setState(() => _isNavigating = false);
  }

  @override
  Widget build(BuildContext context) {
    final watchlistSymbols = ref.watch(watchlistSymbolsProvider);

    return Scaffold(
      backgroundColor: Colors.transparent,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        centerTitle: true,
        title: Text(
          'WATCHLIST',
          style: GoogleFonts.inter(
            fontSize: 20,
            fontWeight: FontWeight.w800,
            color: ThemeV2.primary,
            letterSpacing: 1.5,
          ),
        ),
      ),
      body: watchlistSymbols.isEmpty
          ? _emptyState()
          : SingleChildScrollView(
              padding: const EdgeInsets.fromLTRB(16, 8, 16, 32),
              child: Column(
                children: [
                  Container(
                    decoration: FomoShieldTheme.cardDecoration,
                    clipBehavior: Clip.antiAlias,
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Padding(
                          padding: const EdgeInsets.fromLTRB(22, 14, 22, 14),
                          child: Row(
                            children: [
                              Text(
                                'WATCHLIST',
                                style: FomoShieldTheme.cardTitle(),
                              ),
                              const Spacer(),
                              InkWell(
                                onTap: _isNavigating ? null : _navigateToSearch,
                                borderRadius: BorderRadius.circular(20),
                                child: const Icon(
                                  Icons.add_rounded,
                                  color: ThemeV2.primary,
                                  size: 22,
                                ),
                              ),
                            ],
                          ),
                        ),
                        Divider(
                          height: 1,
                          indent: 16,
                          endIndent: 16,
                          color: Colors.black.withValues(alpha: 0.06),
                        ),
                        for (int i = 0; i < watchlistSymbols.length; i++)
                          _WatchlistRow(
                            key: ValueKey(watchlistSymbols[i]),
                            symbol: watchlistSymbols[i],
                            showDivider: i < watchlistSymbols.length - 1,
                          ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
    );
  }

  Widget _emptyState() {
    return Center(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(
            Icons.visibility_off_rounded,
            color: ThemeV2.textSecondary,
            size: 48,
          ),
          const SizedBox(height: 12),
          Text(
            'No companies yet',
            style: GoogleFonts.inter(
              fontSize: 16,
              fontWeight: FontWeight.w600,
              color: ThemeV2.textPrimary,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            'Tap + to search and add companies',
            style: GoogleFonts.inter(
              fontSize: 13,
              color: ThemeV2.textSecondary,
            ),
          ),
          const SizedBox(height: 24),
          ElevatedButton.icon(
            onPressed: _isNavigating ? null : _navigateToSearch,
            icon: const Icon(Icons.search_rounded, size: 18),
            label: const Text('Search companies'),
          ),
        ],
      ),
    );
  }
}

// ---------------------------------------------------------------------------
// Watchlist Row — logo, name + sector, no live price (see cachedLogoEntryProvider
// doc comment: no Finnhub call ever happens from this row — price only shows
// once the user taps through to Company Detail).
// ---------------------------------------------------------------------------

class _WatchlistRow extends ConsumerWidget {
  final String symbol;
  final bool showDivider;

  const _WatchlistRow({
    super.key,
    required this.symbol,
    required this.showDivider,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final logoEntry = ref.watch(cachedLogoEntryProvider(symbol)).valueOrNull;
    final name = logoEntry?.companyName.isNotEmpty == true
        ? logoEntry!.companyName
        : symbol;
    final sector = resolveGicsSector(
      symbol,
      companyName: logoEntry?.companyName,
    );

    return GestureDetector(
      onTap: () => context.push('/company/$symbol'),
      behavior: HitTestBehavior.opaque,
      child: Container(
        height: 60,
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
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
              child: CompanyLogo(
                ticker: symbol,
                logoUrl: logoEntry?.logoUrl,
                domain: logoEntry?.domain,
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
                      color: ThemeV2.textPrimary,
                    ),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    sector?.label ?? symbol,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: GoogleFonts.inter(
                      fontSize: 11,
                      color: ThemeV2.textSecondary,
                    ),
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
