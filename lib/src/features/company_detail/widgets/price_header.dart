import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../../core/theme/theme_v2.dart';
import '../../../core/theme/fomo_shield_theme.dart';
import '../../../core/theme/typography_helpers.dart';
import '../../../core/theme/app_palette.dart';
import '../../../shared/widgets/card_frame.dart';
import '../../../core/services/gics_sector_mapper.dart';
import '../../../l10n/gen/app_localizations.dart';
import '../../../shared/utils/currency_format.dart';
import '../../../shared/widgets/company_logo.dart';
import '../../market_clock/market_clock_dial.dart'
    show dialBrassLight, darkCardDecoration;
import '../../market_clock/market_clock_engine.dart'
    show MarketPhase, nowInNewYork, resolveMarketPhase;

// ===========================================================================
// Market session label — reuses Market Clock's real Eastern-time engine
// (nowInNewYork/resolveMarketPhase, DST-aware) instead of the phone's
// local clock, so this always agrees with the actual NYSE session.
// ===========================================================================

String _phaseLabel(AppLocalizations l10n, MarketPhase p) => switch (p) {
  MarketPhase.preMarket => l10n.companyDetailPhasePreMarket,
  MarketPhase.marketOpen => l10n.companyDetailPhaseMarketOpen,
  MarketPhase.afterHours => l10n.companyDetailPhasePostMarket,
  MarketPhase.closed => l10n.companyDetailPhaseMarketClosed,
};

// ===========================================================================
// Price Header — brand dark-green hero card (logo/name/price/change always
// pinned first, not part of the widget order system)
// ===========================================================================

class PriceHeader extends StatelessWidget {
  final String? logo;
  final String companyName;
  final String symbol;
  final double price;
  final double change;
  final double changePercent;
  final bool isUp;
  final String changeLabel;
  final int? fsScore;
  // Stress Test assets aren't real companies and never have a score — set
  // false there to drop the slot entirely instead of showing an empty box.
  final bool showFsScore;
  // Overrides the real-NYSE-time phase label/color computed below — for
  // callers whose price isn't a real market price (Stress Test's
  // simulated engine has its own always-open semantics; showing the
  // actual NYSE session there would misrepresent it).
  final String? phaseLabel;
  final Color? phaseLabelColor;
  final bool phaseGlow;
  // Stress Test's simulated market has no real session concept to show
  // (always tradeable) and no real NYSE phase to fall back to either —
  // false there drops the session label from the price cell entirely
  // instead of showing something fake or misleadingly real.
  final bool showSessionLabel;
  final AppPalette palette;

  const PriceHeader({
    super.key,
    this.logo,
    required this.companyName,
    required this.symbol,
    required this.price,
    required this.change,
    required this.changePercent,
    required this.isUp,
    this.changeLabel = 'CHANGE',
    this.fsScore,
    this.showFsScore = true,
    this.phaseLabel,
    this.phaseLabelColor,
    this.phaseGlow = false,
    this.showSessionLabel = true,
    required this.palette,
  });

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final changeColor = isUp ? ThemeV2.success : ThemeV2.loss;
    // Home Portfolio widget's cell fills are a 10%-alpha tint meant for a
    // light card background — flattened against white here so it still
    // reads as a distinct tinted box instead of nearly disappearing.
    final changeCellBg = Color.alphaBlend(
      isUp ? ThemeV2.successBg : ThemeV2.lossBg,
      Colors.white,
    );
    // Home Portfolio widget's tints are 10%-alpha, meant for a light card
    // background — flattened to opaque here so they still read as distinct
    // boxes on top of/next to this card's dark-green gradient instead of
    // nearly disappearing into it.
    final sectorBadgeBg = Color.alphaBlend(ThemeV2.primaryBg, Colors.white);
    final sector = resolveGicsSector(symbol, companyName: companyName);

