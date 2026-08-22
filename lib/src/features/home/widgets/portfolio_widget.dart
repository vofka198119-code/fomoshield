import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../../core/theme/theme_v2.dart';
import '../../../core/theme/typography_helpers.dart';
import '../../../core/theme/fomo_shield_theme.dart';
import '../../../core/router/navigation_history_provider.dart';
import '../../../shared/utils/currency_format.dart';
import '../../../shared/widgets/card_frame.dart';
import '../../../shared/widgets/segment_gauge_math.dart';
import '../../market_clock/market_clock_dial.dart';
import '../../portfolio/portfolio_providers.dart';
import '../../portfolio/widgets/target_widget.dart' show targetDisplayPercent;
import '../../../l10n/gen/app_localizations.dart';

// ---------------------------------------------------------------------------
// Portfolio Widget — Live portfolio summary for Home screen
// ---------------------------------------------------------------------------

class PortfolioWidget extends ConsumerStatefulWidget {
  const PortfolioWidget({super.key});

  @override
  ConsumerState<PortfolioWidget> createState() => _PortfolioWidgetState();
}

class _PortfolioWidgetState extends ConsumerState<PortfolioWidget> {
  // Fixed height for the swipeable page area, sized to the actual 4-cell
  // content: top row (Balance/Cash stack, ~132) + 8 spacer + P&L/Change
  // stack (~122). Text is all fixed-size numbers/labels, so real content
  // height barely varies between portfolios. +30px over the tightest fit
  // as a safety margin — some devices' font metrics render the 4 cells'
  // labels/values a bit taller than others (confirmed overflow on a Redmi
  // Note 9S at 270, even with single-line labels).
  static const double _pageAreaHeight = 306;

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
          padding: const EdgeInsets.fromLTRB(16, 12, 16, 16),
          child: Text(
            AppLocalizations.of(context)!.portfolioWidgetNoPortfolio,
            style: GoogleFonts.inter(
              fontSize: 14,
              color: ThemeV2.textSecondary,
            ),
          ),
        ),
      );
    }

    final activeId = ref.watch(activePortfolioIdProvider);
    int index = activeId != null
        ? portfolios.indexWhere((p) => p.id == activeId)
        : 0;
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
        padding: const EdgeInsets.fromLTRB(16, 12, 16, 16),
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
    String? title,
    bool showPremiumBadge = false,
    required Widget child,
  }) {
    final resolvedTitle =
        title ?? AppLocalizations.of(context)!.portfolioWidgetTitle;
    return InkWell(
      onTap: () {
        ref.read(previousTabRouteProvider.notifier).state = '/home';
        context.go('/portfolio');
      },
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
                      resolvedTitle,
                      style: FomoShieldTheme.cardTitle(),
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                  if (showPremiumBadge) ...[
                    const SizedBox(width: 8),
                    _premiumPill(context),
                  ],
                ],
              ),
            ),
            Divider(
              height: 1,
              indent: 16,
              endIndent: 16,
              color: Colors.black.withValues(alpha: 0.06),
            ),
            child,
          ],
        ),
      ),
    );
  }

  Widget _premiumPill(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
      decoration: darkCardDecoration(borderRadius: BorderRadius.circular(12)),
      child: Text(
        AppLocalizations.of(context)!.profilePremiumBadge,
        style: GoogleFonts.inter(
          fontSize: 10,
          fontWeight: FontWeight.w800,
          color: dialBrassLight,
          letterSpacing: 1.5,
          shadows: [
            Shadow(color: dialBrassLight.withValues(alpha: 0.5), blurRadius: 6),
          ],
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
    final l10n = AppLocalizations.of(context)!;
    final performanceAsync = ref.watch(
      portfolioPerformanceProvider(portfolioId),
    );

    return performanceAsync.when(
      loading: () => Row(
        children: [
          const SizedBox(
            width: 18,
            height: 18,
            child: CircularProgressIndicator(
              strokeWidth: 2,
              color: ThemeV2.primary,
            ),
          ),
          const SizedBox(width: 12),
          Text(
            l10n.commonLoading,
            style: GoogleFonts.inter(
              fontSize: 14,
              color: ThemeV2.textSecondary,
            ),
          ),
        ],
      ),
      error: (_, _) => Text(
        '\$– – –',
        style: interNums(
          fontSize: 28,
          fontWeight: FontWeight.w600,
          color: ThemeV2.textPrimary,
        ),
      ),
      data: (perf) {
        final isUp = perf.pnl >= 0;
        final pnlColor = isUp ? ThemeV2.success : ThemeV2.loss;
        final pnlBg = isUp ? ThemeV2.successBg : ThemeV2.lossBg;
        final barPercent = targetDisplayPercent(
          currentValue: perf.currentValue,
          startingBalance: perf.startingBalance,
          goalAmount: perf.goalAmount,
        );

        // IntrinsicHeight so the Row (with a stretch child) gets a real
        // bounded height from the 4-cell column instead of an unbounded
        // one — see project memory on the infinite-height Row+stretch bug
        // that previously blanked this exact widget.
        return IntrinsicHeight(
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Expanded(
                child: Column(
                  children: [
                    _cell(
                      label: l10n.portfolioBalanceLabel,
                      value: formatUsd(perf.currentValue),
                      bgColor: ThemeV2.primaryBg,
                    ),
                    const SizedBox(height: 6),
                    _cell(
                      label: l10n.portfolioCashLabel,
                      value: formatUsd(perf.cash),
                      bgColor: ThemeV2.primaryBg,
                    ),
                    const SizedBox(height: 6),
                    _cell(
                      label: l10n.portfolioUnrealizedPnl,
                      value: formatUsdSigned(perf.pnl),
                      valueFontSize: 14,
                      bgColor: pnlBg,
                      valueColor: pnlColor,
                    ),
                    const SizedBox(height: 6),
                    _cell(
                      label: l10n.shieldSignalChange,
                      value:
                          '${isUp ? '+' : ''}${perf.pnlPercent.toStringAsFixed(2)}%',
                      valueFontSize: 14,
                      bgColor: pnlBg,
                      valueColor: pnlColor,
                    ),
                  ],
                ),
              ),
              const SizedBox(width: 10),
              Expanded(child: _VerticalProgressBar(currentPercent: barPercent)),
            ],
          ),
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
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 7),
      decoration: BoxDecoration(
        color: bgColor,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: ThemeV2.divider),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          FittedBox(
            fit: BoxFit.scaleDown,
            alignment: Alignment.centerLeft,
            child: Text(
              label,
              maxLines: 1,
              style: GoogleFonts.inter(
                fontSize: 10,
                fontWeight: FontWeight.w700,
                letterSpacing: 0.6,
                color: ThemeV2.primary,
              ),
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
                fontWeight: FontWeight.w600,
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

/// Vertical mirror of TARGET's `_GraphWindow` (`target_widget.dart`) — same
/// gradient panel, same 20-segment red/yellow/green fill, same pill and
/// tick styling, just rotated: pill on the left, bar in the middle,
/// -100%/0%/+100% ticks on the right (instead of marker-above,
/// bar-below, ticks-below). The panel fills its whole half of the Home
/// card — no extra whitespace around a narrower track.
class _VerticalProgressBar extends StatelessWidget {
  final double currentPercent; // -100..100

  const _VerticalProgressBar({required this.currentPercent});

  @override
  Widget build(BuildContext context) {
    final t = ((currentPercent + 100) / 200).clamp(0.0, 1.0); // 0 bottom..1 top
    // Fractional Alignment.y: -1 = top, +1 = bottom. t=0 (bottom) -> y=1,
    // t=1 (top) -> y=-1. No LayoutBuilder (and no pixel math from a
    // constraints.maxHeight) — IntrinsicHeight (used by the parent Row)
    // can't be wrapped around a LayoutBuilder, since LayoutBuilder can't
    // answer intrinsic-size queries; that combination threw "LayoutBuilder
    // does not support returning intrinsic dimensions" and silently
    // blanked this whole card. Align sidesteps the problem entirely.
    final pillAlignY = (1 - 2 * t).clamp(-1.0, 1.0);

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.fromLTRB(10, 10, 12, 14),
      decoration: darkCardDecoration(borderRadius: BorderRadius.circular(16)),
      // Same window title treatment as the cells to the left (label above
      // content), just in white — the cells' primary-green label color
      // would be invisible against this dark gradient. The window itself
      // doesn't grow: the title eats into the same space the bar used to
      // have, so the bar segments got a bit shorter and are narrowed
      // further (0.8 -> 0.65 width factor) to keep their proportions.
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          Text(
            AppLocalizations.of(context)!.targetLabel,
            style: GoogleFonts.inter(
              fontSize: 10,
              fontWeight: FontWeight.w700,
              letterSpacing: 0.6,
              color: Colors.white,
            ),
          ),
          const SizedBox(height: 6),
          Expanded(
            child: Row(
              children: [
                // Marker pill, floating beside the bar at the current position.
                SizedBox(
                  width: 34,
                  child: Align(
                    alignment: Alignment(0, pillAlignY),
                    child: Container(
                      height: 20,
                      padding: const EdgeInsets.symmetric(horizontal: 2),
                      alignment: Alignment.center,
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(6),
                      ),
                      child: Text(
                        '${currentPercent >= 0 ? '+' : ''}${currentPercent.toStringAsFixed(0)}%',
                        style: GoogleFonts.inter(
                          fontSize: 10,
                          fontWeight: FontWeight.w700,
                          color: ThemeV2.primary,
                        ),
                      ),
                    ),
                  ),
                ),
                const SizedBox(width: 4),
                // The segmented bar itself, narrowed (centered).
                Expanded(
                  child: FractionallySizedBox(
                    widthFactor: 0.65,
                    child: Column(
                      verticalDirection: VerticalDirection.up,
                      children: List.generate(SegmentGaugeMath.segmentCount, (
                        i,
                      ) {
                        final fraction = SegmentGaugeMath.fillFraction(
                          currentPercent,
                          i,
                        );
                        return Expanded(
                          child: Container(
                            margin: EdgeInsets.only(
                              top: i == SegmentGaugeMath.segmentCount - 1
                                  ? 0
                                  : 3,
                            ),
                            clipBehavior: Clip.antiAlias,
                            decoration: BoxDecoration(
                              color: SegmentGaugeMath.unfilled,
                              borderRadius: BorderRadius.circular(4),
                            ),
                            child: fraction > 0
                                ? Align(
                                    alignment: Alignment.bottomCenter,
                                    child: FractionallySizedBox(
                                      heightFactor: fraction,
                                      child: Container(
                                        color: SegmentGaugeMath.colorForIndex(
                                          i,
                                        ),
                                      ),
                                    ),
                                  )
                                : null,
                          ),
                        );
                      }),
                    ),
                  ),
                ),
                const SizedBox(width: 6),
                // -100%/0%/+100% ticks, bottom to top.
                Column(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: const [
                    _VerticalTick('+100%'),
                    _VerticalTick('0%'),
                    _VerticalTick('-100%'),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _VerticalTick extends StatelessWidget {
  final String label;
  const _VerticalTick(this.label);

  @override
  Widget build(BuildContext context) {
    return Text(
      label,
      style: GoogleFonts.inter(
        fontSize: 10,
        fontWeight: FontWeight.w600,
        color: Colors.white.withValues(alpha: 0.5),
      ),
    );
  }
}
