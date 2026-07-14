import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:go_router/go_router.dart';
import '../../core/theme/theme_v2.dart';
import '../../core/theme/typography_helpers.dart';
import '../../core/supabase/supabase_providers.dart';
import '../../shared/services/finnhub_service.dart';
import '../../shared/services/scoring_engine.dart';
import '../home/home_providers.dart';
import '../portfolio/portfolio_providers.dart';
import '../monetization/monetization_modal.dart';
import '../../core/cache/logo_dao.dart';
import '../../core/models/logo_cache_entry.dart';
import 'company_cache_provider.dart';
import 'score_cache_provider.dart';
import 'metrics_cache_provider.dart';
import 'watchlist_ad_provider.dart';
import 'company_widget_order_provider.dart';
import 'widgets/price_chart.dart';
import 'widgets/fs_score_widget.dart';

// ---------------------------------------------------------------------------
// Providers — with layered cache: 4h (main) + 30d (score + metrics)
// ---------------------------------------------------------------------------

final companyDetailProvider =
    FutureProvider.family<Map<String, dynamic>, String>((ref, symbol) async {
      final cache = ref.read(companyCacheProvider);

      // Check per-ticker cache first (4h TTL)
      final cached = cache.get(symbol);
      if (cached != null) return cached;

      final api = FinnhubService();
      final scoreCache = ref.read(scoreCacheProvider);
      final metricsCache = ref.read(metricsCacheProvider);

      // Check 30-day score cache before full API call (экономия трафика)
      final cachedScore = scoreCache.get(symbol);
      if (cachedScore != null) {
        // Score актуален — берём только profile + quote
        // Метрики пробуем из 30-дневного кэша, если нет — запрос к Finnhub
        final profile = await api.companyProfile(symbol);
        final quote = await api.quote(symbol);

        _cacheLogo(symbol, profile);

        Map<String, dynamic> metrics = {};
        final cachedMetrics = metricsCache.get(symbol);
        if (cachedMetrics != null) {
          metrics = cachedMetrics;
        } else {
          try {
            metrics = await api.metrics(symbol);
            metricsCache.set(symbol, metrics);
          } catch (_) {
            metrics = {};
          }
        }

        final data = {
          'profile': profile,
          'quote': quote,
          'metrics': metrics,
          'score': cachedScore,
        };

        // Store in 4h cache
        cache.set(symbol, Map<String, dynamic>.from(data));
        return data;
      }

      // Score кэш пуст — полный запрос к Finnhub
      final profile = await api.companyProfile(symbol);
      final quote = await api.quote(symbol);
      final metrics = await api.metrics(symbol);
      final score = ScoringEngine.calculate(metrics);

      // Сохранить логотип в LogoCache (если есть и нет в кэше)
      _cacheLogo(symbol, profile);

      // Сохранить score в 30-дневный кэш
      scoreCache.set(symbol, Map<String, dynamic>.from(score));
      // Сохранить сырые метрики в 30-дневный кэш
      metricsCache.set(symbol, Map<String, dynamic>.from(metrics));

      final data = {
        'profile': profile,
        'quote': quote,
        'metrics': metrics,
        'score': score,
      };

      // Store in per-ticker cache (4h)
      cache.set(symbol, Map<String, dynamic>.from(data));

      return data;
    });

// ---------------------------------------------------------------------------
// Helpers
// ---------------------------------------------------------------------------

/// Сохраняет логотип компании в LogoCache.
Future<void> _cacheLogo(String symbol, Map<String, dynamic> profile) async {
  try {
    final dao = LogoDao();
    final existing = await dao.getLogo(symbol);
    if (existing != null) return; // уже есть в кэше

    final finnhubLogo = profile['logo'] as String?;
    final weburl = profile['weburl'] as String?;
    String? domain;
    if (weburl != null && weburl.isNotEmpty) {
      try {
        final uri = Uri.parse(weburl);
        domain = uri.host;
        if (domain.startsWith('www.')) domain = domain.substring(4);
      } catch (_) {}
    }
    final logoUrl =
        finnhubLogo ??
        (domain != null ? 'https://logo.clearbit.com/$domain' : null);
    if (logoUrl == null) return;

    final entry = LogoCacheEntry(
      ticker: symbol.toUpperCase(),
      companyName: profile['name'] as String? ?? symbol,
      domain: domain,
      logoUrl: logoUrl,
      createdAt: DateTime.now(),
    );
    await dao.saveLogo(entry);
  } catch (_) {
    // Не ломаем UI
  }
}

