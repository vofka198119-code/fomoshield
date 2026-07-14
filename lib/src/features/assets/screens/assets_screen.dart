// ---------------------------------------------------------------------------
// Stress Test Assets Screen — holdings list (Block 1)
// ---------------------------------------------------------------------------
// Trading 212 style:
//   - Total Balance (TOTAL VALUE, unrealized P&L, start cash)
//   - Search bar + sort toggles (Value / Market Price)
//   - Holdings list with logo, name, ticker, weight, value, P&L
// ---------------------------------------------------------------------------

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:intl/intl.dart';
import '../../../core/theme/app_theme.dart';
import '../../stress_test/stress_test_models.dart';
import '../../stress_test/stress_test_engine.dart';
import '../widgets/asset_row_widget.dart';

/// Asset list sort mode
enum AssetSortMode { value, marketPrice }

class AssetsScreen extends ConsumerStatefulWidget {
  final String sessionId;

  const AssetsScreen({super.key, required this.sessionId});

  @override
  ConsumerState<AssetsScreen> createState() => _AssetsScreenState();
}

class _AssetsScreenState extends ConsumerState<AssetsScreen> {
  final _searchController = TextEditingController();
  String _searchQuery = '';
  AssetSortMode _sortMode = AssetSortMode.value;

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  StressTestSession? get _session {
    return ref.read(stressTestProvider.notifier).getSession(widget.sessionId);
  }

  List<StressTestHolding> _sortedAndFiltered(StressTestSession session) {
    var list = session.holdings.toList();

    // Filter by search
    if (_searchQuery.isNotEmpty) {
      final q = _searchQuery.toUpperCase();
      list = list.where((h) => h.symbol.contains(q)).toList();
    }

    // Sort
    if (_sortMode == AssetSortMode.value) {
      list.sort((a, b) {
        final priceA = session.currentPrices[a.symbol] ?? a.entryPrice;
        final priceB = session.currentPrices[b.symbol] ?? b.entryPrice;
        return (b.shares * priceB).compareTo(a.shares * priceA);
      });
    } else {
      list.sort((a, b) {
        final priceA = session.currentPrices[a.symbol] ?? a.entryPrice;
        final priceB = session.currentPrices[b.symbol] ?? b.entryPrice;
        return priceB.compareTo(priceA);
      });
    }

    return list;
  }

  @override
  Widget build(BuildContext context) {
    ref.watch(stressTestRefreshProvider);
    final session = _session;
    if (session == null) {
      return Scaffold(
        backgroundColor: Colors.transparent,
        appBar: AppBar(
          title: Text(
            'Assets',
            style: GoogleFonts.inter(
              fontSize: 20,
              fontWeight: FontWeight.w800,
              color: AppTheme.accentBlue,
              letterSpacing: 1.5,
            ),
          ),
          leading: IconButton(
            icon: const Icon(Icons.arrow_back_rounded),
            onPressed: () => context.pop(),
          ),
        ),
        body: Center(
          child: Text(
            'Session not found',
            style: GoogleFonts.inter(color: AppTheme.textDim, fontSize: 14),
          ),
        ),
      );
    }

    final holdings = _sortedAndFiltered(session);
    final totalValue = session.totalValue;
    final startCash = session.startingCash;
    final unrealizedPnl = session.unrealizedPnl;
    final pnlPercent = session.profitLossPercent;
    final isPositive = unrealizedPnl >= 0;

    return Scaffold(
      backgroundColor: Colors.transparent,
      appBar: AppBar(
        title: Text(
          'Assets',
          style: GoogleFonts.inter(
            fontSize: 20,
            fontWeight: FontWeight.w800,
            color: AppTheme.accentBlue,
            letterSpacing: 1.5,
          ),
        ),
        leading: IconButton(
          icon: const Icon(
            Icons.arrow_back_rounded,
            color: AppTheme.textPrimary,
          ),
          onPressed: () => context.pop(),
        ),
      ),
      body: Column(
        children: [
          // ── Developer Trace Bar (only when enabled) ─────────────
          if (session.enableDeveloperTrace) _buildDevTraceBar(session),

          // ── Total Balance Header ─────────────────────────────
          _buildBalanceHeader(
            totalValue: totalValue,
            unrealizedPnl: unrealizedPnl,
            pnlPercent: pnlPercent,
            isPositive: isPositive,
            startCash: startCash,
          ),

          // ── Search Bar ───────────────────────────────────────
          _buildSearchBar(),

          // ── Sort Toggle ──────────────────────────────────────
          _buildSortToggle(),

          // ── Divider ──────────────────────────────────────────
          const Divider(height: 1, color: AppTheme.borderSubtle),

          // ── Assets List ──────────────────────────────────────
          Expanded(
            child: holdings.isEmpty
                ? Center(
                    child: Text(
                      'No assets',
                      style: GoogleFonts.inter(
                        fontSize: 14,
                        color: AppTheme.textDim,
                      ),
                    ),
                  )
                : ListView.builder(
                    padding: const EdgeInsets.symmetric(horizontal: 16),
                    itemCount: holdings.length,
                    itemBuilder: (context, index) {
                      final h = holdings[index];
                      return AssetRowWidget(
                        holding: h,
                        session: session,
                        onTap: () {
                          context.push(
                            '/stress-test/${widget.sessionId}/stock/${h.symbol}',
                          );
                        },
                      );
                    },
                  ),
          ),
        ],
      ),
    );
  }

