import 'package:flutter/material.dart';
import '../../../core/theme/fomo_shield_theme.dart';
import '../../../core/theme/app_palette.dart';
import '../../../core/theme/themed_header.dart';
import '../../../core/theme/themed_divider.dart';
import '../../../shared/widgets/card_frame.dart';

// ---------------------------------------------------------------------------
// BrowseLane — titled card containing a vertical stack of row widgets
// (Watchlist-style). Shared by every browse-lane surface in the app: Search
// screen's Companies tab (Top S&P 500, per-sector tops, Recently Viewed —
// CompanyMiniCard rows) and Funds tab (fund_browse_lanes.dart's
// FundMiniCard rows). `items` is untyped Widget on purpose so both can
// share this one shell instead of each screen rolling its own card chrome.
// ---------------------------------------------------------------------------

class BrowseLane extends StatelessWidget {
  final String title;
  final List<Widget> items;
  final VoidCallback? onSeeAll;
  final AppPalette palette;

  const BrowseLane({
    super.key,
    required this.title,
    required this.items,
    required this.palette,
    this.onSeeAll,
  });

  @override
  Widget build(BuildContext context) {
    return CardFrame(
      decoration: FomoShieldTheme.cardDecoration,
      padding: const EdgeInsets.fromLTRB(0, 14, 0, 16),
      palette: palette,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 22),
            child: Row(
              children: [
                Expanded(
                  child: themedHeaderText(
                    title,
                    palette,
                    FomoShieldTheme.cardTitle(),
                  ),
                ),
                if (onSeeAll != null)
                  InkWell(
                    onTap: onSeeAll,
                    borderRadius: BorderRadius.circular(20),
                    child: Padding(
                      padding: const EdgeInsets.all(4),
                      child: Icon(
                        Icons.chevron_right_rounded,
                        color: palette.textBody,
                        size: 22,
                      ),
                    ),
                  ),
              ],
            ),
          ),
          const SizedBox(height: 14),
          palette.dividerGradient != null
              ? themedDivider(palette)
              : const Divider(
                  height: 1,
                  indent: 22,
                  endIndent: 22,
                  color: Color(0x0F000000),
                ),
          for (int i = 0; i < items.length; i++) items[i],
        ],
      ),
    );
  }
}
