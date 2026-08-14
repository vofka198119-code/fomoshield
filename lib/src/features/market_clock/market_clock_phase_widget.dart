import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../core/theme/theme_v2.dart';
import '../../core/theme/fomo_shield_theme.dart';
import 'market_clock_engine.dart';

// ---------------------------------------------------------------------------
// Market Phase widget (id: 'market_phase') — same Home-card look as every
// other widget on Home (title bar + divider via FomoShieldTheme), instead of
// the old plain surface box.
// ---------------------------------------------------------------------------

class MarketPhaseWidget extends StatelessWidget {
  final MarketWindow window;
  final bool isEarlyClose;
  const MarketPhaseWidget({
    super.key,
    required this.window,
    required this.isEarlyClose,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: FomoShieldTheme.cardDecoration,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          InkWell(
            onTap: () => context.push('/market-clock/phases'),
            child: Padding(
              padding: const EdgeInsets.fromLTRB(22, 14, 22, 14),
              child: Row(
                children: [
                  Text('MARKET PHASE', style: FomoShieldTheme.cardTitle()),
                  const Spacer(),
                  const Icon(
                    Icons.chevron_right_rounded,
                    color: ThemeV2.textSecondary,
                    size: 20,
                  ),
                ],
              ),
            ),
          ),
          Divider(
            height: 1,
            indent: 16,
            endIndent: 16,
            color: Colors.black.withValues(alpha: 0.06),
          ),
          Padding(
            padding: const EdgeInsets.all(16),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Text(
                            window.emoji,
                            style: const TextStyle(fontSize: 18),
                          ),
                          const SizedBox(width: 8),
                          Expanded(
                            child: Text(
                              window.shortHeadline,
                              style: GoogleFonts.inter(
                                fontSize: 15,
                                fontWeight: FontWeight.w700,
                                color: ThemeV2.textPrimary,
                              ),
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 6),
                      Text(
                        window.shortDetail,
                        style: GoogleFonts.inter(
                          fontSize: 13,
                          color: ThemeV2.textSecondary,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        window.timeRangeLabel,
                        style: GoogleFonts.inter(
                          fontSize: 11,
                          fontWeight: FontWeight.w500,
                          color: ThemeV2.primary,
                        ),
                      ),
                    ],
                  ),
                ),
                IconButton(
                  onPressed: () =>
                      context.push('/market-clock/period/${window.id}'),
                  icon: const Icon(
                    Icons.help_outline_rounded,
                    color: ThemeV2.primary,
                  ),
                  tooltip: 'Details',
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