  /// Developer Trace Bar — видна только при enableDeveloperTrace == true.
  /// Отображает текущие метки MarketCycleManager в техническом стиле.
  Widget _buildDevTraceBar(StressTestSession session) {
    final monoStyle = GoogleFonts.jetBrainsMono(
      fontSize: 11,
      fontWeight: FontWeight.w500,
      height: 1.3,
    );

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      color: const Color(0xFF1A1A2E),
      child: SingleChildScrollView(
        scrollDirection: Axis.horizontal,
        child: Row(
          children: [
            _devChip(
              'PHASE',
              session.devMarketPhase.isNotEmpty
                  ? session.devMarketPhase.toUpperCase()
                  : '—',
              const Color(0xFF7B68EE),
              monoStyle,
            ),
            const SizedBox(width: 12),
            _devChip(
              'TEMP',
              '${session.devMarketTemperature.toStringAsFixed(1)}°',
              _tempColor(session.devMarketTemperature),
              monoStyle,
            ),
            const SizedBox(width: 12),
            _devChip(
              'FATIGUE',
              '${(session.devFatigue * 100).toStringAsFixed(0)}%',
              const Color(0xFFFFA726),
              monoStyle,
            ),
            const SizedBox(width: 12),
            _devChip(
              'SEED',
              session.simulationSeed.toString(),
              const Color(0xFF66BB6A),
              monoStyle,
            ),
            const SizedBox(width: 12),
            _devChip(
              'TICK',
              '#${session.devCurrentTick}',
              const Color(0xFF42A5F5),
              monoStyle,
            ),
          ],
        ),
      ),
    );
  }

  Widget _devChip(String label, String value, Color accent, TextStyle mono) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Text(
          '$label ',
          style: mono.copyWith(
            color: accent.withValues(alpha: 0.7),
            fontSize: 9,
            letterSpacing: 0.8,
          ),
        ),
        Text(value, style: mono.copyWith(color: accent)),
      ],
    );
  }

  Color _tempColor(double temp) {
    if (temp >= 60) return const Color(0xFFEF5350); // Euphoria → red
    if (temp >= 30) return const Color(0xFFFFA726); // Greed → orange
    if (temp >= 10) return const Color(0xFF66BB6A); // Optimism → green
    if (temp > -10) return const Color(0xFFB0BEC5); // Neutral → grey
    if (temp > -30) return const Color(0xFF42A5F5); // Anxiety → blue
    if (temp > -60) return const Color(0xFF7E57C2); // Fear → purple
    return const Color(0xFFEF5350); // Panic → red
  }

  Widget _buildBalanceHeader({
    required double totalValue,
    required double unrealizedPnl,
    required double pnlPercent,
    required bool isPositive,
    required double startCash,
  }) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.fromLTRB(20, 8, 20, 16),
      decoration: const BoxDecoration(
        color: AppTheme.card,
        border: Border(bottom: BorderSide(color: AppTheme.borderSubtle)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // TOTAL VALUE
          Text(
            'TOTAL VALUE',
            style: GoogleFonts.inter(
              fontSize: 13,
              fontWeight: FontWeight.w500,
              color: AppTheme.accentBlue,
              letterSpacing: 0.8,
            ),
          ),
          const SizedBox(height: 4),
          // Главная сумма — жирный Serif
          Text(
            '\$${_fmt(totalValue)}',
            style: GoogleFonts.playfairDisplay(
              fontSize: 36,
              fontWeight: FontWeight.w700,
              color: AppTheme.textPrimary,
              height: 1.1,
            ),
          ),
          const SizedBox(height: 8),
          // Unrealized P&L
          Row(
            children: [
              Text(
                'UNREALIZED P&L',
                style: GoogleFonts.inter(
                  fontSize: 11,
                  fontWeight: FontWeight.w500,
                  color: AppTheme.textSecondary,
                  letterSpacing: 0.5,
                ),
              ),
              const SizedBox(width: 8),
              Text(
                '${isPositive ? '+' : ''}\$${_fmt(unrealizedPnl.abs())} '
                '(${isPositive ? '+' : ''}${pnlPercent.toStringAsFixed(2)}%)',
                style: GoogleFonts.inter(
                  fontSize: 12,
                  fontWeight: FontWeight.w700,
                  color: isPositive ? AppTheme.shieldGreen : AppTheme.dangerRed,
                ),
              ),
            ],
          ),
          const SizedBox(height: 4),
          // Start cash
          Row(
            children: [
              Text(
                'START CASH',
                style: GoogleFonts.inter(
                  fontSize: 11,
                  fontWeight: FontWeight.w500,
                  color: AppTheme.textSecondary,
                  letterSpacing: 0.5,
                ),
              ),
              const SizedBox(width: 8),
              Text(
                '\$${_fmt(startCash)}',
                style: GoogleFonts.inter(
                  fontSize: 12,
                  fontWeight: FontWeight.w600,
                  color: AppTheme.textPrimary,
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
          color: AppTheme.textSecondary.withValues(alpha: 0.3),
        ),
        color: AppTheme.card,
      ),
      child: TextField(
        controller: _searchController,
        onChanged: (v) => setState(() => _searchQuery = v.trim()),
        style: GoogleFonts.inter(fontSize: 14, color: AppTheme.textPrimary),
        decoration: InputDecoration(
          hintText: 'Search',
          hintStyle: GoogleFonts.inter(fontSize: 14, color: AppTheme.textDim),
          prefixIcon: const Icon(
            Icons.search_rounded,
            color: AppTheme.textDim,
            size: 20,
          ),
          border: InputBorder.none,
          contentPadding: const EdgeInsets.symmetric(
            horizontal: 12,
            vertical: 12,
          ),
          fillColor: AppTheme.card,
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
          _sortChip('Value', AssetSortMode.value),
          const SizedBox(width: 16),
          _sortChip('Market Price', AssetSortMode.marketPrice),
        ],
      ),
    );
  }

  Widget _sortChip(String label, AssetSortMode mode) {
    final isActive = _sortMode == mode;
    return GestureDetector(
      onTap: () => setState(() => _sortMode = mode),
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 6),
        decoration: BoxDecoration(
          border: Border(
            bottom: BorderSide(
              color: isActive ? AppTheme.accentBlue : Colors.transparent,
              width: 2,
            ),
          ),
        ),
        child: Text(
          label,
          style: GoogleFonts.inter(
            fontSize: 13,
            fontWeight: FontWeight.w600,
            color: isActive ? AppTheme.accentBlue : AppTheme.textDim,
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
