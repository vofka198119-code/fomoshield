import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../core/theme/fomo_shield_theme.dart';
import '../../core/theme/app_palette.dart';
import '../../core/theme/themed_header.dart';
import '../../core/theme/themed_divider.dart';
import '../../shared/widgets/card_frame.dart';
import '../../l10n/gen/app_localizations.dart';
import 'market_clock_engine.dart';

// ---------------------------------------------------------------------------
// Market Phase widget (id: 'market_phase') — same Home-card look as every
// other widget on Home (title bar + divider via FomoShieldTheme), instead of
// the old plain surface box.
// ---------------------------------------------------------------------------

class MarketPhaseWidget extends StatelessWidget {
  final MarketWindow window;
  final bool isEarlyClose;
  final AppPalette palette;
  const MarketPhaseWidget({
    super.key,
    required this.window,
    required this.isEarlyClose,
    required this.palette,
  });

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    return CardFrame(
      padding: EdgeInsets.zero,
      decoration: FomoShieldTheme.cardDecoration,
      palette: palette,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          InkWell(
            onTap: () => context.push('/market-clock/phases'),
            child: Padding(
              padding: const EdgeInsets.fromLTRB(22, 14, 22, 14),
              child: Row(
                children: [
                  themedHeaderText(
                    l10n.marketPhaseWidgetTitle,
                    palette,
                    FomoShieldTheme.cardTitle(),
                  ),
                  const Spacer(),
                  Icon(
                    Icons.chevron_right_rounded,
                    color: palette.textBody,
                    size: 20,
                  ),
                ],
              ),
            ),
          ),
          themedDivider(palette),
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
                                color: palette.textHeader,
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
                          color: palette.textHeader,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        window.timeRangeLabel,
                        style: GoogleFonts.inter(
                          fontSize: 11,
                          fontWeight: FontWeight.w500,
                          color: palette.accentPrimary,
                        ),
                      ),
                    ],
                  ),
                ),
                IconButton(
                  onPressed: () =>
                      context.push('/market-clock/period/${window.id}'),
                  icon: Icon(
                    Icons.help_outline_rounded,
                    color: palette.accentPrimary,
                  ),
                  tooltip: l10n.marketPhaseWidgetDetailsTooltip,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
