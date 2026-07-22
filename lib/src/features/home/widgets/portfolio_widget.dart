import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../../core/theme/theme_v2.dart';
import '../../../core/theme/typography_helpers.dart';
import '../../../core/theme/fomo_shield_theme.dart';
import '../../../shared/widgets/card_frame.dart';
import '../../portfolio/portfolio_providers.dart';
import 'portfolio_goal_gauge.dart';

// ---------------------------------------------------------------------------
// Portfolio Widget — Live portfolio summary for Home screen
// ---------------------------------------------------------------------------

class PortfolioWidget extends ConsumerStatefulWidget {
  const PortfolioWidget({super.key});

  @override
  ConsumerState<PortfolioWidget> createState() => _PortfolioWidgetState();
}

class _PortfolioWidgetState extends ConsumerState<PortfolioWidget> {
  // Generous fixed height for the swipeable page area — the 4-cell layout's
  // text is all fixed-size numbers/labels, so real content height barely
  // varies between portfolios; top-aligned content absorbs the rest.
  static const double _pageAreaHeight = 230;

  late final PageController _pageController;
  int _currentIndex = 0;

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

  void _goTo(int i, List<Portfolio> portfolios) {
    if (i < 0 || i >= portfolios.length) return;
    ref.read(activePortfolioIdProvider.notifier).state = portfolios[i].id;
    _pageController.animateToPage(
      i,
      duration: const Duration(milliseconds: 300),
      curve: Curves.easeOut,
    );
  }

  @override
  Widget build(BuildContext context) {
    final portfolios = ref.watch(portfoliosProvider);

    if (portfolios.isEmpty) {
      return _shell(
        context,
        child: Padding(
          padding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
          child: Text('No portfolio',
              style: GoogleFonts.inter(
                  fontSize: 14, color: ThemeV2.textSecondary)),
        ),
      );
    }

    final activeId = ref.watch(activePortfolioIdProvider);
    int index =
        activeId != null ? portfolios.indexWhere((p) => p.id == activeId) : 0;
    if (index < 0) index = 0;
    _currentIndex = _currentIndex.clamp(0, portfolios.length - 1);

    // Keep the page view in sync if the active portfolio changed from
    // elsewhere (e.g. the full Portfolio screen's own switcher).
    if (_pageController.hasClients && _pageController.page?.round() != index) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (_pageController.hasClients) {
          _pageController.animateToPage(
            index,
            duration: const Duration(milliseconds: 300),
            curve: Curves.easeOut,
          );
        }
      });
    }

    return _shell(
      context,
      title: portfolios[index].name.toUpperCase(),
      showPremiumBadge: index > 0,
      child: Padding(
        padding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
        child: Column(
          children: [
            SizedBox(
              height: _pageAreaHeight,
              child: PageView.builder(
                controller: _pageController,
                itemCount: portfolios.length,
                onPageChanged: (i) {
                  setState(() => _currentIndex = i);
                  ref.read(activePortfolioIdProvider.notifier).state =
                      portfolios[i].id;
                },
                itemBuilder: (context, i) => Align(
                  alignment: Alignment.topCenter,
                  child: _PortfolioPerformanceView(
                    portfolioId: portfolios[i].id,
                  ),
                ),
              ),
            ),
            if (portfolios.length > 1) ...[
              const SizedBox(height: 12),
              _dots(
                count: portfolios.length,
                current: _currentIndex,
                onTap: (i) => _goTo(i, portfolios),
              ),
            ],
          ],
        ),
      ),
    );
  }

  /// Card chrome + header, shared by loading/error/empty/data states.
  Widget _shell(
    BuildContext context, {
    String title = 'PORTFOLIO',
    bool showPremiumBadge = false,
    required Widget child,
  }) {
    return InkWell(
      onTap: () => context.go('/portfolio'),
      borderRadius: FomoShieldTheme.cardRadius,
      child: CardFrame(
        showTopBar: false,
        padding: EdgeInsets.zero,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Padding(
              padding: const EdgeInsets.fromLTRB(22, 14, 22, 14),
              child: Row(
                children: [
                  Flexible(
                    child: Text(
                      title,
                      style: FomoShieldTheme.cardTitle(),
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                  if (showPremiumBadge) ...[
                    const SizedBox(width: 8),
                    _premiumPill(),
                  ],
                ],
              ),
            ),
            child,
          ],
        ),
      ),
    );
  }

  Widget _premiumPill() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
      decoration: BoxDecoration(
        color: ThemeV2.primary,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Text(
        'PREMIUM',
        style: GoogleFonts.inter(
          fontSize: 10,
          fontWeight: FontWeight.w800,
          color: Colors.white,
          letterSpacing: 1.5,
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
                  ? ThemeV2.primary
                  : ThemeV2.primary.withValues(alpha: 0.25),
              borderRadius: BorderRadius.circular(3),
            ),
          ),
        );
      }),
    );
  }
}

