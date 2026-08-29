import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:go_router/go_router.dart';
import '../../l10n/gen/app_localizations.dart';
import '../../core/cache/logo_providers.dart';
import '../../core/cache/sector_providers.dart';
import '../../core/theme/theme_v2.dart';
import '../../core/theme/app_palette.dart';
import '../../core/theme/theme_variant_provider.dart';
import '../../core/theme/themed_header.dart';
import '../../core/theme/themed_button.dart';
import '../../shared/widgets/card_frame.dart';
import '../../core/supabase/supabase_providers.dart';
import '../../shared/widgets/stagger_fade_in.dart';
import '../home/home_providers.dart';
import '../home/watchlist_limits_provider.dart';
import '../portfolio/portfolio_providers.dart';
import '../monetization/monetization_modal.dart';
import 'watchlist_ad_provider.dart';
import 'company_detail_provider.dart';
import 'company_widget_order_provider.dart';
import 'widgets/price_chart.dart';
import 'widgets/financial_score_widget.dart';
import 'widgets/price_header.dart';
import 'widgets/key_metrics_section.dart';
import 'widgets/position_section.dart';
import 'widgets/limit_orders_section.dart';
import 'widgets/portfolio_option_tile.dart';
import 'widgets/company_widgets_settings_sheet.dart';
import 'widgets/company_encyclopedia_widget.dart';
import 'widgets/company_bottom_bar.dart';
import 'widgets/company_ad_overlay.dart';
import '../search/recently_viewed_provider.dart';

// ---------------------------------------------------------------------------
// Screen
// ---------------------------------------------------------------------------

class CompanyDetailScreen extends ConsumerStatefulWidget {
  final String symbol;
  // Set when navigated here from inside a specific portfolio (e.g. tapping
  // a holding row) so Buy skips the "Select Portfolio" sheet and trades
  // straight into that portfolio. Null means an ambiguous entry point
  // (Search, Watchlist, Recently Viewed) — the picker is the right call
  // there since we don't know which portfolio the user means.
  final String? contextPortfolioId;

  const CompanyDetailScreen({
    super.key,
    required this.symbol,
    this.contextPortfolioId,
  });

  @override
  ConsumerState<CompanyDetailScreen> createState() =>
      _CompanyDetailScreenState();
}

class _CompanyDetailScreenState extends ConsumerState<CompanyDetailScreen> {
  bool _showAd = false;

  @override
  void initState() {
    super.initState();
    _checkAd();
  }

  Future<void> _checkAd() async {
    final tier = ref.read(subscriptionTierProvider);
    // Admin/premium bypass ads entirely
    if (tier.isPremiumOrAdmin) {
      return;
    }
    try {
      final shouldShow = await ref
          .read(watchlistAdProvider.notifier)
          .incrementAndCheck();
      if (mounted) {
        setState(() => _showAd = shouldShow);
      }
    } catch (_) {
      // If ad check fails, just show the data without ad overlay
    }
  }

  void _dismissAd() {
    setState(() => _showAd = false);
  }

