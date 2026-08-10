import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../../core/theme/theme_v2.dart';
import '../../market_clock/market_clock_dial.dart' show dialLight, dialDark;

// ===========================================================================
// Sticky Bottom Bar: BUY / SELL
// ===========================================================================

class CompanyBottomBar extends StatelessWidget {
  final double price;
  final bool isUp;
  final VoidCallback onBuy;
  final VoidCallback onSell;

  const CompanyBottomBar({
    super.key,
    required this.price,
    required this.isUp,
    required this.onBuy,
    required this.onSell,
  });

  @override
  Widget build(BuildContext context) {
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
                  child: Material(
                    color: Colors.transparent,
                    borderRadius: BorderRadius.circular(18),
                    child: Ink(
                      decoration: BoxDecoration(
                        gradient: const LinearGradient(
                          begin: Alignment.topLeft,
                          end: Alignment.bottomRight,
                          colors: [dialLight, dialDark],
                        ),
                        borderRadius: BorderRadius.circular(18),
                      ),
                      child: InkWell(
                        onTap: onBuy,
                        borderRadius: BorderRadius.circular(18),
                        child: Center(
                          child: Text(
                            'BUY',
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
          const SizedBox(width: 12),
          // SELL button — brand olive fill (same tone as Portfolio Balance
          // cell: primaryBg flattened to opaque), black text.
          Expanded(
            child: Center(
              child: FractionallySizedBox(
                widthFactor: 0.94,
                child: SizedBox(
                  height: 47,
                  child: ElevatedButton(
                    onPressed: onSell,
                    style: ElevatedButton.styleFrom(
                      backgroundColor:
                          Color.alphaBlend(ThemeV2.primaryBg, Colors.white),
                      foregroundColor: Colors.black,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(18),
                      ),
                      elevation: 0,
                    ),
                    child: Text(
                      'SELL',
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
        ],
      ),
    );
  }
}
