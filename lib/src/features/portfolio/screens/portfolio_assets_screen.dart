// ---------------------------------------------------------------------------
// Portfolio Assets Screen — список активов портфеля (Блок 1 для Portfolio)
// ---------------------------------------------------------------------------
// Trading 212 style:
//   - Total Balance (СТОИМОСТЬ АКТИВОВ, нереализованная прибыль, базовая стоимость)
//   - Search bar + сортировка
//   - Список активов с лого, названием, тикером, стоимостью, P&L
// ---------------------------------------------------------------------------

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:intl/intl.dart';
import '../../../core/theme/theme_v2.dart';
import '../../../core/theme/typography_helpers.dart';
import '../../../core/cache/logo_providers.dart';
import '../../../shared/widgets/company_logo.dart';
import '../../../shared/widgets/portfolio_value_chart.dart';
import '../portfolio_providers.dart';

/// Сортировка списка активов
enum _PortAssetSort { value, marketPrice }

class PortfolioAssetsScreen extends ConsumerStatefulWidget {
  final String portfolioId;

  const PortfolioAssetsScreen({super.key, required this.portfolioId});

  @override
  ConsumerState<PortfolioAssetsScreen> createState() =>
      _PortfolioAssetsScreenState();
}

class _PortfolioAssetsScreenState extends ConsumerState<PortfolioAssetsScreen> {
  final _searchController = TextEditingController();
  String _searchQuery = '';
  _PortAssetSort _sortMode = _PortAssetSort.value;

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final performanceAsync = ref.watch(
      portfolioPerformanceProvider(widget.portfolioId),
    );

