import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../../core/theme/theme_v2.dart';
import '../../../core/theme/fomo_shield_theme.dart';
import '../../../core/theme/typography_helpers.dart';
import '../../../shared/utils/currency_format.dart';
import '../../market_clock/market_clock_dial.dart'
    show dialBrassLight, darkCardDecoration;
import '../../portfolio/portfolio_providers.dart';

// ===========================================================================
// Position Section — "MY INVESTMENTS"
// One isolated page per portfolio the user has, swipeable. A portfolio that
// doesn't hold this symbol still gets its own page, shown with dashes — it
// never borrows or blends numbers from another portfolio's holding of the
// same symbol.
// ===========================================================================

typedef _PortfolioPosition = ({
  String portfolioName,
  double shares,
  double avgCost,
  double totalValue,
  double totalCost,
  bool hasPosition,
});

class PositionSection extends ConsumerStatefulWidget {
  final String symbol;
  final double price;

  const PositionSection({super.key, required this.symbol, required this.price});

  @override
  ConsumerState<PositionSection> createState() => _PositionSectionState();
}

class _PositionSectionState extends ConsumerState<PositionSection> {
  late final PageController _pageController;
  int _index = 0;

  @override
  void initState() {
    super.initState();
    _pageController = PageController();
  }

  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }

  void _goTo(int i, int count) {
    if (i < 0 || i >= count) return;
    setState(() => _index = i);
    _pageController.animateToPage(
      i,
      duration: const Duration(milliseconds: 300),
      curve: Curves.easeOut,
    );
  }

  @override
  Widget build(BuildContext context) {
    final portfolios = ref.watch(portfoliosProvider);

    // Cost basis is pure transaction math (no live price involved), so this
    // reads straight off Portfolio.holdings instead of going through
    // portfolioPerformanceProvider — that provider fetches a live Finnhub
    // quote for EVERY holding in EVERY portfolio, which this widget never
    // needed just to show avg-cost/shares for one symbol.
    final positions = <_PortfolioPosition>[];
    for (final p in portfolios) {
      final holding = p.holdings[widget.symbol];
      final shares = holding?['shares'] ?? 0;
      final hasPosition = shares > 0;
      final avgCost = hasPosition ? holding!['cost']! / shares : 0.0;
      positions.add((
        portfolioName: p.name,
        shares: hasPosition ? shares : 0,
        avgCost: avgCost,
        totalValue: hasPosition ? shares * widget.price : 0,
        totalCost: hasPosition ? holding!['cost']! : 0,
        hasPosition: hasPosition,
      ));
    }

    if (positions.isEmpty) return const SizedBox.shrink();

    final safeIndex = _index.clamp(0, positions.length - 1);

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: Container(
        padding: const EdgeInsets.all(FomoShieldTheme.cardPadding),
        decoration: darkCardDecoration(),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'MY INVESTMENTS',
              style: FomoShieldTheme.cardTitle(Colors.white),
            ),
            const SizedBox(height: 10),
            Divider(height: 1, color: Colors.white.withValues(alpha: 0.15)),
            if (positions.length > 1) ...[
              const SizedBox(height: 10),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Flexible(
                    child: Text(
                      positions[safeIndex].portfolioName,
                      overflow: TextOverflow.ellipsis,
                      style: GoogleFonts.inter(
                        fontSize: 14,
                        fontWeight: FontWeight.w600,
                        color: safeIndex > 0 ? dialBrassLight : Colors.white,
                      ),
                    ),
                  ),
                  if (safeIndex > 0) _premiumBadge(),
                ],
              ),
            ],
            const SizedBox(height: 12),
            Stack(
              children: [
                // Invisible but fully laid-out — sizes the Stack to the
                // tallest page's content so the real PageView below never
                // clips, without hand-guessing a fixed pixel height.
                Visibility(
                  visible: false,
                  maintainSize: true,
                  maintainAnimation: true,
                  maintainState: true,
                  child: IndexedStack(
                    index: 0,
                    children: [
                      for (final pos in positions) _positionBlock(pos),
                    ],
                  ),
                ),
                Positioned.fill(
                  child: PageView.builder(
                    controller: _pageController,
                    itemCount: positions.length,
                    onPageChanged: (i) => setState(() => _index = i),
                    itemBuilder: (context, i) => Align(
                      alignment: Alignment.topCenter,
                      child: _positionBlock(positions[i]),
                    ),
                  ),
                ),
              ],
            ),
            if (positions.length > 1) ...[
              const SizedBox(height: 12),
              _dots(
                count: positions.length,
                current: safeIndex,
                onTap: (i) => _goTo(i, positions.length),
              ),
            ],
          ],
        ),
      ),
    );
  }

  Widget _positionBlock(_PortfolioPosition pos) {
    final pnl = pos.totalValue - pos.totalCost;
    final pnlPercent = pos.totalCost > 0 ? (pnl / pos.totalCost) * 100 : 0.0;
    final isUp = pnl >= 0;
    final pnlColor = isUp ? ThemeV2.success : ThemeV2.loss;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _row('Asset Value', pos.hasPosition ? formatUsd(pos.totalValue) : '—'),
        const SizedBox(height: 8),
        _row('Shares', pos.hasPosition ? pos.shares.toStringAsFixed(4) : '—'),
        const SizedBox(height: 8),
        _pnlRow(
          pos,
          pnl: pnl,
          pnlPercent: pnlPercent,
          isUp: isUp,
          pnlColor: pnlColor,
        ),
        const SizedBox(height: 8),
        _row('Avg Cost', pos.hasPosition ? formatUsd(pos.avgCost) : '—'),
      ],
    );
  }

  // Label/value font matches the "Active — {duration}" tile in the Home
  // MY STRESS TEST widget (stress_test_widget.dart) — the app's reference
  // for readable label+number pairs; value uses interNums() (tabular
  // figures) rather than plain GoogleFonts.inter like every other number
  // in the app.
  Widget _row(String label, String value) => Row(
    mainAxisAlignment: MainAxisAlignment.spaceBetween,
    children: [
      Text(
        label,
        style: GoogleFonts.inter(
          fontSize: 13,
          fontWeight: FontWeight.w600,
          color: Colors.white,
        ),
      ),
      Text(
        value,
        style: interNums(
          fontSize: 14,
          fontWeight: FontWeight.w600,
          color: Colors.white,
        ),
      ),
    ],
  );

  Widget _pnlRow(
    _PortfolioPosition pos, {
    required double pnl,
    required double pnlPercent,
    required bool isUp,
    required Color pnlColor,
  }) => Row(
    mainAxisAlignment: MainAxisAlignment.spaceBetween,
    children: [
      Text(
        'Unrealized P&L',
        style: GoogleFonts.inter(
          fontSize: 13,
          fontWeight: FontWeight.w600,
          color: Colors.white,
        ),
      ),
      if (!pos.hasPosition)
        Text(
          '—',
          style: interNums(
            fontSize: 14,
            fontWeight: FontWeight.w600,
            color: Colors.white,
          ),
        )
      else
        Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              isUp ? Icons.arrow_upward_rounded : Icons.arrow_downward_rounded,
              size: 14,
              color: pnlColor,
            ),
            const SizedBox(width: 4),
            Text(
              '${formatUsdSigned(pnl)} (${pnlPercent.toStringAsFixed(2)}%)',
              style: interNums(
                fontSize: 14,
                fontWeight: FontWeight.w600,
                color: pnlColor,
              ),
            ),
          ],
        ),
    ],
  );

  // Same "PREMIUM" tag used elsewhere (see PortfolioOptionTile), but as a
  // gold outline instead of its usual dark-green fill — a filled chip in
  // the same dialLight/dialDark gradient would disappear into this card's
  // own background.
  Widget _premiumBadge() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
      decoration: BoxDecoration(
        border: Border.all(color: dialBrassLight, width: 1),
        borderRadius: BorderRadius.circular(6),
        boxShadow: [
          BoxShadow(
            color: dialBrassLight.withValues(alpha: 0.35),
            blurRadius: 4,
          ),
        ],
      ),
      child: Text(
        'PREMIUM',
        style: GoogleFonts.inter(
          fontSize: 9,
          fontWeight: FontWeight.w800,
          color: dialBrassLight,
          letterSpacing: 0.8,
        ),
      ),
    );
  }

  Widget _dots({
    required int count,
    required int current,
    required void Function(int) onTap,
  }) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: List.generate(count, (i) {
        final isActive = i == current;
        return GestureDetector(
          onTap: () => onTap(i),
          child: AnimatedContainer(
            duration: const Duration(milliseconds: 200),
            margin: const EdgeInsets.symmetric(horizontal: 3),
            width: isActive ? 16 : 6,
            height: 6,
            decoration: BoxDecoration(
              color: isActive
                  ? Colors.white
                  : Colors.white.withValues(alpha: 0.3),
              borderRadius: BorderRadius.circular(3),
            ),
          ),
        );
      }),
    );
  }
}