    return Column(
      children: [
        // Name card — logo/name/ticker/sector, always pinned first (not
        // part of the widget order system).
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16),
          child: CardFrame(
            showTopBar: false,
            padding: const EdgeInsets.all(FomoShieldTheme.cardPadding),
            decoration: darkCardDecoration(),
            palette: palette,
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Container(
                  padding: const EdgeInsets.all(2),
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    border: Border.all(color: dialBrassLight, width: 1.5),
                    boxShadow: [
                      BoxShadow(
                        color: dialBrassLight.withValues(alpha: 0.35),
                        blurRadius: 6,
                      ),
                    ],
                  ),
                  child: CompanyLogo(ticker: symbol, logoUrl: logo, radius: 30),
                ),
                const SizedBox(width: 10),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        companyName,
                        style: GoogleFonts.inter(
                          fontSize: 15,
                          fontWeight: FontWeight.w600,
                          color: Colors.white,
                        ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                      Text(
                        symbol,
                        style: GoogleFonts.inter(
                          fontSize: 12,
                          color: Colors.white,
                        ),
                      ),
                      if (sector != null) ...[
                        const SizedBox(height: 6),
                        Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 6,
                            vertical: 1,
                          ),
                          decoration: BoxDecoration(
                            color: sectorBadgeBg,
                            borderRadius: BorderRadius.circular(6),
                          ),
                          child: Text(
                            sector.localizedLabel(AppLocalizations.of(context)!),
                            style: GoogleFonts.inter(
                              fontSize: 10,
                              fontWeight: FontWeight.w600,
                              color: palette.accentPrimary,
                            ),
                          ),
                        ),
                      ],
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
        const SizedBox(height: 16),
        // Price cell — wide enough for 4-digit prices (e.g. 1234.098) but
        // not edge-to-edge, gradient-backed to match the name card, gold
        // value with a subtle glow, and a market-session read (gold+glow
        // only while the regular session is actually open).
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16),
          child: IntrinsicHeight(
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Expanded(
                  flex: showFsScore ? 7 : 10,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      _priceCell(l10n),
                      const SizedBox(height: 10),
                      // Change — fill/colors unchanged for now (still the
                      // olive/success/loss tint used elsewhere), just
                      // repositioned below the price cell.
                      _cell(
                        label: changeLabel,
                        bgColor: changeCellBg,
                        valueColor: changeColor,
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Icon(
                              isUp
                                  ? Icons.trending_up_rounded
                                  : Icons.trending_down_rounded,
                              size: 16,
                              color: changeColor,
                            ),
                            const SizedBox(width: 3),
                            Flexible(
                              child: Text(
                                '${formatUsdSigned(change)} (${isUp ? '+' : ''}${changePercent.toStringAsFixed(2)}%)',
                                style: interNums(
                                  fontSize: 14,
                                  fontWeight: FontWeight.w600,
                                  color: changeColor,
                                ),
                                overflow: TextOverflow.ellipsis,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
                if (showFsScore) ...[
                  const SizedBox(width: 10),
                  // FS Score gauge — duplicates FinancialScoreWidget's
                  // circle so the score is visible without scrolling down.
                  Expanded(
                    flex: 3,
                    child: fsScore == null
                        ? Container(
                            decoration: BoxDecoration(
                              gradient: palette.windowGradient,
                              color: palette.windowGradient == null
                                  ? Colors.white
                                  : null,
                              borderRadius: BorderRadius.circular(16),
                              border: Border.all(color: ThemeV2.divider),
                            ),
                          )
                        : _fsScoreCell(l10n, fsScore!),
                  ),
                ],
              ],
            ),
          ),
        ),
      ],
    );
  }

  Color _gaugeColor(int score) {
    if (score >= 70) return ThemeV2.success;
    if (score >= 40) return ThemeV2.warning;
    return ThemeV2.loss;
  }

  // Green-gradient card duplicating FinancialScoreWidget's circular gauge,
  // so the score is visible right at the top without scrolling down.
  Widget _fsScoreCell(AppLocalizations l10n, int score) {
    final color = _gaugeColor(score);

    // Manually gated rather than CardFrame — this cell's inner Column has
    // an Expanded (the gauge circle fills the cell's own bounded height),
    // which needs the outer Container to pass tight constraints straight
    // through; CardFrame's own mainAxisSize.min wrapper Column isn't a
    // safe fit for that here.
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 10),
      decoration: palette.borderGradient != null
          ? BoxDecoration(
              gradient: palette.cardGradient,
              borderRadius: BorderRadius.circular(16),
              boxShadow: [if (palette.cardGlow != null) palette.cardGlow!],
            )
          : darkCardDecoration(borderRadius: BorderRadius.circular(16)),
      child: Column(
        children: [
          Text(
            l10n.companyDetailFsScoreLabel,
            style: GoogleFonts.inter(
              fontSize: 10,
              fontWeight: FontWeight.w700,
              letterSpacing: 0.6,
              color: Colors.white,
            ),
          ),
          const SizedBox(height: 8),
          Expanded(
            child: Center(
              child: FractionallySizedBox(
                widthFactor: 0.9,
                heightFactor: 0.9,
                child: AspectRatio(
                  aspectRatio: 1,
                  child: Container(
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      gradient: palette.windowGradient,
                      color: palette.windowGradient == null
                          ? ThemeV2.surface
                          : null,
                      border: Border.all(
                        color: color.withValues(alpha: 0.3),
                        width: 3,
                      ),
                      boxShadow: [
                        BoxShadow(
                          color: color.withValues(alpha: 0.1),
                          blurRadius: 20,
                          spreadRadius: 3,
                        ),
                      ],
                    ),
                    child: Center(
                      child: Text(
                        '$score',
                        style: GoogleFonts.inter(
                          fontSize: 24,
                          fontWeight: FontWeight.w900,
                          color: color,
                          letterSpacing: -1,
                        ),
                      ),
                    ),
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _priceCell(AppLocalizations l10n) {
    String sessionLabel = '';
    bool isOpen = false;
    if (showSessionLabel) {
      if (phaseLabel != null) {
        sessionLabel = phaseLabel!;
        isOpen = phaseGlow;
      } else {
        final phase = resolveMarketPhase(nowInNewYork());
        sessionLabel = _phaseLabel(l10n, phase);
        isOpen = phase == MarketPhase.marketOpen;
      }
    }
    final sessionColor =
        phaseLabelColor ?? (isOpen ? dialBrassLight : Colors.white);

    return CardFrame(
      showTopBar: false,
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
      decoration: darkCardDecoration(borderRadius: BorderRadius.circular(16)),
      palette: palette,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Text(
                l10n.companyDetailPriceLabel,
                style: GoogleFonts.inter(
                  fontSize: 10,
                  fontWeight: FontWeight.w700,
                  letterSpacing: 0.6,
                  color: Colors.white,
                ),
              ),
              if (showSessionLabel) ...[
                const Spacer(),
                Text(
                  sessionLabel,
                  style: GoogleFonts.inter(
                    fontSize: 9,
                    fontWeight: FontWeight.w700,
                    letterSpacing: 0.5,
                    color: sessionColor,
                    shadows: isOpen
                        ? [
                            Shadow(
                              color: dialBrassLight.withValues(alpha: 0.5),
                              blurRadius: 6,
                            ),
                          ]
                        : null,
                  ),
                ),
              ],
            ],
          ),
          const SizedBox(height: 4),
          FittedBox(
            fit: BoxFit.scaleDown,
            alignment: Alignment.centerLeft,
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                Icon(Icons.attach_money_rounded, size: 26, color: sessionColor),
                Text(
                  price.toStringAsFixed(2),
                  style:
                      interNums(
                        fontSize: 32,
                        fontWeight: FontWeight.w600,
                        color: sessionColor,
                        height: 1,
                      ).copyWith(
                        shadows: isOpen
                            ? [
                                Shadow(
                                  color: dialBrassLight.withValues(alpha: 0.5),
                                  blurRadius: 6,
                                ),
                              ]
                            : null,
                      ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  // Same shape as Home Portfolio widget's `_cell`: small caps label, then
  // the value — kept flexible (a widget, not just text) so the change
  // cell can show its trending icon alongside the number.
  Widget _cell({
    required String label,
    required Color bgColor,
    required Color valueColor,
    required Widget child,
  }) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
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
              color: palette.accentPrimary,
            ),
          ),
          const SizedBox(height: 4),
          FittedBox(
            fit: BoxFit.scaleDown,
            alignment: Alignment.centerLeft,
            child: child,
          ),
        ],
      ),
    );
  }
}
