import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../../core/theme/app_palette.dart';
import '../../../core/theme/themed_divider.dart';

// ---------------------------------------------------------------------------
// Company History Tile — one row in the "Companies" widget/screen: fund
// icon left (a themed ring, same recipe as FundManagementScreen's own name
// card — no fund logo upload exists), name + ticker stacked next to it,
// role right-aligned. Same row shape/sizing as trade_history_tile.dart
// (40x40 ring, 14/w600 name, 11/body subtitle) so this list reads as the
// same visual system as Portfolio's Trade History/Watchlist rows, per
// explicit ask.
// ---------------------------------------------------------------------------

class CompanyHistoryTile extends StatelessWidget {
  final String fundName;
  final String fundTicker;
  final String roleLabel;
  final bool isActive;
  final AppPalette palette;
  final VoidCallback? onTap;
  final bool showDivider;

  const CompanyHistoryTile({
    super.key,
    required this.fundName,
    required this.fundTicker,
    required this.roleLabel,
    required this.isActive,
    required this.palette,
    this.onTap,
    this.showDivider = false,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        Material(
          color: Colors.transparent,
          child: InkWell(
            onTap: onTap,
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
              child: Row(
                children: [
                  Container(
                    width: 40,
                    height: 40,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      border: Border.all(
                        color: palette.accentPrimary.withValues(alpha: 0.3),
                        width: 1.5,
                      ),
                    ),
                    padding: const EdgeInsets.all(2),
                    child: Container(
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        gradient: palette.windowGradient,
                        color: palette.windowGradient == null
                            ? palette.accentPrimary.withValues(alpha: 0.15)
                            : null,
                      ),
                      child: Icon(
                        Icons.account_balance_rounded,
                        color: palette.accentPrimary,
                        size: 18,
                      ),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Text(
                          fundName,
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: GoogleFonts.inter(
                            fontSize: 14,
                            fontWeight: FontWeight.w600,
                            color: palette.textHeader,
                          ),
                        ),
                        const SizedBox(height: 2),
                        Text(
                          fundTicker,
                          style: GoogleFonts.inter(
                            fontSize: 11,
                            color: palette.textBody,
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(width: 8),
                  Text(
                    roleLabel,
                    style: GoogleFonts.inter(
                      fontSize: 13,
                      fontWeight: FontWeight.w700,
                      color: isActive
                          ? palette.textHeader
                          : palette.textBody,
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
        if (showDivider) themedDivider(palette),
      ],
    );
  }
}
