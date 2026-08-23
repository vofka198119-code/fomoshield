import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../../core/theme/theme_v2.dart';
import '../../../core/theme/typography_helpers.dart';
import '../../../core/theme/fomo_shield_theme.dart';
import '../../../core/theme/app_palette.dart';
import '../../../core/theme/themed_header.dart';
import '../../../core/theme/themed_border.dart';
import '../../../core/theme/themed_divider.dart';
import '../../../core/theme/theme_variant_provider.dart';
import '../../../shared/utils/currency_format.dart';
import '../../../shared/widgets/card_frame.dart';
import '../../../l10n/gen/app_localizations.dart';
import '../../market_clock/market_clock_dial.dart';
import '../home_providers.dart';

// ---------------------------------------------------------------------------
// Shield Signal Widget — S&P 500 / NASDAQ / Dow Jones sentiment, swipeable
// ---------------------------------------------------------------------------

class ShieldSignalWidget extends ConsumerStatefulWidget {
  const ShieldSignalWidget({super.key});

  @override
  ConsumerState<ShieldSignalWidget> createState() => _ShieldSignalWidgetState();
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
    final l10n = AppLocalizations.of(context)!;
    final indicesAsync = ref.watch(marketIndicesProvider);
    final palette = resolveAppPalette(ref.watch(themeVariantProvider));

