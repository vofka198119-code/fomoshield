import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../../core/theme/theme_v2.dart';
import '../../../core/theme/fomo_shield_theme.dart';
import '../../../core/theme/typography_helpers.dart';
import '../../../core/services/gics_sector_mapper.dart';
import '../../../shared/widgets/company_logo.dart';
import '../../market_clock/market_clock_dial.dart' show dialLight, dialDark, dialBrassLight;

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

  const PriceHeader({
    super.key,
    this.logo,
    required this.companyName,
    required this.symbol,
    required this.price,
    required this.change,
    required this.changePercent,
    required this.isUp,
  });

  @override
  Widget build(BuildContext context) {
    final changeColor = isUp ? ThemeV2.success : ThemeV2.loss;
    // Home Portfolio widget's cell fills are a 10%-alpha tint meant for a
    // light card background — flattened against white here so they still
    // read as a distinct olive/tinted box on top of this card's dark-green
    // gradient instead of nearly disappearing into it.
    final priceCellBg = Color.alphaBlend(ThemeV2.primaryBg, Colors.white);
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
          child: Container(
            padding: const EdgeInsets.all(FomoShieldTheme.cardPadding),
            decoration: BoxDecoration(
              gradient: const LinearGradient(
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
                colors: [dialLight, dialDark],
              ),
              borderRadius: FomoShieldTheme.cardRadius,
            ),
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
                            sector.label,
                            style: GoogleFonts.inter(
                              fontSize: 10,
                              fontWeight: FontWeight.w600,
                              color: ThemeV2.primary,
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
        // Price + change — own row, same cell shape as Home's Portfolio
        // widget (PORTFOLIO BALANCE / CHANGE), price kept at its existing
        // larger display size.
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Expanded(
                child: _cell(
                  label: 'PRICE',
                  bgColor: priceCellBg,
                  valueColor: ThemeV2.textPrimary,
                  child: Text(
                    '\$${price.toStringAsFixed(2)}',
                    style: interNums(
                      fontSize: 32,
                      fontWeight: FontWeight.w600,
                      color: ThemeV2.textPrimary,
                      height: 1,
                    ),
                  ),
                ),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: _cell(
                  label: 'CHANGE',
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
                          '${isUp ? '+' : ''}${change.toStringAsFixed(2)} (${changePercent.toStringAsFixed(2)}%)',
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
              ),
            ],
          ),
        ),
      ],
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
              color: ThemeV2.primary,
            ),
          ),
          const SizedBox(height: 4),
          FittedBox(fit: BoxFit.scaleDown, alignment: Alignment.centerLeft, child: child),
        ],
      ),
    );
  }
}
