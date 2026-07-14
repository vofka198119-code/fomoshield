import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../../core/theme/theme_v2.dart';
import '../../../core/theme/typography_helpers.dart';
import '../../../core/cache/logo_providers.dart';
import '../../../shared/widgets/company_logo.dart';
import '../../../shared/widgets/widget_container.dart';
import '../portfolio_providers.dart';

// ---------------------------------------------------------------------------
// Portfolio Holdings Widget — sorted by weight, collapsible, with %
// ---------------------------------------------------------------------------

class PortfolioHoldingsWidget extends StatefulWidget {
  final List<HoldingPerformance>? holdings;
  final String? emptyPortfolioName;

  const PortfolioHoldingsWidget({
    super.key,
    this.holdings,
    this.emptyPortfolioName,
  });

  @override
  State<PortfolioHoldingsWidget> createState() => _PortfolioHoldingsWidgetState();
}

class _PortfolioHoldingsWidgetState extends State<PortfolioHoldingsWidget> {
  bool _showAll = false;

  @override
  Widget build(BuildContext context) {
    final holdings = widget.holdings;

    if (holdings == null) {
      return WidgetContainer(
        title: 'HOLDINGS',
        onTap: () {},
        showFooter: false,
        children: [
          const Padding(
            padding: EdgeInsets.all(20),
            child: Center(
              child: SizedBox(
                width: 20,
                height: 20,
                child: CircularProgressIndicator(
                  strokeWidth: 2,
                  color: ThemeV2.primary,
                ),
              ),
            ),
          ),
        ],
      );
    }

    if (holdings.isEmpty) {
      return _emptyHoldings(context);
    }

    // Sort by currentValue descending (largest first)
    final sorted = List<HoldingPerformance>.from(holdings)
      ..sort((a, b) => b.currentValue.compareTo(a.currentValue));
    final totalValue = sorted.fold<double>(0, (s, h) => s + h.currentValue);
    const int previewLimit = 4;
    final display = _showAll ? sorted : sorted.take(previewLimit).toList();

    return WidgetContainer(
      title: 'HOLDINGS',
      onTap: () => setState(() => _showAll = !_showAll),
      showFooter: !_showAll && sorted.length > previewLimit,
      footerText: '+ ${sorted.length - previewLimit} more',
      children: display
          .map((h) => KeyedSubtree(
                key: ValueKey(h.symbol),
                child: _HoldingCard(
                  holding: h,
                  weightPercent:
                      totalValue > 0 ? (h.currentValue / totalValue) * 100 : 0,
                ),
              ))
          .toList(),
    );
  }

  Widget _emptyHoldings(BuildContext context) {
    final name = widget.emptyPortfolioName ?? 'this portfolio';
    return WidgetContainer(
      title: 'HOLDINGS',
      onTap: () => context.push('/search'),
      showFooter: false,
      emptyText: 'Nothing here yet',
      children: [
        Padding(
          padding: const EdgeInsets.all(20),
          child: Center(
            child: Column(
              children: [
                const Icon(Icons.shopping_bag_rounded,
                    size: 48, color: ThemeV2.textSecondary),
                const SizedBox(height: 12),
                Text('No holdings yet',
                    style: GoogleFonts.inter(
                        fontSize: 16,
                        fontWeight: FontWeight.w600,
                        color: ThemeV2.textPrimary)),
                const SizedBox(height: 8),
                Text('Search and add companies to "$name"',
                    textAlign: TextAlign.center,
                    style: GoogleFonts.inter(
                        fontSize: 13, color: ThemeV2.textSecondary)),
                const SizedBox(height: 16),
                ElevatedButton.icon(
                  onPressed: () => context.push('/search'),
                  icon: const Icon(Icons.search_rounded, size: 18),
                  label: Text('Find Companies',
                      style: GoogleFonts.inter(
                          fontSize: 14, fontWeight: FontWeight.w600)),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: ThemeV2.primary,
                    foregroundColor: Colors.white,
                    padding: const EdgeInsets.symmetric(
                        horizontal: 20, vertical: 12),
                  ),
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }
}

// ---------------------------------------------------------------------------
// Holding Card (extracted from original portfolio_screen.dart)
// ---------------------------------------------------------------------------

class _HoldingCard extends ConsumerWidget {
  final HoldingPerformance holding;
  final double weightPercent;

  const _HoldingCard({required this.holding, this.weightPercent = 0});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final isUp = holding.pnl >= 0;
    final logoAsync = ref.watch(quickLogoProvider(holding.symbol));
    final logoUrl = logoAsync.valueOrNull;

    return Card(
      margin: const EdgeInsets.only(bottom: 8),
      child: InkWell(
        onTap: () => context.push('/company/${holding.symbol}'),
        borderRadius: BorderRadius.circular(22),
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
                    Row(
                      children: [
                        Text(holding.symbol,
                            style: GoogleFonts.inter(
                                fontSize: 15,
                                fontWeight: FontWeight.w600,
                                color: ThemeV2.textPrimary)),
                        const SizedBox(width: 6),
                        Container(
                          padding: const EdgeInsets.symmetric(
                              horizontal: 5, vertical: 1),
                          decoration: BoxDecoration(
                            color: ThemeV2.primary.withValues(alpha: 0.15),
                            borderRadius: BorderRadius.circular(6),
                          ),
                          child: Text(
                            '${weightPercent.toStringAsFixed(1)}%',
                            style: GoogleFonts.inter(
                                fontSize: 11,
                                fontWeight: FontWeight.w700,
                                color: ThemeV2.primary),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 2),
                    Text(
                        '${holding.shares.toStringAsFixed(4)} @ \$${holding.avgCost.toStringAsFixed(2)}',
                        style: GoogleFonts.inter(
                            fontSize: 12, color: ThemeV2.textSecondary)),
                  ],
                ),
              ),
              Column(
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  FittedBox(
                    fit: BoxFit.scaleDown,
                    child: Text('\$${holding.currentValue.toStringAsFixed(2)}',
                        style: GoogleFonts.inter(
                            fontSize: 15,
                            fontWeight: FontWeight.w600,
                            color: ThemeV2.textPrimary)),
                  ),
                  const SizedBox(height: 2),
                  FittedBox(
                    fit: BoxFit.scaleDown,
                    child: Text(
                        '${isUp ? '+' : ''}\$${holding.pnl.toStringAsFixed(2)} (${isUp ? '+' : ''}${holding.pnlPercent.toStringAsFixed(2)}%)',
                        style: GoogleFonts.inter(
                            fontSize: 12,
                            color: isUp
                                ? ThemeV2.success
                                : ThemeV2.loss)),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}

