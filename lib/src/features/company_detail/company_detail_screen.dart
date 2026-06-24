import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:google_fonts/google_fonts.dart';
import 'dart:math';
import '../../core/theme/app_theme.dart';
import '../../shared/services/finnhub_service.dart';
import '../../shared/services/scoring_engine.dart';
import '../../shared/services/history_service.dart';
import '../home/home_providers.dart';
import '../portfolio/portfolio_providers.dart';
import '../../core/cache/logo_dao.dart';
import '../../core/models/logo_cache_entry.dart';
import 'company_cache_provider.dart';
import 'widgets/price_chart.dart';

// ---------------------------------------------------------------------------
// Providers — with 4-hour per-ticker cache
// ---------------------------------------------------------------------------

final companyDetailProvider =
    FutureProvider.family<Map<String, dynamic>, String>((ref, symbol) async {
      final cache = ref.read(companyCacheProvider);

      // Check per-ticker cache first (4h TTL)
      final cached = cache.get(symbol);
      if (cached != null) return cached;

      // Fetch fresh data from API
      final api = FinnhubService();
      final profile = await api.companyProfile(symbol);
      final quote = await api.quote(symbol);
      final metrics = await api.metrics(symbol);
      final score = ScoringEngine.calculate(metrics);

      // Сохранить логотип в LogoCache (если есть и нет в кэше)
      _cacheLogo(symbol, profile);

      final data = {
        'profile': profile,
        'quote': quote,
        'metrics': metrics,
        'score': score,
      };

      // Store in per-ticker cache
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
    final logoUrl = finnhubLogo ??
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

class CompanyDetailScreen extends ConsumerWidget {
  final String symbol;

  const CompanyDetailScreen({super.key, required this.symbol});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final asyncData = ref.watch(companyDetailProvider(symbol));

    return Scaffold(
      backgroundColor: AppTheme.background,
      body: asyncData.when(
        loading: () => const Center(
          child: CircularProgressIndicator(color: AppTheme.accentBlue),
        ),
        error: (err, _) => Center(
          child: Padding(
            padding: const EdgeInsets.all(24),
            child: Text(
              'Failed to load company data',
              style: GoogleFonts.inter(color: AppTheme.dangerRed, fontSize: 16),
              textAlign: TextAlign.center,
            ),
          ),
        ),
        data: (data) => _CompanyDetailBody(symbol: symbol, data: data),
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

class _CompanyDetailBodyState extends ConsumerState<_CompanyDetailBody>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;
  final FinnhubService _api = FinnhubService();
  List<dynamic>? _news;
  bool _newsLoading = false;
  Map<String, dynamic>? _wikiData;
  bool _wikiLoading = false;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 5, vsync: this);
    _loadNews();
    _loadWiki();
    _cacheDetailLogo();
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  Future<void> _loadNews() async {
    setState(() => _newsLoading = true);
    try {
      _news = await _api.companyNews(widget.symbol);
    } catch (_) {}
    if (mounted) setState(() => _newsLoading = false);
  }

  Future<void> _loadWiki() async {
    setState(() => _wikiLoading = true);
    try {
      final profile = widget.data['profile'] as Map<String, dynamic>? ?? {};
      final companyName = (profile['name'] as String? ?? widget.symbol)
          .replaceAll(
            RegExp(r'\s+(Inc|Corp|Corporation|Ltd|PLC|Group|Co\.?)$'),
            '',
          );
      final service = HistoryService();
      _wikiData = await service.fetchSummary(companyName);
    } catch (_) {}
    if (mounted) setState(() => _wikiLoading = false);
  }

  Future<void> _cacheDetailLogo() async {
    final profile = widget.data['profile'] as Map<String, dynamic>? ?? {};
    await _cacheLogo(widget.symbol, profile);
  }

  @override
  Widget build(BuildContext context) {
    final profile = widget.data['profile'] as Map<String, dynamic>? ?? {};
    final quote = widget.data['quote'] as Map<String, dynamic>? ?? {};
    final score = widget.data['score'] as Map<String, dynamic>? ?? {};

    final companyName = profile['name'] as String? ?? widget.symbol;
    final logo = profile['logo'] as String?;
    final price = (quote['c'] as num?)?.toDouble() ?? 0;
    final change = (quote['d'] as num?)?.toDouble() ?? 0;
    final changePercent = (quote['dp'] as num?)?.toDouble() ?? 0;
    final fsScore = (score['fs_score'] as num?)?.toInt() ?? 0;

    return NestedScrollView(
      headerSliverBuilder: (context, innerBoxIsScrolled) => [
        SliverAppBar(
          expandedHeight: 220,
          pinned: true,
          backgroundColor: AppTheme.background,
          leading: IconButton(
            icon: const Icon(Icons.arrow_back_rounded, color: Colors.white),
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
                        ? AppTheme.accentBlue
                        : AppTheme.textDim,
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
          ],
          flexibleSpace: FlexibleSpaceBar(
            background: Container(
              padding: const EdgeInsets.fromLTRB(20, 80, 20, 20),
              decoration: const BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                  colors: [Color(0xFF0B1018), Color(0xFF141B26)],
                ),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  Row(
                    children: [
                      if (logo != null && logo.isNotEmpty)
                        ClipRRect(
                          borderRadius: BorderRadius.circular(8),
                          child: Image.network(
                            logo,
                            width: 40,
                            height: 40,
                            errorBuilder: (_, __, ___) => _defaultLogo(),
                          ),
                        )
                      else
                        _defaultLogo(),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              companyName,
                              style: GoogleFonts.inter(
                                fontSize: 18,
                                fontWeight: FontWeight.w700,
                                color: Colors.white,
                              ),
                            ),
                            Text(
                              widget.symbol,
                              style: GoogleFonts.inter(
                                fontSize: 13,
                                color: AppTheme.textDim,
                              ),
                            ),
                          ],
                        ),
                      ),
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.end,
                        children: [
                          Text(
                            '\$${price.toStringAsFixed(2)}',
                            style: GoogleFonts.inter(
                              fontSize: 22,
                              fontWeight: FontWeight.w700,
                              color: Colors.white,
                            ),
                          ),
                          Row(
                            children: [
                              Icon(
                                change >= 0
                                    ? Icons.trending_up_rounded
                                    : Icons.trending_down_rounded,
                                size: 16,
                                color: change >= 0
                                    ? AppTheme.shieldGreen
                                    : AppTheme.dangerRed,
                              ),
                              const SizedBox(width: 4),
                              Text(
                                '${change >= 0 ? '+' : ''}${change.toStringAsFixed(2)} (${changePercent.toStringAsFixed(2)}%)',
                                style: GoogleFonts.inter(
                                  fontSize: 13,
                                  fontWeight: FontWeight.w600,
                                  color: change >= 0
                                      ? AppTheme.shieldGreen
                                      : AppTheme.dangerRed,
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ],
                  ),
                  const SizedBox(height: 16),
                  // FS Score mini badge
                  Row(
                    children: [
                      _fsScoreBadge(fsScore),
                      const SizedBox(width: 12),
                      Text(
                        'FS Score',
                        style: GoogleFonts.inter(
                          fontSize: 13,
                          color: AppTheme.textDim,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
          bottom: TabBar(
            controller: _tabController,
            indicatorColor: AppTheme.accentBlue,
            labelColor: Colors.white,
            unselectedLabelColor: AppTheme.textDim,
            labelStyle: GoogleFonts.inter(
              fontSize: 12,
              fontWeight: FontWeight.w600,
            ),
            unselectedLabelStyle: GoogleFonts.inter(fontSize: 12),
            isScrollable: true,
            tabAlignment: TabAlignment.start,
            tabs: const [
              Tab(text: 'Overview'),
              Tab(text: 'FS Audit'),
              Tab(text: 'History'),
              Tab(text: 'News'),
              Tab(text: 'Add to Portfolio'),
            ],
          ),
        ),
      ],
      body: TabBarView(
        controller: _tabController,
        children: [
          _OverviewTab(
            symbol: widget.symbol,
            profile: profile,
            quote: quote,
            score: score,
          ),
          _FsAuditTab(score: score),
          _HistoryTab(
            symbol: widget.symbol,
            wikiData: _wikiData,
            isLoading: _wikiLoading,
          ),
          _NewsTab(symbol: widget.symbol, news: _news, isLoading: _newsLoading),
          _AddPortfolioTab(symbol: widget.symbol, price: price),
        ],
      ),
    );
  }

  Widget _defaultLogo() => Container(
    width: 40,
    height: 40,
    decoration: BoxDecoration(
      color: AppTheme.card,
      borderRadius: BorderRadius.circular(8),
    ),
    child: const Icon(
      Icons.business_rounded,
      color: AppTheme.accentBlue,
      size: 22,
    ),
  );

  Widget _fsScoreBadge(int score) {
    final color = score >= 70
        ? AppTheme.shieldGreen
        : score >= 40
        ? AppTheme.shieldYellow
        : AppTheme.dangerRed;
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.15),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: color.withValues(alpha: 0.4)),
      ),
      child: Text(
        '$score/100',
        style: GoogleFonts.inter(
          fontSize: 13,
          fontWeight: FontWeight.w700,
          color: color,
        ),
      ),
    );
  }
}

// ===========================================================================
// Overview Tab
// ===========================================================================

class _OverviewTab extends StatelessWidget {
  final String symbol;
  final Map<String, dynamic> profile;
  final Map<String, dynamic> quote;
  final Map<String, dynamic> score;

  const _OverviewTab({
    required this.symbol,
    required this.profile,
    required this.quote,
    required this.score,
  });

  @override
  Widget build(BuildContext context) {
    final description =
        profile['description'] as String? ?? 'No description available.';
    final industry = profile['finnhubIndustry'] as String? ?? 'N/A';
    final mktCap = (profile['marketCapitalization'] as num?)?.toDouble() ?? 0;
    final shareOutstanding =
        (profile['shareOutstanding'] as num?)?.toDouble() ?? 0;
    final ipo = profile['ipo'] as String? ?? 'N/A';
    final country = profile['country'] as String? ?? 'N/A';
    final exchange = profile['exchange'] as String? ?? 'N/A';
    final currency = profile['currency'] as String? ?? 'USD';

    final high = (quote['h'] as num?)?.toDouble() ?? 0;
    final low = (quote['l'] as num?)?.toDouble() ?? 0;
    final open = (quote['o'] as num?)?.toDouble() ?? 0;
    final prevClose = (quote['pc'] as num?)?.toDouble() ?? 0;

    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Business Description
          _sectionTitle('Business Overview'),
          const SizedBox(height: 8),
          Text(
            description,
            style: GoogleFonts.inter(
              fontSize: 14,
              color: Colors.white70,
              height: 1.6,
            ),
          ),

          const SizedBox(height: 24),

          // Price Chart
          _sectionTitle('Price Chart'),
          const SizedBox(height: 8),
          PriceChart(symbol: symbol),
          const SizedBox(height: 24),

          // Key Statistics
          _sectionTitle('Key Statistics'),
          const SizedBox(height: 8),
          _infoGrid({
            'Industry': industry,
            'Market Cap': _fmtMarketCap(mktCap),
            'Shares Outstanding': _fmtNumber(shareOutstanding),
            'IPO Date': ipo,
            'Country': country,
            'Exchange': exchange,
            'Currency': currency,
          }),

          const SizedBox(height: 24),

          // Today's Trading
          _sectionTitle("Today's Trading"),
          const SizedBox(height: 8),
          _infoGrid({
            'Open': '\$${open.toStringAsFixed(2)}',
            'High': '\$${high.toStringAsFixed(2)}',
            'Low': '\$${low.toStringAsFixed(2)}',
            'Prev. Close': '\$${prevClose.toStringAsFixed(2)}',
          }),

          const SizedBox(height: 32),
        ],
      ),
    );
  }

  Widget _sectionTitle(String title) => Text(
    title,
    style: GoogleFonts.inter(
      fontSize: 16,
      fontWeight: FontWeight.w700,
      color: Colors.white,
    ),
  );

  Widget _infoGrid(Map<String, String> items) {
    final entries = items.entries.toList();
    return Column(
      children: List.generate((entries.length + 1) ~/ 2, (rowIdx) {
        return Padding(
          padding: const EdgeInsets.only(bottom: 8),
          child: Row(
            children: List.generate(2, (colIdx) {
              final idx = rowIdx * 2 + colIdx;
              if (idx >= entries.length)
                return const Expanded(child: SizedBox());
              final entry = entries[idx];
              return Expanded(
                child: Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: AppTheme.card,
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        entry.key,
                        style: GoogleFonts.inter(
                          fontSize: 11,
                          color: AppTheme.textDim,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        entry.value,
                        style: GoogleFonts.inter(
                          fontSize: 14,
                          fontWeight: FontWeight.w600,
                          color: Colors.white,
                        ),
                      ),
                    ],
                  ),
                ),
              );
            }),
            crossAxisAlignment: CrossAxisAlignment.start,
          ),
        );
      }),
    );
  }

  String _fmtMarketCap(double val) {
    if (val >= 1000) return '\$${(val / 1000).toStringAsFixed(2)}T';
    return '\$${val.toStringAsFixed(2)}B';
  }

  String _fmtNumber(double val) {
    if (val >= 1000) return '${(val / 1000).toStringAsFixed(2)}B';
    if (val >= 1) return '${val.toStringAsFixed(2)}B';
    return '${(val * 1000).toStringAsFixed(2)}M';
  }
}

