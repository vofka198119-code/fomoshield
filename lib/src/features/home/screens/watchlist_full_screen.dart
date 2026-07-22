import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:intl/intl.dart';
import 'package:url_launcher/url_launcher.dart';
import '../../../core/theme/theme_v2.dart';
import '../../../core/theme/typography_helpers.dart';
import '../../../core/theme/fomo_shield_theme.dart';
import '../../../core/cache/sector_providers.dart';
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
  bool _showAllEvents = false;

  Future<void> _navigateToSearch() async {
    if (_isNavigating) return;
    setState(() => _isNavigating = true);
    await context.push('/search');
    if (mounted) setState(() => _isNavigating = false);
  }

  @override
  Widget build(BuildContext context) {
    final watchlistSymbols = ref.watch(watchlistSymbolsProvider);
    final watchlistQuotesAsync = ref.watch(watchlistQuotesProvider);

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
        actions: [
          IconButton(
            icon: const Icon(Icons.add_rounded, color: ThemeV2.primary),
            tooltip: 'Add company',
            onPressed: _isNavigating ? null : _navigateToSearch,
          ),
        ],
      ),
      body: watchlistSymbols.isEmpty
          ? _emptyState()
          : watchlistQuotesAsync.when(
              loading: () => const Center(
                child: CircularProgressIndicator(
                  strokeWidth: 2,
                  color: ThemeV2.primary,
                ),
              ),
              error: (err, _) {
                debugPrint('❌ WatchlistFullScreen error: $err');
                return _emptyState();
              },
              data: (companies) {
                if (companies.isEmpty) return _emptyState();
                return SingleChildScrollView(
                  padding: const EdgeInsets.fromLTRB(16, 8, 16, 32),
                  child: Column(
                    children: [
                      Container(
                        decoration: FomoShieldTheme.cardDecoration,
                        clipBehavior: Clip.antiAlias,
                        child: Column(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            for (int i = 0; i < companies.length; i++)
                              _WatchlistRow(
                                key: ValueKey(companies[i]['symbol']),
                                data: companies[i],
                                showDivider: i < companies.length - 1,
                              ),
                          ],
                        ),
                      ),
                      const SizedBox(height: 16),
                      _buildEventsSection(),
                    ],
                  ),
                );
              },
            ),
    );
  }

  Widget _buildEventsSection() {
    return Consumer(
      builder: (context, ref, _) {
        final eventsAsync = ref.watch(calendarEventsProvider);
        return eventsAsync.when(
          loading: () => const SizedBox.shrink(),
          error: (_, _) => const SizedBox.shrink(),
          data: (events) {
            if (events.isEmpty) return const SizedBox.shrink();

            const previewCount = 3;
            final display = _showAllEvents
                ? events
                : events.take(previewCount).toList();

            return Container(
              decoration: FomoShieldTheme.cardDecoration,
              clipBehavior: Clip.antiAlias,
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Padding(
                    padding: const EdgeInsets.fromLTRB(22, 14, 22, 14),
                    child: Text(
                      'EVENTS & NEWS',
                      style: FomoShieldTheme.cardTitle(),
                    ),
                  ),
                  for (int i = 0; i < display.length; i++)
                    _EventRow(
                      event: display[i],
                      showDivider: i < display.length - 1,
                    ),
                  if (events.length > previewCount)
                    GestureDetector(
                      onTap: () =>
                          setState(() => _showAllEvents = !_showAllEvents),
                      child: Container(
                        margin: const EdgeInsets.fromLTRB(16, 6, 16, 16),
                        width: double.infinity,
                        padding: const EdgeInsets.symmetric(vertical: 10),
                        decoration: BoxDecoration(
                          color: ThemeV2.primary.withValues(alpha: 0.06),
                          borderRadius: BorderRadius.circular(10),
                        ),
                        child: Center(
                          child: Text(
                            _showAllEvents
                                ? 'Less'
                                : 'More (${events.length - previewCount})',
                            style: GoogleFonts.inter(
                              fontSize: 12,
                              fontWeight: FontWeight.w600,
                              color: ThemeV2.primary,
                            ),
                          ),
                        ),
                      ),
                    ),
                ],
              ),
            );
          },
        );
      },
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
// Watchlist Row — My Assets sizing/layout: logo, name + sector, price + %
// ---------------------------------------------------------------------------

