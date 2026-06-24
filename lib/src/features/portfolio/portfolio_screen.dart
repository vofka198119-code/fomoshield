import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:go_router/go_router.dart';
import '../../core/theme/app_theme.dart';
import '../../core/cache/logo_providers.dart';
import '../../shared/widgets/company_logo.dart';
import 'portfolio_providers.dart';

class PortfolioScreen extends ConsumerStatefulWidget {
  const PortfolioScreen({super.key});

  @override
  ConsumerState<PortfolioScreen> createState() => _PortfolioScreenState();
}

class _PortfolioScreenState extends ConsumerState<PortfolioScreen> {
  @override
  Widget build(BuildContext context) {
    final portfolios = ref.watch(portfoliosProvider);
    final activeId = ref.watch(activePortfolioIdProvider);
    final effectiveId =
        activeId ?? (portfolios.isNotEmpty ? portfolios.first.id : null);

    return Scaffold(
      appBar: AppBar(
        title: Row(
          children: [
            const Icon(Icons.account_balance_wallet_rounded,
                color: AppTheme.accentBlue, size: 22),
            const SizedBox(width: 8),
            Text('PORTFOLIO',
                style: GoogleFonts.inter(
                    fontSize: 16,
                    fontWeight: FontWeight.w700,
                    color: Colors.white,
                    letterSpacing: 1)),
          ],
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.add_rounded, color: AppTheme.accentBlue),
            onPressed: () => _showCreatePortfolioDialog(context),
          ),
        ],
      ),
      body: portfolios.isEmpty
          ? _emptyState(context)
          : effectiveId == null
              ? _emptyState(context)
              : RefreshIndicator(
                  color: AppTheme.accentBlue,
                  backgroundColor: AppTheme.card,
                  onRefresh: () async {
                    ref.invalidate(portfolioPerformanceProvider(effectiveId));
                    await Future.delayed(const Duration(milliseconds: 500));
                  },
                  child: _PortfolioBody(portfolioId: effectiveId),
                ),
    );
  }

  Widget _emptyState(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(Icons.account_balance_wallet_rounded,
                size: 64, color: AppTheme.textDim),
            const SizedBox(height: 16),
            Text('No portfolios yet',
                style: GoogleFonts.inter(
                    fontSize: 18,
                    fontWeight: FontWeight.w600,
                    color: Colors.white)),
            const SizedBox(height: 8),
            Text(
                'Create your first virtual portfolio\nwith \$10,000 starting balance',
                textAlign: TextAlign.center,
                style: GoogleFonts.inter(fontSize: 14, color: AppTheme.textDim)),
            const SizedBox(height: 24),
            ElevatedButton.icon(
              onPressed: () => _showCreatePortfolioDialog(context),
              icon: const Icon(Icons.add_rounded),
              label: Text('Create Portfolio'),
              style: ElevatedButton.styleFrom(
                backgroundColor: AppTheme.accentBlue,
                foregroundColor: Colors.white,
                padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _showCreatePortfolioDialog(BuildContext context) {
    final controller = TextEditingController();
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        backgroundColor: AppTheme.card,
        title: Text('New Portfolio',
            style: GoogleFonts.inter(
                fontSize: 18,
                fontWeight: FontWeight.w700,
                color: Colors.white)),
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
                borderSide: BorderSide.none),
          ),
          style: GoogleFonts.inter(color: Colors.white, fontSize: 14),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: Text('Cancel',
                style: GoogleFonts.inter(color: AppTheme.textDim)),
          ),
          TextButton(
            onPressed: () {
              if (controller.text.trim().isNotEmpty) {
                ref
                    .read(portfoliosProvider.notifier)
                    .addPortfolio(controller.text.trim());
                Navigator.pop(ctx);
              }
            },
            child: Text('Create',
                style: GoogleFonts.inter(
                    color: AppTheme.accentBlue,
                    fontWeight: FontWeight.w600)),
          ),
        ],
      ),
    );
  }
}

// ---------------------------------------------------------------------------
// Portfolio Body
// ---------------------------------------------------------------------------

class _PortfolioBody extends ConsumerWidget {
  final String portfolioId;
  const _PortfolioBody({required this.portfolioId});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final portfolios = ref.watch(portfoliosProvider);
    final performanceAsync =
        ref.watch(portfolioPerformanceProvider(portfolioId));
    final portfolio = portfolios.firstWhere((p) => p.id == portfolioId);

