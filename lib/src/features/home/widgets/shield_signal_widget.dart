import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../../core/theme/theme_v2.dart';
import '../../../core/theme/typography_helpers.dart';
import '../../../core/theme/fomo_shield_theme.dart';
import '../../../shared/widgets/card_frame.dart';
import '../home_providers.dart';

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
  // Generous fixed height for the swipeable page area — content is always
  // a price cell + two small cells + an explanation paragraph of similar
  // length across all three indices.
  static const double _pageAreaHeight = 300;

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
                fontWeight: FontWeight.w800,
                color: ThemeV2.textPrimary)),
        data: (indices) {
          if (indices.isEmpty) return const SizedBox.shrink();
          final safeIndex = _index.clamp(0, indices.length - 1);

          return Column(
            children: [
              SizedBox(
                height: _pageAreaHeight,
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
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
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

    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        _cell(
          label: index.name,
          value: '\$${index.price.toStringAsFixed(2)}',
          valueFontSize: 20,
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
                valueFontSize: 18,
                bgColor: changeBg,
                valueColor: changeColor,
              ),
            ),
            const SizedBox(width: 8),
            Expanded(
              child: _cell(
                label: 'CHANGE %',
                value: '${isUp ? '+' : ''}${index.change.toStringAsFixed(2)}%',
                valueFontSize: 18,
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
            color: ThemeV2.surfaceDark.withValues(alpha: 0.5),
            borderRadius: BorderRadius.circular(16),
          ),
          child: Text(
            _explanation(index.name, index.level),
            style: GoogleFonts.inter(
              fontSize: 12,
              color: ThemeV2.textSecondary,
              height: 1.5,
            ),
          ),
        ),
      ],
    );
  }

  Widget _cell({
    required String label,
    required String value,
    Color? bgColor,
    Color? valueColor,
    double valueFontSize = 24,
    bool horizontalLayout = false,
  }) {
    final labelText = Text(
      label,
      style: GoogleFonts.inter(
        fontSize: 10,
        fontWeight: FontWeight.w700,
        letterSpacing: 0.6,
        color: ThemeV2.primary,
      ),
    );
    final valueText = Text(
      value,
      style: interNums(
        fontSize: valueFontSize,
        fontWeight: FontWeight.w800,
        color: valueColor ?? ThemeV2.textPrimary,
        letterSpacing: -0.3,
      ),
    );

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
      decoration: BoxDecoration(
        color: bgColor,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: ThemeV2.divider),
      ),
      child: horizontalLayout
          ? Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [labelText, valueText],
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

  /// Plain-language explanation, keyed by index + sentiment level.
  String _explanation(String name, String level) {
    final key = name.toUpperCase();
    final isNasdaq = key.contains('NASDAQ');
    final isDow = key.contains('DOW');

    switch (level) {
      case 'greed':
        if (isNasdaq) {
          return 'Nasdaq is rising because technology companies are gaining '
              'the most. This usually happens when investors believe in '
              'continued growth in technology and AI.';
        }
        if (isDow) {
          return 'Dow Jones is rising as the value of the largest, most '
              'stable companies increases. This signals positive '
              'expectations for the US economy.';
        }
        return 'The index is rising because investors are actively buying '
            'shares of large companies. This means market participants '
            'expect strong financial results from businesses and the '
            'economy.';
      case 'fear':
        if (isNasdaq) {
          return 'Nasdaq is falling as investors cut back on technology '
              'holdings. This usually happens when uncertainty rises or '
              'market sentiment worsens.';
        }
        if (isDow) {
          return 'Dow Jones is declining as investors exit large-company '
              'stocks, worried about a slowing economy or other negative '
              'factors.';
        }
        return 'The index is falling because investors are selling shares. '
            'This can be caused by concerns about the economy, weak company '
            'earnings, or negative news.';
      default:
        if (isNasdaq) {
          return 'Nasdaq is trading without a clear trend. Investors are '
              'assessing the current situation and aren\'t rushing into new '
              'decisions.';
        }
        if (isDow) {
          return 'Dow Jones is holding near previous levels. The market is '
              'waiting for major economic events or company earnings '
              'reports.';
        }
        return 'The index is barely moving. Buyers and sellers are roughly '
            'balanced, so the market is waiting for news and hasn\'t picked '
            'a direction.';
    }
  }
}
