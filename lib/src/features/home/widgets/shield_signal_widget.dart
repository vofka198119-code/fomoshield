import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../../core/theme/theme_v2.dart';
import '../../../core/theme/typography_helpers.dart';
import '../../../core/theme/fomo_shield_theme.dart';
import '../../../shared/widgets/card_frame.dart';
import '../../market_clock/market_clock_dial.dart';
import '../home_providers.dart';

// Same dark-green instrument-panel gradient as the TARGET widget's graph
// window (market_clock_dial.dart's dialLight/dialDark).
const List<Color> _priceCellGradient = [dialLight, dialDark];

// ---------------------------------------------------------------------------
// Shield Signal Widget — S&P 500 / NASDAQ / Dow Jones sentiment, swipeable
// ---------------------------------------------------------------------------

class ShieldSignalWidget extends ConsumerStatefulWidget {
  const ShieldSignalWidget({super.key});

  @override
  ConsumerState<ShieldSignalWidget> createState() =>
      _ShieldSignalWidgetState();
}

class _ShieldSignalWidgetState extends ConsumerState<ShieldSignalWidget> {
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
    final indicesAsync = ref.watch(marketIndicesProvider);

    return _shell(
      child: indicesAsync.when(
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
                fontWeight: FontWeight.w600,
                color: ThemeV2.textPrimary)),
        data: (indices) {
          if (indices.isEmpty) return const SizedBox.shrink();
          final safeIndex = _index.clamp(0, indices.length - 1);

          return Column(
            children: [
              Stack(
                children: [
                  // Invisible but fully laid-out — forces the Stack to size
                  // itself to the tallest index's content so the real
                  // PageView below never clips regardless of copy length.
                  Visibility(
                    visible: false,
                    maintainSize: true,
                    maintainAnimation: true,
                    maintainState: true,
                    child: IndexedStack(
                      index: 0,
                      children: [
                        for (final idx in indices) _IndexView(index: idx),
                      ],
                    ),
                  ),
                  Positioned.fill(
                    child: PageView.builder(
                      controller: _pageController,
                      itemCount: indices.length,
                      onPageChanged: (i) => setState(() => _index = i),
                      itemBuilder: (context, i) => Align(
                        alignment: Alignment.topCenter,
                        child: _IndexView(index: indices[i]),
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 12),
              _dots(
                count: indices.length,
                current: safeIndex,
                onTap: (i) => _goTo(i, indices.length),
              ),
            ],
          );
        },
      ),
    );
  }

  Widget _shell({required Widget child}) {
    return CardFrame(
      showTopBar: false,
      padding: EdgeInsets.zero,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: const EdgeInsets.fromLTRB(22, 14, 22, 14),
            child: Text('SHIELD SIGNAL', style: FomoShieldTheme.cardTitle()),
          ),
          Divider(
            height: 1,
            indent: 16,
            endIndent: 16,
            color: Colors.black.withValues(alpha: 0.06),
          ),
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 12, 16, 16),
            child: child,
          ),
        ],
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

/// Renders price/change cells + plain-language explanation for one index.
class _IndexView extends StatelessWidget {
  final MarketIndex index;

  const _IndexView({required this.index});