    return SingleChildScrollView(
      physics: const AlwaysScrollableScrollPhysics(),
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _PortfolioSelector(portfolios: portfolios, activeId: portfolioId),
          const SizedBox(height: 16),
          performanceAsync.when(
            loading: () => _perfLoading(),
            error: (_, __) => _perfLoading(),
            data: (perf) => _PerformanceCard(performance: perf),
          ),
          const SizedBox(height: 24),
          performanceAsync.when(
            loading: () => const SizedBox.shrink(),
            error: (_, __) => const SizedBox.shrink(),
            data: (perf) {
              if (perf.holdings.isEmpty) return const SizedBox.shrink();
              return Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text('ALLOCATION',
                      style: GoogleFonts.inter(
                          fontSize: 12,
                          fontWeight: FontWeight.w700,
                          color: AppTheme.textDim,
                          letterSpacing: 1.5)),
                  const SizedBox(height: 12),
                  _PieChartSection(holdings: perf.holdings),
                  const SizedBox(height: 24),
                ],
              );
            },
          ),
          performanceAsync.when(
            loading: () => _holdingsLoading(),
            error: (_, __) => _holdingsLoading(),
            data: (perf) => perf.holdings.isEmpty
                ? _emptyHoldings(portfolio.name)
                : _HoldingsList(holdings: perf.holdings),
          ),
          const SizedBox(height: 100),
        ],
      ),
    );
  }

  Widget _perfLoading() => Container(
        padding: const EdgeInsets.all(20),
        decoration: BoxDecoration(
          color: AppTheme.card,
          borderRadius: BorderRadius.circular(16),
        ),
        child: const Center(
          child: SizedBox(
            width: 20,
            height: 20,
            child: CircularProgressIndicator(
                strokeWidth: 2, color: AppTheme.accentBlue),
          ),
        ),
      );

  Widget _holdingsLoading() => Card(
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Center(
            child: Column(
              children: [
                const SizedBox(
                  width: 20,
                  height: 20,
                  child: CircularProgressIndicator(
                      strokeWidth: 2, color: AppTheme.accentBlue),
                ),
                const SizedBox(height: 8),
                Text('Loading holdings...',
                    style: GoogleFonts.inter(
                        fontSize: 14, color: AppTheme.textDim)),
              ],
            ),
          ),
        ),
      );

  Widget _emptyHoldings(String name) => Card(
        child: Padding(
          padding: const EdgeInsets.all(32),
          child: Center(
            child: Column(
              children: [
                const Icon(Icons.shopping_bag_rounded,
                    size: 48, color: AppTheme.textDim),
                const SizedBox(height: 12),
                Text('No holdings yet',
                    style: GoogleFonts.inter(
                        fontSize: 16,
                        fontWeight: FontWeight.w600,
                        color: Colors.white)),
                const SizedBox(height: 8),
                Text(
                    'Search and add companies\nto "$name" from the detail screen',
                    textAlign: TextAlign.center,
                    style: GoogleFonts.inter(
                        fontSize: 13, color: AppTheme.textDim)),
              ],
            ),
          ),
        ),
      );
}

// ---------------------------------------------------------------------------
// Portfolio Selector
// ---------------------------------------------------------------------------