// ===========================================================================
// FS Audit Tab (Radar Chart)
// ===========================================================================

class _FsAuditTab extends StatelessWidget {
  final Map<String, dynamic> score;

  const _FsAuditTab({required this.score});

  @override
  Widget build(BuildContext context) {
    final markers = score['markers'] as Map<String, dynamic>? ?? {};
    final fsScore = (score['fs_score'] as num?)?.toInt() ?? 0;
    final penalty = (score['dividend_trap_penalty'] as num?)?.toInt() ?? 0;

    if (markers.isEmpty) {
      return Center(
        child: Text(
          'FS Score data not available',
          style: GoogleFonts.inter(color: AppTheme.textDim, fontSize: 14),
        ),
      );
    }

    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        children: [
          // FS Score Gauge
          _FsScoreGauge(score: fsScore),
          const SizedBox(height: 8),
          if (penalty > 0)
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
              decoration: BoxDecoration(
                color: AppTheme.dangerRed.withValues(alpha: 0.1),
                borderRadius: BorderRadius.circular(8),
                border: Border.all(
                  color: AppTheme.dangerRed.withValues(alpha: 0.3),
                ),
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  const Icon(
                    Icons.warning_amber_rounded,
                    size: 16,
                    color: AppTheme.dangerRed,
                  ),
                  const SizedBox(width: 8),
                  Text(
                    'Dividend trap penalty: -$penalty pts',
                    style: GoogleFonts.inter(
                      fontSize: 12,
                      color: AppTheme.dangerRed,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ],
              ),
            ),

          const SizedBox(height: 24),

          // Radar Chart
          SizedBox(height: 280, child: _RadarChart(markers: markers)),

          const SizedBox(height: 24),

          // Marker Details
          ...markers.entries.map((entry) {
            final marker = Map<String, dynamic>.from(entry.value);
            final name = marker['name'] as String? ?? entry.key;
            final markerScore = (marker['score'] as num?)?.toInt() ?? 0;
            final description = marker['description'] as String? ?? '';
            final details = marker['details'] as String? ?? '';
            final color = _markerColor(markerScore);

            return Container(
              margin: const EdgeInsets.only(bottom: 12),
              padding: const EdgeInsets.all(14),
              decoration: BoxDecoration(
                color: AppTheme.card,
                borderRadius: BorderRadius.circular(12),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Expanded(
                        child: Text(
                          name,
                          style: GoogleFonts.inter(
                            fontSize: 14,
                            fontWeight: FontWeight.w600,
                            color: Colors.white,
                          ),
                        ),
                      ),
                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 8,
                          vertical: 2,
                        ),
                        decoration: BoxDecoration(
                          color: color.withValues(alpha: 0.15),
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: Text(
                          '$markerScore',
                          style: GoogleFonts.inter(
                            fontSize: 13,
                            fontWeight: FontWeight.w700,
                            color: color,
                          ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 4),
                  Text(
                    description,
                    style: GoogleFonts.inter(
                      fontSize: 12,
                      color: AppTheme.textDim,
                    ),
                  ),
                  const SizedBox(height: 6),
                  // Mini progress bar
                  ClipRRect(
                    borderRadius: BorderRadius.circular(4),
                    child: LinearProgressIndicator(
                      value: markerScore / 100,
                      backgroundColor: AppTheme.cardDark,
                      valueColor: AlwaysStoppedAnimation(color),
                      minHeight: 4,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    details,
                    style: GoogleFonts.inter(
                      fontSize: 11,
                      color: color,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ],
              ),
            );
          }),

          const SizedBox(height: 16),
        ],
      ),
    );
  }

  Color _markerColor(int score) {
    if (score >= 70) return AppTheme.shieldGreen;
    if (score >= 40) return AppTheme.shieldYellow;
    return AppTheme.dangerRed;
  }
}

// ===========================================================================
// FS Score Gauge Widget
// ===========================================================================

class _FsScoreGauge extends StatelessWidget {
  final int score;
  const _FsScoreGauge({required this.score});