  @override
  Widget build(BuildContext context) {
    final isUp = index.change >= 0;
    final changeColor = isUp ? ThemeV2.success : ThemeV2.loss;
    final changeBg = isUp ? ThemeV2.successBg : ThemeV2.lossBg;
    final mood = _moodFor(index.change);

    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        _cell(
          label: index.name,
          value: '\$${index.price.toStringAsFixed(2)}',
          valueFontSize: 18,
          labelFontSize: 14,
          gradient: const LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: _priceCellGradient,
          ),
          labelColor: changeColor,
          labelGlowColor: changeColor,
          valueColor: Colors.white,
          leadingIcon: isUp ? Icons.trending_up : Icons.trending_down,
          leadingIconColor: changeColor,
          horizontalLayout: true,
        ),
        const SizedBox(height: 8),
        Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Expanded(
              child: _cell(
                label: 'CHANGE',
                value:
                    '${isUp ? '+' : ''}\$${index.changeAbs.toStringAsFixed(2)}',
                valueFontSize: 14,
                bgColor: changeBg,
                valueColor: changeColor,
              ),
            ),
            const SizedBox(width: 8),
            Expanded(
              child: _cell(
                label: 'CHANGE %',
                value: '${isUp ? '+' : ''}${index.change.toStringAsFixed(2)}%',
                valueFontSize: 14,
                bgColor: changeBg,
                valueColor: changeColor,
              ),
            ),
          ],
        ),
        const SizedBox(height: 12),
        Container(
          width: double.infinity,
          padding: const EdgeInsets.all(14),
          decoration: BoxDecoration(
            gradient: const LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: _priceCellGradient,
            ),
            borderRadius: BorderRadius.circular(16),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                mood.title,
                style: GoogleFonts.inter(
                  fontSize: 13,
                  fontWeight: FontWeight.w700,
                  color: Colors.white,
                ),
              ),
              const SizedBox(height: 6),
              Text(
                mood.body,
                style: GoogleFonts.inter(
                  fontSize: 12,
                  color: Colors.white.withValues(alpha: 0.85),
                  height: 1.5,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _cell({
    required String label,
    required String value,
    Color? bgColor,
    Gradient? gradient,
    Color? valueColor,
    Color? labelColor,
    Color? labelGlowColor,
    IconData? leadingIcon,
    Color? leadingIconColor,
    double valueFontSize = 18,
    double labelFontSize = 10,
    bool horizontalLayout = false,
  }) {
    final labelText = Text(
      label,
      style: GoogleFonts.inter(
        fontSize: labelFontSize,
        fontWeight: FontWeight.w700,
        letterSpacing: 0.6,
        color: labelColor ?? ThemeV2.primary,
        shadows: labelGlowColor == null
            ? null
            : [
                Shadow(color: labelGlowColor.withValues(alpha: 0.9), blurRadius: 10),
                Shadow(color: labelGlowColor.withValues(alpha: 0.5), blurRadius: 20),
              ],
      ),
    );
    final labelWidget = leadingIcon == null
        ? labelText
        : Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(leadingIcon,
                  size: 16, color: leadingIconColor ?? (labelColor ?? ThemeV2.primary)),
              const SizedBox(width: 6),
              labelText,
            ],
          );
    final valueText = Text(
      value,
      style: interNums(
        fontSize: valueFontSize,
        fontWeight: FontWeight.w600,
        color: valueColor ?? ThemeV2.textPrimary,
        letterSpacing: -0.3,
      ),
    );

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
      decoration: BoxDecoration(
        color: gradient == null ? bgColor : null,
        gradient: gradient,
        borderRadius: BorderRadius.circular(16),
        border: gradient == null ? Border.all(color: ThemeV2.divider) : null,
      ),
      child: horizontalLayout
          ? Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [labelWidget, valueText],
            )
          : Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                labelText,
                const SizedBox(height: 4),
                valueText,
              ],
            ),
    );
  }

  /// Emotional headline + body, keyed by the day's percent move. Thresholds
  /// split each direction into a "small" and "strong" band, with a ±0.1%
  /// dead zone in the middle counting as neutral.
  _Mood _moodFor(double changePercent) {
    if (changePercent >= 1.0) {
      return const _Mood(
        'Bullish Momentum',
        'Buyers are clearly leading today\'s market. Strong demand is '
            'pushing prices higher across many companies, and positive news '
            'or growing optimism is encouraging investors to keep buying. '
            'Momentum is on the bulls\' side — just remember, even strong '
            'trends eventually slow down, so avoid chasing prices out of '
            'excitement.',
      );
    }
    if (changePercent > 0.1) {
      return const _Mood(
        'Steady Climb',
        'Buyers have a slight advantage today. Demand is a little stronger '
            'than selling pressure, pushing the index higher. The move is '
            'healthy and controlled, with no signs of panic or excessive '
            'excitement — confidence is slowly building.',
      );
    }
    if (changePercent >= -0.1) {
      return const _Mood(
        'Waiting for Direction',
        'The market is taking a breath. Buyers and sellers are evenly '
            'matched, so prices are moving very little. Nothing unusual is '
            'happening right now — investors are simply waiting for the '
            'next piece of important news before choosing a direction.',
      );
    }
    if (changePercent >= -1.0) {
      return const _Mood(
        'Growing Caution',
        'Sellers have gained a small advantage. The market is drifting '
            'lower, but there are no signs of panic. Small pullbacks like '
            'this are a normal part of investing.',
      );
    }
    return const _Mood(
      'Storm Warning',
      'Fear is spreading through the market. Selling pressure is much '
          'stronger than buying, causing prices to fall quickly. Sharp '
          'declines can feel uncomfortable, but emotional decisions often '
          'make difficult days even worse.',
    );
  }
}

class _Mood {
  final String title;
  final String body;
  const _Mood(this.title, this.body);
}
