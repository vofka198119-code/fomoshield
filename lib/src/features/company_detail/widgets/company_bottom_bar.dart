import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../../core/theme/theme_v2.dart';
import '../../../core/theme/app_palette.dart';
import '../../market_clock/market_clock_dial.dart' show buyButtonDecoration;
import '../../../core/theme/themed_border.dart';
import '../../../l10n/gen/app_localizations.dart';

// ===========================================================================
// Sticky Bottom Bar: BUY / SELL
// ===========================================================================
// BUY/SELL keep their real green/white fills in both themes — deliberately
// NOT switched to the gold/graphite CTA look every other button gets. Under
// Luxury Gold they just pick up the shared gold gradient ring (themedBorder,
// a no-op on Standard since palette.borderGradient is null there).

class CompanyBottomBar extends StatelessWidget {
  final double price;
  final bool isUp;
  final VoidCallback onBuy;
  final VoidCallback onSell;
  final AppPalette palette;
  // Override the button text without touching styling -- used in fund
  // context (2026-09-12) where tapping doesn't trade directly, it opens
  // Propose Trade with the symbol prefilled, so "Создать ордер на
  // покупку/продажу" reads more honestly than plain "Купить"/"Продать".
  // Null (every other call site) keeps the original labels.
  final String? buyLabel;
  final String? sellLabel;

  const CompanyBottomBar({
    super.key,
    required this.price,
    required this.isUp,
    required this.onBuy,
    required this.onSell,
    required this.palette,
    this.buyLabel,
    this.sellLabel,
  });

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    return Container(
      padding: EdgeInsets.only(
        top: 8,
        bottom: MediaQuery.of(context).padding.bottom + 8,
        left: 16,
        right: 16,
      ),
      decoration: BoxDecoration(
        color: Colors.transparent,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.06),
            blurRadius: 8,
            offset: const Offset(0, -2),
          ),
        ],
      ),
      child: Row(
        children: [
          // BUY button — dark-green brand gradient, white text.
          Expanded(
            child: Center(
              child: FractionallySizedBox(
                widthFactor: 0.94,
                child: SizedBox(
                  height: 47,
                  child: themedBorder(
                    palette: palette,
                    borderRadius: BorderRadius.circular(18),
                    child: Material(
                      color: Colors.transparent,
                      borderRadius: BorderRadius.circular(18),
                      child: Ink(
                        decoration: buyButtonDecoration(
                          borderRadius: BorderRadius.circular(18),
                        ),
                        child: InkWell(
                          onTap: onBuy,
                          borderRadius: BorderRadius.circular(18),
                          child: Center(
                            child: Padding(
                              padding: const EdgeInsets.symmetric(
                                horizontal: 6,
                              ),
                              child: FittedBox(
                                fit: BoxFit.scaleDown,
                                child: Text(
                                  buyLabel ?? l10n.tradeBuy,
                                  maxLines: 1,
                                  style: GoogleFonts.inter(
                                    fontSize: 16,
                                    fontWeight: FontWeight.w700,
                                    color: Colors.white,
                                  ),
                                ),
                              ),
                            ),
                          ),
                        ),
                      ),
                    ),
                  ),
                ),
              ),
            ),
          ),
          const SizedBox(width: 12),
          // SELL button — brand olive fill (same tone as Portfolio Balance
          // cell: primaryBg flattened to opaque), black text.
          Expanded(
            child: Center(
              child: FractionallySizedBox(
                widthFactor: 0.94,
                child: SizedBox(
                  height: 47,
                  child: themedBorder(
                    palette: palette,
                    borderRadius: BorderRadius.circular(18),
                    child: ElevatedButton(
                      onPressed: onSell,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Color.alphaBlend(
                          ThemeV2.primaryBg,
                          Colors.white,
                        ),
                        foregroundColor: Colors.black,
                        // Matches the BUY button's own 6px Padding exactly
                        // (2026-09-12) -- ElevatedButton's own default
                        // padding is much wider, so the two FittedBoxes had
                        // different available width and scaled their equal-
                        // length labels to two different font sizes.
                        padding: const EdgeInsets.symmetric(horizontal: 6),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(18),
                        ),
                        elevation: 0,
                      ),
                      child: FittedBox(
                        fit: BoxFit.scaleDown,
                        child: Text(
                          sellLabel ?? l10n.tradeSell,
                          maxLines: 1,
                          style: GoogleFonts.inter(
                            fontSize: 16,
                            fontWeight: FontWeight.w700,
                            color: Colors.black,
                          ),
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
}
