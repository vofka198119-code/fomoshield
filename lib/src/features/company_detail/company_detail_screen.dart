import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:go_router/go_router.dart';
import '../../l10n/gen/app_localizations.dart';
import '../../core/theme/theme_v2.dart';
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
import 'widgets/company_bottom_bar.dart';
import 'widgets/company_ad_overlay.dart';
import '../search/recently_viewed_provider.dart';
import '../portfolio/portfolio_limits_provider.dart'
    show firstPortfolioStartingCapital;

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
    if (tier == SubscriptionTier.premium || tier == SubscriptionTier.admin) {
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
    if (_showAd) {
      return Scaffold(
        backgroundColor: Colors.transparent,
        body: Center(
          child: Container(
            margin: const EdgeInsets.all(32),
            padding: const EdgeInsets.all(32),
            decoration: BoxDecoration(
              color: ThemeV2.surface,
              borderRadius: BorderRadius.circular(20),
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                const Icon(
                  Icons.play_circle_rounded,
                  color: ThemeV2.primary,
                  size: 64,
                ),
                const SizedBox(height: 24),
                Text(
                  l10n.companyDetailSponsoredTitle,
                  style: GoogleFonts.inter(
                    fontSize: 20,
                    fontWeight: FontWeight.w700,
                    color: ThemeV2.textPrimary,
                  ),
                ),
                const SizedBox(height: 12),
                Text(
                  l10n.companyDetailWatchAdBody,
                  textAlign: TextAlign.center,
                  style: GoogleFonts.inter(
                    fontSize: 14,
                    color: ThemeV2.textSecondary,
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
                      color: ThemeV2.primary,
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
        loading: () => const Center(
          child: CircularProgressIndicator(color: ThemeV2.primary),
        ),
        error: (err, _) => Center(
          child: Padding(
            padding: const EdgeInsets.all(32),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                const Icon(
                  Icons.cloud_off_rounded,
                  color: ThemeV2.textSecondary,
                  size: 56,
                ),
                const SizedBox(height: 16),
                Text(
                  l10n.companyDetailLoadError,
                  style: GoogleFonts.inter(
                    color: ThemeV2.textPrimary,
                    fontSize: 18,
                    fontWeight: FontWeight.w600,
                  ),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 8),
                Text(
                  l10n.companyDetailLoadErrorBody,
                  style: GoogleFonts.inter(
                    color: ThemeV2.textSecondary,
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

  Future<void> _cacheDetailLogo() async {
    final profile = widget.data['profile'] as Map<String, dynamic>? ?? {};
    await cacheCompanyLogo(widget.symbol, profile);
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
    if (portfolios.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(l10n.companyDetailNoPortfolios)),
      );
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
                  name: p.name,
                  cash: p.cash,
                  isPremium: p.startingBalance > firstPortfolioStartingCapital,
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
                IconButton(
                  icon: const Icon(
                    Icons.arrow_back_rounded,
                    color: ThemeV2.textPrimary,
                  ),
                  onPressed: () => context.pop(),
                ),
                Expanded(
                  child: Center(
                    child: Text(
                      l10n.companyDetailTitle,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: GoogleFonts.inter(
                        fontSize: 20,
                        fontWeight: FontWeight.w800,
                        color: ThemeV2.primary,
                        letterSpacing: 1.5,
                      ),
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
                            ? ThemeV2.primary
                            : ThemeV2.textSecondary,
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
                          ),
                        ),
                      ),
                    const SizedBox(height: 16),
                    // ── Add widgets button ──
                    StaggerFadeIn(
                      index: visibleWidgets.length,
                      child: Center(
                        child: TextButton.icon(
                          onPressed: _showWidgetsBottomSheet,
                          icon: const Icon(
                            Icons.add_rounded,
                            color: ThemeV2.primary,
                            size: 20,
                          ),
                          label: Text(
                            l10n.homeAddWidgets,
                            style: GoogleFonts.inter(
                              fontSize: 14,
                              fontWeight: FontWeight.w600,
                              color: ThemeV2.primary,
                            ),
                          ),
                          style: TextButton.styleFrom(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 24,
                              vertical: 14,
                            ),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(30),
                              side: const BorderSide(
                                color: ThemeV2.primary,
                                width: 0.5,
                              ),
                            ),
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(height: 20),
                    // ── Educational Purpose & Legal Disclaimer ──
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
                                color: ThemeV2.textPrimary,
                              ),
                            ),
                            const SizedBox(height: 6),
                            Text(
                              l10n.companyDetailDisclaimerBody,
                              textAlign: TextAlign.center,
                              style: GoogleFonts.inter(
                                fontSize: 9,
                                color: ThemeV2.textPrimary,
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
                  ? l10n.companyDetailChangePeriodLabel(periodChange.periodLabel)
                  : l10n.companyDetailChangeLabel,
              fsScore: scoreData['financial_score'] as int?,
            ),
            const SizedBox(height: 16),
          ],
        );
      case 'chart':
        return Column(
          children: [
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              child: PriceChart(symbol: symbol),
            ),
            const SizedBox(height: 24),
          ],
        );
      case 'key_metrics':
        return Column(
          children: [
            KeyMetricsSection(metrics: metrics),
            const SizedBox(height: 24),
          ],
        );
      case 'financial_score':
        if (scoreData.isEmpty) return const SizedBox.shrink();
        return Column(
          children: [
            FinancialScoreWidget(score: scoreData),
            const SizedBox(height: 24),
          ],
        );
      case 'position':
        return Column(
          children: [
            PositionSection(symbol: symbol, price: price),
            const SizedBox(height: 24),
          ],
        );
      case 'limit_orders':
        return Column(
          children: [
            LimitOrdersSection(symbol: symbol),
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

    showModalBottomSheet(
      context: context,
      backgroundColor: ThemeV2.surface,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (_) => CompanyWidgetsSettingsSheet(
        initialConfigs: currentConfigs,
        notifier: notifier,
      ),
    );
  }
}
