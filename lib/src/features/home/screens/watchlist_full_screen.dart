import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../../core/theme/fomo_shield_theme.dart';
import '../../../core/theme/app_palette.dart';
import '../../../core/theme/theme_variant_provider.dart';
import '../../../core/theme/themed_header.dart';
import '../../../core/theme/themed_divider.dart';
import '../../../shared/widgets/card_frame.dart';
import '../../../core/cache/logo_providers.dart';
import '../../../core/services/gics_sector_mapper.dart';
import '../../../l10n/gen/app_localizations.dart';
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
    final l10n = AppLocalizations.of(context)!;
    final palette = resolveAppPalette(ref.watch(themeVariantProvider));

    return Scaffold(
      backgroundColor: Colors.transparent,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        centerTitle: true,
        leading: themedBackButton(context, palette),
        title: themedHeaderText(
          l10n.watchlistTitle,
          palette,
          GoogleFonts.inter(
            fontSize: 20,
            fontWeight: FontWeight.w800,
            letterSpacing: 1.5,
          ),
        ),
      ),
      body: SafeArea(
        bottom: true,
        top: false,
        left: false,
        right: false,
        child: watchlistSymbols.isEmpty
            ? _emptyState(l10n, palette)
            : SingleChildScrollView(
                padding: const EdgeInsets.fromLTRB(16, 8, 16, 32),
                child: Column(
                  children: [
                    CardFrame(
                      padding: EdgeInsets.zero,
                      decoration: FomoShieldTheme.cardDecoration,
                      palette: palette,
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Padding(
                            padding: const EdgeInsets.fromLTRB(22, 14, 22, 14),
                            child: Row(
                              children: [
                                themedHeaderText(
                                  l10n.watchlistTitle,
                                  palette,
                                  FomoShieldTheme.cardTitle(),
                                ),
                                const Spacer(),
                                InkWell(
                                  onTap: _isNavigating
                                      ? null
                                      : _navigateToSearch,
                                  borderRadius: BorderRadius.circular(20),
                                  child: Icon(
                                    Icons.add_rounded,
                                    color: palette.accentPrimary,
                                    size: 22,
                                  ),
                                ),
                              ],
                            ),
                          ),
                          palette.dividerGradient != null
                              ? themedDivider(palette)
                              : Divider(
                                  height: 1,
                                  indent: 16,
                                  endIndent: 16,
                                  color: Colors.black.withValues(alpha: 0.06),
                                ),
                          // Lazy-built (shrinkWrap over the outer scroll
                          // view still only builds rows near the viewport,
                          // same as ListView.separated elsewhere) — a large
                          // watchlist no longer fires every row's logo/name
                          // fetch in one frame just because it's on screen.
                          ListView.builder(
                            shrinkWrap: true,
                            physics: const NeverScrollableScrollPhysics(),
                            itemCount: watchlistSymbols.length,
                            itemBuilder: (context, i) => _WatchlistRow(
                              key: ValueKey(watchlistSymbols[i]),
                              symbol: watchlistSymbols[i],
                              showDivider: i < watchlistSymbols.length - 1,
                              palette: palette,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
      ),
    );
  }

  Widget _emptyState(AppLocalizations l10n, AppPalette palette) {
    return Center(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(Icons.visibility_off_rounded, color: palette.textBody, size: 48),
          const SizedBox(height: 12),
          Text(
            l10n.watchlistFullScreenEmptyTitle,
            style: GoogleFonts.inter(
              fontSize: 16,
              fontWeight: FontWeight.w600,
              color: palette.textHeader,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            l10n.watchlistFullScreenEmptySubtitle,
            style: GoogleFonts.inter(fontSize: 13, color: palette.textBody),
          ),
          const SizedBox(height: 24),
          ElevatedButton.icon(
            onPressed: _isNavigating ? null : _navigateToSearch,
            icon: const Icon(Icons.search_rounded, size: 18),
            label: Text(l10n.watchlistFullScreenSearchButton),
          ),
        ],
      ),
    );
  }
}

// ---------------------------------------------------------------------------
// Watchlist Row — logo, name + sector, no live price (price only shows once
// the user taps through to Company Detail). Logo/name now live-fetch (see
// watchlist_widget.dart's _WatchlistTile doc comment) — a per-user
// watchlist is a bounded list, same reasoning already applied to Portfolio
// Holdings, and this is the "load the rest" second stage after the Home
// widget's own 2-item preview.
// ---------------------------------------------------------------------------

class _WatchlistRow extends ConsumerWidget {
  final String symbol;
  final bool showDivider;
  final AppPalette palette;

  const _WatchlistRow({
    super.key,
    required this.symbol,
    required this.showDivider,
    required this.palette,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = AppLocalizations.of(context)!;
    final logoUrl = ref.watch(cachedLogoProvider(symbol)).valueOrNull;
    final resolvedName = ref.watch(resolvedCompanyNameProvider(symbol));
    final name = resolvedName.valueOrNull ?? symbol;
    final sector = resolveGicsSector(symbol, companyName: name);

    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        GestureDetector(
          onTap: () => context.push('/company/$symbol'),
          behavior: HitTestBehavior.opaque,
          child: Container(
            // minHeight (not a hard height) so the row can grow instead of
            // overflowing when the title+sector stack renders taller than
            // this — confirmed happening on a Redmi Note 9S both from RU font
            // metrics at a fixed 60px and, separately, from the OS
            // accessibility text-scale slider, same row style as
            // company_mini_card.dart.
            constraints: const BoxConstraints(minHeight: 66),
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
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
                      Text(
                        sector?.localizedLabel(l10n) ?? symbol,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: GoogleFonts.inter(
                          fontSize: 11,
                          // Same fix as watchlist_widget.dart's tile — see
                          // its comment.
                          color: palette.titleGradient != null
                              ? Colors.white.withValues(alpha: 0.85)
                              : palette.textBody,
                        ),
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