  @override
  Widget build(BuildContext context) {
    final color = score >= 70
        ? AppTheme.shieldGreen
        : score >= 40
        ? AppTheme.shieldYellow
        : AppTheme.dangerRed;

    return Container(
      width: 140,
      height: 140,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        color: AppTheme.card,
        border: Border.all(color: color.withValues(alpha: 0.3), width: 2),
      ),
      child: Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              '$score',
              style: GoogleFonts.inter(
                fontSize: 40,
                fontWeight: FontWeight.w800,
                color: color,
              ),
            ),
            Text(
              'FS SCORE',
              style: GoogleFonts.inter(
                fontSize: 10,
                fontWeight: FontWeight.w700,
                letterSpacing: 2,
                color: AppTheme.textDim,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// ===========================================================================
// Radar Chart Widget
// ===========================================================================

class _RadarChart extends StatelessWidget {
  final Map<String, dynamic> markers;
  const _RadarChart({required this.markers});

  @override
  Widget build(BuildContext context) {
    return CustomPaint(
      painter: _RadarChartPainter(markers: markers),
      size: const Size(double.infinity, 280),
    );
  }
}

class _RadarChartPainter extends CustomPainter {
  final Map<String, dynamic> markers;

  _RadarChartPainter({required this.markers});

  @override
  void paint(Canvas canvas, Size size) {
    final center = Offset(size.width / 2, size.height / 2);
    final radius = size.height / 2 - 30;
    final entries = markers.entries.toList();
    final n = entries.length;
    if (n == 0) return;

    final angleStep = (2 * 3.14159) / n;

    // Draw grid
    final gridPaint = Paint()
      ..color = const Color(0xFF1A2235)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1;

    for (int ring = 1; ring <= 5; ring++) {
      final r = radius * ring / 5;
      final path = Path();
      for (int i = 0; i < n; i++) {
        final angle = -3.14159 / 2 + i * angleStep;
        final x = center.dx + r * cos(angle);
        final y = center.dy + r * sin(angle);
        if (i == 0) {
          path.moveTo(x, y);
        } else {
          path.lineTo(x, y);
        }
      }
      path.close();
      canvas.drawPath(path, gridPaint);
    }

    // Draw axis lines
    final axisPaint = Paint()
      ..color = const Color(0xFF1A2235)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1;

    for (int i = 0; i < n; i++) {
      final angle = -3.14159 / 2 + i * angleStep;
      final x = center.dx + radius * cos(angle);
      final y = center.dy + radius * sin(angle);
      canvas.drawLine(center, Offset(x, y), axisPaint);
    }

    // Draw data
    final dataPaint = Paint()
      ..color = const Color(0xFF00B4D8).withValues(alpha: 0.6)
      ..style = PaintingStyle.fill;

    final dataStrokePaint = Paint()
      ..color = const Color(0xFF00B4D8)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 2;

    final dataPath = Path();
    for (int i = 0; i < n; i++) {
      final marker = Map<String, dynamic>.from(entries[i].value);
      final score = (marker['score'] as num?)?.toDouble() ?? 0;
      final angle = -3.14159 / 2 + i * angleStep;
      final r = radius * score / 100;
      final x = center.dx + r * cos(angle);
      final y = center.dy + r * sin(angle);
      if (i == 0) {
        dataPath.moveTo(x, y);
      } else {
        dataPath.lineTo(x, y);
      }
    }
    dataPath.close();
    canvas.drawPath(dataPath, dataPaint);
    canvas.drawPath(dataPath, dataStrokePaint);

    // Draw labels
    for (int i = 0; i < n; i++) {
      final marker = Map<String, dynamic>.from(entries[i].value);
      final name = marker['name'] as String? ?? entries[i].key;
      final score = (marker['score'] as num?)?.toInt() ?? 0;
      final angle = -3.14159 / 2 + i * angleStep;
      final labelR = radius + 20;
      final x = center.dx + labelR * cos(angle);
      final y = center.dy + labelR * sin(angle);

      final textPainter = TextPainter(
        text: TextSpan(
          text: '$name\n$score',
          style: TextStyle(
            color: AppTheme.textDim,
            fontSize: 10,
            fontFamily: 'Inter',
          ),
        ),
        textDirection: TextDirection.ltr,
        textAlign: TextAlign.center,
      );
      textPainter.layout(maxWidth: 80);
      textPainter.paint(
        canvas,
        Offset(x - textPainter.width / 2, y - textPainter.height / 2),
      );
    }
  }

  @override
  bool shouldRepaint(covariant _RadarChartPainter oldDelegate) => true;
}

// ===========================================================================
// History Tab
// ===========================================================================

class _HistoryTab extends StatelessWidget {
  final String symbol;
  final Map<String, dynamic>? wikiData;
  final bool isLoading;

  const _HistoryTab({
    required this.symbol,
    required this.wikiData,
    required this.isLoading,
  });

  @override
  Widget build(BuildContext context) {
    if (isLoading) {
      return const Center(
        child: CircularProgressIndicator(color: AppTheme.accentBlue),
      );
    }

    if (wikiData == null) {
      return Center(
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Icon(
                Icons.history_rounded,
                size: 64,
                color: AppTheme.textDim,
              ),
              const SizedBox(height: 16),
              Text(
                'History not available for $symbol',
                textAlign: TextAlign.center,
                style: GoogleFonts.inter(fontSize: 16, color: AppTheme.textDim),
              ),
            ],
          ),
        ),
      );
    }

    final extract = wikiData!['extract'] as String? ?? '';
    final title = wikiData!['title'] as String? ?? '';
    final sourceUrl = wikiData!['content_urls']?['desktop']?['page'] as String?;
    final thumbnail = wikiData!['thumbnail']?['source'] as String?;

    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          if (thumbnail != null)
            ClipRRect(
              borderRadius: BorderRadius.circular(12),
              child: Image.network(
                thumbnail,
                width: double.infinity,
                height: 180,
                fit: BoxFit.cover,
                errorBuilder: (_, __, ___) => const SizedBox(),
              ),
            ),
          if (thumbnail != null) const SizedBox(height: 16),

          Text(
            title,
            style: GoogleFonts.inter(
              fontSize: 18,
              fontWeight: FontWeight.w700,
              color: Colors.white,
            ),
          ),
          const SizedBox(height: 12),
          Text(
            extract,
            style: GoogleFonts.inter(
              fontSize: 14,
              color: Colors.white70,
              height: 1.7,
            ),
          ),
          if (sourceUrl != null) ...[
            const SizedBox(height: 16),
            InkWell(
              onTap: () {
                /* TODO: url_launcher */
              },
              child: Text(
                'Read more on Wikipedia →',
                style: GoogleFonts.inter(
                  fontSize: 13,
                  color: AppTheme.accentBlue,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
          ],
          const SizedBox(height: 32),
        ],
      ),
    );
  }
}

// ===========================================================================
// News Tab
// ===========================================================================

class _NewsTab extends StatelessWidget {
  final String symbol;
  final List<dynamic>? news;
  final bool isLoading;