    return Scaffold(
      backgroundColor: Colors.transparent,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        title: Text(
          'Активы',
          style: GoogleFonts.inter(
            fontSize: 20,
            fontWeight: FontWeight.w800,
            color: ThemeV2.primary,
            letterSpacing: 1.5,
          ),
        ),
        leading: IconButton(
          icon: const Icon(
            Icons.arrow_back_rounded,
            color: ThemeV2.textPrimary,
          ),
          onPressed: () => context.pop(),
        ),
      ),
      body: performanceAsync.when(
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (err, _) => Center(child: Text('Ошибка: $err')),
        data: (performance) {
          var holdings = performance.holdings.toList();

          // Filter
          if (_searchQuery.isNotEmpty) {
            final q = _searchQuery.toUpperCase();
            holdings = holdings.where((h) => h.symbol.contains(q)).toList();
          }

          // Sort
          if (_sortMode == _PortAssetSort.value) {
            holdings.sort((a, b) => b.currentValue.compareTo(a.currentValue));
          } else {
            holdings.sort((a, b) => b.currentPrice.compareTo(a.currentPrice));
          }

          return Column(
            children: [
              // Balance header
              _buildBalanceHeader(performance),

              // Chart
              PortfolioValueChartWidget(
                portfolioId: widget.portfolioId,
                height: 250,
              ),

              // Search bar
              _buildSearchBar(),

              // Sort toggle
              _buildSortToggle(),

              const Divider(height: 1, color: ThemeV2.divider),

              // Assets list
              Expanded(
                child: holdings.isEmpty
                    ? Center(
                        child: Text(
                          'Нет активов',
                          style: GoogleFonts.inter(
                            fontSize: 14,
                            color: ThemeV2.textSecondary,
                          ),
                        ),
                      )
                    : ListView.builder(
                        padding: const EdgeInsets.symmetric(horizontal: 16),
                        itemCount: holdings.length,
                        itemBuilder: (context, index) {
                          final h = holdings[index];
                          return _PortfolioAssetRow(
                            holding: h,
                            portfolioId: widget.portfolioId,
                          );
                        },
                      ),
              ),
            ],
          );
        },
      ),
    );
  }

  Widget _buildBalanceHeader(PortfolioPerformance performance) {
    final pnl = performance.pnl;
    final pnlPercent = performance.pnlPercent;
    final isPositive = pnl >= 0;

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.fromLTRB(20, 8, 20, 16),
      decoration: const BoxDecoration(
        color: ThemeV2.surface,
        border: Border(bottom: BorderSide(color: ThemeV2.divider)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'СТОИМОСТЬ АКТИВОВ',
            style: GoogleFonts.inter(
              fontSize: 13,
              fontWeight: FontWeight.w500,
              color: ThemeV2.primary,
              letterSpacing: 0.8,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            '\$${_fmt(performance.currentValue)}',
            style: GoogleFonts.playfairDisplay(
              fontSize: 36,
              fontWeight: FontWeight.w700,
              color: ThemeV2.textPrimary,
              height: 1.1,
            ),
          ),
          const SizedBox(height: 8),
          Row(
            children: [
              Text(
                'НЕРЕАЛИЗОВАННАЯ ПРИБЫЛЬ',
                style: GoogleFonts.inter(
                  fontSize: 11,
                  fontWeight: FontWeight.w500,
                  color: ThemeV2.primary,
                  letterSpacing: 0.5,
                ),
              ),
              const SizedBox(width: 8),
              Text(
                '${isPositive ? '+' : ''}\$${_fmt(pnl.abs())} '
                '(${isPositive ? '+' : ''}${pnlPercent.toStringAsFixed(2)}%)',
                style: GoogleFonts.inter(
                  fontSize: 12,
                  fontWeight: FontWeight.w700,
                  color: isPositive ? ThemeV2.success : ThemeV2.loss,
                ),
              ),
            ],
          ),
          const SizedBox(height: 4),
          Row(
            children: [
              Text(
                'БАЗОВАЯ СТОИМОСТЬ',
                style: GoogleFonts.inter(
                  fontSize: 11,
                  fontWeight: FontWeight.w500,
                  color: ThemeV2.primary,
                  letterSpacing: 0.5,
                ),
              ),
              const SizedBox(width: 8),
              Text(
                '\$${_fmt(performance.totalInvested)}',
                style: GoogleFonts.inter(
                  fontSize: 12,
                  fontWeight: FontWeight.w600,
                  color: ThemeV2.textPrimary,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildSearchBar() {
    return Container(
      margin: const EdgeInsets.fromLTRB(16, 12, 16, 4),
      decoration: BoxDecoration(
        border: Border.all(
          color: ThemeV2.textSecondary.withValues(alpha: 0.3),
        ),
        color: ThemeV2.surface,
      ),
      child: TextField(
        controller: _searchController,
        onChanged: (v) => setState(() => _searchQuery = v.trim()),
        style: GoogleFonts.inter(fontSize: 14, color: ThemeV2.textPrimary),
        decoration: InputDecoration(
          hintText: 'Поиск',
          hintStyle: GoogleFonts.inter(fontSize: 14, color: ThemeV2.textSecondary),
          prefixIcon: const Icon(
            Icons.search_rounded,
            color: ThemeV2.textSecondary,
            size: 20,
          ),
          border: InputBorder.none,
          contentPadding: const EdgeInsets.symmetric(
            horizontal: 12,
            vertical: 12,
          ),
          fillColor: ThemeV2.surface,
          filled: true,
        ),
      ),
    );
  }

  Widget _buildSortToggle() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      child: Row(
        children: [
          _sortChip('Стоимость', _PortAssetSort.value),
          const SizedBox(width: 16),
          _sortChip('Рыночная цена', _PortAssetSort.marketPrice),
        ],
      ),
    );
  }

  Widget _sortChip(String label, _PortAssetSort mode) {
    final isActive = _sortMode == mode;
    return GestureDetector(
      onTap: () => setState(() => _sortMode = mode),
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 6),
        decoration: BoxDecoration(
          border: Border(
            bottom: BorderSide(
              color: isActive ? ThemeV2.primary : Colors.transparent,
              width: 2,
            ),
          ),
        ),
        child: Text(
          label,
          style: GoogleFonts.inter(
            fontSize: 13,
            fontWeight: FontWeight.w600,
            color: isActive ? ThemeV2.primary : ThemeV2.textSecondary,
            letterSpacing: 0.3,
          ),
        ),
      ),
    );
  }

  String _fmt(double v) {
    return NumberFormat('#,##0.00', 'en_US').format(v);
  }
}

// ---------------------------------------------------------------------------
// Portfolio Asset Row
// ---------------------------------------------------------------------------

class _PortfolioAssetRow extends ConsumerWidget {
  final HoldingPerformance holding;
  final String portfolioId;

  const _PortfolioAssetRow({required this.holding, required this.portfolioId});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final logoAsync = ref.watch(cachedLogoProvider(holding.symbol));
    final isPositive = holding.pnl >= 0;

    return GestureDetector(
      onTap: () {
        context.push('/company/${holding.symbol}');
      },
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 14, horizontal: 4),
        decoration: const BoxDecoration(
          border: Border(bottom: BorderSide(color: ThemeV2.divider)),
        ),
        child: Row(
          children: [
            SizedBox(
              width: 40,
              height: 40,
              child: logoAsync.when(
                data: (url) => CompanyLogo(
                  ticker: holding.symbol,
                  logoUrl: url,
                  radius: 20,
                ),
                error: (_, _) =>
                    CompanyLogo(ticker: holding.symbol, radius: 20),
                loading: () => CompanyLogo(ticker: holding.symbol, radius: 20),
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    holding.symbol,
                    style: GoogleFonts.inter(
                      fontSize: 15,
                      fontWeight: FontWeight.w600,
                      color: ThemeV2.textPrimary,
                    ),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    '${holding.shares.toStringAsFixed(2)} акций',
                    style: GoogleFonts.inter(
                      fontSize: 12,
                      color: ThemeV2.textSecondary,
                    ),
                  ),
                ],
              ),
            ),
            Column(
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                Text(
                  '\$${_fmt(holding.currentValue)}',
                  style: GoogleFonts.inter(
                    fontSize: 15,
                    fontWeight: FontWeight.w600,
                    color: ThemeV2.textPrimary,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  '${isPositive ? '+' : ''}${holding.pnlPercent.toStringAsFixed(2)}%',
                  style: GoogleFonts.inter(
                    fontSize: 12,
                    fontWeight: FontWeight.w500,
                    color: isPositive
                        ? ThemeV2.success
                        : ThemeV2.loss,
                  ),
                ),
              ],
            ),
            const SizedBox(width: 4),
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

  String _fmt(double v) {
    return NumberFormat('#,##0.00', 'en_US').format(v);
  }
}