  void _showWatchAdOverlay(BuildContext context) {
    Navigator.of(context).push(
      PageRouteBuilder(
        opaque: false,
        barrierColor: Colors.black87,
        barrierDismissible: false,
        pageBuilder: (context, animation, secondaryAnimation) =>
            CompanyAdOverlay(
              onComplete: () {
                if (mounted) _dismissAd();
              },
            ),
        transitionsBuilder: (context, animation, secondaryAnimation, child) {
          return FadeTransition(opacity: animation, child: child);
        },
        transitionDuration: const Duration(milliseconds: 300),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final palette = resolveAppPalette(ref.watch(themeVariantProvider));
    if (_showAd) {
      return Scaffold(
        backgroundColor: Colors.transparent,
        body: Center(
          child: CardFrame(
            margin: const EdgeInsets.all(32),
            padding: const EdgeInsets.all(32),
            decoration: BoxDecoration(
              color: ThemeV2.surface,
              borderRadius: BorderRadius.circular(20),
            ),
            palette: palette,
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(
                  Icons.play_circle_rounded,
                  color: palette.accentPrimary,
                  size: 64,
                ),
                const SizedBox(height: 24),
                Text(
                  l10n.companyDetailSponsoredTitle,
                  style: GoogleFonts.inter(
                    fontSize: 20,
                    fontWeight: FontWeight.w700,
                    color: palette.textHeader,
                  ),
                ),
                const SizedBox(height: 12),
                Text(
                  l10n.companyDetailWatchAdBody,
                  textAlign: TextAlign.center,
                  style: GoogleFonts.inter(
                    fontSize: 14,
                    color: palette.textBody,
                    height: 1.5,
                  ),
                ),
                const SizedBox(height: 32),
                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton(
                    onPressed: () => _showWatchAdOverlay(context),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: ThemeV2.primary,
                      foregroundColor: Colors.white,
                      padding: const EdgeInsets.symmetric(vertical: 16),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(14),
                      ),
                    ),
                    child: Text(
                      l10n.companyDetailWatchAdButton,
                      style: GoogleFonts.inter(
                        fontWeight: FontWeight.w700,
                        fontSize: 15,
                      ),
                    ),
                  ),
                ),
                const SizedBox(height: 12),
                TextButton(
                  onPressed: () {
                    showMonetizationModal(context, ref);
                  },
                  child: Text(
                    l10n.companyDetailUpgradeNoAds,
                    style: GoogleFonts.inter(
                      fontSize: 13,
                      color: palette.accentPrimary,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      );
    }

    final asyncData = ref.watch(companyDetailProvider(widget.symbol));

    ref.listen<AsyncValue<Map<String, dynamic>>>(
      companyDetailProvider(widget.symbol),
      (previous, next) {
        next.whenData((data) {
          final profile = data['profile'] as Map<String, dynamic>? ?? {};
          final name = profile['name'] as String? ?? widget.symbol;
          ref
              .read(recentlyViewedProvider.notifier)
              .recordView(widget.symbol, name);
        });
      },
    );

    return Scaffold(
      backgroundColor: Colors.transparent,
      body: asyncData.when(
        loading: () => Center(
          child: CircularProgressIndicator(color: palette.accentPrimary),
        ),
        error: (err, _) => Center(
          child: Padding(
            padding: const EdgeInsets.all(32),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(
                  Icons.cloud_off_rounded,
                  color: palette.textBody,
                  size: 56,
                ),
                const SizedBox(height: 16),
                Text(
                  l10n.companyDetailLoadError,
                  style: GoogleFonts.inter(
                    color: palette.textHeader,
                    fontSize: 18,
                    fontWeight: FontWeight.w600,
                  ),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 8),
                Text(
                  l10n.companyDetailLoadErrorBody,
                  style: GoogleFonts.inter(
                    color: palette.textBody,
                    fontSize: 14,
                  ),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 24),
                ElevatedButton.icon(
                  onPressed: () {
                    ref.invalidate(companyDetailProvider(widget.symbol));
                  },
                  icon: const Icon(Icons.refresh_rounded, size: 18),
                  label: Text(l10n.commonRetry),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: ThemeV2.primary,
                    foregroundColor: Colors.white,
                    padding: const EdgeInsets.symmetric(
                      horizontal: 24,
                      vertical: 14,
                    ),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
        data: (data) => _CompanyDetailBody(
          symbol: widget.symbol,
          data: data,
          contextPortfolioId: widget.contextPortfolioId,
        ),
      ),
    );
  }
}

class _CompanyDetailBody extends ConsumerStatefulWidget {
  final String symbol;
  final Map<String, dynamic> data;
  final String? contextPortfolioId;

  const _CompanyDetailBody({
    required this.symbol,
    required this.data,
    this.contextPortfolioId,
  });

  @override
  ConsumerState<_CompanyDetailBody> createState() => _CompanyDetailBodyState();
}

class _CompanyDetailBodyState extends ConsumerState<_CompanyDetailBody> {
  @override
  void initState() {
    super.initState();
    _cacheDetailLogo();
  }

  // Belt-and-suspenders: companyDetailProvider itself already ran this
  // (see cacheCompanyLogo in company_detail_provider.dart) before
  // widget.data ever reached this widget — kept here in case a future
  // caller hands this widget pre-fetched data some other way. WidgetRef
  // isn't a Ref, so this can't just call the shared helper directly.
  Future<void> _cacheDetailLogo() async {
    final profile = widget.data['profile'] as Map<String, dynamic>? ?? {};
    try {
      await ref
          .read(logoRepositoryProvider)
          .cacheFromProfile(widget.symbol, profile);
      ref.invalidate(quickLogoProvider(widget.symbol));
      ref.invalidate(quickGicsSectorProvider(widget.symbol));
      ref.invalidate(cachedLogoProvider(widget.symbol));
      ref.invalidate(cachedGicsSectorProvider(widget.symbol));
      ref.invalidate(cachedLogoEntryProvider(widget.symbol));
    } catch (_) {
      // Не ломаем UI
    }
  }

  // Quote/profile already loaded for this screen — handed to the order
  // entry screen via route extra so it doesn't have to refetch on open or
  // guess the company name/logo. Only price (not day's change, see
  // order_header.dart).
  Map<String, dynamic> get _quoteExtra {
    final profile = widget.data['profile'] as Map<String, dynamic>? ?? {};
    final quote = widget.data['quote'] as Map<String, dynamic>? ?? {};
    return {
      'price': (quote['c'] as num?)?.toDouble() ?? 0,
      'companyName': profile['name'] as String? ?? widget.symbol,
      'logo': profile['logo'] as String?,
    };
  }

  void _openOrderEntry(String type) {
    final l10n = AppLocalizations.of(context)!;
    final portfolios = ref.read(portfoliosProvider);
    final tier = ref.read(subscriptionTierProvider);
    final isPremiumTier = tier.isPremiumOrAdmin;
    if (portfolios.isEmpty) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text(l10n.companyDetailNoPortfolios)));
      return;
    }

    // Came from a specific portfolio (e.g. tapped a holding row) — trade
    // straight into it, no picker.
    final contextId = widget.contextPortfolioId;
    if (contextId != null && portfolios.any((p) => p.id == contextId)) {
      context.push(
        '/portfolio/$contextId/stock/${widget.symbol}/order',
        extra: {'type': type, ..._quoteExtra},
      );
      return;
    }

    if (portfolios.length == 1) {
      context.push(
        '/portfolio/${portfolios.first.id}/stock/${widget.symbol}/order',
        extra: {'type': type, ..._quoteExtra},
      );
      return;
    }

    showModalBottomSheet(
      context: context,
      backgroundColor: ThemeV2.surface,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (ctx) => Padding(
        padding: const EdgeInsets.fromLTRB(16, 20, 16, 24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            Container(
              width: 36,
              height: 4,
              decoration: BoxDecoration(
                color: Colors.black26,
                borderRadius: BorderRadius.circular(2),
              ),
            ),
            const SizedBox(height: 20),
            Text(
              l10n.companyDetailSelectPortfolioTitle,
              style: GoogleFonts.inter(
                fontSize: 18,
                fontWeight: FontWeight.w700,
                color: ThemeV2.primary,
              ),
            ),
            const SizedBox(height: 4),
            Text(
              type == 'buy'
                  ? l10n.companyDetailSelectPortfolioBodyBuy(widget.symbol)
                  : l10n.companyDetailSelectPortfolioBodySell(widget.symbol),
              style: GoogleFonts.inter(
                fontSize: 13,
                color: ThemeV2.textSecondary,
              ),
            ),
            const SizedBox(height: 16),
            ...portfolios.map(
              (p) => Padding(
                padding: const EdgeInsets.only(bottom: 10),
                child: PortfolioOptionTile(
                  name: p.displayName(l10n),
                  cash: p.cash,
                  // Every portfolio is on the same (single-slot) plan now —
                  // "premium" here just reflects the user's own tier, not a
                  // per-portfolio distinction like the old $15k/$50k tiers.
                  isPremium: isPremiumTier,
                  onTap: () {
                    Navigator.pop(ctx);
                    context.push(
                      '/portfolio/${p.id}/stock/${widget.symbol}/order',
                      extra: {'type': type, ..._quoteExtra},
                    );
                  },
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final palette = resolveAppPalette(ref.watch(themeVariantProvider));
    final profile = widget.data['profile'] as Map<String, dynamic>? ?? {};
    final quote = widget.data['quote'] as Map<String, dynamic>? ?? {};
    final metrics = widget.data['metrics'] as Map<String, dynamic>? ?? {};
    final scoreData = widget.data['score'] as Map<String, dynamic>? ?? {};
    final companyName = profile['name'] as String? ?? widget.symbol;
    final logo = profile['logo'] as String?;
    final price = (quote['c'] as num?)?.toDouble() ?? 0;
    final change = (quote['d'] as num?)?.toDouble() ?? 0;
    final changePercent = (quote['dp'] as num?)?.toDouble() ?? 0;
    final isUp = change >= 0;

    // ── Widget order system ──
    final widgetConfigs = ref.watch(companyWidgetsProvider);
    final visibleWidgets = widgetConfigs.where((w) => w.visible).toList();

    return Column(
      children: [
        // Top bar with back + bookmark — fixed outside the scroll view so it
        // never scrolls away, matching every other screen's header pattern.
        SafeArea(
          bottom: false,
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 4),
            child: Row(
              children: [
                themedBackButton(context, palette),
                Expanded(
                  child: Center(
                    child: themedHeaderText(
                      l10n.companyDetailTitle,
                      palette,
                      GoogleFonts.inter(
                        fontSize: 20,
                        fontWeight: FontWeight.w800,
                        letterSpacing: 1.5,
                      ),
                      overflow: TextOverflow.ellipsis,
                      maxLines: 1,
                    ),
                  ),
                ),
                Consumer(
                  builder: (context, ref, _) {
                    final watchlist = ref.watch(watchlistSymbolsProvider);
                    final inWatchlist = watchlist.contains(widget.symbol);
                    return IconButton(
                      icon: Icon(
                        inWatchlist
                            ? Icons.bookmark_rounded
                            : Icons.bookmark_border_rounded,
                        color: inWatchlist
                            ? palette.accentPrimary
                            : palette.textBody,
                      ),
                      onPressed: () {
                        if (inWatchlist) {
                          ref
                              .read(watchlistSymbolsProvider.notifier)
                              .remove(widget.symbol);
                          return;
                        }
                        final maxW = ref.read(maxWatchlistProvider);
                        if (watchlist.length >= maxW) {
                          ScaffoldMessenger.of(context).showSnackBar(
                            SnackBar(
                              content: Text(
                                maxW == 30
                                    ? l10n.watchlistLimitFree
                                    : l10n.watchlistLimitMax(maxW),
                                style: GoogleFonts.inter(fontSize: 13),
                              ),
                              backgroundColor: ThemeV2.primary,
                              behavior: SnackBarBehavior.floating,
                            ),
                          );
                          return;
                        }
                        ref
                            .read(watchlistSymbolsProvider.notifier)
                            .add(widget.symbol);
                      },
                    );
                  },
                ),
              ],
            ),
          ),
        ),
        // Scrollable content
        Expanded(
          child: CustomScrollView(
            slivers: [
              // Main content — dynamic widgets
              SliverToBoxAdapter(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    for (int i = 0; i < visibleWidgets.length; i++)
                      KeyedSubtree(
                        key: ValueKey('company_widget_${visibleWidgets[i].id}'),
                        child: StaggerFadeIn(
                          index: i,
                          child: _buildWidget(
                            visibleWidgets[i].id,
                            logo: logo,
                            companyName: companyName,
                            symbol: widget.symbol,
                            price: price,
                            change: change,
                            changePercent: changePercent,
                            isUp: isUp,
                            metrics: metrics,
                            scoreData: scoreData,
                            palette: palette,
                          ),
                        ),
                      ),
                    const SizedBox(height: 16),
                    // ── Add widgets button ──
                    StaggerFadeIn(
                      index: visibleWidgets.length,
                      child: Center(
                        child: themedAddWidgetsButton(
                          context,
                          palette,
                          label: l10n.homeAddWidgets,
                          onTap: _showWidgetsBottomSheet,
                        ),
                      ),
                    ),
                    const SizedBox(height: 20),
                    // ── Educational Purpose & Legal Disclaimer ──
                    // Sits directly on the scroll background, no card
                    // behind it. Color is the same fixed muted gray as
                    // DisclaimerFooter's reference treatment (2026-08-25:
                    // unify every card-level disclaimer to that one look)
                    // — NOT palette-based, so it's readable regardless of
                    // backdrop in both themes.
                    StaggerFadeIn(
                      index: visibleWidgets.length + 1,
                      child: Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 24),
                        child: Column(
                          children: [
                            Text(
                              l10n.companyDetailDisclaimerTitle,
                              textAlign: TextAlign.center,
                              style: GoogleFonts.inter(
                                fontSize: 10,
                                fontWeight: FontWeight.w700,
                                color: ThemeV2.textSecondary.withValues(
                                  alpha: 0.5,
                                ),
                              ),
                            ),
                            const SizedBox(height: 6),
                            Text(
                              l10n.companyDetailDisclaimerBody,
                              textAlign: TextAlign.center,
                              style: GoogleFonts.inter(
                                fontSize: 9,
                                color: ThemeV2.textSecondary.withValues(
                                  alpha: 0.5,
                                ),
                                height: 1.5,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                    const SizedBox(height: 100), // space for bottom bar
                  ],
                ),
              ),
            ],
          ),
        ),
        // --- Sticky Bottom Bar: BUY / SELL ---
        CompanyBottomBar(
          price: price,
          isUp: isUp,
          onBuy: () => _openOrderEntry('buy'),
          onSell: () => _openOrderEntry('sell'),
          palette: palette,
        ),
      ],
    );
  }

  // ─────────────────────────────────────────────────────────────────────────
  // Widget Router — builds a widget by its id
  // ─────────────────────────────────────────────────────────────────────────

  Widget _buildWidget(
    String id, {
    required String? logo,
    required String companyName,
    required String symbol,
    required double price,
    required double change,
    required double changePercent,
    required bool isUp,
    required Map<String, dynamic> metrics,
    required Map<String, dynamic> scoreData,
    required AppPalette palette,
  }) {
    switch (id) {
      case 'price_header':
        final l10n = AppLocalizations.of(context)!;
        final hoverPrice = ref.watch(chartHoverPriceProvider(symbol));
        final periodChange = ref.watch(chartPeriodChangeProvider(symbol));
        final shownChange = periodChange?.change ?? change;
        final shownChangePercent = periodChange?.changePercent ?? changePercent;
        return Column(
          children: [
            PriceHeader(
              logo: logo,
              companyName: companyName,
              symbol: symbol,
              price: hoverPrice ?? price,
              change: shownChange,
              changePercent: shownChangePercent,
              isUp: shownChange >= 0,
              changeLabel: periodChange != null
                  ? l10n.companyDetailChangePeriodLabel(
                      periodChange.periodLabel,
                    )
                  : l10n.companyDetailChangeLabel,
              fsScore: scoreData['financial_score'] as int?,
              palette: palette,
            ),
            const SizedBox(height: 16),
          ],
        );
      case 'chart':
        return Column(
          children: [
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              child: PriceChart(symbol: symbol, palette: palette),
            ),
            const SizedBox(height: 24),
          ],
        );
      case 'key_metrics':
        return Column(
          children: [
            KeyMetricsSection(metrics: metrics, palette: palette),
            const SizedBox(height: 24),
          ],
        );
      case 'financial_score':
        if (scoreData.isEmpty) return const SizedBox.shrink();
        return Column(
          children: [
            FinancialScoreWidget(score: scoreData, palette: palette),
            const SizedBox(height: 24),
          ],
        );
      case 'encyclopedia':
        return Column(
          children: [
            CompanyEncyclopediaWidget(
              symbol: symbol,
              companyName: companyName,
              palette: palette,
            ),
            const SizedBox(height: 24),
          ],
        );
      case 'position':
        return Column(
          children: [
            PositionSection(symbol: symbol, price: price, palette: palette),
            const SizedBox(height: 24),
          ],
        );
      case 'limit_orders':
        return Column(
          children: [
            LimitOrdersSection(symbol: symbol, palette: palette),
            const SizedBox(height: 24),
          ],
        );
      default:
        return const SizedBox.shrink();
    }
  }

  // ─────────────────────────────────────────────────────────────────────────
  // Show Widget Settings BottomSheet
  // ─────────────────────────────────────────────────────────────────────────

  void _showWidgetsBottomSheet() {
    final notifier = ref.read(companyWidgetsProvider.notifier);
    final currentConfigs = ref.read(companyWidgetsProvider);
    final palette = resolveAppPalette(ref.read(themeVariantProvider));

    showModalBottomSheet(
      context: context,
      backgroundColor: palette.card,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (_) => CompanyWidgetsSettingsSheet(
        initialConfigs: currentConfigs,
        notifier: notifier,
        palette: palette,
      ),
    );
  }
}