class _PortfolioSelector extends ConsumerWidget {
  final List<Portfolio> portfolios;
  final String activeId;
  const _PortfolioSelector(
      {required this.portfolios, required this.activeId});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return SizedBox(
      height: 40,
      child: ListView.separated(
        scrollDirection: Axis.horizontal,
        itemCount: portfolios.length,
        separatorBuilder: (_, __) => const SizedBox(width: 8),
        itemBuilder: (context, i) {
          final p = portfolios[i];
          final isActive = p.id == activeId;
          return GestureDetector(
            key: ValueKey(p.id),
            onTap: () =>
                ref.read(activePortfolioIdProvider.notifier).state = p.id,
            child: Container(
              padding:
                  const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
              decoration: BoxDecoration(
                color: isActive ? AppTheme.accentBlue : AppTheme.card,
                borderRadius: BorderRadius.circular(20),
              ),
              child: Row(
                children: [
                  if (isActive)
                    const Padding(
                      padding: EdgeInsets.only(right: 6),
                      child: Icon(Icons.check, size: 14, color: Colors.white),
                    ),
                  Text(p.name,
                      style: GoogleFonts.inter(
                          fontSize: 13,
                          fontWeight: FontWeight.w600,
                          color:
                              isActive ? Colors.white : AppTheme.textDim)),
                  if (isActive)
                    Padding(
                      padding: const EdgeInsets.only(left: 6),
                      child: GestureDetector(
                        onTap: () => _deleteConfirm(context, ref, p.id),
                        child: const Icon(Icons.close,
                            size: 14, color: Colors.white70),
                      ),
                    ),
                ],
              ),
            ),
          );
        },
      ),
    );
  }

  void _deleteConfirm(BuildContext context, WidgetRef ref, String id) {
    if (portfolios.length <= 1) {
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(
        content: Text('Cannot delete the last portfolio',
            style: GoogleFonts.inter(fontSize: 13)),
        backgroundColor: AppTheme.dangerRed,
      ));
      return;
    }
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        backgroundColor: AppTheme.card,
        title: Text('Delete portfolio?',
            style: GoogleFonts.inter(
                fontSize: 18,
                fontWeight: FontWeight.w700,
                color: Colors.white)),
        content: Text('All holdings and history will be lost.',
            style: GoogleFonts.inter(fontSize: 14, color: AppTheme.textDim)),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: Text('Cancel',
                style: GoogleFonts.inter(color: AppTheme.textDim)),
          ),
          TextButton(
            onPressed: () {
              ref.read(portfoliosProvider.notifier).deletePortfolio(id);
              Navigator.pop(ctx);
            },
            child: Text('Delete',
                style: GoogleFonts.inter(
                    color: AppTheme.dangerRed,
                    fontWeight: FontWeight.w600)),
          ),
        ],
      ),
    );
  }
}

// ---------------------------------------------------------------------------
// Performance Card
// ---------------------------------------------------------------------------

class _PerformanceCard extends StatelessWidget {
  final PortfolioPerformance performance;
  const _PerformanceCard({required this.performance});

  @override
  Widget build(BuildContext context) {
    final isUp = performance.pnl >= 0;
    final c = isUp ? AppTheme.shieldGreen : AppTheme.dangerRed;

    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [c.withValues(alpha: 0.15), AppTheme.card],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: c.withValues(alpha: 0.2)),
      ),
      child: Column(
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text('Total Value',
                  style: GoogleFonts.inter(
                      fontSize: 13, color: AppTheme.textDim)),
              Text('P&L',
                  style: GoogleFonts.inter(
                      fontSize: 13, color: AppTheme.textDim)),
            ],
          ),
          const SizedBox(height: 4),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text('\$${performance.currentValue.toStringAsFixed(2)}',
                  style: GoogleFonts.inter(
                      fontSize: 26,
                      fontWeight: FontWeight.w800,
                      color: Colors.white)),
              Column(
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  Text(
                    '${isUp ? '+' : ''}\$${performance.pnl.toStringAsFixed(2)}',
                    style: GoogleFonts.inter(
                        fontSize: 18,
                        fontWeight: FontWeight.w700,
                        color: c),
                  ),
                  Text(
                    '${isUp ? '+' : ''}${performance.pnlPercent.toStringAsFixed(2)}%',
                    style: GoogleFonts.inter(
                        fontSize: 14, fontWeight: FontWeight.w500, color: c),
                  ),
                ],
              ),
            ],
          ),
          const SizedBox(height: 12),
          const Divider(color: AppTheme.cardDark),
          const SizedBox(height: 8),
          Row(
            children: [
              _stat('Invested',
                  '\$${performance.totalInvested.toStringAsFixed(2)}'),
              _stat('Cash', '\$${performance.cash.toStringAsFixed(2)}'),
              _stat('Holdings', '${performance.holdings.length}'),
            ],
          ),
        ],
      ),
    );
  }

  Widget _stat(String label, String value) => Expanded(
        child: Column(
          children: [
            Text(label,
                style: GoogleFonts.inter(
                    fontSize: 11, color: AppTheme.textDim)),
            const SizedBox(height: 4),
            Text(value,
                style: GoogleFonts.inter(
                    fontSize: 13,
                    fontWeight: FontWeight.w600,
                    color: Colors.white)),
          ],
        ),
      );
}

// ---------------------------------------------------------------------------
// Pie Chart
// ---------------------------------------------------------------------------

class _PieChartSection extends StatelessWidget {
  final List<HoldingPerformance> holdings;
  const _PieChartSection({required this.holdings});