class _WatchlistRow extends ConsumerWidget {
  final Map<String, dynamic> data;
  final bool showDivider;

  const _WatchlistRow({
    super.key,
    required this.data,
    required this.showDivider,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final price = (data['price'] as num?)?.toDouble() ?? 0;
    final change = (data['change'] as num?)?.toDouble() ?? 0;
    final symbol = data['symbol'] as String? ?? '';
    final name = data['name'] as String? ?? '';
    final weburl = data['weburl'] as String?;
    final domain = CompanyLogo.extractDomain(weburl);
    final logoUrl = data['logoUrl'] as String?;
    final isUp = change >= 0;

    final sectorAsync = ref.watch(cachedGicsSectorProvider(symbol));

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
            CompanyLogo(
              ticker: symbol,
              logoUrl: logoUrl,
              domain: domain,
              radius: 18,
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
                    sectorAsync.when(
                      data: (s) => s?.label ?? symbol,
                      loading: () => symbol,
                      error: (_, _) => symbol,
                    ),
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
            Column(
              crossAxisAlignment: CrossAxisAlignment.end,
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text(
                  '\$${price.toStringAsFixed(2)}',
                  style: interNums(
                    fontSize: 14,
                    fontWeight: FontWeight.w700,
                    color: ThemeV2.textPrimary,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  '${isUp ? '+' : ''}${change.toStringAsFixed(2)}%',
                  style: interNums(
                    fontSize: 12,
                    fontWeight: FontWeight.w600,
                    color: isUp ? ThemeV2.success : ThemeV2.loss,
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

// ---------------------------------------------------------------------------
// Event Row — earnings / dividend / news, same compact style throughout
// ---------------------------------------------------------------------------

class _EventRow extends StatelessWidget {
  final CalendarEvent event;
  final bool showDivider;

  const _EventRow({required this.event, required this.showDivider});

  Future<void> _openArticle() async {
    final url = event.url;
    if (url == null) return;
    final uri = Uri.parse(url);
    if (await canLaunchUrl(uri)) {
      await launchUrl(uri, mode: LaunchMode.externalApplication);
    }
  }

  @override
  Widget build(BuildContext context) {
    final isEarnings = event.type == 'earnings';
    final isNews = event.type == 'news';
    final accent = isNews
        ? ThemeV2.warning
        : (isEarnings ? ThemeV2.primary : ThemeV2.success);

    return GestureDetector(
      onTap: isNews
          ? _openArticle
          : () => context.push('/company/${event.symbol}'),
      behavior: HitTestBehavior.opaque,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
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
              width: 36,
              height: 36,
              decoration: BoxDecoration(
                color: accent.withValues(alpha: 0.15),
                borderRadius: BorderRadius.circular(10),
              ),
              child: Icon(
                isNews
                    ? Icons.newspaper_rounded
                    : (isEarnings
                        ? Icons.bar_chart_rounded
                        : Icons.payments_rounded),
                size: 18,
                color: accent,
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    event.title,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: GoogleFonts.inter(
                      fontSize: 13,
                      fontWeight: FontWeight.w600,
                      color: ThemeV2.textPrimary,
                    ),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    '${event.symbol} · ${DateFormat('MMM d, yyyy').format(event.date)}',
                    style: GoogleFonts.inter(
                      fontSize: 11,
                      color: ThemeV2.textSecondary,
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(width: 8),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
              decoration: BoxDecoration(
                color: accent.withValues(alpha: 0.1),
                borderRadius: BorderRadius.circular(6),
              ),
              child: Text(
                isNews ? 'NEWS' : (isEarnings ? 'EAR' : 'DIV'),
                style: GoogleFonts.inter(
                  fontSize: 10,
                  fontWeight: FontWeight.w700,
                  color: accent,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