// ---------------------------------------------------------------------------
// Screen
// ---------------------------------------------------------------------------

class CompanyDetailScreen extends ConsumerStatefulWidget {
  final String symbol;

  const CompanyDetailScreen({super.key, required this.symbol});

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
    if (tier == SubscriptionTier.premium || tier == SubscriptionTier.admin)
      return;
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
            _CompanyAdOverlay(
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
                  'Sponsored content',
                  style: GoogleFonts.inter(
                    fontSize: 20,
                    fontWeight: FontWeight.w700,
                    color: ThemeV2.textPrimary,
                  ),
                ),
                const SizedBox(height: 12),
                Text(
                  'Please watch a short ad to continue viewing company details.',
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
                      'Watch 3s Ad',
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
                    'Upgrade to Premium — no ads',
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
                  'Could not load company data',
                  style: GoogleFonts.inter(
                    color: ThemeV2.textPrimary,
                    fontSize: 18,
                    fontWeight: FontWeight.w600,
                  ),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 8),
                Text(
                  'The market data API may be temporarily unavailable. Please try again.',
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
                  label: const Text('Retry'),
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
        data: (data) => _CompanyDetailBody(symbol: widget.symbol, data: data),
      ),
    );
  }
}

class _CompanyDetailBody extends ConsumerStatefulWidget {
  final String symbol;
  final Map<String, dynamic> data;

  const _CompanyDetailBody({required this.symbol, required this.data});

  @override
  ConsumerState<_CompanyDetailBody> createState() => _CompanyDetailBodyState();
}

class _CompanyDetailBodyState extends ConsumerState<_CompanyDetailBody> {
  final FinnhubService _api = FinnhubService();
  List<dynamic>? _news;
  bool _newsLoading = false;

  @override
  void initState() {
    super.initState();
    _loadNews();
    _cacheDetailLogo();
  }

  Future<void> _loadNews() async {
    setState(() => _newsLoading = true);
    try {
      _news = await _api.companyNews(widget.symbol);
    } catch (_) {}
    if (mounted) setState(() => _newsLoading = false);
  }

  Future<void> _cacheDetailLogo() async {
    final profile = widget.data['profile'] as Map<String, dynamic>? ?? {};
    await _cacheLogo(widget.symbol, profile);
  }