  @override
  Widget build(BuildContext context) {
    final total =
        holdings.fold<double>(0, (s, h) => s + h.currentValue);
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppTheme.card,
        borderRadius: BorderRadius.circular(16),
      ),
      child: Row(
        children: [
          SizedBox(
            width: 120,
            height: 120,
            child: PieChart(
              PieChartData(
                sectionsSpace: 2,
                centerSpaceRadius: 24,
                sections: holdings.map((h) {
                  final pct = total > 0 ? h.currentValue / total : 0;
                  return PieChartSectionData(
                    value: pct * 100,
                    title: '${(pct * 100).toStringAsFixed(0)}%',
                    titleStyle: GoogleFonts.inter(
                        fontSize: 10,
                        fontWeight: FontWeight.w700,
                        color: Colors.white),
                    radius: 28,
                    color: _color(holdings.indexOf(h)),
                  );
                }).toList(),
              ),
            ),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: holdings.take(6).map((h) {
                final share = total > 0 ? h.currentValue / total : 0;
                return Padding(
                  padding: const EdgeInsets.symmetric(vertical: 3),
                  child: Row(
                    children: [
                      Container(
                        width: 8,
                        height: 8,
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          color: _color(holdings.indexOf(h)),
                        ),
                      ),
                      const SizedBox(width: 8),
                      Expanded(
                        child: Text(h.symbol,
                            style: GoogleFonts.inter(
                                fontSize: 12,
                                fontWeight: FontWeight.w600,
                                color: Colors.white)),
                      ),
                      Text('${(share * 100).toStringAsFixed(1)}%',
                          style: GoogleFonts.inter(
                              fontSize: 12, color: AppTheme.textDim)),
                    ],
                  ),
                );
              }).toList(),
            ),
          ),
        ],
      ),
    );
  }

  static const _colors = [
    AppTheme.accentBlue,
    AppTheme.shieldGreen,
    AppTheme.shieldYellow,
    AppTheme.dangerRed,
    Color(0xFF9B59B6),
    Color(0xFFE67E22),
    Color(0xFF1ABC9C),
    Color(0xFF3498DB),
  ];

  Color _color(int i) => _colors[i % _colors.length];
}

// ---------------------------------------------------------------------------
// Holdings List
// ---------------------------------------------------------------------------

class _HoldingsList extends StatelessWidget {
  final List<HoldingPerformance> holdings;
  const _HoldingsList({required this.holdings});

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text('HOLDINGS',
            style: GoogleFonts.inter(
                fontSize: 12,
                fontWeight: FontWeight.w700,
                color: AppTheme.textDim,
                letterSpacing: 1.5)),
        const SizedBox(height: 8),
        ...holdings.map((h) => KeyedSubtree(key: ValueKey(h.symbol), child: _HoldingCard(holding: h))),
      ],
    );
  }
}

class _HoldingCard extends ConsumerWidget {
  final HoldingPerformance holding;
  const _HoldingCard({required this.holding});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final isUp = holding.pnl >= 0;
    final logoAsync = ref.watch(quickLogoProvider(holding.symbol));
    final logoUrl = logoAsync.valueOrNull;

    return Card(
      margin: const EdgeInsets.only(bottom: 8),
      child: InkWell(
        onTap: () => context.push('/company/${holding.symbol}'),
        borderRadius: BorderRadius.circular(12),
        child: Padding(
          padding: const EdgeInsets.all(14),
          child: Row(
            children: [
              CompanyLogo(
                ticker: holding.symbol,
                logoUrl: logoUrl,
                radius: 18,
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(holding.symbol,
                        style: GoogleFonts.inter(
                            fontSize: 14,
                            fontWeight: FontWeight.w600,
                            color: Colors.white)),
                    const SizedBox(height: 2),
                    Text(
                        '${holding.shares.toStringAsFixed(4)} @ \$${holding.avgCost.toStringAsFixed(2)}',
                        style: GoogleFonts.inter(
                            fontSize: 11, color: AppTheme.textDim)),
                  ],
                ),
              ),
              Column(
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  Text('\$${holding.currentValue.toStringAsFixed(2)}',
                      style: GoogleFonts.inter(
                          fontSize: 14,
                          fontWeight: FontWeight.w600,
                          color: Colors.white)),
                  const SizedBox(height: 2),
                  Text(
                      '${isUp ? '+' : ''}\$${holding.pnl.toStringAsFixed(2)} (${isUp ? '+' : ''}${holding.pnlPercent.toStringAsFixed(2)}%)',
                      style: GoogleFonts.inter(
                          fontSize: 11,
                          color: isUp
                              ? AppTheme.shieldGreen
                              : AppTheme.dangerRed)),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}