/// Renders the 4-cell performance breakdown for a single portfolio.
class _PortfolioPerformanceView extends ConsumerWidget {
  final String portfolioId;

  const _PortfolioPerformanceView({required this.portfolioId});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final performanceAsync =
        ref.watch(portfolioPerformanceProvider(portfolioId));

    return performanceAsync.when(
      loading: () => Row(
        children: [
          const SizedBox(
            width: 18,
            height: 18,
            child: CircularProgressIndicator(
                strokeWidth: 2, color: ThemeV2.primary),
          ),
          const SizedBox(width: 12),
          Text('Loading...',
              style: GoogleFonts.inter(
                  fontSize: 14, color: ThemeV2.textSecondary)),
        ],
      ),
      error: (_, _) => Text('\$– – –',
          style: interNums(
              fontSize: 28,
              fontWeight: FontWeight.w800,
              color: ThemeV2.textPrimary)),
      data: (perf) {
        final isUp = perf.pnl >= 0;
        final pnlColor = isUp ? ThemeV2.success : ThemeV2.loss;
        final pnlBg = isUp ? ThemeV2.successBg : ThemeV2.lossBg;

        return Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Row(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Expanded(
                  flex: 3,
                  child: Column(
                    children: [
                      _cell(
                        label: 'PORTFOLIO BALANCE',
                        value: '\$${perf.currentValue.toStringAsFixed(2)}',
                        bgColor: ThemeV2.primaryBg,
                      ),
                      const SizedBox(height: 8),
                      _cell(
                        label: 'CASH AVAILABLE',
                        value: '\$${perf.cash.toStringAsFixed(2)}',
                        bgColor: ThemeV2.primaryBg,
                      ),
                    ],
                  ),
                ),
                const SizedBox(width: 8),
                Expanded(
                  flex: 2,
                  child: PortfolioGoalGauge(
                    portfolioId: portfolioId,
                    currentValue: perf.currentValue,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 8),
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Expanded(
                  child: _cell(
                    label: 'UNREALIZED P&L',
                    value:
                        '${isUp ? '+' : ''}\$${perf.pnl.toStringAsFixed(2)}',
                    valueFontSize: 14,
                    bgColor: pnlBg,
                    valueColor: pnlColor,
                  ),
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: _cell(
                    label: 'CHANGE',
                    value:
                        '${isUp ? '+' : ''}${perf.pnlPercent.toStringAsFixed(2)}%',
                    valueFontSize: 14,
                    bgColor: pnlBg,
                    valueColor: pnlColor,
                  ),
                ),
              ],
            ),
          ],
        );
      },
    );
  }

  Widget _cell({
    required String label,
    required String value,
    Color? bgColor,
    Color? valueColor,
    double valueFontSize = 18,
  }) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
      decoration: BoxDecoration(
        color: bgColor,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: ThemeV2.divider),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            label,
            style: GoogleFonts.inter(
              fontSize: 10,
              fontWeight: FontWeight.w700,
              letterSpacing: 0.6,
              color: ThemeV2.primary,
            ),
          ),
          const SizedBox(height: 4),
          FittedBox(
            fit: BoxFit.scaleDown,
            alignment: Alignment.centerLeft,
            child: Text(
              value,
              style: interNums(
                fontSize: valueFontSize,
                fontWeight: FontWeight.w800,
                color: valueColor ?? ThemeV2.textPrimary,
                letterSpacing: -0.3,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
