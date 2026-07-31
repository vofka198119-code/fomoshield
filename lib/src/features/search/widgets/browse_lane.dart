import 'package:flutter/material.dart';
import '../../../core/theme/fomo_shield_theme.dart';
import '../../../core/theme/theme_v2.dart';
import 'company_mini_card.dart';

// ---------------------------------------------------------------------------
// BrowseLane — titled card containing a horizontally scrolling row of
// CompanyMiniCard entries. Shared by all Search-screen browse widgets (Top
// S&P 500, per-sector tops, Recently Viewed).
// ---------------------------------------------------------------------------

class BrowseLane extends StatelessWidget {
  final String title;
  final List<CompanyMiniCard> items;
  final VoidCallback? onSeeAll;

  const BrowseLane({
    super.key,
    required this.title,
    required this.items,
    this.onSeeAll,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: FomoShieldTheme.cardDecoration,
      padding: const EdgeInsets.fromLTRB(0, 14, 0, 16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 22),
            child: Row(
              children: [
                Expanded(
                  child: Text(title, style: FomoShieldTheme.cardTitle()),
                ),
                if (onSeeAll != null)
                  InkWell(
                    onTap: onSeeAll,
                    borderRadius: BorderRadius.circular(20),
                    child: const Padding(
                      padding: EdgeInsets.all(4),
                      child: Icon(
                        Icons.chevron_right_rounded,
                        color: ThemeV2.primary,
                        size: 22,
                      ),
                    ),
                  ),
              ],
            ),
          ),
          const SizedBox(height: 14),
          const Divider(
            height: 1,
            indent: 22,
            endIndent: 22,
            color: Color(0x0F000000),
          ),
          const SizedBox(height: 14),
          SizedBox(
            height: 128,
            child: ListView.separated(
              scrollDirection: Axis.horizontal,
              padding: const EdgeInsets.symmetric(horizontal: 22),
              itemCount: items.length,
              separatorBuilder: (_, _) => const SizedBox(width: 14),
              itemBuilder: (context, i) => items[i],
            ),
          ),
        ],
      ),
    );
  }
}
