import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../../core/theme/app_theme.dart';
import '../../../shared/widgets/company_logo.dart';
import '../home_providers.dart';

// ---------------------------------------------------------------------------
// Watchlist Full Screen — All items with search & add
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
    final watchlistQuotesAsync = ref.watch(watchlistQuotesProvider);

    return Scaffold(
      backgroundColor: AppTheme.background,
      appBar: AppBar(
        title: Text(
          'Watchlist',
          style: GoogleFonts.inter(
            fontSize: 18,
            fontWeight: FontWeight.w700,
            color: Colors.white,
          ),
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.add_rounded, color: AppTheme.accentBlue),
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
                  color: AppTheme.accentBlue,
                ),
              ),
              error: (err, _) {
                debugPrint('❌ WatchlistFullScreen error: $err');
                return _emptyState();
              },
              data: (companies) {
                if (companies.isEmpty) return _emptyState();
                return ListView.builder(
                  padding: const EdgeInsets.fromLTRB(16, 8, 16, 32),
                  itemCount: companies.length,
                  itemBuilder: (_, i) {
                    final symbol = companies[i]['symbol'] as String? ?? 'unknown';
                    return Padding(
                      key: ValueKey(symbol),
                      padding: const EdgeInsets.only(bottom: 8),
                      child: _CompanyCard(data: companies[i]),
                    );
                  },
                );
              },
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
            color: AppTheme.textDim,
            size: 48,
          ),
          const SizedBox(height: 12),
          Text(
            'No companies yet',
            style: GoogleFonts.inter(
              fontSize: 16,
              fontWeight: FontWeight.w600,
              color: Colors.white,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            'Tap + to search and add companies',
            style: GoogleFonts.inter(
              fontSize: 13,
              color: AppTheme.textDim,
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
// Company Card — Full version with accordion details
// ---------------------------------------------------------------------------

class _CompanyCard extends ConsumerStatefulWidget {
  final Map<String, dynamic> data;
  const _CompanyCard({required this.data});

  @override
  ConsumerState<_CompanyCard> createState() => _CompanyCardState();
}

class _CompanyCardState extends ConsumerState<_CompanyCard>
    with SingleTickerProviderStateMixin {
  bool _expanded = false;
  late AnimationController _animController;
  late Animation<double> _heightFactor;

  @override
  void initState() {
    super.initState();
    _animController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 300),
    );
    _heightFactor = CurvedAnimation(
      parent: _animController,
      curve: Curves.easeInOut,
    );
  }

  @override
  void dispose() {
    _animController.dispose();
    super.dispose();
  }

  void _toggle() {
    setState(() {
      _expanded = !_expanded;
      if (_expanded) {
        _animController.forward();
      } else {
        _animController.reverse();
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    final price = (widget.data['price'] as num?)?.toDouble() ?? 0;
    final change = (widget.data['change'] as num?)?.toDouble() ?? 0;
    final symbol = widget.data['symbol'] as String? ?? '';
    final name = widget.data['name'] as String? ?? '';
    final tag = widget.data['tag'] as String?;
    final weburl = widget.data['weburl'] as String?;
    final domain = CompanyLogo.extractDomain(weburl);
    final logoUrl = widget.data['logoUrl'] as String?;

    return Container(
      decoration: BoxDecoration(
        color: AppTheme.card,
        borderRadius: BorderRadius.circular(16),
      ),
      clipBehavior: Clip.antiAlias,
      child: Column(
        children: [
          // Main card row (tappable to expand)
          InkWell(
            onTap: _toggle,
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
              child: Row(
                children: [
                  CompanyLogo(ticker: symbol, logoUrl: logoUrl, domain: domain),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          name,
                          style: GoogleFonts.inter(
                            fontSize: 14,
                            fontWeight: FontWeight.w600,
                            color: Colors.white,
                          ),
                        ),
                        const SizedBox(height: 1),
                        Text(
                          symbol,
                          style: GoogleFonts.inter(
                            fontSize: 12,
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
                          fontSize: 14,
                          fontWeight: FontWeight.w600,
                          color: Colors.white,
                        ),
                      ),
                      Text(
                        '${change >= 0 ? '+' : ''}${change.toStringAsFixed(2)}%',
                        style: GoogleFonts.inter(
                          fontSize: 12,
                          color: change >= 0
                              ? AppTheme.shieldGreen
                              : AppTheme.shieldRed,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(width: 4),
                  AnimatedRotation(
                    turns: _expanded ? 0.5 : 0,
                    duration: const Duration(milliseconds: 300),
                    child: const Icon(
                      Icons.keyboard_arrow_down_rounded,
                      color: AppTheme.textDim,
                      size: 20,
                    ),
                  ),
                ],
              ),
            ),
          ),
          // Expandable description + View Full Audit
          SizeTransition(
            sizeFactor: _heightFactor,
            axisAlignment: -1.0,
            child: Padding(
              padding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Divider(height: 1, color: Colors.white12),
                  const SizedBox(height: 12),
                  tag != null
                      ? Row(
                          children: [
                            Container(
                              padding: const EdgeInsets.symmetric(
                                horizontal: 10,
                                vertical: 4,
                              ),
                              decoration: BoxDecoration(
                                color: AppTheme.accentBlue.withAlpha(25),
                                borderRadius: BorderRadius.circular(6),
                              ),
                              child: Text(
                                tag,
                                style: GoogleFonts.inter(
                                  fontSize: 12,
                                  fontWeight: FontWeight.w600,
                                  color: AppTheme.accentBlue,
                                ),
                              ),
                            ),
                          ],
                        )
                      : Text(
                          'No description available.',
                          style: GoogleFonts.inter(
                            fontSize: 12,
                            color: AppTheme.textDim,
                          ),
                        ),
                  const SizedBox(height: 12),
                  SizedBox(
                    width: double.infinity,
                    child: OutlinedButton.icon(
                      onPressed: () {
                        ref.read(debouncerProvider).run(() {
                          context.push('/company/$symbol');
                        });
                      },
                      icon: const Icon(Icons.search_rounded, size: 16),
                      label: Text(
                        'View Full Audit',
                        style: GoogleFonts.inter(fontSize: 13),
                      ),
                      style: OutlinedButton.styleFrom(
                        foregroundColor: AppTheme.accentBlue,
                        side: const BorderSide(
                          color: AppTheme.accentBlue,
                          width: 0.5,
                        ),
                        padding: const EdgeInsets.symmetric(vertical: 10),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(8),
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