    return _shell(
      palette: palette,
      child: indicesAsync.when(
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
                        for (final idx in indices)
                          _IndexView(index: idx, palette: palette),
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
                        child: _IndexView(index: indices[i], palette: palette),
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
                palette: palette,
              ),
            ],
          );
        },
      ),
    );
  }

  Widget _shell({required Widget child, required AppPalette palette}) {
    // Luxury Gold pilot widget (2026-08-23): gradient border + glow
    // (molecule 2) and radial card background (molecule 4) — title/divider
    // recolored here only because a dark card background would otherwise
    // make the original dark-on-light title/divider unreadable; the rest
    // of this widget's content is untouched (molecule 3 still deferred).
    return CardFrame(
      showTopBar: false,
      padding: EdgeInsets.zero,
      palette: palette,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: const EdgeInsets.fromLTRB(22, 14, 22, 14),
            child: themedHeaderText(
              AppLocalizations.of(context)!.shieldSignalTitle,
              palette,
              FomoShieldTheme.cardTitle(),
            ),
          ),
          themedDivider(palette),
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
    required AppPalette palette,
  }) {
    // Same treatment as buttons: active dot fills with the theme's button
    // gradient (+ its glow) instead of a flat brand color; inactive dots
    // dim the theme's own accent instead of the brand green. Null
    // buttonGradient (Standard theme) falls back to the original flat
    // ThemeV2.primary look, unchanged.
    final buttonGradient = palette.buttonGradient;
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
              color: buttonGradient == null
                  ? (isActive
                        ? ThemeV2.primary
                        : ThemeV2.primary.withValues(alpha: 0.25))
                  : (isActive
                        ? null
                        : palette.accentPrimary.withValues(alpha: 0.25)),
              gradient: buttonGradient != null && isActive
                  ? buttonGradient
                  : null,
              borderRadius: BorderRadius.circular(3),
              boxShadow:
                  buttonGradient != null &&
                      isActive &&
                      palette.glowShadow != null
                  ? [palette.glowShadow!]
                  : null,
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
  final AppPalette palette;

  const _IndexView({required this.index, required this.palette});

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final isUp = index.change >= 0;
    final changeColor = isUp ? ThemeV2.success : ThemeV2.loss;
    final changeBg = isUp ? ThemeV2.successBg : ThemeV2.lossBg;
    final mood = _moodFor(l10n, index.change);
    // Every inner "window" (stat tile, mood panel) gets the same border
    // treatment as the outer card — confirmed universal, 2026-08-23. See
    // themed_border.dart's doc comment.
    const cellRadius = BorderRadius.all(Radius.circular(16));

    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        themedBorder(
          palette: palette,
          borderRadius: cellRadius,
          child: _cell(
            label: index.name,
            value: formatUsd(index.price),
            valueFontSize: 18,
            labelFontSize: 14,
            gradient: palette.windowGradient ?? darkCardGradient(),
            labelColor: changeColor,
            labelGlowColor: changeColor,
            valueColor: Colors.white,
            goldValue: true,
            leadingIcon: isUp ? Icons.trending_up : Icons.trending_down,
            leadingIconColor: changeColor,
            horizontalLayout: true,
            palette: palette,
          ),
        ),
        const SizedBox(height: 8),
        Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Expanded(
              child: themedBorder(
                palette: palette,
                borderRadius: cellRadius,
                child: _cell(
                  label: l10n.shieldSignalChange,
                  value: formatUsdSigned(index.changeAbs),
                  valueFontSize: 14,
                  bgColor: changeBg,
                  valueColor: changeColor,
                  labelColor: changeColor,
                  labelGlowColor: changeColor,
                  palette: palette,
                ),
              ),
            ),
            const SizedBox(width: 8),
            Expanded(
              child: themedBorder(
                palette: palette,
                borderRadius: cellRadius,
                child: _cell(
                  label: l10n.shieldSignalChangePercent,
                  value:
                      '${isUp ? '+' : ''}${index.change.toStringAsFixed(2)}%',
                  valueFontSize: 14,
                  bgColor: changeBg,
                  valueColor: changeColor,
                  labelColor: changeColor,
                  labelGlowColor: changeColor,
                  palette: palette,
                ),
              ),
            ),
          ],
        ),
        const SizedBox(height: 12),
        themedBorder(
          palette: palette,
          borderRadius: cellRadius,
          child: Container(
            width: double.infinity,
            padding: const EdgeInsets.all(14),
            decoration: palette.windowGradient != null
                ? BoxDecoration(
                    gradient: palette.windowGradient,
                    borderRadius: cellRadius,
                  )
                : darkCardDecoration(borderRadius: cellRadius),
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
        ),
      ],
    );
  }

  Widget _cell({
    required AppPalette palette,
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
    // Canonical gold treatment for a neutral price with no up/down meaning
    // of its own (see themedPriceText's doc comment) — never combine with
    // a green/red valueColor, the two are mutually exclusive by design.
    bool goldValue = false,
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
                Shadow(
                  color: labelGlowColor.withValues(alpha: 0.9),
                  blurRadius: 10,
                ),
                Shadow(
                  color: labelGlowColor.withValues(alpha: 0.5),
                  blurRadius: 20,
                ),
              ],
      ),
    );
    final labelWidget = leadingIcon == null
        ? labelText
        : Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(
                leadingIcon,
                size: 16,
                color: leadingIconColor ?? (labelColor ?? ThemeV2.primary),
              ),
              const SizedBox(width: 6),
              labelText,
            ],
          );
    final valueStyle = interNums(
      fontSize: valueFontSize,
      fontWeight: FontWeight.w600,
      color: valueColor ?? ThemeV2.textPrimary,
      letterSpacing: -0.3,
    );
    final valueText = goldValue
        ? themedPriceText(value, palette, valueStyle)
        : Text(value, style: valueStyle);

    // The gradient-border wrapper (themedBorder) already draws a border
    // around this cell when the theme defines one — don't also draw this
    // flat divider border, or the two would double up.
    final hasThemedBorder = palette.borderGradient != null;
    // bgColor (e.g. changeBg) is a translucent tint meant to sit on a
    // white background — at only ~10% alpha it let the gold border's
    // gradient bleed through and read as a solid gold box once the
    // backdrop became dark. Fall back to the theme's own window gradient
    // (same one the other two windows in this widget use) instead; the
    // up/down signal still comes through via labelColor/valueColor.
    final effectiveGradient =
        gradient ??
        (hasThemedBorder
            ? (palette.windowGradient ?? darkCardGradient())
            : null);
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
      decoration: BoxDecoration(
        color: effectiveGradient == null ? bgColor : null,
        gradient: effectiveGradient,
        borderRadius: BorderRadius.circular(16),
        border: effectiveGradient == null && !hasThemedBorder
            ? Border.all(color: ThemeV2.divider)
            : null,
      ),
      child: horizontalLayout
          ? Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [labelWidget, valueText],
            )
          : Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [labelText, const SizedBox(height: 4), valueText],
            ),
    );
  }

  /// Emotional headline + body, keyed by the day's percent move. Thresholds
  /// split each direction into a "small" and "strong" band, with a ±0.1%
  /// dead zone in the middle counting as neutral.
  _Mood _moodFor(AppLocalizations l10n, double changePercent) {
    if (changePercent >= 1.0) {
      return _Mood(l10n.moodBullishTitle, l10n.moodBullishBody);
    }
    if (changePercent > 0.1) {
      return _Mood(l10n.moodSteadyClimbTitle, l10n.moodSteadyClimbBody);
    }
    if (changePercent >= -0.1) {
      return _Mood(l10n.moodWaitingTitle, l10n.moodWaitingBody);
    }
    if (changePercent >= -1.0) {
      return _Mood(l10n.moodCautionTitle, l10n.moodCautionBody);
    }
    return _Mood(l10n.moodStormTitle, l10n.moodStormBody);
  }
}

class _Mood {
  final String title;
  final String body;
  const _Mood(this.title, this.body);
}