  const _NewsTab({
    required this.symbol,
    required this.news,
    required this.isLoading,
  });

  @override
  Widget build(BuildContext context) {
    if (isLoading) {
      return const Center(
        child: CircularProgressIndicator(color: AppTheme.accentBlue),
      );
    }

    if (news == null || news!.isEmpty) {
      return Center(
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Icon(
                Icons.newspaper_rounded,
                size: 64,
                color: AppTheme.textDim,
              ),
              const SizedBox(height: 16),
              Text(
                'No recent news for $symbol',
                style: GoogleFonts.inter(fontSize: 16, color: AppTheme.textDim),
              ),
            ],
          ),
        ),
      );
    }

    return ListView.separated(
      padding: const EdgeInsets.all(16),
      itemCount: news!.length,
      separatorBuilder: (_, __) => const SizedBox(height: 12),
      itemBuilder: (context, i) {
        final article = Map<String, dynamic>.from(news![i]);
        final headline = article['headline'] as String? ?? '';
        final summary = article['summary'] as String? ?? '';
        final source = article['source'] as String? ?? '';
        final datetime = (article['datetime'] as num?)?.toInt() ?? 0;
        final dateStr = datetime > 0
            ? DateTime.fromMillisecondsSinceEpoch(datetime * 1000)
            : null;
        final imageUrl = article['image'] as String?;

        return Container(
          key: ValueKey('$headline\_$datetime'),
          decoration: BoxDecoration(
            color: AppTheme.card,
            borderRadius: BorderRadius.circular(12),
          ),
          clipBehavior: Clip.antiAlias,
          child: InkWell(
            onTap: () {
              /* TODO: url_launcher */
            },
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                if (imageUrl != null && imageUrl.isNotEmpty)
                  Image.network(
                    imageUrl,
                    width: double.infinity,
                    height: 160,
                    fit: BoxFit.cover,
                    errorBuilder: (_, __, ___) => const SizedBox(),
                  ),
                Padding(
                  padding: const EdgeInsets.all(14),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        headline,
                        style: GoogleFonts.inter(
                          fontSize: 14,
                          fontWeight: FontWeight.w600,
                          color: Colors.white,
                        ),
                      ),
                      const SizedBox(height: 6),
                      Text(
                        summary,
                        maxLines: 3,
                        overflow: TextOverflow.ellipsis,
                        style: GoogleFonts.inter(
                          fontSize: 12,
                          color: Colors.white60,
                          height: 1.5,
                        ),
                      ),
                      const SizedBox(height: 8),
                      Row(
                        children: [
                          Text(
                            source,
                            style: GoogleFonts.inter(
                              fontSize: 11,
                              color: AppTheme.accentBlue,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                          const Spacer(),
                          if (dateStr != null)
                            Text(
                              '${dateStr.day}.${dateStr.month}.${dateStr.year}',
                              style: GoogleFonts.inter(
                                fontSize: 11,
                                color: AppTheme.textDim,
                              ),
                            ),
                        ],
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }
}

// ===========================================================================
// Add to Portfolio Tab
// ===========================================================================

class _AddPortfolioTab extends ConsumerStatefulWidget {
  final String symbol;
  final double price;

  const _AddPortfolioTab({required this.symbol, required this.price});

  @override
  ConsumerState<_AddPortfolioTab> createState() => _AddPortfolioTabState();
}

class _AddPortfolioTabState extends ConsumerState<_AddPortfolioTab> {
  final _sharesController = TextEditingController();
  String? _selectedPortfolioId;

  @override
  void dispose() {
    _sharesController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final portfolios = ref.watch(portfoliosProvider);
    final total = (double.tryParse(_sharesController.text) ?? 0) * widget.price;

    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Icon(
            Icons.add_shopping_cart_rounded,
            size: 48,
            color: AppTheme.accentBlue,
          ),
          const SizedBox(height: 16),
          Text(
            'Add ${widget.symbol} to Portfolio',
            style: GoogleFonts.inter(
              fontSize: 20,
              fontWeight: FontWeight.w700,
              color: Colors.white,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            'Current price: \$${widget.price.toStringAsFixed(2)}',
            style: GoogleFonts.inter(fontSize: 14, color: AppTheme.textDim),
          ),

          const SizedBox(height: 24),

          // Portfolio selector
          Text(
            'Portfolio',
            style: GoogleFonts.inter(
              fontSize: 14,
              fontWeight: FontWeight.w600,
              color: Colors.white,
            ),
          ),
          const SizedBox(height: 8),
          DropdownButtonFormField<String>(
            value: _selectedPortfolioId,
            items: [
              ...portfolios.map(
                (p) => DropdownMenuItem(value: p.id, child: Text(p.name)),
              ),
              const DropdownMenuItem(
                value: '__new__',
                child: Text(
                  '+ New Portfolio...',
                  style: TextStyle(color: AppTheme.accentBlue),
                ),
              ),
            ],
            onChanged: (v) {
              if (v == '__new__') {
                _showCreatePortfolioDialog();
              } else {
                setState(() => _selectedPortfolioId = v);
              }
            },
            dropdownColor: AppTheme.card,
            style: GoogleFonts.inter(color: Colors.white, fontSize: 14),
            decoration: _inputDecoration(),
          ),

          const SizedBox(height: 16),

          // Shares input
          Text(
            'Number of Shares',
            style: GoogleFonts.inter(
              fontSize: 14,
              fontWeight: FontWeight.w600,
              color: Colors.white,
            ),
          ),
          const SizedBox(height: 8),
          TextField(
            controller: _sharesController,
            keyboardType: TextInputType.number,
            style: GoogleFonts.inter(color: Colors.white, fontSize: 16),
            decoration: _inputDecoration(hint: 'Enter shares...'),
            onChanged: (_) => setState(() {}),
          ),

          const SizedBox(height: 16),

          // Total
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: AppTheme.card,
              borderRadius: BorderRadius.circular(12),
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  'Total Cost',
                  style: GoogleFonts.inter(
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                    color: Colors.white,
                  ),
                ),
                Text(
                  '\$${total.toStringAsFixed(2)}',
                  style: GoogleFonts.inter(
                    fontSize: 18,
                    fontWeight: FontWeight.w800,
                    color: AppTheme.accentBlue,
                  ),
                ),
              ],
            ),
          ),

          const SizedBox(height: 24),

          // Cash remaining warning
          if (_selectedPortfolioId != null) ...[
            Consumer(
              builder: (context, ref, _) {
                final p = portfolios
                    .where((p) => p.id == _selectedPortfolioId)
                    .firstOrNull;
                if (p == null) return const SizedBox.shrink();
                final remaining = p.cash;
                final cost = total;
                final enough = cost <= remaining;
                return Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: (enough ? AppTheme.shieldGreen : AppTheme.dangerRed)
                        .withValues(alpha: 0.1),
                    borderRadius: BorderRadius.circular(10),
                    border: Border.all(
                      color:
                          (enough ? AppTheme.shieldGreen : AppTheme.dangerRed)
                              .withValues(alpha: 0.3),
                    ),
                  ),
                  child: Row(
                    children: [
                      Icon(
                        enough
                            ? Icons.check_circle_rounded
                            : Icons.warning_rounded,
                        size: 18,
                        color: enough
                            ? AppTheme.shieldGreen
                            : AppTheme.dangerRed,
                      ),
                      const SizedBox(width: 8),
                      Expanded(
                        child: Text(
                          enough
                              ? '\$${remaining.toStringAsFixed(2)} available in ${p.name}'
                              : 'Insufficient funds — need \$${(cost - remaining).toStringAsFixed(2)} more',
                          style: GoogleFonts.inter(
                            fontSize: 12,
                            color: Colors.white,
                          ),
                        ),
                      ),
                    ],
                  ),
                );
              },
            ),
            const SizedBox(height: 16),
          ],

          // Add button
          SizedBox(
            width: double.infinity,
            height: 50,
            child: ElevatedButton(
              onPressed:
                  (_selectedPortfolioId == null ||
                      _sharesController.text.isEmpty ||
                      double.tryParse(_sharesController.text) == null ||
                      (double.tryParse(_sharesController.text) ?? 0) <= 0)
                  ? null
                  : () {
                      final shares = double.parse(_sharesController.text);
                      final p = portfolios
                          .where((p) => p.id == _selectedPortfolioId)
                          .firstOrNull;
                      if (p == null) return;
                      if (shares * widget.price > p.cash) {
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(
                            content: Text(
                              'Insufficient funds in ${p.name}',
                              style: GoogleFonts.inter(fontSize: 13),
                            ),
                            backgroundColor: AppTheme.dangerRed,
                          ),
                        );
                        return;
                      }
                      ref
                          .read(portfoliosProvider.notifier)
                          .addTransaction(
                            _selectedPortfolioId!,
                            Transaction(
                              symbol: widget.symbol,
                              type: TransactionType.buy,
                              shares: shares,
                              price: widget.price,
                              date: DateTime.now(),
                            ),
                          );
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(
                          content: Text(
                            'Added ${_sharesController.text} ${widget.symbol} to ${portfolios.where((p) => p.id == _selectedPortfolioId).firstOrNull?.name ?? ''}',
                            style: GoogleFonts.inter(fontSize: 13),
                          ),
                          backgroundColor: AppTheme.shieldGreen,
                        ),
                      );
                      _sharesController.clear();
                    },
              style: ElevatedButton.styleFrom(
                backgroundColor: AppTheme.accentBlue,
                foregroundColor: Colors.white,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
              child: Text(
                'Add to Portfolio',
                style: GoogleFonts.inter(
                  fontSize: 16,
                  fontWeight: FontWeight.w700,
                ),
              ),
            ),
          ),

          const SizedBox(height: 32),
        ],
      ),
    );
  }

  void _showCreatePortfolioDialog() {
    final controller = TextEditingController();
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        backgroundColor: AppTheme.card,
        title: Text(
          'New Portfolio',
          style: GoogleFonts.inter(
            fontSize: 18,
            fontWeight: FontWeight.w700,
            color: Colors.white,
          ),
        ),
        content: TextField(
          controller: controller,
          autofocus: true,
          decoration: InputDecoration(
            hintText: 'e.g. Tech Growth',
            hintStyle: GoogleFonts.inter(color: AppTheme.textDim, fontSize: 14),
            filled: true,
            fillColor: AppTheme.cardDark,
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(10),
              borderSide: BorderSide.none,
            ),
          ),
          style: GoogleFonts.inter(color: Colors.white, fontSize: 14),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: Text(
              'Cancel',
              style: GoogleFonts.inter(color: AppTheme.textDim),
            ),
          ),
          TextButton(
            onPressed: () {
              if (controller.text.trim().isNotEmpty) {
                ref
                    .read(portfoliosProvider.notifier)
                    .addPortfolio(controller.text.trim());
                // Get the newly created portfolio
                final updated = ref.read(portfoliosProvider);
                final newest = updated.last;
                setState(() => _selectedPortfolioId = newest.id);
                Navigator.pop(ctx);
              }
            },
            child: Text(
              'Create',
              style: GoogleFonts.inter(
                color: AppTheme.accentBlue,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
        ],
      ),
    );
  }

  InputDecoration _inputDecoration({String? hint}) => InputDecoration(
    hintText: hint,
    hintStyle: GoogleFonts.inter(color: AppTheme.textDim, fontSize: 14),
    filled: true,
    fillColor: AppTheme.card,
    contentPadding: const EdgeInsets.symmetric(horizontal: 14, vertical: 14),
    border: OutlineInputBorder(
      borderRadius: BorderRadius.circular(10),
      borderSide: BorderSide.none,
    ),
  );
}