  void _openOrderEntry(String type) {
    final portfolios = ref.read(portfoliosProvider);
    if (portfolios.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('No portfolios yet. Create one first.')),
      );
      return;
    }

    if (portfolios.length == 1) {
      context.push(
        '/portfolio/${portfolios.first.id}/stock/${widget.symbol}/order',
        extra: {'type': type},
      );
      return;
    }

    showModalBottomSheet(
      context: context,
      backgroundColor: ThemeV2.surface,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(16)),
      ),
      builder: (ctx) => Container(
        padding: const EdgeInsets.all(16),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: 36,
              height: 4,
              decoration: BoxDecoration(
                color: Colors.black26,
                borderRadius: BorderRadius.circular(2),
              ),
            ),
            const SizedBox(height: 16),
            Text(
              'Select Portfolio',
              style: GoogleFonts.inter(
                fontSize: 16,
                fontWeight: FontWeight.w700,
                color: ThemeV2.textPrimary,
              ),
            ),
            const SizedBox(height: 12),
            ...portfolios.map(
              (p) => ListTile(
                title: Text(
                  p.name,
                  style: GoogleFonts.inter(color: ThemeV2.textPrimary),
                ),
                subtitle: Text(
                  '\$${p.cash.toStringAsFixed(2)} available',
                  style: GoogleFonts.inter(
                    color: ThemeV2.textSecondary,
                    fontSize: 12,
                  ),
                ),
                trailing: Icon(
                  Icons.chevron_right_rounded,
                  color: ThemeV2.textSecondary,
                ),
                onTap: () {
                  Navigator.pop(ctx);
                  context.push(
                    '/portfolio/${p.id}/stock/${widget.symbol}/order',
                    extra: {'type': type},
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
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
        // Scrollable content
        Expanded(
          child: CustomScrollView(
            slivers: [
              // Top bar with back + bookmark + widget settings
              SliverAppBar(
                floating: true,
                backgroundColor: Colors.transparent,
                leading: IconButton(
                  icon: const Icon(
                    Icons.arrow_back_rounded,
                    color: ThemeV2.textPrimary,
                  ),
                  onPressed: () => context.pop(),
                ),
                actions: [
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
                          } else {
                            ref
                                .read(watchlistSymbolsProvider.notifier)
                                .add(widget.symbol);
                          }
                        },
                      );
                    },
                  ),
                  IconButton(
                    icon: const Icon(
                      Icons.tune_rounded,
                      color: ThemeV2.textSecondary,
                    ),
                    onPressed: _showWidgetsBottomSheet,
                  ),
                ],
              ),
              // Main content — dynamic widgets
              SliverToBoxAdapter(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    for (int i = 0; i < visibleWidgets.length; i++)
                      KeyedSubtree(
                        key: ValueKey('company_widget_${visibleWidgets[i].id}'),
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
                    const SizedBox(height: 16),
                    // ── Add widgets button ──
                    Center(
                      child: TextButton.icon(
                        onPressed: _showWidgetsBottomSheet,
                        icon: const Icon(
                          Icons.add_rounded,
                          color: ThemeV2.primary,
                          size: 20,
                        ),
                        label: Text(
                          'Add widgets',
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
                    const SizedBox(height: 100), // space for bottom bar
                  ],
                ),
              ),
            ],
          ),
        ),
        // --- Sticky Bottom Bar: BUY / SELL ---
        _BottomBar(
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
        return Column(
          children: [
            _PriceHeader(
              logo: logo,
              companyName: companyName,
              symbol: symbol,
              price: price,
              change: change,
              changePercent: changePercent,
              isUp: isUp,
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
            _KeyMetricsSection(metrics: metrics),
            const SizedBox(height: 24),
          ],
        );
      case 'fs_score':
        if (scoreData.isEmpty) return const SizedBox.shrink();
        return Column(
          children: [
            FsScoreWidget(score: scoreData),
            const SizedBox(height: 24),
          ],
        );
      case 'position':
        return Column(
          children: [
            _PositionSection(symbol: symbol, price: price),
            const SizedBox(height: 24),
          ],
        );
      case 'events':
        return Column(children: [_EventsStub(), const SizedBox(height: 24)]);
      case 'news':
        return Column(
          children: [
            _NewsSection(symbol: symbol, news: _news, isLoading: _newsLoading),
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
      builder: (_) => _CompanyWidgetsSettingsSheet(
        initialConfigs: currentConfigs,
        notifier: notifier,
      ),
    );
  }
}

// ===========================================================================
// Price Header
// ===========================================================================

class _PriceHeader extends StatelessWidget {
  final String? logo;
  final String companyName;
  final String symbol;
  final double price;
  final double change;
  final double changePercent;
  final bool isUp;

  const _PriceHeader({
    this.logo,
    required this.companyName,
    required this.symbol,
    required this.price,
    required this.change,
    required this.changePercent,
    required this.isUp,
  });

  @override
  Widget build(BuildContext context) {
    final changeColor = isUp ? ThemeV2.success : ThemeV2.loss;

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const SizedBox(height: 4),
          // Company name + ticker
          Row(
            children: [
              if (logo != null && logo!.isNotEmpty)
                ClipRRect(
                  borderRadius: BorderRadius.circular(10),
                  child: Image.network(
                    logo!,
                    width: 44,
                    height: 44,
                    errorBuilder: (_, _, _) => const Icon(
                      Icons.business_rounded,
                      size: 44,
                      color: ThemeV2.primary,
                    ),
                  ),
                )
              else
                const Icon(
                  Icons.business_rounded,
                  size: 44,
                  color: ThemeV2.primary,
                ),
              const SizedBox(width: 10),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      companyName,
                      style: GoogleFonts.inter(
                        fontSize: 15,
                        fontWeight: FontWeight.w600,
                        color: ThemeV2.textPrimary,
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                    Text(
                      symbol,
                      style: GoogleFonts.inter(
                        fontSize: 12,
                        color: ThemeV2.textSecondary,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          // Price row
          Row(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              Text(
                '\$${price.toStringAsFixed(2)}',
                style: GoogleFonts.inter(
                  fontSize: 32,
                  fontWeight: FontWeight.w700,
                  color: ThemeV2.textPrimary,
                  height: 1,
                ),
              ),
              const SizedBox(width: 10),
              Padding(
                padding: const EdgeInsets.only(bottom: 4),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(
                      isUp
                          ? Icons.trending_up_rounded
                          : Icons.trending_down_rounded,
                      size: 18,
                      color: changeColor,
                    ),
                    const SizedBox(width: 3),
                    Text(
                      '${isUp ? '+' : ''}${change.toStringAsFixed(2)} (${changePercent.toStringAsFixed(2)}%)',
                      style: GoogleFonts.inter(
                        fontSize: 15,
                        fontWeight: FontWeight.w600,
                        color: changeColor,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

// ===========================================================================
// Key Metrics — P/E, дивиденды, маржинальность (из 30-дневного кэша)
// ===========================================================================

class _KeyMetricsSection extends StatelessWidget {
  final Map<String, dynamic> metrics;

  const _KeyMetricsSection({required this.metrics});

  @override
  Widget build(BuildContext context) {
    final m = metrics['metric'] as Map<String, dynamic>? ?? {};
    if (m.isEmpty) return const SizedBox.shrink();

    final pe = _double(m['peTTM']);
    final divYield = _double(m['dividendYieldIndicatedAnnual']);
    final netMargin = _double(m['netProfitMarginTTM']);
    final opMargin = _double(m['operatingMarginTTM']);
    final grossMargin = _double(m['grossMarginTTM']);
    final roe = _double(m['roeTTM']);

    final items = <_MetricItem>[
      _MetricItem(
        'P/E',
        pe > 0 ? pe.toStringAsFixed(1) : 'N/A',
        'Price-to-Earnings',
      ),
      _MetricItem(
        'Div. Yield',
        divYield > 0 ? '${(divYield * 100).toStringAsFixed(2)}%' : 'N/A',
        'Dividend Yield',
      ),
      _MetricItem(
        'Net Margin',
        netMargin > 0 ? '${(netMargin * 100).toStringAsFixed(1)}%' : 'N/A',
        'Net Profit Margin',
      ),
      _MetricItem(
        'Op. Margin',
        opMargin > 0 ? '${(opMargin * 100).toStringAsFixed(1)}%' : 'N/A',
        'Operating Margin',
      ),
      _MetricItem(
        'Gross Margin',
        grossMargin > 0 ? '${(grossMargin * 100).toStringAsFixed(1)}%' : 'N/A',
        'Gross Margin',
      ),
      if (m['roeTTM'] != null)
        _MetricItem(
          'ROE',
          '${(roe * 100).toStringAsFixed(1)}%',
          'Return on Equity',
        ),
    ];

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: ThemeV2.surface,
          borderRadius: BorderRadius.circular(14),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Key Metrics',
              style: GoogleFonts.inter(
                fontSize: 14,
                fontWeight: FontWeight.w700,
                color: ThemeV2.textPrimary,
              ),
            ),
            const SizedBox(height: 12),
            ...items.asMap().entries.map((entry) {
              final i = entry.key;
              final item = entry.value;
              final showDivider = i < items.length - 1;
              return _metricRow(item, showDivider: showDivider);
            }),
          ],
        ),
      ),
    );
  }

  Widget _metricRow(_MetricItem item, {required bool showDivider}) {
    return Column(
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  item.label,
                  style: GoogleFonts.inter(
                    fontSize: 13,
                    fontWeight: FontWeight.w600,
                    color: ThemeV2.textPrimary,
                  ),
                ),
                const SizedBox(height: 1),
                Text(
                  item.subtitle,
                  style: GoogleFonts.inter(
                    fontSize: 11,
                    color: ThemeV2.textSecondary,
                  ),
                ),
              ],
            ),
            Text(
              item.value,
              style: GoogleFonts.inter(
                fontSize: 15,
                fontWeight: FontWeight.w700,
                color: ThemeV2.primary,
              ),
            ),
          ],
        ),
        if (showDivider)
          Padding(
            padding: const EdgeInsets.symmetric(vertical: 10),
            child: Container(height: 1, color: ThemeV2.divider),
          ),
      ],
    );
  }

  double _double(dynamic v) => (v is num) ? v.toDouble() : 0.0;
}

class _MetricItem {
  final String label;
  final String value;
  final String subtitle;
  const _MetricItem(this.label, this.value, this.subtitle);
}

// ===========================================================================
// Position Section
// ===========================================================================

class _PositionSection extends ConsumerWidget {
  final String symbol;
  final double price;

  const _PositionSection({required this.symbol, required this.price});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final portfolios = ref.watch(portfoliosProvider);

    // Find all holdings for this symbol across portfolios
    List<
      ({String portfolioName, double shares, double avgCost, double totalValue})
    >
    positions = [];
    for (final p in portfolios) {
      final perf = ref.watch(portfolioPerformanceProvider(p.id));
      final holding = perf.asData?.value.holdings.firstWhere(
        (h) => h.symbol == symbol,
        orElse: () => HoldingPerformance(
          symbol: symbol,
          shares: 0,
          avgCost: 0,
          totalCost: 0,
          currentPrice: 0,
          currentValue: 0,
          pnl: 0,
          pnlPercent: 0,
        ),
      );
      if (holding != null && holding.shares > 0) {
        positions.add((
          portfolioName: p.name,
          shares: holding.shares,
          avgCost: holding.avgCost,
          totalValue: holding.shares * price,
        ));
      }
    }

    if (positions.isEmpty) return const SizedBox.shrink();

    final totalShares = positions.fold<double>(0, (s, p) => s + p.shares);
    final totalValue = positions.fold<double>(0, (s, p) => s + p.totalValue);
    // Weighted average cost
    final totalCost = positions.fold<double>(
      0,
      (s, p) => s + p.shares * p.avgCost,
    );
    final avgCost = totalShares > 0 ? totalCost / totalShares : 0.0;
    final pnl = totalValue - totalCost;
    final pnlPercent = totalCost > 0 ? (pnl / totalCost) * 100 : 0.0;

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: ThemeV2.surface,
          borderRadius: BorderRadius.circular(14),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Your Position',
              style: GoogleFonts.inter(
                fontSize: 14,
                fontWeight: FontWeight.w700,
                color: ThemeV2.textPrimary,
              ),
            ),
            const SizedBox(height: 12),
            Row(
              children: [
                _positionTile('Shares', totalShares.toStringAsFixed(4)),
                _positionTile('Avg Cost', '\$${avgCost.toStringAsFixed(2)}'),
                _positionTile(
                  'Market Value',
                  '\$${totalValue.toStringAsFixed(2)}',
                ),
              ],
            ),
            const SizedBox(height: 8),
            Row(
              children: [
                Text(
                  '${isUp(pnl) ? '+' : ''}${pnl.toStringAsFixed(2)} (${pnlPercent.toStringAsFixed(2)}%)',
                  style: GoogleFonts.inter(
                    fontSize: 18,
                    fontWeight: FontWeight.w700,
                    color: pnl >= 0 ? ThemeV2.success : ThemeV2.loss,
                  ),
                ),
                const SizedBox(width: 6),
                Text(
                  pnl >= 0 ? 'all time' : 'all time',
                  style: GoogleFonts.inter(
                    fontSize: 11,
                    color: ThemeV2.textSecondary,
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _positionTile(String label, String value) => Expanded(
    child: Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: GoogleFonts.inter(fontSize: 11, color: ThemeV2.textSecondary),
        ),
        const SizedBox(height: 2),
        Text(
          value,
          style: GoogleFonts.inter(
            fontSize: 13,
            fontWeight: FontWeight.w600,
            color: ThemeV2.textPrimary,
          ),
        ),
      ],
    ),
  );

  bool isUp(double v) => v >= 0;
}

// ===========================================================================
// Events Stub
// ===========================================================================

class _EventsStub extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: ThemeV2.surface,
          borderRadius: BorderRadius.circular(14),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Upcoming Events',
              style: GoogleFonts.inter(
                fontSize: 14,
                fontWeight: FontWeight.w700,
                color: ThemeV2.textPrimary,
              ),
            ),
            const SizedBox(height: 12),
            Row(
              children: [
                Icon(Icons.event_rounded, size: 20, color: ThemeV2.textSecondary),
                const SizedBox(width: 8),
                Text(
                  'No upcoming events',
                  style: GoogleFonts.inter(
                    fontSize: 13,
                    color: ThemeV2.textSecondary,
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

// ===========================================================================
// News Section (inline, no tab)
// ===========================================================================

class _NewsSection extends StatelessWidget {
  final String symbol;
  final List<dynamic>? news;
  final bool isLoading;

  const _NewsSection({
    required this.symbol,
    this.news,
    required this.isLoading,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: const EdgeInsets.only(bottom: 12),
            child: Text(
              'News',
              style: GoogleFonts.inter(
                fontSize: 16,
                fontWeight: FontWeight.w700,
                color: ThemeV2.textPrimary,
              ),
            ),
          ),
          if (isLoading)
            const Center(
              child: Padding(
                padding: EdgeInsets.all(24),
                child: CircularProgressIndicator(color: ThemeV2.primary),
              ),
            )
          else if (news == null || news!.isEmpty)
            Center(
              child: Padding(
                padding: const EdgeInsets.all(24),
                child: Text(
                  'No news available',
                  style: GoogleFonts.inter(
                    color: ThemeV2.textSecondary,
                    fontSize: 13,
                  ),
                ),
              ),
            )
          else
            ...List.generate(news!.length.clamp(0, 5), (i) {
              final article = news![i] as Map<String, dynamic>;
              final headline = article['headline'] as String? ?? 'No title';
              final source = article['source'] as String? ?? '';
              final imageUrl = article['image'] as String?;
              final datetime = (article['datetime'] as num?)?.toInt() ?? 0;
              final dateStr = datetime > 0
                  ? _formatDate(
                      DateTime.fromMillisecondsSinceEpoch(datetime * 1000),
                    )
                  : '';

              return Container(
                margin: const EdgeInsets.only(bottom: 10),
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: ThemeV2.surface,
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            headline,
                            style: GoogleFonts.inter(
                              fontSize: 13,
                              fontWeight: FontWeight.w600,
                              color: ThemeV2.textPrimary,
                            ),
                            maxLines: 2,
                            overflow: TextOverflow.ellipsis,
                          ),
                          const SizedBox(height: 6),
                          Row(
                            children: [
                              if (source.isNotEmpty)
                                Text(
                                  source,
                                  style: GoogleFonts.inter(
                                    fontSize: 11,
                                    color: ThemeV2.primary,
                                    fontWeight: FontWeight.w500,
                                  ),
                                ),
                              if (source.isNotEmpty && dateStr.isNotEmpty)
                                Text(
                                  ' · ',
                                  style: GoogleFonts.inter(
                                    fontSize: 11,
                                    color: ThemeV2.textSecondary,
                                  ),
                                ),
                              if (dateStr.isNotEmpty)
                                Text(
                                  dateStr,
                                  style: GoogleFonts.inter(
                                    fontSize: 11,
                                    color: ThemeV2.textSecondary,
                                  ),
                                ),
                            ],
                          ),
                        ],
                      ),
                    ),
                    if (imageUrl != null && imageUrl.isNotEmpty)
                      Container(
                        width: 60,
                        height: 60,
                        margin: const EdgeInsets.only(left: 10),
                        child: ClipRRect(
                          borderRadius: BorderRadius.circular(8),
                          child: Image.network(
                            imageUrl,
                            fit: BoxFit.cover,
                            errorBuilder: (_, _, _) => const SizedBox.shrink(),
                          ),
                        ),
                      ),
                  ],
                ),
              );
            }),
        ],
      ),
    );
  }

  String _formatDate(DateTime dt) {
    final now = DateTime.now();
    final diff = now.difference(dt);
    if (diff.inHours < 1) return '${diff.inMinutes}m ago';
    if (diff.inHours < 24) return '${diff.inHours}h ago';
    if (diff.inDays < 7) return '${diff.inDays}d ago';
    return '${dt.month}/${dt.day}';
  }
}

