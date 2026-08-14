import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../../core/theme/theme_v2.dart';
import '../../market_clock/market_clock_dial.dart'
    show dialBrassLight, darkCardDecoration;

// ===========================================================================
// Select Portfolio — option row for the multi-portfolio Buy/Sell sheet
// ===========================================================================

class PortfolioOptionTile extends StatelessWidget {
  final String name;
  final double cash;
  final bool isPremium;
  final VoidCallback onTap;

  const PortfolioOptionTile({
    super.key,
    required this.name,
    required this.cash,
    required this.isPremium,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.all(14),
        decoration: BoxDecoration(
          color: ThemeV2.primaryBg,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: ThemeV2.divider),
        ),
        child: Row(
          children: [
            Container(
              width: 40,
              height: 40,
              decoration: darkCardDecoration(
                borderRadius: BorderRadius.circular(10),
              ),
              alignment: Alignment.center,
              child: Icon(
                Icons.account_balance_wallet_rounded,
                color: isPremium ? dialBrassLight : Colors.white,
                size: 20,
              ),
            ),
            const SizedBox(width: 14),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Flexible(
                        child: Text(
                          name,
                          overflow: TextOverflow.ellipsis,
                          style: GoogleFonts.inter(
                            fontSize: 15,
                            fontWeight: FontWeight.w700,
                            color: ThemeV2.primary,
                          ),
                        ),
                      ),
                      if (isPremium) ...[
                        const SizedBox(width: 6),
                        _premiumBadge(),
                      ],
                    ],
                  ),
                  const SizedBox(height: 2),
                  Text(
                    '\$${cash.toStringAsFixed(2)} available',
                    style: GoogleFonts.inter(
                      fontSize: 12,
                      color: ThemeV2.textSecondary,
                    ),
                  ),
                ],
              ),
            ),
            Icon(Icons.chevron_right_rounded, color: ThemeV2.textSecondary),
          ],
        ),
      ),
    );
  }

  Widget _premiumBadge() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 5, vertical: 1.5),
      decoration: darkCardDecoration(borderRadius: BorderRadius.circular(5)),
      child: Text(
        'PREMIUM',
        style: GoogleFonts.inter(
          fontSize: 8,
          fontWeight: FontWeight.w800,
          color: dialBrassLight,
          letterSpacing: 1.0,
          shadows: [
            Shadow(color: dialBrassLight.withValues(alpha: 0.5), blurRadius: 6),
          ],
        ),
      ),
    );
  }
}
