import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../../core/theme/app_palette.dart';
import '../../../core/theme/themed_divider.dart';
import '../models/fund.dart';

// ---------------------------------------------------------------------------
// FundMiniCard — one row inside a Funds browse lane (ETF Fund Emulation).
// Same row chrome as Search's CompanyMiniCard (ring avatar, name + subtitle
// stacked, thin bottom divider) — see that file's own doc comment for the
// shared recipe. Differs only in trailing content: NAV/unit + up/down is
// already sitting in the same fundsListProvider response FundsTabList's own
// flat-list row (_FundRow) shows, so unlike CompanyMiniCard (which
// deliberately omits price to avoid a live per-row quote call) there's no
// extra cost to showing it here too.
// ---------------------------------------------------------------------------

class FundMiniCard extends StatelessWidget {
  final Fund fund;
  final AppPalette palette;
  final VoidCallback? onTap;
  final bool showDivider;

  const FundMiniCard({
    super.key,
    required this.fund,
    required this.palette,
    this.onTap,
    this.showDivider = false,
  });

  @override
  Widget build(BuildContext context) {
    final up = fund.navPerUnit >= 10.0; // vs. the $10.00 launch NAV
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        GestureDetector(
          onTap: onTap,
          behavior: HitTestBehavior.opaque,
          child: Container(
            constraints: const BoxConstraints(minHeight: 66),
            padding: const EdgeInsets.symmetric(horizontal: 22, vertical: 6),
            child: Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(2),
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    border: Border.all(
                      color: palette.accentPrimary,
                      width: 1.5,
                    ),
                  ),
                  child: CircleAvatar(
                    radius: 18,
                    backgroundColor: palette.accentPrimary.withValues(
                      alpha: 0.15,
                    ),
                    child: Text(
                      fund.ticker.length > 4
                          ? fund.ticker.substring(0, 4)
                          : fund.ticker,
                      style: GoogleFonts.inter(
                        fontSize: 10,
                        fontWeight: FontWeight.w800,
                        color: palette.accentPrimary,
                      ),
                    ),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text(
                        fund.name,
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
                        fund.ticker,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: GoogleFonts.inter(
                          fontSize: 11,
                          // Same fix as watchlist_widget.dart's tile — see
                          // its comment.
                          color: palette.titleGradient != null
                              ? Colors.white.withValues(alpha: 0.85)
                              : palette.textBody,
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(width: 8),
                Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  crossAxisAlignment: CrossAxisAlignment.end,
                  children: [
                    Text(
                      '\$${fund.navPerUnit.toStringAsFixed(2)}',
                      style: GoogleFonts.inter(
                        fontSize: 14,
                        fontWeight: FontWeight.w700,
                        color: palette.textHeader,
                      ),
                    ),
                    Text(
                      up ? '▲' : '▼',
                      style: GoogleFonts.inter(
                        fontSize: 11,
                        color: up ? Colors.green : Colors.red,
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
        if (showDivider) themedRowDivider(palette),
      ],
    );
  }
}