// ===========================================================================
// Company Detail Widgets Settings BottomSheet
// ===========================================================================

class _CompanyWidgetsSettingsSheet extends StatefulWidget {
  final List<CompanyWidgetConfig> initialConfigs;
  final CompanyWidgetsNotifier notifier;

  const _CompanyWidgetsSettingsSheet({
    required this.initialConfigs,
    required this.notifier,
  });

  @override
  State<_CompanyWidgetsSettingsSheet> createState() =>
      _CompanyWidgetsSettingsSheetState();
}

class _CompanyWidgetsSettingsSheetState
    extends State<_CompanyWidgetsSettingsSheet> {
  late List<CompanyWidgetConfig> _configs;

  @override
  void initState() {
    super.initState();
    _configs = List.from(widget.initialConfigs);
  }

  void _onReorder(int oldIndex, int newIndex) {
    setState(() {
      final item = _configs.removeAt(oldIndex);
      _configs.insert(newIndex, item);
    });
    widget.notifier.reorder(_configs[newIndex].id, newIndex);
  }

  void _toggleVisibility(String id) {
    setState(() {
      final index = _configs.indexWhere((c) => c.id == id);
      if (index >= 0) {
        final current = _configs[index];
        _configs[index] = CompanyWidgetConfig(
          id: current.id,
          visible: !current.visible,
        );
      }
    });
    widget.notifier.toggleVisibility(id);
  }

  IconData _widgetIcon(String id) {
    switch (id) {
      case 'price_header':
        return Icons.business_rounded;
      case 'chart':
        return Icons.show_chart_rounded;
      case 'key_metrics':
        return Icons.analytics_rounded;
      case 'fs_score':
        return Icons.shield_rounded;
      case 'position':
        return Icons.account_balance_wallet_rounded;
      case 'events':
        return Icons.event_rounded;
      case 'news':
        return Icons.newspaper_rounded;
      default:
        return Icons.widgets_rounded;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.only(
        bottom: MediaQuery.of(context).viewInsets.bottom,
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          // Handle bar
          Container(
            margin: const EdgeInsets.only(top: 12, bottom: 8),
            width: 36,
            height: 4,
            decoration: BoxDecoration(
              color: Colors.black26,
              borderRadius: BorderRadius.circular(2),
            ),
          ),
          // Title
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
            child: Row(
              children: [
                Text(
                  'Widget Settings',
                  style: GoogleFonts.inter(
                    fontSize: 18,
                    fontWeight: FontWeight.w700,
                    color: ThemeV2.textPrimary,
                  ),
                ),
                const Spacer(),
                TextButton(
                  onPressed: () {
                    widget.notifier.resetToDefaults();
                    setState(() {
                      _configs = defaultCompanyWidgetOrder
                          .map(
                            (id) => CompanyWidgetConfig(id: id, visible: true),
                          )
                          .toList();
                    });
                  },
                  child: Text(
                    'Reset',
                    style: GoogleFonts.inter(
                      fontSize: 13,
                      color: ThemeV2.primary,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 4),
          // Reorderable list
          Flexible(
            child: ReorderableListView.builder(
              shrinkWrap: true,
              itemCount: _configs.length,
              onReorderItem: _onReorder,
              padding: const EdgeInsets.fromLTRB(16, 0, 16, 24),
              buildDefaultDragHandles: false,
              proxyDecorator: (child, index, animation) {
                return AnimatedBuilder(
                  animation: animation,
                  builder: (context, child) {
                    return Material(
                      color: Colors.transparent,
                      elevation: 4,
                      shadowColor: Colors.black45,
                      child: child!,
                    );
                  },
                  child: child,
                );
              },
              itemBuilder: (context, index) {
                final config = _configs[index];
                return Container(
                  key: ValueKey(config.id),
                  margin: const EdgeInsets.only(bottom: 8),
                  decoration: BoxDecoration(
                    color: config.visible
                        ? ThemeV2.surfaceDark
                        : ThemeV2.surfaceDark.withValues(alpha: 0.5),
                    borderRadius: BorderRadius.circular(14),
                    border: Border.all(
                      color: config.visible
                          ? Colors.black12
                          : Colors.black.withValues(alpha: 0.03),
                    ),
                  ),
                  child: ListTile(
                    key: ValueKey('${config.id}_tile'),
                    leading: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        // Drag handle
                        ReorderableDragStartListener(
                          index: index,
                          child: const Icon(
                            Icons.drag_handle_rounded,
                            color: ThemeV2.textSecondary,
                            size: 24,
                          ),
                        ),
                        const SizedBox(width: 8),
                        Icon(
                          _widgetIcon(config.id),
                          color: config.visible
                              ? ThemeV2.primary
                              : ThemeV2.textSecondary,
                          size: 22,
                        ),
                      ],
                    ),
                    title: Text(
                      config.displayName,
                      style: GoogleFonts.inter(
                        fontSize: 14,
                        fontWeight: FontWeight.w600,
                        color: config.visible
                            ? ThemeV2.textPrimary
                            : ThemeV2.textSecondary,
                      ),
                    ),
                    trailing: GestureDetector(
                      onTap: () => _toggleVisibility(config.id),
                      child: Icon(
                        config.visible
                            ? Icons.visibility_rounded
                            : Icons.visibility_off_rounded,
                        color: config.visible
                            ? ThemeV2.primary
                            : ThemeV2.textSecondary,
                        size: 22,
                      ),
                    ),
                  ),
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}

// ===========================================================================
// Sticky Bottom Bar: BUY / SELL
// ===========================================================================

class _BottomBar extends StatelessWidget {
  final double price;
  final bool isUp;
  final VoidCallback onBuy;
  final VoidCallback onSell;

  const _BottomBar({
    required this.price,
    required this.isUp,
    required this.onBuy,
    required this.onSell,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.only(
        top: 8,
        bottom: MediaQuery.of(context).padding.bottom + 8,
        left: 16,
        right: 16,
      ),
      decoration: BoxDecoration(
        color: Colors.transparent,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.06),
            blurRadius: 8,
            offset: const Offset(0, -2),
          ),
        ],
      ),
      child: Row(
        children: [
          // BUY button
          Expanded(
            child: SizedBox(
              height: 50,
              child: ElevatedButton(
                onPressed: onBuy,
                style: ElevatedButton.styleFrom(
                  backgroundColor: ThemeV2.success,
                  foregroundColor: Colors.white,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(14),
                  ),
                  elevation: 0,
                ),
                child: Text(
                  'BUY',
                  style: GoogleFonts.inter(
                    fontSize: 16,
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ),
            ),
          ),
          const SizedBox(width: 12),
          // SELL button
          Expanded(
            child: SizedBox(
              height: 50,
              child: ElevatedButton(
                onPressed: onSell,
                style: ElevatedButton.styleFrom(
                  backgroundColor: ThemeV2.loss,
                  foregroundColor: Colors.white,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(14),
                  ),
                  elevation: 0,
                ),
                child: Text(
                  'SELL',
                  style: GoogleFonts.inter(
                    fontSize: 16,
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

// ===========================================================================
// Simulated 3‑second ad overlay for company detail watch‑to‑continue flow
// ===========================================================================

class _CompanyAdOverlay extends StatefulWidget {
  final VoidCallback onComplete;
  const _CompanyAdOverlay({required this.onComplete});

  @override
  State<_CompanyAdOverlay> createState() => _CompanyAdOverlayState();
}

class _CompanyAdOverlayState extends State<_CompanyAdOverlay>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _progress;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 3),
    );
    _progress = CurvedAnimation(parent: _controller, curve: Curves.linear);
    _controller.forward();

    _controller.addStatusListener((status) {
      if (status == AnimationStatus.completed && mounted) {
        Navigator.of(context).pop();
        widget.onComplete();
      }
    });
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
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
                Icons.videocam_rounded,
                color: ThemeV2.primary,
                size: 48,
              ),
              const SizedBox(height: 24),
              Text(
                'Sponsored Ad',
                style: GoogleFonts.inter(
                  fontSize: 18,
                  fontWeight: FontWeight.w700,
                  color: ThemeV2.textPrimary,
                ),
              ),
              const SizedBox(height: 8),
              Text(
                'Continuing in a moment…',
                style: GoogleFonts.inter(fontSize: 14, color: ThemeV2.textSecondary),
              ),
              const SizedBox(height: 24),
              AnimatedBuilder(
                animation: _progress,
                builder: (context, child) {
                  return ClipRRect(
                    borderRadius: BorderRadius.circular(6),
                    child: LinearProgressIndicator(
                      value: _progress.value,
                      minHeight: 4,
                      backgroundColor: Colors.white12,
                      valueColor: const AlwaysStoppedAnimation<Color>(
                        ThemeV2.primary,
                      ),
                    ),
                  );
                },
              ),
            ],
          ),
        ),
      ),
    );
  }
}

